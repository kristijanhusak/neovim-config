local nvim_tree = {
  install = function(packager)
    return packager.add('kyazdani42/nvim-tree.lua', { requires = 'kyazdani42/nvim-web-devicons' })
  end,
}
nvim_tree.setup = function()
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

  local nvim_tree_augroup = vim.api.nvim_create_augroup('custom_nvim_tree', { clear = true })
  vim.api.nvim_create_autocmd('VimEnter', {
    pattern = '*',
    group = nvim_tree_augroup,
    callback = function()
      vim.defer_fn(function()
        if vim.bo.filetype == 'NvimTree' then
          vim.cmd.wincmd('p')
        end
      end, 40)
    end,
  })

  vim.keymap.set('n', '<Leader>n', ':NvimTreeToggle<CR>', { silent = true })
  vim.keymap.set('n', '<Leader>hf', ':NvimTreeFindFile<CR>', { silent = true })

  return nvim_tree
end

return nvim_tree
