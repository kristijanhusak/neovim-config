vim.pack.load({
  src = 'stevearc/quicker.nvim',
  ft = 'qf',
  config = function()
    require('quicker').setup({
      highlight = {
        lsp = false,
        treesitter = false,
      },
      type_icons = {
        E = _G.kris.diagnostic_icons[vim.diagnostic.severity.ERROR],
        W = _G.kris.diagnostic_icons[vim.diagnostic.severity.WARN],
        I = _G.kris.diagnostic_icons[vim.diagnostic.severity.INFO],
        N = _G.kris.diagnostic_icons[vim.diagnostic.severity.HINT],
        H = _G.kris.diagnostic_icons[vim.diagnostic.severity.HINT],
      },
    })
  end,
})
