set completeopt-=preview                                                        "Disable preview window for autocompletion
set pumheight=15                                                                "Maximum number of entries in autocomplete popup

augroup vimrc_autocomplete
  autocmd CursorHold * silent! call CocActionAsync('highlight')
  autocmd CursorHoldI * silent! call CocActionAsync('showSignatureHelp')
  autocmd BufNewFile,BufRead *.dbout let b:coc_enabled = 0
augroup END

let g:coc_user_config = {
      \ 'javascript.suggestionActions.enabled': v:false,
      \ 'prettier.printWidth': 100,
      \ 'prettier.singleQuote': v:true,
      \ }

let g:coc_global_extensions = [
      \ 'coc-go',
      \ 'coc-tag',
      \ 'coc-css',
      \ 'coc-html',
      \ 'coc-json',
      \ 'coc-jest',
      \ 'coc-prettier',
      \ 'coc-tsserver',
      \ 'coc-snippets',
      \ 'coc-vimlsp',
      \ 'coc-pairs',
      \ 'coc-phpls',
      \ 'coc-sql',
      \ 'coc-db',
      \ ]

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
vmap <leader>lf <Plug>(coc-format-selected)
nmap <leader>lf <Plug>(coc-format-selected)
nmap <leader>lF <Plug>(coc-format)
nmap <leader>ld <Plug>(coc-definition)
nmap <leader>lc <Plug>(coc-declaration)
nmap <leader>lg <Plug>(coc-implementation)
nmap <leader>lu <Plug>(coc-references)
nmap <leader>lr <Plug>(coc-rename)
nmap <leader>lq <Plug>(coc-fix-current)
nmap <silent><leader>lh :call CocAction('doHover')<CR>
vmap <leader>la <Plug>(coc-codeaction-selected)
nmap <leader>la <Plug>(coc-codeaction-selected)
inoremap <silent><C-Space> <C-x><C-o>
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

set wildoptions=pum
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
set wildignore+=**/node_modules/**
set wildignore+=*DS_Store*
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif
