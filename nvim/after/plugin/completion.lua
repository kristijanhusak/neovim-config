local utils = require('partials.utils')
if vim.fn.has('nvim-0.11') > 0 then
  vim.opt.completeitemalign = { 'kind', 'abbr', 'menu' }
end
vim.opt.completeopt = 'menu,menuone,noinsert,noselect,fuzzy,popup'
vim.opt.pumheight = 15

if not utils.enable_builtin_lsp_completion() then
  return
end

vim.keymap.set('i', '<Tab>', function()
  if vim.fn['vsnip#jumpable'](1) > 0 then
    return utils.feedkeys('<Plug>(vsnip-jump-next)')
  end
  if vim.fn['vsnip#expandable']() > 0 then
    return utils.feedkeys('<Plug>(vsnip-expand)')
  end
  if require('copilot.suggestion').is_visible() then
    require('copilot.suggestion').accept()
  elseif utils.has_words_before() then
    require('copilot.suggestion').next()
  else
    utils.feedkeys('<Tab>', 'n')
  end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
  if vim.fn['vsnip#jumpable'](-1) == 1 then
    return utils.feedkeys('<Plug>(vsnip-jump-prev)')
  end
  return utils.feedkeys('<S-Tab>', 'n')
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
  if vim.fn['vsnip#jumpable'](-1) == 1 then
    return utils.feedkeys('<Plug>(vsnip-jump-prev)')
  end
  return utils.feedkeys('<S-Tab>', 'n')
end, { silent = true })

if true then
  return
end

local lspMethods = vim.lsp.protocol.Methods

local get_completion_lsp_client = function()
  local clients = vim.lsp.get_clients({
    method = lspMethods.textDocument_completion,
    bufnr = 0,
  })
  if #clients > 0 then
    return clients[1]
  end
  return nil
end

local has_valid_lsp_clients = function()
  return get_completion_lsp_client() ~= nil
end

local preselect = function()
  if vim.fn.pumvisible() > 0 and vim.fn.complete_info({ 'selected' }).selected == -1 then
    utils.feedkeys('<C-n>', 'n')
  end
end

local function complete(key)
  utils.feedkeys(key, 'n')
  vim.schedule(preselect)
end

vim.keymap.set('i', '<C-n>', function()
  if vim.fn.pumvisible() > 0 then
    return utils.feedkeys('<C-n>', 'n')
  end

  local lsp_client = get_completion_lsp_client()
  ---@diagnostic disable-next-line: undefined-field
  local has_omnifunc = vim.opt_local.omnifunc:get() ~= ''

  if not lsp_client and not has_omnifunc then
    return complete('<C-n>')
  end

  if not lsp_client then
    utils.feedkeys('<C-x><C-o>', 'n')
    vim.schedule(function()
      if vim.fn.pumvisible() == 0 then
        complete('<C-e><C-n>')
      else
        preselect()
      end
    end)
    return
  end

  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)

  vim.lsp.completion.trigger()

  vim.wait(500, function()
    return #vim.tbl_filter(function(request)
      return request.method == lspMethods.textDocument_completion
    end, lsp_client.requests) == 0
  end)

  if vim.fn.pumvisible() > 0 then
    return preselect()
  end

  local mode = vim.api.nvim_get_mode().mode
  local is_insert_mode = mode == 'i' or mode == 'ic'
  local cursor_changed = not vim.deep_equal(cursor, vim.api.nvim_win_get_cursor(win))
  if cursor_changed or not is_insert_mode then
    return
  end
  complete('<C-e><C-n>')
end)

vim.keymap.set('i', '<C-space>', function()
  if has_valid_lsp_clients() then
    vim.lsp.completion.trigger()
  else
    utils.feedkeys('<C-x><C-o>', 'n')
  end
end)
