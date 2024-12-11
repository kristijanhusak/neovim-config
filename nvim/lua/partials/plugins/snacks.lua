return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  keys = {
    {
      '<leader>dl',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit',
    },
  },
  config = function()
    require('snacks').setup({
      bigfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true, debounce = 100 },
      quickfile = { enabled = false },
      notifier = {
        enabled = true,
        top_down = false,
        margin = { bottom = 1 },
      },
      dim = {
        animate = {
          enabled = false,
          duration = {
            total = 0
          }
        }
      },
      dashboard = {
        sections = {
          { section = 'header' },
          { section = 'keys', gap = 1, padding = 1 },
          {
            title = 'Orgmode',
            icon = ' ',
          },
          {
            title = 'Agenda',
            indent = 3,
            action = ':lua require("orgmode").agenda:agenda()',
            key = 'a',
          },
          {
            title = 'Capture',
            indent = 3,
            action = '<leader>oc',
            key = 'C',
            padding = 1,
          },
          { icon = ' ', title = 'Projects', section = 'projects', indent = 2, padding = 2 },
          { section = 'startup' },
        },
      },
    })

    vim.api.nvim_create_user_command('Notifications', function()
      Snacks.notifier.show_history()
    end, {
      nargs = 0,
    })
  end,
}
