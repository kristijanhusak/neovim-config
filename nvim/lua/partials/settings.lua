_G.kris.settings = {}
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_matchit = 1

vim.o.title = true
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.showmode = false
vim.o.gdefault = true
vim.wo.cursorline = true
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.mouse='a'
vim.o.showmatch = true
vim.o.startofline = false
vim.o.timeoutlen= 1000
vim.o.ttimeoutlen= 0
vim.o.fileencoding= 'utf-8'
vim.wo.wrap = false
vim.wo.linebreak = true
vim.o.listchars='tab:│ ,trail:·'
vim.o.list = true
vim.o.lazyredraw = true
vim.o.hidden = true
vim.o.conceallevel = 2
vim.o.concealcursor = 'i'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.inccommand='nosplit'
vim.o.exrc = true
vim.o.secure = true
vim.o.grepprg = 'rg --smart-case --color=never --no-heading -H -n --column'
vim.o.tagcase = 'smart'
vim.o.updatetime= 300
vim.o.shortmess=vim.o.shortmess..'c'
vim.o.undofile = true
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.fillchars='vert:│'
vim.o.breakindent = true
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.foldenable = false
vim.o.foldmethod = 'syntax'
vim.o.diffopt=vim.o.diffopt..',vertical'
vim.o.scrolloff = 8
vim.o.sidescrolloff = 15
vim.o.sidescroll = 5
vim.o.pyxversion = 3
vim.g.python3_host_prog = '/usr/bin/python3'

vim.cmd[[augroup vimrc]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd BufWritePre * call v:lua.kris.settings.strip_trailing_whitespace()]]
  vim.cmd [[autocmd InsertEnter * set nocul]]
  vim.cmd [[autocmd InsertLeave * set cul]]
  -- vim.cmd [[autocmd FocusGained,BufEnter * silent! exe 'checktime']]
  vim.cmd [[autocmd FileType vim inoremap <buffer><silent><C-Space> <C-x><C-v>]]
  vim.cmd [[autocmd FileType markdown setlocal spell]]
  vim.cmd [[autocmd FileType json setlocal equalprg=python\ -m\ json.tool]]
  vim.cmd [[autocmd TermOpen * setlocal nonumber norelativenumber]]
vim.cmd [[augroup END]]

vim.cmd[[augroup numbertoggle]]
  vim.cmd [[autocmd!]]
  vim.cmd [[autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif]]
  vim.cmd [[autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif]]
vim.cmd[[augroup END]]

function _G.kris.settings.strip_trailing_whitespace()
  if vim.bo.modifiable then
    local line = vim.fn.line('.')
    local col = vim.fn.col('.')
    vim.cmd[[%s/\s\+$//e]]
    vim.fn.histdel('/', -1)
    vim.fn.cursor(line, col)
  end
end

local cwd = vim.fn.getcwd()
local handle = vim.loop.fs_scandir(cwd)
if type(handle) == 'string' then return end
local paths = {}
while true do
  local name, t = vim.loop.fs_scandir_next(handle)
  if not name then break end
  if t == 'directory' and not vim.o.wildignore:find(name) then
    table.insert(paths, name..'/**')
  end
end

vim.o.path = vim.o.path..','..table.concat(paths, ',')
