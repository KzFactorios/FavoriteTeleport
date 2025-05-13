local PREFIX = require("constants").PREFIX

---@diagnostic disable-next-line: undefined-global
local gui_style = data.raw["gui-style"].default

gui_style[PREFIX .. "toggle_favorite_mode_button"] = {
  type = "button_style",
  parent = "slot_button",
  width = 36,
  height = 36,
  top_margin = 2,
  background_color = { 1, 0, 0 },
  default_graphical_set = {
    base = {
      position = { 64, 0 },
      width = 32,
      height = 32,
      scale = 1.0,
      filename = "__base__/graphics/icons/signal/signal-heart.png",

    },
  }
}