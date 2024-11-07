return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true, debounce = 100 },
    notifier = {
      enabled = true,
      top_down = false,
      margin = { bottom = 1 }
    },
    quickfile = { enabled = false },
  },
  keys = {
    {
      '<leader>dl',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit',
    },
  },
}
