local is_nightly = vim.fn.has('nvim-0.13') == 1
return {
  { 'tpope/vim-repeat', event = 'VeryLazy' },
  {
    'tpope/vim-sleuth',
    event = 'VeryLazy',
    enabled = false,
  },
  {
    'tpope/vim-abolish',
    event = 'VeryLazy',
    enabled = false,
  },
  { 'tpope/vim-surround', event = 'VeryLazy' },
  { 'nvim-tree/nvim-web-devicons' },
  { 'nvim-lua/plenary.nvim', priority = 800 },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    enabled = not is_nightly,
    config = function()
      require('which-key').setup({
        preset = 'helix',
        plugins = {
          spelling = {
            enabled = not is_nightly,
          },
        },
      })
    end,
  },
}
