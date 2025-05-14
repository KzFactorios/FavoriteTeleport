local PREFIX = require("constants").PREFIX

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

-- Custom cancel button style (fixed width, centered text)
gui_style.ft_cancel_button = {
  type = "button_style",
  parent = "back_button",
  minimal_width = 100,
  maximal_width = 100,
  horizontally_stretchable = "off",
  horizontal_align = "center",
  right_margin = 20
}

-- Custom save/teleport button style (fixed width, confirm appearance)
gui_style.ft_confirm_button = {
  type = "button_style",
  parent = "confirm_button",
  minimal_width = 180,
  maximal_width = 180,
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
