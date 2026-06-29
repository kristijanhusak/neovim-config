vim.g.builtin_autocompletion = true
vim.g.custom_autocompletion = false
vim.g.builtin_dir = vim.fn.has('nvim-0.13') == 1 and true

require('partials.abbreviations')
require('partials.settings')
require('partials.pack')
require('partials.statusline')
require('partials.mappings')
require('partials.picker')
require('partials.ai')

local ok, ui2 = pcall(require, 'vim._core.ui2')

if ok then
  ui2.enable({
    enable = true,
    msg = {
      target = 'cmd',
      timeout = 4000,
    },
  })
end
