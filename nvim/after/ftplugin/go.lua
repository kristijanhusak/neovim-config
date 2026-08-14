local go = {}

function go.setup()
  vim.bo.expandtab = false
  vim.bo.tabstop = 4
end

function go.add_tags()
  local struct = vim.fn.expand('<cword>')
  local type = vim.fn.input('Type: ', 'json')
  local file = vim.fn.expand('%:p')
  local view = vim.fn.winsaveview()
  local response = vim.fn.systemlist(string.format('gomodifytags -file %s -struct %s -add-tags %s', file, struct, type))
  vim.api.nvim_buf_set_lines(0, 0, -1, true, response)
  vim.fn.winrestview(view)
end

vim.api.nvim_create_user_command('GoAddTags', go.add_tags, { force = true })
go.setup()
