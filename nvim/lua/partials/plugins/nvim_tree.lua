local nvim_tree = {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'antosha417/nvim-lsp-file-operations',
  },
  cmd = { 'NvimTreeToggle', 'NvimTreeFindFile', 'NvimTreeOpen' },
}

nvim_tree.init = function()
  vim.keymap.set('n', '<Leader>n', ':NvimTreeToggle<CR>', { silent = true, desc = 'Toggle NvimTree' })
  vim.keymap.set('n', '<Leader>hf', ':NvimTreeToggle<CR>', { silent = true, desc = 'Toggle NvimTree on current file' })
end

nvim_tree.config = function()
  require('nvim-tree').setup({
    hijack_unnamed_buffer_when_opening = false,
    on_attach = function(bufnr)
      local api = require('nvim-tree.api')
      local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }
      api.config.mappings.default_on_attach(bufnr)

      vim.keymap.set('n', 's', api.node.open.vertical, opts)
      vim.keymap.set('n', '<s-c>', api.tree.change_root_to_node, opts)
      vim.keymap.set('n', '<s-x>', api.node.run.system, opts)
    end,
    disable_netrw = true,
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
      width = 40,
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
  require('lsp-file-operations').setup()
end

return nvim_tree
