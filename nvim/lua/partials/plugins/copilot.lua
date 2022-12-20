local copilot = {
  'zbirenbaum/copilot.lua',
  event = 'InsertEnter',
}
copilot.config = function()
  require('copilot').setup({
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
  })

  return copilot
end

return copilot
