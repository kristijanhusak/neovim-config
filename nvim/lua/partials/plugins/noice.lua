return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  opts = {
    messages = {
      view_search = false,
    },
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
      hover = {
        enabled = false,
        opts = {
          border = 'rounded',
          focusable = false,
        },
      },
      signature = {
        opts = {
          border = 'rounded',
          focusable = false,
          silent = true,
        },
      },
    },
  },
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
}
