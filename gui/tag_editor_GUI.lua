--- tag_editor_GUI.lua
--- Handles the tag editor dialog for FavoriteTeleport mod

--[[
  Static analysis suppressions:
  Some if-statements in this file are flagged as 'impossible' or 'unnecessary' by static analysis tools.
  These are required for runtime correctness in Factorio multiplayer and migration scenarios.
  See comments above each such block for details.
]]

local TagEditorGUI = {}
local Constants = require("constants")
local Helpers = require("core.utils.helpers")
local Storage = require("core/storage")
local TagEditorGUIBuilder = require("gui/tag_editor_GUI_builder")
local TagEditorGUIValidation = require("gui/tag_editor_GUI_validation")
local TagEditorGUIEvents = require("gui/tag_editor_GUI_events")

-- Helper: Find a tag by gps in a tag list
local function find_tag_by_gps(tag_list, gps)
  for idx, tag in pairs(tag_list) do
    if tag.gps == gps then
      return tag, idx
    end
  end
  return nil, nil
end

-- Helper: Remove a favorite from all players on a surface (uses robust access)
local function remove_favorite_from_all_players(surface_index, gps)
  local storage = Storage.get()
  for pidx, pdata in pairs(storage.players) do
    local surf = pdata[surface_index]
    --[[@diagnostic disable-next-line: unreachable-code]]
    if surf and surf.favorites then -- Required for multiplayer/migration safety
      for slot, fav in pairs(surf.favorites) do
        if fav and fav.gps == gps then
          surf.favorites[slot] = nil
        end
      end
    end
  end
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

TagEditorGUI.open = TagEditorGUIBuilder.open
TagEditorGUI.close = TagEditorGUIBuilder.close
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

  -- Gather input values
  local gps = frame.ft_tag_editor_teleport_row.ft_tag_editor_pos_btn.caption
  local icon_picker = frame.ft_tag_editor_icon_row["tag-editor-icon"]
  local icon = icon_picker and icon_picker.elem_value
  local text_box = frame.ft_tag_editor_text_row.ft_tag_editor_textbox
  local desc_box = frame.ft_tag_editor_desc_row.ft_tag_editor_descbox
  local text = text_box and (text_box.text or ""):gsub("^%s*(.-)%s*$", "%1") or ""
  local description = desc_box and (desc_box.text or ""):gsub("^%s*(.-)%s*$", "%1") or ""
  local favorite_btn = frame.ft_tag_editor_favorite_row.ft_tag_editor_favorite_btn
  local is_favorite = favorite_btn and favorite_btn.sprite and favorite_btn.sprite ~= "" or false
  local favorite_slots_unavailable = false

  -- Validation
  if not TagEditorGUIValidation.validate_inputs(icon, text, description, player) then
    return
  end

  -- Favorite slot logic
  local slot = nil
  --[[@diagnostic disable-next-line: unreachable-code]]
  if is_favorite then -- Required for runtime: GUI state can change
    slot = TagEditorGUI.get_next_available_favorite_slot(player)
    if not slot then
      is_favorite = false
      favorite_slots_unavailable = true
    end
  end

  -- Find or create chart_tag
  local chart_tags = Storage.get_chart_tags(player)
  local found_tag, found_idx = find_tag_by_gps(chart_tags, gps)
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
      player.print{"FavoriteTeleport.ft_tag_editor_error_chart_tag_failed"}
      TagEditorGUI.close(player)
      return
    end
    table.insert(chart_tags, {gps=gps, tag=chart_tag, last_user=player.name})
    Storage.get().surfaces[surface_index].chart_tags = nil -- Invalidate cache
  else
    chart_tag = found_tag.tag
    if found_tag.last_user ~= player.name then
      player.print{"FavoriteTeleport.ft_tag_editor_error_not_last_user"}
      return
    end
    chart_tag.icon = icon
    chart_tag.text = text
    found_tag.last_user = player.name
    Storage.get().surfaces[surface_index].chart_tags = nil -- Invalidate cache
  end

  -- MapTag creation/update
  local map_tags = Storage.get_map_tags(player)
  local map_tag, map_idx = find_tag_by_gps(map_tags, gps)
  if not map_tag then
    map_tag = {
      gps = gps,
      faved_by_players = {},
      description = description
    }
    table.insert(map_tags, map_tag)
  else
    map_tag.description = description
  end

  -- Favorite logic
  local favorites = Storage.get_player_favorites(player)
  --[[@diagnostic disable-next-line: unreachable-code]]
  if is_favorite and slot then -- Required for runtime: user may toggle favorite
    favorites[slot] = {
      surface_index = surface_index,
      gps = gps,
      map_tag = map_tag,
      slot_locked = false
    }
    -- Add to faved_by_players if not already present
    local already_faved = false
    for _, idx in ipairs(map_tag.faved_by_players) do
      if idx == player_index then already_faved = true; break end
    end
    if not already_faved then
      table.insert(map_tag.faved_by_players, player_index)
    end
  else
    -- Remove from favorites if present
    for i, fav in pairs(favorites) do
      if fav and fav.gps == gps then
        favorites[i] = {
          surface_index = surface_index,
          gps = "",
          map_tag = nil,
          slot_locked = false
        }
      end
    end
    -- Remove from faved_by_players
    for i=#map_tag.faved_by_players,1,-1 do
      if map_tag.faved_by_players[i] == player_index then
        table.remove(map_tag.faved_by_players, i)
      end
    end
    Storage.get().surfaces[surface_index].chart_tags = nil -- Invalidate cache after removal
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
    local found_tag, found_idx = find_tag_by_gps(chart_tags, gps)
    --[[@diagnostic disable-next-line: unreachable-code]]
    if found_tag then -- Required for runtime: tag may not exist
      --[[@diagnostic disable-next-line: unreachable-code]]
      if found_tag.created_by ~= player.name then
        player.print{"FavoriteTeleport.ft_tag_editor_error_not_creator"}
        return
      end
      --[[@diagnostic disable-next-line: unreachable-code]]
      if found_tag.last_user ~= player.name then
        player.print{"FavoriteTeleport.ft_tag_editor_error_not_last_user"}
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
      local map_tag, map_idx = find_tag_by_gps(map_tags, gps)
      --[[@diagnostic disable-next-line: unreachable-code]]
      if map_tag and map_idx then
        table.remove(map_tags, map_idx)
      end
      remove_favorite_from_all_players(surface_index, gps)
      Storage.get().surfaces[surface_index].chart_tags = nil
      if Storage.save_data then Storage.save_data(Storage.get()) end
      player.print{"FavoriteTeleport.ft_tag_editor_deleted"}
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
    player.print{"FavoriteTeleport.ft_tag_editor_move_mode_active"}
    TagEditorGUI.close(player)
    return
  end
end

return TagEditorGUI
