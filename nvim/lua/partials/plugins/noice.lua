local noice = {
  install = function(packager)
    return packager.add('folke/noice.nvim', {
      requires = 'MunifTanjim/nui.nvim',
    })
  end,
}
noice.setup = function()
  require('noice').setup({
    messages = {
      view_search = false,
    },
    views = {
      cmdline_popup = {
        position = {
          row = 1,
          col = '50%',
        },
        size = {
          width = 80,
          height = 'auto',
        },
      },
      popupmenu = {
        relative = 'editor',
        position = {
          row = 4,
          col = '50%',
        },
        size = {
          width = 80,
          height = 10,
        },
        border = {
          style = 'rounded',
          padding = { top = 0, left = 0, right = 0, bottom = 0 },
        },
        win_options = {
          winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
        },
      },
    },
    lsp_progress = {
      enabled = false,
    },
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = "",
          find = "written",
        },
        opts = { skip = true },
      },
    },
  })
  return noice
end

return noice
