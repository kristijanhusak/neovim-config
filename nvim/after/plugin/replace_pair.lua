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

function replace_pair.run()
  if vim.wo.diff then
    return vim.cmd.diffupdate()
  end

  local char = fn.getline('.'):sub(fn.col('.'), fn.col('.'))
  if not chars[char] then
    return fn.feedkeys('R', 'n')
  end

  local new_char = fn.nr2char(fn.getchar())
  local flags = 'nW'
  local search_char = char
  if chars[char][2] == 'right' then
    flags = flags .. 'b'
    search_char = chars[char][1]
  end
  local lnum, col =
    unpack(fn.searchpairpos(fn.escape(search_char, '[]'), '', fn.escape(chars[search_char][1], '[]'), flags))
  vim.cmd('norm!r' .. new_char)
  local view = fn.winsaveview()
  vim.fn.cursor({ lnum, col })
  vim.cmd('norm!r' .. chars[new_char][1])
  return fn.winrestview(view)
end

vim.keymap.set('n', 'R', replace_pair.run, { silent = true })
