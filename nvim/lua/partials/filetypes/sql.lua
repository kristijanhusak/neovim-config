local sql_group = vim.api.nvim_create_augroup('vimrc_sql', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'sql',
  command = [[setlocal omnifunc=vim_dadbod_completion#omni formatprg=sql-formatter\ -l\ postgresql]],
  group = sql_group,
})
