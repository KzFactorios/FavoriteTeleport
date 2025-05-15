local Constants = require("constants")
local Helpers = require("core.utils.helpers")

local TagEditorGUI = {}

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

TagEditorGUI.add_row = add_row

function TagEditorGUI.open(player, position, is_favorite, context)
  is_favorite = is_favorite or false
  TagEditorGUI.close(player) -- Ensure only one instance

  local gui = player.gui.screen

  -- Outer frame (vanilla style, with border)
  local outer_frame = gui.add {
    type = "frame",
    name = "ft_tag_editor_outer_frame",
    direction = "vertical",
    style = "frame"
  }

  -- Titlebar (vanilla style)
  local titlebar_flow = outer_frame.add {
    type = "flow",
    direction = "horizontal",
    name = "ft_tag_editor_titlebar_flow"
  }
  titlebar_flow.style.horizontally_stretchable = true
  titlebar_flow.style.vertical_align = "center"
  titlebar_flow.style.top_padding = 2
  titlebar_flow.style.bottom_padding = 2

  -- Title label
  local title_label = titlebar_flow.add {
    type = "label",
    caption = { "ft_tag_editor_title" },
    style = "frame_title"
  }
  title_label.style.left_margin = 4
  title_label.style.right_margin = 4
  -- Draggable space
  local handle = titlebar_flow.add { type = "empty-widget", style = "draggable_space_header" }
  handle.style.horizontally_stretchable = true
  handle.style.height = 24
  handle.drag_target = outer_frame
  -- Close button
  local close_btn = titlebar_flow.add {
    type = "sprite-button",
    name = "ft_tag_editor_x_btn",
    sprite = "utility/close",
    style = "frame_action_button"
  }

  -- Main content frame (vanilla inside frame)
  local frame = outer_frame.add {
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

  -- Last user row (vanilla style, dark background, full width, no margins, correct border)
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

  -- Containing frame for last_user label/value
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

  -- Last user label (static localized text)
  local last_user_label = last_user_container.add {
    type = "label",
    caption = {"ft_tag_editor_last_user"},
  }
  last_user_label.style.horizontally_stretchable = false
  last_user_label.style.font = "default-bold"
  last_user_label.style.font_color = {r=1, g=0.901961, b=0.752941}
  last_user_label.style.top_margin = 2
  last_user_label.style.left_margin = 8
  last_user_label.style.right_margin = 0
  last_user_label.style.vertical_align = "center"

  -- Last user value label (dynamic value)
  local last_user = (context and context.tag_data and context.tag_data.last_user)
  if not last_user or last_user == "" then
    last_user = player.name
  end
  local last_user_value_label = last_user_container.add {
    type = "label",
    caption = last_user,
  }
  last_user_value_label.style.horizontally_stretchable = false
  last_user_value_label.style.font = "default-bold"
  last_user_value_label.style.font_color = {r=1, g=0.901961, b=0.752941}
  last_user_value_label.style.top_margin = 2
  last_user_value_label.style.left_margin = 4
  last_user_value_label.style.vertical_align = "center"
  last_user_value_label.style.horizontal_align = "left"

  -- Move button in a bordered_frame for proper layout
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
    enabled = false -- will be enabled only for last_user and existing tag
  }
  move_btn.style.width = 24
  move_btn.style.height = 24
  move_btn.style.left_margin = -2
  move_btn.style.right_margin = 0
  move_btn.style.top_margin = -2
  move_btn.style.bottom_margin = 0
  move_btn.style.padding = 2

  -- Delete button (vanilla: red trash icon)
  local delete_btn = top_row_frame.add {
    type = "sprite-button",
    name = "ft_tag_editor_delete_btn",
    sprite = "utility/trash",
    style = "frame_action_button",
    tooltip = { "ft_tag_editor_delete_tooltip" }
  }
  delete_btn.style.left_margin = 2
  delete_btn.style.right_margin = 0
  -- Enable move button only for last_user if editing an existing tag (chart_tag exists)
  local effective_last_user = (context and context.tag_data and context.tag_data.last_user)
  if not effective_last_user or effective_last_user == "" then
    effective_last_user = player.name
  end
  if context and context.is_edit and effective_last_user == player.name and context.tag_data and context.tag_data.chart_tag then
    move_btn.enabled = true
  end
  -- end of last user row

  -- Content row
  local content_frame = frame.add {
    type = "frame",
    name = "ft_tag_editor_content_frame",
    direction = "vertical",
    style = "inside_shallow_frame_with_padding"
  }
  content_frame.style.padding = 16
  content_frame.style.horizontally_stretchable = true
  content_frame.style.vertically_stretchable = true

  -- Teleport row (add top_margin to match vanilla spacing)
  local pos_string = position and Helpers.map_position_to_pos_string(position) or "[no pos]"
  add_row(content_frame, "ft_tag_editor_teleport_row", { "ft_tag_editor_teleport" },
    "te_tr_teleport_label", {
    type = "button",
    name = "ft_tag_editor_pos_btn",
    caption = pos_string,
    style = "ft_teleport_button"
  })

  -- Favorite row
  local max_slots = Constants.MAX_FAVORITE_SLOTS
  local available_slots = context and context.available_slots or max_slots
  local favorite_enabled = available_slots > 0
  add_row(content_frame, "ft_tag_editor_favorite_row", { "ft_tag_editor_favorite_label" },
    "te_tr_favorite_label", {
    type = "sprite-button",
    name = "ft_tag_editor_favorite_btn",
    sprite = (is_favorite and favorite_enabled) and "utility/check_mark_green" or nil,
    tooltip = { "ft_tag_editor_favorite_tooltip" },
    style = "ft_favorite_button",
    enabled = favorite_enabled
  }, { top_margin = 8 })
  if not favorite_enabled then
    is_favorite = false
  end

  -- Icon picker row
  add_row(content_frame, "ft_tag_editor_icon_row", { "ft_tag_editor_icon" }, "te_tr_icon_label", {
    type = "choose-elem-button",
    name = "tag-editor-icon",
    elem_type = "signal",
    signal = nil,
    tooltip = { "ft_tag_editor_icon_tooltip" },
    style = "ft_icon_picker_button"
  }, { top_margin = 8 })

  -- Text row
  add_row(content_frame, "ft_tag_editor_text_row", { "ft_tag_editor_text" }, "te_tr_text_label", {
    type = "textfield",
    name = "ft_tag_editor_textbox",
    text = "",
    clear_and_focus_on_right_click = true,
    tooltip = { "ft_tag_editor_text_tooltip" },
    style = "ft_textfield"
  }, { top_margin = 8 })

  -- Description row
  add_row(content_frame, "ft_tag_editor_desc_row", { "ft_tag_editor_desc" }, "te_tr_desc_label", {
    type = "textfield",
    name = "ft_tag_editor_descbox",
    text = "",
    clear_and_focus_on_right_click = true,
    tooltip = { "ft_tag_editor_desc_tooltip" },
    numeric = false,
    allow_blank = true,
    style = "ft_descfield"
  }, { top_margin = 8 })

  -- Move action row to outer_frame (below the main content frame)
  local action_row = outer_frame.add { type = "flow", direction = "horizontal", name = "ft_tag_editor_action_row" }
  --action_row.style.top_margin = 8
  -- Add draggable handle instead of cancel button
  local drag_handle = action_row.add {
    type = "empty-widget",
    style = "draggable_space_header"
  }
  drag_handle.style.horizontally_stretchable = true
  drag_handle.style.height = 32
  drag_handle.drag_target = outer_frame
  local save_btn = action_row.add {
    type = "button",
    name = "ft_tag_editor_save_btn",
    caption = { "ft_tag_editor_save" },
    style = "ft_confirm_button",
    enabled = false,
    tooltip = { "ft_tag_editor_save_tooltip" }
  }
  save_btn.style.horizontal_align = "center"

  player.opened = outer_frame
  if outer_frame.force_auto_center then
    outer_frame.force_auto_center()
  end
end

function TagEditorGUI.close(player)
  local gui = player.gui.screen
  if gui.ft_tag_editor_outer_frame then
    gui.ft_tag_editor_outer_frame.destroy()
  end
end

return TagEditorGUI
