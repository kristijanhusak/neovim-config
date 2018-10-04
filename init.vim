" ================ Plugins ==================== {{{
function! PackagerInit() abort
  packadd vim-packager
  call packager#init()
  call packager#add('kristijanhusak/vim-packager', { 'type': 'opt' })
  call packager#add('Shougo/deoplete.nvim')
  call packager#add('Shougo/neosnippet')
  call packager#add('Shougo/defx.nvim')
  call packager#add('w0rp/ale', { 'do': 'npm install -g prettier' })
  call packager#add('Raimondi/delimitMate')
  call packager#add('manasthakur/vim-commentor')
  call packager#add('tpope/vim-surround')
  call packager#add('tpope/vim-repeat')
  call packager#add('tpope/vim-fugitive')
  call packager#add('AndrewRadev/splitjoin.vim')
  call packager#add('airblade/vim-gitgutter')
  call packager#add('sheerun/vim-polyglot')
  call packager#add('dyng/ctrlsf.vim')
  call packager#add('junegunn/fzf', { 'do': './install --all && ln -sf $(pwd) ~/.fzf'})
  call packager#add('junegunn/fzf.vim')
  call packager#add('ludovicchabant/vim-gutentags')
  call packager#add('phpactor/phpactor', { 'do': 'composer install' })
  call packager#add('kristijanhusak/vim-js-file-import', { 'do': 'npm install' })
  call packager#add('kristijanhusak/deoplete-phpactor')
  call packager#add('vimwiki/vimwiki')
  call packager#add('editorconfig/editorconfig-vim')
  call packager#add('morhetz/gruvbox')
  call packager#add('andymass/vim-matchup')
  call packager#add('haya14busa/vim-asterisk')
  call packager#add('osyo-manga/vim-anzu')
  call packager#add('autozimu/LanguageClient-neovim', { 'do': 'bash install.sh' })
  call packager#add('wellle/targets.vim')
  call packager#add('wsdjeg/FlyGrep.vim')
endfunction

command! PackagerInstall call PackagerInit() | call packager#install()
command! PackagerUpdate call PackagerInit() | call packager#update()
command! PackagerClean call PackagerInit() | call packager#clean()
command! PackagerStatus call PackagerInit() | call packager#status()

"}}}
" ================ General Config ==================== {{{

let g:loaded_netrwPlugin = 1                                                    "Do not load netrw
let g:loaded_matchit = 1                                                        "Do not load matchit, use matchup plugin

let g:mapleader = ','                                                           "Change leader to a comma

let g:gruvbox_italic = 1                                                        "Enable italics in Gruvbox colorscheme
let g:gruvbox_invert_selection = 0                                              "Do not invert selection in Gruvbox colorscheme
let g:gruvbox_sign_column = 'bg0'                                               "Use default bg color in sign column

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
set shortmess+=c                                                                "Disable completion menu messages in command line
set undofile                                                                    "Keep undo history across sessions, by storing in file
set completeopt-=preview                                                        "Disable preview window for autocompletion

filetype plugin indent on
syntax on
silent! colorscheme gruvbox
hi! link jsFuncCall GruvboxBlue
" Remove highlighting of Operator because it is reversed with cursorline enabled
hi! Operator guifg=NONE guibg=NONE

" }}}
" ================ Turn Off Swap Files ============== {{{

set noswapfile
set nobackup
set nowritebackup

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
  autocmd BufEnter,BufWritePost,TextChanged,TextChangedI * call HighlightModified()
  autocmd VimEnter * call deoplete#custom#option({ 'async_timeout': 10, 'camel_case': 1 })
  autocmd VimEnter * call SetStatusline()
  autocmd FileType defx call DefxSettings()
  autocmd VimEnter * if isdirectory(expand(printf('#%s:p', expand('<abuf>'))))
        \ | call DefxOpen({ 'dir': expand(printf('#%s:p', expand('<abuf>'))) }) | endif
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

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
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

function! SetStatusline() abort
  set statusline=%1*\ %{StatuslineMode()}                                       "Mode
  set statusline+=\ %*%2*%{GitStatusline()}%*                                   "Git branch and status
  set statusline+=\ %f                                                          "File path
  set statusline+=\ %m                                                          "Modified indicator
  set statusline+=\ %w                                                          "Preview indicator
  set statusline+=\ %r                                                          "Read only indicator
  set statusline+=\ %q                                                          "Quickfix list indicator
  set statusline+=\ %=                                                          "Start right side layout
  set statusline+=\ %{anzu#search_status()}                                     "Search status
  set statusline+=\ %2*\ %{&ft}                                                 "Filetype
  set statusline+=\ \│\ %p%%                                                    "Percentage
  set statusline+=\ \│\ %c                                                      "Column number
  set statusline+=\ \│\ %l/%L                                                   "Current line number/Total line numbers
  set statusline+=\ %*%#Error#%{AleStatus('error')}%*                           "Errors count
  set statusline+=%#DiffText#%{AleStatus('warning')}%*                          "Warning count
endfunction

hi User1 guifg=#504945 gui=bold
hi User2 guibg=#665c54 guifg=#ebdbb2

function! AleStatus(type) abort
  let l:count = ale#statusline#Count(bufnr(''))
  let l:errors = l:count.error + l:count.style_error
  let l:warnings = l:count.warning + l:count.style_warning

  if a:type ==? 'error' && l:errors
    return printf(' %d E ', l:errors)
  endif

  if a:type ==? 'warning' && l:warnings
    let l:space = l:errors ? ' ': ''
    return printf('%s %d W ', l:space, l:warnings)
  endif

  return ''
endfunction

function! GitStatusline() abort
  let l:head = fugitive#head()
  if !exists('b:gitgutter')
    return (empty(l:head) ? '' : printf(' %s ', l:head))
  endif
  let [l:added, l:modified, l:removed] = get(b:gitgutter, 'summary', [0, 0, 0])
  let l:result = l:added == 0 ? '' : ' +'.l:added
  let l:result .= l:modified == 0 ? '' : ' ~'.l:modified
  let l:result .= l:removed == 0 ? '' : ' -'.l:removed
  let l:result = join(filter([l:head, l:result], {-> !empty(v:val) }), '')
  return (empty(l:result) ? '' : printf(' %s ', l:result))
endfunction

function! HighlightModified() abort
  let l:is_modified = getwinvar(winnr(), '&mod') && getbufvar(bufnr(''), '&mod')

  if empty(l:is_modified)
    hi StatusLine guifg=#ebdbb2 guibg=#504945 gui=NONE
    return ''
  endif

  hi StatusLine guifg=#ebdbb2 guibg=#fb4934 gui=NONE
  return ''
endfunction

function! StatuslineMode() abort
  let l:mode = mode()
  call ModeHighlight(l:mode)
  let l:modeMap = {
  \ 'n'  : 'NORMAL',
  \ 'i'  : 'INSERT',
  \ 'R'  : 'REPLACE',
  \ 'v'  : 'VISUAL',
  \ 'V'  : 'V-LINE',
  \ 'c'  : 'COMMAND',
  \ '' : 'V-BLOCK',
  \ 's'  : 'SELECT',
  \ 'S'  : 'S-LINE',
  \ '' : 'S-BLOCK',
  \ 't'  : 'TERMINAL',
  \ }

  return get(l:modeMap, l:mode, 'UNKNOWN')
endfunction

function! ModeHighlight(mode) abort
  if a:mode ==? 'i'
    hi User1 guibg=#83a598
  elseif a:mode =~? '\(v\|V\|\)'
    hi User1 guibg=#fe8019
  elseif a:mode ==? 'R'
    hi User1 guibg=#8ec07c
  else
    hi User1 guibg=#928374
  endif
endfunction

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
cnoreabbrev E e

" }}}
" ================ Functions ======================== {{{

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

function! DefxOpen(...) abort
  let l:opts = get(a:, 1, {})
  let l:defx_winnr = get(filter(range(1, winnr('$')), 'getwinvar(v:val, "&ft") ==? "defx"'), 0, 0)
  let l:args = '-fnamewidth=50'

  if has_key(l:opts, 'split')
    let l:args = '-split=vertical -winwidth=40 -direction=topleft -fnamewidth=50'
  endif

  if !has_key(l:opts, 'find_current_file')
    call execute(printf('Defx -toggle %s %s', l:args, get(l:opts, 'dir', getcwd())))
    if l:defx_winnr
      call execute('wincmd p')
    endif
    return execute("norm!\<C-w>=")
  endif

  let l:full_path = expand('%:p')
  let l:head_path = expand('%:p:h')

  if l:defx_winnr > 0
    let l:args = '-fnamewidth=50'
    call execute(printf('%dwincmd w', l:defx_winnr))
  endif

  call execute(printf('Defx %s -search=%s %s', l:args, l:full_path, l:head_path))
  return execute("norm!\<C-w>=")
endfunction

function! DefxContextMenu() abort
  let l:actions = ['new_file', 'new_directory', 'rename', 'copy', 'move', 'paste', 'remove']
  let l:selection = confirm('Action?', "&New file\nNew &Folder\n&Rename\n&Copy\n&Move\n&Paste\n&Delete")
  silent exe 'redraw'

  return feedkeys(defx#do_action(l:actions[l:selection - 1]))
endfunction

function! DefxSettings() abort
  nnoremap <silent><buffer>m :call DefxContextMenu()<CR>
  nnoremap <silent><buffer><expr> o defx#do_action('open', 'wincmd p \| drop')
  nnoremap <silent><buffer><expr> <CR> defx#do_action('open', 'wincmd p \| drop')
  nnoremap <silent><buffer><expr> <2-LeftMouse> defx#do_action('open', 'wincmd p \| drop')
  nnoremap <silent><buffer><expr> s defx#do_action('open', 'botright vsplit')
  nnoremap <silent><buffer><expr> R defx#do_action('redraw')
  nnoremap <silent><buffer><expr> u defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> H defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> <Space> defx#do_action('toggle_select') . 'j'
  nnoremap <silent><buffer><expr> j line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> yy defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> q defx#do_action('quit')
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
" Select last pasted text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Move selected lines up and down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" Clear search highlight
nnoremap <silent><Leader><space> :AnzuClearSearchStatus<BAR>noh<CR>

" Handle ale error window
nnoremap <Leader>e :lopen<CR>
nnoremap <Leader>E :copen<CR>

nnoremap <silent><Leader>q :call CloseBuffer()<CR>
nnoremap <silent><Leader>Q :call CloseBuffer(v:true)<CR>

nnoremap <Leader>n :call DefxOpen({ 'split': v:true })<CR>
nnoremap <Leader>hf :call DefxOpen({ 'split': v:true, 'find_current_file': v:true })<CR>

" Toggle between last 2 buffers
nnoremap <leader><tab> <c-^>

" Filesearch plugin map for searching in whole folder
nnoremap <Leader>f :call Search()<CR>
nnoremap <Leader>F :call Search(v:true)<CR>

" Toggle buffer list
nnoremap <C-p> :Files<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>t :BTags<CR>
nnoremap <Leader>m :History<CR>
nnoremap <Leader>g :GFiles?<CR>

" Indenting in visual mode
xnoremap <s-tab> <gv
xnoremap <tab> >gv

" Resize window with shift + and shift - or use for diffget/diffput in diff mode
nnoremap <expr> + &diff ? ':diffput<BAR>diffupdate<CR>' : '<c-w>5>'
nnoremap <expr> _ &diff ? ':diffget<BAR>diffupdate<CR>' : '<c-w>5<'
xnoremap <expr> + &diff ? ':diffput<BAR>diffupdate<CR>' : '+'
xnoremap <expr> _ &diff ? ':diffget<BAR>diffupdate<CR>' : '_'
nnoremap <expr> R &diff ? ':diffupdate<CR>' : 'R'

" Better search status
nmap n <Plug>(anzu-n)zz
nmap N <Plug>(anzu-N)zz
map * <Plug>(asterisk-z*)<Plug>(anzu-update-search-status)
map # <Plug>(asterisk-z#)<Plug>(anzu-update-search-status)
map g* <Plug>(asterisk-gz*)<Plug>(anzu-update-search-status)
map g# <Plug>(asterisk-gz#)<Plug>(anzu-update-search-status)

" Language client context menu
nnoremap <Leader>r :call LanguageClient_contextMenu()<CR>

"Disable ex mode mapping
map Q <Nop>

" Jump to definition in vertical split
nnoremap <Leader>] <C-W>v<C-]>

" Reformat and fix linting errors
nnoremap <Leader>R :ALEFix<CR>

" Close all other buffers except current one
nnoremap <Leader>db :silent w <BAR> :silent %bd <BAR> e#<CR>

nnoremap gx :call netrw#BrowseX(expand('<cfile>'), netrw#CheckIfRemote())<CR>

nnoremap <Leader>/ :FlyGrep<CR>

" }}}
" ================ Plugins setups ======================== {{{

let g:ctrlsf_auto_close = 0                                                     "Do not close search when file is opened
let g:ctrlsf_mapping = {'vsplit': 's'}                                          "Mapping for opening search result in vertical split

let g:deoplete#enable_at_startup = 1                                            "Enable deoplete on startup

let g:neosnippet#disable_runtime_snippets = {'_' : 1}                           "Snippets setup
let g:neosnippet#snippets_directory = ['~/.config/nvim/snippets']               "Snippets directory

let g:delimitMate_expand_cr = 1                                                 "Auto indent on enter

let g:ale_linters = {'javascript': ['eslint']}                                  "Lint js with eslint
let g:ale_fixers = {'javascript': ['prettier', 'eslint']}                       "Fix eslint errors
let g:ale_javascript_prettier_options = '--print-width 100'                     "Set max width to 100 chars for prettier
let g:ale_lint_delay = 400                                                      "Increase linting delay
let g:ale_sign_error = '✖'                                                      "Lint error sign
let g:ale_sign_warning = '⚠'                                                    "Lint warning sign

let g:jsx_ext_required = 1                                                      "Force jsx extension for jsx filetype
let g:javascript_plugin_jsdoc = 1                                               "Enable syntax highlighting for js doc blocks
let g:vim_markdown_conceal = 0                                                  "Disable concealing in markdown

let g:vimwiki_list = [{'path': '~/Dropbox/vimwiki'}]                            "Use dropbox folder for easier syncing of wiki

let g:matchup_matchparen_status_offscreen = 0                                   "Do not show offscreen closing match in statusline
let g:matchup_matchparen_nomode = "ivV\<c-v>"                                   "Enable matchup only in normal mode
let g:matchup_matchparen_deferred = 1                                           "Defer matchup highlights to allow better cursor movement performance

let g:LanguageClient_serverCommands = {
\ 'javascript': ['javascript-typescript-stdio'],
\ 'javascript.jsx': ['javascript-typescript-stdio'],
\ 'typescript': ['javascript-typescript-stdio'],
\ 'go': ['go-langserver', '-gocodecompletion', '-func-snippet-enabled=false'],
\ 'python': ['pyls'],
\ }
" }}}
" vim:foldenable:foldmethod=marker
