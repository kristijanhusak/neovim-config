vim.g.enable_builtin_completion = false

if vim.fn.has('nvim-0.12') == 0 then
  vim.g.enable_builtin_completion = false
end

require('partials.abbreviations')
require('partials.settings')
require('partials.lazy')
require('partials.statusline')
require('partials.mappings')
require('partials.picker')
