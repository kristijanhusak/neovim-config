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
    opts = {
      preset = 'helix',
    },
  },
  {
    'A7Lavinraj/fyler.nvim',
    dependencies = { 'echasnovski/mini.icons', opts = {} },
    cmd = { 'Fyler' },
    config = function()
      require('fyler').setup({
        window_config = {
          split = 'left',
        },
        window_options = {
          number = false,
          relativenubmers = false,
        },
      })

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'fyler',
        command = 'setlocal signcolumn=yes'
      })

      vim.api.nvim_set_hl(0, 'FylerParagraph', {})
    end,
  },
}
