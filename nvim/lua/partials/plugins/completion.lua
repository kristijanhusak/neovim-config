local completion = {
  install = function(packager)
    return packager.add('hrsh7th/nvim-cmp', {
      requires = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-vsnip',
        'quangnguyen30192/cmp-nvim-tags',
        'lukas-reineke/cmp-rg',
      },
    })
  end,
}
completion.setup = function()
  local utils = require('partials.utils')
  local cmp = require('cmp')

  vim.opt.pumheight = 15
  vim.opt.completeopt = 'menuone,noselect'

  cmp.setup({
    formatting = {
      format = function(entry, vim_item)
        vim_item.menu = ({
          rg = '[Rg]',
          buffer = '[Buffer]',
          nvim_lsp = '[LSP]',
          vsnip = '[Snippet]',
          tags = '[Tag]',
          path = '[Path]',
          orgmode = '[Org]',
          ['vim-dadbod-completion'] = '[DB]',
        })[entry.source.name]
        return vim_item
      end,
    },
    sources = {
      { name = 'nvim_lsp', group_index = 1 },
      { name = 'vsnip', group_index = 1 },
      { name = 'buffer', group_index = 2 },
      { name = 'tags', keyword_length = 2, group_index = 2 },
      { name = 'rg', keyword_length = 3, group_index = 2 },
      { name = 'path', group_index = 1 },
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
      ['<C-Space>'] = cmp.mapping.complete({
        config = {
          sources = {
            { name = 'nvim_lsp', group_index = 1 },
            { name = 'path', group_index = 1 },
          },
        },
      }),
      ['<Tab>'] = cmp.mapping(function()
        if vim.fn['vsnip#jumpable'](1) > 0 then
          vim.fn.feedkeys(utils.esc('<Plug>(vsnip-jump-next)'), '')
        elseif vim.fn['vsnip#expandable']() > 0 then
          vim.fn.feedkeys(utils.esc('<Plug>(vsnip-expand)'), '')
        else
          vim.api.nvim_feedkeys(
            vim.fn['copilot#Accept'](vim.api.nvim_replace_termcodes('<Tab>', true, true, true)),
            'n',
            true
          )
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
      cmp.setup.buffer({ sources = { { name = 'vim-dadbod-completion' } } })
    end,
    group = autocomplete_group,
  })

  return completion
end

return completion
