return {
  'yorickpeterse/nvim-pqf',
  event = 'VeryLazy',
  opts = {
    signs = {
      error = { text = _G.kris.diagnostic_icons[vim.diagnostic.severity.ERROR] },
      warning = { text = _G.kris.diagnostic_icons[vim.diagnostic.severity.WARN] },
      info = { text = _G.kris.diagnostic_icons[vim.diagnostic.severity.INFO] },
      hint = { text = _G.kris.diagnostic_icons[vim.diagnostic.severity.HINT] },
    },
  },
}
