local completion = {}
local utils = require('partials.utils')
local cmp = require('cmp')
vim.opt.pumheight = 15
vim.opt.completeopt = 'menuone,noselect'

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
end

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
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'tags', keyword_length = 2 },
    { name = 'rg', keyword_length = 3 },
    { name = 'path' },
    { name = 'orgmode' },
  },
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  mapping = {
    ['<CR>'] = function(fallback)
      if vim.fn['vsnip#expandable']() ~= 0 then
        vim.fn.feedkeys(utils.esc('<Plug>(vsnip-expand)'), '')
        return
      end
      return cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace })(fallback)
    end,
    ['<C-Space>'] = cmp.mapping(
      cmp.mapping.complete({
        config = {
          sources = {
            { name = 'nvim_lsp' },
            { name = 'path' },
          },
        },
      }),
      { 'i' }
    ),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if vim.fn['vsnip#jumpable'](1) > 0 then
        vim.fn.feedkeys(utils.esc('<Plug>(vsnip-jump-next)'), '')
      elseif cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn['vsnip#expandable']() > 0 then
        vim.fn.feedkeys(utils.esc('<Plug>(vsnip-expand)'), '')
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      elseif vim.fn['vsnip#jumpable'](-1) == 1 then
        vim.fn.feedkeys(utils.esc('<Plug>(vsnip-jump-prev)'), '')
      end
    end, { 'i', 's' }),
  },
  experimental = {
    ghost_text = true,
  },
  window = {
    documentation = {
      border = 'rounded',
    },
  }
})

local autocomplete_group = vim.api.nvim_create_augroup('vimrc_autocompletion', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'sql', 'mysql', 'plsql' },
  callback = function()
    cmp.setup.buffer({ sources = { { name = 'vim-dadbod-completion' } } })
  end,
  group = autocomplete_group,
})

vim.opt.wildignore = {
  '*.o',
  '*.obj,*~',
  '*.git*',
  '*.meteor*',
  '*vim/backups*',
  '*sass-cache*',
  '*mypy_cache*',
  '*__pycache__*',
  '*cache*',
  '*logs*',
  '*node_modules*',
  '**/node_modules/**',
  '*DS_Store*',
  '*.gem',
  'log/**',
  'tmp/**',
}

_G.kris.completion = completion
