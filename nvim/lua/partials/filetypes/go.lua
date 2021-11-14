local go = {}
local utils = require('partials/utils')
vim.cmd([[augroup vimrc_go]])
vim.cmd([[autocmd!]])
vim.cmd([[autocmd FileType go lua kris.go.setup()]])
vim.cmd([[autocmd BufWritePre *.go lua kris.go.format()]])
vim.cmd([[augroup END]])

vim.cmd([[command! GoAddTags lua kris.go.add_tags()]])

function go.setup()
  vim.bo.expandtab = false
  vim.bo.tabstop = 4
  utils.buf_keymap(0, 'n', '<C-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = false })
end

function go.add_tags()
  local struct = vim.fn.expand('<cword>')
  local type = vim.fn.input('Type: ', 'json')
  local file = vim.fn.expand('%:p')
  local view = vim.fn.winsaveview()
  local response = vim.fn.systemlist(string.format('gomodifytags -file %s -struct %s -add-tags %s', file, struct, type))
  vim.api.nvim_buf_set_lines(0, 0, -1, true, response)
  vim.fn.winrestview(view)
end

function go.format()
  vim.lsp.buf.formatting_sync()
  local params = vim.lsp.util.make_range_params()
  params.context = { source = { organizeImports = true } }
  local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params)
  if not result then
    return
  end
  result = result[1].result
  if not result then
    return
  end
  vim.lsp.util.apply_workspace_edit(result[1].edit)
end

_G.kris.go = go
