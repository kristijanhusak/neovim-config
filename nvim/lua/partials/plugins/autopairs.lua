return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {
    map_cr = not vim.g.enable_custom_completion,
    map_bs = not vim.g.enable_custom_completion,
  }
}
