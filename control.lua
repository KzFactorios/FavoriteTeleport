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
  if not global.ft_tag_editor_autoclose_active then
    global.ft_tag_editor_autoclose_active = true
    script.on_nth_tick(20, Control._tag_editor_autoclose_tick)
  end
end

function Control.stop_tag_editor_autoclose(player)
  global.ft_tag_editor_autoclose_players = global.ft_tag_editor_autoclose_players or {}
  global.ft_tag_editor_autoclose_players[player.index] = nil
  -- If no players left, stop the tick handler
  local any = false
  for _, v in pairs(global.ft_tag_editor_autoclose_players) do
    if v then any = true; break end
  end
  -- Only stop the tick handler if no players are left
  if not next(global.ft_tag_editor_autoclose_players) then
    global.ft_tag_editor_autoclose_active = false
    script.on_nth_tick(20, nil)
  end
end

function Control._tag_editor_autoclose_tick(event)
  for idx in pairs(global.ft_tag_editor_autoclose_players or {}) do
    local player = game.get_player(idx)
    if player and player.valid then
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

-- Patch TagEditorGUI.open/close to start/stop autoclose only once
function Control.patch_tag_editor_autoclose()
  if TagEditorGUI._autoclose_patched then return end
  local _orig_tag_editor_open = TagEditorGUI.open
  local _orig_tag_editor_close = TagEditorGUI.close
  TagEditorGUI.open = function(player, position, context)
    local result = _orig_tag_editor_open(player, position, context)
    Control.start_tag_editor_autoclose(player)
    return result
  end
  TagEditorGUI.close = function(player)
    Control.stop_tag_editor_autoclose(player)
    return _orig_tag_editor_close(player)
  end
  TagEditorGUI._autoclose_patched = true
end

-- Call the patching function once at the end
Control.patch_tag_editor_autoclose()

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

return Control
