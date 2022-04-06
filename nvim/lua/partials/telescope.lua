local telescope = {}
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

local transform_mod = require('telescope.actions.mt').transform_mod
local custom_actions = transform_mod({
  jump_to_symbol = function(prompt_bufnr)
    actions.file_edit(prompt_bufnr)
    builtin.lsp_document_symbols()
    vim.defer_fn(function()
      vim.cmd('startinsert')
    end, 0)
  end,
  jump_to_line = function(prompt_bufnr)
    actions.file_edit(prompt_bufnr)
    vim.defer_fn(function()
      vim.api.nvim_feedkeys(':', 'n', true)
    end, 100)
  end,
})

require('telescope').setup({
  defaults = {
    layout_config = {
      prompt_position = 'top',
    },
    sorting_strategy = 'ascending',
    mappings = {
      i = {
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
        ['<Esc>'] = actions.close,
        ['<C-w>'] = function()
          vim.cmd([[normal! bcw]])
        end,
        ['@'] = custom_actions.jump_to_symbol,
        [':'] = custom_actions.jump_to_line,
      },
    },
  },
})

vim.keymap.set('n', '<C-p>', function()
  return builtin.find_files({ find_command = { 'rg', '--files', '--hidden' } })
end)
vim.keymap.set('n', '<Leader>b', function()
  return builtin.buffers({ sort_lastused = true })
end)
vim.keymap.set('n', '<Leader>t', builtin.lsp_document_symbols)
vim.keymap.set('n', '<Leader>m', builtin.oldfiles)
vim.keymap.set('n', '<Leader>g', builtin.git_status)

vim.keymap.set('n', '<Leader>lT', builtin.lsp_dynamic_workspace_symbols)
vim.keymap.set('n', '<Leader>lt', builtin.current_buffer_tags)

_G.kris.telescope = telescope
