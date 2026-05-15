local M = {}

local DEFAULT_WORKSPACE_KEY = '__default'
local DEFAULT_RESIZE_STEP = 0.05
local MIN_LAYOUT_WEIGHT = 0.1
local is_setup = false

---@class I3WorkspaceState
---@field layout_columns string[][]
---@field column_weights number[]
---@field row_weights number[][]
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
    column_weights = {},
    row_weights = {},
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

local function active_window_id_from_targets(targets)
  for _, target in ipairs(targets) do
    if target.window and target.window.active then
      return target_window_id(target)
    end
  end

  return nil
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

local function find_window_in_order(window_order, target_window_id)
  for index, current_window_id in ipairs(window_order) do
    if current_window_id == target_window_id then
      return index
    end
  end

  return nil
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

local function normalized_weight(weight)
  return math.max(weight or 1, MIN_LAYOUT_WEIGHT)
end

local function total_weights(weights)
  local total = 0

  for _, weight in ipairs(weights) do
    total = total + normalized_weight(weight)
  end

  return total
end

local function sync_layout_weights(state)
  local column_weights = {}
  local row_weights = {}

  for column_index, column in ipairs(state.layout_columns) do
    column_weights[column_index] = normalized_weight(state.column_weights[column_index])
    row_weights[column_index] = {}

    for row_index = 1, #column do
      row_weights[column_index][row_index] = normalized_weight((state.row_weights[column_index] or {})[row_index])
    end
  end

  state.column_weights = column_weights
  state.row_weights = row_weights
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

local function set_split(state, direction)
  if state.split == direction then
    return true
  end

  state.split = direction
  hl.exec_cmd(([[hyprctl notify 0 2000 "rgb(ffffff)" "Split %s"]]):format(direction))
  return true
end

local function focus(state, direction)
  if direction == 'u' or direction == 'd' then
    hl.dispatch(hl.dsp.focus({ direction = direction }))
    return true
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

        return true
      end
    end
  end

  return true
end

local function toggle_active_split(state, active_window_id, targets)
  local window_order = flatten_columns(state)

  if #window_order == 0 then
    for _, target in ipairs(targets) do
      local current_window_id = target_window_id(target)

      if current_window_id then
        table.insert(window_order, current_window_id)
      end
    end
  end

  if #window_order < 2 or not active_window_id then
    return true
  end

  local active_index = find_window_in_order(window_order, active_window_id)

  if not active_index then
    return true
  end

  local split_window_id = active_index == 1 and window_order[2] or active_window_id

  if not split_window_id then
    return true
  end

  local direction = state.window_split_modes[split_window_id] == 'horizontal' and 'vertical' or 'horizontal'
  state.window_split_modes[split_window_id] = direction
  rebuild_columns(state, window_order)
  hl.exec_cmd(([[hyprctl notify 0 2000 "rgb(ffffff)" "Split %s"]]):format(direction))
  return true
end

local function transfer_weight(weights, grow_index, shrink_index, amount)
  local shrink_weight = normalized_weight(weights[shrink_index])
  local actual_amount = math.min(amount, shrink_weight - MIN_LAYOUT_WEIGHT)

  if actual_amount <= 0 then
    return true
  end

  weights[grow_index] = normalized_weight(weights[grow_index]) + actual_amount
  weights[shrink_index] = shrink_weight - actual_amount
  return true
end

local function resize_columns(state, active_window_id, direction)
  local column_index = find_window_in_columns(state, active_window_id)

  if not column_index or #state.layout_columns < 2 then
    return true
  end

  sync_layout_weights(state)

  if direction == 'left' then
    if column_index > 1 then
      return transfer_weight(state.column_weights, column_index - 1, column_index, DEFAULT_RESIZE_STEP)
    end

    return transfer_weight(state.column_weights, column_index + 1, column_index, DEFAULT_RESIZE_STEP)
  end

  if column_index < #state.layout_columns then
    return transfer_weight(state.column_weights, column_index, column_index + 1, DEFAULT_RESIZE_STEP)
  end

  return transfer_weight(state.column_weights, column_index, column_index - 1, DEFAULT_RESIZE_STEP)
end

local function resize_rows(state, active_window_id, direction)
  local column_index, row_index = find_window_in_columns(state, active_window_id)

  if not column_index or not row_index or #state.layout_columns[column_index] < 2 then
    return true
  end

  sync_layout_weights(state)

  local row_weights = state.row_weights[column_index]

  if direction == 'up' then
    if row_index > 1 then
      return transfer_weight(row_weights, row_index - 1, row_index, DEFAULT_RESIZE_STEP)
    end

    return transfer_weight(row_weights, row_index + 1, row_index, DEFAULT_RESIZE_STEP)
  end

  if row_index < #state.layout_columns[column_index] then
    return transfer_weight(row_weights, row_index, row_index + 1, DEFAULT_RESIZE_STEP)
  end

  return transfer_weight(row_weights, row_index, row_index - 1, DEFAULT_RESIZE_STEP)
end

local function fit_all(state)
  sync_layout_weights(state)

  for column_index = 1, #state.layout_columns do
    state.column_weights[column_index] = 1
  end

  return true
end

local VALID_LAYOUT_COMMANDS = {
  fit = {
    all = function(command_ctx)
      return fit_all(command_ctx.state)
    end,
  },
  focus = {
    down = function(command_ctx)
      return focus(command_ctx.state, 'd')
    end,
    left = function(command_ctx)
      return focus(command_ctx.state, 'l')
    end,
    right = function(command_ctx)
      return focus(command_ctx.state, 'r')
    end,
    up = function(command_ctx)
      return focus(command_ctx.state, 'u')
    end,
  },
  resize = {
    down = function(command_ctx)
      return resize_rows(command_ctx.state, command_ctx.active_window_id, 'down')
    end,
    left = function(command_ctx)
      return resize_columns(command_ctx.state, command_ctx.active_window_id, 'left')
    end,
    right = function(command_ctx)
      return resize_columns(command_ctx.state, command_ctx.active_window_id, 'right')
    end,
    up = function(command_ctx)
      return resize_rows(command_ctx.state, command_ctx.active_window_id, 'up')
    end,
  },
  split = {
    h = function(command_ctx)
      return set_split(command_ctx.state, 'horizontal')
    end,
    horizontal = function(command_ctx)
      return set_split(command_ctx.state, 'horizontal')
    end,
    toggle = function(command_ctx)
      return toggle_active_split(command_ctx.state, command_ctx.active_window_id, command_ctx.ctx.targets)
    end,
    v = function(command_ctx)
      return set_split(command_ctx.state, 'vertical')
    end,
    vertical = function(command_ctx)
      return set_split(command_ctx.state, 'vertical')
    end,
  },
}

local function set_active_window(window)
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
local function recalculate(ctx)
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

  sync_layout_weights(state)

  local remaining_x = ctx.area.x
  local remaining_width = ctx.area.w
  local remaining_column_weight = total_weights(state.column_weights)

  for column_index, column in ipairs(state.layout_columns) do
    local column_weight = normalized_weight(state.column_weights[column_index])
    local column_width = column_index == #state.layout_columns and remaining_width
      or math.floor(remaining_width * column_weight / remaining_column_weight + 0.5)
    local remaining_y = ctx.area.y
    local remaining_height = ctx.area.h
    local row_weights = state.row_weights[column_index]
    local remaining_row_weight = total_weights(row_weights)

    for row_index, current_window_id in ipairs(column) do
      local target = current_targets[current_window_id]

      if target then
        local row_weight = normalized_weight(row_weights[row_index])
        local row_height = row_index == #column and remaining_height
          or math.floor(remaining_height * row_weight / remaining_row_weight + 0.5)

        target:place({
          x = remaining_x,
          y = remaining_y,
          w = column_width,
          h = row_height,
        })

        remaining_y = remaining_y + row_height
        remaining_height = remaining_height - row_height
        remaining_row_weight = remaining_row_weight - row_weight
      end
    end

    remaining_x = remaining_x + column_width
    remaining_width = remaining_width - column_width
    remaining_column_weight = remaining_column_weight - column_weight
  end

  if active_window then
    state.last_active_window = active_window
  elseif state.active_window_id and current_windows[state.active_window_id] then
    state.last_active_window = state.active_window_id
  end
end

local function layout_msg(ctx, msg)
  local command, argument = msg:match('^(%S+)%s*(.-)%s*$')
  local command_arguments = command and VALID_LAYOUT_COMMANDS[command]

  if not command or not command_arguments then
    return nil
  end

  local workspace_key = #ctx.targets > 0 and workspace_key_from_target(ctx.targets[1]) or current_workspace_key
  local state = get_workspace_state(workspace_key)
  local active_window_id = active_window_id_from_targets(ctx.targets)
    or state.active_window_id
    or state.last_active_window

  current_workspace_key = workspace_key

  if active_window_id then
    state.active_window_id = active_window_id
    state.last_active_window = active_window_id
  end

  local command_handler = command_arguments[argument]

  if not command_handler then
    if command == 'fit' then
      return 'i3: expected "fit all"'
    end

    if command == 'focus' then
      return 'i3: expected "focus left", "focus right", "focus up", or "focus down"'
    end

    if command == 'resize' then
      return 'i3: expected "resize left", "resize right", "resize up", or "resize down"'
    end

    return 'i3: expected "split vertical", "split horizontal", or "split toggle"'
  end

  return command_handler({
    active_window_id = active_window_id,
    ctx = ctx,
    state = state,
  })
end

function M.setup()
  if is_setup then
    return
  end

  is_setup = true

  hl.on('window.active', function(window)
    set_active_window(window)
  end)

  hl.layout.register('i3', {
    recalculate = function(ctx)
      recalculate(ctx)
    end,
    layout_msg = function(ctx, msg)
      return layout_msg(ctx, msg)
    end,
  })
end

return M
