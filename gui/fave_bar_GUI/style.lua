-- style.lua
-- Styling and theme helpers for the favorites bar GUI

local Style = {}

function Style.apply_bar_style(bar)
  bar.style.horizontally_stretchable = "on"
  bar.style.vertically_stretchable = "off"
  bar.style.maximal_height = 48
  bar.style.minimal_height = 32
  bar.style.maximal_width = 1200
  bar.style.minimal_width = 320
  bar.style.padding = 2
  bar.style.margin = 2
  bar.style.use_header_filler = true
  bar.style.top_margin = 4
  bar.style.bottom_margin = 4
  bar.style.horizontal_spacing = 8
  bar.style.vertical_align = "center"
  bar.style.horizontal_align = "center"
  bar.style.single_line = true
  bar.style.graphical_set = {
    base = { position = {0, 0}, corner_size = 8, center = { width = 1, height = 1, tint = { r = 0.1, g = 0.1, b = 0.1, a = 0.95 } }, draw_type = "outer" }
  }
end

function Style.apply_label_style(label)
  label.style.font = "default-bold"
  label.style.font_color = { r = 1, g = 0.85, b = 0.2 }
  label.style.top_padding = 2
  label.style.bottom_padding = 2
  label.style.left_padding = 4
  label.style.right_padding = 8
end

function Style.apply_toggle_button_style(button)
  button.style.font = "default-large-bold"
  button.style.font_color = { r = 1, g = 0.2, b = 0.2 }
  button.style.width = 32
  button.style.height = 32
  button.style.top_margin = 0
  button.style.left_margin = 0
end

function Style.apply_slot_button_style(btn, fav)
  btn.style.font = "default-bold"
  btn.style.font_color = fav and fav.slot_locked and {r=0.7,g=0.7,b=0.7} or {r=1,g=1,b=1}
  btn.enabled = not (fav and fav.slot_locked)
  btn.style.horizontal_align = "center"
  btn.style.vertical_align = "center"
  btn.style.padding = 0
  btn.style.margin = 0
  btn.style.height = 36
  btn.style.width = 36
  btn.style.stretch_image_to_widget_size = true
  btn.style.hovered_graphical_set = { base = { position = {0, 0}, corner_size = 8, center = { width = 1, height = 1, tint = { r = 0.2, g = 0.2, b = 0.2, a = 1.0 } }, draw_type = "outer" } }
  btn.style.clicked_graphical_set = { base = { position = {0, 0}, corner_size = 8, center = { width = 1, height = 1, tint = { r = 0.3, g = 0.3, b = 0.3, a = 1.0 } }, draw_type = "outer" } }
end

return Style
