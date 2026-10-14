-- Do not hide code block fences (```lang) in regular markdown files.
-- nvim-treesitter conceals them on purpose for LSP hover docs, so floats
-- and other special buffers keep the default query.
-- See https://github.com/nvim-treesitter/nvim-treesitter/issues/5751
if vim.bo.buftype ~= '' then
  return
end

local parser = vim.treesitter.get_parser(0, 'markdown', { error = false })
if not parser then
  return
end

if not vim.g.markdown_file_highlights_query then
  local content = {}
  for _, file in ipairs(vim.treesitter.query.get_files('markdown', 'highlights')) do
    local source = table.concat(vim.fn.readfile(file), '\n')
    source = source:gsub('%(#set!%s+conceal%s+""%)%s*%(#set!%s+conceal_lines%s+""%)', '')
    table.insert(content, source)
  end
  vim.g.markdown_file_highlights_query = table.concat(content, '\n')
end

vim.treesitter.stop()
vim.treesitter.highlighter.new(parser, { queries = { markdown = vim.g.markdown_file_highlights_query } })
