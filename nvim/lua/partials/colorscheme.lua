local colorscheme = {}

vim.opt.termguicolors = true
vim.opt.background = vim.env.NVIM_COLORSCHEME_BG or 'dark'
vim.opt.synmaxcol = 300

vim.cmd([[filetype plugin indent on]])
vim.cmd([[syntax on]])

require('onenord').setup({
  styles = {
    diagnostics = 'undercurl',
    comments = 'italic',
    functions = 'bold',
  },
})

_G.kris.colorscheme = colorscheme
