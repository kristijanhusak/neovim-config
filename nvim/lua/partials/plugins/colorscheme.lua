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
    plugins = {
      cmp = true,
    },
    on_highlights = function(hl, c)
      hl.SimpleF = {
        fg = c.red,
        reverse = true,
        bold = true,
      }

      local prompt = '#2d3149'
      hl.SnacksPickerInput = {
        bg = prompt,
      }
      hl.SnacksPickerInputBorder = {
        bg = prompt,
      }

      hl.SnacksPickerInputTitle = {
        bg = prompt,
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
