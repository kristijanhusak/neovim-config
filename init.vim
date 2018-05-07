" ================ Plugins ==================== {{{
if exists('*minpac#init')
  call minpac#init()

  " Manually loaded plugins
  call minpac#add('k-takata/minpac', {'type': 'opt'})
  call minpac#add('justinmk/vim-dirvish', { 'type': 'opt' })
  call minpac#add('andymass/vim-matchup', { 'type': 'opt' })
  call minpac#add('joshdick/onedark.vim', { 'type': 'opt' })

  " Auto loaded plugins
  call minpac#add('arcticicestudio/nord-vim')
  call minpac#add('lifepillar/vim-solarized8')
  call minpac#add('Shougo/deoplete.nvim')
  call minpac#add('Shougo/neosnippet')
  call minpac#add('w0rp/ale', { 'do': '!npm install -g prettier' })
  call minpac#add('nelstrom/vim-visual-star-search')
  call minpac#add('Raimondi/delimitMate')
  call minpac#add('manasthakur/vim-commentor')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tpope/vim-repeat')
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('FooSoft/vim-argwrap')
  call minpac#add('airblade/vim-gitgutter')
  call minpac#add('sheerun/vim-polyglot')
  call minpac#add('mattn/emmet-vim')
  call minpac#add('dyng/ctrlsf.vim')
  call minpac#add('junegunn/fzf')
  call minpac#add('junegunn/fzf.vim')
  call minpac#add('ludovicchabant/vim-gutentags')
  call minpac#add('phpactor/phpactor', { 'do': '!composer install' })
  call minpac#add('kristijanhusak/vim-js-file-import')
  call minpac#add('kristijanhusak/vim-dirvish-git')
  call minpac#add('kristijanhusak/deoplete-phpactor')
  call minpac#add('vimwiki/vimwiki')
endif

command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update()
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()

" Plugins that must be loaded before all other plugins
silent! packadd onedark.vim
silent! packadd vim-dirvish
silent! packadd vim-matchup

"}}}
" ================ General Config ==================== {{{

let g:mapleader = ','                                                           "Change leader to a comma

let g:onedark_terminal_italics = 1                                              "Enable italics in Onedark colorscheme
let g:solarized_extra_hi_groups = 1                                             "Enable extra highlighting in Solarized colorscheme
let g:nord_italic = 1                                                           "Enable italics in Nord colorscheme
let g:nord_italic_comments = 1                                                  "Use italics for comments in Nord colorscheme
let g:nord_comment_brightness = 12                                              "Increase comments brightness in Nord colorscheme
let g:nord_uniform_diff_background = 1                                          "Use same background color for all diff highlights

set termguicolors
set title                                                                       "change the terminal's title
set number                                                                      "Line numbers are good
set relativenumber                                                              "Show numbers relative to current line
set history=500                                                                 "Store lots of :cmdline history
set showcmd                                                                     "Show incomplete cmds down the bottom
set noshowmode                                                                  "Hide showmode because of the powerline plugin
set gdefault                                                                    "Set global flag for search and replace
set guicursor=a:blinkon500-blinkwait500-blinkoff500                             "Set cursor blinking rate
set cursorline                                                                  "Highlight current line
set smartcase                                                                   "Smart case search if there is uppercase
set ignorecase                                                                  "case insensitive search
set mouse=a                                                                     "Enable mouse usage
set showmatch                                                                   "Highlight matching bracket
set nostartofline                                                               "Jump to first non-blank character
set timeoutlen=1000 ttimeoutlen=0                                               "Reduce Command timeout for faster escape and O
set fileencoding=utf-8                                                          "Set utf-8 encoding on write
set wrap                                                                        "Enable word wrap
set linebreak                                                                   "Wrap lines at convenient points
set listchars=tab:\ \ ,trail:·                                                  "Set trails for tabs and spaces
set list                                                                        "Enable listchars
set lazyredraw                                                                  "Do not redraw on registers and macros
set background=dark                                                             "Set background to dark
set hidden                                                                      "Hide buffers in background
set conceallevel=2 concealcursor=i                                              "neosnippets conceal marker
set splitright                                                                  "Set up new vertical splits positions
set splitbelow                                                                  "Set up new horizontal splits positions
set path+=**                                                                    "Allow recursive search
set inccommand=nosplit                                                          "Show substitute changes immidiately in separate split
set fillchars+=vert:\│                                                          "Make vertical split separator full line
set pumheight=15                                                                "Maximum number of entries in autocomplete popup
set exrc                                                                        "Allow using local vimrc
set secure                                                                      "Forbid autocmd in local vimrc
set grepprg=rg\ --vimgrep                                                       "Use ripgrep for grepping
set tagcase=smart                                                               "Use smarcase for tags
set updatetime=500                                                              "Cursor hold timeout
set synmaxcol=300                                                               "Use syntax highlighting only for 300 columns

syntax on
silent! colorscheme $THEME
hi Conceal guibg=NONE

" }}}
" ================ Turn Off Swap Files ============== {{{

set noswapfile
set nobackup
set nowritebackup

" }}}
" ================ Persistent Undo ================== {{{

" Keep undo history across sessions, by storing in file.
silent !mkdir ~/.config/nvim/backups > /dev/null 2>&1
set undodir=~/.config/nvim/backups
set undofile

" }}}
" ================ Indentation ====================== {{{

set shiftwidth=2
set softtabstop=2
set tabstop=2
set expandtab
set breakindent
set smartindent
set nofoldenable
set colorcolumn=80
set foldmethod=syntax

" }}}
" ================ Auto commands ====================== {{{

augroup vimrc
  autocmd!
  autocmd QuickFixCmdPost [^l]* cwindow                                       "Open quickfix window after grepping
  autocmd BufWritePre * call StripTrailingWhitespaces()                       "Auto-remove trailing spaces
  autocmd InsertEnter * set nocul                                             "Remove cursorline highlight
  autocmd InsertLeave * set cul                                               "Add cursorline highlight in normal mode
  autocmd FocusGained,BufEnter * checktime                                    "Refresh file when vim gets focus
  autocmd FileType html,css,javascript.jsx EmmetInstall
augroup END

augroup php
  autocmd!
  autocmd FileType php setlocal shiftwidth=4 softtabstop=4 tabstop=4
  autocmd FileType php nmap <buffer><silent><Leader>if :call phpactor#UseAdd()<CR>
  autocmd FileType php nmap <buffer><silent><Leader>ir :call phpactor#ContextMenu()<CR>
  autocmd FileType php vmap <buffer><silent><Leader>ie :<C-U>call phpactor#ExtractMethod()<CR>
  autocmd FileType php nmap <buffer><silent><C-]> :call phpactor#GotoDefinition()<CR>
augroup END

augroup javascript
  autocmd!
  autocmd FileType javascript nmap <buffer><silent><C-]> <Plug>(JsGotoDefinition)
  autocmd FileType javascript xmap <buffer><silent><C-]> <Plug>(JsGotoDefinition)
  autocmd FileType javascript nmap <buffer><silent><Leader>] <C-W>v<Plug>(JsGotoDefinition)
  autocmd FileType javascript xmap <buffer><silent><Leader>] <C-W>vgv<Plug>(JsGotoDefinition)
augroup END

augroup dirvish
  autocmd!
  autocmd FileType dirvish nnoremap <silent><buffer> o :call dirvish#open('edit', 0)<CR>
  autocmd FileType dirvish nnoremap <silent><buffer> s :call dirvish#open('vsplit', 1)<CR>
  autocmd FileType dirvish xnoremap <silent><buffer> o :call dirvish#open('edit', 0)<CR>
  autocmd FileType dirvish nmap <silent><buffer> u <Plug>(dirvish_up)
  autocmd FileType dirvish nmap <silent><buffer><Leader>n <Plug>(dirvish_quit)
  autocmd FileType dirvish silent! unmap <buffer> <C-p>
augroup END

" }}}
" ================ Completion ======================= {{{

set wildmode=list:full
set wildignore=*.o,*.obj,*~                                                     "stuff to ignore when tab completing
set wildignore+=*.git*
set wildignore+=*.meteor*
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*cache*
set wildignore+=*logs*
set wildignore+=*node_modules/**
set wildignore+=*DS_Store*
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

" }}}
" ================ Scrolling ======================== {{{

set scrolloff=8                                                                 "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=5

" }}}
" ================ Statusline ======================== {{{

let s:statuslineBgColor = synIDattr(synIDtrans(hlID('StatusLine')), 'reverse') ? 'fg' : 'bg'
let s:statuslineBg = synIDattr(synIDtrans(hlID('StatusLine')), s:statuslineBgColor)
silent exe 'hi User1 guifg=#FF0000 guibg='.s:statuslineBg.' gui=bold'

hi User2 guifg=#FFFFFF guibg=#FF1111 gui=bold
hi User3 guifg=#2C323C guibg=#E5C07B gui=bold
set statusline=\ %{toupper(mode())}                                             "Mode
set statusline+=\ \│\ %{StatuslineFn('fugitive#head')}                          "Git branch
set statusline+=%{GitFileStatus()}                                              "Git file status
set statusline+=\ \│\ %4F                                                       "File path
set statusline+=\ %1*%m%*                                                       "Modified indicator
set statusline+=\ %w                                                            "Preview indicator
set statusline+=\ %r                                                            "Read only indicator
set statusline+=\ %q                                                            "Quickfix list indicator
set statusline+=\ %=                                                            "Start right side layout
set statusline+=\ %{&enc}                                                       "Encoding
set statusline+=\ \│\ %y                                                        "Filetype
set statusline+=\ \│\ %p%%                                                      "Percentage
set statusline+=\ \│\ %c                                                        "Column number
set statusline+=\ \│\ %l/%L                                                     "Current line number/Total line numbers
set statusline+=\ %{StatuslineFn('gutentags#statusline','\│\ ')}                "Tags status
set statusline+=\ %2*%{AleStatusline('error')}%*                                "Errors count
set statusline+=%3*%{AleStatusline('warning')}%*                                "Warning count

"}}}
" ================ Abbreviations ==================== {{{

cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev Wqa wqa
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qa qa
cnoreabbrev Bd bd
cnoreabbrev wrap set wrap
cnoreabbrev nowrap set nowrap

" }}}
" ================ Functions ======================== {{{

function! StatuslineFn(name, ...) abort
  try
    return call(a:name, a:000)
  catch
    return ''
  endtry
endfunction


function! StripTrailingWhitespaces()
  if &modifiable
    let l:l = line('.')
    let l:c = col('.')
    call execute('%s/\s\+$//e')
    call histdel('/', -1)
    call cursor(l:l, l:c)
  endif
endfunction

function! Search(...)
  let l:default = a:0 > 0 ? expand('<cword>') : ''
  let l:term = input('Search for: ', l:default)
  if l:term !=? ''
    let l:path = input('Path: ', '', 'file')
    execute 'CtrlSF "'.l:term.'" '.l:path
  endif
endfunction

function! AleStatusline(type)
  try
    let l:count = ale#statusline#Count(bufnr(''))
    if a:type ==? 'error' && l:count['error']
      return printf(' %d E ', l:count['error'])
    endif

    if a:type ==? 'warning' && l:count['warning']
      let l:space = l:count['error'] ? ' ': ''
      return printf('%s %d W ', l:space, l:count['warning'])
    endif

    return ''
  catch
    return ''
  endtry
endfunction

function! GitFileStatus()
  if !exists('b:gitgutter')
    return ''
  endif
  let [l:added, l:modified, l:removed] = get(b:gitgutter, 'summary', [0, 0, 0])
  let l:result = l:added == 0 ? '' : ' +'.l:added
  let l:result .= l:modified == 0 ? '' : ' ~'.l:modified
  let l:result .= l:removed == 0 ? '' : ' -'.l:removed
  if l:result !=? ''
    return ' '.l:result
  endif
  return l:result
endfunction

function! CloseBuffer(...) abort
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

function! CustomDiffColors() abort
  let l:added = '#A3BE8C'
  let l:deleted = '#BF616A'

  let l:normalBg = synIDattr(synIDtrans(hlID('Normal')), 'bg')
  let l:bg = substitute(l:normalBg, '\(#..\)..\(..\)', '\13f\2', 'g')
  exe 'hi DiffAdd guifg='.l:added.' guibg='.l:bg.' gui=NONE'
  exe 'hi DiffChange guifg='.l:added.' guibg='.l:bg.' gui=NONE'
  exe 'hi DiffText  guifg='.l:added.' guibg='.l:bg.' gui=reverse'
  exe 'hi DiffDelete guifg='.l:deleted.' guibg='.l:normalBg.' gui=NONE'
endfunction

" }}}
" ================ Custom mappings ======================== {{{

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
nnoremap <c-Space> <C-w>p
tnoremap <c-h> <C-\><C-n><C-w>h
tnoremap <c-l> <C-\><C-n><C-w>l
tnoremap <c-Space> <C-\><C-n><C-w>p

" Down is really the next line
nnoremap j gj
nnoremap k gk

" Expand snippets on tab if snippets exists, otherwise do autocompletion
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)"
\ : pumvisible() ? "\<C-n>" : "\<TAB>"
" If popup window is visible do autocompletion from back
imap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" Fix for jumping over placeholders for neosnippet
smap <expr><TAB> neosnippet#jumpable() ?
\ "\<Plug>(neosnippet_jump)"
\: "\<TAB>"

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

" Move selected lines up and down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Clear search highlight
nnoremap <Leader><space> :noh<CR>

" Handle ale error window
nnoremap <Leader>e :lopen<CR>
nnoremap <Leader>E :copen<CR>

nnoremap <silent><Leader>q :call CloseBuffer()<CR>
nnoremap <silent><Leader>Q :call CloseBuffer(1)<CR>

nnoremap <Leader>hf :Dirvish %<CR>
nnoremap <Leader>n :Dirvish<CR>

" Toggle between last 2 buffers
nnoremap <leader><tab> <c-^>

" Filesearch plugin map for searching in whole folder
nnoremap <Leader>f :call Search()<CR>
nnoremap <Leader>F :call Search(1)<CR>

" Toggle buffer list
nnoremap <C-p> :Files<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>t :BTags<CR>
nnoremap <Leader>m :History<CR>

" Indenting in visual mode
xnoremap <s-tab> <gv
xnoremap <tab> >gv

" Resize window with shift + and shift - or use for diffget/diffput in diff mode
nnoremap <expr> + &diff ? ':diffput<BAR>diffupdate<CR>' : '<c-w>5>'
nnoremap <expr> _ &diff ? ':diffget<BAR>diffupdate<CR>' : '<c-w>5<'
xnoremap <expr> + &diff ? ':diffput<BAR>diffupdate<CR>' : '+'
xnoremap <expr> _ &diff ? ':diffget<BAR>diffupdate<CR>' : '_'
nnoremap <expr> R &diff ? ':diffupdate<CR>' : 'R'

" Center highlighted search
nnoremap n nzz
nnoremap N Nzz

"Disable ex mode mapping
map Q <Nop>

" Jump to definition in vertical split
nnoremap <Leader>] <C-W>v<C-]>

" Reformat and fix linting errors
nnoremap <Leader>R :ALEFix<CR>
" Wrap/Unwrap lines
nnoremap <leader>r :ArgWrap<CR>

" Close all other buffers except current one
nnoremap <Leader>db :silent w <BAR> :silent %bd <BAR> e#<CR>

" }}}
" ================ Plugins setups ======================== {{{

let g:ctrlsf_auto_close = 0                                                     "Do not close search when file is opened
let g:ctrlsf_mapping = {'vsplit': 's'}                                          "Mapping for opening search result in vertical split

let g:dirvish_mode = ':sort ,^.*[\/],'                                          "List directories first in dirvish

let g:user_emmet_leader_key = '<c-e>'                                           "Change trigger emmet key
let g:user_emmet_install_global = 0                                             "Load emmet on demand

let g:deoplete#enable_at_startup = 1                                            "Enable deoplete on startup
let g:deoplete#camel_case = 1                                                   "Autocomplete files relative to current buffer path
let g:deoplete#file#enable_buffer_path = 1                                      "Show only 30 entries in list and allow smart case autocomplete

let g:neosnippet#disable_runtime_snippets = {'_' : 1}                           "Snippets setup
let g:neosnippet#snippets_directory = ['~/.config/nvim/snippets']               "Snippets directory

let g:delimitMate_expand_cr = 1                                                 "Auto indent on enter

let g:ale_linters = {'javascript': ['eslint']}                                  "Lint js with eslint
let g:ale_fixers = {'javascript': ['prettier', 'eslint']}                       "Fix eslint errors
let g:ale_javascript_prettier_options = '--print-width 100'                     "Set max width to 100 chars for prettier
let g:ale_sign_error = '✖'                                                      "Lint error sign
let g:ale_sign_warning = '⚠'                                                    "Lint warning sign

let g:jsx_ext_required = 1                                                      "Force jsx extension for jsx filetype
let g:javascript_plugin_jsdoc = 1                                               "Enable syntax highlighting for js doc blocks

let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki'}]                            "Use dropbox folder for easier syncing of wiki

let g:matchup_matchparen_status_offscreen = 0                                   "Do not show offscreen closing match in statusline

call CustomDiffColors()                                                         "Use custom diff colors
" }}}
" vim:foldenable:foldmethod=marker
