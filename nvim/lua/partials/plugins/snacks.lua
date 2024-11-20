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
        enabled = false,
        top_down = false,
        margin = { bottom = 1 },
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
            key = 'a'
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

    -- Override the default notify function and make it work as nvim-notify
    vim.notify = function(msg, level, o)
      o = o or {}
      if o.replace or o.overwrite then
        o.id = o.replace or o.overwrite
      end
      local result = Snacks.notifier.notify(msg, level, o)
      if type(result) == 'table' then
        return result
      end
      return { id = result }
    end
  end,
}
