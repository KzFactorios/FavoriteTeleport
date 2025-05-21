-- actions.lua
-- Tag editor GUI action handlers for FavoriteTeleport

local TagEditorGUIActions = {}
local Storage = require("core.storage.init")
local Helpers = require("core.utils.helpers")
local MapTag = require("core.map_tag")
local TagEditorGUIValidation = require("gui.tag_editor_GUI.validation")
local ChartTagOps = require("gui.tag_editor_GUI.chart_tag_ops")

function TagEditorGUIActions.handle_confirm(TagEditorGUI, player)
  if not player then return end
  local frame = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "ft_tag_editor_frame")
  if not frame then player.print("[FavoriteTeleport] Error: No tag editor frame found"); return end

  -- Always retrieve position from Storage (source of truth)
  local current_position = TagEditorGUI.get_current_position(player)
  if not current_position or type(current_position) ~= "table" or current_position.x == nil or current_position.y == nil then
    player.print("[FavoriteTeleport] Error: No valid position for tag"); return
  end

  -- Validate position before use
  if not Helpers.is_valid_map_position(current_position) then
    player.print("[FavoriteTeleport] Error: Invalid map position"); return
  end

  local gps = Helpers.format_gps(current_position.x, current_position.y, player.surface.index)
  local input = TagEditorGUI.get_gui_input(frame, player)

  -- Hide error label by default
  if input.error_label then
    input.error_label.caption = ""
    input.error_label.visible = false
  end

  -- Validate inputs (position, icon, text)
  local valid, new_text, error_msg = TagEditorGUIValidation.validate_inputs(current_position, input.icon, input.text, player)
  if not valid then
    if input.error_label then
      input.error_label.caption = error_msg or "[FavoriteTeleport] Error: Invalid input. Please enter text or select an icon."
      input.error_label.visible = true
    else
      player.print(error_msg or "[FavoriteTeleport] Error: Invalid input. Please enter text or select an icon.")
    end
    return
  end

  -- Find or create chart_tag
  local chart_tag = TagEditorGUI.find_create_chart_tag_on_confirm(player, gps, input)
  if not chart_tag then
    if input.error_label then
      input.error_label.caption = "[FavoriteTeleport] Error: Could not create or update map tag."
      input.error_label.visible = true
    else
      player.print("[FavoriteTeleport] Error: Could not create or update map tag.")
    end
    return
  end

  -- update any chart tag info text/position
  chart_tag = ChartTagOps.update_chart_tag(player, chart_tag, input, current_position)

  -- MapTag creation/update
  local map_tag = TagEditorGUI.find_create_map_tag_on_confirm(player, gps, chart_tag, input)

  -- Favorite logic
  if input.is_favorite then
    TagEditorGUI.update_favorite(player, gps)
  else
    TagEditorGUI.remove_favorite(player, gps)
  end

  if Storage.save_data then Storage.save_data(Storage.get()) end

  TagEditorGUI.close(player)
end

return TagEditorGUIActions
