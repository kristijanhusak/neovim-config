local M = {}

local protocol = vim.lsp.protocol
local match = require('partials.custom_plugins.autocompletion.match')

--- Extracts items from a CompletionList or CompletionItem[], applying itemDefaults.
function M.get_items(result)
  if result.items then
    for _, item in ipairs(result.items) do
      local d = result.itemDefaults
      if d then
        item.insertTextFormat = item.insertTextFormat or d.insertTextFormat
        item.data = item.data or d.data
        if not item.textEdit and d.editRange then
          item.textEdit = { newText = item.textEditText or item.insertText or item.label }
          if d.editRange.start then
            item.textEdit.range = d.editRange
          elseif d.editRange.insert then
            item.textEdit.insert = d.editRange.insert
            item.textEdit.replace = d.editRange.replace
          end
        end
      end
    end
    return result.items
  end
  return result
end

--- Returns the word to insert for a completion item.
--- For snippets, return clean text (label/filterText); the real snippet is expanded on CompleteDone.
local function item_word(item)
  if item.insertTextFormat == protocol.InsertTextFormat.Snippet then
    return item.filterText or item.label
  end
  if item.textEdit then
    return (item.textEdit.newText or ''):match('[^\n]+') or item.label
  end
  if item.insertText and item.insertText ~= '' then
    return item.insertText
  end
  return item.label
end

--- Converts LSP items to vim complete-items, filtered and sorted by sortText.
function M.candidates(items, prefix)
  local icons = require('partials.utils').lsp_kind_icons()
  local candidates = {}
  for _, item in ipairs(items) do
    local word = item_word(item)
    local matched, score = match.match(word, prefix)
    if matched then
      local kind = protocol.CompletionItemKind[item.kind] or 'Text'
      candidates[#candidates + 1] = {
        word = word,
        abbr = item.label,
        kind = icons[kind],
        kind_hlgroup = ('BlinkCmpKind%s'):format(kind),
        menu = ('[%s]'):format(kind),
        icase = 1,
        dup = 0,
        empty = 1,
        user_data = { nvim = { lsp = { completion_item = item, client_id = item._client_id } } },
        _fuzzy_score = score,
      }
    end
  end

  local by_sort_text = function(a, b)
    local ia = a.user_data.nvim.lsp.completion_item
    local ib = b.user_data.nvim.lsp.completion_item
    return (ia.sortText or ia.label) < (ib.sortText or ib.label)
  end

  if match.fuzzy_enabled() and prefix ~= '' then
    table.sort(candidates, function(a, b)
      local sa, sb = a._fuzzy_score or 0, b._fuzzy_score or 0
      if sa ~= sb then
        return sa > sb
      end
      return by_sort_text(a, b)
    end)
  else
    table.sort(candidates, by_sort_text)
  end

  return candidates
end

local trigger_cache = {} -- [client.name] = { [char] = true, ... }

local function get_trigger_set(client)
  if trigger_cache[client.name] then
    return trigger_cache[client.name]
  end
  local set = {}
  local triggers = vim.tbl_get(client, 'server_capabilities', 'completionProvider', 'triggerCharacters') or {}
  for _, ch in ipairs(triggers) do
    set[ch] = true
  end
  trigger_cache[client.name] = set
  return set
end

--- Returns the minimum textEdit start byte (0-indexed) across all items, or nil.
--- Mirrors adjust_start_col from vim/lsp/completion.lua.
function M.adjust_start_col(lnum, line, items, encoding)
  local min_start_char = nil
  for _, item in ipairs(items) do
    if item.textEdit then
      local start_char = nil
      if item.textEdit.range and item.textEdit.range.start.line == lnum then
        start_char = item.textEdit.range.start.character
      elseif item.textEdit.insert and item.textEdit.insert.start.line == lnum then
        start_char = item.textEdit.insert.start.character
      end
      if start_char and (not min_start_char or start_char < min_start_char) then
        min_start_char = start_char
      end
    end
  end
  if min_start_char then
    return vim.str_byteindex(line, encoding, min_start_char, false)
  end
end

--- Returns a set `{ [char] = true }` of trigger characters for `client`.
--- Result is cached by client name.
function M.trigger_set(client)
  return get_trigger_set(client)
end

return M
