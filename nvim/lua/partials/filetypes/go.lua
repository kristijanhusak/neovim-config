_G.kris.go = {}
local utils = require'partials/utils'
vim.cmd [[augroup vimrc_go]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd FileType go lua kris.go.setup()]]
  vim.cmd [[autocmd BufWritePre *.go lua kris.go.format()]]
vim.cmd [[augroup END]]

function _G.kris.go.setup()
  vim.bo.expandtab = false
  vim.bo.tabstop = 4
  utils.buf_keymap(0, 'n', '<C-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', { noremap = false })
end

function _G.kris.go.format()
  vim.lsp.buf.formatting_sync()
  local params = vim.lsp.util.make_range_params()
  params.context  = { source = { organizeImports = true } }
  local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 5000)
  if not result then return end
  result = result[1].result
  if not result then return end
  vim.lsp.util.apply_workspace_edit(result[1].edit)
end
