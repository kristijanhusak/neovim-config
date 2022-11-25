local treesj = {
  install = function(packager)
    return packager.add('Wansmer/treesj')
  end,
}
treesj.setup = function()
  require('treesj').setup({
    use_default_keymaps = false,
    check_syntax_error = true,
    max_join_length = 200,
    cursor_behavior = 'hold',
    notify = true,
  })
  vim.keymap.set('n', 'gS', ':TSJSplit<CR>', { silent = true })
  vim.keymap.set('n', 'gJ', ':TSJJoin<CR>', { silent = true })
  return treesj
end

return treesj
