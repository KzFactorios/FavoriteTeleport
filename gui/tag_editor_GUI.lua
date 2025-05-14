--- tag_editor_GUI.lua
--- Handles the tag editor dialog for FavoriteTeleport mod

local TagEditorGUI = {}
local Constants = require("constants")
local Helpers = require("core.utils.helpers")

--- Opens the tag editor GUI for a player
-- @param player LuaPlayer
-- @param position MapPosition|nil The map position that was clicked (optional)
-- @param is_favorite boolean|nil Whether the tag is a favorite (optional)
function TagEditorGUI.open(player, position, is_favorite)
  is_favorite = is_favorite or false
  TagEditorGUI.close(player) -- Ensure only one instance

  local gui = player.gui.screen
  local width, height = 330, 240 -- increased width by ~10%

  -- Outer frame (vanilla style)
  local outer_frame = gui.add{
    type = "frame",
    name = "ft_tag_editor_outer_frame",
    direction = "vertical",
    style = "frame"
  }
  -- Remove explicit maximal/minimal width/height for dynamic sizing
  -- outer_frame.style.minimal_width = width
  -- outer_frame.style.maximal_width = width
  -- outer_frame.style.minimal_height = height
  -- outer_frame.style.maximal_height = height

  -- Titlebar (vanilla style)
  local titlebar_flow = outer_frame.add{
    type = "flow",
    direction = "horizontal",
    name = "ft_tag_editor_titlebar_flow"
  }
  titlebar_flow.style.horizontally_stretchable = true
  titlebar_flow.style.vertical_align = "center"
  titlebar_flow.style.top_padding = 2
  titlebar_flow.style.bottom_padding = 2

  -- Title label
  local title_label = titlebar_flow.add{
    type = "label",
    caption = {"FavoriteTeleport.ft_tag_editor_title"},
    style = "frame_title"
  }
  title_label.style.left_margin = 4
  title_label.style.right_margin = 4
  -- Draggable space
  local handle = titlebar_flow.add{type = "empty-widget", style = "draggable_space_header"}
  handle.style.horizontally_stretchable = true
  handle.style.height = 24
  handle.drag_target = outer_frame
  -- Close button
  local close_btn = titlebar_flow.add{
    type = "sprite-button",
    name = "ft_tag_editor_x_btn",
    sprite = "utility/close",
    style = "frame_action_button"
  }

  -- Main content frame (vanilla inside frame)
  local frame = outer_frame.add{
    type = "frame",
    name = "ft_tag_editor_frame",
    caption = "",
    direction = "vertical",
    style = "inside_shallow_frame_with_padding"
  }
  frame.style.horizontally_stretchable = true
  frame.style.vertically_stretchable = true

  -- Use flows for layout instead of a table

  -- Teleport row
  local teleport_row = frame.add{type="flow", direction="horizontal", name="ft_tag_editor_teleport_row"}
  teleport_row.add{
    type = "label",
    caption = {"FavoriteTeleport.ft_tag_editor_teleport"},
    style = "te_tr_teleport_label"
  }
  local pos_string = position and Helpers.map_position_to_pos_string(position) or "[no pos]"
  teleport_row.add{
    type = "button",
    name = "ft_tag_editor_pos_btn",
    caption = pos_string,
    style = "red_button",
    style_mods = {width=160, horizontally_stretchable=false}
  }

  -- Icon picker row
  local icon_row = frame.add{type="flow", direction="horizontal", name="ft_tag_editor_icon_row"}
  icon_row.style.top_margin = 8
  icon_row.add{type = "label", caption = {"FavoriteTeleport.ft_tag_editor_icon"}, style = "te_ip_icon_label"}
  icon_row.add{
    type = "choose-elem-button",
    name = "tag-editor-icon",
    elem_type = "signal",
    signal = nil,
    tooltip = {"FavoriteTeleport.ft_tag_editor_icon_tooltip"},
    style_mods = {width=36, height=36, horizontally_stretchable=false}
  }
  icon_row.add{type = "label", caption = {"FavoriteTeleport.ft_tag_editor_favorite_label"}, style = "te_ip_favorite_label", style_mods = {left_margin=20}}
  icon_row.add{
    type = "sprite-button",
    name = "ft_tag_editor_favorite_btn",
    sprite = is_favorite and "utility/check_mark_green" or nil,
    tooltip = {"FavoriteTeleport.ft_tag_editor_favorite_tooltip"},
    style = "slot_button",
    style_mods = {width=36, height=36, left_margin=20, horizontally_stretchable=false}
  }

  -- Text row
  local text_row = frame.add{type="flow", direction="horizontal", name="ft_tag_editor_text_row"}
  text_row.style.top_margin = 8
  text_row.add{type="label", caption={"FavoriteTeleport.ft_tag_editor_text"}, style="te_tr_text_label"}
  local text_box = text_row.add{
    type = "textfield",
    name = "ft_tag_editor_textbox",
    text = "",
    clear_and_focus_on_right_click = true,
    tooltip = {"FavoriteTeleport.ft_tag_editor_text_tooltip"},
    style_mods = {width=180, left_margin=20, horizontally_stretchable=false}
  }

  -- Description row
  local desc_row = frame.add{type="flow", direction="horizontal", name="ft_tag_editor_desc_row"}
  desc_row.style.top_margin = 8
  desc_row.add{type="label", caption={"FavoriteTeleport.ft_tag_editor_desc"}, style="te_dr_description_label"}
  local desc_box = desc_row.add{
    type = "textfield",
    name = "ft_tag_editor_descbox",
    text = "",
    clear_and_focus_on_right_click = true,
    tooltip = {"FavoriteTeleport.ft_tag_editor_desc_tooltip"},
    numeric = false,
    allow_blank = true,
    style_mods = {width=180, horizontally_stretchable=false}
  }

  -- Action buttons row
  local action_row = frame.add{type="flow", direction="horizontal", name="ft_tag_editor_action_row"}
  action_row.style.top_margin = 8
  action_row.add{
    type = "button",
    name = "ft_tag_editor_cancel_btn",
    caption = {"FavoriteTeleport.ft_tag_editor_cancel"},
    style_mods = {width=100, horizontally_stretchable=false}
  }
  action_row.add{
    type = "button",
    name = "ft_tag_editor_save_btn",
    caption = {"FavoriteTeleport.ft_tag_editor_save"},
    style = "confirm_button",
    style_mods = {width=100, left_margin=40, horizontally_stretchable=false}
  }

  player.opened = outer_frame
  if outer_frame.force_auto_center then
    outer_frame.force_auto_center()
  end
end

--- Closes the tag editor GUI for a player
-- @param player LuaPlayer
function TagEditorGUI.close(player)
  local gui = player.gui.screen
  if gui.ft_tag_editor_outer_frame then
    gui.ft_tag_editor_outer_frame.destroy()
  end
end

--- Handles GUI click events for the tag editor
-- @param event EventData.on_gui_click
function TagEditorGUI.on_click(event)
  if not event or not event.element or not event.element.valid then return end
  if event.element.name == "ft_tag_editor_x_btn" or event.element.name == "ft_tag_editor_close_btn" then
    return "close"
  end
  if event.element.name == "tag-editor-icon" then
    return "icon_picker"
  end
  if event.element.name == "ft_tag_editor_favorite_btn" then
    -- Toggle favorite state in-place using event.element
    if event.element.sprite and event.element.sprite ~= "" then
      event.element.sprite = nil
    else
      event.element.sprite = "utility/check_mark_green"
    end
    return "toggled_favorite_in_place"
  end
end

return TagEditorGUI
