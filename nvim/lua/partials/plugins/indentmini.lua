return {
  'nvimdev/indentmini.nvim',
  event = 'VeryLazy',
  config = function()
    require('indentmini').setup({
      char = '▏',
      exclude = { 'dbout' },
    })
    vim.cmd('hi! link IndentLine IndentBlanklineChar')
    vim.cmd('hi! link IndentLineCurrent IndentBlanklineContextChar')
  end,
}
