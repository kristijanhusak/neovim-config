vim.g.mapleader = ','

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--single-branch',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.runtimepath:prepend(lazypath)

require('lazy').setup('partials.plugins', {
  ui = {
    border = 'rounded',
  },
  install = {
    colorscheme = { 'onenord' },
  },
  lockfile = vim.fn.stdpath('data') .. '/lazy-lock.json',
})
