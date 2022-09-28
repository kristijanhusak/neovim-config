local plugins = {}
vim.cmd([[packadd vim-packager]])

require('packager').setup(function(packager)
  packager.add('kristijanhusak/vim-packager', { type = 'opt' })
  packager.add('kristijanhusak/vim-js-file-import', { ['do'] = 'npm install', type = 'opt' })
  packager.add('numToStr/Comment.nvim')
  packager.add('kylechui/nvim-surround')
  packager.add('tpope/vim-repeat')
  packager.add('tpope/vim-fugitive')
  packager.add('tpope/vim-sleuth')
  packager.add('tpope/vim-dadbod')
  packager.add('tpope/vim-abolish')
  packager.add('kristijanhusak/vim-dadbod-completion', { type = 'opt' })
  packager.add('kristijanhusak/vim-dadbod-ui')
  packager.add('nvim-orgmode/orgmode')
  packager.add('akinsho/org-bullets.nvim')
  packager.add('windwp/nvim-ts-autotag')
  packager.add('axelvc/template-string.nvim')
  packager.add('AndrewRadev/splitjoin.vim')
  packager.add('lewis6991/gitsigns.nvim', { requires = 'nvim-lua/plenary.nvim' })
  packager.add('nvim-telescope/telescope.nvim')
  packager.add('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })
  packager.add('smartpde/telescope-recent-files')
  packager.add('ludovicchabant/vim-gutentags')
  packager.add('andymass/vim-matchup')
  packager.add('haya14busa/vim-asterisk')
  packager.add('stefandtw/quickfix-reflector.vim')
  packager.add('wakatime/vim-wakatime')
  packager.add('neovim/nvim-lspconfig')
  packager.add('nvim-treesitter/nvim-treesitter')
  packager.add('nvim-treesitter/nvim-treesitter-refactor')
  packager.add('nvim-treesitter/nvim-treesitter-textobjects')
  packager.add('nvim-treesitter/playground')
  packager.add('hrsh7th/vim-vsnip')
  packager.add('kyazdani42/nvim-tree.lua', { requires = 'kyazdani42/nvim-web-devicons' })
  packager.add('puremourning/vimspector')
  packager.add('lukas-reineke/indent-blankline.nvim')
  packager.add('Raimondi/delimitMate')
  packager.add('lewis6991/impatient.nvim')
  packager.add('rmehri01/onenord.nvim')
  packager.add('jose-elias-alvarez/null-ls.nvim')
  packager.add('SmiteshP/nvim-navic')
  packager.add('antoinemadec/FixCursorHold.nvim')
  packager.add('vigoux/notifier.nvim')
  packager.add('jose-elias-alvarez/typescript.nvim')
  packager.add('https://gitlab.com/yorickpeterse/nvim-pqf')
  packager.add('hrsh7th/nvim-cmp', {
    requires = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-vsnip',
      'quangnguyen30192/cmp-nvim-tags',
      'lukas-reineke/cmp-rg',
    },
  })
  packager.add('github/copilot.vim')
  packager.add('sindrets/diffview.nvim')
end)

vim.g.mapleader = ','

local plugins_group = vim.api.nvim_create_augroup('packager_filetype', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  command = [[packadd vim-js-file-import | exe 'runtime ftplugin/'.&ft.'.vim']],
  group = plugins_group,
})
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'sql',
  command = 'packadd vim-dadbod-completion | runtime after/plugin/vim_dadbod_completion.lua',
  group = plugins_group,
})
vim.api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  callback = function()
    vim.g.vsnip_snippet_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h') .. '/snippets'
    local stats = vim.loop.fs_stat(vim.fn.expand('%:p'))
    if not stats or stats.type == 'directory' then
      vim.defer_fn(function()
        vim.cmd([[wincmd p]])
      end, 40)
    end
  end,
  group = plugins_group,
})
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
  pattern = '.env*',
  command = 'set filetype=conf',
})

vim.keymap.set('n', '<Leader><space>', ':noh<CR>')

vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('', '*', '<Plug>(asterisk-z*)')
vim.keymap.set('', '#', '<Plug>(asterisk-z#)')
vim.keymap.set('', 'g*', '<Plug>(asterisk-gz*)')
vim.keymap.set('', 'g#', '<Plug>(asterisk-gz#)')

vim.keymap.set('n', '<Leader>G', ':vert G<CR>', { silent = true })

vim.keymap.set('n', '<Leader>n', ':NvimTreeToggle<CR>', { silent = true })
vim.keymap.set('n', '<Leader>hf', ':NvimTreeFindFile<CR>', { silent = true })

vim.keymap.set('n', '<leader>do', function()
  if vim.t.diffview_view_initialized then
    return vim.cmd('DiffviewClose')
  end
  return vim.cmd('DiffviewOpen')
end, { silent = true })
vim.keymap.set('n', '<leader>dh', ':DiffviewFileHistory %<CR>', { silent = true })
vim.keymap.set('n', '<leader>dc', function()
  vim.cmd([[DiffviewClose]])
  vim.cmd([[botright Git commit]])
end, { silent = true })
vim.keymap.set('n', '<leader>da', function()
  vim.cmd([[DiffviewClose]])
  vim.cmd([[botright Git commit --amend]])
end, { silent = true })
vim.keymap.set('n', '<leader>dp', ':Git push<CR>', { silent = true })
vim.keymap.set('n', '<leader>df', ':Git push --force-with-lease<CR>', { silent = true })

local gitsigns = require('gitsigns')

gitsigns.setup({
  signs = {
    add = { text = '▌' },
    change = { text = '▌' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '▌' },
  },
  numhl = true,
  on_attach = function(bufnr)
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end
    map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true, replace_keycodes = false })
    map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true, replace_keycodes = false })
    map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', gitsigns.stage_buffer)
    map('n', '<leader>hu', gitsigns.undo_stage_hunk)
    map('n', '<leader>hR', gitsigns.reset_buffer)
    map('n', '<leader>hp', gitsigns.preview_hunk)
    map('n', '<leader>hb', function()
      gitsigns.blame_line({ full = true })
    end)
    map('n', '<leader>hd', gitsigns.toggle_deleted)
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end,
})

require('Comment').setup({})
require('pqf').setup()
require('orgmode').setup(require('partials.orgmode_config'))
require('notifier').setup({
  components = { 'lsp' },
})

require('nvim-tree').setup({
  hijack_unnamed_buffer_when_opening = false,
  disable_netrw = true,
  open_on_setup = true,
  update_focused_file = {
    enable = true,
  },
  diagnostics = {
    enable = true,
  },
  actions = {
    open_file = {
      resize_window = true,
    },
  },
  view = {
    mappings = {
      list = {
        { key = { 's' }, action = 'vsplit' },
        { key = { 'C' }, action = 'cd' },
        { key = { 'X' }, action = 'system_open' },
      },
    },
  },
  renderer = {
    full_name = true,
    highlight_git = true,
    icons = {
      glyphs = {
        default = '',
        git = {
          unstaged = '✹',
        },
      },
    },
  },
})

require('indent_blankline').setup({
  char = '▏',
  show_current_context = true,
  disable_with_nolist = true,
})

require('nvim-surround').setup()
require('template-string').setup({
  remove_template_string = true,
})
require('org-bullets').setup({
  concealcursor = true,
  symbols = {
    checkboxes = {
      half = { '', 'OrgTSCheckboxHalfChecked' },
      done = { '✓', 'OrgDone' },
      todo = { ' ', 'OrgTODO' },
    },
  },
})

vim.g.matchup_matchparen_status_offscreen = 0
vim.g.matchup_matchparen_nomode = 'ivV'
vim.g.matchup_matchparen_deferred = 100

vim.g.db_ui_show_help = 0
vim.g.db_ui_win_position = 'right'
vim.g.db_ui_use_nerd_fonts = 1

vim.g.db_ui_save_location = '~/Dropbox/dbui'
vim.g.db_ui_tmp_query_location = '~/code/queries'

vim.g.vsnip_filetypes = {
  typescript = { 'javascript' },
  typescriptreact = { 'javascript' },
  javascriptreact = { 'javascript' },
}

vim.g.js_file_import_use_telescope = 1

vim.g.delimitMate_expand_cr = 1

vim.g.tagalong_mappings = { 'c', 'C', 'i', 'a' }

vim.g.db_ui_hide_schemas = { 'pg_toast_temp.*' }

vim.keymap.set('i', '<Plug>(vimrc:copilot-map)', [[copilot#Accept("\<Tab>")]], {
  expr = true,
  remap = true,
})
vim.cmd([[imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")]])
vim.g.copilot_no_tab_map = true

vim.g.copilot_filetypes = {
  TelescopePrompt = false,
  TelescopeResults = false,
}

vim.env.GIT_EDITOR = "nvr -cc tabedit --remote-wait +'set bufhidden=wipe'"

_G.kris.plugins = plugins
