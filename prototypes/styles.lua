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
  minimal_width = 100,
  maximal_width = 100
}

gui_style.te_tr_icon_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 100,
  maximal_width = 100
}

gui_style.te_tr_teleport_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 100,
  maximal_width = 100
}

gui_style.te_tr_text_label = {
  type = "label_style",
  parent = "label",
  single_line = true,
  horizontally_stretchable = "off",
  vertically_stretchable = "off",
  font = "default-bold",
  minimal_width = 100,
  maximal_width = 100
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
  minimal_width = 200,
  maximal_width = 200,
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
  width = 200,
  horizontally_stretchable = "off"
}

-- Description field style
gui_style.ft_descfield = {
  type = "textbox_style",
  parent = "textbox",
  width = 200,
  horizontally_stretchable = "off"
}


gui_style.te_tr_error_label = {
  type = "label_style",
  parent = "label",
  font = "default-bold",
  font_color = { r = 1, g = 0.2, b = 0.2 }, -- red
  single_line = false,
  horizontally_stretchable = "on",
  vertically_stretchable = "off",
  top_padding = 2,
  bottom_padding = 2,
  left_padding = 4,
  right_padding = 4,
}



--- TOP ROW (last user row)
gui_style.te_tr_top_row_frame = {
  type = "frame_style",
  parent = "frame",
  graphical_set = {
    base = {
      type = "composition",
      filename = "__core__/graphics/gui-new.png",
      position = { 0, 0 },
      corner_size = 8,
      draw_type = "outer",
      tint = { r = 0.25, g = 0.25, b = 0.25, a = 1 }
    }
  }
}

gui_style.te_tr_last_user_label_container = {
  type = "frame_style",
  parent = "invisible_frame"
}

gui_style.te_tr_last_user_action_container = {
  type = "frame_style",
  parent = "invisible_frame",
  top_padding = 2
}

gui_style.te_tr_move_button = {
  type = "button_style",
  parent = "slot_button",
  width = 20,
  height = 20,
  icon_scale = .5,
  default_graphical_set = {
    base = {
      filename = "__FavoriteTeleport__/graphics/white_slot_button_20.png",
      position = { 0, 0 },
      size = 20,
      scale = 1,
      corner_size = 2,
      draw_type = "outer",
      tint = { r = 0.6, g = 0.6, b = 0.6, a = 1 }
    }
  },
  hovered_graphical_set = {
    base = {
      filename = "__FavoriteTeleport__/graphics/white_slot_button_20.png",
      position = { 0, 0 },
      size = 20,
      scale = 1,
      corner_size = 2,
      draw_type = "outer",
      tint = { r = 0.8, g = 0.8, b = 0.8, a = 1 }
    }
  },
  clicked_graphical_set = {
    base = {
      filename = "__FavoriteTeleport__/graphics/white_slot_button_20.png",
      position = { 0, 0 },
      size = 20,
      scale = 1,
      corner_size = 2,
      draw_type = "outer",
      tint = { r = 1, g = 1, b = 1, a = 1 }
    }
  },
  disabled_graphical_set = {
    base = {
      filename = "__FavoriteTeleport__/graphics/white_slot_button_20.png",
      position = { 0, 0 },
      size = 20,
      scale = 1,
      corner_size = 2,
      draw_type = "outer",
      tint = { r = 0.5, g = 0,5, b = 0,5, a = 1 }
    }
  }
}

gui_style.te_tr_delete_button = {
  type = "button_style",
  parent = "slot_button",
  width = 20,
  height = 20,
  icon_scale = .5,
  default_graphical_set = {
    base = {
      filename = "__FavoriteTeleport__/graphics/red_slot_button_20.png",
      position = { 0, 0 },
      size = 20,
      scale = 1,
      corner_size = 2,
      draw_type = "outer",
      tint = { r = 0.8, g = 0.8, b = 0.8, a = 1 }
    }
  },
  hovered_graphical_set = {
    base = {
      filename = "__FavoriteTeleport__/graphics/red_slot_button_20.png",
      position = { 0, 0 },
      size = 20,
      scale = 1,
      corner_size = 2,
      draw_type = "outer",
      tint = { r = 0.9, g = 0.9, b = 0.9, a = 0 }
    }
  },
  clicked_graphical_set = {
    base = {
      filename = "__FavoriteTeleport__/graphics/red_slot_button_20.png",
      position = { 0, 0 },
      size = 20,
      scale = 1,
      corner_size = 2,
      draw_type = "outer",
      tint = { r = 1, g = 1, b = 1, a = 1 }
    }
  },
  disabled_graphical_set = {
    base = {
      filename = "__FavoriteTeleport__/graphics/red_slot_button_20.png",
      position = { 0, 0 },
      size = 20,
      scale = 1,
      corner_size = 2,
      draw_type = "outer",
      tint = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    }
  }
}
