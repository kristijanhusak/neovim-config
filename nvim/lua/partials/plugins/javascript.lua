local js_group = vim.api.nvim_create_augroup('custom_javascript', { clear = true })
local utils = require('partials.utils')
local fn = vim.fn

local handlers = {}
local filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

local javascript = {
  'dmmulroy/tsc.nvim',
  ft = filetypes,
}
javascript.config = function()
  require('tsc').setup({
    auto_close_qflist = true,
  })
  vim.keymap.set('n', '<Plug>(JsConsoleLog)', handlers.console_log)
  vim.keymap.set('n', '<Plug>(JsGotoFile)', handlers.goto_file)

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    callback = handlers.setup_buffer,
    group = js_group,
  })

  if vim.tbl_contains(filetypes, vim.bo.filetype) then
    vim.cmd('doautocmd FileType ' .. vim.bo.filetype)
  end

  return javascript
end

function handlers.setup_buffer()
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
  local view = fn.winsaveview() or {}
  local word = fn.expand('<cword>')
  local node = vim.treesitter.get_node()
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
