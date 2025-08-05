return {
  'CopilotC-Nvim/CopilotChat.nvim',
  enabled = false,
  opts = {
    show_help = 'no',
    debug = false,
    disable_extra_info = 'no',
    language = 'English',
  },
  cmd = { 'CopilotChat' },
  keys = {
    {
      '<leader>et',
      function()
        require('CopilotChat').toggle()
      end,
      desc = 'Open Copilot Chat',
    },
  }
}
