return {
  { 'tpope/vim-repeat', event = 'VeryLazy' },
  { 'tpope/vim-sleuth', event = 'VeryLazy' },
  { 'tpope/vim-abolish', event = 'VeryLazy' },
  { 'tpope/vim-surround', event = 'VeryLazy' },
  { 'windwp/nvim-ts-autotag', event = 'VeryLazy' },
  { 'nvim-lua/plenary.nvim', event = 'VeryLazy' },
  { 'stefandtw/quickfix-reflector.vim', event = 'VeryLazy' },
  { 'wakatime/vim-wakatime', event = 'VeryLazy' },
  { 'LunarVim/bigfile.nvim' },
  {
    'glacambre/firenvim',

    cond = not not vim.g.started_by_firenvim,
    build = function()
      require('lazy').load({ plugins = 'firenvim', wait = true })
      vim.fn['firenvim#install'](0)
    end,
  },
}
