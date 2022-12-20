local replace_pair = {}
local fn = vim.fn
local chars = {
  ['{'] = { '}', 'left' },
  ['}'] = { '{', 'right' },
  ['['] = { ']', 'left' },
  [']'] = { '[', 'right' },
  ['('] = { ')', 'left' },
  [')'] = { '(', 'right' },
}

vim.keymap.set('n', 'R', ':call v:lua.kris.replace_pair.run()<CR>', { silent = true })

function replace_pair.run()
  if vim.wo.diff then
    return vim.cmd.diffupdate()
  end

  local char = fn.getline('.'):sub(fn.col('.'), fn.col('.'))
  if chars[char] then
    local new_char = fn.nr2char(fn.getchar())
    local flags = 'nW'
    local search_char = char
    if chars[char][2] == 'right' then
      flags = flags .. 'b'
      search_char = chars[char][1]
    end
    local pos = fn.searchpairpos(fn.escape(search_char, '[]'), '', fn.escape(chars[search_char][1], '[]'), flags)
    local lnum = pos[1]
    local col = pos[2]
    vim.cmd('norm!r' .. new_char)
    local view = fn.winsaveview()
    vim.fn.cursor({ lnum, col })
    vim.cmd('norm!r' .. chars[new_char][1])
    return fn.winrestview(view)
  end

  return fn.feedkeys('R', 'n')
end

_G.kris.replace_pair = replace_pair
