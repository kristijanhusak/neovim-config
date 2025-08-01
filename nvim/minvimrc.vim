" Fast install with this command
" curl https://raw.githubusercontent.com/kristijanhusak/neovim-config/refs/heads/master/nvim/minvimrc.vim -o $HOME/.vimrc
set nocompatible
let g:mapleader = ','

filetype plugin indent on
syntax on

let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

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
set completeopt-=preview
set hidden
set conceallevel=2 concealcursor=i
set splitright
set noswapfile
set nobackup
set nowb
set undofile
set statusline=\ %f\ %m\ %=\ %y
set smarttab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set smartindent
set autoindent
set nofoldenable
set wildmode=list:full
set wildmenu
set wildignore=*.o,*.obj,*~
set wildignore+=*logs*
set wildignore+=*node_modules/**
set wildignore+=*DS_Store*
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

set path=**/*

if !has('nvim')
  set undodir=~/.cache/vim/undo
endif

silent! exe 'colorscheme sorbet'

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

nnoremap <C-p> :call feedkeys(':find ')<CR>
nnoremap <leader>f :vimgrep  **/*<left><left><left><left><left>
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [q :cprev<CR>
nnoremap <silent> ]b :bnext<CR>
nnoremap <silent> [b :bprev<CR>


function! ToggleComment()
  let l:cs = substitute(&commentstring, '%s', '', '')
  if getline('.') =~ '^\s*' . escape(l:cs, '#')
    execute 'normal! ^' . len(l:cs) . 'x'
  else
    execute 'normal! I' . l:cs
  endif
endfunction
nnoremap <leader>c :call ToggleComment()<CR>
vnoremap <leader>c :call ToggleComment()<CR>

let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 15

map <silent> <leader>n :Lexplore<CR>

augroup fallback_vimrc
  autocmd!
  autocmd FileType netrw nmap <silent><buffer> o <CR> | silent! unmap <buffer><C-l>
  autocmd QuickFixCmdPost [^l]* cwindow
  autocmd InsertEnter * set nocul
  autocmd InsertLeave * set cul
  autocmd FocusGained,BufEnter * silent! exe checktime
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu | endif
  autocmd BUfLeave,FocusLost,InsertEnter,WinLeave * if &nu | set nornu | endif
augroup end
