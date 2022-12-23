local filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

local template_string = {
  'axelvc/template-string.nvim',
  ft = filetypes,
}
template_string.config = function()
  require('template-string').setup({
    remove_template_string = true,
  })

  if vim.tbl_contains(filetypes, vim.bo.filetype) then
    vim.cmd('doautocmd FileType ' .. vim.bo.filetype)
  end
end

return template_string
