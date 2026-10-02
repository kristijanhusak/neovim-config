local M = {}

local RESIZE_STEP = 0.05
local MIN_WEIGHT = 0.1
local is_setup = false

---@alias I3Axis 'x' | 'y'

---@class I3Node
---@field parent I3Container|nil
---@field weight number

---@class I3Container: I3Node
---@field dir I3Axis
---@field children I3Node[]
---@field key string|nil

---@class I3Leaf: I3Node
---@field address string
---@field window HL.Window

---@type table<string, I3Container>
local roots = {}
---@type table<string, I3Leaf>
local leaves = {}
---@type table<string, integer>
local focus_stamps = {}
local focus_counter = 0

local DIRECTIONS = {
  left = { char = 'l', axis = 'x', delta = -1 },
  right = { char = 'r', axis = 'x', delta = 1 },
  up = { char = 'u', axis = 'y', delta = -1 },
  down = { char = 'd', axis = 'y', delta = 1 },
}

local SPLIT_NAMES = { x = 'vertical', y = 'horizontal' }

local function notify(text)
  hl.exec_cmd(([[hyprctl notify 0 2000 "rgb(ffffff)" "%s"]]):format(text))
end

local function workspace_key(workspace)
  if not workspace then
    return '__default'
  end

  if workspace.name and workspace.name ~= '' then
    return workspace.name
  end

  return tostring(workspace.id)
end

local function get_root(key)
  if not roots[key] then
    roots[key] = { dir = 'x', children = {}, weight = 1, key = key }
  end

  return roots[key]
end

local function is_leaf(node)
  return node.address ~= nil
end

local function root_of(node)
  while node.parent do
    node = node.parent
  end

  return node
end

local function index_of(parent, node)
  for i, child in ipairs(parent.children) do
    if child == node then
      return i
    end
  end
end

local function each_leaf(node, fn)
  if is_leaf(node) then
    return fn(node)
  end

  for _, child in ipairs(node.children) do
    each_leaf(child, fn)
  end
end

local function most_recent_leaf(node)
  local best, best_stamp = nil, -1

  each_leaf(node, function(leaf)
    local stamp = focus_stamps[leaf.address] or 0

    if stamp > best_stamp then
      best, best_stamp = leaf, stamp
    end
  end)

  return best
end

local function stamp_focus(window)
  if window and window.address then
    focus_counter = focus_counter + 1
    focus_stamps[window.address] = focus_counter
  end
end

local function average_weight(children)
  if #children == 0 then
    return 1
  end

  local total = 0

  for _, child in ipairs(children) do
    total = total + child.weight
  end

  return total / #children
end

local function insert_child(parent, index, node)
  node.weight = average_weight(parent.children)
  node.parent = parent
  table.insert(parent.children, index, node)
end

local function replace_child(parent, old, new)
  parent.children[index_of(parent, old)] = new
  new.parent = parent
  new.weight = old.weight
end

---Collapses empty and single-child containers and merges containers that
---split the same way as their parent, walking up from `container`.
local function normalize(container)
  local root = container and root_of(container)

  while container and container.parent do
    local parent = container.parent
    local next_node = parent

    if #container.children == 0 then
      table.remove(parent.children, index_of(parent, container))
    elseif #container.children == 1 then
      local only = container.children[1]
      replace_child(parent, container, only)

      if not is_leaf(only) then
        next_node = only
      end
    elseif container.dir == parent.dir then
      local index = index_of(parent, container)
      local total = 0

      table.remove(parent.children, index)

      for _, child in ipairs(container.children) do
        total = total + child.weight
      end

      for offset, child in ipairs(container.children) do
        child.parent = parent
        child.weight = child.weight * container.weight / total
        table.insert(parent.children, index + offset - 1, child)
      end
    else
      break
    end

    container = next_node
  end

  if root and #root.children == 1 and not is_leaf(root.children[1]) then
    local only = root.children[1]
    root.dir = only.dir
    root.children = only.children

    for _, child in ipairs(root.children) do
      child.parent = root
    end
  end
end

local function detach(node)
  local parent = node.parent

  if parent then
    table.remove(parent.children, index_of(parent, node))
    node.parent = nil
  end

  return parent
end

local function remove_leaf(leaf)
  normalize(detach(leaf))

  if leaves[leaf.address] == leaf then
    leaves[leaf.address] = nil
  end
end

local function insert_leaf(root, leaf, anchor)
  if anchor and anchor.parent then
    insert_child(anchor.parent, index_of(anchor.parent, anchor) + 1, leaf)
  else
    insert_child(root, #root.children + 1, leaf)
  end
end

local function is_tiled_on(leaf, key)
  local window = leaf.window

  return window.address ~= nil
    and window.mapped
    and not window.hidden
    and not window.floating
    and workspace_key(window.workspace) == key
end

---Every Lua layout instance shares this module, so the workspace is inferred
---from the targets. Windows mid-move can report their new workspace while
---still being laid out on the old one, so the majority wins and ties go to
---the tree that already owns most of the targets.
local function pick_root(targets)
  local votes, owned = {}, {}
  local best = nil

  for _, target in ipairs(targets) do
    local window = target.window

    if window then
      local key = workspace_key(window.workspace)
      votes[key] = (votes[key] or 0) + 1
      best = best or key

      local leaf = leaves[window.address]

      if leaf then
        local owner = root_of(leaf).key
        owned[owner] = (owned[owner] or 0) + 1
      end
    end
  end

  if not best then
    return nil
  end

  for key, count in pairs(votes) do
    if count > votes[best] or (count == votes[best] and (owned[key] or 0) > (owned[best] or 0)) then
      best = key
    end
  end

  return get_root(best)
end

local function active_leaf(targets)
  for _, target in ipairs(targets) do
    local window = target.window

    if window and window.active then
      return leaves[window.address]
    end
  end
end

local function is_live_group(group)
  return group ~= nil and group.size ~= nil
end

---A group is a single target whose window is the current tab, so its leaf is
---tracked by group and handed to whichever tab is shown. Runs before anything
---else so a tab that just left the group doesn't keep the group's leaf.
local function adopt_group_leaves(root, targets)
  for _, target in ipairs(targets) do
    local window = target.window
    local group = window and window.group

    if is_live_group(group) then
      local owner = nil

      each_leaf(root, function(leaf)
        if not owner and is_live_group(leaf.group) and leaf.group == group then
          owner = leaf
        end
      end)

      if owner and owner.address ~= window.address then
        local existing = leaves[window.address]

        if existing and existing ~= owner then
          remove_leaf(existing)
        end

        leaves[owner.address] = nil
        owner.address = window.address
        leaves[window.address] = owner
      end
    end
  end
end

---Puts `node` in a new container that splits along `axis`.
local function wrap(node, axis)
  local container = { dir = axis, children = { node } }
  replace_child(node.parent, node, container)
  node.parent = container
  node.weight = 1
  return container
end

---Inserts `leaf` right next to `node` in `direction`, splitting `node` when
---its container runs the other way.
local function insert_beside(node, leaf, direction)
  local parent = node.parent

  if parent.dir ~= direction.axis then
    if #parent.children == 1 then
      parent.dir = direction.axis
    else
      parent = wrap(node, direction.axis)
    end
  end

  insert_child(parent, index_of(parent, node) + (direction.delta > 0 and 1 or 0), leaf)
end

---@type table<string, { anchor: I3Leaf, direction: table }>
local pending_placements = {}

local function sync_tree(root, targets)
  local present = {}
  local disjoint = true

  adopt_group_leaves(root, targets)

  for _, target in ipairs(targets) do
    local window = target.window

    if window then
      present[window.address] = target

      if window.active then
        stamp_focus(window)
      end

      local leaf = leaves[window.address]

      if leaf and root_of(leaf) == root then
        disjoint = false
        leaf.window = window
        leaf.group = window.group
      end
    end
  end

  local stale = {}

  each_leaf(root, function(leaf)
    -- A recalculate that shares no windows with the tree is either a fresh
    -- start or a transient call during a move, only drop windows that are
    -- really gone in that case.
    if not present[leaf.address] and (not disjoint or not is_tiled_on(leaf, root.key)) then
      table.insert(stale, leaf)
    end
  end)

  for _, leaf in ipairs(stale) do
    remove_leaf(leaf)
  end

  local anchor = most_recent_leaf(root)

  for _, target in ipairs(targets) do
    local window = target.window

    if window and not (leaves[window.address] and root_of(leaves[window.address]) == root) then
      if leaves[window.address] then
        remove_leaf(leaves[window.address])
      end

      local leaf = { address = window.address, window = window, group = window.group, weight = 1 }
      local placement = pending_placements[window.address]
      pending_placements[window.address] = nil
      leaves[window.address] = leaf

      if placement and leaves[placement.anchor.address] == placement.anchor and root_of(placement.anchor) == root then
        insert_beside(placement.anchor, leaf, placement.direction)
      else
        insert_leaf(root, leaf, anchor)
        anchor = leaf
      end
    end
  end

  return present
end

local function place(node, box, present)
  if is_leaf(node) then
    local target = present[node.address]

    if target then
      target:place(box)
    end

    return
  end

  local total = 0

  for _, child in ipairs(node.children) do
    total = total + child.weight
  end

  local horizontal = node.dir == 'x'
  local offset = horizontal and box.x or box.y
  local remaining = horizontal and box.w or box.h

  for i, child in ipairs(node.children) do
    local size = i == #node.children and remaining or math.floor(remaining * child.weight / total + 0.5)

    if horizontal then
      place(child, { x = offset, y = box.y, w = size, h = box.h }, present)
    else
      place(child, { x = box.x, y = offset, w = box.w, h = size }, present)
    end

    offset = offset + size
    remaining = remaining - size
    total = total - child.weight
  end
end

---@param ctx HL.LayoutContext
local function recalculate(ctx)
  local root = pick_root(ctx.targets)

  if not root then
    return
  end

  local present = sync_tree(root, ctx.targets)

  -- Windows hidden behind a maximized one are kept at the maximized size, so
  -- focusing them while maximized doesn't make them resize.
  for _, target in ipairs(ctx.targets) do
    if target.window and target.window.fullscreen == 1 then
      for _, other in pairs(present) do
        other:place(ctx.area)
      end

      return
    end
  end

  place(root, ctx.area, present)
end

---Groupbar orientation is a global option, so every tab group follows it.
local stacked = false

---Returns the focused window's group when there are tabs to move between.
local function tab_group(leaf)
  local group = leaf and leaf.window.group

  if is_live_group(group) and group.size > 1 then
    return group
  end
end

---Returns the tab index one step in `direction`, or nil when leaving the group.
local function next_tab(group, direction)
  local index = group.current_index + direction.delta

  if direction.axis == (stacked and 'y' or 'x') and index >= 1 and index <= group.size then
    return index
  end
end

---Takes `window` out of its group and lays it out next to the group's tile.
local function ungroup(anchor, group, window, direction)
  pending_placements[window.address] = { anchor = anchor, direction = direction }
  pcall(group.remove, group, window)
end

local function make_tabbed(leaf, stack)
  if stacked ~= stack then
    stacked = stack
    hl.config({ group = { groupbar = { stacked = stack } } })
  end

  if not leaf or is_live_group(leaf.window.group) then
    return
  end

  local window = leaf.window
  local before, after = {}, {}
  local list = before

  for _, sibling in ipairs(leaf.parent.children) do
    if sibling == leaf then
      list = after
    elseif is_leaf(sibling) and not is_live_group(sibling.window.group) then
      table.insert(list, sibling.window)
    end
  end

  hl.dispatch(hl.dsp.group.toggle())

  local group = window.group

  if not is_live_group(group) then
    return
  end

  for i, sibling in ipairs(before) do
    pcall(group.add, group, sibling, i)
  end

  for _, sibling in ipairs(after) do
    pcall(group.add, group, sibling, group.size + 1)
  end

  -- Adding tabs makes each new one current, so bring back the window the
  -- layout was toggled from and give it focus again.
  for i, member in ipairs(group.members) do
    if member.address == window.address then
      hl.dispatch(hl.dsp.group.active({ index = i, window = window }))
    end
  end

  hl.dispatch(hl.dsp.focus({ window = window }))
end

local function untab(leaf, group)
  local before = stacked and DIRECTIONS.up or DIRECTIONS.left
  local after = stacked and DIRECTIONS.down or DIRECTIONS.right
  local members, current = group.members, group.current_index

  for i = 1, current - 1 do
    ungroup(leaf, group, members[i], before)
  end

  for i = #members, current + 1, -1 do
    ungroup(leaf, group, members[i], after)
  end

  pcall(group.remove, group, members[current])
  hl.dispatch(hl.dsp.focus({ window = members[current] }))
end

---Finds the closest node next to `leaf` in `direction`.
local function neighbor(leaf, direction)
  local node = leaf

  while node.parent do
    local parent = node.parent

    if parent.dir == direction.axis then
      local sibling = parent.children[index_of(parent, node) + direction.delta]

      if sibling then
        return sibling
      end
    end

    node = parent
  end
end

local function focus(leaf, direction)
  local group = tab_group(leaf)

  if group and next_tab(group, direction) then
    hl.dispatch(direction.delta > 0 and hl.dsp.group.next() or hl.dsp.group.prev())
    return
  end

  local sibling = leaf and neighbor(leaf, direction)

  if not sibling then
    if not leaf or leaf.window.fullscreen == 0 then
      hl.dispatch(hl.dsp.focus({ direction = direction.char }))
    end

    return
  end

  local target = most_recent_leaf(sibling)

  if leaf.window.fullscreen ~= 1 then
    hl.dispatch(hl.dsp.focus({ window = target.window }))
    return
  end

  -- Hand the maximized state straight to the newly focused window instead of
  -- restoring the layout first, only for this focus change.
  local previous = hl.get_config('misc.on_focus_under_fullscreen')
  hl.config({ misc = { on_focus_under_fullscreen = 1 } })
  hl.dispatch(hl.dsp.focus({ window = target.window }))
  hl.config({ misc = { on_focus_under_fullscreen = previous } })
end

local function move(leaf, direction)
  if not leaf then
    hl.dispatch(hl.dsp.window.move({ direction = direction.char }))
    return
  end

  if leaf.window.fullscreen ~= 0 then
    return
  end

  local group = tab_group(leaf)

  if group then
    if next_tab(group, direction) then
      hl.dispatch(hl.dsp.group.move_window({ forward = direction.delta > 0 }))
    else
      local window = leaf.window
      ungroup(leaf, group, window, direction)
      hl.dispatch(hl.dsp.focus({ window = window }))
    end

    return
  end

  local parent = leaf.parent

  if parent.dir == direction.axis then
    local index = index_of(parent, leaf)
    local sibling = parent.children[index + direction.delta]

    if sibling and is_leaf(sibling) and is_live_group(sibling.window.group) then
      pcall(sibling.window.group.add, sibling.window.group, leaf.window)
      return
    end

    if sibling and is_leaf(sibling) then
      local target_index = index + direction.delta
      parent.children[index], parent.children[target_index] = sibling, leaf
      leaf.weight, sibling.weight = sibling.weight, leaf.weight
      return
    end

    if sibling then
      detach(leaf)

      if sibling.dir == direction.axis then
        insert_child(sibling, direction.delta > 0 and 1 or #sibling.children + 1, leaf)
      else
        local focused = most_recent_leaf(sibling)

        while focused.parent ~= sibling do
          focused = focused.parent
        end

        insert_child(sibling, index_of(sibling, focused) + 1, leaf)
      end

      normalize(parent)
      return
    end
  end

  local branch = parent
  local ancestor = parent.parent

  while ancestor and ancestor.dir ~= direction.axis do
    branch = ancestor
    ancestor = ancestor.parent
  end

  if ancestor then
    detach(leaf)
    insert_child(ancestor, index_of(ancestor, branch) + (direction.delta > 0 and 1 or 0), leaf)
    normalize(parent)
    return
  end

  local root = root_of(leaf)

  if root.dir == direction.axis or #root.children == 1 then
    pcall(function()
      hl.dispatch(hl.dsp.window.move({ monitor = direction.char }))
    end)
    return
  end

  detach(leaf)

  local rest = { dir = root.dir, children = root.children, weight = 1 }

  for _, child in ipairs(rest.children) do
    child.parent = rest
  end

  root.dir = direction.axis
  root.children = { rest }
  rest.parent = root
  insert_child(root, direction.delta > 0 and 2 or 1, leaf)
  normalize(parent == root and rest or parent)
end

local function split(leaf, axis)
  if not leaf then
    return
  end

  local parent = leaf.parent

  if parent.dir == axis then
    return
  end

  if #parent.children == 1 then
    parent.dir = axis
    normalize(parent)
  else
    wrap(leaf, axis)
  end

  notify('Split ' .. SPLIT_NAMES[axis])
end

local function toggle_split(leaf)
  if not leaf then
    return
  end

  local parent = leaf.parent
  parent.dir = parent.dir == 'x' and 'y' or 'x'
  notify('Split ' .. SPLIT_NAMES[parent.dir])
  normalize(parent)
end

local function transfer_weight(children, grow, shrink)
  local amount = math.min(RESIZE_STEP, children[shrink].weight - MIN_WEIGHT)

  if amount > 0 then
    children[grow].weight = children[grow].weight + amount
    children[shrink].weight = children[shrink].weight - amount
  end
end

---Shrinks the focused window towards left/up and grows it towards right/down.
local function resize(leaf, direction)
  local node = leaf

  while node and node.parent do
    local parent = node.parent

    if parent.dir == direction.axis and #parent.children > 1 then
      local index = index_of(parent, node)
      local other = parent.children[index + direction.delta] and index + direction.delta or index - direction.delta

      if direction.delta < 0 then
        transfer_weight(parent.children, other, index)
      else
        transfer_weight(parent.children, index, other)
      end

      return
    end

    node = parent
  end
end

local function fit_all(root)
  local function reset(node)
    node.weight = 1

    for _, child in ipairs(node.children or {}) do
      reset(child)
    end
  end

  reset(root)
end

local COMMANDS = {
  focus = function(leaf, arg)
    return DIRECTIONS[arg] and function()
      focus(leaf, DIRECTIONS[arg])
    end
  end,
  move = function(leaf, arg)
    return DIRECTIONS[arg] and function()
      move(leaf, DIRECTIONS[arg])
    end
  end,
  resize = function(leaf, arg)
    return DIRECTIONS[arg] and function()
      resize(leaf, DIRECTIONS[arg])
    end
  end,
  split = function(leaf, arg)
    local axis = ({ v = 'x', vertical = 'x', h = 'y', horizontal = 'y' })[arg]

    if axis then
      return function()
        split(leaf, axis)
      end
    end

    return arg == 'toggle' and function()
      toggle_split(leaf)
    end
  end,
  layout = function(leaf, arg)
    if arg == 'tabbed' or arg == 'stacking' then
      return function()
        make_tabbed(leaf, arg == 'stacking')
      end
    end

    return arg == 'toggle split' and function()
      local group = leaf and leaf.window.group

      if is_live_group(group) then
        untab(leaf, group)
      else
        toggle_split(leaf)
      end
    end
  end,
  fit = function(_, arg, root)
    return arg == 'all' and function()
      if root then
        fit_all(root)
      end
    end
  end,
}

local USAGE =
  'i3: expected "focus|move|resize <left|right|up|down>", "split <vertical|horizontal|toggle>", "layout <tabbed|stacking|toggle split>", or "fit all"'

local function layout_msg(ctx, msg)
  local command, arg = msg:match('^(%S+)%s*(.-)%s*$')
  local root = pick_root(ctx.targets)

  if root then
    sync_tree(root, ctx.targets)
  end

  local handler = command and COMMANDS[command]
  local run = handler and handler(active_leaf(ctx.targets), arg, root)

  if not run then
    return USAGE
  end

  run()
  return true
end

function M.setup()
  if is_setup then
    return
  end

  is_setup = true

  hl.on('window.active', stamp_focus)

  hl.on('window.destroy', function(window)
    if window and window.address then
      focus_stamps[window.address] = nil
    end
  end)

  hl.layout.register('i3', {
    recalculate = recalculate,
    layout_msg = layout_msg,
  })
end

return M
