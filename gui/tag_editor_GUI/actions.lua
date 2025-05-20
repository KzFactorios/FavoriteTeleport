-- actions.lua
-- Tag editor GUI action handlers for FavoriteTeleport

local TagEditorGUIActions = {}
local Storage = require("core.storage")
local Helpers = require("core.utils.helpers")
local MapTag = require("core.map_tag")

function TagEditorGUIActions.handle_confirm(TagEditorGUI, player)
  if not player then return end
  local frame = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "ft_tag_editor_frame")
  if not frame then player.print("[DEBUG] No tag editor frame found"); return end

  -- Always retrieve position from Storage (source of truth)
  local current_position = TagEditorGUI.get_current_position(player)
  if not current_position or type(current_position) ~= "table" or current_position.x == nil or current_position.y == nil then
    player.print("[DEBUG] No valid current_position in Storage"); return
  end

  -- Validate position before use
  if not Helpers.is_valid_map_position(current_position) then
    return
  end

  -- Use current_position for all downstream logic
  local gps = Helpers.format_gps(current_position.x, current_position.y, player.surface.index)

  -- Extract GUI values using shared helpers
  local input = TagEditorGUI.get_gui_input(frame, player)

  -- Validate inputs (position, icon, text, description)
  local TagEditorGUIValidation = require("gui.tag_editor_GUI.validation")
  local valid, new_text, new_description = TagEditorGUIValidation.validate_inputs(current_position, input.icon, input.text, input.description, player)
  if not valid then
    return
  end

  -- Find or create chart_tag
  local chart_tag = TagEditorGUI.find_create_chart_tag_on_confirm(player, gps, input)
  if not chart_tag then
    TagEditorGUI.close(player); return
  end

  -- MapTag creation/update
  local map_tag = TagEditorGUI.find_create_map_tag_on_confirm(player, gps, chart_tag, input)

  -- Favorite logic
  if not not input.is_favorite then
    TagEditorGUI.update_favorite(player, gps)
  else
    TagEditorGUI.remove_favorite(player, gps)
  end
  
  if Storage.save_data then Storage.save_data(Storage.get()) end

  TagEditorGUI.close(player)
end

return TagEditorGUIActions
