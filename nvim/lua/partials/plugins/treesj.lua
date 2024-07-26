return {
  'Wansmer/treesj',
  cmd = { 'TSJSplit', 'TSJJoin' },
  init = function()
    vim.keymap.set('n', 'gS', ':TSJSplit<CR>', { silent = true, desc = 'Split to lines' })
    vim.keymap.set('n', 'gJ', ':TSJJoin<CR>', { silent = true, desc = 'Join lines' })
  end,
  opts = {
    use_default_keymaps = false,
    check_syntax_error = true,
    max_join_length = 200,
    cursor_behavior = 'hold',
    notify = true,
  },
}
