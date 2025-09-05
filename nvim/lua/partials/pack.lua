require('partials.utils.pack')

vim.pack.load({ src = 'tpope/vim-repeat', event = 'VeryLazy' })
vim.pack.load({ src = 'tpope/vim-sleuth', event = 'VeryLazy' })
vim.pack.load({ src = 'tpope/vim-abolish', event = 'VeryLazy' })
vim.pack.load({ src = 'tpope/vim-surround', event = 'VeryLazy' })
vim.pack.load({ src = 'nvim-tree/nvim-web-devicons' })
vim.pack.load({ src = 'nvim-lua/plenary.nvim' })
vim.pack.load({
  src = 'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    require('which-key').setup({
      preset = 'helix',
    })
  end,
})

vim.pack.dir('./packs')
