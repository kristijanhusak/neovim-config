local mappings = {}
local utils = require('partials/utils')
-- Comment map
utils.keymap('n', '<Leader>c', 'gcc', { noremap = false })
-- Line comment command
utils.keymap('v', '<Leader>c', 'gc', { noremap = false })

-- Map save to Ctrl + S
utils.keymap('', '<c-s>', ':w<CR>', { noremap = false })
utils.keymap('i', '<c-s>', '<C-o>:w<CR>', { noremap = false })
utils.keymap('n', '<Leader>s', ':w<CR>')

-- Open vertical split
utils.keymap('n', '<Leader>v', '<C-w>v')

-- Move between slits
utils.keymap('n', '<c-h>', '<C-w>h')
utils.keymap('n', '<c-j>', '<C-w>j')
utils.keymap('n', '<c-k>', '<C-w>k')
utils.keymap('n', '<c-l>', '<C-w>l')
utils.keymap('n', '<c-h>', '<C-\\><C-n><C-w>h')
utils.keymap('n', '<c-l>', '<C-\\><C-n><C-w>l')

-- Down is really the next line
utils.keymap('n', 'j', 'gj')
utils.keymap('n', 'k', 'gk')

-- Map for Escape key in terminal
utils.keymap('t', '<Leader>jj', '<C-\\><C-n>')

vim.cmd([[augroup vimrc_terminal_mappings]])
vim.cmd([[autocmd!]])
-- Focus first file:line:col pattern in the terminal output
vim.cmd([[autocmd TermOpen * nnoremap <silent><buffer> F :call search('\f\+:\d\+:\d\+')<CR>]])
vim.cmd([[autocmd TermOpen * setlocal bufhidden=wipe]])
vim.cmd([[augroup END]])

-- Copy to system clipboard
utils.keymap('v', '<C-c>', '"+y')
-- Paste from system clipboard with Ctrl + v
utils.keymap('i', '<C-v>', '<Esc>"+p')
utils.keymap('n', '<Leader>p', '"0p')
utils.keymap('v', '<Leader>p', '"0p')
utils.keymap('n', '<Leader>h', 'viw"0p', { nowait = false })

-- Move to the end of yanked text after yank and paste
utils.keymap('n', 'p', 'p`]')
utils.keymap('v', 'y', 'y`]')
utils.keymap('v', 'p', 'p`]')
-- Select last pasted text
utils.keymap('n', 'gp', "'`[' . strpart(getregtype(), 0, 1) . '`]'", { expr = true })

-- Move selected lines up and down
utils.keymap('v', 'J', ":m '>+1<CR>gv=gv")
utils.keymap('v', 'K', ":m '<-2<CR>gv=gv")

utils.keymap('n', '<Leader>q', ':call v:lua.kris.mappings.close_buffer()<CR>')
utils.keymap('n', '<Leader>Q', ':call v:lua.kris.mappings.close_buffer(v:true)<CR>')

-- Toggle between last 2 buffers
utils.keymap('n', '<leader><tab>', '<c-^>')

-- Indenting in visual mode
utils.keymap('x', '<s-tab>', '<gv')
utils.keymap('x', '<tab>', '>gv')

-- Resize window with shift + and shift -
utils.keymap('n', '_', '<c-w>5<')
utils.keymap('n', '+', '<c-w>5>')

-- Disable ex mode mapping
utils.keymap('', 'Q', '<c-z>', { noremap = false })

-- Jump to definition in vertical split
utils.keymap('n', '<Leader>]', '<C-W>v<C-]>')

-- Close all other buffers except current one
utils.keymap('n', '<Leader>db', ':silent w <BAR> :silent %bd <BAR> e#<CR>')

-- Unimpaired mappings
utils.keymap('n', '[q', ':cprevious<CR>')
utils.keymap('n', ']q', ':cnext<CR>')
utils.keymap('n', '[Q', ':cfirst<CR>')
utils.keymap('n', ']Q', ':clast<CR>')
utils.keymap('n', '[e', ':lprevious<CR>')
utils.keymap('n', ']e', ':lnext<CR>')
utils.keymap('n', '[L', ':lfirst<CR>')
utils.keymap('n', ']L', ':llast<CR>')
utils.keymap('n', '[t', ':tprevious<CR>')
utils.keymap('n', ']t', ':tnext<CR>')
utils.keymap('n', '[T', ':tfirst<CR>')
utils.keymap('n', ']T', ':tlast<CR>')
utils.keymap('n', '[b', ':bprevious<CR>')
utils.keymap('n', ']b', ':bnext<CR>')
utils.keymap('n', '[B', ':bfirst<CR>')
utils.keymap('n', ']B', ':blast<CR>')

--rsi mappings
utils.keymap('c', '<C-a>', '<Home>', { silent = false })
utils.keymap('c', '<C-e>', '<End>', { silent = false })
utils.keymap('c', '<C-b>', '<End>', { silent = false })
utils.keymap('c', '<C-j>', 'wildmenumode() ? "<c-j>" : "<down>"', { expr = true, silent = false })
utils.keymap('c', '<C-k>', 'wildmenumode() ? "<c-k>" : "<up>"', { expr = true, silent = false })

utils.keymap('n', '<leader>T', ':call v:lua.kris.mappings.toggle_terminal()<CR>')
utils.keymap('t', '<leader>T', '<C-\\><C-n><C-w>c')

utils.keymap('n', 'gs', ':%s/', { silent = false })
utils.keymap('x', 'gs', ':s/', { silent = false })

utils.keymap('n', 'gx', ':call netrw#BrowseX(expand("<cfile>"), netrw#CheckIfRemote())<CR>')

-- Taken from https://gist.github.com/romainl/c0a8b57a36aec71a986f1120e1931f20
for _, char in ipairs({ '_', '.', ':', ',', ';', '<bar>', '/', '<bslash>', '*', '+', '-', '#' }) do
  utils.keymap('x', 'i' .. char, ':<C-u>normal! T' .. char .. 'vt' .. char .. '<CR>')
  utils.keymap('o', 'i' .. char, ':normal vi' .. char .. '<CR>')
  utils.keymap('x', 'a' .. char, ':<C-u>normal! F' .. char .. 'vf' .. char .. '<CR>')
  utils.keymap('o', 'a' .. char, ':normal va' .. char .. '<CR>')
end

function mappings.close_buffer(bang)
  if vim.bo.buftype ~= '' then
    return vim.cmd('q!')
  end

  local windowCount = vim.fn.winnr('$')
  local totalBuffers = #vim.fn.getbufinfo({ buflisted = 1 })
  local noSplits = windowCount == 1
  bang = bang and '!' or ''
  if totalBuffers > 1 and noSplits then
    local command = 'bp'
    if vim.fn.buflisted(vim.fn.bufnr('#')) then
      command = command .. '|bd' .. bang .. '#'
    end
    return vim.cmd(command)
  end
  return vim.cmd('q' .. bang)
end

utils.keymap('n', 'gF', ':call v:lua.kris.mappings.open_file_or_create_new()<CR>')

local function open_file_on_line_and_column()
  local path = vim.fn.expand('<cfile>')
  local line = vim.fn.getline('.')
  local row = 1
  local col = 1
  if vim.fn.match(line, vim.fn.escape(path, '/') .. ':\\d*:\\d*') > -1 then
    local matchlist = vim.fn.matchlist(line, vim.fn.escape(path, '/') .. ':\\(\\d*\\):\\(\\d*\\)')
    row = matchlist[2] or 1
    col = matchlist[3] or 1
  end

  local bufnr = vim.fn.bufnr(path)
  local winnr = vim.fn.bufwinnr(bufnr)
  if winnr > -1 and vim.fn.getbufvar(bufnr, '&buftype') ~= 'terminal' then
    vim.cmd(winnr .. 'wincmd w')
  else
    vim.cmd('vsplit ' .. path)
  end
  vim.fn.cursor(row, col)
end

function mappings.open_file_or_create_new()
  local path = vim.fn.expand('<cfile>')
  if not path or path == '' then
    return false
  end

  if vim.bo.buftype == 'terminal' then
    return open_file_on_line_and_column()
  end

  if pcall(vim.cmd, 'norm!gf') then
    return true
  end

  vim.api.nvim_out_write('New file.\n')
  local new_path = vim.fn.fnamemodify(vim.fn.expand('%:p:h') .. '/' .. path, ':p')
  local ext = vim.fn.fnamemodify(new_path, ':e')

  if ext and ext ~= '' then
    return vim.cmd('edit ' .. new_path)
  end

  local suffixes = vim.fn.split(vim.bo.suffixesadd, ',')

  for _, suffix in ipairs(suffixes) do
    if vim.fn.filereadable(new_path .. suffix) then
      return vim.cmd('edit ' .. new_path .. suffix)
    end
  end

  return vim.cmd('edit ' .. new_path .. suffixes[1])
end

vim.cmd([[command! Json call v:lua.kris.mappings.paste_to_json_buffer()]])

function mappings.paste_to_json_buffer()
  vim.cmd([[vsplit]])
  vim.cmd([[enew]])
  vim.bo.filetype = 'json'
  vim.cmd([[norm!"+p]])
  vim.cmd([[norm!VGgq]])
end

local terminal_bufnr = 0
function mappings.toggle_terminal(close)
  if close then
    terminal_bufnr = 0
    return
  end
  if terminal_bufnr <= 0 then
    vim.cmd([[autocmd TermOpen * ++once startinsert]])
    vim.cmd([[sp | term]])
    vim.cmd([[setlocal bufhidden=hide]])
    vim.cmd([[autocmd BufDelete <buffer> call v:lua.kris.mappings.toggle_terminal(v:true)]])
    terminal_bufnr = vim.api.nvim_get_current_buf()
    return
  end

  local win = vim.fn.bufwinnr(terminal_bufnr)

  if win > -1 then
    vim.cmd(win .. 'close')
    return
  end

  vim.cmd('sp | b' .. terminal_bufnr .. ' | startinsert')
end

_G.kris.mappings = mappings
