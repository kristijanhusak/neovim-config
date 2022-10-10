local snippets = {
  install = function(packager)
    return packager.add('hrsh7th/vim-vsnip')
  end,
}
snippets.setup = function()
  vim.g.vsnip_snippet_dir = vim.fn.fnamemodify(vim.env.MYVIMRC, ':p:h') .. '/snippets'
  vim.g.vsnip_filetypes = {
    typescript = { 'javascript' },
    typescriptreact = { 'javascript' },
    javascriptreact = { 'javascript' },
  }

  return snippets
end

return snippets
