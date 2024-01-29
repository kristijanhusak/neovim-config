local org_plugin = require('partials.plugins.orgmode')
local orgmode = nil

if org_plugin.dev then
  orgmode = vim.fn.fnamemodify('~/github/orgmode', ':p')
else
  orgmode = vim.fn.stdpath('data') .. '/lazy/orgmode'
end
local treesitter = vim.fn.stdpath('data') .. '/lazy/nvim-treesitter'
vim.opt.runtimepath:append(treesitter)
vim.opt.runtimepath:append(orgmode)

---@diagnostic disable-next-line: different-requires
require('orgmode').cron(require('partials.plugins.orgmode').orgmode_config)
