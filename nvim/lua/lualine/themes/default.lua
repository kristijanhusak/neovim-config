local p = require('partials.plugins.colorscheme').default_palette()
local light = vim.o.background == 'light'
local tone = light and 'Dark' or 'Light'

local fg = light and p.LightGrey1 or p.DarkGrey1
local section_b = light and { bg = p.LightGrey3, fg = p.DarkGrey2 } or { bg = p.DarkGrey3, fg = p.LightGrey2 }

local function mode(color)
  return {
    a = { bg = p[tone .. color], fg = fg, gui = 'bold' },
    b = section_b,
  }
end

return {
  normal = mode('Blue'),
  insert = mode('Green'),
  visual = mode('Magenta'),
  replace = mode('Red'),
  command = mode('Yellow'),
  inactive = mode('Cyan'),
}
