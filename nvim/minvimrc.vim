" Fast install with curl or wget command
" curl https://raw.githubusercontent.com/kristijanhusak/neovim-config/refs/heads/master/nvim/minvimrc.vim -o $HOME/.vimrc
" wget https://raw.githubusercontent.com/kristijanhusak/neovim-config/refs/heads/master/nvim/minvimrc.vim -O $HOME/.vimrc
set nocompatible
set termguicolors
let g:mapleader = ','

filetype plugin indent on
syntax on

" Setup block and beam cursor in normal/insert mode
let &t_VS = "\<esc>[ q"
let &t_SI = "\<esc>[5 q"
let &t_SR = "\<esc>[5 q"
let &t_EI = "\<esc>[ q"

set title
set number
set relativenumber
set backspace=indent,eol,start
set showcmd
set noshowmode
set gdefault
set guicursor+=a:blinkon500-blinkoff100
set cursorline
set autoread
set smartcase
set ignorecase
set hlsearch
set incsearch
set showmatch
set mouse=a
set nostartofline
set timeoutlen=1000 ttimeoutlen=0
set laststatus=2
set fileencoding=utf-8 encoding=utf-8
set wrap
set linebreak
set listchars=tab:\ \ ,trail:·
set list
set lazyredraw
set fillchars=fold:\ ,vert:│
set completeopt-=preview
set hidden
set conceallevel=2 concealcursor=i
set splitright
set splitbelow
set noswapfile
set nobackup
set nowb
set undofile
set statusline=\ %{toupper(mode())}\ ▏%f\ ▏%m\ %=\ %y\ ▏%4l:%-3c
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set smartindent
set autoindent
set nofoldenable
set wildmenu
set wildignore=*.o,*.obj,*~
set wildignore+=*logs*
set wildignore+=*node_modules/**
set wildignore+=*DS_Store*
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=dist/**
set wildignore+=*.png,*.jpg,*.gif

set path=**/*

if !has('nvim')
  set wildmode=list:full
  set undodir=~/.cache/vim/undo
  try
    colorscheme sorbet
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme slate
  endtry
endif

" Map save to Ctrl + S
map <c-s> :w<CR>
imap <c-s> <C-o>:w<CR>
" Also save with ,w and ,s
nnoremap <Leader>w :w<CR>
nnoremap <Leader>s :w<CR>

" Easier window navigation
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l
" Open vertical split
nnoremap <Leader>v <C-w>v

" Down is really the next line
nnoremap j gj
nnoremap k gk

nnoremap Y y$

vnoremap <C-c> "+y
" Paste from system clipboard with Ctrl + v
inoremap <C-v> <Esc>"+p
nnoremap <Leader>p "0p

" Move to the end of yanked text after yank and paste
nnoremap p p`]
vnoremap y y`]
vnoremap p p`]

" Move selected lines up and down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Clear search highlight
nnoremap <Leader><space> :noh<CR>

nnoremap <leader><tab> <c-^>

cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qa qa

" Indenting in visual mode
xnoremap <s-tab> <gv
xnoremap <tab> >gv

" Center highlighted search
nnoremap n nzz
nnoremap N Nzz

" Fuzzy file finder in the quickfix list. Type to filter ("file:12" jumps to line),
" <C-n>/<C-p> or arrows to move, <CR> to open, <Esc> to cancel.
function! s:find() abort
  let files = executable('rg') ? systemlist('rg --files --hidden -g "!.git"') : filter(glob('**/*', 0, 1), '!isdirectory(v:val)')
  let [q, sel, mode] = ['', 1, ' ']
  while 1
    let [pat, lnum] = matchlist(q, '^\(.\{-}\)\%(:\(\d\+\)\)\?$')[1:2]
    let found = (empty(pat) ? files : matchfuzzy(files, pat))[:199]
    " Text-only items: items with a filename would create a buffer for each result
    call setqflist([], mode, {'title': 'Find ' . len(found), 'items': map(copy(found), {_, f -> {'text': f}}),
          \ 'quickfixtextfunc': {d -> map(getqflist({'id': d.id, 'items': 1}).items[d.start_idx - 1 : d.end_idx - 1], 'v:val.text')}})
    if mode ==# ' ' | botright copen 15 | endif
    let mode = 'r'
    let sel = max([1, min([sel, len(found)])])
    call cursor(sel, 1)
    redraw | echo '> ' . q
    try | let c = getcharstr() | catch | let c = "\<Esc>" | endtry
    if c ==# "\<CR>" || c ==# "\<Esc>" || c ==# "\<C-c>"
      cclose | redraw | echo ''
      if c ==# "\<CR>" && !empty(found)
        execute 'edit' fnameescape(found[sel - 1])
        if !empty(lnum) | execute lnum | endif
      endif
      return
    elseif c ==# "\<C-n>" || c ==# "\<Down>" | let sel += 1
    elseif c ==# "\<C-p>" || c ==# "\<Up>" | let sel -= 1
    elseif c ==# "\<BS>" | let q = q[:-2] | let sel = 1
    elseif c ==# "\<C-u>" | let q = '' | let sel = 1
    elseif c[0] !=# "\x80" && c >=# ' ' | let q .= c | let sel = 1
    endif
  endwhile
endfunction
nnoremap <silent> <C-p> :call <SID>find()<CR>
nnoremap <leader>m :find<space>
nnoremap <leader>f :vimgrep  **/*<left><left><left><left><left>
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [q :cprev<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [b :bprev<CR>


function! ToggleComment() abort
  let l:cs = substitute(&commentstring, '%s', '', '')
  if getline('.') =~ '^\s*' . escape(l:cs, '#')
    execute 'normal! ^' . len(l:cs) . 'x'
  else
    execute 'normal! I' . l:cs
  endif
endfunction
nnoremap <silent><leader>c :call ToggleComment()<CR>
vnoremap <silent><leader>c :call ToggleComment()<CR>

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 15

map <silent> <leader>n :Lexplore<CR>

function! s:setup_paths() abort
  let cwd = getcwd()
  let entries = glob(cwd.'/*', 0, 1)
  let paths = ['.', '']
  for entry in entries
    if isdirectory(entry) && stridx(&wildignore, fnamemodify(entry, ':t')) < 0
      call add(paths, entry.'/**')
    endif
  endfor
  let &path = join(paths, ',')
endfunction

augroup fallback_vimrc
  autocmd!
  autocmd FileType netrw nmap <silent><buffer> o <CR> | silent! unmap <buffer><C-l>
  autocmd QuickFixCmdPost [^l]* cwindow
  autocmd InsertEnter * set nocul
  autocmd InsertLeave,BufEnter * set cul
  autocmd FocusGained,BufEnter * silent! exe checktime
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu | endif
  autocmd BUfLeave,FocusLost,InsertEnter,WinLeave * if &nu | set nornu | endif
  autocmd VimEnter,DirChanged * call s:setup_paths()
augroup end

if has('nvim-0.12')
  set autocomplete
endif
