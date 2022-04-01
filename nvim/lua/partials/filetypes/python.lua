local python_group = vim.api.nvim_create_augroup('vimrc_python', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  command = [[setlocal textwidth=79]],
  group = python_group,
})
