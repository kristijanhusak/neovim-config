augroup python
  autocmd!
  autocmd FileType python nmap <buffer><silent><Leader>if :ImportName<CR>
  autocmd FileType python setlocal textwidth=79
augroup END
