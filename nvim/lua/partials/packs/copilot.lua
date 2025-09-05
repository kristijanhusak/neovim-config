vim.pack.load({
  src = 'zbirenbaum/copilot.lua',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup({
      panel = {
        enabled = false,
      },
      suggestion = {
        auto_trigger = true,
        hide_during_completion = false,
        debounce = 700,
      },
    })
  end,
})
