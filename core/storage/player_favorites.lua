-- core/storage/player_favorites.lua
-- Player favorite slots logic for FavoriteTeleport

local PlayerFavorites = {}
local Constants = require("constants")
local Helpers = require("core.utils.helpers")
local Storage = require("core.storage")

--- Returns the favorites array for a player on their current surface, initializing any missing slots.
---@param player LuaPlayer
---@return table[]
function PlayerFavorites.get_player_favorites(player)
  if type(player) ~= "table" or not player.valid or not player.surface or not player.surface.index then return {} end
  local pdata = Storage.get_player_data(player)
  local faves = pdata.surfaces[player.surface.index].favorites or {}
  if #faves < Constants.MAX_FAVORITE_SLOTS then
    PlayerFavorites.ensure_favorite_slots_initialized(faves, player.surface.index)
  end
  return faves
end

--- Ensures all slots are initialized for a favorites array (helper)
---@param slots table[]
---@param surface_index uint
function PlayerFavorites.ensure_favorite_slots_initialized(slots, surface_index)
  if #slots < Constants.MAX_FAVORITE_SLOTS then
    for slot = 1, Constants.MAX_FAVORITE_SLOTS do
      if not slots[slot] then
        slots[slot] = {
          gps = "",
          slot_locked = false
        }
      end
    end
  end
  return slots
end

return PlayerFavorites
