augroup vimrc_sql
  autocmd!
  autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni formatprg=pg_format\ -u\ 0\ -U\ 0
augroup END
