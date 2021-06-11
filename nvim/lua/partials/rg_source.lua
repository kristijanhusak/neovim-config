local compe = require'compe'

local jobs = {}
local result = {}
local notified_missing_executable = false
local base_args = {'--trim', '--vimgrep', '--no-line-number', '--no-column', '--smart-case'}

local function trigger_callback(context)
  local items = vim.tbl_map(function(item) return {word = item} end, vim.tbl_keys(result))

  context.callback({
      incomplete = true,
      items = items
    })
end

local function cache(context, data)
  local word = context.input
  local word_esc = vim.pesc(word)
  if not data then return end
  for line in data:gmatch('[^\r\n]+') do
    local m = line:match(word_esc..'[A-Za-z0-9]*')
    if m and m ~= '' then
      local path = vim.split(line, ':')[1]
      if not result[m] then
        result[m] = {path}
      elseif not vim.tbl_contains(result[m], path) then
        table.insert(result[m], path)
      end
    end
  end
end

local function search_word(context)
  local word = context.input
  if jobs[word] ~= nil or result[word] then return false end
  local rg_args = {unpack(base_args)}
  table.insert(rg_args, word)
  local stdout = vim.loop.new_pipe(false)
  local stderr = vim.loop.new_pipe(false)
  jobs[word] = true
  local handle
  handle = vim.loop.spawn('rg', { args = rg_args, stdio = { stdout, stderr } }, vim.schedule_wrap(function()
    stdout:read_stop()
    stderr:read_stop()
    stdout:close()
    stderr:close()
    handle:close()
    jobs[word] = nil
    trigger_callback(context)
  end))
  vim.loop.read_start(stdout, function(err, data)
    if err then return end
    cache(context, data)
  end)
  vim.loop.read_start(stderr, function(err, data)
    if err then return end
    cache(context, data)
  end)
end

local function should_search(word)
  if #vim.fn.complete_info().items > 5 then return false end

  local searched = false
  local word_esc = vim.pesc(word)
  for item, _ in pairs(result) do
    if item:find(word_esc) then
      searched = true
      break
    end
  end

  return not searched
end

local Source = {
  has_executable = vim.fn.executable('rg') ~= 0
}

function Source.new()
  return setmetatable({}, { __index = Source })
end

function Source.get_metadata(self)
  if not self.has_executable and not notified_missing_executable then
    notified_missing_executable = true
    vim.api.nvim_echo({{'[nvim-compe-rg] Missing "rg" executable in path.', 'ErrorMsg'}}, true, {})
  end
  return {
    priority = 10,
    menu = '[RG]',
  }
end

function Source.determine(_, context)
  return compe.helper.determine(context)
end

function Source.complete(self, context)
  if not self.has_executable or #context.input < 5 then return context.abort() end

  if should_search(context.input) then
    search_word(context)
  end

  trigger_callback(context)
end

function Source.documentation(_, context)
  local entry = result[context.completed_item.word]
  if not entry then return end
  local document = {}
  for i, item in ipairs(entry) do
    if i > 10 then
      table.insert(document, ('...and %d more'):format(#entry - 10))
      break
    end
    table.insert(document, item)
  end
  context.callback(document)
end

compe.register_source('ripgrep', Source)
