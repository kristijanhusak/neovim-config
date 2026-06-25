vim.g.builtin_autocompletion = false
vim.g.custom_autocompletion = true

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
