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

  local picker_bg = '#eff0f2'
  local prompt = '#eaebed'

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
      LspReferenceRead = { bg = colors.highlight, style = 'NONE' },
      LspReferenceWrite = { bg = colors.highlight, style = 'NONE' },
      LspReferenceText = { bg = colors.highlight, style = 'NONE' },
      SnacksPicker = {
        bg = picker_bg,
      },
      SnacksPickerBorder = {
        bg = picker_bg,
      },
      SnacksPickerInput = {
        bg = prompt,
      },
      SnacksPickerInputBorder = {
        bg = prompt,
      },
      SnacksPickerInputTitle = { bg = prompt },
    },
  })

  return colorscheme
end

colorscheme.tokyonight = function()
  ---@diagnostic disable-next-line: missing-fields
  require('tokyonight').setup({
    terminal_colors = true,
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

      hl['@org.agenda.scheduled'] = {
        fg = c.green1,
      }

      hl['@org.keyword.done'] = {
        fg = c.green1,
        bold = true,
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
