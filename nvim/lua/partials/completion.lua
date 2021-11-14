local completion = {}
local utils = require('partials/utils')
local cmp = require('cmp')
utils.opt('o', 'pumheight', 15)
vim.cmd('set completeopt=menuone,noselect')

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
    { name = 'rg' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'tags', keyword_length = 2 },
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

utils.keymap('i', '<TAB>', 'v:lua.kris.completion.tab_completion()', { expr = true, noremap = false })

utils.keymap(
  'i',
  '<S-TAB>',
  [[luaeval('require("cmp").visible()') ? "<C-p>" : vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<S-TAB>"]],
  {
    expr = true,
    noremap = false,
  }
)

utils.keymap('s', '<TAB>', 'vsnip#available(1)  ? "<Plug>(vsnip-expand-or-jump)" : "<TAB>"', {
  expr = true,
  noremap = false,
})

utils.keymap('s', '<S-TAB>', 'vsnip#available(-1)  ? "<Plug>(vsnip-jump-prev)" : "<S-TAB>"', {
  expr = true,
  noremap = false,
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
