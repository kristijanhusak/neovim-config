---@class Agentic
---@field provider string provider name
---@field keymap_prefix string keymap prefix for commands
local Agentic = {}
Agentic.__index = Agentic

---@param opts { provider: string, keymap_prefix: string}
function Agentic.new(opts)
  local this = setmetatable({
    provider = opts.provider,
    keymap_prefix = opts.keymap_prefix,
  }, Agentic)
  this:_setup_keymaps()
  return this
end

function Agentic:open()
  local bufnr = self:get_bufnr()
  if bufnr then
    vim.api.nvim_set_current_win(vim.fn.bufwinid(bufnr))
    vim.cmd.startinsert()
    return bufnr
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.b[buf].agentic_provider = self.provider
  vim.api.nvim_open_win(buf, true, {
    width = math.floor(vim.o.columns * 0.3),
    split = 'right',
  })
  vim.fn.jobstart(self.provider, { term = true })
  vim.cmd.startinsert()
  return buf
end

function Agentic:toggle()
  local bufnr = self:get_bufnr()
  if bufnr then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  else
    self:open()
  end
end

function Agentic:send_current_buffer()
  local bufname = ('@%s'):format(vim.fn.expand('%:.'))
  local view = vim.fn.winsaveview()
  self:open()
  vim.api.nvim_input(bufname)
  vim.fn.winrestview(view)
end

function Agentic:get_bufnr()
  return vim.iter(vim.api.nvim_list_bufs()):find(function(bufnr)
    return vim.bo[bufnr].buftype == 'terminal' and vim.b[bufnr].agentic_provider == self.provider
  end)
end

function Agentic:_setup_keymaps()
  vim.keymap.set('n', ('<Leader>%so'):format(self.keymap_prefix), function()
    self:open()
  end, { desc = ('Open %s'):format(self.provider) })

  vim.keymap.set('n', ('<Leader>%s%s'):format(self.keymap_prefix, self.keymap_prefix), function()
    self:toggle()
  end, { desc = ('Toggle %s'):format(self.provider) })

  vim.keymap.set('n', ('<Leader>%sb'):format(self.keymap_prefix), function()
    self:send_current_buffer()
  end, { desc = ('Send current buffer to %s'):format(self.provider) })
end

return Agentic
