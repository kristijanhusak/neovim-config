require('impatient')
_G.kris = {}
require'partials/abbreviations'
require'partials/plugins'
require'partials/treesitter'
require'partials/lsp'
require'partials/completion'
require'partials/fzf'
require'partials/settings'
require'partials/colorscheme'
require'partials/statusline'
require'partials/mappings'
require'partials/filetypes'
require'partials/replace_pair'
require'partials/search'
require'partials/vimspector'

-- Load .nvimrc manually until this PR is merged.
-- https://github.com/neovim/neovim/pull/13503
local local_vimrc = vim.fn.getcwd()..'/.nvimrc'
if vim.loop.fs_stat(local_vimrc) then
  vim.cmd('source '..local_vimrc)
end
