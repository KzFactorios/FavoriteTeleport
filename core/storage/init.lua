-- core/storage/init.lua
-- Storage initialization, schema, and migration logic for FavoriteTeleport

local StorageInit = {}
local Constants = require("constants")
local PlayerFavorites = require("core.storage.player_favorites")
local Helpers = require("core.utils.helpers")
-- Removed: local ChartTags = require("core.storage.chart_tags")
-- At the top of any file (e.g., core/storage/init.lua or control.lua)
--[[
  VERSION MANAGEMENT:
  This mod's version is auto-injected from info.json at build time.
  To update the version in runtime code, run:
      python scripts/update_version.py
  This will update core/version.lua with the current version from info.json.
  Do NOT edit core/version.lua manually.
]] --
local mod_version = require("core.version")

-- Ensure 'storage' is defined as a global table if not already present
_G.storage = _G.storage or {}
local storage = _G.storage

function StorageInit.init()
  if not storage.FavoriteTeleport or type(storage.FavoriteTeleport) ~= "table" then
    storage.FavoriteTeleport = {}
  end
  local ft = storage.FavoriteTeleport
  if not ft.mod_version or type(ft.mod_version) ~= "string" then ft.mod_version = mod_version end
  if type(ft.tag_editor_positions) ~= "table" then ft.tag_editor_positions = {} end
  if type(ft.players) ~= "table" then ft.players = {} end
  if type(ft.surfaces) ~= "table" then ft.surfaces = {} end
  StorageInit.inject_player_favorites_dependency()
end

function StorageInit.get()
  StorageInit.init()
  return storage.FavoriteTeleport
end

function StorageInit.get_player_favorites(player)
  return PlayerFavorites.get_player_favorites(player)
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

function StorageInit.get_player_data_by_player_index(player_index)
  local global_data = StorageInit.get()
  global_data.players = global_data.players or {}
  local pdata = global_data.players[player_index]
  if type(pdata) ~= "table" then
    pdata = {}
    global_data.players[player_index] = pdata
  end
  return pdata
end

function StorageInit.inject_player_favorites_dependency()
  PlayerFavorites.get_player_data = StorageInit.get_player_data
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

--- Adds or updates a map_tag in the given surface's map_tags (by gps)
function StorageInit.add_or_update_map_tag(player, map_tag)
  local map_tags = StorageInit.get_map_tags(player)
  for i, mt in ipairs(map_tags) do
    if mt.gps == map_tag.gps then
      map_tags[i] = map_tag
      return
    end
  end

  --if not found then--
  -- Remove any runtime object references before storing
  if map_tag.tag then map_tag.tag = nil end

  table.insert(map_tags, map_tag)
end

function StorageInit.get_map_tags(player)
  if not player then return {} end
  return StorageInit.get_surface_data(player).map_tags or {}
end

--- Finds a chart tag by GPS string for a given player
-- @param player LuaPlayer
-- @param gps string
-- @return LuaCustomChartTag|nil
function StorageInit.find_chart_tag_by_gps(player, gps)
  if not player or not gps then return nil end
  local surface_data = StorageInit.get_surface_data(player)
  if not surface_data or not surface_data.chart_tags then return nil end
  for _, tag in pairs(surface_data.chart_tags) do
    if tag.position then
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
    if tag.gps == gps then
      return tag
    end
  end
  return nil
end

--- Returns the number of available favorite slots for a player
function StorageInit.get_available_favorite_slots_count(player)
  local favorites = StorageInit.get_player_favorites(player)
  local max_slots = Constants.MAX_FAVORITE_SLOTS
  local count = 0
  for i = 1, max_slots do
    ---@diagnostic disable-next-line: need-check-nil
    if not favorites[i] or not favorites[i].map_tag and favorites[i].map_tag ~= {} then
      count = count + 1
    end
  end
  return count
end

--- Invalidates the chart tag cache for a given surface index by setting chart_tags to nil.
-- @param surface_index integer
function StorageInit.reset_cached_chart_tags(surface_index)
  local storage = StorageInit.get()
  if storage.surfaces and storage.surfaces[surface_index] then
    storage.surfaces[surface_index].chart_tags = {}
  end
end

-- Rehomes a chart_tag to a new GPS if needed
-- @param player LuaPlayer
-- @param chart_tag LuaCustomChartTag (runtime object)
-- @param gps string (target GPS string)
-- @return LuaCustomChartTag (the new or original chart tag)
function StorageInit.rehome_chart_tag(player, chart_tag, gps)
  if not player or not chart_tag or not gps then return chart_tag end
  local surface = player.surface
  local surface_index = surface.index
  local gps_from_chart_tag = Helpers.format_gps(chart_tag.position.x, chart_tag.position.y, surface_index)
  if gps_from_chart_tag == gps then
    return chart_tag
  end

  -- find any matching map_tags/favorites that have this chart_tag
  local matching_favorites = {}
  local found_map_tag = StorageInit.find_map_tag_by_gps(gps)

  if found_map_tag then
    for _, players in pairs(_G.game.players) do
      for _, favorite in pairs(StorageInit.get_player_favorites(player)) do
        if favorite.gps == gps then
          table.insert(matching_favorites, favorite)
        end
      end
    end
  end

  -- Create new chart tag at the new GPS position
  local new_pos = Helpers.gps_to_map_position(gps)
  if not new_pos then return chart_tag end

  local tag_spec = {
    position = new_pos,
    icon = chart_tag.icon,
    text = chart_tag.text,
    last_user = chart_tag.last_user,
    -- Add any other fields you want to copy
  }
  local new_chart_tag = player.force.add_chart_tag(surface, tag_spec)

  if new_chart_tag then
    local update_gps =
        Helpers.format_gps(new_chart_tag.position.x, new_chart_tag.position.y, player.surface.index)
    for _, favorite in pairs(matching_favorites) do
      favorite.gps = update_gps
    end

    if found_map_tag then
      found_map_tag.gps = update_gps
    end
    -- Destroy the old chart tag
    pcall(function() chart_tag.destroy() end)
  end

  return new_chart_tag or chart_tag
end

-- In core/storage.lua, add per-player tag editor position storage
function StorageInit.get_tag_editor_position(player)
  if not player or type(player) ~= "userdata" or not player.index then return nil end
  local global_data = StorageInit.get()
  return global_data.tag_editor_positions[player.index] or nil
end

function StorageInit.set_tag_editor_position(player, pos)
  if not player or type(player) ~= "userdata" or not player.index then return end
  local global_data = StorageInit.get()
  global_data.tag_editor_positions = global_data.tag_editor_positions or {}
  global_data.tag_editor_positions[player.index] = pos
end

function StorageInit.clear_tag_editor_position(player)
  if not player or type(player) ~= "userdata" or not player.index then return end
  local global_data = StorageInit.get()
  global_data.tag_editor_positions = global_data.tag_editor_positions or {}
  global_data.tag_editor_positions[player.index] = nil
end

return StorageInit
