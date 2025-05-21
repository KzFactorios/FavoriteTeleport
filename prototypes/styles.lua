local Constants = require("constants")

---@diagnostic disable-next-line: undefined-global
local gui_style = data.raw["gui-style"].default

gui_style.te_tr_favorite_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 120,
  maximal_width = 120
}

gui_style.te_tr_icon_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 120,
  maximal_width = 120
}

gui_style.te_tr_teleport_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 120,
  maximal_width = 120
}

gui_style.te_tr_text_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 120,
  maximal_width = 120
}

gui_style.te_tr_desc_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 120,
  maximal_width = 120
}

gui_style.te_tr_teleport_button = {
  type = "button_style",
  parent = "red_button",
  minimal_width = 180,
  maximal_width = 180,
  horizontally_stretchable = "off",
}

-- Custom save/teleport button style (fixed width, confirm appearance)
gui_style.ft_confirm_button = {
  type = "button_style",
  parent = "confirm_button",
  --minimal_width = 180,
  --maximal_width = 180,
  horizontally_stretchable = "off"
}

gui_style.ft_teleport_button = {
  type = "button_style",
  parent = "confirm_button",
  minimal_width = 180,
  maximal_width = 180,
  horizontally_stretchable = "off",
  horizontal_align = "center"
}

-- Favorite teleport button style
gui_style.ft_favorite_button = {
  type = "button_style",
  parent = "slot_button",
  width = 36,
  height = 36,
  horizontally_stretchable = "off"
}

-- Icon picker button style (fix: use slot_button as parent, since choose_elem_button is not a valid parent for button_style)
gui_style.ft_icon_picker_button = {
  type = "button_style",
  parent = "slot_button",
  width = 36,
  height = 36,
  horizontally_stretchable = "off"
}

-- Toggle favorite mode button style (fixes missing style error)
gui_style.ft_toggle_favorite_mode_button = {
  type = "button_style",
  parent = "slot_button",
  width = 36,
  height = 36,
  horizontally_stretchable = "off"
}

-- Textfield style
gui_style.ft_textfield = {
  type = "textbox_style",
  parent = "textbox",
  width = 180,
  horizontally_stretchable = "off"
}

-- Description field style
gui_style.ft_descfield = {
  type = "textbox_style",
  parent = "textbox",
  width = 180,
  horizontally_stretchable = "off"
}

-- top row flow style
-- (removed duplicate ft_descfield definition)

-- Custom style for the tag editor top row (last user row)
gui_style.ft_tag_editor_top_row_frame = {
  type = "frame_style",
  graphical_set = {
    base = {
      position = {17, 0},
      corner_size = 8,
      center = {width = 1, height = 1, tint = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 }},
      draw_type = "outer"
    }
  },
  left_padding = 8,
  right_padding = 8,
  top_padding = 4,
  bottom_padding = 8,
  font = "default-bold",
  horizontally_stretchable = "on",
  width = 0,             
  maximal_width = 0,
  border = { base = { center = { width = 1, height = 1, tint = { r = 0.4, g = 0.4, b = 0.4, a = 1.0 } } } }   
}

gui_style.ft_tag_editor_top_row = {
  type = "horizontal_flow_style",
}

gui_style.te_tr_error_label = {
  type = "label_style",
  parent = "label",
  font = "default-bold",
  font_color = { r = 1, g = 0.2, b = 0.2 }, -- red
  single_line = false,
  horizontally_stretchable = "on",
  vertically_stretchable = "off",
  maximal_width = 400,
  minimal_width = 120,
  top_padding = 2,
  bottom_padding = 2,
  left_padding = 4,
  right_padding = 4,
}
