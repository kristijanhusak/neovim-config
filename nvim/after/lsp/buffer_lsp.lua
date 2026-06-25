local methods = vim.lsp.protocol.Methods
local icons = require('partials.utils').lsp_kind_icons()
local buf_cache = {}

local enable_fuzzy = vim.list_contains(vim.opt.completeopt:get(), 'fuzzy')

--- Returns `matched, score`. Score is non-nil only for fuzzy matches.
local function matcher(value, prefix)
  if prefix == '' then
    return true, nil
  end
  if enable_fuzzy then
    local score = vim.fn.matchfuzzypos({ value }, prefix)[3] ---@type table
    if #score > 0 then
      return true, score[1]
    end
    return false, nil
  end
  if vim.o.ignorecase and (not vim.o.smartcase or not prefix:find('%u')) then
    return vim.startswith(value:lower(), prefix:lower()), nil
  end
  return vim.startswith(value, prefix), nil
end

local function collect_buf_words(bufnr)
  local tick = vim.api.nvim_buf_get_changedtick(bufnr)
  local c = buf_cache[bufnr]
  if c and c.tick == tick then
    return c.words
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  local words, seen = {}, {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
    for w in line:gmatch('[%w_]+') do
      if #w >= 3 and #w < 50 and not seen[w] then
        seen[w] = true
        words[#words + 1] = w
      end
    end
  end
  buf_cache[bufnr] = { tick = tick, words = words, name = name }
  return words
end

--- Returns complete-items matching `prefix` from all loaded buffers.
local function candidates(prefix)
  local seen, items = {}, {}
  local current_bufnr = vim.api.nvim_get_current_buf()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) then
      for _, w in ipairs(collect_buf_words(bufnr)) do
        local matched, score = matcher(w, prefix)
        local info = ''
        if bufnr ~= current_bufnr then
          info = buf_cache[bufnr] and buf_cache[bufnr].name or ''
          info = info ~= '' and vim.fn.fnamemodify(info, ':.') or ''
        end
        if matched and not seen[w] and w ~= prefix then
          seen[w] = true
          items[#items + 1] = {
            word = w,
            menu = '[buf]',
            kind = icons.Text,
            kind_hlgroup = 'BlinkCmpKindText',
            icase = 1,
            info = info,
            dup = 0,
            empty = 1,
            _fuzzy_score = score,
          }
        end
      end
    end
  end
  if enable_fuzzy and prefix ~= '' then
    table.sort(items, function(a, b)
      return (a._fuzzy_score or 0) > (b._fuzzy_score or 0)
    end)
  end
  return items
end

--- Returns complete-items from the buffer's omnifunc (if set).
--- Falls back to empty list if omnifunc is absent, errors, or returns nothing.
local function omni_candidates(base)
  local omnifunc = vim.bo.omnifunc
  if omnifunc == '' or omnifunc == 'v:lua.vim.lsp.omnifunc' then
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
      items[#items + 1] =
        vim.tbl_extend('keep', item, { menu = item.menu or '[omni]', icase = 1, dup = 0, empty = 1, info = item.info })
    end
  end
  return items
end

local function buffer_results(params)
  local bufnr = vim.uri_to_bufnr(params.textDocument.uri)
  local line = vim.api
    .nvim_buf_get_lines(bufnr, params.position.line, params.position.line + 1, false)[1]
    :sub(1, params.position.character)

  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = methods.textDocument_completion })

  local base = line:match('[%w_]+$') or ''

  local items = {}

  if #clients == 0 then
    items = omni_candidates(base)
  end

  if #items < 3 and vim.trim(line) ~= '' then
    items = vim.list_extend(items, candidates(base))
  end

  local results = vim.tbl_map(function(item)
    return {
      label = item.word,
      labelDetails = item.menu and { description = item.menu } or nil,
      documentation = item.info,
      buf = true
    }
  end, items)

  return {
    isIncomplete = true,
    items = results,
  }
end

return {
  name = 'buffer_lsp',
  cmd = function(dispatchers)
    local closing = false
    local srv = {}

    function srv.request(method, params, callback)
      if method == 'initialize' then
        callback(nil, {
          capabilities = {
            completionProvider = true,
          },
        })
      elseif method == 'shutdown' then
        callback(nil, nil)
      elseif method == methods.textDocument_completion then
        vim.schedule(function()
          callback(nil, buffer_results(params))
        end)
      end
      return true, 1
    end

    function srv.notify(method)
      if method == 'exit' then
        dispatchers.on_exit(0, 15)
      end
    end

    function srv.is_closing()
      return closing
    end

    function srv.terminate()
      closing = true
    end

    return srv
  end,
}
