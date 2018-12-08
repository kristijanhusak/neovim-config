set completeopt-=preview                                                        "Disable preview window for autocompletion
set pumheight=15                                                                "Maximum number of entries in autocomplete popup

inoremap <C-space> <C-x><C-o>
inoremap <silent><TAB> <C-R>=<sid>completion()<CR>
inoremap <silent><expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

function! s:completion() abort
  if pumvisible()
    return "\<C-n>"
  endif

  let l:col = col('.') - 1
  if !l:col || getline('.')[l:col - 1] =~? '\s'
    return "\<TAB>"
  endif

  set completeopt-=noselect
  let l:file_complete = s:file_completion()
  if l:file_complete
    return ''
  endif

  return "\<C-n>"
endfunction

function! s:file_completion() abort
  let l:file_path = matchstr(getline('.'), '[\.\/~]\f*\%'.col('.').'c')
  if empty(l:file_path) || l:file_path !~? '\/'
    return 0
  endif

  let l:start = l:file_path[0] !~? '^\(\~\|\/\)' ? expand('%:p:h').'/' : ''
  let l:dir = matchstr(l:file_path, '.*\/\ze[^\/]*$')
  let l:values = glob(printf('%s%s*', l:start , l:file_path), 0, 1)

  if empty(l:values)
    echo 'No file matches.'
    return 0
  endif

  if len(l:values) > 1
    set completeopt+=noselect
  endif

  let l:remove_ext = &filetype =~? '^javascript'
  call map(l:values, {-> {
        \ 'word' : fnamemodify(v:val, ':t'.(l:remove_ext ? ':r' : '')),
        \ 'abbr' : fnamemodify(v:val, ':t')
        \ }})
  call complete(col('.') - (len(l:file_path) - len(l:dir)), l:values)
  return 1
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
