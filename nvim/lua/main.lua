vim.g.enable_custom_completion = false

if vim.fn.has('nvim-0.11') == 0 then
  vim.g.enable_custom_completion = false
end

require('partials.abbreviations')
require('partials.settings')
require('partials.lazy')
require('partials.statusline')
require('partials.mappings')
require('partials.picker')
