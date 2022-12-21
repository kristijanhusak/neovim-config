local snippets = {
  'hrsh7th/vim-vsnip',
  event = 'InsertEnter',
}
snippets.init = function()
  vim.g.vsnip_snippet_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h') .. '/snippets'
  vim.g.vsnip_filetypes = {
    typescript = { 'javascript' },
    typescriptreact = { 'javascript' },
    javascriptreact = { 'javascript' },
  }

  return snippets
end

return snippets
