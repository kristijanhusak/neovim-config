local utils = require('partials.utils')
if not utils.enable_builtin_lsp_completion() then
  return
end

vim.opt.completeopt = 'menu,menuone,noinsert,noselect,fuzzy,popup'
vim.opt.pumheight = 15

local has_valid_lsp_clients = function()
  return #vim.lsp.get_clients({ method = 'textDocument/completion', bufnr = 0 }) > 0
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
    utils.feedkeys('<Tab>')
  end
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
  if vim.fn['vsnip#jumpable'](-1) == 1 then
    return utils.feedkeys('<Plug>(vsnip-jump-prev)')
  end
  return utils.feedkeys('<S-Tab>')
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
  if vim.fn['vsnip#jumpable'](-1) == 1 then
    return utils.feedkeys('<Plug>(vsnip-jump-prev)')
  end
  return utils.feedkeys('<S-Tab>')
end, { silent = true })

vim.keymap.set('i', '<C-n>', function()
  ---@diagnostic disable-next-line: undefined-field
  if vim.fn.pumvisible() > 0 then
    return utils.feedkeys('<C-n>', 'n')
  end

  local has_lsp = has_valid_lsp_clients()
  ---@diagnostic disable-next-line: undefined-field
  local has_omnifunc = vim.opt_local.omnifunc:get() ~= ''

  if not has_lsp and not has_omnifunc then
    return utils.feedkeys('<C-n>', 'n')
  end

  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)

  if has_lsp then
    vim.lsp.completion.trigger()
  else
    utils.feedkeys('<C-x><C-o>', 'n')
  end

  vim.defer_fn(function()
    if vim.fn.pumvisible() > 0 then
      return
    end

    local mode = vim.api.nvim_get_mode().mode
    local is_insert_mode = mode == 'i' or mode == 'ic'
    local cursor_changed = not vim.deep_equal(cursor, vim.api.nvim_win_get_cursor(win))
    if cursor_changed or not is_insert_mode then
      return
    end
    utils.feedkeys('<C-e><C-n>', 'n')
  end, 100)
end)

vim.keymap.set('i', '<C-space>', function()
  if has_valid_lsp_clients() then
    vim.lsp.completion.trigger()
  else
    utils.feedkeys('<C-x><C-o>', 'n')
  end
end)

local group = vim.api.nvim_create_augroup('kris_builtin_lsp', { clear = true })

vim.api.nvim_create_autocmd('CompleteDonePre', {
  group = group,
  callback = function()
    local item = vim.v.completed_item

    if item and vim.tbl_get(item, 'user_data', 'nvim', 'lsp', 'completion_item', 'labelDetails') then
      item.user_data.nvim.lsp.completion_item.labelDetails = nil
      vim.v.completed_item = item
    end
  end,
})
