local PREFIX = require("constants").PREFIX

---@diagnostic disable-next-line: undefined-global
local gui_style = data.raw["gui-style"].default

gui_style.te_ip_favorite_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 70,
  maximal_width = 70,
  left_margin = 20,
  vertical_align = "center"
}

gui_style.te_ip_icon_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 50,
  maximal_width = 50,
  vertical_align = "center"
}

gui_style.te_tr_teleport_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 110,
  maximal_width = 110
}

gui_style.te_tr_text_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 110,
  maximal_width = 110
}

gui_style.te_dr_description_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 110,
  maximal_width = 110
}
