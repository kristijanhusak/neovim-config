return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    map_cr = not vim.g.enable_builtin_completion,
    map_bs = not vim.g.enable_builtin_completion,
  },
}
