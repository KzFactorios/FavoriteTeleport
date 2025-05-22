-- Cache initialization, schema, and migration logic for FavoriteTeleport

local Cache = {}
local Constants = require("constants")
local PlayerFavorites = require("core.cache.player_favorites")
local Helpers = require("core.utils.helpers")
local mod_version = require("core.version")

-- All persistent data must be stored ONLY in global.FavoriteTeleport
-- No use of _G.cache or any other global for persistence

local function ensure_schema()
  global.FavoriteTeleport = global.FavoriteTeleport or {}
  local cache = global.FavoriteTeleport
  cache.mod_version = cache.mod_version or mod_version
  cache.tag_editor_positions = cache.tag_editor_positions or {}
  cache.players = cache.players or {}
  cache.surfaces = cache.surfaces or {}
  for surface_index, surface_data in pairs(cache.surfaces) do
    surface_data.map_tags = surface_data.map_tags or {}
    if surface_data.chart_tags then
      surface_data.chart_tags = nil
    end
  end
end

function Cache.init()
  ensure_schema()
  Cache.inject_player_favorites_dependency()
end

function Cache.get_data()
  Cache.init()
  return global.FavoriteTeleport
end

function Cache.get_player_favorites(player)
  return PlayerFavorites.get_player_favorites(player)
end

function Cache.get_player_data(player)
  if not player or not player.index then return {} end
  local cache = Cache.get_data()
  cache.players = cache.players or {}
  cache.players[player.index] = cache.players[player.index] or {}
  return cache.players[player.index]
end

function Cache.get_player_data_by_player_index(player_index)
  local cache = Cache.get_data()
  cache.players = cache.players or {}
  cache.players[player_index] = cache.players[player_index] or {}
  return cache.players[player_index]
end

function Cache.inject_player_favorites_dependency()
  PlayerFavorites.get_player_data = Cache.get_player_data
end

function Cache.get_surface_data(player)
  if not player or not player.surface or not player.surface.index then return nil end
  local cache = Cache.get_data()
  local surface_index = player.surface.index
  cache.surfaces[surface_index] = cache.surfaces[surface_index] or {}
  local surface_data = cache.surfaces[surface_index]
  if not surface_data.chart_tags or type(surface_data.chart_tags) ~= "table" or next(surface_data.chart_tags) == nil then
    surface_data.chart_tags = player.force.find_chart_tags(player.surface) or {}
  end
  if not surface_data.map_tags or type(surface_data.map_tags) ~= "table" then
    surface_data.map_tags = {}
  end
  return surface_data
end

function Cache.get_map_tags_table(surface_index)
  local cache = Cache.get_data()
  cache.surfaces[surface_index] = cache.surfaces[surface_index] or {}
  cache.surfaces[surface_index].map_tags = cache.surfaces[surface_index].map_tags or {}
  return cache.surfaces[surface_index].map_tags
end

function Cache.add_or_update_map_tag(player, map_tag)
  local surface_index = player.surface.index
  local map_tags = Cache.get_map_tags_table(surface_index)
  if not map_tag or not map_tag.gps then return end
  map_tags[map_tag.gps] = map_tag
end

function Cache.get_map_tags(player)
  local surface_index = player.surface.index
  local map_tags = Cache.get_map_tags_table(surface_index)
  local tags = {}
  for _, tag in pairs(map_tags) do
    table.insert(tags, tag)
  end
  return tags
end

function Cache.find_chart_tag_by_gps(player, gps)
  if not player or not gps then return nil end
  local surface_data = Cache.get_surface_data(player)
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

function Cache.find_map_tag_by_gps(player, gps)
  local surface_index = player.surface.index
  local map_tags = Cache.get_map_tags_table(surface_index)
  return map_tags[gps]
end

function Cache.get_available_favorite_slots_count(player)
  local favorites = Cache.get_player_favorites(player)
  local max_slots = Constants.MAX_FAVORITE_SLOTS
  local count = 0
  for i = 1, max_slots do
    if not favorites[i] or not favorites[i].map_tag and favorites[i].map_tag ~= {} then
      count = count + 1
    end
  end
  return count
end

function Cache.reset_cached_chart_tags(surface_index)
  local cache = Cache.get_data()
  if cache.surfaces and cache.surfaces[surface_index] then
    cache.surfaces[surface_index].chart_tags = {}
  end
end

function Cache.rehome_chart_tag(player, chart_tag, gps)
  if not player or not chart_tag or not gps then return chart_tag end
  local surface = player.surface
  local surface_index = surface.index
  local gps_from_chart_tag = Helpers.format_gps(chart_tag.position.x, chart_tag.position.y, surface_index)
  if gps_from_chart_tag == gps then
    return chart_tag
  end
  local matching_favorites = {}
  local found_map_tag = Cache.find_map_tag_by_gps(player, gps)
  if found_map_tag then
    for _, players in pairs(_G.game.players) do
      for _, favorite in pairs(Cache.get_player_favorites(player)) do
        if favorite.gps == gps then
          table.insert(matching_favorites, favorite)
        end
      end
    end
  end
  local new_pos = Helpers.gps_to_map_position(gps)
  if not new_pos then return chart_tag end
  local tag_spec = {
    position = new_pos,
    icon = chart_tag.icon,
    text = chart_tag.text,
    last_user = chart_tag.last_user and chart_tag.last_user.name or "",
  }
  local new_chart_tag = player.force.add_chart_tag(surface, tag_spec)
  if new_chart_tag then
    local update_gps = Helpers.format_gps(new_chart_tag.position.x, new_chart_tag.position.y, player.surface.index)
    for _, favorite in pairs(matching_favorites) do
      favorite.gps = update_gps
    end
    if found_map_tag then
      found_map_tag.gps = update_gps
    end
    pcall(function() chart_tag.destroy() end)
  end
  return new_chart_tag or chart_tag
end

function Cache.get_tag_editor_position(player)
  if not player or type(player) ~= "userdata" or not player.index then return nil end
  local cache = Cache.get_data()
  return cache.tag_editor_positions[player.index] or nil
end

function Cache.set_tag_editor_position(player, pos)
  if not player or type(player) ~= "userdata" or not player.index then return end
  local cache = Cache.get_data()
  cache.tag_editor_positions = cache.tag_editor_positions or {}
  cache.tag_editor_positions[player.index] = pos
end

function Cache.clear_tag_editor_position(player)
  if not player or type(player) ~= "userdata" or not player.index then return end
  local cache = Cache.get_data()
  cache.tag_editor_positions = cache.tag_editor_positions or {}
  cache.tag_editor_positions[player.index] = nil
end

function Cache.remove_map_tag(player, gps)
  local surface_index = player.surface.index
  local map_tags = Cache.get_map_tags_table(surface_index)
  map_tags[gps] = nil
end

return Cache
