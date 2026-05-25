return {
  'nvim-mini/mini.pairs',
  event = 'InsertEnter',
  config = function()
    require('mini.pairs').setup()
  end,
}
