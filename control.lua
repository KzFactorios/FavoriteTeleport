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

remote.add_interface("FavoriteTeleport", {
  get_storage = function()
    return require("core.storage.init").get()
  end
})

return Control
