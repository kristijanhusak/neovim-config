local colorscheme = {
  'folke/tokyonight.nvim',
  dependencies = {
    { 'rmehri01/onenord.nvim', lazy = false, priority = 1000 },
    'folke/todo-comments.nvim',
  },
  lazy = false,
  priority = 1000,
}

colorscheme.onenord = function()
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
      IndentLine = { link = 'IndentBlanklineChar' },
      IndentLineCurrent = { link = 'IndentBlanklineContextChar' },
    },
  })

  return colorscheme
end

colorscheme.tokyonight = function()
  ---@diagnostic disable-next-line: missing-fields
  require('tokyonight').setup({
    terminal_colors = true,
    on_highlights = function(hl, c)
      local prompt = '#2d3149'
      hl.SimpleF = {
        fg = c.red,
        reverse = true,
        bold = true,
      }
      hl.TelescopeNormal = {
        bg = c.bg_dark,
        fg = c.fg_dark,
      }
      hl.TelescopeBorder = {
        bg = c.bg_dark,
        fg = c.bg_dark,
      }
      hl.TelescopePromptNormal = {
        bg = prompt,
      }
      hl.TelescopePromptBorder = {
        bg = prompt,
        fg = prompt,
      }
      hl.TelescopePromptTitle = {
        bg = prompt,
        fg = prompt,
      }
      hl.TelescopePreviewTitle = {
        bg = c.bg_dark,
        fg = c.bg_dark,
      }
      hl.TelescopeResultsTitle = {
        bg = c.bg_dark,
        fg = c.bg_dark,
      }

      hl.SnacksPicker = {
        bg = c.bg_dark,
        fg = c.fg_dark,
      }
      hl.SnacksPickerBorder = {
        bg = c.bg_dark,
        fg = c.bg_dark,
      }
      hl.SnacksPickerInputBorder = {
        bg = c.bg_dark,
        fg = c.bg_dark,
      }

      hl.Folded = {
        bg = 'NONE',
        fg = '#82aaff',
      }
      hl.BlinkCmpSource = {
        link = 'Comment',
      }
    end,
  })
  vim.cmd.colorscheme('tokyonight')
end

colorscheme.config = function()
  require('todo-comments').setup()
  vim.opt.background = vim.env.NVIM_COLORSCHEME_BG or 'dark'

  vim.cmd.filetype('plugin indent on')
  vim.cmd.syntax('on')
  if vim.opt.background:get() == 'dark' then
    colorscheme.tokyonight()
  else
    colorscheme.onenord()
  end
end

return colorscheme
