local js_group = vim.api.nvim_create_augroup('custom_javascript', { clear = true })
local utils = require('partials.utils')
local fn = vim.fn

local handlers = {}
local filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

local javascript = {
  'dmmulroy/tsc.nvim',
  ft = filetypes,
}
javascript.config = function()
  require('tsc').setup({
    auto_close_qflist = true,
  })
  vim.keymap.set('n', '<Plug>(JsConsoleLog)', handlers.console_log)
  vim.keymap.set('n', '<Plug>(JsGotoFile)', handlers.goto_file)

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    callback = handlers.setup_buffer,
    group = js_group,
  })

  if vim.tbl_contains(filetypes, vim.bo.filetype) then
    vim.cmd('doautocmd FileType ' .. vim.bo.filetype)
  end

  return javascript
end

function handlers.setup_buffer()
  vim.keymap.set('n', '<Leader>ll', '<Plug>(JsConsoleLog)', { remap = true, buffer = true, desc = 'Console log' })
  vim.keymap.set('n', 'gf', '<Plug>(JsGotoFile)', { remap = true, buffer = true, desc = 'Go to file' })
  vim.keymap.set('n', '<F1>', handlers.setup_imports, { buffer = true, silent = true })
  vim.keymap.set('n', '<F2>', function()
    return handlers.setup_imports(true)
  end, { buffer = true, silent = true })
  vim.opt_local.isfname:append('@-@')
  vim.cmd('compiler tsc')

  vim.api.nvim_create_user_command('TSRenameFile', function()
    local client = vim.lsp.get_clients({ name = 'ts_ls' })[1]
    if not client then
      vim.notify('No active LSP client')
      return
    end

    vim.ui.input({
      prompt = 'New filename',
      default = vim.api.nvim_buf_get_name(0),
    }, function(result)
      local params = {
        sourceUri = vim.uri_from_bufnr(0),
        targetUri = vim.fn.fnamemodify(result, ':p'),
      }

      client.request_sync(vim.lsp.protocol.Methods.workspace_executeCommand, {
        command = '_typescript.applyRenameFile',
        arguments = { params },
      }, 5000, vim.api.nvim_get_current_buf())
    end)
  end, {})
end

function handlers.console_log()
  local view = fn.winsaveview() or {}
  local word = fn.expand('<cword>')
  local node = vim.treesitter.get_node()
  while node and node:type() ~= 'lexical_declaration' do
    node = node:parent()
  end
  if node then
    local _, _, end_line, _ = vim.treesitter.get_node_range(node)
    fn.cursor(end_line + 1, 0)
  end
  local scope = utils.get_gps_scope(word)
  if not scope:match(vim.pesc(word) .. '$') then
    scope = ('%s > %s'):format(scope, word)
  end
  vim.cmd(string.format("keepjumps norm!oconsole.log('%s', %s); // eslint-disable-line no-console", scope, word))
  fn['repeat#set'](utils.esc('<Plug>(JsConsoleLog)'))
  fn.winrestview(view)
end

function handlers.goto_file()
  local full_path = fn.printf('%s/%s', fn.expand('%:p:h'), fn.expand('<cfile>'))
  local stats = vim.loop.fs_stat(full_path)
  if not stats or stats.type ~= 'directory' then
    return vim.cmd([[norm! gf]])
  end

  for _, suffix in ipairs(fn.split(vim.bo.suffixesadd, ',')) do
    local index_file = full_path .. '/index' .. suffix
    if fn.filereadable(index_file) then
      return vim.cmd.edit(index_file)
    end
  end
end

local function execute_code_action(code_action)
  local client = vim.lsp.get_clients({ name = 'ts_ls' })[1]
  local bufnr = vim.api.nvim_get_current_buf()

  local params = vim.lsp.util.make_range_params()
  params.context = {
    only = { code_action },
  }

  local res = client.request_sync(vim.lsp.protocol.Methods.textDocument_codeAction, params, 5000, bufnr)

  if not res or #res.result == 0 then
    return
  end

  vim.lsp.util.apply_text_edits(
    res.result[1].edit.documentChanges[1].edits,
    vim.api.nvim_get_current_buf(),
    client.offset_encoding
  )
end

function handlers.setup_imports(organize)
  local cmds = { 'source.addMissingImports.ts', 'source.removeUnusedImports.ts', 'source.fixAll.ts' }
  if organize then
    table.insert(cmds, 'source.organizeImports.ts')
  end
  for _, cmd in ipairs(cmds) do
    execute_code_action(cmd)
  end
end

return javascript
