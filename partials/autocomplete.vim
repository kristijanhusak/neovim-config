set completeopt-=preview                                                        "Disable preview window for autocompletion
set pumheight=15                                                                "Maximum number of entries in autocomplete popup

let g:coc_user_config = {
      \ 'coc.preferences.diagnostic.displayByAle': v:true,
      \ 'prettier.printWidth': 100,
      \ 'prettier.singleQuote': v:true
      \ }

let g:coc_global_extensions = [
      \ 'coc-css',
      \ 'coc-html',
      \ 'coc-tag',
      \ 'coc-json',
      \ 'coc-pyls',
      \ 'coc-eslint',
      \ 'coc-jest',
      \ 'coc-prettier',
      \ 'coc-tsserver',
      \ 'coc-gocode'
      \ ]

inoremap <silent><TAB> <C-R>=<sid>completion()<CR>
inoremap <silent><expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"
vmap <leader>r <Plug>(coc-format-selected)
nmap <leader>r <Plug>(coc-format-selected)

function! s:completion() abort
  if pumvisible()
    return "\<C-n>"
  endif

  let l:col = col('.') - 1
  if !l:col || getline('.')[l:col - 1] =~? '\s'
    return "\<TAB>"
  endif

  return coc#refresh()
endfunction

set wildmode=list:full
set wildignore=*.o,*.obj,*~                                                     "stuff to ignore when tab completing
set wildignore+=*.git*
set wildignore+=*.meteor*
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*mypy_cache*
set wildignore+=*__pycache__*
set wildignore+=*cache*
set wildignore+=*logs*
set wildignore+=*node_modules*
set wildignore+=*DS_Store*
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif
