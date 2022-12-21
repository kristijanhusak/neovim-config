local treesj = {
  'Wansmer/treesj',
  cmd = { 'TSJSplit', 'TSJJoin' },
}
treesj.init = function()
  vim.keymap.set('n', 'gS', ':TSJSplit<CR>', { silent = true })
  vim.keymap.set('n', 'gJ', ':TSJJoin<CR>', { silent = true })
end
treesj.config = function()
  require('treesj').setup({
    use_default_keymaps = false,
    check_syntax_error = true,
    max_join_length = 200,
    cursor_behavior = 'hold',
    notify = true,
  })
end

return treesj
