-- fave_bar_GUI/bar.lua
-- Responsible for building and updating the favorites bar

local Bar = {}
local Slots = require("gui.fave_bar_GUI.slots")
local Style = require("gui.fave_bar_GUI.style")
local Settings = require("settings")

function Bar.build(player)
  local settings = Settings:getPlayerSettings(player)
  if not settings.favorites_on then
    local gui = player.gui.top
    if gui.ft_fave_bar then gui.ft_fave_bar.destroy() end
    return
  end
  local gui = player.gui.top
  if gui.ft_fave_bar then gui.ft_fave_bar.destroy() end
  local bar = gui.add{
    type = "flow",
    name = "ft_fave_bar",
    direction = "horizontal"
  }
  Style.apply_bar_style(bar)
  local label = bar.add{
    type = "label",
    name = "ft_fave_bar_label",
    caption = "Teleport"
  }
  Style.apply_label_style(label)
  local button = bar.add{
    type = "button",
    name = "toggle_favorite_buttons",
    style = "toggle_favorite_buttons",
    caption = "★"
  }
  Style.apply_toggle_button_style(button)
  -- Build slots
  Slots.update_slots(player)
end

function Bar.update_slots(player)
  Slots.update_slots(player)
end

function Bar.destroy(player)
  local gui = player.gui.top
  if gui.ft_fave_bar then gui.ft_fave_bar.destroy() end
end

return Bar
