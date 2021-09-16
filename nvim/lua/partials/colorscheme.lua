local colorscheme = {}
local opt = require'partials/utils'.opt
local bg = vim.env.NVIM_COLORSCHEME_BG or 'light'

opt('o', 'termguicolors', true)
opt('o', 'synmaxcol', 300)

vim.cmd[[filetype plugin indent on]]
vim.cmd[[syntax on]]

local colors = require('github-theme.colors').setup()
local bg_statusline = bg == 'light' and 'fg_gutter' or 'bg2'
require('github-theme').setup({
  theme_style = bg,
  colors = {
    bg_statusline = colors[bg_statusline],
  },
  dark_float = false,
})
vim.cmd(string.format('hi StatusLineNC guibg=%s', colors[bg_statusline]))
vim.cmd(string.format('hi OrgDONE guifg=%s gui=bold', colors.git.add))
vim.cmd(string.format('hi OrgAgendaScheduled guifg=%s', colors.green))
vim.cmd('hi link OrgAgendaDay Directory')
vim.defer_fn(function()
  vim.g.terminal_color_2 = colors.gitSigns.add
end, 1)

_G.kris.colorscheme = colorscheme
