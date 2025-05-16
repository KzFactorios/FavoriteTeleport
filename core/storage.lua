local Helpers = require("core.utils.helpers")
local Constants = require("constants")

-- Storage.lua
-- Centralized persistent storage handler for mod
-- Handles saving, loading, and schema management for mod data

local Storage = {}

--- Initializes the storage structure if not present
function Storage.init()
  if not Storage._data then
    Storage._data = {
      mod_version = nil,
      players = {},
      surfaces = {},
    }
  end
end

--- Returns the root storage table
function Storage.get()
  if not Storage._data then Storage.init() end
  return Storage._data
end

--- Returns the player-specific storage table
-- @param player_index integer
function Storage.get_player_data(player_index)
  local storage = Storage.get()
  storage.players[player_index] = storage.players[player_index] or {}
  return storage.players[player_index]
end

local function get_surface_data_and_index(player)
  if not player or not player.valid then return nil, nil end
  local surface_index = player.surface.index
  if not surface_index then return nil, nil end
  local storage = Storage.get()
  storage.surfaces[surface_index] = storage.surfaces[surface_index] or {}
  return storage.surfaces[surface_index], surface_index
end

--- Returns the chart_tags for the player's current surface, populating from the game if missing or empty.
-- @param player LuaPlayer
function Storage.get_chart_tags(player)
  local surface_data = get_surface_data_and_index(player)
  if not surface_data then return {} end
  surface_data.chart_tags = surface_data.chart_tags or {}
  if not next(surface_data.chart_tags) or #surface_data.chart_tags == 0 then
    local surface = player.surface
    if surface and player.force then
      surface_data.chart_tags = player.force.find_chart_tags(surface)
    end
  end
  return surface_data.chart_tags or {}
end

--- Returns the map_tags for the given surface, initializing to {} if missing.
-- @param surface_index integer
function Storage.get_map_tags_for_surface(surface_index)
  local storage = Storage.get()
  storage.surfaces[surface_index] = storage.surfaces[surface_index] or {}
  local surf = storage.surfaces[surface_index]
  surf.map_tags = surf.map_tags or {}
  return surf.map_tags
end

--- Returns the map_tags for the player's current surface
function Storage.get_map_tags(player)
  if not player or not player.valid then return {} end
  local surface_index = player.surface.index
  return Storage.get_map_tags_for_surface(surface_index)
end

--- Finds a map_tag by gps in the given surface's map_tags
function Storage.find_map_tag_by_gps(gps)
  local surface_index = Helpers.get_surface_index_from_gps(gps)
  local map_tags = Storage.get_map_tags_for_surface(surface_index)
  for _, tag in ipairs(map_tags) do
    if tag.gps == gps then return tag end
  end
  return nil
end

--- Adds or updates a map_tag in the given surface's map_tags (by gps)
function Storage.add_or_update_map_tag(surface_index, map_tag)
  local map_tags = Storage.get_map_tags_for_surface(surface_index)
  for i, tag in ipairs(map_tags) do
    if tag.gps == map_tag.gps then
      map_tags[i] = map_tag
      return
    end
  end
  table.insert(map_tags, map_tag)
end

function Storage.get_ALL_player_favorites(player)
  if not player or not player.valid then return {} end
  local faves = {}
  local pdata = Storage.get_player_data(player.index)
  local favorites = pdata.favorites

  for i = 1, #favorites do
    local surface_faves = favorites[i]
    for _, favorite in ipairs(surface_faves) do
      table.insert(faves, favorite)
    end
  end

  return faves
end

--- Returns the favorites array for a player on their current surface, initializing any missing slots.
--- Only favorites for the player's current surface are returned. For all surfaces, use a different accessor.
---@param player LuaPlayer
---@return table[]
function Storage.get_player_favorites(player)
  if not player or not player.valid then return {} end
  local pdata = Storage.get_player_data(player.index)
  local surface_index = player.surface and player.surface.index or 1
  local checked_surface_index = 1
  if type(surface_index) == "number" and surface_index > 0 then
    checked_surface_index = math.floor(surface_index)
  end

  pdata.favorites = pdata.favorites or {}
  if not pdata.favorites[surface_index] then
    pdata.favorites[surface_index] = {}
  end
  local faves = pdata.favorites[surface_index]
  Storage.ensure_favorite_slots_initialized(faves, checked_surface_index)
  return faves
end

--- Ensures all slots are initialized for a favorites array (helper)
---@param faves table[]
---@param surface_index integer
function Storage.ensure_favorite_slots_initialized(faves, surface_index)
  if #faves < Constants.MAX_FAVORITE_SLOTS then
    for slot = 1, Constants.MAX_FAVORITE_SLOTS do
      if not faves[slot] then
        faves[slot] = {
          surface_index = surface_index,
          gps = "",
          map_tag = nil,
          slot_locked = false
        }
      end
    end
  end
end

--- Finds a favorite by gps for a player and surface
function Storage.find_favorite_by_gps(player, gps)
  local favorites = Storage.get_player_favorites(player)
  return Helpers.find_favorite_by_gps(favorites, gps)
end

--- Returns true if the favorite slot is empty for a player and surface
function Storage.favorite_slot_is_empty(player, slot)
  local favorites = Storage.get_player_favorites(player)
  return Helpers.favorite_slot_is_empty(favorites[slot])
end

--- Returns the number of used slots in a player's favorites for a surface
function Storage.count_used_favorite_slots(player)
  local favorites = Storage.get_player_favorites(player)
  return Helpers.count_used_favorite_slots(favorites)
end

--- Called when a player leaves the game; cleans up their tag ownership and favorites
-- @param player_index integer
-- @param player_name string
function Storage.on_player_left_game(player_index, player_name)
  local storage = Storage.get()
  -- Remove player_index from all faved_by_players and set last_user to nil if owned
  for surface_index, surface_data in pairs(storage.surfaces) do
    -- Clean up chart_tags
    if surface_data.chart_tags then
      for _, tag in pairs(surface_data.chart_tags) do
        if tag.last_user == player_name then
          tag.last_user = nil
        end
        if tag.faved_by_players then
          for i = #tag.faved_by_players, 1, -1 do
            if tag.faved_by_players[i] == player_index then
              table.remove(tag.faved_by_players, i)
            end
          end
        end
      end
    end
    -- Clean up ext_tags if present
    if surface_data.ext_tags then
      for _, tag in pairs(surface_data.ext_tags) do
        if tag.last_user == player_name then
          tag.last_user = nil
        end
        if tag.faved_by_players then
          for i = #tag.faved_by_players, 1, -1 do
            if tag.faved_by_players[i] == player_index then
              table.remove(tag.faved_by_players, i)
            end
          end
        end
      end
    end
  end
end

--- Invalidates the chart tag cache for a given surface index by setting chart_tags to nil.
-- @param surface_index integer
function Storage.reset_cached_chart_tags(surface_index)
  local storage = Storage.get()
  if storage.surfaces and storage.surfaces[surface_index] then
    storage.surfaces[surface_index].chart_tags = nil
  end
end

return Storage
