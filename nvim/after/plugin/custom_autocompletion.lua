-- Barebones autocompletion: LSP first, buffer words as fallback.
-- Based on completion item collecting logic from vim/lsp/completion.lua.

if not vim.g.custom_autocompletion then
  return
end

local utils = require('partials.utils')
local buf = require('partials.custom_plugins.autocompletion.buf')
local lsp = require('partials.custom_plugins.autocompletion.lsp')
local resolve = require('partials.custom_plugins.autocompletion.resolve')

-- ─── Trigger char cache ───────────────────────────────────────────────────────

-- [bufnr] = { chars = { [char] = true, ... }, encoding = string }
local buf_triggers = {}

local function build_trigger_cache(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/completion' })
  if #clients == 0 then
    buf_triggers[bufnr] = nil
    return
  end
  local chars = {}
  for _, client in ipairs(clients) do
    for ch in pairs(lsp.trigger_set(client)) do
      chars[ch] = true
    end
  end
  buf_triggers[bufnr] = { chars = chars, encoding = clients[1].offset_encoding or 'utf-16' }
end

-- ─── Completefunc ─────────────────────────────────────────────────────────────

local cancel_lsp = nil

-- Stashed between phase 1 and phase 2 of completefunc.
local last_lnum = 0
local last_is_trigger = false

local function completefunc(findstart, base)
  if findstart == 1 then
    local col = vim.fn.col('.') - 1
    local line = vim.api.nvim_get_current_line():sub(1, col)
    local start = line:find('[%w_]+$')

    last_lnum = vim.api.nvim_win_get_cursor(0)[1] - 1

    -- Check if the char immediately before the word (or at EOL when no word) is a trigger char.
    local bufnr = vim.api.nvim_get_current_buf()
    local trigger_data = buf_triggers[bufnr]
    local char_before = start and line:sub(start - 1, start - 1) or line:sub(-1)
    last_is_trigger = trigger_data ~= nil and trigger_data.chars[char_before] == true

    return start and (start - 1) or col
  end

  local is_empty_line = #vim.trim(vim.api.nvim_get_current_line()) == 0
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/completion' })
  clients = vim.tbl_filter(function(client)
    return client.name ~= 'filepaths_ls'
  end, clients)

  if #clients == 0 then
    local items = buf.omni_candidates(base)
    if #items < 3 and not is_empty_line then
      items = vim.list_extend(items, buf.candidates(base))
    end
    return { words = items, refresh = 'always' }
  end

  -- For empty base, only proceed if a trigger char preceded or force was requested.
  if base == '' and not last_is_trigger and not vim.g.custom_autocompletion_force then
    return { words = {}, refresh = 'always' }
  end
  vim.g.custom_autocompletion_force = false

  local encoding = clients[1].offset_encoding
  local lnum = last_lnum
  local line = vim.api.nvim_get_current_line()

  if cancel_lsp then
    cancel_lsp()
    cancel_lsp = nil
  end
  local params = vim.lsp.util.make_position_params(0, encoding)
  cancel_lsp = vim.lsp.buf_request_all(bufnr, 'textDocument/completion', params, function(results)
    cancel_lsp = nil
    local all_items = {}
    for client_id, r in pairs(results) do
      if r.result then
        for _, item in ipairs(lsp.get_items(r.result)) do
          item._client_id = client_id
          all_items[#all_items + 1] = item
        end
      end
    end
    local items = lsp.candidates(all_items, base)
    if #items < 3 and not is_empty_line then
      items = vim.list_extend(items, buf.candidates(base))
    end
    vim.schedule(function()
      if vim.fn.mode() ~= 'i' or #items == 0 then
        return
      end
      local col = vim.fn.col('.') - 1
      local current_prefix = vim.api.nvim_get_current_line():sub(1, col):match('[%w_]+$') or ''
      if current_prefix == base then
        local start_byte = lsp.adjust_start_col(lnum, line, all_items, encoding)
        vim.fn.complete(start_byte and (start_byte + 1) or (vim.fn.col('.') - #base), items)
      end
    end)
  end)

  return { words = {}, refresh = 'always' }
end

_G._custom_completefunc = completefunc

-- ─── Setup ────────────────────────────────────────────────────────────────────

vim.opt.complete = 'F'

local augroup = vim.api.nvim_create_augroup('custom_autocompletion', { clear = true })

vim.api.nvim_create_autocmd('InsertEnter', {
  group = augroup,
  callback = function(ev)
    local is_valid = vim.bo[ev.buf].buftype ~= 'prompt' and vim.bo[ev.buf].filetype ~= 'snacks_input'
    if not is_valid then
      return
    end
    vim.bo[ev.buf].completefunc = 'v:lua._custom_completefunc'
    vim.bo[ev.buf].autocomplete = true
  end,
})

vim.api.nvim_create_autocmd('InsertLeave', {
  group = augroup,
  callback = function()
    if cancel_lsp then
      cancel_lsp()
      cancel_lsp = nil
    end
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = augroup,
  callback = function(ev)
    build_trigger_cache(ev.buf)
  end,
})

vim.api.nvim_create_autocmd('LspDetach', {
  group = augroup,
  callback = function(ev)
    build_trigger_cache(ev.buf)
  end,
})

resolve.setup(augroup)

-- ─── Keymaps ──────────────────────────────────────────────────────────────────

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
  vim.g.custom_autocompletion_force = true
  utils.feedkeys('<C-x><C-u>', 'n')
end, { silent = true })

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
