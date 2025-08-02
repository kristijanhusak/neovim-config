local protocol = vim.lsp.protocol

local function call_omnifunc(omnifunc, ...)
  if vim.startswith(omnifunc, 'v:lua.') then
    local func_name = omnifunc:sub(7)
    local fn = vim.split(func_name, '.', { plain = true })
    local mod = _G
    for i = 1, #fn - 1 do
      mod = mod[fn[i]]
    end

    return mod[fn[#fn]](...)
  end
  return vim.call(omnifunc, ...)
end

local function get_completion(bufnr, params, omnifunc, callback)
  local offset = call_omnifunc(omnifunc, 1, '')
  local line = vim.api.nvim_buf_get_lines(bufnr, params.position.line, params.position.line + 1, false)[1] or ''
  line = line:sub(1, params.position.character + 1)
  local base = line
  if offset > 0 then
    base = line:sub(offset + 1)
  end
  local result = call_omnifunc(omnifunc, 0, base)

  local items = {}
  local isIncomplete = true
  for _, item in ipairs(result) do
    table.insert(items, {
      label = item.abbr or item.word,
      insertText = item.word,
      documentation = item.info and item.info ~= '' and item.info or nil,
      sortText = 0,
      detail = item.menu,
    })
  end

  callback(items, isIncomplete)
end

local function server(dispatchers)
  local closing = false
  local srv = {}

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
      local bufnr = params.textDocument and params.textDocument.uri and vim.uri_to_bufnr(params.textDocument.uri)

      if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        callback(nil, nil)
        return
      end

      local omnifunc = vim.api.nvim_get_option_value('omnifunc', { buf = bufnr })
      if not omnifunc or omnifunc == '' or omnifunc == 'v:lua.vim.lsp.omnifunc' then
        callback(nil, nil)
        return
      end

      get_completion(bufnr, params, omnifunc, function(items, isIncomplete)
        callback(nil, { isIncomplete = isIncomplete, items = items })
      end)
      return
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

vim.lsp.config('omnifunc_lsp', {
  name = 'omnifunc_lsp',
  cmd = server,
  filetypes={'sql', 'org', 'mysql'}
})
