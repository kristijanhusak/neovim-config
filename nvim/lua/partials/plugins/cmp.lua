---@diagnostic disable: missing-fields
local completion = {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  enabled = not vim.g.enable_custom_completion,
  dependencies = {
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-path' },
    { 'lukas-reineke/cmp-rg' },
  },
}
completion.config = function()
  local utils = require('partials.utils')
  local cmp = require('cmp')

  local kind_icons = utils.lsp_kind_icons()

  cmp.setup({
    enabled = function()
      local buf = vim.api.nvim_get_current_buf()
      if vim.bo[buf].buftype == 'prompt' or vim.bo[buf].filetype == 'snacks_input' then
        return false
      end
      return true
    end,
    formatting = {
      fields = { 'kind', 'abbr', 'menu' },
      format = function(entry, vim_item)
        local kind_text = ({
          rg = '[Rg]',
          buffer = '[Buffer]',
          nvim_lsp = '[LSP]',
          path = '[Path]',
          orgmode = '[Org]',
          ['vim-dadbod-completion'] = '[DB]',
        })[entry.source.name]

        if not vim_item.kind then
          vim.print(vim_item)
          return vim_item
        end

        vim_item.menu = vim_item.kind .. ' ' .. (kind_text or '[Unknown]')
        vim_item.kind = kind_icons[vim_item.kind] or ''
        return vim_item
      end,
    },
    sources = {
      { name = 'nvim_lsp', group_index = 1 },
      { name = 'path', group_index = 2 },
      { name = 'buffer', group_index = 3 },
      { name = 'rg', group_index = 4, keyword_length = 3 },
      { name = 'orgmode', group_index = 1 },
    },
    snippet = {
      expand = function(args)
        vim.snippet.expand(args.body)
      end,
    },
    performance = {
      debounce = 20,
      throttle = 10,
    },
    mapping = cmp.mapping.preset.insert({
      ['<CR>'] = function(fallback)
        return cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })(fallback)
      end,
      ['<Tab>'] = cmp.mapping(function(fallback)
        if vim.snippet.active({ direction = 1 }) then
          return vim.snippet.jump(1)
        end

        if require('partials.utils').expand_snippet() then
          return
        end

        if require('copilot.suggestion').is_visible() then
          require('copilot.suggestion').accept()
        elseif utils.has_words_before() then
          require('copilot.suggestion').next()
        else
          fallback()
        end
      end, { 'i', 's' }),

      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if vim.snippet.active({ direction = -1 }) then
          return vim.snippet.jump(-1)
        end
        fallback()
      end, { 'i', 's' }),
    }),
    window = {
      documentation = {
        border = 'rounded',
      },
    },
    experimental = {
      ghost_text = false,
    },
  })

  local autocomplete_group = vim.api.nvim_create_augroup('vimrc_autocompletion', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'sql', 'mysql', 'plsql' },
    callback = function()
      cmp.setup.buffer({
        sources = {
          { name = 'vim-dadbod-completion' },
          { name = 'vsnip' },
        },
      })
    end,
    group = autocomplete_group,
  })

  return completion
end

return completion
