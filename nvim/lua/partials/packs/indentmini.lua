vim.pack.on_start({
  src = 'nvimdev/indentmini.nvim',
  config = function()
    require('indentmini').setup({
      char = '▏',
      exclude = { 'dbout' },
    })
  end,
})
