-- tag_editor_GUI_builder/content_frame.lua
-- Builds the main content frame (rows for teleport, favorite, icon, text, desc)

local ContentFrame = {}
local Rows = require("gui.tag_editor_GUI_builder.rows")
local Helpers = require("core.utils.helpers")
local Cache = require("core.cache.init")

function ContentFrame.build(parent, builder)
  local content_frame = parent.add {
    type = "frame",
    name = "ft_tag_editor_content_frame",
    direction = "vertical",
    style = "inside_shallow_frame_with_padding"
  }
  content_frame.style.padding = 16
  content_frame.style.horizontally_stretchable = true
  content_frame.style.vertically_stretchable = true

  Rows.add_row(content_frame, "ft_tag_editor_teleport_row", { "ft_tag_editor_teleport" },
    "te_tr_teleport_label", {
      type = "button",
      name = "ft_tag_editor_pos_btn",
      caption = builder.gps,
      tooltip = { "ft_tag_editor_teleport_tooltip", tostring(builder.gps) },
      --tooltip = "Teleport to " .. tostring(builder.gps),
      style = "ft_teleport_button"
    })

  local available_slots = Cache.get_available_favorite_slots_count(builder.player)
  local faved = builder.map_tag and builder.map_tag:is_player_favorite(builder.player) or false
  local favorite_enabled = (available_slots > 0) or faved

  Rows.add_row(content_frame, "ft_tag_editor_favorite_row", { "ft_tag_editor_favorite_label" },
    "te_tr_favorite_label", {
      type = "sprite-button",
      name = "ft_tag_editor_favorite_btn",
      sprite = faved and "utility/check_mark_green" or nil,
      tooltip = { "ft_tag_editor_favorite_tooltip" },
      style = "ft_favorite_button",
      enabled = favorite_enabled
    }, { top_margin = 8 })

  Rows.add_row(content_frame, "ft_tag_editor_icon_row", { "ft_tag_editor_icon" }, "te_tr_icon_label", {
    type = "choose-elem-button",
    name = "tag-editor-icon",
    elem_type = "signal",
    signal = builder.chart_tag and builder.chart_tag.icon or nil,
    tooltip = { "ft_tag_editor_icon_tooltip" },
    style = "ft_icon_picker_button"
  }, { top_margin = 8 })

  Rows.add_row(content_frame, "ft_tag_editor_text_row", { "ft_tag_editor_text" }, "te_tr_text_label", {
    type = "textfield",
    name = "ft_tag_editor_textbox",
    text = builder.chart_tag and builder.chart_tag.text or "",
    clear_and_focus_on_right_click = true,
    tooltip = { "ft_tag_editor_text_tooltip" },
    style = "ft_textfield"
  }, { top_margin = 8 })

  -- Error label row (hidden by default)
  local error_row = Rows.add_row(content_frame, "ft_tag_editor_error_row", { "ft_tag_editor_error_label" },
    "te_tr_error_label", {
    type = "label",
    name = "ft_tag_editor_error_label",
    caption = "",
    style = "label",
    visible = false
  }, { top_margin = 8 })

  return content_frame
end

return ContentFrame
