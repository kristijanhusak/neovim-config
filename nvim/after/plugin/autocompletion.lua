if not vim.g.builtin_autocompletion then
  return
end

local utils = require('partials.utils')
local augroup = vim.api.nvim_create_augroup('custom_lsp_completion', { clear = true })
local icons = utils.lsp_kind_icons()
local protocol = vim.lsp.protocol
vim.opt.complete = 'o'

-- vim.api.nvim_create_autocmd('InsertEnter', {
--   pattern = '*',
--   group = augroup,
--   callback = function(ev)
--     local is_valid_buffer = vim.bo[ev.buf].buftype ~= 'prompt' and vim.bo[ev.buf].filetype ~= 'snacks_input'
--     vim.opt_local.autocomplete = is_valid_buffer
--   end,
-- })

local compare_by_sortText_and_label = function(a, b)
  ---@type lsp.CompletionItem
  local itema = a.user_data.nvim.lsp.completion_item
  ---@type lsp.CompletionItem
  local itemb = b.user_data.nvim.lsp.completion_item
  return (itema.sortText or itema.label) < (itemb.sortText or itemb.label)
end

local compare_fn = function(a, b)
  local score_a = a._fuzzy_score or 0
  local score_b = b._fuzzy_score or 0
  if score_a ~= score_b then
    return score_a > score_b
  end
  return compare_by_sortText_and_label(a, b)
end

--- @type uv.uv_timer_t?
local completion_timer = nil

--- @return uv.uv_timer_t
local function new_timer()
  return (assert(vim.uv.new_timer()))
end

local function reset_timer()
  if completion_timer then
    completion_timer:stop()
    completion_timer:close()
  end

  completion_timer = nil
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or not client:supports_method(protocol.Methods.textDocument_completion) then
      return
    end
    local bufnr = ev.buf

    if vim.bo[bufnr].omnifunc ~= 'v:lua.vim.lsp.omnifunc' then
      vim.b[bufnr].old_omnifunc = vim.bo[bufnr].omnifunc
    end
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    vim.lsp.completion.enable(true, client.id, bufnr, {
      cmp = function(a, b)
        local is_a_buf = a.user_data.nvim.lsp.completion_item.buf
        local is_b_buf = b.user_data.nvim.lsp.completion_item.buf

        if is_a_buf and not is_b_buf then
          return false
        end
        if not is_a_buf and is_b_buf then
          return true
        end

        return compare_fn(a, b)
      end,
      convert = function(item)
        local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or 'Text'
        local menu = item.labelDetails and item.labelDetails.description or ('[%s]'):format(kind)
        return {
          kind = icons[kind],
          kind_hlgroup = ('BlinkCmpKind%s'):format(kind),
          menu = menu,
        }
      end,
    })

    vim.api.nvim_create_autocmd('InsertCharPre', {
      buf = bufnr,
      callback = function()
        reset_timer()
        completion_timer = new_timer()
        completion_timer:start(
          120,
          0,
          vim.schedule_wrap(function()
            vim.lsp.completion.get()
          end)
        )
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
  local npairs = require('nvim-autopairs')

  if vim.fn.pumvisible() == 0 then
    return npairs.autopairs_cr()
  end

  if vim.fn.complete_info({ 'selected' }).selected ~= -1 then
    return npairs.esc('<c-y>')
  end
  return npairs.esc('<c-e>') .. npairs.autopairs_cr()
end, { expr = true, noremap = true, replace_keycodes = false })
