-- core/storage/player_favorites.lua
-- Player favorite slots logic for FavoriteTeleport

-- Do not use this module directly! Always use require("core.storage.init") or require("core.storage") for all storage and favorites access.
-- This ensures PlayerFavorites.get_player_data is injected properly.
-- If you see an error about get_player_data being nil, update your code to use the storage/init interface.

local PlayerFavorites = {}
local Constants = require("constants")
local Helpers = require("core.utils.helpers")


--- Ensures all slots are initialized for a favorites array (helper)
---@param slots table[]
---@param surface_index uint
local function ensure_favorite_slots_initialized(slots, surface_index)
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

-- This function must be injected by the storage/init.lua module:
-- PlayerFavorites.get_player_data = StorageInit.get_player_data
-- If you see an error here, ensure that storage/init.lua sets this up before use.
function PlayerFavorites.get_player_favorites(player)
  if type(PlayerFavorites.get_player_data) ~= "function" then
        error("PlayerFavorites.get_player_data is not set. It must be injected by storage/init.lua.")
  end
  if type(player) ~= "userdata" or not player.valid or not player.surface or not player.surface.index then return {} end
  local pdata = PlayerFavorites.get_player_data(player)
  pdata.surfaces = pdata.surfaces or {}
  pdata.surfaces[player.surface.index] = pdata.surfaces[player.surface.index] or {}
  local faves = pdata.surfaces[player.surface.index].favorites or {}
  if #faves < Constants.MAX_FAVORITE_SLOTS then
    ensure_favorite_slots_initialized(faves, player.surface.index)
  end
  return faves
end

return PlayerFavorites
