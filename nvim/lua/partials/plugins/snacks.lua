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
    })

    -- Override the default notify function and make it work as nvim-notify
    vim.notify = function(msg, level, o)
      o = o or {}
      if o.replace then
        o.id = o.replace
      end
      local result = Snacks.notifier.notify(msg, level, o)
      if type(result) == 'table' then
        return result
      end
      return { id = result }
    end
  end,
}
