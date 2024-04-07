return {
  'zbirenbaum/copilot.lua',
  event = 'InsertEnter',
  opts = {
    panel = {
      enabled = true,
      keymap = {
        open = '<D-h>',
      },
    },
    filetypes = {
      TelescopePrompt = false,
      TelescopeResults = false,
    },
  },
}
