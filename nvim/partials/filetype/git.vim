augroup gitcommit
  autocmd!
  autocmd FileType fugitive nmap <buffer><silent> <Space> =
  autocmd FileType git setlocal foldenable foldmethod=syntax | nnoremap <buffer><silent> <Space> za
augroup END
