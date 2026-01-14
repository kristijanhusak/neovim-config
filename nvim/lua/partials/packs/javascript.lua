local js_group = vim.api.nvim_create_augroup('custom_javascript', { clear = true })
local utils = require('partials.utils')
local fn = vim.fn

local handlers = {}
local filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

vim.g.js_file_import_omit_semicolon = 1

vim.pack.load({
  src = 'dmmulroy/tsc.nvim',
  dependencies = {
    'kristijanhusak/vim-js-file-import',
  },
  ft = filetypes,
  config = function()
    require('tsc').setup({
      auto_close_qflist = true,
    })
    vim.keymap.set('n', '<Plug>(JsConsoleLog)', handlers.console_log)
    vim.keymap.set('n', '<Plug>(JsGotoFile)', handlers.goto_file)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = filetypes,
      callback = handlers.setup_buffer,
      group = js_group,
    })

    if vim.tbl_contains(filetypes, vim.bo.filetype) then
      vim.cmd('doautocmd FileType ' .. vim.bo.filetype)
    end

    vim.api.nvim_create_autocmd('DirChanged', {
      callback = function()
        require('tsc').setup({
          auto_close_qflist = true,
          bin_path = require('tsc.utils').find_tsc_bin(),
        })
      end,
    })
  end,
})

function handlers.setup_buffer()
  vim.keymap.set('n', '<Leader>ll', '<Plug>(JsConsoleLog)', { remap = true, buffer = true, desc = 'Console log' })
  vim.keymap.set('n', 'gf', '<Plug>(JsGotoFile)', { remap = true, buffer = true, desc = 'Go to file' })
  vim.keymap.set('n', '<F1>', handlers.setup_imports, { buffer = true, silent = true })
  vim.keymap.set('n', '<F2>', handlers.setup_imports_and_lsp_format, { buffer = true, silent = true })
  vim.opt_local.isfname:append('@-@')
  vim.cmd('compiler tsc')
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

function handlers.setup_imports_and_lsp_format()
  handlers.setup_imports()

  vim.wait(500, function()
    local client = vim.lsp.get_clients({
      name = 'ts_ls',
    })[1]
    if client then
      return client.requests == 0
    end
    return true
  end)

  vim.lsp.buf.format()
end

function handlers.setup_imports(organize)
  local cmds = { 'source.addMissingImports.ts', 'source.removeUnusedImports.ts', 'source.fixAll.ts' }
  if organize then
    table.insert(cmds, 'source.organizeImports.ts')
  end
  for _, cmd in ipairs(cmds) do
    vim.lsp.buf.code_action({
      apply = true,
      context = {
        only = { cmd },
        diagnostics = {},
        triggerKind = vim.lsp.protocol.CodeActionTriggerKind.Invoked
      },
    })
  end
end
