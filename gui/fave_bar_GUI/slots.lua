-- slots.lua
-- Logic for favorite slot creation, update, and validation

local Slots = {}

local Constants = require("constants")
local Cache = require("core.cache.init")
local Helpers = require("core.utils.helpers")
local GuiBase = require("gui.gui_base")
local Style = require("gui.fave_bar_GUI.style")

--- Updates the favorites bar slots for the current surface
-- @param player LuaPlayer
function Slots.update_slots(player)
  local favorites = Cache.get_player_favorites(player)
  Helpers.init_favorite_slots(favorites, Constants.MAX_FAVORITE_SLOTS)
  local gui = player.gui.top
  local bar = gui.ft_fave_bar
  if not bar then return end
  -- Remove old slot buttons if present
  for _, child in pairs(bar.children) do
    if child.valid and type(child.name) == "string" and child.name:find("^ft_fave_slot_") then
      child.destroy()
    end
  end
  for slot = 1, Constants.MAX_FAVORITE_SLOTS do
    local fav = favorites[slot]
    local btn = GuiBase.add_favorite_slot_button(bar, slot, fav)
    Style.apply_slot_button_style(btn, fav)
  end
end

return Slots
