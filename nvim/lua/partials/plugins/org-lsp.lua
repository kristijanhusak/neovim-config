return {
  '~/github/org-lsp',
  enabled = vim.g.enable_org_lsp and true or false,
  event = 'VeryLazy',
  dir = '~/github/org-lsp',
  config = function()
    require('org-lsp').setup({
      calendar_win_mode = 'float',
      win_split_size = 0.75
    })
  end,
}
