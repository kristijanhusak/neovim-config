return {
  'yorickpeterse/nvim-pqf',
  event = 'VeryLazy',
  opts = {
    signs = {
      error = _G.kris.diagnostic_icons[vim.diagnostic.severity.ERROR],
      warning = _G.kris.diagnostic_icons[vim.diagnostic.severity.WARN],
      info = _G.kris.diagnostic_icons[vim.diagnostic.severity.INFO],
      hint = _G.kris.diagnostic_icons[vim.diagnostic.severity.HINT],
    },
  },
}
