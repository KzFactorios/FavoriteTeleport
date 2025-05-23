-- tag_editor_GUI_builder/top_row.lua
-- Builds the top row (last user, move/delete buttons) for the tag editor GUI

local TopRow = {}

function TopRow:build(parent, player, chart_tag)
  local top_row_frame = parent.add {
    type = "frame",
    direction = "horizontal",
    name = "te_tr_top_row_frame",
    style = "te_tr_top_row_frame"
  }
  top_row_frame.style.horizontally_stretchable = true
  top_row_frame.style.vertically_stretchable = false
  top_row_frame.style.top_margin = 0
  top_row_frame.style.right_margin = 0
  top_row_frame.style.bottom_margin = 0
  top_row_frame.style.left_margin = 0

  top_row_frame.style.vertical_align = "center"
  top_row_frame.style.top_padding = 0
  top_row_frame.style.right_padding = 0
  top_row_frame.style.left_padding = 0
  top_row_frame.style.bottom_padding = 0
  top_row_frame.style.width = 340
  top_row_frame.style.height = 40

  --- sections...

  local last_user_label_container = top_row_frame.add {
    type = "frame",
    direction = "horizontal",
    style = "te_tr_last_user_label_container"
  }
  last_user_label_container.style.horizontally_stretchable = false
  last_user_label_container.style.vertically_stretchable = false
  last_user_label_container.style.width = 265
  last_user_label_container.style.maximal_width = 265
  last_user_label_container.style.margin = 0
  last_user_label_container.style.padding = 0
  last_user_label_container.style.bottom_padding = 0

  --- The label ties together "last user: <user_name>"

  local last_user_label = last_user_label_container.add {
    type = "label",
    caption = { "ft_tag_editor_last_user", ": " },
  }
  last_user_label.style.horizontally_stretchable = true
  last_user_label.style.font = "default-bold"
  last_user_label.style.font_color = { r = 1, g = 0.901961, b = 0.752941 }

  last_user_label.style.top_margin = 0
  last_user_label.style.right_margin = 0
  last_user_label.style.bottom_margin = 0
  last_user_label.style.left_margin = 8
  
  last_user_label.style.vertical_align = "center"

  local last_user = chart_tag and chart_tag.last_user and chart_tag.last_user.name or ""
  local last_user_value_label = last_user_label_container.add {
    type = "label",
    caption = last_user,
  }
  last_user_value_label.style.horizontally_stretchable = false
  last_user_value_label.style.font = "default-bold"
  last_user_value_label.style.font_color = { r = 1, g = 0.901961, b = 0.752941 }
  last_user_value_label.style.top_margin = 0
  last_user_value_label.style.left_margin = 4
  last_user_value_label.style.vertical_align = "center"
  last_user_value_label.style.horizontal_align = "left"

  --- end of the last user label

  local last_user_action_container = top_row_frame.add {
    type = "frame",
    direction = "horizontal",
    style = "te_tr_last_user_action_container"
  }
  last_user_action_container.style.horizontally_stretchable = true
  last_user_action_container.style.vertically_stretchable = false
  last_user_action_container.style.width = 65
  last_user_action_container.style.maximal_width = 65
  last_user_action_container.style.top_margin = -2
  last_user_action_container.style.right_margin = 8
  last_user_action_container.style.bottom_margin = 0
  last_user_action_container.style.left_margin = 0

  last_user_action_container.style.right_padding = 8

  last_user_action_container.style.horizontal_align = "right"

  -- leave the following for debugging
  local move_btn_enabled = true
  --[[if chart_tag and chart_tag.last_user and chart_tag.last_user == player.name then
    move_btn_enabled = true
  end]]
  local move_btn = last_user_action_container.add {
    type = "sprite-button",
    name = "ft_tag_editor_move_btn",
    sprite = "ft_move_tag_icon",
    style = "te_tr_move_button",
    tooltip = { "ft_tag_editor_move_tooltip_enhanced" },
    enabled = move_btn_enabled,
    icon_scale = 0.8
  }
  move_btn.style.width = 16
  move_btn.style.height = 16
  move_btn.style.padding = 0
  move_btn.style.top_margin = 0
  move_btn.style.right_margin = 12
  move_btn.style.bottom_margin = 0
  move_btn.style.left_margin = 0

  -- leave the following for debugging
  local delete_btn_enabled = true
  --[[if chart_tag and chart_tag.last_user and chart_tag.last_user == player.name then
    delete_btn_enabled = true
  end]]
  local delete_btn = last_user_action_container.add {
    type = "sprite-button",
    name = "ft_tag_editor_delete_btn",
    sprite = "utility/trash",
    style = "te_tr_delete_button",
    tooltip = { "ft_tag_editor_delete_tooltip" },
    enabled = delete_btn_enabled,
    icon_scale = 0.8
  }
  delete_btn.style.width = 16
  delete_btn.style.height = 16
  delete_btn.style.padding = 0
  delete_btn.style.top_margin = 0
  delete_btn.style.right_margin = 0
  delete_btn.style.bottom_margin = 0
  delete_btn.style.left_margin = 0

  return top_row_frame
end

return TopRow
