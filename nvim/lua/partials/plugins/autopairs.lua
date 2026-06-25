return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup({
      map_cr = not vim.g.builtin_autocompletion,
      map_bs = not vim.g.builtin_autocompletion,
    })
  end,
}
