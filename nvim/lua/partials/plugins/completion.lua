local completion = {
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  dependencies = {
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-vsnip' },
    { 'lukas-reineke/cmp-rg' },
  },
}
completion.config = function()
  local utils = require('partials.utils')
  local cmp = require('cmp')
  vim.opt.pumheight = 15

  local kind_icons = {
    Text = '',
    Method = '󰆧',
    Function = '󰊕',
    Constructor = '',
    Field = '󰇽',
    Variable = '󰂡',
    Class = '󰠱',
    Interface = '',
    Module = '',
    Property = '󰜢',
    Unit = '',
    Value = '󰎠',
    Enum = '',
    Keyword = '󰌋',
    Snippet = '',
    Color = '󰏘',
    File = '󰈙',
    Reference = '',
    Folder = '󰉋',
    EnumMember = '',
    Constant = '󰏿',
    Struct = '',
    Event = '',
    Operator = '󰆕',
    TypeParameter = '󰅲',
  }

  cmp.setup({
    view = {
      entries = {
        follow_cursor = true,
      }
    },
    formatting = {
      fields = { 'kind', 'abbr', 'menu' },
      format = function(entry, vim_item)
        vim_item.menu = vim_item.kind
          .. ' '
          .. ({
            rg = '[Rg]',
            buffer = '[Buffer]',
            nvim_lsp = '[LSP]',
            vsnip = '[Snippet]',
            path = '[Path]',
            orgmode = '[Org]',
            ['vim-dadbod-completion'] = '[DB]',
          })[entry.source.name]
        vim_item.kind = kind_icons[vim_item.kind] or ''
        return vim_item
      end,
    },
    sources = {
      { name = 'nvim_lsp', group_index = 1 },
      { name = 'vsnip', group_index = 1 },
      { name = 'path', group_index = 1 },
      { name = 'buffer', group_index = 2 },
      { name = 'rg', group_index = 2 },
      { name = 'orgmode', group_index = 1 },
    },
    snippet = {
      expand = function(args)
        vim.fn['vsnip#anonymous'](args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<CR>'] = function(fallback)
        if vim.fn['vsnip#expandable']() ~= 0 then
          vim.fn.feedkeys(utils.esc('<Plug>(vsnip-expand)'), '')
          return
        end
        return cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })(fallback)
      end,
      ['<Tab>'] = cmp.mapping(function(fallback)
        if vim.fn['vsnip#jumpable'](1) > 0 then
          vim.fn.feedkeys(utils.esc('<Plug>(vsnip-jump-next)'), '')
        elseif vim.fn['vsnip#expandable']() > 0 then
          vim.fn.feedkeys(utils.esc('<Plug>(vsnip-expand)'), '')
        elseif require('copilot.suggestion').is_visible() then
          require('copilot.suggestion').accept()
        else
          fallback()
        end
      end, { 'i', 's' }),

      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if vim.fn['vsnip#jumpable'](-1) == 1 then
          vim.fn.feedkeys(utils.esc('<Plug>(vsnip-jump-prev)'), '')
        else
          fallback()
        end
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
