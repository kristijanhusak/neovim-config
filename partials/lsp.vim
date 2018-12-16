augroup langserver
  autocmd!
  autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'javascript-typescript-langserver',
        \ 'cmd': {server_info->['javascript-typescript-stdio']},
        \ 'whitelist': ['javascript', 'javascript.jsx', 'typescript'],
        \ })
  autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
  autocmd FileType javascript,javascript.jsx,typescript,python setlocal omnifunc=lsp#complete
augroup END

