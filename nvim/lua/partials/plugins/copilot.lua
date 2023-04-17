return {
  'zbirenbaum/copilot.lua',
  event = 'InsertEnter',
  enabled = function()
    return not vim.g.started_by_firenvim
  end,
  opts = {
    panel = {
      enabled = false,
    },
    filetypes = {
      TelescopePrompt = false,
      TelescopeResults = false,
    },
    suggestion = {
      auto_trigger = true,
    },
  },
}
