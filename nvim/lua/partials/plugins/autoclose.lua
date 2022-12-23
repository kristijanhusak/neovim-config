return {
  'm4xshen/autoclose.nvim',
  event = 'InsertEnter',
  config = function()
    require('autoclose').setup({})
  end,
}
