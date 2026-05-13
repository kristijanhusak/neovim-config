local colorscheme = {
  'catppuccin/nvim',
  dependencies = {
    'folke/todo-comments.nvim',
    'nvim-mini/mini.base16',
    'gabiuz/kape-nvim',
  },
  lazy = false,
  priority = 1000,
}

colorscheme.catppuccin = function()
  local flavor = vim.env.NVIM_COLORSCHEME_BG == 'light' and 'latte' or 'mocha'
  local palette = require('catppuccin.palettes').get_palette(flavor)
  local u = require('catppuccin.utils.colors')
  local prompt = u.darken(palette.mantle, flavor == 'mocha' and 0.8 or 0.98)
  require('catppuccin').setup({
    flavour = flavor,
    term_colors = true,
    lsp_styles = {
      underlines = {
        errors = { 'undercurl' },
        hints = { 'undercurl' },
        warnings = { 'undercurl' },
        information = { 'undercurl' },
      },
    },
    custom_highlights = function()
      return {
        NvimTreeCursorLine = { bg = prompt },
        SnacksPickerInput = { bg = prompt },
        SnacksPickerInputBorder = { bg = prompt },
        SnacksPickerInputTitle = { bg = prompt },
        IndentLine = { link = 'IblIndent' },
        IndentLineCurrent = { link = 'IblScope' },
      }
    end,
  })

  vim.cmd.colorscheme('catppuccin-nvim')
end

colorscheme.base16 = function()
  local tomorrow_night = {
    base00 = '#1d1f21',
    base01 = '#282a2e',
    base02 = '#373b41',
    base03 = '#969896',
    base04 = '#b4b7b4',
    base05 = '#c5c8c6',
    base06 = '#e0e0e0',
    base07 = '#ffffff',
    base08 = '#cc6666',
    base09 = '#de935f',
    base0A = '#f0c674',
    base0B = '#b5bd68',
    base0C = '#8abeb7',
    base0D = '#81a2be',
    base0E = '#b294bb',
    base0F = '#a3685a',
  }

  local one_night = {
    base00 = '#fafafa',
    base01 = '#f0f0f1',
    base02 = '#e5e5e6',
    base03 = '#a0a1a7',
    base04 = '#696c77',
    base05 = '#383a42',
    base06 = '#202227',
    base07 = '#090a0b',
    base08 = '#ca1243',
    base09 = '#d75f00',
    base0A = '#c18401',
    base0B = '#50a14f',
    base0C = '#0184bc',
    base0D = '#4078f2',
    base0E = '#a626a4',
    base0F = '#986801',
  }

  local bg = vim.env.NVIM_COLORSCHEME_BG or 'dark'
  local pallete = bg == 'light' and one_night or tomorrow_night

  local custom_highlights = {
    IndentLine = { link = 'IndentBlanklineChar' },
    IndentLineCurrent = { link = 'IndentBlanklineContextChar' },
    SnacksPickerPrompt = { bg = pallete.base01, fg = pallete.base0C },
    LineNr = { bg = 'NONE' },
    LineNrAbove = { bg = 'NONE' },
    LineNrBelow = { bg = 'NONE' },
    CursorLineNr = { bg = 'NONE' },
    GitSignsAdd = { bg = 'NONE' },
    GitSignsChange = { bg = 'NONE' },
    GitSignsDelete = { bg = 'NONE' },
    WinSeparator = { bg = 'NONE' },
    DiagnosticUnderlineError = { undercurl = true },
    DiagnosticUnderlineHint = { undercurl = true },
    DiagnosticUnderlineInfo = { undercurl = true },
    DiagnosticUnderlineOk = { undercurl = true },
    DiagnosticUnderlineWarn = { undercurl = true },
    WarningMsg = { fg = pallete.base0A },
    Comment = { italic = true },
  }

  require('mini.base16').setup({
    palette = pallete,
    use_cterm = true,
  })

  for group, colors in pairs(custom_highlights) do
    colors.update = true
    vim.api.nvim_set_hl(0, group, colors)
  end
end

colorscheme.kape = function()
  require('kape').setup({
    styles = {
      type = {
        italic = false,
      },
    },
  })
  local kape = require('kape')
  if not kape then return end
  kape.load()
  local palette = require('kape.palette.kape')

  local custom_highlights = {
    IndentLine = { fg = palette.dimmed5 },
    IndentLineCurrent = { fg = palette.text },
    NormalFloat = { bg = palette.dark1 },
    FloatBorder = { bg = palette.dark1 },
    ['@lsp.type.function'] = { link = 'Function' },
    ['@lsp.typemod.function.defaultLibrary.lua'] = { link = 'Function' },
    BlinkCmpKindClass = { link = 'Type' },
    BlinkCmpKindColor = { link = 'Special' },
    BlinkCmpKindConstant = { link = 'Constant' },
    BlinkCmpKindConstructor = { link = 'Type' },
    BlinkCmpKindEnum = { link = 'Structure' },
    BlinkCmpKindEnumMember = { link = 'Structure' },
    BlinkCmpKindEvent = { link = 'Exception' },
    BlinkCmpKindField = { link = 'Structure' },
    BlinkCmpKindFile = { link = 'Tag' },
    BlinkCmpKindFolder = { link = 'Directory' },
    BlinkCmpKindFunction = { link = 'Function' },
    BlinkCmpKindInterface = { link = 'Structure' },
    BlinkCmpKindKeyword = { link = 'Keyword' },
    BlinkCmpKindMethod = { link = 'Function' },
    BlinkCmpKindModule = { link = 'Structure' },
    BlinkCmpKindOperator = { link = 'Operator' },
    BlinkCmpKindProperty = { link = 'Structure' },
    BlinkCmpKindReference = { link = 'Tag' },
    BlinkCmpKindSnippet = { link = 'Special' },
    BlinkCmpKindStruct = { link = 'Structure' },
    BlinkCmpKindText = { link = 'Statement' },
    BlinkCmpKindTypeParameter = { link = 'Type' },
    BlinkCmpKindUnit = { link = 'Special' },
    BlinkCmpKindValue = { link = 'Identifier' },
    BlinkCmpKindVariable = { link = 'Delimiter' },
  }

  for group, colors in pairs(custom_highlights) do
    colors.update = true
    vim.api.nvim_set_hl(0, group, colors)
  end
end

colorscheme.config = function()
  require('todo-comments').setup()
  local bg = vim.env.NVIM_COLORSCHEME_BG or 'dark'
  vim.opt.background = bg

  vim.cmd.filetype('plugin indent on')
  vim.cmd.syntax('on')
  if bg == 'light' then
    colorscheme.base16()
  else
    colorscheme.kape()
  end
end

return colorscheme
