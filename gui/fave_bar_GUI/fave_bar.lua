-- fave_bar_GUI/fave_bar.lua
-- Orchestrates the favorites bar GUI using modular subcomponents

local Bar = require("gui.fave_bar_GUI.bar")
local Slots = require("gui.fave_bar_GUI.slots")
local Events = require("gui.fave_bar_GUI.events")
local Style = require("gui.fave_bar_GUI.style")
local Utils = require("gui.fave_bar_GUI.utils")

local FaveBar = {}

function FaveBar.build(player)
  Bar.build(player)
end

function FaveBar.update_slots(player)
  Slots.update_slots(player)
end

function FaveBar.on_click(event)
  Events.on_click(event)
end

function FaveBar.on_drag(event)
  Events.on_drag(event)
end

function FaveBar.destroy(player)
  Bar.destroy(player)
end

return FaveBar
