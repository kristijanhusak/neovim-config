local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local telescope = require('telescope')

local function setup_mappings()
  vim.keymap.set('n', '<C-p>', function()
    return builtin.find_files({ find_command = { 'rg', '--files', '--hidden' } })
  end)
  vim.keymap.set('n', '<Leader>b', function()
    return builtin.buffers({ sort_lastused = true })
  end)
  vim.keymap.set('n', '<Leader>t', builtin.lsp_document_symbols)
  vim.keymap.set('n', '<Leader>m', function()
    return telescope.extensions.recent_files.pick()
  end)
  vim.keymap.set('n', '<Leader>g', builtin.git_status)

  vim.keymap.set('n', '<Leader>lT', builtin.lsp_dynamic_workspace_symbols)
  vim.keymap.set('n', '<Leader>lt', builtin.current_buffer_tags)
end

local function setup_custom_actions()
  local transform_mod = require('telescope.actions.mt').transform_mod
  return transform_mod({
    jump_to_symbol = function(prompt_bufnr)
      actions.file_edit(prompt_bufnr)
      local valid_clients = #vim.tbl_filter(function(client)
        return client.server_capabilities.documentSymbolProvider
      end, vim.lsp.get_active_clients()) > 0

      if valid_clients and vim.lsp.buf.server_ready() then
        return builtin.lsp_document_symbols()
      end

      return builtin.current_buffer_tags()
    end,
    jump_to_line = function(prompt_bufnr)
      actions.file_edit(prompt_bufnr)
      vim.defer_fn(function()
        vim.api.nvim_feedkeys(':', 'n', true)
      end, 100)
    end,
  })
end

local ts = {
  install = function(packager)
    packager.add('nvim-telescope/telescope.nvim')
    packager.add('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })
    packager.add('smartpde/telescope-recent-files')
  end,
}
ts.setup = function()
  local custom_actions = setup_custom_actions()

  telescope.setup({
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = 'smart_case',
      },
    },
    defaults = {
      layout_config = {
        prompt_position = 'top',
        preview_cutoff = 170,
      },
      prompt_prefix = '   ',
      selection_caret = '  ',
      entry_prefix = '  ',
      results_title = false,
      sorting_strategy = 'ascending',
      mappings = {
        i = {
          ['<C-j>'] = actions.move_selection_next,
          ['<C-k>'] = actions.move_selection_previous,
          ['<Esc>'] = actions.close,
          ['<C-[>'] = actions.close,
          ['@'] = custom_actions.jump_to_symbol,
          [':'] = custom_actions.jump_to_line,
        },
      },
    },
  })

  telescope.load_extension('fzf')
  telescope.load_extension('recent_files')
  setup_mappings()
  return ts
end

return ts