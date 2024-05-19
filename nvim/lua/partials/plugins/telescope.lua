local function setup_custom_actions(actions, builtin)
  local transform_mod = require('telescope.actions.mt').transform_mod
  return transform_mod({
    jump_to_symbol = function(prompt_bufnr)
      actions.file_edit(prompt_bufnr)
      builtin.lsp_document_symbols()
    end,
  })
end

local ts = {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'smartpde/telescope-recent-files' },
  },
  cmd = { 'Telescope' },
}
ts.init = function()
  vim.keymap.set('n', '<C-p>', function()
    return require('telescope.builtin').find_files({ find_command = { 'rg', '--files', '--hidden', '-g', '!.git/' } })
  end)
  vim.keymap.set('n', '<C-y>', function()
    return require('telescope.builtin').resume()
  end)
  vim.keymap.set('n', '<Leader>b', function()
    return require('telescope.builtin').buffers({ sort_lastused = true })
  end)
  vim.keymap.set('n', '<Leader>m', function()
    return require('telescope').extensions.recent_files.pick()
  end)
  vim.keymap.set('n', '<Leader>g', function()
    return require('telescope.builtin').git_status()
  end)
end
ts.config = function()
  local builtin = require('telescope.builtin')
  local actions = require('telescope.actions')
  local telescope = require('telescope')
  local custom_actions = setup_custom_actions(actions, builtin)

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
      selection_caret = '󰼛 ',
      entry_prefix = '  ',
      results_title = false,
      sorting_strategy = 'ascending',
      mappings = {
        i = {
          ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
          ['<C-j>'] = actions.move_selection_next,
          ['<C-k>'] = actions.move_selection_previous,
          ['<Esc>'] = actions.close,
          ['<C-[>'] = actions.close,
          ['<C-s>'] = custom_actions.jump_to_symbol,
        },
      },
    },
  })

  telescope.load_extension('fzf')
  telescope.load_extension('recent_files')
  telescope.load_extension('workspaces')
  telescope.load_extension('notify')
  return ts
end

return ts
