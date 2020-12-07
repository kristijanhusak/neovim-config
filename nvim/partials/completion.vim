function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

function s:tab_completion() abort
  if vsnip#jumpable(1)
    return "\<Plug>(vsnip-jump-next)"
  endif

  if pumvisible()
    return "\<C-n>"
  endif

  if s:check_back_space()
    return "\<TAB>"
  endif

  if vsnip#expandable()
    return "\<Plug>(vsnip-expand)"
  endif

  return compe#complete()
endfunction

imap <expr> <TAB> <sid>tab_completion()

imap <expr><S-TAB> pumvisible() ? "\<C-p>" : vsnip#jumpable(-1) ? "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
smap <expr><TAB> vsnip#available(1)  ? "\<Plug>(vsnip-expand-or-jump)" : "\<TAB>"
smap <expr><S-TAB> vsnip#available(-1)  ? "\<Plug>(vsnip-jump-prev)" : "\<S-TAB>"
imap <expr> <CR> pumvisible() && complete_info()['selected'] != '-1'
      \ ? compe#confirm('<CR>')
      \ : vsnip#expandable() ? "\<Plug>(vsnip-expand)" : "\<Plug>(PearTreeExpand)"
