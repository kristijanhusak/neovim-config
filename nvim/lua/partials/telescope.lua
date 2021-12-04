local telescope = {}
local utils = require('partials/utils')
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
        ['@'] = custom_actions.jump_to_symbol,
        [':'] = custom_actions.jump_to_line,
      },
    },
  },
})

utils.keymap(
  'n',
  '<C-p>',
  '<cmd>lua require("telescope.builtin").find_files({ find_command = { "rg", "--files" } })<cr>'
)
utils.keymap('n', '<Leader>b', "<cmd>lua require('telescope.builtin').buffers({ sort_lastused = true })<cr>")
utils.keymap('n', '<Leader>t', "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>")
utils.keymap('n', '<Leader>m', "<cmd>lua require('telescope.builtin').oldfiles()<cr>")
utils.keymap('n', '<Leader>g', "<cmd>lua require('telescope.builtin').git_status()<cr>")

utils.keymap('n', '<Leader>lT', "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>")
utils.keymap('n', '<Leader>lt', "<cmd>lua require('telescope.builtin').current_buffer_tags()<cr>")

_G.kris.telescope = telescope
