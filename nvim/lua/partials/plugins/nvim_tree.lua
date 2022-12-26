local nvim_tree = {
  'kyazdani42/nvim-tree.lua',
  dependencies = 'kyazdani42/nvim-web-devicons',
  cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
}

nvim_tree.init = function()
  vim.keymap.set('n', '<Leader>n', ':NvimTreeToggle<CR>', { silent = true })
  vim.keymap.set('n', '<Leader>hf', ':NvimTreeFindFile<CR>', { silent = true })
end

nvim_tree.config = {
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
    float = {
      enable = true,
      open_win_config = function()
        return {
          relative = 'editor',
          border = 'rounded',
          width = 50,
          height = vim.o.lines - 5,
          row = 0,
          col = 0,
        }
      end,
    },
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
}

return nvim_tree
