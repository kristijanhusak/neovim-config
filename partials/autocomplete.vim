set completeopt-=preview                                                        "Disable preview window for autocompletion
set pumheight=15                                                                "Maximum number of entries in autocomplete popup

augroup vimrc_autocomplete
  autocmd!
  autocmd CursorHoldI,CursorMovedI * call CocAction('showSignatureHelp')
augroup END

let g:coc_user_config = {
      \ 'coc.preferences.diagnostic.enable': v:false,
      \ 'prettier.printWidth': 100,
      \ 'prettier.singleQuote': v:true,
      \ 'coc.preferences.maxCompleteItemCount': 20,
      \ 'coc.preferences.triggerCompletionWait': 80,
      \ 'coc.preferences.hoverTarget': 'echo',
      \ 'coc.preferences.triggerSignatureHelp': v:false
      \ }

let g:coc_global_extensions = [
      \ 'coc-css',
      \ 'coc-html',
      \ 'coc-tag',
      \ 'coc-json',
      \ 'coc-pyls',
      \ 'coc-jest',
      \ 'coc-prettier',
      \ 'coc-tsserver',
      \ 'coc-gocode'
      \ ]

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
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

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
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
