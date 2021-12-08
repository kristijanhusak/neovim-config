local colorscheme = {}
local opt = require('partials/utils').opt

opt('o', 'termguicolors', true)
opt('o', 'background', vim.env.NVIM_COLORSCHEME_BG or 'dark')
opt('o', 'synmaxcol', 300)

vim.cmd([[filetype plugin indent on]])
vim.cmd([[syntax on]])

require('onenord').setup({
  italics = {
    comments = true,
  },
  styles = {
    diagnostics = 'undercurl',
  }
})

_G.kris.colorscheme = colorscheme
