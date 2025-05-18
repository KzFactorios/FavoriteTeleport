--- fave_bar_GUI.lua
--- Handles the favorites bar GUI for FavoriteTeleport mod

local FaveBarGUI = {}

local Constants = require("constants")
local Context = require("core.context")
local Favorite = require("core.favorite")
local MapTag = require("core.map_tag")
local ErrorHandler = require("core.utils.error_handler")
local Storage = require("core.storage")
local Helpers = require("core.utils.helpers")

--- Creates or updates the favorites bar for a player
-- @param player LuaPlayer
function FaveBarGUI.build(player)
  local gui = player.gui.top
  if gui.ft_fave_bar then
    gui.ft_fave_bar.destroy()
  end
  local bar = gui.add{
    type = "flow",
    name = "ft_fave_bar",
    direction = "horizontal"
  }
  bar.style.horizontal_spacing = 8
  bar.style.vertical_align = "center"
  bar.style.top_padding = 2
  bar.style.bottom_padding = 2
  bar.style.left_padding = 6
  bar.style.right_padding = 6
  bar.style.height = 36

  local label = bar.add{
    type = "label",
    name = "ft_fave_bar_label",
    caption = "Teleport"
  }
  label.style.font = "default-bold"
  label.style.font_color = { r = 1, g = 0.85, b = 0.2 }
  label.style.top_padding = 2
  label.style.bottom_padding = 2
  label.style.left_padding = 4
  label.style.right_padding = 8

  local button = bar.add{
    type = "button",
    name = Constants.PREFIX .. "toggle_favorite_mode_button",
    style = Constants.PREFIX .. "toggle_favorite_mode_button",
    caption = "★"
  }
  button.style.font = "default-large-bold"
  button.style.font_color = { r = 1, g = 0.2, b = 0.2 }
  button.style.width = 32
  button.style.height = 32
  button.style.top_margin = 0
  button.style.left_margin = 0
end

--- Updates the favorites bar slots for the current surface
-- @param player LuaPlayer
function FaveBarGUI.update_slots(player)
  local favorites = Storage.get_player_favorites(player)
  local slots = Helpers.get_surface_favorites_array(favorites, Constants.MAX_FAVORITE_SLOTS)
  for slot, fav in ipairs(slots) do
    -- Use fav.surface_index, fav.gps, fav.map_tag, fav.slot_locked
    -- Example: display slot as empty 
    -- TODO: Implement actual GUI update logic using new structure
  end
end

--- Handles click events on the favorites bar
-- @param event EventData.on_gui_click
function FaveBarGUI.on_click(event)
  -- TODO: Implement click handling logic
end

--- Destroys the favorites bar GUI for a player
-- @param player LuaPlayer
function FaveBarGUI.destroy(player)
  -- TODO: Implement GUI destruction logic
end

return FaveBarGUI
