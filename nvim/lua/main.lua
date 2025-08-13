vim.g.builtin_autocompletion = false

if vim.fn.has('nvim-0.12') == 0 then
  vim.g.builtin_autocompletion = false
end

require('partials.abbreviations')
require('partials.settings')
require('partials.lazy')
require('partials.statusline')
require('partials.mappings')
require('partials.picker')
