local colorscheme = {
  'rmehri01/onenord.nvim',
  lazy = false,
  priority = 1000,
}
colorscheme.config = function()
  vim.opt.background = vim.env.NVIM_COLORSCHEME_BG or 'dark'

  vim.cmd.filetype('plugin indent on')
  vim.cmd.syntax('on')

  local colors = require('onenord.colors').load()

  local telescope_normal = colors.active
  local telescope_prompt = colors.float

  if vim.o.background == 'light' then
    telescope_prompt = '#edeff4'
    telescope_normal = '#e4e7ee'
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
      NvimTreeNormal = { fg = colors.fg, bg = colors.bg },
      CurSearch = { fg = colors.cyan, bg = colors.selection, style = 'bold' },
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

  return colorscheme
end

return colorscheme
