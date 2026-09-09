return {
  'lukas-reineke/indent-blankline.nvim',
  event = 'VeryLazy',
  config = function()
    require('ibl').setup({
      indent = { char = '▏', highlight = 'IndentLine' },
      debounce = 50,
      scope = {
        highlight = { 'IndentLineCurrent' },
        enabled = true,
        show_start = false,
        show_end = false,
        include = {
          node_type = { ['*'] = { '*' } },
        },
      },
      exclude = {
        filetypes = { 'dbout' },
      },
    })
  end,
}
