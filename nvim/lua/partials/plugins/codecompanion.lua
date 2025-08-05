return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'ravitemer/codecompanion-history.nvim',
  },
  event = 'VeryLazy',
  keys = {
    {
      '<leader>ea',
      mode = { 'n', 'x' },
      function()
        vim.cmd('CodeCompanionActions')
      end,
      desc = 'Open Code Companion Actions',
    },
    {
      '<leader>ee',
      mode = { 'n', 'x' },
      function()
        vim.cmd('CodeCompanionChat')
      end,
      desc = 'Open Code Companion Chat',
    },
  },
  opts = {
    extensions = {
      history = {
        enabled = true,
        opts = {
          picker = 'default',
        },
      },
    },
    strategies = {
      chat = { adapter = 'copilot' },
      inline = { adapter = 'copilot' },
    },
    adapters = {
      gemini = function()
        return require('codecompanion.adapters').extend('gemini', {
          env = {
            api_key = vim.env.GEMINI_API_KEY,
          },
        })
      end,
    },
  },
}
