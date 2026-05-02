return {
  { 'tpope/vim-repeat', event = 'VeryLazy' },
  { 'tpope/vim-sleuth', event = 'VeryLazy' },
  { 'tpope/vim-abolish', event = 'VeryLazy' },
  { 'tpope/vim-surround', event = 'VeryLazy' },
  { 'nvim-tree/nvim-web-devicons' },
  { 'nvim-lua/plenary.nvim' },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup({
        preset = 'helix',
        plugins = {
          spelling = {
            enabled = vim.fn.has('nvim-0.13') == 0,
          },
        },
      })
    end,
  },
}
