local indent_blankline = {
  'lukas-reineke/indent-blankline.nvim',
  event = 'ColorScheme',
}
indent_blankline.config = function()
  require('indent_blankline').setup({
    char = '▏',
    show_current_context = true,
    disable_with_nolist = true,
  })
end

return indent_blankline
