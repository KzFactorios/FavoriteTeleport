-- storage_viewer_GUI.lua
-- Advanced tree view GUI for displaying the FavoriteTeleport storage object

local StorageViewerGUI = {}
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
  for k, v in pairs(data) do
    local node_path = path .. "." .. tostring(k)
    local is_table = type(v) == "table"
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
