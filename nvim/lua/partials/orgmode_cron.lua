local orgmode_config = require('partials.orgmode_config')
vim.opt.runtimepath:append(vim.fn.fnamemodify('~/github/orgmode', ':p'))

require('orgmode').cron(orgmode_config)
