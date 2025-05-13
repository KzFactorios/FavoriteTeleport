---@diagnostic disable: undefined-global
-- control.lua
-- Main entry point for event registration and mod lifecycle

local Context = require("context")
local MapTag = require("core/maptag")
local ErrorHandler = require("core/utils/error_handler")

-- Main mod event registration and lifecycle management

script.on_init(function()
  -- TODO: Initialize global data, GUIs, etc.
end)

script.on_load(function()
  -- TODO: Restore runtime references if needed
end)

script.on_configuration_changed(function(event)
--[[if event.mod_changes and event.mod_changes["FavoriteTeleport"] then
    local changes = event.mod_changes["FavoriteTeleport"]

    -- this condition indicates the mod was removed
    if changes.old_version and not changes.new_version then
      -- cleanup gui for all players
      for _, player in pairs(game.players) do
        add_tag_gui.on_player_removed(player)
        edit_fave_gui.on_player_removed(player)
        _gui_manager.update_the_fav_bar(player) -- or .on_player_removed if needed
      end
      -- Mod is being removed, clean up data
      context.qmtt = nil
    else
      for _, player in pairs(game.players) do
        control.initialize(player)
      end
    end
  end
  if migration.needs_migration(context) then
    migration.migrate(context)
  end
  ]]
  -- TODO: Handle migrations and config changes
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if not event then return end
  -- .player_index is optional in the API but we need the player index in our logic
  if not event.player_index then return end

  local player = game.get_player(event.player_index)
  if not player then return end

  local setting_name = event.setting
  local setting_type = event.setting_type

  if setting_type == "runtime-per-user" and setting_name == PREFIX .. "favorites-on" then
    --control.apply_favorites_on_off_state(player)
    --control.update_uis(player)
  end
end)

script.on_event(defines.events.on_chart_tag_modified, function(event)
    MapTag.on_chart_tag_modified(event)
end)

script.on_event(defines.events.on_player_created, function(event)
--STUB
end)

script.on_event(defines.events.on_player_joined_game, function(event)
--STUB
end)

script.on_event(defines.events.on_player_left_game, function(event)
-- cleanup player's data?
end)

script.on_event(defines.events.on_player_removed, function(event)
-- cleanup player's data?
end)

script.on_event(defines.events.script_raised_teleported, function(event) 
-- STUB
end)

script.on_event(defines.events.on_player_changed_force, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  -- implemented to handle EditorExtensions incompat? 1/20/2025
  -- TODO when implemented pcall(context.reset_surface_chart_tags, player)
end)

--[[TODO decide if this is necessary to handle stock editor and/or should
      handle mod's additions for consistency
script.on_event(defines.events.on_chart_tag_added, function(event)
  qmtt.handle_chart_tag_added(event)
end)]]

script.on_event(defines.events.on_chart_tag_modified, function(event)
  qmtt.handle_chart_tag_modified(event)
end)

script.on_event(defines.events.on_chart_tag_removed, function(event)
  --qmtt.handle_chart_tag_removal(event)
end)

-- set events for hotkeys
for i = 1, 10 do
  script.on_event(prototypes.custom_input[PREFIX .. "teleport-to-fave-" .. i], function(event)
    ---@diagnostic disable-next-line: undefined-field
    local player = game.get_player(event.player_index)
    if not player then return end

    --[[local faves = context.get_player_favorites_on_current_surface(player)
    if not faves then return end

    local sel_fave = faves[i]
    if sel_fave and sel_fave._pos_idx and sel_fave._pos_idx ~= "" then
      -- Teleporting on a space platform is handled at teleport function
      map_tag_utils.teleport_player_to_closest_position(player,
        wutils.decode_position_from_pos_idx(sel_fave._pos_idx))
    end]]
  end)
end


local _startup = nil

script.on_event(defines.events.on_tick, function(event)
  if not _startup then
    for _, player in pairs(game.players) do
      if not player then return end
      control.update_uis(player)
    end
    startup = 1
  end
  script.on_event(defines.events.on_tick, nil)
end)

local RESPONSIVE_TICKS = 30 * 1

script.on_nth_tick(RESPONSIVE_TICKS, function(event)
  if not game then return end

  for _, player in pairs(game.players) do
    if not player.character then
      -- TODO control.close_guis(player)
    end
  end
end)

-- TODO: Register additional event handlers for player actions, GUI, etc.

return {}

