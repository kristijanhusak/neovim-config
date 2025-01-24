local settings = {}

_G.kris.diagnostic_icons = {
  [vim.diagnostic.severity.ERROR] = ' ',
  [vim.diagnostic.severity.WARN] = ' ',
  [vim.diagnostic.severity.INFO] = ' ',
  [vim.diagnostic.severity.HINT] = ' ',
}

vim.opt.termguicolors = true
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
vim.opt.guicursor:append('a:blinkon500-blinkoff100')
vim.opt.listchars = {
  tab = '▏ ',
  trail = '·',
}
vim.opt.list = true
vim.opt.hidden = true
vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nc'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.inccommand = 'nosplit'
vim.opt.exrc = true
vim.opt.grepprg = 'rg --smart-case --color=never --no-heading -H -n --column'
vim.opt.tagcase = 'smart'
vim.opt.updatetime = 100
vim.opt.foldenable = false
vim.opt.shortmess:append('c')
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.fillchars = 'fold: ,vert:│'
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
vim.g.python3_host_prog = '/usr/bin/python3'
vim.opt.splitkeep = 'screen'
vim.opt.diffopt:append('linematch:60')
vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'noselect' }
vim.opt.pumheight = 10
if vim.fn.exists('&completeitemalign') > 0 then
  vim.opt.completeitemalign = { 'kind', 'abbr', 'menu' }
end

if vim.fn.has('nvim-0.11') > 0 then
  vim.opt.completeopt:append({ 'fuzzy', 'popup' })
end

function settings.strip_trailing_whitespace()
  if vim.bo.modifiable then
    local line = vim.fn.line('.')
    local col = vim.fn.col('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.histdel('/', -1)
    vim.fn.cursor({ line, col })
  end
end

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

vim.o.path = vim.o.path .. table.concat(paths, ',')

local vimrc_group = vim.api.nvim_create_augroup('vimrc', { clear = true })
vim.api.nvim_create_autocmd('VimResized', {
  group = vimrc_group,
  command = 'wincmd =',
})
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vimrc_group,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd('normal! g`"zz')
    end
  end,
})
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

vim.filetype.add({
  pattern = {
    ['.env*'] = 'conf',
    ['*.mjml'] = 'html',
  },
})

return settings
