vim.cmd([[augroup vimrc_sql]])
vim.cmd([[autocmd!]])
vim.cmd([[autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni formatprg=sql-formatter\ -l\ postgresql]])
vim.cmd([[augroup END]])
