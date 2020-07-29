augroup vimrc_sql
  autocmd!
  autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni equalprg=pg_format
augroup END
