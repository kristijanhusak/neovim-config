return {
  'nvimdev/indentmini.nvim',
  event = 'VeryLazy',
  enabled = function()
    return vim.fn.has('nvim-0.10') > 0
  end,
  config = function()
    require('indentmini').setup({
      char = '▏',
      exclude = { 'dbout' },
    })
    vim.cmd('hi! link IndentLine IndentBlanklineChar')
    vim.cmd('hi! link IndentLineCurrent IndentBlanklineContextChar')
  end,
}
