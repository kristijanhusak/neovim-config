return {
  'natecraddock/workspaces.nvim',
  cmd = { 'WorkspacesAdd', 'WorkspacesOpen' },
  opts = {
    path = vim.fs.normalize('~/Dropbox/workspaces')
  },
}
