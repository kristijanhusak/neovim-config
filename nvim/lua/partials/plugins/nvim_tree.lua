local nvim_tree = {
  'kyazdani42/nvim-tree.lua',
  dependencies = 'kyazdani42/nvim-web-devicons',
}
nvim_tree.config = function()
  require('nvim-tree').setup({
    hijack_unnamed_buffer_when_opening = false,
    disable_netrw = true,
    open_on_setup = true,
    update_focused_file = {
      enable = true,
    },
    diagnostics = {
      enable = true,
    },
    actions = {
      open_file = {
        resize_window = true,
      },
    },
    view = {
      mappings = {
        list = {
          { key = { 's' }, action = 'vsplit' },
          { key = { '<s-c>' }, action = 'cd' },
          { key = { '<s-x>' }, action = 'system_open' },
        },
      },
    },
    renderer = {
      full_name = true,
      highlight_git = true,
      icons = {
        glyphs = {
          default = '',
          git = {
            unstaged = '✹',
          },
        },
      },
    },
  })

  local api = require('nvim-tree.api')
  local Event = api.events.Event

  api.events.subscribe(Event.Ready, function()
    vim.schedule(function()
      vim.cmd.wincmd('p')
    end)
  end)

  vim.keymap.set('n', '<Leader>n', ':NvimTreeToggle<CR>', { silent = true })
  vim.keymap.set('n', '<Leader>hf', ':NvimTreeFindFile<CR>', { silent = true })

  return nvim_tree
end

return nvim_tree
