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
          { key = { 'C' }, action = 'cd' },
          { key = { 'X' }, action = 'system_open' },
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
    callback = function()
      local stats = vim.loop.fs_stat(vim.fn.expand('%:p'))
      if not stats or stats.type == 'directory' then
        vim.defer_fn(function()
          vim.cmd([[wincmd p]])
        end, 40)
      end
    end,
    group = nvim_tree_augroup,
  })


  vim.keymap.set('n', '<Leader>n', ':NvimTreeToggle<CR>', { silent = true })
  vim.keymap.set('n', '<Leader>hf', ':NvimTreeFindFile<CR>', { silent = true })

  return nvim_tree
end

return nvim_tree
