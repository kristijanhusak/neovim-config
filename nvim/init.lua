_G.kris = {}
require('partials.abbreviations')
require('partials.settings')
require('partials.lazy')
require('partials.statusline')
require('partials.mappings')

_G.kris.test = function()
  local devicons = require('nvim-web-devicons')
  local ft_icon, ft_icon_hl = devicons.get_icon_by_filetype(vim.bo.filetype)
  if ft_icon then
    print('statusline_active > ft_icon_color', vim.inspect(ft_icon_hl or ''))
  end
end
