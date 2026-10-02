---@class Agentic
---@field provider string provider name (command to run)
---@field name string unique name used to identify the terminal buffer
---@field keymap_prefix string keymap prefix for commands
---@field env table<string, string> environment variables for the provider
local Agentic = {}
Agentic.__index = Agentic

---@param opts { provider: string, name?: string, keymap_prefix: string, env?: table<string, string> }
function Agentic.new(opts)
  local this = setmetatable({
    provider = opts.provider,
    name = opts.name or opts.provider,
    keymap_prefix = opts.keymap_prefix,
    env = opts.env or {}
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
  vim.b[buf].agentic_name = self.name
  vim.api.nvim_open_win(buf, true, {
    width = math.floor(vim.o.columns * 0.3),
    split = 'right',
  })
  vim.fn.jobstart(self.provider, { term = true, env = self.env })
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
    return vim.bo[bufnr].buftype == 'terminal' and vim.b[bufnr].agentic_name == self.name
  end)
end

function Agentic:_setup_keymaps()
  vim.keymap.set('n', ('<Leader>%so'):format(self.keymap_prefix), function()
    self:open()
  end, { desc = ('Open %s'):format(self.name) })

  vim.keymap.set('n', ('<Leader>%s%s'):format(self.keymap_prefix, self.keymap_prefix), function()
    self:toggle()
  end, { desc = ('Toggle %s'):format(self.name) })

  vim.keymap.set('n', ('<Leader>%sb'):format(self.keymap_prefix), function()
    self:send_current_buffer()
  end, { desc = ('Send current buffer to %s'):format(self.name) })
end

return Agentic
