local colorscheme = {}

vim.opt.termguicolors = true
vim.opt.background = vim.env.NVIM_COLORSCHEME_BG or 'dark'
vim.opt.synmaxcol = 300

vim.cmd([[filetype plugin indent on]])
vim.cmd([[syntax on]])

local colors = require('onenord.colors').load()

local telescope_normal = colors.active
local telescope_prompt = colors.float

if vim.o.background == 'light' then
  telescope_prompt = '#e9ebed'
  telescope_normal = '#dfe1e5'
end

require('onenord').setup({
  styles = {
    diagnostics = 'undercurl',
    comments = 'italic',
    functions = 'bold',
  },
  inverse = {
    match_paren = true,
  },
  custom_highlights = {
    TelescopeTitle = { bg = telescope_prompt, fg = colors.fg },
    TelescopeNormal = { bg = telescope_normal },
    TelescopePromptBorder = { bg = telescope_prompt, fg = telescope_prompt },
    TelescopePromptNormal = { bg = telescope_prompt },
    TelescopePromptTitle = { fg = colors.fg, bg = telescope_normal },
    TelescopeSelection = { bg = telescope_prompt },
    TelescopePreviewBorder = { fg = telescope_normal, bg = telescope_normal },
    TelescopeResultsBorder = { fg = telescope_normal, bg = telescope_normal },
    MatchParenCur = { fg = colors.blue, style = 'inverse' },
    NormalFloat = { bg = colors.bg },
    FloatBorder = { bg = colors.bg },
    SimpleF = { fg = colors.red, bg = colors.diff_add_bg, style = 'bold' },
    fugitiveStagedHeading = { fg = colors.green },
    fugitiveStagedSection = { fg = colors.blue },
    fugitiveUntrackedSection = { fg = colors.blue },
    fugitiveUnstagedSection = { fg = colors.blue },
  },
})

_G.kris.colorscheme = colorscheme
