return {
  'nvim-mini/mini.pairs',
  event = 'VeryLazy',
  config = function()
    require('mini.pairs').setup()
  end,
}
