--- tag_editor_GUI.lua
--- Handles the tag editor dialog for FavoriteTeleport mod

local Constants = require("constants")
local Helpers = require("core.utils.helpers")
local Storage = require("core.storage")
local TagEditorGUIBuilder = require("gui.tag_editor_GUI_builder")
local TagEditorGUIValidation = require("gui.tag_editor_GUI_validation")
local TagEditorGUIEvents = require("gui.tag_editor_GUI_events")
local GuiBase = require("gui.gui_base")
local MapTag = require("core.map_tag")

local TagEditorGUI = {}
TagEditorGUI.current_position = nil -- Stores the current MapPosition for the open tag editor

TagEditorGUI.open = function(player, position, context)
  if Storage.set_tag_editor_position then
    Storage.set_tag_editor_position(player, position)
  end
  return TagEditorGUIBuilder.open(player, position, context, TagEditorGUI)
end

TagEditorGUI.get_current_position = function(player)
  if Storage.get_tag_editor_position then
    return Storage.get_tag_editor_position(player)
  end
  return nil
end

TagEditorGUI.close = function(player)
  if Storage.clear_tag_editor_position then
    Storage.clear_tag_editor_position(player)
  end
  return TagEditorGUIBuilder.close(player)
end

TagEditorGUI.add_row = TagEditorGUIBuilder.add_row
TagEditorGUI.on_click = TagEditorGUIEvents.on_click

--- Extracts icon, text, description, and favorite state from the tag editor GUI
-- @param frame LuaGuiElement (ft_tag_editor_frame)
-- @return table {icon, text, description, is_favorite, favorite_btn, icon_picker, text_box, desc_box}
function TagEditorGUI.get_gui_input(frame, player)
  local content_frame = frame.ft_tag_editor_content_frame
  local icon_picker = GuiBase.find_by_path(content_frame, {"ft_tag_editor_icon_row", "tag-editor-icon"})
  local favorite_btn = GuiBase.find_by_path(content_frame, {"ft_tag_editor_favorite_row", "ft_tag_editor_favorite_btn"})
  local text_box = GuiBase.find_by_path(content_frame, {"ft_tag_editor_text_row", "ft_tag_editor_textbox"})
  local desc_box = GuiBase.find_by_path(content_frame, {"ft_tag_editor_desc_row", "ft_tag_editor_descbox"})
  local icon = icon_picker and icon_picker.elem_value or nil
  local text = text_box and (text_box.text or ""):gsub("^%s*(.-)%s*$", "%1") or ""
  local description = desc_box and (desc_box.text or ""):gsub("^%s*(.-)%s*$", "%1") or ""
  local is_favorite = (favorite_btn and favorite_btn.sprite and favorite_btn.sprite ~= "")
  return {
    icon = icon,
    text = text,
    description = description,
    is_favorite = is_favorite,
    favorite_btn = favorite_btn,
    icon_picker = icon_picker,
    text_box = text_box,
    desc_box = desc_box
  }
end

--- Finds or creates a chart tag for the given gps and input, updating if needed
-- @param player LuaPlayer
-- @param gps string
-- @param input table (from get_gui_input)
-- @return chart_tag (LuaCustomChartTag)
function TagEditorGUI.find_create_chart_tag_on_confirm(player, gps, input)
  local chart_tag = Storage.find_chart_tag_by_gps(player, gps)
  if not chart_tag then
    local tag_spec = {
      position = Helpers.gps_to_map_position(gps),
      icon = input.icon or {},
      text = input.text,
      last_user = player.name
    }
    chart_tag = player.force.add_chart_tag(player.surface, tag_spec)
    if not chart_tag then
      player.print { "FavoriteTeleport.ft_tag_editor_error_chart_tag_failed" }
      return nil
    end
  elseif chart_tag.last_user == player.name then
    chart_tag.icon = input.icon or {}
    chart_tag.text = input.text
    chart_tag.last_user = player.name
  end
  Storage.reset_chart_tags(player)
  return Storage.find_chart_tag_by_gps(player, gps)
end

--- Finds or creates a map tag for the given gps and input, updating if needed
-- @param player LuaPlayer
-- @param gps string
-- @param chart_tag LuaCustomChartTag
-- @param input table (from get_gui_input)
-- @return map_tag (MapTag)
function TagEditorGUI.find_create_map_tag_on_confirm(player, gps, chart_tag, input)
  local map_tag = Storage.find_map_tag_by_gps(player, gps)
  local is_favorite = not not input.is_favorite
  local safe_chart_tag = chart_tag or player.force.add_chart_tag(player.surface, { position = Helpers.simplify_position(TagEditorGUI.current_position), icon = {}, text = "", last_user = player.name })
  local simple_position = Helpers.simplify_position(TagEditorGUI.get_current_position(player))
  
  if not map_tag then
    map_tag = MapTag.new(player, simple_position, safe_chart_tag, is_favorite, input.description)
  else
    map_tag.gps = gps
    map_tag.description = input.description
    map_tag.chart_tag = chart_tag
  end
  if map_tag then
    map_tag.faved_by_players = map_tag.faved_by_players or {}
    local is_in, t_idx = Helpers.index_is_in_table(map_tag.faved_by_players, player.index)
    if is_favorite and not is_in then
      table.insert(map_tag.faved_by_players, player.index)
    end
    Storage.add_or_update_map_tag(player, map_tag)
  end
  return map_tag
end

--- Handles the confirm/save action for the tag editor GUI
-- @param player LuaPlayer
function TagEditorGUI.handle_confirm(player)
  if not player then return end
  local gui = player.gui.screen
  local frame = gui.ft_tag_editor_outer_frame and gui.ft_tag_editor_outer_frame.ft_tag_editor_frame
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

--- Updates or adds a favorite for the given player and gps. Also updates all map_tag objects for all players if needed.
-- @param player LuaPlayer
-- @param gps string
-- @param slot_locked boolean|nil (optional, default false)
function TagEditorGUI.update_favorite(player, gps, slot_locked)
  slot_locked = slot_locked or false
  local favorites = Storage.get_player_favorites(player)
  local existing_favorite, existing_idx = Helpers.find_by_predicate(favorites, function(v) return v.gps == gps end)
  if not existing_favorite then
    local slot = Storage.get_next_available_favorite_slot(player)
    if slot then
      favorites[slot] = { gps = gps, slot_locked = slot_locked }
    end
  end
  -- Update all map_tags for all players if this favorite affects shared tags
  for _, other in pairs(_G.game.players) do
    local map_tag = Storage.find_map_tag_by_gps(other, gps)
    if map_tag then
      map_tag.faved_by_players = map_tag.faved_by_players or {}
      local is_in = false
      for _, idx in ipairs(map_tag.faved_by_players) do
        if idx == player.index then is_in = true; break end
      end
      table.insert(map_tag.faved_by_players, player.index)
      Storage.add_or_update_map_tag(other, map_tag)
    end
  end
end

--- Removes a favorite for the given player and gps. Also updates all map_tag objects for all players if needed.
-- @param player LuaPlayer
-- @param gps string
function TagEditorGUI.remove_favorite(player, gps)
  local favorites = Storage.get_player_favorites(player)
  for i, fav in ipairs(favorites) do
    if fav and fav.gps == gps then
      favorites[i] = nil
      break
    end
  end
  -- Update all map_tags for all players if this favorite affects shared tags
  for _, other in pairs(_G.game.players) do
    local map_tag = Storage.find_map_tag_by_gps(other, gps)
    if map_tag then
      -- map_tag.faved_by_players is always a table
      for idx = #map_tag.faved_by_players, 1, -1 do
        if map_tag.faved_by_players[idx] == player.index then
          table.remove(map_tag.faved_by_players, idx)
        end
      end
      Storage.add_or_update_map_tag(other, map_tag)
    end
  end
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
    -- Use the new storage method to destroy the chart tag and remove from storage
    local destroyed = Storage.destroy_chart_tag(player, gps)
    -- Remove map tag if present
    local map_tags = Storage.get_map_tags(player)
    local map_tag, map_idx = Storage.find_map_tag_by_gps(player, gps)
    if map_tag and map_idx then
      table.remove(map_tags, map_idx)
    end
    Storage.reset_chart_tags(player)
    if Storage.save_data then Storage.save_data(Storage.get()) end
    player.print { "FavoriteTeleport.ft_tag_editor_deleted" }
    TagEditorGUI.close(player)
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
  local content_frame = frame.ft_tag_editor_content_frame
  if not content_frame then return end
  local action_row = outer.ft_tag_editor_action_row
  local save_btn = action_row and action_row.ft_tag_editor_save_btn
  local text_box = GuiBase.find_by_path(content_frame, {"ft_tag_editor_text_row", "ft_tag_editor_textbox"})
  local icon_picker = GuiBase.find_by_path(content_frame, {"ft_tag_editor_icon_row", "tag-editor-icon"})
  if not save_btn then return end
  local text_val = text_box and text_box.text and text_box.text:match("%S")
  local icon_val = icon_picker and icon_picker.elem_value or ""
  local icon_selected = false
  if type(icon_val) == "table" then
    icon_selected = icon_val.name ~= nil and icon_val.name ~= ""
  elseif type(icon_val) == "string" then
    icon_selected = icon_val ~= ""
  end
  save_btn.enabled = (text_val ~= nil) or icon_selected
  if save_btn.enabled then
    save_btn.tooltip = ""
  else
    save_btn.tooltip = { "ft_tag_editor_save_tooltip" }
  end
end

-- Helper: returns true if the element is inside the tag editor frame
local function click_is_inside_tag_editor(element)
  while element do
    if element.name == "ft_tag_editor_outer_frame" then
      return true
    end
    element = element.parent
  end
  return false
end

-- Patch: ignore clicks outside tag editor when open
function TagEditorGUI.on_click(event)
  local player_index = Helpers.find_player_index_in_event(event)
  if not player_index then return end
  local player = _G.game.get_player(player_index)
  if not player then return end
  local gui = player.gui.screen
  if gui.ft_tag_editor_outer_frame then
    local element = event.element
    if not element or not element.valid then return end
    if not click_is_inside_tag_editor(element) and element.name ~= "ft_tag_editor_outer_frame" then
      -- Click was outside the tag editor, ignore
      return
    end
  end
  -- ...existing code...
end

-- When the tag editor is open, ignore clicks outside the tag editor GUI
-- NOTE: The script.on_event registration must be done in control.lua, not here.
-- Please register TagEditorGUI.on_click for defines.events.on_gui_click in control.lua.

return TagEditorGUI
