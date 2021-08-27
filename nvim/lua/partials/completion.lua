local completion = {}
local utils = require'partials/utils'
local cmp = require'cmp'
utils.opt('o', 'pumheight' , 15)
vim.cmd('set completeopt=menuone,noselect')

cmp.setup({
  sources = {
    { name = 'buffer' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'vsnip' },
    { name = 'tags' },
    { name = 'orgmode' },
  },
  mapping = {
    ['<CR>'] = function()
      local complete_info = vim.fn.complete_info()
      local selected = complete_info.selected

      if vim.fn['vsnip#expandable']() ~= 0 then
        vim.fn.feedkeys(utils.esc('<Plug>(vsnip-expand)'), '')
        return
      end

      if vim.fn.pumvisible() ~= 0 and selected ~= -1 then
        cmp.confirm()
        return
      end

      if vim.fn.pumvisible() ~= 0 then
        vim.fn.feedkeys(utils.esc('<C-e><Plug>delimitMateCR'), '')
        return
      end

      vim.fn.feedkeys(utils.esc('<Plug>delimitMateCR'), '')
    end
  },
  documentation = {
    border = 'rounded'
  }
})

vim.cmd [[augroup vimrc_autocompletion]]
  vim.cmd [[autocmd!]]
  vim.cmd[[autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })]]
vim.cmd [[augroup END]]

local function check_back_space()
  local col = vim.fn.col('.') - 1
  return col <= 0 or vim.fn.getline('.'):sub(col, col):match('%s')
end

function completion.tab_completion()
  if vim.fn['vsnip#jumpable'](1) > 0 then
    return utils.esc('<Plug>(vsnip-jump-next)')
  end

  if vim.fn.pumvisible() > 0 then
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

utils.keymap('i', '<S-TAB>', 'pumvisible() ? "<C-p>" : vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)" : "<S-TAB>"', {
  expr = true,
  noremap = false
})

utils.keymap('s', '<TAB>', 'vsnip#available(1)  ? "<Plug>(vsnip-expand-or-jump)" : "<TAB>"', {
  expr = true,
  noremap = false
})

utils.keymap('s', '<S-TAB>', 'vsnip#available(-1)  ? "<Plug>(vsnip-jump-prev)" : "<S-TAB>"', {
  expr = true,
  noremap = false
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
