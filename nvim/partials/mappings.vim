" Comment map
nmap <Leader>c gcc
" Line comment command
xmap <Leader>c gc

" Map save to Ctrl + S
map <c-s> :w<CR>
imap <c-s> <C-o>:w<CR>
nnoremap <Leader>s :w<CR>

" Open vertical split
nnoremap <Leader>v <C-w>v

" Move between slits
nnoremap <c-h> <C-w>h
nnoremap <c-j> <C-w>j
nnoremap <c-k> <C-w>k
nnoremap <c-l> <C-w>l
tnoremap <c-h> <C-\><C-n><C-w>h
tnoremap <c-l> <C-\><C-n><C-w>l

" Down is really the next line
nnoremap j gj
nnoremap k gk

" Map for Escape key
inoremap jj <Esc>
tnoremap <Leader>jj <C-\><C-n>

" Yank to the end of the line
nnoremap Y y$

" Copy to system clipboard
vnoremap <C-c> "+y
" Paste from system clipboard with Ctrl + v
inoremap <C-v> <Esc>"+p
nnoremap <Leader>p "0p
vnoremap <Leader>p "0p
nnoremap <Leader>h viw"0p

" Move to the end of yanked text after yank and paste
nnoremap p p`]
vnoremap y y`]
vnoremap p p`]
" Select last pasted text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Move selected lines up and down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Clear search highlight

" Handle ale error window
nnoremap <Leader>e :lopen<CR>
nnoremap <Leader>E :copen<CR>

nnoremap <silent><Leader>q :call <sid>close_buffer()<CR>
nnoremap <silent><Leader>Q :call <sid>close_buffer(v:true)<CR>

" Toggle between last 2 buffers
nnoremap <leader><tab> <c-^>

" Indenting in visual mode
xnoremap <s-tab> <gv
xnoremap <tab> >gv

" Resize window with shift + and shift -
nnoremap _ <c-w>5<
nnoremap + <c-w>5>

nnoremap <silent><expr> R &diff ? ':diffupdate<CR>' : 'R'

" Disable ex mode mapping
map Q <Nop>

" Jump to definition in vertical split
nnoremap <Leader>] <C-W>v<C-]>

" Close all other buffers except current one
nnoremap <Leader>db :silent w <BAR> :silent %bd <BAR> e#<CR>

nnoremap gx :call netrw#BrowseX(expand('<cfile>'), netrw#CheckIfRemote())<CR>

" Unimpaired mappings
nnoremap [q :cprevious<CR>
nnoremap ]q :cnext<CR>
nnoremap [Q :cfirst<CR>
nnoremap ]Q :clast<CR>
nnoremap [l :lprevious<CR>
nnoremap ]l :lnext<CR>
nnoremap [L :lfirst<CR>
nnoremap ]L :llast<CR>
nnoremap [t :tprevious
nnoremap ]t :tnext
nnoremap [T :tfirst
nnoremap ]T :tlast
nnoremap [b :bprevious
nnoremap ]b :bnext
nnoremap [B :bfirst
nnoremap ]B :blast

"rsi mappings
cnoremap <C-A> <Home>
cnoremap <C-E> <End>
cnoremap <C-B> <End>

function! s:close_buffer(...) abort
  if &buftype !=? ''
    return execute('q!')
  endif
  let l:windowCount = winnr('$')
  let l:totalBuffers = len(getbufinfo({ 'buflisted': 1 }))
  let l:noSplits = l:windowCount ==? 1
  let l:bang = a:0 > 0 ? '!' : ''
  if l:totalBuffers > 1 && l:noSplits
    let l:command = 'bp'
    if buflisted(bufnr('#'))
      let l:command .= '|bd'.l:bang.'#'
    endif
    return execute(l:command)
  endif
  return execute('q'.l:bang)
endfunction

nnoremap <silent> gF :call <sid>open_file_or_create_new()<CR>

function! s:open_file_or_create_new() abort
  let l:path = expand('<cfile>')
  if empty(l:path)
    return
  endif

  if &buftype ==? 'terminal'
    return s:open_file_on_line_and_column()
  endif

  try
    exe 'norm!gf'
  catch /.*/
    echo 'New file.'
    let l:new_path = fnamemodify(expand('%:p:h') . '/' . l:path, ':p')
    if !empty(fnamemodify(l:new_path, ':e')) "Edit immediately if file has extension
      return execute('edit '.l:new_path)
    endif

    let l:suffixes = split(&suffixesadd, ',')

    for l:suffix in l:suffixes
      if filereadable(l:new_path.l:suffix)
        return execute('edit '.l:new_path.l:suffix)
      endif
    endfor

    return execute('edit '.l:new_path.l:suffixes[0])
  endtry
endfunction

command! Json call <sid>paste_to_json_buffer()

function! s:paste_to_json_buffer() abort
  vsplit
  enew
  set filetype=json
  silent! exe 'norm!"+p'
  silent! exe 'norm!gg=G'
endfunction

function! s:open_file_on_line_and_column() abort
  let l:path = expand('<cfile>')
  let l:line = getline('.')
  let l:row = 1
  let l:col = 1
  if match(l:line, escape(l:path, '/').':\d*:\d*') > -1
    let l:matchlist = matchlist(l:line, escape(l:path, '/').':\(\d*\):\(\d*\)')
    let l:row = get(l:matchlist, 1, 1)
    let l:col = get(l:matchlist, 2, 1)
  endif

  let l:bufnr = bufnr(l:path)
  let l:winnr = bufwinnr(l:bufnr)
  if l:winnr > -1 && getbufvar(l:bufnr, '&buftype') !=? 'terminal'
    silent! exe l:winnr.'wincmd w'
  else
    silent! exe 'vsplit '.l:path
  endif
  call cursor(l:row, l:col)
endfunction
