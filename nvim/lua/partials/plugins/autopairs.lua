return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    map_cr = not vim.g.builtin_autocompletion,
    map_bs = not vim.g.builtin_autocompletion,
  },
}
