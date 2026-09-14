return {
  'lukas-reineke/indent-blankline.nvim',
  event = 'VeryLazy',
  config = function()
    require('ibl').setup({
      indent = { char = '▏' },
      debounce = 50,
      scope = {
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
