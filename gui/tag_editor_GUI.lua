--- tag_editor_GUI.lua
--- Handles the tag editor dialog for FavoriteTeleport mod

--[[
  Static analysis suppressions:
  Some if-statements in this file are flagged as 'impossible' or 'unnecessary' by static analysis tools.
  These are required for runtime correctness in Factorio multiplayer and migration scenarios.
  See comments above each such block for details.
]]

local TagEditorGUI = {}
TagEditorGUI.current_position = nil -- Stores the current MapPosition for the open tag editor
local Constants = require("constants")
local Helpers = require("core.utils.helpers")
local Storage = require("core.storage")
local TagEditorGUIBuilder = require("gui/tag_editor_GUI_builder")
local TagEditorGUIValidation = require("gui/tag_editor_GUI_validation")
local TagEditorGUIEvents = require("gui/tag_editor_GUI_events")

-- Helper: Find a map tag by gps in a tag list
local function find_map_tag_by_gps(tag_list, gps)
  for idx, tag in pairs(tag_list) do
    if tag.gps == gps then
      return tag, idx
    end
  end
  return nil, nil
end

-- Favorite slot helpers using new accessors
TagEditorGUI.get_available_favorite_slots = function(player)
  local favorites = Storage.get_player_favorites(player)
  local max_slots = Constants.MAX_FAVORITE_SLOTS
  local count = 0
  for i = 1, max_slots do
    if not favorites[i] then count = count + 1 end
  end
  return count
end

TagEditorGUI.get_next_available_favorite_slot = function(player)
  local favorites = Storage.get_player_favorites(player)
  local max_slots = Constants.MAX_FAVORITE_SLOTS
  for i = 1, max_slots do
    if not favorites[i] then return i end
  end
  return nil
end

TagEditorGUI.has_available_favorite_slot = function(player)
  local favorites = Storage.get_player_favorites(player)
  local max_slots = Constants.MAX_FAVORITE_SLOTS
  for i = 1, max_slots do
    if not favorites[i] then return true end
  end
  return false
end

TagEditorGUI.open = function(player, position, is_favorite, context)
  TagEditorGUI.current_position = position
  return TagEditorGUIBuilder.open(player, position, is_favorite, context, TagEditorGUI)
end
TagEditorGUI.close = function(player)
  TagEditorGUI.current_position = nil
  return TagEditorGUIBuilder.close(player)
end
TagEditorGUI.add_row = TagEditorGUIBuilder.add_row

TagEditorGUI.on_click = TagEditorGUIEvents.on_click

--- Handles the confirm/save action for the tag editor GUI
-- @param player LuaPlayer
function TagEditorGUI.handle_confirm(player)
  local gui = player.gui.screen
  local frame = gui.ft_tag_editor_outer_frame and gui.ft_tag_editor_outer_frame.ft_tag_editor_frame
  if not frame then return end

  local surface = player.surface
  local surface_index = surface.index
  local player_index = player.index

  -- Use the tracked MapPosition if available
  local map_position = TagEditorGUI.current_position
  if map_position == nil then return end

  -- Fallback to GPS string from GUI if needed
  local gps = Helpers.format_gps(map_position.x, map_position.y, player.surface.index)

  -- Gather input values
  -- TODO add surface data to gps
  local content_frame = frame.ft_tag_editor_content_frame
  local icon_picker = content_frame and content_frame.ft_tag_editor_icon_row and
      content_frame.ft_tag_editor_icon_row["tag-editor-icon"]
  local icon = icon_picker and icon_picker.elem_value
  local text_box = content_frame and content_frame.ft_tag_editor_text_row and
      content_frame.ft_tag_editor_text_row.ft_tag_editor_textbox
  local desc_box = content_frame and content_frame.ft_tag_editor_desc_row and
      content_frame.ft_tag_editor_desc_row.ft_tag_editor_descbox
  local text = text_box and (text_box.text or ""):gsub("^%s*(.-)%s*$", "%1") or ""
  local description = desc_box and (desc_box.text or ""):gsub("^%s*(.-)%s*$", "%1") or ""
  local favorite_btn = content_frame and content_frame.ft_tag_editor_favorite_row and
      content_frame.ft_tag_editor_favorite_row.ft_tag_editor_favorite_btn
  local is_favorite = favorite_btn and favorite_btn.sprite and favorite_btn.sprite ~= "" or false

  -- Validation
  if not TagEditorGUIValidation.validate_inputs(icon, text, description, player) then
    return
  end

  -- Find or create chart_tag
  local chart_tags = Storage.get_chart_tags(player)
  if not chart_tags then return nil end
  local found_tag = Storage.find_chart_tag_by_gps(player, gps)
  local chart_tag
  if not found_tag then
    -- Create new chart tag
    local tag_spec = {
      position = Helpers.gps_to_map_position(gps),
      icon = icon,
      text = text,
      last_user = player.name
    }
    chart_tag = player.force.add_chart_tag(player.surface, tag_spec)
    if not chart_tag then
      player.print { "FavoriteTeleport.ft_tag_editor_error_chart_tag_failed" }
      TagEditorGUI.close(player)
      return
    end
    --table.insert(chart_tags, chart_tag)
  else
    chart_tag = found_tag
    if chart_tag.last_user == player.name then
      chart_tag.icon = icon
      chart_tag.text = text
      chart_tag.last_user = player.name
    end
    -- Storage.reset_chart_tags(player) -- Invalidate cache
  end

  Storage.reset_chart_tags(player) -- Invalidate cache

  -- MapTag creation/update
  local map_tags = Storage.get_map_tags(player)
  local map_tag = Storage.find_map_tag_by_gps(gps)
  if not map_tag then
    map_tag = {
      gps = gps,
      faved_by_players = {},
      description = description
    }
    table.insert(map_tags, map_tag)
  else -- update the existing map_tag
    map_tag.gps = gps
    -- if is favorite and the player's index is not in the array...
    local is_in_array, idx_slot = Helpers.index_is_in_table(map_tag.faved_by_players, player.index)
    if is_favorite and not is_in_array then
      table.insert(map_tag.faved_by_players, player_index)
    elseif not is_favorite and is_in_array then
      table.remove(map_tag.faved_by_players, idx_slot)
    end
    map_tag.description = description
  end

  -- Favorite logic
  local slot = nil
  local favorites = Storage.get_player_favorites(player)
  -- see if the favorite already exists - match by map_tag.gps
  local existing_favorite, existing_idx = Helpers.find_by_predicate(favorites, function(v) return v.gps == gps end) or
      nil, -1

  -- if is_favorite, make sure we have the favorite in the collection
  -- if not, make sure that there is no favorite for that location
  if not existing_favorite then
    if is_favorite then -- Required for runtime: GUI state can change
      slot = TagEditorGUI.get_next_available_favorite_slot(player)
      if not slot then
        is_favorite = false
      else
        favorites[slot] = {
          gps = gps,
          slot_locked = false
        }
      end
    end
  else
    if not is_favorite then
      table.remove(favorites, existing_idx)
    end
  end

  if Storage.save_data then Storage.save_data(Storage.get()) end
  TagEditorGUI.close(player)
end

--- Handles tag editor actions (confirm, delete, move)
-- @param player LuaPlayer
-- @param action string
function TagEditorGUI.handle_action(player, action)
  local gui = player.gui.screen
  local frame = gui.ft_tag_editor_outer_frame and gui.ft_tag_editor_outer_frame.ft_tag_editor_frame
  if not frame then return end

  local surface = player.surface
  local surface_index = surface.index
  local player_index = player.index

  if action == "confirm" then
    TagEditorGUI.handle_confirm(player)
  elseif action == "delete" then
    local gps = frame.ft_tag_editor_teleport_row.ft_tag_editor_pos_btn.caption
    local chart_tags = Storage.get_chart_tags(player)
    local found_tag, found_idx = Storage.find_chart_tag_by_gps(player, gps)
    --[[@diagnostic disable-next-line: unreachable-code]]
    if found_tag then -- Required for runtime: tag may not exist
      --[[@diagnostic disable-next-line: unreachable-code]]
      if found_tag.created_by ~= player.name then
        player.print { "FavoriteTeleport.ft_tag_editor_error_not_creator" }
        return
      end
      --[[@diagnostic disable-next-line: unreachable-code]]
      if found_tag.last_user ~= player.name then
        player.print { "FavoriteTeleport.ft_tag_editor_error_not_last_user" }
        return
      end
      --[[@diagnostic disable-next-line: unreachable-code]]
      if found_tag.tag and found_tag.tag.valid then
        found_tag.tag.destroy()
      end
      --[[@diagnostic disable-next-line: unreachable-code]]
      if chart_tags and found_idx then
        chart_tags[found_idx] = nil
      end
      local map_tags = Storage.get_map_tags(player)
      local map_tag, map_idx = Storage.find_map_tag_by_gps(player, gps)
      --[[@diagnostic disable-next-line: unreachable-code]]
      if map_tag and map_idx then
        table.remove(map_tags, map_idx)
      end
      
      Storage.reset_chart_tags(player)
      if Storage.save_data then Storage.save_data(Storage.get()) end
      player.print { "FavoriteTeleport.ft_tag_editor_deleted" }
      TagEditorGUI.close(player)
    end
    return
  elseif action == "move" then
    local storage = Storage.get()
    storage.ft_tag_editor_move_mode = storage.ft_tag_editor_move_mode or {}
    storage.ft_tag_editor_move_mode[player.index] = {
      active = true,
      surface_index = player.surface.index,
      gps = frame.ft_tag_editor_teleport_row.ft_tag_editor_pos_btn.caption
    }
    if Storage.save_data then Storage.save_data(storage) end
    player.print { "FavoriteTeleport.ft_tag_editor_move_mode_active" }
    TagEditorGUI.close(player)
    return
  end
end

-- Helper: update the confirm/save <button> state and tooltip in the tag editor
function TagEditorGUI.update_save_btn(player)
  if not player then return end
  local gui = player.gui.screen
  local outer = gui.ft_tag_editor_outer_frame
  if not outer then return end
  local frame = outer.ft_tag_editor_frame
  if not frame then return end
  -- Corrected: descend into content_frame for row lookups
  local content_frame = frame.ft_tag_editor_content_frame
  if not content_frame then return end
  local action_row = outer.ft_tag_editor_action_row
  local save_btn = action_row and action_row.ft_tag_editor_save_btn
  local text_row = content_frame.ft_tag_editor_text_row
  local text_box = text_row and text_row.ft_tag_editor_textbox
  local icon_row = content_frame.ft_tag_editor_icon_row
  local icon_picker = icon_row and icon_row["tag-editor-icon"]
  if not save_btn then return end
  local text_val = text_box and text_box.text and text_box.text:match("%S")
  local icon_val = icon_picker and icon_picker.elem_value
  local icon_selected = false
  if icon_val then
    if type(icon_val) == "table" then
      icon_selected = icon_val.name ~= nil and icon_val.name ~= ""
    elseif type(icon_val) == "string" then
      icon_selected = icon_val ~= ""
    end
  end
  save_btn.enabled = (text_val ~= nil) or icon_selected
  if save_btn.enabled then
    save_btn.tooltip = ""
  else
    save_btn.tooltip = { "ft_tag_editor_save_tooltip" }
  end
end

return TagEditorGUI
