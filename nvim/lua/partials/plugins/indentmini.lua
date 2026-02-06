return {
  'nvimdev/indentmini.nvim',
  event = 'VeryLazy',
  config = function()
    require('indentmini').setup({
      char = '▏',
      exclude = { 'dbout' },
    })
  end,
}
