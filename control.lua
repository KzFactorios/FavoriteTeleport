-- control.lua
-- Main entry point for event registration and mod lifecycle

-- luacheck: globals script defines remote game serpent
---@diagnostic disable: undefined-global

local Lifecycle = require("core.control.lifecycle")
local Events = require("core.control.events")
local Util = require("core.control.util")
local Observer = require("core.observer")
local FaveBarGUI = require("gui.fave_bar_GUI")
local TagEditorGUI = require("gui.tag_editor_GUI")
local MoveMarker = require('core.control.move_marker')
local Helpers = require("core.utils.helpers")
local TagSync = require("core.tag_sync.tag_sync_suite")
local Storage = require("core.storage.init")

local Control = {}

-- Register lifecycle events
global = global or {}
script.on_init(Lifecycle.on_init)
script.on_load(Lifecycle.on_load)
script.on_configuration_changed(Lifecycle.on_configuration_changed)

-- Register all other events
Events.register()

-- Observer pattern for GUI updates
Observer.register(function(event)
  if event.type == "favorite_added" or event.type == "favorite_removed" or event.type == "favorite_updated" then
    local player = event.player
    if player and FaveBarGUI.update_slots then FaveBarGUI.update_slots(player) end
  elseif event.type == "favorite_changed" then
    local player = event.player
    if player and TagEditorGUI.update then TagEditorGUI.update(player) end
  end
end)

function Control.close_guis(player)
  -- TODO handle any other frames
  if player then
    for _, element in pairs(player.gui.screen.children) do
      if element.name == "ft_tag_editor_outer_frame" then
        element.destroy()
        break
      end
    end
  end
end

function Control.update_guis(player, event_type)
  -- Notify observers with a specific event type
  Observer.notify_all({type = event_type or "favorite_changed", player = player})
end

-- Helper: Start/stop the tag editor auto-close check
function Control.start_tag_editor_autoclose(player)
  global.ft_tag_editor_autoclose_players = global.ft_tag_editor_autoclose_players or {}
  global.ft_tag_editor_autoclose_players[player.index] = true
  global.ft_tag_editor_autoclose_active = true
  script.on_nth_tick(20, Control._tag_editor_autoclose_tick)
end

function Control.stop_tag_editor_autoclose(player)
  global.ft_tag_editor_autoclose_players = global.ft_tag_editor_autoclose_players or {}
  global.ft_tag_editor_autoclose_players[player.index] = nil
  if not next(global.ft_tag_editor_autoclose_players) then
    global.ft_tag_editor_autoclose_active = false
    script.on_nth_tick(20, nil)
  end
end

function Control._tag_editor_autoclose_tick(event)
  for idx in pairs(global.ft_tag_editor_autoclose_players or {}) do
    local player = game.get_player(idx)
    if player then
      local gui = player.gui.screen
      if gui.ft_tag_editor_outer_frame and player.render_mode ~= defines.render_mode.chart then
        TagEditorGUI.close(player)
        Control.stop_tag_editor_autoclose(player)
      end
    end
  end
end

-- Helper: returns true if the tag editor is open for a player
function Control.is_tag_editor_open(player)
  return player and player.gui and player.gui.screen and player.gui.screen.ft_tag_editor_outer_frame ~= nil
end

-- Patch TagEditorGUI autoclose logic (must be required last)
local patch_tag_editor_autoclose = require("core.control.autoclose_patch")
patch_tag_editor_autoclose(Control)

-- GUI stack system for ESC handling (per-player)
local function get_player_stack(player_index)
  global.FavoriteTeleport = global.FavoriteTeleport or {}
  global.FavoriteTeleport.players = global.FavoriteTeleport.players or {}
  global.FavoriteTeleport.players[player_index] = global.FavoriteTeleport.players[player_index] or {}
  global.FavoriteTeleport.players[player_index].gui_stack = global.FavoriteTeleport.players[player_index].gui_stack or {}
  return global.FavoriteTeleport.players[player_index].gui_stack
end

-- Push a GUI id onto the stack
function Control.push_gui(player, gui_id)
  local stack = get_player_stack(player.index)
  table.insert(stack, gui_id)
end

-- Pop the top GUI id from the stack
function Control.pop_gui(player)
  local stack = get_player_stack(player.index)
  return table.remove(stack)
end

-- Peek the top GUI id
function Control.peek_gui(player)
  local stack = get_player_stack(player.index)
  return stack[#stack]
end

-- Clear the stack (e.g. on player leave)
function Control.clear_gui_stack(player)
  local stack = get_player_stack(player.index)
  for i = #stack, 1, -1 do stack[i] = nil end
end

-- Add on_tick handler for move marker rendering
script.on_event(defines.events.on_tick, function(event)
  -- Move marker rendering for tag move mode
  for _, player in pairs(game.connected_players) do
    local ft = _G.storage and _G.storage.FavoriteTeleport
    if ft and ft.ft_tag_editor_move_mode and ft.ft_tag_editor_move_mode[player.index] then
      local move_mode = ft.ft_tag_editor_move_mode[player.index]
      if move_mode.active and move_mode.gps then
        MoveMarker.show_marker(player, move_mode.gps)
      else
        MoveMarker.remove_marker(player)
      end
    else
      MoveMarker.remove_marker(player)
    end
  end
end)

-- Register a handler for the next map click to complete move mode
script.on_event(defines.events.on_player_selected_area, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local storage = Storage.get()
  local move_mode = storage.ft_tag_editor_move_mode and storage.ft_tag_editor_move_mode[player.index]
  if not (move_mode and move_mode.active) then return end

  -- Only allow move on the correct surface
  if event.surface_index ~= move_mode.surface_index then
    player.create_local_flying_text{text = {"ft_tag_editor_move_invalid_surface"}, position = event.area.left_top, color = {r=1,g=0.5,b=0.5}}
    return
  end

  -- Use the center of the selected area as the new position
  local new_pos = {
    x = (event.area.left_top.x + event.area.right_bottom.x) / 2,
    y = (event.area.left_top.y + event.area.right_bottom.y) / 2
  }
  local new_gps = Helpers.format_gps(new_pos.x, new_pos.y, event.surface_index)

  -- Move the tag and sync all data
  TagSync.move_tag(player, move_mode.gps, new_gps)

  -- Clear move mode and remove marker
  storage.ft_tag_editor_move_mode[player.index] = nil
  if Storage.save_data then Storage.save_data(storage) end

  -- Reopen the tag editor at the new location
  TagEditorGUI.open(player, new_pos)
end)

-- Optionally, handle cancel (ESC or right-click) to exit move mode and remove marker
script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local storage = Storage.get()
  -- Use StorageInit.get() to ensure ft_tag_editor_move_mode is always initialized
  local move_mode_tbl = Storage.get().ft_tag_editor_move_mode
  if move_mode_tbl and move_mode_tbl[player.index] then
    move_mode_tbl[player.index] = nil
    if Storage.save_data then Storage.save_data(Storage.get()) end
    player.create_local_flying_text{text = {"ft_tag_editor_move_cancelled"}, position = player.position, color = {r=1,g=0.5,b=0.5}}
  end
end)

return Control
