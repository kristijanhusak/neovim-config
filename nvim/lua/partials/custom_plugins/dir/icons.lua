local ns_id = vim.api.nvim_create_namespace('directory_browser_icons')

local function add_icons(icons, bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local directory_icon = ''

  for row, line in ipairs(lines) do
    if vim.endswith(line, '/') then
      vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, 0, {
        virt_text = { { directory_icon .. ' ', 'Directory' } },
        virt_text_pos = 'inline',
        hl_mode = 'combine',
      })
    else
      local file_icon, file_icon_hl = icons.get_icon(line, nil, { default = true })
      if file_icon then
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, 0, {
          virt_text = { { file_icon .. ' ', file_icon_hl } },
          virt_text_pos = 'inline',
          hl_mode = 'combine',
        })
      end
    end
  end
end

return {
  attach = function(bufnr)
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    if ok then
      add_icons(devicons, bufnr)
    end
  end
}
