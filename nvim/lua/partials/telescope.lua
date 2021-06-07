local telescope = {}
local utils = require('partials/utils')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local sorters = require('telescope.sorters')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values

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
  end
})

local function is_file_valid(file)
  local stat = vim.loop.fs_stat(file)
  return stat and stat.type ~= 'directory'
end

function telescope.oldfiles_buffers()
  local buffers = {}
  local current_buffer = vim.api.nvim_get_current_buf()
  local current_buffer_path = vim.api.nvim_buf_get_name(current_buffer)
  for _, line in ipairs(vim.fn.split(vim.fn.execute('buffers t'), '\n')) do
    local bufnr, file = line:match('(%d+)[^"]*"([^"]+)"')
    if is_file_valid(file) and tonumber(bufnr) ~= current_buffer then
      table.insert(buffers, file)
    end
  end

  local oldfiles = vim.tbl_filter(function(val)
    return is_file_valid(val) and not vim.tbl_contains(buffers, val) and val ~= current_buffer_path
  end, vim.v.oldfiles)

  local results = vim.tbl_extend('keep', buffers, oldfiles)

  pickers.new({}, {
    prompt_title = 'History',
    finder = finders.new_table{
      results = results,
      entry_maker = make_entry.gen_from_file({}),
    },
    sorter = conf.file_sorter({}),
    previewer = conf.file_previewer({}),
  }):find()
end

require'telescope'.setup({
  defaults = {
    prompt_position = 'top',
    sorting_strategy = 'ascending',
    file_sorter = sorters.get_fzy_sorter,
    file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
    grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
    qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
    mappings = {
      i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<Esc>"] = actions.close,
        ['@'] =  custom_actions.jump_to_symbol,
        [':'] = custom_actions.jump_to_line,
      },
    }
  }
})

utils.keymap('n', '<C-p>', '<cmd>lua require("telescope.builtin").find_files({ find_command = { "rg", "--files" } })<cr>')
utils.keymap('n', '<Leader>b', "<cmd>lua require('telescope.builtin').buffers({ sort_lastused = true })<cr>")
utils.keymap('n', '<Leader>t', "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>")
utils.keymap('n', '<Leader>m', "<cmd>lua kris.telescope.oldfiles_buffers()<cr>")
utils.keymap('n', '<Leader>g', "<cmd>lua require('telescope.builtin').git_status()<cr>")

utils.keymap('n', '<Leader>lu', "<cmd>lua require('telescope.builtin').lsp_references()<cr>")
utils.keymap('n', '<Leader>lT', "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>")
utils.keymap('n', '<Leader>lt', "<cmd>lua require('telescope.builtin').current_buffer_tags()<cr>")

_G.kris.telescope = telescope
