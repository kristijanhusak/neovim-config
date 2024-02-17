return {
  'stevearc/oil.nvim',
  opts = {
    keymaps = {
      ['<C-v>'] = 'actions.select_vsplit',
      o = 'actions.select',
      q = 'actions.close',
      Q = 'actions.close',
    },
  },
  cmd = { 'Oil' },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  init = function()
    vim.keymap.set('n', '-', '<CMD>Oil<CR>')
  end,
}
