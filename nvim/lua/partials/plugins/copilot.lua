local copilot = {
  install = function(packager)
    return packager.add('zbirenbaum/copilot.lua')
  end,
}
copilot.setup = function()
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
