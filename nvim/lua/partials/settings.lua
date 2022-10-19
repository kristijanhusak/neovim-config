local settings = {}

vim.opt.title = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showmode = false
vim.opt.gdefault = true
vim.opt.cursorline = true
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.mouse = 'a'
vim.opt.showmatch = true
vim.opt.startofline = false
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 0
vim.opt.fileencoding = 'utf-8'
vim.opt.wrap = false
vim.opt.linebreak = true
vim.opt.listchars = 'tab:│ ,trail:·'
vim.opt.list = true
vim.opt.lazyredraw = true
vim.opt.hidden = true
vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nc'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = 'nosplit'
vim.opt.exrc = true
vim.opt.secure = true
vim.opt.grepprg = 'rg --smart-case --color=never --no-heading -H -n --column'
vim.opt.tagcase = 'smart'
vim.opt.updatetime = 100
vim.opt.shortmess = vim.o.shortmess .. 'c'
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.fillchars = 'vert:│'
vim.opt.breakindent = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.shiftround = true
vim.opt.diffopt:append('vertical')
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 15
vim.opt.sidescroll = 5
vim.opt.pyxversion = 3
vim.opt.matchtime = 0
vim.opt.splitkeep = 'screen'
vim.g.python3_host_prog = '/usr/bin/python3'

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

local vimrc_group = vim.api.nvim_create_augroup('vimrc', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = settings.strip_trailing_whitespace,
  group = vimrc_group,
})
vim.api.nvim_create_autocmd('InsertEnter', {
  pattern = '*',
  command = 'set nocul',
  group = vimrc_group,
})
vim.api.nvim_create_autocmd('InsertLeave', {
  pattern = '*',
  command = 'set cul',
  group = vimrc_group,
})
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  pattern = '*',
  command = [[silent! exe 'checktime']],
  group = vimrc_group,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  command = 'setlocal spell',
  group = vimrc_group,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'json',
  command = [[setlocal conceallevel=0 formatprg=python\ -m\ json.tool]],
  group = vimrc_group,
})
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  command = [[setlocal nonumber norelativenumber]],
  group = vimrc_group,
})
vim.api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }, {
  pattern = '*',
  command = [[if &nu | set rnu | endif]],
  group = vimrc_group,
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }, {
  pattern = '*',
  command = [[if &nu | set nornu | endif]],
  group = vimrc_group,
})

vim.opt.wildignore = {
  '*.o',
  '*.obj,*~',
  '*.git*',
  '*.meteor*',
  '*vim/backups*',
  '*sass-cache*',
  '*mypy_cache*',
  '*__pycache__*',
  '*cache*',
  '*logs*',
  '*node_modules*',
  '**/node_modules/**',
  '*DS_Store*',
  '*.gem',
  'log/**',
  'tmp/**',
  '*package-lock.json*',
  '**/dist/**',
  '**/.next/**',
  '**/.nx/**',
}

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
  pattern = '.env*',
  command = 'set filetype=conf',
})

_G.kris.settings = settings
