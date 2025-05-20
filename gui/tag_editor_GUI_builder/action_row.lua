-- tag_editor_GUI_builder/action_row.lua
-- Builds the action row (save button, drag handle) for the tag editor GUI

local ActionRow = {}

function ActionRow.build(parent, outer_frame)
  local action_row = parent.add { type = "flow", direction = "horizontal", name = "ft_tag_editor_action_row" }
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
  return action_row, save_btn
end

return ActionRow
