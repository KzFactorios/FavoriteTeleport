-- core/cache/events.lua
-- Cache-related event handlers and multiplayer cleanup for FavoriteTeleport

local CacheEvents = {}
local Cache = require("core.cache.init")
local Helpers = require("core.utils.helpers")

--- Called when a player leaves the game; cleans up their tag ownership and favorites
function CacheEvents.on_player_left_game(player_index, player_name)
  if not _G.game or not _G.game.surfaces then return end
  local player = _G.game.players[player_index]
  if not player then return end

  local all_faves = {}
  local all_map_tags = {}
  local all_chart_tags = {}

  for _, surface in pairs(_G.game.surfaces) do
    if surface and surface.valid and type(surface) == "table" or type(surface) == "LuaSurface" then
      local favorites = Cache.get_player_favorites(player)
      local map_tags = Cache.get_map_tags(player)
      local chart_tags = _G.game.forces["player"].find_chart_tags(surface) or {}

      for _, o in pairs(favorites) do
        table.insert(all_faves, o)
      end
      for _, o in pairs(map_tags) do
        table.insert(all_map_tags, o)
      end
      for _, o in pairs(chart_tags) do
        table.insert(all_chart_tags, o)
      end
    end
  end

  local map_tags_to_delete = {}
  local chart_tags_to_update = {}
  local chart_tags_to_destroy = {}
  local chart_tag_gps_map = {}

  -- Build a lookup for chart tags by gps string for efficient matching
  for _, tag in pairs(all_chart_tags) do
    if tag and type(tag.position) == "table" then
      local gps_str = Helpers.format_gps(tag.position.x, tag.position.y, tag.surface.index)
      chart_tag_gps_map[gps_str] = chart_tag_gps_map[gps_str] or {}
      table.insert(chart_tag_gps_map[gps_str], tag)
    end
  end

  -- Remove player from map tag favorites, collect tags to delete
  for _, fave in pairs(all_faves) do
    local gps = fave.gps
    for _, map_tag in pairs(all_map_tags) do
      if map_tag.gps == gps and type(map_tag.remove_player_index_from_faved_by_players) == "function" then
        map_tag.remove_player_index_from_faved_by_players(player_index)
        if map_tag.faved_by_players and #map_tag.faved_by_players == 0 then
          table.insert(map_tags_to_delete, map_tag)
        end
      end
    end
    -- Collect chart tags to update and destroy
    local matching_tags = chart_tag_gps_map[gps] or {}
    for _, chart_tag in pairs(matching_tags) do
      if chart_tag.valid and chart_tag.last_user and chart_tag.last_user.name == player_name then
        table.insert(chart_tags_to_update, chart_tag)
      end
      -- If this chart tag matches a soon-to-be-deleted map tag, mark for destruction
      for _, map_tag in pairs(map_tags_to_delete) do
        if gps == map_tag.gps then
          table.insert(chart_tags_to_destroy, chart_tag)
        end
      end
    end
  end

  -- Update chart tags' last_user
  for _, chart_tag in pairs(chart_tags_to_update) do
    chart_tag.last_user = nil
  end

  -- Remove the map tags that were only favorited by this player
  -- and if there is an associated chart_tag, destroy it as well
  -- Use a set to avoid duplicate chart tag destruction
  local destroyed_chart_tags = {}
  for i = #map_tags_to_delete, 1, -1 do
    local map_tag = map_tags_to_delete[i]
    if map_tag and type(map_tag.destroy) == "function" then
      -- Destroy associated chart tags (if any)
      local gps = map_tag.gps
      local matching_tags = chart_tag_gps_map[gps] or {}
      for _, chart_tag in pairs(matching_tags) do
        if chart_tag and chart_tag.valid and type(chart_tag.destroy) == "function" and not destroyed_chart_tags[chart_tag] then
          chart_tag.destroy()
          destroyed_chart_tags[chart_tag] = true
        end
      end
      map_tag.destroy()
    end
  end
  -- Also destroy any chart tags that were marked for destruction but not already destroyed
  for i = #chart_tags_to_destroy, 1, -1 do
    local chart_tag = chart_tags_to_destroy[i]
    if chart_tag and chart_tag.valid and type(chart_tag.destroy) == "function" and not destroyed_chart_tags[chart_tag] then
      chart_tag.destroy()
      destroyed_chart_tags[chart_tag] = true
    end
  end

  
end

return CacheEvents
