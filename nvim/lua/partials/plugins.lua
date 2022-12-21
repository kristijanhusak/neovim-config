return {
  { 'tpope/vim-repeat', event = 'VeryLazy' },
  { 'tpope/vim-sleuth' },
  { 'tpope/vim-abolish', event = 'VeryLazy' },
  { 'tpope/vim-surround', event = 'VeryLazy' },
  {
    'windwp/nvim-ts-autotag',
    event = 'VeryLazy',
  },
  { 'nvim-lua/plenary.nvim', event = 'VeryLazy' },
  {
    'ludovicchabant/vim-gutentags',
    event = 'VeryLazy',
  },
  {
    'stefandtw/quickfix-reflector.vim',
    event = 'VeryLazy',
  },
  {
    'wakatime/vim-wakatime',
    event = 'VeryLazy',
  },
  {
    'Raimondi/delimitMate',
    config = function()
      vim.g.delimitMate_expand_cr = 1
    end,
    event = 'VeryLazy',
  },
}
