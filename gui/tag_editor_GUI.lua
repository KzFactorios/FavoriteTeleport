--- tag_editor_GUI.lua
--- Handles the tag editor dialog for FavoriteTeleport mod

local TagEditorGUI = {}
local Constants = require("constants")
local Helpers = require("core.utils.helpers")
local TagEditorGUIBuilder = require("gui/tag_editor_GUI_builder")
local TagEditorGUIValidation = require("gui/tag_editor_GUI_validation")
local TagEditorGUIEvents = require("gui/tag_editor_GUI_events")

TagEditorGUI.get_available_favorite_slots = function(player_index, surface_index, max_slots)
  local storage = require("core/storage").get()
  if not storage.players[player_index] then return max_slots end
  if not storage.players[player_index][surface_index] then return max_slots end
  local favorites = storage.players[player_index][surface_index].favorites or {}
  local count = 0
  for i = 1, max_slots do
    if not favorites[i] then count = count + 1 end
  end
  return count
end

TagEditorGUI.get_next_available_favorite_slot = function(player_index, surface_index)
  local storage = require("core/storage").get()
  local max_slots = Constants.MAX_FAVORITE_SLOTS
  if not storage.players[player_index] then return nil end
  if not storage.players[player_index][surface_index] then return nil end
  local favorites = storage.players[player_index][surface_index].favorites or {}
  for i = 1, max_slots do
    if not favorites[i] then return i end
  end
  return nil
end

TagEditorGUI.has_available_favorite_slot = function(player_index, surface_index)
  return TagEditorGUI.get_next_available_favorite_slot(player_index, surface_index) ~= nil
end

TagEditorGUI.open = TagEditorGUIBuilder.open
TagEditorGUI.close = TagEditorGUIBuilder.close
TagEditorGUI.add_row = TagEditorGUIBuilder.add_row

TagEditorGUI.on_click = TagEditorGUIEvents.on_click

function TagEditorGUI.handle_confirm(player)
  local gui = player.gui.screen
  local frame = gui.ft_tag_editor_outer_frame and gui.ft_tag_editor_outer_frame.ft_tag_editor_frame
  if not frame then return end

  local surface = player.surface
  local surface_index = surface.index
  local player_index = player.index

  -- Gather input values
  local pos_string = frame.ft_tag_editor_teleport_row.ft_tag_editor_pos_btn.caption
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

  -- Storage setup
  local Storage = require("core/storage")
  local storage = Storage.get()
  storage.players[player_index] = storage.players[player_index] or {}
  storage.players[player_index][surface_index] = storage.players[player_index][surface_index] or {}
  storage.players[player_index][surface_index].favorites = storage.players[player_index][surface_index].favorites or {}
  storage.surfaces[surface_index] = storage.surfaces[surface_index] or {}
  storage.surfaces[surface_index].chart_tags = storage.surfaces[surface_index].chart_tags or {}
  storage.surfaces[surface_index].map_tags = storage.surfaces[surface_index].map_tags or {}

  -- Favorite slot logic
  if is_favorite and not TagEditorGUI.has_available_favorite_slot(player_index, surface_index) then
    is_favorite = false
    favorite_slots_unavailable = true
  end

  -- Find or create chart_tag
  local chart_tags = storage.surfaces[surface_index].chart_tags
  local found_tag = nil
  for _, tag in pairs(chart_tags) do
    if tag.pos_string == pos_string then
      found_tag = tag
      break
    end
  end

  local chart_tag
  if not found_tag then
    -- Create new chart tag
    local tag_spec = {
      position = Helpers.pos_string_to_map_position(pos_string),
      icon = icon,
      text = text,
      last_user = player.name
    }
    --[[
      The following check triggers a static analysis diagnostic (false positive):
      'chart_tag = player.force.add_chart_tag(player.surface, tag_spec)'
      Static analysis may claim 'chart_tag' is always non-nil, but in Factorio runtime,
      add_chart_tag can return nil if the tag cannot be created (e.g., invalid position).
      This check is required for runtime correctness.
    --]]
    chart_tag = player.force.add_chart_tag(player.surface, tag_spec)
    if not chart_tag then
      player.print{"FavoriteTeleport.ft_tag_editor_error_chart_tag_failed"}
      TagEditorGUI.close(player)
      return
    end
    table.insert(chart_tags, {pos_string=pos_string, tag=chart_tag, last_user=player.name})

    -- Invalidate chart_tags cache so it will be rebuilt on next access
    storage.surfaces[surface_index].chart_tags = nil
  else
    -- Only last_user can update tag info (except favoriting)
    chart_tag = found_tag.tag
    --[[
      The following check triggers a static analysis diagnostic (false positive):
      'if found_tag.last_user ~= player.name then'
      Static analysis may claim this is always false, but in multiplayer or after tag transfer,
      this check is required for runtime correctness and security.
    --]]
    if found_tag.last_user ~= player.name then
      player.print{"FavoriteTeleport.ft_tag_editor_error_not_last_user"}
      return
    end
    chart_tag.icon = icon
    chart_tag.text = text
    found_tag.last_user = player.name

    -- Invalidate chart_tags cache after update
    storage.surfaces[surface_index].chart_tags = nil
  end

  -- MapTag creation/update
  local map_tags = storage.surfaces[surface_index].map_tags
  local map_tag = nil
  for _, mt in pairs(map_tags) do
    if mt.pos_string == pos_string then
      map_tag = mt
      break
    end
  end
  -- The following 'if' statement may trigger a static analysis diagnostic for being 'impossible' or 'unnecessary'.
  -- This is a false positive: Factorio runtime can return nil here if the map tag is not found, so this check is required.
  if not map_tag then
    map_tag = {
      pos_string = pos_string,
      faved_by_players = {},
      description = description
    }
    table.insert(map_tags, map_tag)
  else
    map_tag.description = description
  end

  -- Favorite logic
  local favorites = storage.players[player_index][surface_index].favorites
  local slot = TagEditorGUI.get_next_available_favorite_slot(player_index, surface_index)

  --[[
    The following check may trigger a static analysis diagnostic (false positive):
    'if is_favorite and slot then'
    Static analysis may claim this is always falsy, but in Factorio runtime,
    both values can be true, and this check is required for runtime correctness.
  --]]
  if is_favorite and slot then
    favorites[slot] = {pos_string = pos_string}

    -- Add to faved_by_players if not already present
    local already_faved = false
    for _, idx in ipairs(map_tag.faved_by_players) do
      if idx == player_index then already_faved = true; break end
    end

    --[[
      The following check may trigger a static analysis diagnostic (false positive):
      'if not already_faved then'
      Static analysis may claim this is always truthy, but in multiplayer or after tag transfer,
      this check is required for runtime correctness.
    --]]
    if not already_faved then
      table.insert(map_tag.faved_by_players, player_index)
    end
  else
    -- Remove from favorites if present
    for i, fav in pairs(favorites) do
      if fav and fav.pos_string == pos_string then
        favorites[i] = nil
      end
    end
    -- Remove from faved_by_players
    for i=#map_tag.faved_by_players,1,-1 do
      if map_tag.faved_by_players[i] == player_index then
        table.remove(map_tag.faved_by_players, i)
      end
    end

    -- Invalidate chart_tags cache after removal
    storage.surfaces[surface_index].chart_tags = nil
  end

  -- Save storage (if needed)
  if Storage.save_data then Storage.save_data(storage) end

  -- Close the tag editor GUI
  TagEditorGUI.close(player)
end

function TagEditorGUI.handle_action(player, action)
  local gui = player.gui.screen
  local frame = gui.ft_tag_editor_outer_frame and gui.ft_tag_editor_outer_frame.ft_tag_editor_frame
  if not frame then return end

  if action == "confirm" then
    TagEditorGUI.handle_confirm(player)
  elseif action == "delete" then
    -- Only allow deletion if editing an existing tag
    local surface = player.surface
    local surface_index = surface.index
    local player_index = player.index
    local Storage = require("core/storage")
    local storage = Storage.get()
    local pos_string = frame.ft_tag_editor_teleport_row.ft_tag_editor_pos_btn.caption
    local chart_tags = storage.surfaces[surface_index].chart_tags or {}
    local found_tag, found_idx = nil, nil
    for idx, tag in pairs(chart_tags) do
      if tag.pos_string == pos_string then
        found_tag = tag
        found_idx = idx
        break
      end
    end
    --[[
        The following checks may trigger static analysis diagnostics (false positives):
        - 'if found_tag then' and 'if found_tag.tag and found_tag.tag.valid then'
        - 'if pdata[surface_index] and pdata[surface_index].favorites then'
        These are required for runtime correctness due to possible nil values in Factorio runtime.
      --]]
      if found_tag then
        -- Only creator can delete or move
        if found_tag.created_by ~= player.name then
          player.print{"FavoriteTeleport.ft_tag_editor_error_not_creator"}
          return
        end
        -- Only last_user can delete
        if found_tag.last_user ~= player.name then
          player.print{"FavoriteTeleport.ft_tag_editor_error_not_last_user"}
          return
        end
        if found_tag.tag and found_tag.tag.valid then
          found_tag.tag.destroy()
        end
        if chart_tags and found_idx then
          chart_tags[found_idx] = nil
        end
        local map_tags = storage.surfaces[surface_index].map_tags or {}
        for i=#map_tags,1,-1 do
          if map_tags[i].pos_string == pos_string then
            table.remove(map_tags, i)
          end
        end
        for pidx, pdata in pairs(storage.players) do
          if pdata[surface_index] and pdata[surface_index].favorites then
            local favorites = pdata[surface_index].favorites
            for slot, fav in pairs(favorites) do
              if fav and fav.pos_string == pos_string then
                favorites[slot] = nil
              end
            end
          end
        end
        storage.surfaces[surface_index].chart_tags = nil
        if Storage.save_data then Storage.save_data(storage) end
        player.print{"FavoriteTeleport.ft_tag_editor_deleted"}
        TagEditorGUI.close(player)
      end
    return
  elseif action == "move" then
    -- Only last_user can move; button is only enabled for last_user
    -- Set a flag in the player's persistent storage to indicate move mode is active
    local Storage = require("core/storage")
    local storage = Storage.get()
    storage.ft_tag_editor_move_mode = storage.ft_tag_editor_move_mode or {}
    storage.ft_tag_editor_move_mode[player.index] = {
      active = true,
      surface_index = player.surface.index,
      pos_string = frame.ft_tag_editor_teleport_row.ft_tag_editor_pos_btn.caption
    }
    if Storage.save_data then Storage.save_data(storage) end
    player.print{"FavoriteTeleport.ft_tag_editor_move_mode_active"}
    -- Optionally, show a floating text or GUI indicator for move mode
    TagEditorGUI.close(player)
    return
  end
end

return TagEditorGUI
