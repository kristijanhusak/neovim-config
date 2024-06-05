local utils = require('partials.utils')
if not utils.enable_builtin_lsp_completion() then
  return
end

vim.opt.completeopt = 'menu,menuone,noinsert,noselect,fuzzy,popup'
vim.opt.pumheight = 15

local has_valid_clients = function()
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
  if vim.fn.pumvisible() > 0 or not has_valid_clients() then
    return utils.feedkeys('<C-n>')
  end

  vim.lsp.completion.trigger()
end)

vim.keymap.set('i', '<C-space>', function()
  if has_valid_clients() then
    vim.lsp.completion.trigger()
  else
    utils.feedkeys('<C-x><C-o>')
  end
end)
