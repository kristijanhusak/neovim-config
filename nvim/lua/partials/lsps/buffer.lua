local protocol = vim.lsp.protocol

local cache = {}
local word_bufs = {}

local function get_completion(bufnr, params, callback)
  local line = vim.api.nvim_buf_get_lines(bufnr, params.position.line, params.position.line + 1, false)[1] or ''
  line = line:sub(1, params.position.character)
  local keyword = vim.fn.matchstr(line, [[\k*$]])
  if not keyword or keyword == '' then
    callback({})
    return
  end

  local buffers = vim.api.nvim_list_bufs()
  local items = {}
  local all_items = {}
  local isIncomplete = false
  local cur_bufname = vim.api.nvim_buf_get_name(0)

  for _, b in ipairs(buffers) do
    if not vim.api.nvim_buf_is_valid(b) or not vim.api.nvim_buf_is_loaded(b) then
      goto continue
    end

    local bufnr_key = tostring(b)
    local buffer_entries = {}
    local bufname = vim.api.nvim_buf_get_name(b)
    local bufname_relative = vim.fn.fnamemodify(bufname, ':.')

    local changedtick = vim.api.nvim_buf_get_var(b, 'changedtick')
    if not cache[bufnr_key] or cache[bufnr_key].changedtick ~= changedtick then
      cache[bufnr_key] = cache[bufnr_key] or {}
      cache[bufnr_key].changedtick = changedtick
      if bufname ~= cur_bufname then
        isIncomplete = true
      end

      local lines = vim.api.nvim_buf_get_lines(b, 0, -1, false)
      for _, bufline in ipairs(lines) do
        for word in bufline:gmatch('%w+') do
          table.insert(buffer_entries, word)
          word_bufs[word] = word_bufs[word] or {}
          table.insert(word_bufs[word], bufname_relative)
        end
        cache[bufnr_key].entries = buffer_entries
      end
    end

    ::continue::
  end

  for _, buf_entry in pairs(cache) do
    for _, word in ipairs(buf_entry.entries) do
      if not all_items[word] and word ~= keyword then
        all_items[word] = true
        table.insert(items, {
          label = word,
          kind = protocol.CompletionItemKind.Text,
          detail = '[Buffer]',
          data = {
            bufnames = word_bufs[word] or {},
          },
        })
      end
    end
  end

  callback(items, isIncomplete)
end

local function server(dispatchers)
  local closing = false
  local srv = {}
  local no_result_count = 0

  function srv.request(method, params, callback)
    if method == protocol.Methods.initialize then
      callback(nil, {
        capabilities = {
          completionProvider = {
            resolveProvider = true,
          },
        },
      })
      return
    end
    if method == protocol.Methods.shutdown then
      callback(nil, nil)
      return
    end

    if method == protocol.Methods.textDocument_completion then
      local complete_info = vim.fn.complete_info({'pum_visible', 'matches'})
      if (complete_info.pum_visible and #complete_info.matches > 0) or no_result_count < 3 then
        callback(nil, { isIncomplete = true, items = {} })
        no_result_count = no_result_count + 1
        return
      end
      no_result_count = 0
      local bufnr = params.textDocument and params.textDocument.uri and vim.uri_to_bufnr(params.textDocument.uri)
      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        callback(nil, nil)
        return
      end

      get_completion(bufnr, params, function(items, isIncomplete)
        callback(nil, { isIncomplete = isIncomplete, items = items })
      end)
      return
    end

    if method == protocol.Methods.completionItem_resolve then
      vim.schedule(function()
        callback(
          nil,
          vim.tbl_extend('force', params, {
            documentation = {
              kind = 'markdown',
              value = ('```\n%s\n```'):format(table.concat(vim.list.unique(params.data.bufnames), '\n')),
            },
          })
        )
      end)
    end
  end

  -- This method is called each time the client sends a notification to the server
  -- The difference between `request` and `notify` is that notifications don't expect a response
  function srv.notify(method)
    if method == 'exit' then
      dispatchers.on_exit(0, 15)
    end
  end

  -- Indicates if the client is shutting down
  function srv.is_closing()
    return closing
  end

  -- Callend when the client wants to terminate the process
  function srv.terminate()
    closing = true
  end

  return srv
end

vim.lsp.config('buffer_lsp', {
  name = 'buffer_lsp',
  cmd = server,
})
