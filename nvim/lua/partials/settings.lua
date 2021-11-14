local settings = {}
local opt = require('partials/utils').opt

opt('o', 'title', true)
opt('wo', 'number', true)
opt('wo', 'relativenumber', true)
opt('o', 'showmode', false)
opt('o', 'gdefault', true)
opt('wo', 'cursorline', true)
opt('o', 'smartcase', true)
opt('o', 'ignorecase', true)
opt('o', 'mouse', 'a')
opt('o', 'showmatch', true)
opt('o', 'startofline', false)
opt('o', 'timeoutlen', 1000)
opt('o', 'ttimeoutlen', 0)
opt('o', 'fileencoding', 'utf-8')
opt('wo', 'wrap', false)
opt('wo', 'linebreak', true)
opt('o', 'listchars', 'tab:│ ,trail:·')
opt('o', 'list', true)
opt('o', 'lazyredraw', true)
opt('o', 'hidden', true)
opt('o', 'conceallevel', 2)
opt('o', 'concealcursor', 'nc')
opt('o', 'splitright', true)
opt('o', 'splitbelow', true)
opt('o', 'inccommand', 'nosplit')
opt('o', 'exrc', true)
opt('o', 'secure', true)
opt('o', 'grepprg', 'rg --smart-case --color=never --no-heading -H -n --column')
opt('o', 'tagcase', 'smart')
opt('o', 'updatetime', 100)
opt('o', 'shortmess', vim.o.shortmess .. 'c')
opt('o', 'undofile', true)
opt('o', 'swapfile', false)
opt('o', 'backup', false)
opt('o', 'writebackup', false)
opt('o', 'fillchars', 'vert:│')
opt('o', 'breakindent', true)
opt('o', 'smartindent', true)
opt('o', 'expandtab', true)
opt('o', 'shiftwidth', 2)
opt('o', 'shiftround', true)
opt('o', 'foldmethod', 'syntax')
opt('wo', 'foldenable', false)
opt('o', 'diffopt', vim.o.diffopt .. ',vertical')
opt('o', 'scrolloff', 8)
opt('o', 'sidescrolloff', 15)
opt('o', 'sidescroll', 5)
opt('o', 'pyxversion', 3)
opt('o', 'matchtime', 0)
vim.g.python3_host_prog = '/usr/bin/python3'

vim.cmd([[augroup vimrc]])
vim.cmd([[autocmd!]])
vim.cmd([[autocmd BufWritePre * call v:lua.kris.settings.strip_trailing_whitespace()]])
vim.cmd([[autocmd InsertEnter * set nocul]])
vim.cmd([[autocmd InsertLeave * set cul]])
vim.cmd([[autocmd FocusGained,BufEnter * silent! exe 'checktime']])
vim.cmd([[autocmd FileType vim inoremap <buffer><silent><C-Space> <C-x><C-v>]])
vim.cmd([[autocmd FileType markdown setlocal spell]])
vim.cmd([[autocmd FileType json setlocal conceallevel=0 formatprg=python\ -m\ json.tool]])
vim.cmd([[autocmd TermOpen * setlocal nonumber norelativenumber]])
vim.cmd([[augroup END]])

vim.cmd([[augroup numbertoggle]])
vim.cmd([[autocmd!]])
vim.cmd([[autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif]])
vim.cmd([[autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif]])
vim.cmd([[augroup END]])

function settings.strip_trailing_whitespace()
  if vim.bo.modifiable then
    local line = vim.fn.line('.')
    local col = vim.fn.col('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.histdel('/', -1)
    vim.fn.cursor(line, col)
  end
end

local cwd = vim.fn.getcwd()
local handle = vim.loop.fs_scandir(cwd)
if type(handle) == 'string' then
  return
end
local paths = {}
while true do
  local name, t = vim.loop.fs_scandir_next(handle)
  if not name then
    break
  end
  if t == 'directory' and not vim.o.wildignore:find(name) then
    table.insert(paths, name .. '/**')
  end
end

vim.o.path = vim.o.path .. ',' .. table.concat(paths, ',')

_G.kris.settings = settings
