return {
  'zbirenbaum/copilot.lua',
  event = 'InsertEnter',
  config = {
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
