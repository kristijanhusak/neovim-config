local M = {}

local layout_columns = {}
local window_split_modes = {}
local last_active_window = nil
local active_window_id = nil
local previous_active_window_id = nil

local function window_id(window)
  if not window then
    return nil
  end

  return window.stable_id or window.address
end

local function target_window_id(target)
  return window_id(target.window)
end

local function find_window_in_columns(window_id)
  for column_index, column in ipairs(layout_columns) do
    for row_index, id in ipairs(column) do
      if id == window_id then
        return column_index, row_index
      end
    end
  end

  return nil, nil
end

local function has_window(window_id)
  local column_index = find_window_in_columns(window_id)
  return column_index ~= nil
end

local function flatten_columns()
  local ordered = {}

  for _, column in ipairs(layout_columns) do
    for _, window_id in ipairs(column) do
      table.insert(ordered, window_id)
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

local function rebuild_columns(window_order)
  local rebuilt = {}
  local current_column = nil

  for index, window_id in ipairs(window_order) do
    local mode = window_split_modes[window_id] or 'vertical'

    if index == 1 or mode == 'vertical' or current_column == nil then
      current_column = { window_id }
      table.insert(rebuilt, current_column)
    else
      table.insert(current_column, window_id)
    end
  end

  layout_columns = rebuilt
end

local function insert_window(window_id, anchor_window_id, mode)
  if #layout_columns == 0 then
    layout_columns = { { window_id } }
    return
  end

  local column_index, row_index = find_window_in_columns(anchor_window_id)

  if mode == 'vertical' then
    if not column_index then
      table.insert(layout_columns, { window_id })
      return
    end

    table.insert(layout_columns, column_index + 1, { window_id })
    return
  end

  if not column_index then
    table.insert(layout_columns[#layout_columns], window_id)
    return
  end

  table.insert(layout_columns[column_index], row_index + 1, window_id)
end

function M.set_active_window(window)
  local new_active_window_id = window_id(window)

  if new_active_window_id ~= active_window_id then
    previous_active_window_id = active_window_id
    active_window_id = new_active_window_id
  end
end

function M.recalculate(ctx, split)
  if #ctx.targets == 0 then
    layout_columns = {}
    window_split_modes = {}
    last_active_window = nil
    active_window_id = nil
    previous_active_window_id = nil
    return
  end

  local current_targets = {}
  local current_order = {}
  local current_windows = {}
  local active_window = nil
  local removed_windows = false

  for _, target in ipairs(ctx.targets) do
    local window_id = target_window_id(target)

    if window_id then
      current_targets[window_id] = target
      current_windows[window_id] = true
      table.insert(current_order, window_id)

      if target.window.active then
        active_window = window_id
      end
    end
  end

  for window_id in pairs(window_split_modes) do
    if not current_windows[window_id] then
      window_split_modes[window_id] = nil
      removed_windows = true
    end
  end

  for column_index = #layout_columns, 1, -1 do
    local column = layout_columns[column_index]

    for row_index = #column, 1, -1 do
      if not current_windows[column[row_index]] then
        table.remove(column, row_index)
        removed_windows = true
      end
    end

    if #column == 0 then
      table.remove(layout_columns, column_index)
      removed_windows = true
    end
  end

  if last_active_window and not current_windows[last_active_window] then
    last_active_window = nil
  end

  local new_windows = {}

  for _, window_id in ipairs(current_order) do
    if not window_split_modes[window_id] then
      table.insert(new_windows, window_id)
    end
  end

  if #new_windows > 0 then
    local anchor_window = nil

    if has_window(active_window_id) then
      anchor_window = active_window_id
    elseif has_window(previous_active_window_id) then
      anchor_window = previous_active_window_id
    else
      anchor_window = last_active_window
    end

    for _, window_id in ipairs(new_windows) do
      window_split_modes[window_id] = split
      insert_window(window_id, anchor_window, split)
      anchor_window = window_id
    end
  elseif not removed_windows and not same_order(flatten_columns(), current_order) then
    rebuild_columns(current_order)
  end

  if #layout_columns == 0 then
    rebuild_columns(current_order)
  end

  for column_index, column in ipairs(layout_columns) do
    local column_box = ctx:column(column_index, #layout_columns)

    for row_index, window_id in ipairs(column) do
      local target = current_targets[window_id]

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
    last_active_window = active_window
  elseif active_window_id and current_windows[active_window_id] then
    last_active_window = active_window_id
  end
end

return M
