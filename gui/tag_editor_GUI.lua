--- tag_editor_GUI.lua
--- Handles the tag editor dialog for FavoriteTeleport mod

local TagEditorGUI = {}
local Constants = require("constants")
local Helpers = require("core.utils.helpers")

-- Helper to add a row to the tag editor GUI
local function add_row(parent, name, label_caption, label_style, element_def, opts)
  opts = opts or {}
  local row = parent.add{type="flow", direction="horizontal", name=name}
  if opts.top_margin then row.style.top_margin = opts.top_margin end
  row.style.vertical_align = "center"
  local label = row.add{type="label", caption=label_caption, style=label_style}
  if opts.label_margin then label.style.left_margin = opts.label_margin end
  -- Add the main element (button, textfield, etc)
  local element = row.add(element_def)
  return row, label, element
end

--- Opens the tag editor GUI for a player
-- @param player LuaPlayer
-- @param position MapPosition|nil The map position that was clicked (optional)
-- @param is_favorite boolean|nil Whether the tag is a favorite (optional)
function TagEditorGUI.open(player, position, is_favorite)
  is_favorite = is_favorite or false
  TagEditorGUI.close(player) -- Ensure only one instance

  local gui = player.gui.screen

  -- Outer frame (vanilla style)
  local outer_frame = gui.add{
    type = "frame",
    name = "ft_tag_editor_outer_frame",
    direction = "vertical",
    style = "frame"
  }

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

  -- Teleport row
  local pos_string = position and Helpers.map_position_to_pos_string(position) or "[no pos]"
  local teleport_row = add_row(frame, "ft_tag_editor_teleport_row", {"FavoriteTeleport.ft_tag_editor_teleport"}, "te_tr_teleport_label", {
    type = "button",
    name = "ft_tag_editor_pos_btn",
    caption = pos_string,
    style = "ft_teleport_button"
  })

  -- Favorite row
  local favorite_row = add_row(frame, "ft_tag_editor_favorite_row", {"FavoriteTeleport.ft_tag_editor_favorite_label"}, "te_tr_favorite_label", {
    type = "sprite-button",
    name = "ft_tag_editor_favorite_btn",
    sprite = is_favorite and "utility/check_mark_green" or nil,
    tooltip = {"FavoriteTeleport.ft_tag_editor_favorite_tooltip"},
    style = "ft_favorite_button"
  }, {top_margin=8})

  -- Icon picker row
  local icon_row = add_row(frame, "ft_tag_editor_icon_row", {"FavoriteTeleport.ft_tag_editor_icon"}, "te_tr_icon_label", {
    type = "choose-elem-button",
    name = "tag-editor-icon",
    elem_type = "signal",
    signal = nil,
    tooltip = {"FavoriteTeleport.ft_tag_editor_icon_tooltip"},
    style = "ft_icon_picker_button"
  }, {top_margin=8})

  -- Text row
  local text_row = add_row(frame, "ft_tag_editor_text_row", {"FavoriteTeleport.ft_tag_editor_text"}, "te_tr_text_label", {
    type = "textfield",
    name = "ft_tag_editor_textbox",
    text = "",
    clear_and_focus_on_right_click = true,
    tooltip = {"FavoriteTeleport.ft_tag_editor_text_tooltip"},
    style = "ft_textfield"
  }, {top_margin=8})

  -- Description row
  local desc_row = add_row(frame, "ft_tag_editor_desc_row", {"FavoriteTeleport.ft_tag_editor_desc"}, "te_tr_desc_label", {
    type = "textfield",
    name = "ft_tag_editor_descbox",
    text = "",
    clear_and_focus_on_right_click = true,
    tooltip = {"FavoriteTeleport.ft_tag_editor_desc_tooltip"},
    numeric = false,
    allow_blank = true,
    style = "ft_descfield"
  }, {top_margin=8})

  -- Action buttons row
  local action_row = frame.add{type="flow", direction="horizontal", name="ft_tag_editor_action_row"}
  action_row.style.top_margin = 24
  action_row.add{
    type = "button",
    name = "ft_tag_editor_cancel_btn",
    caption = {"FavoriteTeleport.ft_tag_editor_cancel"},
    style = "ft_cancel_button"
  }
  local save_btn = action_row.add{
    type = "button",
    name = "ft_tag_editor_save_btn",
    caption = {"FavoriteTeleport.ft_tag_editor_save"},
    style = "ft_confirm_button",
    enabled = false,
    tooltip = {"FavoriteTeleport.ft_tag_editor_save_tooltip"}
  }
  save_btn.style.horizontal_align = "center"

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
