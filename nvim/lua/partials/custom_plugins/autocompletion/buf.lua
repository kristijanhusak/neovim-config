local M = {}

local match = require('partials.custom_plugins.autocompletion.match')

local buf_cache = {} -- [bufnr] = { tick = N, words = {...} }

local function collect_buf_words(bufnr)
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  local c = buf_cache[bufnr]
  if c and c.tick == tick then
    return c.words
  end
  local words, seen = {}, {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    for w in line:gmatch('[%w_]+') do
      if #w > 1 and not seen[w] then
        seen[w] = true
        words[#words + 1] = w
      end
    end
  end
  buf_cache[bufnr] = { tick = tick, words = words }
  return words
end

--- Returns complete-items matching `prefix` from all loaded buffers.
function M.candidates(prefix)
  local icons = require('partials.utils').lsp_kind_icons()
  local seen, items = {}, {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      for _, w in ipairs(collect_buf_words(bufnr)) do
        local matched, score = match.match(w, prefix)
        if matched and not seen[w] and w ~= prefix then
          seen[w] = true
          items[#items + 1] = {
            word = w,
            menu = '[buf]',
            kind = icons.Text,
            kind_hlgroup = 'BlinkCmpKindText',
            icase = 1,
            dup = 0,
            empty = 1,
            _fuzzy_score = score,
          }
        end
      end
    end
  end
  if match.fuzzy_enabled() and prefix ~= '' then
    table.sort(items, function(a, b)
      return (a._fuzzy_score or 0) > (b._fuzzy_score or 0)
    end)
  end
  return items
end

--- Returns complete-items from the buffer's omnifunc (if set).
--- Falls back to empty list if omnifunc is absent, errors, or returns nothing.
function M.omni_candidates(base)
  local omnifunc = vim.bo.omnifunc
  if omnifunc == '' or omnifunc == 'v:lua._custom_completefunc' then
    return {}
  end
  local ok, result = pcall(vim.fn.call, omnifunc, { 0, base })
  if not ok or type(result) ~= 'table' then
    return {}
  end
  -- omnifunc may return a list directly or { words = {...}, refresh = ... }
  local list = result.words or result
  local items = {}
  for _, item in ipairs(list) do
    if type(item) == 'string' then
      items[#items + 1] = { word = item, menu = '[omni]', icase = 1, dup = 0, empty = 1 }
    elseif type(item) == 'table' and item.word then
      items[#items + 1] = vim.tbl_extend('keep', item, { menu = item.menu or '[omni]', icase = 1, dup = 0, empty = 1 })
    end
  end
  return items
end

return M
