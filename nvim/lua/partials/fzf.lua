local fzf = require('fzf-lua')
vim.env.FZF_DEFAULT_OPTS = '--layout=reverse --bind ctrl-d:preview-down,ctrl-u:preview-up'

local function run_cmd(selected, fn)
  vim.cmd(string.format('e %s', selected[1]))
  fn()
  vim.defer_fn(function()
    if fzf.utils.is_term_buffer(0) then
      vim.cmd([[startinsert!]])
    end
  end, 20)
end

local function show_lsp_tags(selected)
  return run_cmd(selected, function()
    vim.wait(5000, function()
      return #vim.tbl_filter(function(client)
        return client.resolved_capabilities.document_symbol
      end, vim.lsp.get_active_clients()) > 0
    end)
    return fzf.lsp_document_symbols()
  end)
end

local function show_lines(selected)
  return run_cmd(selected, function()
    return fzf.blines({ search = '^' })
  end)
end

fzf.setup({
  winopts = {
    width = 0.80,
    height = 0.90,
    preview = {
      horizontal = 'right:45%',
    },
  },
  oldfiles = {
    include_current_session = true,
  },
  actions = {
    files = vim.tbl_extend('force', fzf.config.globals.actions.files, {
      ['@'] = show_lsp_tags,
      [':'] = show_lines,
    }),
  },
  git = {
    status = {
      cmd = 'git status -s -u',
      no_header = true,
    },
  },
  keymap = {
    builtin = vim.tbl_extend('force', fzf.config.globals.keymap.builtin, {
      ['<C-d>'] = 'preview-page-down',
      ['<C-u>'] = 'preview-page-up',
    }),
    fzf = vim.tbl_extend('force', fzf.config.globals.keymap.fzf, {
      ['ctrl-d'] = 'preview-page-down',
      ['ctrl-u'] = 'preview-page-up',
    }),
  },
})

vim.keymap.set('n', '<C-p>', fzf.files)
vim.keymap.set('n', '<Leader>b', fzf.buffers)
vim.keymap.set('n', '<Leader>t', fzf.lsp_document_symbols)
vim.keymap.set('n', '<Leader>m', fzf.oldfiles)
vim.keymap.set('n', '<Leader>g', fzf.git_status)

vim.keymap.set('n', '<Leader>lT', fzf.lsp_workspace_symbols)
vim.keymap.set('n', '<Leader>lt', fzf.btags)
