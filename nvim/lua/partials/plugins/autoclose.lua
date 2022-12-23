  return {
    'm4xshen/autoclose.nvim',
    event = 'VeryLazy',
    config = function()
      require('autoclose').setup({})
    end,
  }
