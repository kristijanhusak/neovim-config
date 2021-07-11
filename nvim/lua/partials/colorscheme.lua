local colorscheme = {}
local opt = require'partials/utils'.opt
local bg = vim.env.NVIM_COLORSCHEME_BG or 'light'

opt('o', 'termguicolors', true)
opt('o', 'synmaxcol', 300)

vim.cmd[[filetype plugin indent on]]
vim.cmd[[syntax on]]

local colors = require('github-theme.colors').setup()
local bg_statusline = bg == 'light' and 'fg_gutter' or 'black'
require('github-theme').setup({
  themeStyle = bg,
  colors = {
    bg_statusline = colors[bg_statusline],
  }
})
vim.cmd(string.format('hi StatusLineNC guibg=%s', colors[bg_statusline]))
vim.cmd(string.format('hi OrgDONE guifg=%s gui=bold', colors.git.add))
vim.cmd(string.format('hi OrgAgendaScheduled guifg=%s', colors.green))

_G.kris.colorscheme = colorscheme
