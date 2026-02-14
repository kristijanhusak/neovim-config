vim.g.builtin_autocompletion = false
local use_vim_pack = vim.pack ~= nil

if vim.fn.has('nvim-0.12') == 0 then
  vim.g.builtin_autocompletion = false
end

require('partials.abbreviations')
require('partials.settings')
if use_vim_pack then
  require('partials.pack')
else
  require('partials.lazy')
end
require('partials.statusline')
require('partials.mappings')
require('partials.picker')

require('vim._core.ui2').enable({
  enable = true,
  msg = {
    target = 'cmd',
    timeout = 4000,
  },
})
