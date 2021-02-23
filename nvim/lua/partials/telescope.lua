local telescope = {}
local utils = require('partials/utils')
local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
local sorters = require('telescope.sorters')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local pickers = require('telescope.pickers')
local conf = require('telescope.config').values

vim.cmd[[augroup telescope_buffers]]
  vim.cmd[[autocmd!]]
  vim.cmd[[autocmd BufWinEnter,WinEnter * call v:lua.kris.telescope.save_buf(bufnr(''))]]
  vim.cmd[[autocmd BufDelete * silent! call v:lua.kris.telescope.remove_buf(expand('<abuf>'))]]
vim.cmd[[augroup END]]

local buffers = {}
function telescope.save_buf(bufnr)
  buffers[tostring(bufnr)] = vim.fn.reltimefloat(vim.fn.reltime())
  return buffers
end

function telescope.remove_buf(bufnr)
  buffers[tostring(bufnr)] = nil
  return buffers
end

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


function telescope.oldfiles_buffers()
  local bufnrs = vim.tbl_filter(function(b)
    local bufnr = tonumber(b)
    local bufname = vim.fn.bufname(bufnr)
    return vim.api.nvim_buf_is_loaded(bufnr) and 1 == vim.fn.buflisted(bufnr) and bufname ~= '' and vim.fn.isdirectory(bufname) ~= 1
  end, vim.tbl_keys(buffers))

  local bufs = vim.fn.sort(bufnrs, function(b1, b2)
    local buf1 = buffers[b1]
    local buf2 = buffers[b2]
    return buf1 < buf2 and 1 or -1
  end)

  bufs = vim.tbl_map(function(bufnr)
    return vim.fn.bufname(tonumber(bufnr))
  end, bufs)

  local oldfiles = vim.tbl_filter(function(val)
    return 0 ~= vim.fn.filereadable(val)
  end, vim.v.oldfiles)

  local default_selection_index = 1
  local results = vim.tbl_extend('keep', bufs, oldfiles)
  if #bufs > 0 then
    default_selection_index = 2
  end

  pickers.new({}, {
    prompt_title = 'History',
    finder = finders.new_table{
      results = results,
      entry_maker = make_entry.gen_from_file({}),
    },
    sorter = conf.file_sorter({}),
    previewer = conf.file_previewer({}),
    default_selection_index = default_selection_index
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
utils.keymap('n', '<Leader>m', "<cmd>call v:lua.kris.telescope.oldfiles_buffers()<cr>")
utils.keymap('n', '<Leader>g', "<cmd>lua require('telescope.builtin').git_status()<cr>")

utils.keymap('n', '<Leader>lu', "<cmd>lua require('telescope.builtin').lsp_references()<cr>")
utils.keymap('n', '<Leader>lT', "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>")
utils.keymap('n', '<Leader>lt', "<cmd>lua require('telescope.builtin').current_buffer_tags()<cr>")

_G.kris.telescope = telescope
