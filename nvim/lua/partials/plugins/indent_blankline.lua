local indent_blankline = {
  install = function(packager)
    return packager.add('lukas-reineke/indent-blankline.nvim')
  end,
}
indent_blankline.setup = function()
  vim.api.nvim_create_autocmd('VimEnter', {
    pattern = '*',
    callback = function()
      require('indent_blankline').setup({
        char = '▏',
        show_current_context = true,
        disable_with_nolist = true,
      })
    end,
    once = true
  })
  return indent_blankline
end

return indent_blankline
