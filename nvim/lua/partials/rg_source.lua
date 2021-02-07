_G.kris.rg = {}
local compe = require'compe'

local jobs = {}
local result = {}
local notified_missing_executable = false
local base_cmd = {'rg', '--trim', '--no-filename', '--vimgrep', '--no-line-number', '--no-column', '--no-heading', '--smart-case'}

local function handle(word)
  return function(_, data, event)
    if event == 'exit' then
      jobs[word] = nil
      return
    end
    if type(data) == 'table' and not vim.tbl_isempty(data) then
      for _, line in ipairs(data) do
        local m = line:match(word..'[A-Za-z0-9]*')
        if m and m ~= '' and not result[m] then
          result[m] = true
        end
      end
    end
  end
end

local function search_word(word)
  if jobs[word] ~= nil or result[word] then return false end
  local rg_cmd = {unpack(base_cmd)}
  table.insert(rg_cmd, word)
  jobs[word] = vim.fn.jobstart(rg_cmd, {
    on_exit = handle(word),
    on_stdout = handle(word),
    on_stderr = handle(word),
  })
  return true
end

local function should_search(word)
  local searched = false
  for item, _ in pairs(result) do
    if item:find(word) then
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
  if not self.has_executable or #context.input < 4 then return context.abort() end

  local incomplete = false
  if should_search(context.input) then
    incomplete = true
    vim.schedule_wrap(search_word(context.input))
  end

  local items = vim.tbl_map(function(item) return {word = item} end, vim.tbl_keys(result))

  context.callback({
      incomplete = incomplete,
      items = items
  })
end

compe.register_source('ripgrep', Source)
