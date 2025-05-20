-- tag_editor_GUI_builder/top_row.lua
-- Builds the top row (last user, move/delete buttons) for the tag editor GUI

local TopRow = {}

function TopRow.build(parent, player, context)
  local top_row_frame = parent.add {
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

  local last_user_label = last_user_container.add {
    type = "label",
    caption = { "ft_tag_editor_last_user", ": " },
  }
  last_user_label.style.horizontally_stretchable = false
  last_user_label.style.font = "default-bold"
  last_user_label.style.font_color = { r = 1, g = 0.901961, b = 0.752941 }
  last_user_label.style.top_margin = 2
  last_user_label.style.left_margin = 8
  last_user_label.style.right_margin = 0
  last_user_label.style.vertical_align = "center"

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
  last_user_value_label.style.font_color = { r = 1, g = 0.901961, b = 0.752941 }
  last_user_value_label.style.top_margin = 2
  last_user_value_label.style.left_margin = 4
  last_user_value_label.style.vertical_align = "center"
  last_user_value_label.style.horizontal_align = "left"

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
    enabled = false
  }
  move_btn.style.width = 24
  move_btn.style.height = 24
  move_btn.style.left_margin = -2
  move_btn.style.right_margin = 0
  move_btn.style.top_margin = -2
  move_btn.style.bottom_margin = 0
  move_btn.style.padding = 2

  local delete_btn = top_row_frame.add {
    type = "sprite-button",
    name = "ft_tag_editor_delete_btn",
    sprite = "utility/trash",
    style = "frame_action_button",
    tooltip = { "ft_tag_editor_delete_tooltip" }
  }
  delete_btn.style.left_margin = 2
  delete_btn.style.right_margin = 0

  return top_row_frame
end

return TopRow
