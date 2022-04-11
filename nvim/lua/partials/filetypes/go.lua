local go = {}

function go.setup()
  vim.bo.expandtab = false
  vim.bo.tabstop = 4
  vim.keymap.set('n', '<C-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', { remap = true, buffer = true })
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

local go_group = vim.api.nvim_create_augroup('vimrc_go', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = go.setup,
  group = go_group,
})
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = go.format,
  group = go_group,
})

vim.api.nvim_create_user_command('GoAddTags', go.add_tags, { force = true })

_G.kris.go = go
