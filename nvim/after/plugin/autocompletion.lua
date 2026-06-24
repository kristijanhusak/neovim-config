if not vim.g.builtin_autocompletion then
  return
end

local utils = require('partials.utils')
local augroup = vim.api.nvim_create_augroup('custom_lsp_completion', { clear = true })
local icons = utils.lsp_kind_icons()
local protocol = vim.lsp.protocol
vim.opt.complete = 'o'

vim.api.nvim_create_autocmd('InsertEnter', {
  pattern = '*',
  group = augroup,
  callback = function(ev)
    local is_valid_buffer = vim.bo[ev.buf].buftype ~= 'prompt' and vim.bo[ev.buf].filetype ~= 'snacks_input'
    vim.opt_local.autocomplete = is_valid_buffer
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or not client:supports_method(protocol.Methods.textDocument_completion) then
      return
    end
    local bufnr = ev.buf

    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    vim.lsp.completion.enable(true, client.id, bufnr, {
      convert = function(item)
        local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or 'Text'
        local menu = ('[%s]'):format(kind)
        return {
          kind = icons[kind],
          kind_hlgroup = ('BlinkCmpKind%s'):format(kind),
          menu = menu,
        }
      end,
    })
  end,
})

-- Keymaps
vim.keymap.set('i', '<Tab>', function()
  if vim.snippet.active({ direction = 1 }) then
    return vim.snippet.jump(1)
  end

  if utils.expand_snippet() then
    return
  end

  if vim.lsp.inline_completion.get() then
    return
  end

  if utils.has_words_before() then
    return vim.lsp.inline_completion.select()
  end

  utils.feedkeys('<Tab>', 'n')
end, { silent = true })

vim.keymap.set({ 'i', 's' }, '<S-Tab>', function()
  if vim.snippet.active({ direction = -1 }) then
    return vim.snippet.jump(-1)
  end

  return utils.feedkeys('<S-Tab>', 'n')
end, { silent = true })

vim.keymap.set('i', '<C-space>', function()
  vim.lsp.completion.get()
end)

vim.keymap.set('i', '<CR>', function()
  if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
    return utils.esc('<C-y>')
  end
  return require('mini.pairs').cr()
end, { expr = true, noremap = true, replace_keycodes = false })
