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

function go.format()
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { 'source.organizeImports' } }
  local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params)
  for cid, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
        vim.lsp.util.apply_workspace_edit(r.edit, enc)
      end
    end
  end
  vim.lsp.buf.format({ async = false })
end

local go_group = vim.api.nvim_create_augroup('vimrc_go', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = go.format,
  group = go_group,
})

vim.api.nvim_create_user_command('GoAddTags', go.add_tags, { force = true })
go.setup()
