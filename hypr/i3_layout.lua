local M = {}

local DEFAULT_WORKSPACE_KEY = '__default'

---@class I3WorkspaceState
---@field layout_columns string[][]
---@field window_split_modes table<string, 'vertical' | 'horizontal'>
---@field last_active_window string|nil
---@field active_window_id string|nil
---@field previous_active_window_id string|nil
---@field windows HL.Window[]
---@field split 'vertical' | 'horizontal'

---@type table<string, I3WorkspaceState>
local workspace_states = {}
local current_workspace_key = DEFAULT_WORKSPACE_KEY

local function new_workspace_state()
  return {
    layout_columns = {},
    window_split_modes = {},
    last_active_window = nil,
    active_window_id = nil,
    previous_active_window_id = nil,
    windows = {},
    split = 'vertical',
  }
end

local function get_workspace_state(workspace_key)
  local key = workspace_key or DEFAULT_WORKSPACE_KEY
  local state = workspace_states[key]

  if not state then
    state = new_workspace_state()
    workspace_states[key] = state
  end

  return state
end

local function workspace_key_from_workspace(workspace)
  if not workspace then
    return DEFAULT_WORKSPACE_KEY
  end

  if workspace.name and workspace.name ~= '' then
    return workspace.name
  end

  if workspace.id ~= nil then
    return tostring(workspace.id)
  end

  return DEFAULT_WORKSPACE_KEY
end

local function workspace_key_from_window(window)
  if not window then
    return DEFAULT_WORKSPACE_KEY
  end

  return workspace_key_from_workspace(window.workspace)
end

local function workspace_key_from_target(target)
  if not target then
    return DEFAULT_WORKSPACE_KEY
  end

  return workspace_key_from_window(target.window)
end

local function window_id(window)
  if not window then
    return nil
  end

  return window.address
end

local function target_window_id(target)
  return window_id(target.window)
end

local function find_window_in_columns(state, target_window_id)
  for column_index, column in ipairs(state.layout_columns) do
    for row_index, id in ipairs(column) do
      if id == target_window_id then
        return column_index, row_index
      end
    end
  end

  return nil, nil
end

local function has_window(state, target_window_id)
  local column_index = find_window_in_columns(state, target_window_id)
  return column_index ~= nil
end

local function flatten_columns(state)
  local ordered = {}

  for _, column in ipairs(state.layout_columns) do
    for _, target_window_id in ipairs(column) do
      table.insert(ordered, target_window_id)
    end
  end

  return ordered
end

local function same_order(lhs, rhs)
  if #lhs ~= #rhs then
    return false
  end

  for i = 1, #lhs do
    if lhs[i] ~= rhs[i] then
      return false
    end
  end

  return true
end

local function rebuild_columns(state, window_order)
  local rebuilt = {}
  local current_column = nil

  for index, target_window_id in ipairs(window_order) do
    local mode = state.window_split_modes[target_window_id] or 'vertical'

    if index == 1 or mode == 'vertical' or current_column == nil then
      current_column = { target_window_id }
      table.insert(rebuilt, current_column)
    else
      table.insert(current_column, target_window_id)
    end
  end

  state.layout_columns = rebuilt
end

local function insert_window(state, new_window_id, anchor_window_id, mode)
  if #state.layout_columns == 0 then
    state.layout_columns = { { new_window_id } }
    return
  end

  local column_index, row_index = find_window_in_columns(state, anchor_window_id)

  if mode == 'vertical' then
    if not column_index then
      table.insert(state.layout_columns, { new_window_id })
      return
    end

    table.insert(state.layout_columns, column_index + 1, { new_window_id })
    return
  end

  if not column_index then
    table.insert(state.layout_columns[#state.layout_columns], new_window_id)
    return
  end

  table.insert(state.layout_columns[column_index], row_index + 1, new_window_id)
end

function M.set_active_window(window)
  local workspace_key = workspace_key_from_window(window)
  local state = get_workspace_state(workspace_key)
  local new_active_window_id = window_id(window)

  current_workspace_key = workspace_key

  if new_active_window_id ~= state.active_window_id then
    state.previous_active_window_id = state.active_window_id
    state.active_window_id = new_active_window_id
  end
end

---@param ctx HL.LayoutContext
function M.recalculate(ctx)
  if #ctx.targets == 0 then
    return
  end

  local workspace_key = workspace_key_from_target(ctx.targets[1])
  local state = get_workspace_state(workspace_key)
  local current_targets = {}
  local current_order = {}
  local current_windows = {}
  local active_window = nil
  local removed_windows = false

  state.windows = {}

  for _, target in ipairs(ctx.targets) do
    local current_window_id = target_window_id(target)

    if current_window_id then
      current_targets[current_window_id] = target
      current_windows[current_window_id] = true
      table.insert(current_order, current_window_id)

      if target.window.active then
        active_window = current_window_id
      end

      table.insert(state.windows, target.window)
    end
  end

  if active_window and active_window ~= state.active_window_id then
    current_workspace_key = workspace_key
    state.previous_active_window_id = state.active_window_id
    state.active_window_id = active_window
  end

  for current_window_id in pairs(state.window_split_modes) do
    if not current_windows[current_window_id] then
      state.window_split_modes[current_window_id] = nil
      removed_windows = true
    end
  end

  for column_index = #state.layout_columns, 1, -1 do
    local column = state.layout_columns[column_index]

    for row_index = #column, 1, -1 do
      if not current_windows[column[row_index]] then
        table.remove(column, row_index)
        removed_windows = true
      end
    end

    if #column == 0 then
      table.remove(state.layout_columns, column_index)
      removed_windows = true
    end
  end

  if state.last_active_window and not current_windows[state.last_active_window] then
    state.last_active_window = nil
  end

  if state.active_window_id and not current_windows[state.active_window_id] then
    state.active_window_id = nil
  end

  if state.previous_active_window_id and not current_windows[state.previous_active_window_id] then
    state.previous_active_window_id = nil
  end

  local new_windows = {}

  for _, current_window_id in ipairs(current_order) do
    if not state.window_split_modes[current_window_id] then
      table.insert(new_windows, current_window_id)
    end
  end

  if #new_windows > 0 then
    local anchor_window = nil

    if has_window(state, state.active_window_id) then
      anchor_window = state.active_window_id
    elseif has_window(state, state.previous_active_window_id) then
      anchor_window = state.previous_active_window_id
    else
      anchor_window = state.last_active_window
    end

    for _, current_window_id in ipairs(new_windows) do
      state.window_split_modes[current_window_id] = state.split
      insert_window(state, current_window_id, anchor_window, state.split)
      anchor_window = current_window_id
    end
  elseif not removed_windows and not same_order(flatten_columns(state), current_order) then
    rebuild_columns(state, current_order)
  end

  if #state.layout_columns == 0 then
    rebuild_columns(state, current_order)
  end

  for column_index, column in ipairs(state.layout_columns) do
    local column_box = ctx:column(column_index, #state.layout_columns)

    for row_index, current_window_id in ipairs(column) do
      local target = current_targets[current_window_id]

      if target then
        target:place({
          x = column_box.x,
          y = column_box.y + column_box.h * (row_index - 1) / #column,
          w = column_box.w,
          h = column_box.h / #column,
        })
      end
    end
  end

  if active_window then
    state.last_active_window = active_window
  elseif state.active_window_id and current_windows[state.active_window_id] then
    state.last_active_window = state.active_window_id
  end
end

---@param direction 'vertical' | 'horizontal'
function M.split(direction)
  local state = get_workspace_state(current_workspace_key)

  if state.split == direction then
    return
  end

  state.split = direction
  hl.exec_cmd(([[hyprctl notify 0 2000 "rgb(ffffff)" "Split %s"]]):format(direction))
end

function M.focus(direction)
  local state = get_workspace_state(current_workspace_key)

  if direction == 'u' or direction == 'd' then
    return hl.dispatch(hl.dsp.focus({ direction = direction }))
  end

  for i, win in ipairs(state.windows) do
    if win.address == state.active_window_id then
      local idx = direction == 'l' and i - 1 or i + 1
      local target_win = state.windows[idx]

      if idx > 0 and idx <= #state.windows and target_win then
        local is_fullscreen = win.fullscreen == 1
        hl.dispatch(hl.dsp.focus({ window = target_win }))

        if is_fullscreen then
          hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 1, client = 1, window = target_win }))
        end

        return
      end
    end
  end
end

return M
