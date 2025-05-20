-- core/storage/init.lua
-- Storage initialization, schema, and migration logic for FavoriteTeleport

local StorageInit = {}
local Constants = require("constants")
local PlayerFavorites = require("core.storage.player_favorites")
local Helpers = require("core.utils.helpers")

-- Ensure 'storage' is defined as a global table if not already present
_G.storage = _G.storage or {}
local storage = _G.storage

function StorageInit.init()
  if not storage.FavoriteTeleport then
    storage.FavoriteTeleport = {
      mod_version = nil,
      players = {},
      surfaces = {},
    }
  end
end

function StorageInit.get()
  StorageInit.init()
  return storage.FavoriteTeleport
end

function StorageInit.get_player_favorites(player)
  return PlayerFavorites.get_player_favorites(player)
end

function StorageInit.ensure_favorite_slots_initialized(slots, surface_index)
  return PlayerFavorites.ensure_favorite_slots_initialized(slots, surface_index)
end

--- Gets or initializes persistent data for a specific player
-- @param player LuaPlayer
-- @return table
function StorageInit.get_player_data(player)
  if not player or not player.index then return {} end
  local global_data = StorageInit.get()
  global_data.players = global_data.players or {}
  local pdata = global_data.players[player.index]
  if type(pdata) ~= "table" then
    pdata = {}
    global_data.players[player.index] = pdata
  end
  return pdata
end

--- Gets or initializes the surface data table for a player's current surface
-- Ensures chart_tags and map_tags are initialized
-- @param player LuaPlayer
-- @return table surface_data
function StorageInit.get_surface_data(player)
  if not player or not player.surface or not player.surface.index then return nil end
  local storage = StorageInit.get()
  local surface_index = player.surface.index
  storage.surfaces[surface_index] = storage.surfaces[surface_index] or {}
  local surface_data = storage.surfaces[surface_index]
  -- Initialize chart_tags if missing or empty
  if not surface_data.chart_tags or type(surface_data.chart_tags) ~= "table" or next(surface_data.chart_tags) == nil then
    surface_data.chart_tags = player.force.find_chart_tags(player.surface) or {}
  end
  -- Initialize map_tags if missing or empty
  if not surface_data.map_tags or type(surface_data.map_tags) ~= "table" then
    surface_data.map_tags = {}
  end
  return surface_data
end

function StorageInit.get_map_tags(player)
  if not player or not player.surface or not player.surface.index then return {} end
  return StorageInit.get_surface_data(player).map_tags or {}
end

-- Tag Editor Position helpers (per-player, not persisted across reloads unless desired)
function StorageInit.set_tag_editor_position(player, position)
  if not player or not player.index then return end
  local pdata = StorageInit.get_player_data(player)
  pdata.tag_editor_position = position
end

function StorageInit.get_tag_editor_position(player)
  if not player or not player.index then return nil end
  local pdata = StorageInit.get_player_data(player)
  return pdata.tag_editor_position
end

function StorageInit.clear_tag_editor_position(player)
  if not player or not player.index then return end
  local pdata = StorageInit.get_player_data(player)
  pdata.tag_editor_position = nil
end

function StorageInit.re_populate_all_chart_tags(game)
  if not game or not game.surfaces then return end
  local storage = StorageInit.get()

  for _, surface in pairs(game.surfaces) do
    local surface_index = surface.index
    storage.surfaces[surface_index].chart_tags = game.forces["player"].find_chart_tags(surface)
  end
end

--- Finds a chart tag by GPS string for a given player
-- @param player LuaPlayer
-- @param gps string
-- @return LuaCustomChartTag|nil
function StorageInit.find_chart_tag_by_gps(player, gps)
  if not player or not gps then return nil end
  for _, tag in pairs(StorageInit.get_chart_tags(player)) do
    if tag and tag.position then
      local tag_gps = Helpers.format_gps(tag.position.x, tag.position.y, player.surface.index)
      if tag_gps == gps then
        return tag
      end
    end
  end
  return nil
end

function StorageInit.find_map_tag_by_gps(player, gps)
  if not player or not gps then return nil end
  for _, tag in pairs(StorageInit.get_map_tags(player)) do
    if tag and tag.gps then
      if tag.gps == gps then
        return tag
      end
    end
  end
  return nil
end

return StorageInit
