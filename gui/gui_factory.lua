local Helpers = require("core.utils.helpers")
local GuiFactory = {}

function GuiFactory.create_button(parent, name, caption, style)
  return parent.add{
    type = "button",
    name = name,
    caption = caption,
    style = style or "button"
  }
end

function GuiFactory.create_frame(parent, name, direction, style)
  return parent.add{
    type = "frame",
    name = name,
    direction = direction or "horizontal",
    style = style or "frame"
  }
end

function GuiFactory.create_label(parent, name, caption, style)
  return parent.add{
    type = "label",
    name = name,
    caption = caption,
    style = style or "label"
  }
end

function GuiFactory.create_favorite_slot(parent, slot_index, favorite)
  local icon = (favorite and favorite.icon) or "utility/slot_icon_module"
  local tooltip = "Slot " .. tostring(slot_index)
  if favorite and type(favorite) == "table" and (favorite.gps or "") ~= "" then
    local t = Helpers.format_favorite_tooltip(favorite)
    tooltip = (t and type(t) == "string" and t ~= "") and t or tooltip
  else
    tooltip = tooltip .. "\nEmpty Slot"
  end
  return parent.add{
    type = "sprite-button",
    name = "ft_fave_slot_" .. slot_index,
    sprite = icon,
    tooltip = tooltip,
    style = "slot_button"
  }
end

return GuiFactory
