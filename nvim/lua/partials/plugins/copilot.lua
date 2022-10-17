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
    plugin_manager_path = vim.fn.stdpath('config') .. '/pack/packager',
  })

  return copilot
end

return copilot
