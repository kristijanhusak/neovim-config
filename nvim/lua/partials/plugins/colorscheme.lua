local colorscheme = {
  'catppuccin/nvim',
  dependencies = {
    'folke/todo-comments.nvim',
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

colorscheme.config = function()
  require('todo-comments').setup()
  vim.opt.background = vim.env.NVIM_COLORSCHEME_BG or 'dark'

  vim.cmd.filetype('plugin indent on')
  vim.cmd.syntax('on')
  colorscheme.catppuccin()
end

return colorscheme
