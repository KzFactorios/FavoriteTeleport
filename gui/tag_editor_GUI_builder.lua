local Constants = require("constants")
local Helpers = require("core.utils.helpers")
local Storage = require("core.storage")
local MapTag = require("core.map_tag")

-- Optional: Patch for test environments where gui.tag_editor_gui_module does not exist
local ok, tag_editor_gui_module = pcall(require, "gui.tag_editor_gui_module")
if not ok then
  tag_editor_gui_module = { update_save_btn = function() end }
end

local TagEditorGUIBuilder = {}

-- Builder object for tag editor GUI
local TagEditorGUIBuilderClass = {}
TagEditorGUIBuilderClass.__index = TagEditorGUIBuilderClass

-- Helper to add a row to the tag editor GUI
local function add_row(parent, name, label_caption, label_style, element_def, opts)
  opts = opts or {}
  local row = parent.add { type = "flow", direction = "horizontal", name = name }
  if opts.top_margin then row.style.top_margin = opts.top_margin end
  row.style.vertical_align = "center"
  local label = row.add { type = "label", caption = label_caption, style = label_style }
  if opts.label_margin then label.style.left_margin = opts.label_margin end
  -- Add the main element (button, textfield, etc)
  local element = row.add(element_def)
  return row, label, element
end

function TagEditorGUIBuilderClass:new(player, position, context)
  if not player or not position then return end
  if not Storage.player_in_chart_view(player) then return end
  if Helpers.is_on_space_platform(player) or player.character == nil then return end

  --[[ -- Validate position: do not allow {x=0, y=0} unless explicitly intended
  if type(position) ~= "table" or type(position.x) ~= "number" or type(position.y) ~= "number" then
    return nil
  end
  if position.x == 0 and position.y == 0 then
    -- Only allow {0,0} if explicitly allowed via context
    if not (context and context.allow_zero_position) then
      return nil
    end
  end]]

  position = Helpers.snap_position(position, Constants.settings.SNAP_SCALE_FOR_CLICKED_TAG)
  local position_can_be_tagged = Helpers.position_can_be_tagged(player, position)
  if not position_can_be_tagged then
    --TODO let the player know that they are not able to create a tag from the position
    return nil
  end


  --- @type LuaCustomChartTag|nil
  local chart_tag = nil
  local gps = Helpers.map_position_to_gps(position, player.surface.index)

  -- TODO: Improve snap_scale logic.
  -- Current approach snaps to the outside of the indicator for better UX: if the chart_tag indicator is highlighted ([]),
  -- the user expects to select that location. However, the indicator is square and the selector is round, which can cause
  -- slight mismatches. Consider snapping to the center of the indicator, matching selector/indicator shapes, or adding a
  -- buffer zone for more intuitive selection. Also, explore dynamic snap_scale based on zoom or user preference.
  local position_has_colliding_tag =
      Helpers.position_has_colliding_tag(player, position, Constants.settings.BOUNDING_BOX_TOLERANCE)
  if position_has_colliding_tag ~= nil then
    -- we are editing, get the matching chart_tag
    -- update the chart_tag position if necessary. Sometimes a chart_tag may have been created
    -- by methods outside of this mod. This will normalize the position xxx.yyy
    local collide_gps = Helpers.format_gps(position_has_colliding_tag.x, position_has_colliding_tag.y,
      player.surface.index)
    local found_tag = Storage.find_chart_tag_by_gps(player, collide_gps)

    -- update to snapped pos
    chart_tag = Storage.rehome_chart_tag(player, found_tag, collide_gps)
    gps = collide_gps
  end

  -- Do NOT create a chart tag here! Only look up existing.
  chart_tag = Storage.find_chart_tag_by_gps(player, gps) or nil
  local map_tag = Storage.find_map_tag_by_gps(player, gps)

  local favorite_calc = map_tag and
      map_tag:is_player_favorite(player) or false

  local effective_position = chart_tag and chart_tag.position or position

  Storage.set_tag_editor_position(player, effective_position)

  local o = {
    player = player,
    position = effective_position, -- use the chart tag's pos
    is_favorite = favorite_calc,
    context = context,
    gui = player.gui.screen,
    outer_frame = nil,
    content_frame = nil,
    gps = Helpers.format_gps(effective_position.x, effective_position.y, player.surface.index) or gps,
    chart_tag = chart_tag,
    map_tag = map_tag
  }
  setmetatable(o, self)
  return o
end

function TagEditorGUIBuilderClass:build_outer_frame()
  -- Ensure no duplicate outer frame exists
  if self.gui.ft_tag_editor_outer_frame then
    self.gui.ft_tag_editor_outer_frame.destroy()
  end
  self.outer_frame = self.gui.add {
    type = "frame",
    name = "ft_tag_editor_outer_frame",
    direction = "vertical",
    style = "frame"
  }
  return self
end

function TagEditorGUIBuilderClass:build_titlebar()
  local titlebar_flow = self.outer_frame.add {
    type = "flow",
    direction = "horizontal",
    name = "ft_tag_editor_titlebar_flow"
  }
  titlebar_flow.style.horizontally_stretchable = true
  titlebar_flow.style.vertical_align = "center"
  titlebar_flow.style.top_padding = 2
  titlebar_flow.style.bottom_padding = 2

  local title_label = titlebar_flow.add {
    type = "label",
    caption = { "ft_tag_editor_title" },
    style = "frame_title"
  }
  title_label.style.left_margin = 4
  title_label.style.right_margin = 4

  local handle = titlebar_flow.add { type = "empty-widget", style = "draggable_space_header" }
  handle.style.horizontally_stretchable = true
  handle.style.height = 24
  handle.drag_target = self.outer_frame

  local close_btn = titlebar_flow.add {
    type = "sprite-button",
    name = "ft_tag_editor_x_btn",
    sprite = "utility/close",
    style = "frame_action_button"
  }
  return self
end

function TagEditorGUIBuilderClass:build_content_frame()
  local frame = self.outer_frame.add {
    type = "frame",
    name = "ft_tag_editor_frame",
    caption = "",
    direction = "vertical",
    style = "inside_shallow_frame_with_padding",
    top_margin = 0
  }
  frame.style.horizontally_stretchable = true
  frame.style.vertically_stretchable = true
  frame.style.padding = 0

  local top_row_frame = frame.add {
    type = "frame",
    direction = "horizontal",
    name = "ft_tag_editor_top_row_frame",
    style = "ft_tag_editor_top_row_frame"
  }
  top_row_frame.style.horizontally_stretchable = true
  top_row_frame.style.vertically_stretchable = false
  top_row_frame.style.margin = 0
  top_row_frame.style.top_padding = 6
  top_row_frame.style.left_padding = 8
  top_row_frame.style.right_padding = 4
  top_row_frame.style.bottom_padding = 4
  top_row_frame.style.height = 40

  local last_user_container = top_row_frame.add {
    type = "frame",
    direction = "horizontal",
    style = "invisible_frame"
  }
  last_user_container.style.horizontally_stretchable = false
  last_user_container.style.vertically_stretchable = false
  last_user_container.style.width = 220
  last_user_container.style.maximal_width = 220
  last_user_container.style.margin = 0
  last_user_container.style.padding = 0

  local last_user_label = last_user_container.add {
    type = "label",
    caption = { "ft_tag_editor_last_user", ": " },
  }
  last_user_label.style.horizontally_stretchable = false
  last_user_label.style.font = "default-bold"
  last_user_label.style.font_color = { r = 1, g = 0.901961, b = 0.752941 }
  last_user_label.style.top_margin = 2
  last_user_label.style.left_margin = 8
  last_user_label.style.right_margin = 0
  last_user_label.style.vertical_align = "center"

  local last_user = (self.context and self.context.tag_data and self.context.tag_data.last_user)
  if not last_user or last_user == "" then
    last_user = self.player.name
  end
  local last_user_value_label = last_user_container.add {
    type = "label",
    caption = last_user,
  }
  last_user_value_label.style.horizontally_stretchable = false
  last_user_value_label.style.font = "default-bold"
  last_user_value_label.style.font_color = { r = 1, g = 0.901961, b = 0.752941 }
  last_user_value_label.style.top_margin = 2
  last_user_value_label.style.left_margin = 4
  last_user_value_label.style.vertical_align = "center"
  last_user_value_label.style.horizontal_align = "left"

  local move_btn_container = top_row_frame.add {
    type = "frame",
    direction = "horizontal",
    style = "bordered_frame"
  }
  move_btn_container.style.horizontally_stretchable = false
  move_btn_container.style.vertically_stretchable = false
  move_btn_container.style.top_margin = -2
  move_btn_container.style.top_padding = 0
  move_btn_container.style.right_padding = 0
  move_btn_container.style.left_padding = 0
  move_btn_container.style.bottom_padding = 0
  move_btn_container.style.width = 28
  move_btn_container.style.height = 28

  local move_btn = move_btn_container.add {
    type = "sprite-button",
    name = "ft_tag_editor_move_btn",
    sprite = "ft_move_tag_icon",
    style = "slot_button",
    tooltip = { "ft_tag_editor_move_tooltip_enhanced" },
    enabled = false
  }
  move_btn.style.width = 24
  move_btn.style.height = 24
  move_btn.style.left_margin = -2
  move_btn.style.right_margin = 0
  move_btn.style.top_margin = -2
  move_btn.style.bottom_margin = 0
  move_btn.style.padding = 2

  local delete_btn = top_row_frame.add {
    type = "sprite-button",
    name = "ft_tag_editor_delete_btn",
    sprite = "utility/trash",
    style = "frame_action_button",
    tooltip = { "ft_tag_editor_delete_tooltip" }
  }
  delete_btn.style.left_margin = 2
  delete_btn.style.right_margin = 0

  local content_frame = frame.add {
    type = "frame",
    name = "ft_tag_editor_content_frame",
    direction = "vertical",
    style = "inside_shallow_frame_with_padding"
  }
  content_frame.style.padding = 16
  content_frame.style.horizontally_stretchable = true
  content_frame.style.vertically_stretchable = true

  add_row(content_frame, "ft_tag_editor_teleport_row", { "ft_tag_editor_teleport" },
    "te_tr_teleport_label", {
      type = "button",
      name = "ft_tag_editor_pos_btn",
      caption = Helpers.gps_to_map_position_string(self.gps),
      style = "ft_teleport_button"
    })

  local available_slots = Storage.get_available_favorite_slots_count(self.player)
  local faved = false
  if self.map_tag and self.map_tag:is_player_favorite(self.player) then
    faved = true
  end
  local favorite_enabled = (available_slots > 0) or faved

  add_row(content_frame, "ft_tag_editor_favorite_row", { "ft_tag_editor_favorite_label" },
    "te_tr_favorite_label", {
      type = "sprite-button",
      name = "ft_tag_editor_favorite_btn",
      sprite = faved and "utility/check_mark_green" or nil,
      tooltip = { "ft_tag_editor_favorite_tooltip" },
      style = "ft_favorite_button",
      enabled = favorite_enabled
    }, { top_margin = 8 })

  add_row(content_frame, "ft_tag_editor_icon_row", { "ft_tag_editor_icon" }, "te_tr_icon_label", {
    type = "choose-elem-button",
    name = "tag-editor-icon",
    elem_type = "signal",
    signal = self.chart_tag and self.chart_tag.icon or nil,
    tooltip = { "ft_tag_editor_icon_tooltip" },
    style = "ft_icon_picker_button"
  }, { top_margin = 8 })

  add_row(content_frame, "ft_tag_editor_text_row", { "ft_tag_editor_text" }, "te_tr_text_label", {
    type = "textfield",
    name = "ft_tag_editor_textbox",
    text = self.chart_tag and self.chart_tag.text or "",
    clear_and_focus_on_right_click = true,
    tooltip = { "ft_tag_editor_text_tooltip" },
    style = "ft_textfield"
  }, { top_margin = 8 })

  add_row(content_frame, "ft_tag_editor_desc_row", { "ft_tag_editor_desc" }, "te_tr_desc_label", {
    type = "textfield",
    name = "ft_tag_editor_descbox",
    text = self.map_tag and self.map_tag.description or "",
    clear_and_focus_on_right_click = true,
    tooltip = { "ft_tag_editor_desc_tooltip" },
    numeric = false,
    allow_blank = true,
    style = "ft_descfield"
  }, { top_margin = 8 })

  return self
end

function TagEditorGUIBuilderClass:build_action_row()
  local action_row = self.outer_frame.add { type = "flow", direction = "horizontal", name = "ft_tag_editor_action_row" }
  local drag_handle = action_row.add {
    type = "empty-widget",
    style = "draggable_space_header"
  }
  drag_handle.style.horizontally_stretchable = true
  drag_handle.style.height = 32
  drag_handle.drag_target = self.outer_frame
  local save_btn = action_row.add {
    type = "button",
    name = "ft_tag_editor_save_btn",
    caption = { "ft_tag_editor_save" },
    style = "ft_confirm_button",
    enabled = false,
    tooltip = { "ft_tag_editor_save_tooltip" }
  }
  save_btn.style.horizontal_align = "center"
  return self
end

function TagEditorGUIBuilderClass:finalize()
  self.player.opened = self.outer_frame
  if self.outer_frame.force_auto_center then
    self.outer_frame.force_auto_center()
  end
  return self.outer_frame
end

function TagEditorGUIBuilder.open(player, position, context)
  if type(player) ~= "table" or type(position) ~= "table" then return nil end
  local builder = TagEditorGUIBuilderClass:new(player, position, context)
  if not builder then return nil end
  builder:build_outer_frame()
      :build_titlebar()
      :build_content_frame()
      :build_action_row()
  if tag_editor_gui_module and type(tag_editor_gui_module.update_save_btn) == "function" then
    local _ok, _err = pcall(tag_editor_gui_module.update_save_btn, player)
  end
  return builder
end

function TagEditorGUIBuilder.close(player)
  local gui = player.gui.screen
  if gui.ft_tag_editor_outer_frame then
    gui.ft_tag_editor_outer_frame.destroy()
  end
end

return TagEditorGUIBuilder
