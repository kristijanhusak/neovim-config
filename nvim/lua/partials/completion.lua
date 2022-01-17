local completion = {}
local utils = require('partials/utils')
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
  },
  documentation = {
    border = 'rounded',
  },
})

vim.cmd([[augroup vimrc_autocompletion]])
vim.cmd([[autocmd!]])
vim.cmd(
  [[autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })]]
)
vim.cmd([[augroup END]])

local function check_back_space()
  local col = vim.fn.col('.') - 1
  return col <= 0 or vim.fn.getline('.'):sub(col, col):match('%s')
end

function completion.tab_completion()
  if vim.fn['vsnip#jumpable'](1) > 0 then
    return utils.esc('<Plug>(vsnip-jump-next)')
  end

  if cmp.visible() then
    return utils.esc('<C-n>')
  end

  if check_back_space() then
    return utils.esc('<TAB>')
  end

  if vim.fn['vsnip#expandable']() > 0 then
    return utils.esc('<Plug>(vsnip-expand)')
  end

  return utils.esc('<C-n>')
end

vim.keymap.set('i', '<TAB>', 'v:lua.kris.completion.tab_completion()', { expr = true, remap = true })

vim.keymap.set('i', '<S-TAB>', function()
  if cmp.visible() then
    return '<c-p>'
  end
  if vim.fn['vsnip#jumpable'](-1) > 0 then
    return '<Plug>(vsnip-jump-prev)'
  end
  return '<c-d>'
end, {
  expr = true,
  remap = true,
})

vim.keymap.set('s', '<TAB>', function()
  if vim.fn['vsnip#available'](1) > 0 then
    return '<Plug>(vsnip-expand-or-jump)'
  end
  return '<TAB>'
end, {
  expr = true,
  remap = true,
})

vim.keymap.set('s', '<S-TAB>', function()
  if vim.fn['vsnip#available'](-1) > 0 then
    return '<Plug>(vsnip-jump-prev)'
  end
  return '<S-TAB>'
end, {
  expr = true,
  remap = true,
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
