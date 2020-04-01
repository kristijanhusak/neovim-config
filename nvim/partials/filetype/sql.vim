augroup vimrc_sql
  autocmd!
  autocmd FileType sql nmap <buffer><silent><Leader>R :call CocAction('format')<CR>
augroup END
