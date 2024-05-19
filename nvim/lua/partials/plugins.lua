return {
  { 'tpope/vim-repeat', event = 'VeryLazy' },
  { 'tpope/vim-sleuth', event = 'VeryLazy' },
  { 'tpope/vim-abolish', event = 'VeryLazy' },
  { 'tpope/vim-surround', event = 'VeryLazy' },
  { 'nvim-lua/plenary.nvim' },
  { 'stefandtw/quickfix-reflector.vim', event = 'VeryLazy' },
  { 'wakatime/vim-wakatime', event = 'VeryLazy' },
  { 'LunarVim/bigfile.nvim', lazy = false, priority = 2000 },
  {
    'nvimdev/indentmini.nvim',
    event = 'VeryLazy',
    config = function()
      require('indentmini').setup({
        char = '▏',
      })
      vim.cmd('hi! link IndentLine IndentBlanklineChar')
      vim.cmd('hi! link IndentLineCurrent IndentBlanklineContextChar')
    end,
  },
}
