let g:loaded_netrwPlugin = 1                                                    "Do not load netrw
let g:loaded_matchit = 1                                                        "Do not load matchit, use matchup plugin

set title                                                                       "change the terminal's title
set number                                                                      "Line numbers are good
set relativenumber                                                              "Show numbers relative to current line
set noshowmode                                                                  "Hide showmode because of the powerline plugin
set gdefault                                                                    "Set global flag for search and replace
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
set listchars=tab:>\ ,trail:·                                                   "Set trails for tabs and spaces
set list                                                                        "Enable listchars
set lazyredraw                                                                  "Do not redraw on registers and macros
set hidden                                                                      "Hide buffers in background
set conceallevel=2 concealcursor=i                                              "neosnippets conceal marker
set splitright                                                                  "Set up new vertical splits positions
set splitbelow                                                                  "Set up new horizontal splits positions
set path+=**                                                                    "Allow recursive search
set inccommand=nosplit                                                          "Show substitute changes immidiately in separate split
set exrc                                                                        "Allow using local vimrc
set secure                                                                      "Forbid autocmd in local vimrc
set grepprg=rg\ --vimgrep                                                       "Use ripgrep for grepping
set tagcase=smart                                                               "Use smarcase for tags
set updatetime=300                                                              "Cursor hold timeout
set shortmess+=c                                                                "Disable completion menu messages in command line
set undofile                                                                    "Keep undo history across sessions, by storing in file
set noswapfile                                                                  "Disable creating swap file
set nobackup                                                                    "Disable saving backup file
set nowritebackup                                                               "Disable writing backup file

set breakindent                                                                 "Preserve indent on line wrap
set smartindent                                                                 "Use smarter indenting
set expandtab                                                                   "Use spaces for indentation
set shiftwidth=2                                                                "Use 2 spaces for indentation
set nofoldenable                                                                "Disable folding by default
set colorcolumn=80                                                              "Highlight 80th column for easier wrapping
set foldmethod=syntax                                                           "When folding enabled, use syntax method
set diffopt+=vertical                                                           "Always use vertical layout for diffs

set scrolloff=8                                                                 "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=5
set pyxversion=3                                                                "Always use python 3

augroup vimrc
  autocmd!
  autocmd QuickFixCmdPost [^l]* cwindow                                         "Open quickfix window after grepping
  autocmd BufWritePre * call s:strip_trailing_whitespace()                      "Auto-remove trailing spaces
  autocmd InsertEnter * set nocul                                               "Remove cursorline highlight
  autocmd InsertLeave * set cul                                                 "Add cursorline highlight in normal mode
  autocmd FocusGained,BufEnter * silent! exe 'checktime'                        "Refresh file when vim gets focus
  autocmd FileType vim inoremap <buffer><silent><C-Space> <C-x><C-v>
  autocmd FileType markdown setlocal spell
  autocmd FileType json setlocal equalprg=python\ -m\ json.tool
  autocmd FileType git setlocal foldenable foldmethod=syntax | nnoremap <buffer><silent> <Space> za
  autocmd TermOpen * setlocal nonumber norelativenumber
augroup END

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
augroup END

function! s:strip_trailing_whitespace()
  if &modifiable
    let l:l = line('.')
    let l:c = col('.')
    call execute('%s/\s\+$//e')
    call histdel('/', -1)
    call cursor(l:l, l:c)
  endif
endfunction
