local js_group = vim.api.nvim_create_augroup('custom_javascript', { clear = true })
local utils = require('partials.utils')
local fn = vim.fn

local handlers = {}
local filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

local javascript = {
  'kristijanhusak/vim-js-file-import',
  ft = filetypes,
}
javascript.config = function()
  vim.keymap.set('n', '<Plug>(JsConsoleLog)', handlers.console_log)
  vim.keymap.set('n', '<Plug>(JsGotoFile)', handlers.goto_file)

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    callback = handlers.setup_buffer,
    group = js_group,
  })

  vim.g.js_file_import_use_telescope = 1

  if vim.tbl_contains(filetypes, vim.bo.filetype) then
    vim.cmd('doautocmd FileType ' .. vim.bo.filetype)
  end

  return javascript
end

function handlers.setup_buffer()
  vim.keymap.set('n', '<C-]>', handlers.goto_definition, { remap = true, buffer = true })
  vim.keymap.set('x', '<C-]>', '<Plug>(JsGotoDefinition)', { remap = true, buffer = true })
  vim.keymap.set('n', '<Leader>]', '<C-W>v<Plug>(JsGotoDefinition)', { remap = true, buffer = true })
  vim.keymap.set('x', '<Leader>]', '<C-W>vgv<Plug>(JsGotoDefinition)', { remap = true, buffer = true })
  vim.keymap.set('n', '<Leader>ll', '<Plug>(JsConsoleLog)', { remap = true, buffer = true })
  vim.keymap.set('n', 'gf', '<Plug>(JsGotoFile)', { remap = true, buffer = true })
  vim.keymap.set('n', '<F1>', handlers.setup_imports, { buffer = true, silent = true })
  vim.keymap.set('n', '<F2>', function()
    return handlers.setup_imports(true)
  end, { buffer = true, silent = true })
  vim.opt_local.isfname:append('@-@')
  vim.cmd('compiler tsc')
end

function handlers.console_log()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local view = fn.winsaveview()
  local word = fn.expand('<cword>')
  local node = ts_utils.get_node_at_cursor()
  while node and node:type() ~= 'lexical_declaration' do
    node = node:parent()
  end
  if node then
    local _, _, end_line, _ = vim.treesitter.get_node_range(node)
    fn.cursor(end_line + 1, 0)
  end
  local scope = utils.get_gps_scope(word)
  if not scope:match(vim.pesc(word) .. '$') then
    scope = ('%s > %s'):format(scope, word)
  end
  vim.cmd(string.format("keepjumps norm!oconsole.log('%s', %s); // eslint-disable-line no-console", scope, word))
  fn['repeat#set'](utils.esc('<Plug>(JsConsoleLog)'))
  fn.winrestview(view)
end

function handlers.goto_file()
  local full_path = fn.printf('%s/%s', fn.expand('%:p:h'), fn.expand('<cfile>'))
  local stats = vim.loop.fs_stat(full_path)
  if not stats or stats.type ~= 'directory' then
    return vim.cmd([[norm! gf]])
  end

  for _, suffix in ipairs(fn.split(vim.bo.suffixesadd, ',')) do
    local index_file = full_path .. '/index' .. suffix
    if fn.filereadable(index_file) then
      return vim.cmd.edit(index_file)
    end
  end
end

function handlers.goto_definition()
  local line = vim.fn.line('.')
  local bufnr = vim.api.nvim_get_current_buf()
  require('telescope.builtin').lsp_definitions()

  vim.defer_fn(function()
    -- We didn't jump anywhere in 300ms, fallback to JsGotoDefinition
    if line == vim.fn.line('.') and bufnr == vim.api.nvim_get_current_buf() then
      vim.cmd.JsGotoDefinition()
    end
  end, 300)
end

function handlers.execute_cmds(vtsls, bufnr, commands)
  if #commands == 0 then
    return
  end
  local cmd = commands[1]
  table.remove(commands, 1)
  return vtsls.commands[cmd](bufnr, function()
    return handlers.execute_cmds(vtsls, bufnr, commands)
  end)
end

---@param organize? boolean
function handlers.setup_imports(organize)
  local vtsls = require('vtsls')
  local bufnr = vim.api.nvim_get_current_buf()
  local commands = { 'remove_unused_imports', 'add_missing_imports', 'fix_all' }
  if organize then
    table.insert(commands, 'organize_imports')
  end

  return handlers.execute_cmds(vtsls, bufnr, commands)
end

return javascript
