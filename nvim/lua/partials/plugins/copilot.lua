return {
  'zbirenbaum/copilot.lua',
  event = 'InsertEnter',
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
      hide_during_completion = false
    },
  },
}
