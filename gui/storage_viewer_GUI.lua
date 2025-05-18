-- storage_viewer_GUI.lua
-- Advanced tree view GUI for displaying the FavoriteTeleport storage object

-- Helper to check if a value is a LuaCustomChartTag (best effort)
local function is_lua_custom_chart_tag(val)
  return type(val) == "table"
    and val.valid ~= nil
    and val.tag_number ~= nil
    and val.position ~= nil
    and val.text ~= nil
end

local StorageViewerGUI = {}

-- Helper to serialize LuaCustomChartTag for display
local function serialize_chart_tag(tag)
  if not tag or type(tag) ~= "table" or not tag.valid then
    return { _type = "LuaCustomChartTag", valid = false }
  end
  local icon_str = tag.icon and (tag.icon.type .. ":" .. tag.icon.name) or "nil"
  return {
    _type = "LuaCustomChartTag",
    position = tag.position and ("{" .. tag.position.x .. ", " .. tag.position.y .. "}") or "nil",
    text = tag.text or "",
    icon = icon_str,
    last_user = tag.last_user and tag.last_user.name or tostring(tag.last_user),
    tag_number = tag.tag_number,
    surface = tag.surface and tag.surface.name or "nil",
    force = tag.force and tag.force.name or "nil",
    valid = tag.valid
  }
end

local GUI_NAME = "ft_storage_viewer_frame"
local SCROLL_NAME = "ft_storage_viewer_scroll"
local CLOSE_BTN_NAME = "ft_storage_viewer_close_btn"

--- Recursively add table data to the parent element as a tree view
-- @param parent LuaGuiElement
-- @param data table
-- @param depth integer
-- @param expand_state table (per-player, per-path)
-- @param path string (dot-separated)
local function add_table_tree(parent, data, depth, expand_state, path)
  if type(data) ~= "table" then
    parent.add{type="label", caption=tostring(data)}
    return
  end
  -- Special handling for LuaCustomChartTag
  if is_lua_custom_chart_tag(data) then
    data = serialize_chart_tag(data)
  end
  for k, v in pairs(data) do
    local node_path = path .. "." .. tostring(k)
    local is_table = type(v) == "table"
    -- Special handling for LuaCustomChartTag values
    if is_table and is_lua_custom_chart_tag(v) then
      local serialized = serialize_chart_tag(v)
      -- Instead of replacing v (which may be used in the next branch), display the serialized fields inline
      for field, value in pairs(serialized) do
        local sub_flow = parent.add{type="flow", direction="horizontal"}
        sub_flow.add{type="empty-widget", style="draggable_space_header"}
        sub_flow.add{type="label", caption=("%s%s:"):format(string.rep("  ", depth+1), tostring(field))}
        sub_flow.add{type="label", caption=tostring(value)}
      end
      goto continue
    end
    local flow = parent.add{type="flow", direction="horizontal"}
    if is_table then
      local expanded = expand_state[node_path] ~= false
      local btn = flow.add{
        type = "button",
        name = "ft_storage_viewer_toggle_" .. node_path,
        caption = expanded and "–" or "+",
        style = "tool_button",
        tooltip = expanded and "Collapse" or "Expand"
      }
      flow.add{type="label", caption=("%s%s:"):format(string.rep("  ", depth), tostring(k))}
      if expanded then
        add_table_tree(parent, v, depth + 1, expand_state, node_path)
      end
    else
      flow.add{type="empty-widget", style="draggable_space_header"}
      flow.add{type="label", caption=("%s%s:"):format(string.rep("  ", depth), tostring(k))}
      flow.add{type="label", caption=tostring(v)}
    end
    ::continue::
  end
end

--- Open the storage viewer GUI for a player
function StorageViewerGUI.open(player, storage, expand_state)
  if not player or not player.valid then return end
  local gui = player.gui.screen
  if gui[GUI_NAME] then gui[GUI_NAME].destroy() end
  local frame = gui.add{
    type = "frame",
    name = GUI_NAME,
    caption = {"storage_viewer_title"},
    direction = "vertical"
  }
  frame.auto_center = true
  frame.style.width = 800
  frame.style.height = 600
  frame.style.vertically_stretchable = true
  frame.style.horizontally_stretchable = true
  frame.style.maximal_height = 800
  frame.style.maximal_width = 1200
  frame.style.minimal_height = 400
  frame.style.minimal_width = 400

  local top_flow = frame.add{type="flow", direction="horizontal"}
  top_flow.add{type="empty-widget", style="draggable_space_header", horizontally_stretchable=true}
  top_flow.add{
    type = "sprite-button",
    name = CLOSE_BTN_NAME,
    sprite = "utility/close_fat",
    style = "frame_action_button",
    tooltip = {"gui.close"}
  }

  local scroll = frame.add{
    type = "scroll-pane",
    name = SCROLL_NAME,
    direction = "vertical"
  }
  scroll.style.vertically_stretchable = true
  scroll.style.horizontally_stretchable = true
  scroll.style.maximal_height = 700
  scroll.style.maximal_width = 1100
  scroll.style.minimal_height = 300
  scroll.style.minimal_width = 300
  scroll.vertical_scroll_policy = "auto"
  scroll.horizontal_scroll_policy = "auto"

  add_table_tree(scroll, storage, 0, expand_state or {}, "root")
end

--- Close the storage viewer GUI for a player
function StorageViewerGUI.close(player)
  if not player or not player.valid then return end
  local gui = player.gui.screen
  if gui[GUI_NAME] then gui[GUI_NAME].destroy() end
end

return StorageViewerGUI
