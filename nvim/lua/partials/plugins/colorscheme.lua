local colorscheme = {
  'folke/tokyonight.nvim',
  dependencies = {
    { 'rmehri01/onenord.nvim', lazy = false, priority = 1000 },
    { 'RRethy/base16-nvim', lazy = false, priority = 1000 },
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
      BlinkCmpSource = {
        link = 'Comment',
      },
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

colorscheme.base16 = function(bg)
  require('base16-colorscheme').with_config({
    telescope = false,
    indentblankline = true,
    notify = false,
    ts_rainbow = false,
    cmp = false,
    illuminate = false,
    dapui = false,
  })

  if bg == 'dark' then
    local colors = require('base16-colorscheme').colorschemes['material-palenight']
    require('base16-colorscheme').setup(vim.tbl_extend('force', colors, {
      base05 = '#c0caf5'
    }))
  else
    vim.cmd.colorscheme('base16-one-light')
  end

  local function set_colors()
    local base16 = require('base16-colorscheme')

    local prompt = bg == 'dark' and base16.colors.base02 or base16.colors.base01

    local overrides = {
      SnacksInputIcon = { bg = prompt },
      SnacksPickerInput = { bg = prompt },
      SnacksPickerPrompt = { bg = prompt },
      SnacksPickerInputBorder = { bg = prompt },
      SnacksPickerInputTitle = { bg = prompt },
      IndentLine = { link = 'IndentBlanklineChar' },
      IndentLineCurrent = { link = 'IndentBlanklineContextChar' },
    }

    if bg == 'dark' then
      overrides.CursorLine = {
        bg = base16.colors.base02,
      }
    end

    for group, opts in pairs(overrides) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  end

  set_colors()

  vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    callback = set_colors,
  })
end

colorscheme.config = function()
  require('todo-comments').setup()
  local bg = vim.env.NVIM_COLORSCHEME_BG or 'dark'
  vim.opt.background = bg

  vim.cmd.filetype('plugin indent on')
  vim.cmd.syntax('on')
  colorscheme.base16(bg)
end

return colorscheme
