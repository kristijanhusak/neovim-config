vim.cmd[[ augroup vimrc_sql ]]
  vim.cmd[[ autocmd! ]]
  vim.cmd[[ autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni formatprg=pg_format\ -u\ 0\ -U\ 0 ]]
vim.cmd[[ augroup END ]]
