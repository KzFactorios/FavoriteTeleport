-- tag_editor_GUI_builder/fields.lua
-- Field builder helpers for tag editor GUI

local Fields = {}

function Fields.create_text_field(parent, name, text, style)
  return parent.add{
    type = "textfield",
    name = name,
    text = text or "",
    style = style or "ft_textfield"
  }
end

function Fields.create_icon_picker(parent, name, icon, style)
  return parent.add{
    type = "choose-elem-button",
    name = name,
    elem_type = "signal",
    signal = icon or nil,
    style = style or "ft_icon_picker_button"
  }
end

-- Add more field builders as needed

return Fields
