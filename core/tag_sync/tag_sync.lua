-- tag_sync.lua
-- Robust syncing suite for map_tag, chart_tag, and favorite management using GPS as the key

local TagSync = {}
local Cache = require("core.cache.init")
local Helpers = require("core.utils.helpers")
local MapTag = require("core.map_tag")
local Constants = require("constants")

-- Create a new tag (map_tag + chart_tag) and update favorites
function TagSync.create_tag(player, gps, input)
  if type(gps) ~= "string" then
    error("[FavoriteTeleport][TagSync.create_tag] Expected gps as string, got " .. tostring(gps))
  end
  local map_position = Helpers.gps_to_map_position(gps)
  if type(map_position) ~= "table" or type(map_position.x) ~= "number" or type(map_position.y) ~= "number" then
    error("[FavoriteTeleport][TagSync.create_tag] gps did not convert to valid MapPosition: " .. tostring(gps))
  end
  -- Create chart_tag
  local tag_spec = {
    position = map_position,
    icon = input.icon or {},
    text = input.text or "",
    last_user = player.name
  }
  local chart_tag = player.force.add_chart_tag(player.surface, tag_spec)
  if not chart_tag then return nil, "Failed to create chart tag" end
  -- Create map_tag
  local map_tag = MapTag.new(player, map_position, chart_tag, input.is_favorite)
  Cache.add_or_update_map_tag(player, map_tag)
  -- Update favorite if needed
  if input.is_favorite then
    TagSync.sync_favorites(player, gps, true)
  end
  return map_tag, chart_tag
end

-- Update an existing tag (map_tag + chart_tag) and sync favorites
function TagSync.update_tag(player, gps, input)
  if type(gps) ~= "string" then
    error("[FavoriteTeleport][TagSync.update_tag] Expected gps as string, got " .. tostring(gps))
  end
  local map_tag = Cache.find_map_tag_by_gps(player, gps)
  local chart_tag = Cache.find_chart_tag_by_gps(player, gps)
  if not map_tag or not chart_tag then return nil, "Tag not found" end
  -- Update chart_tag (position is immutable)
  if input.icon then chart_tag.icon = input.icon end
  if input.text then chart_tag.text = input.text end
  chart_tag.last_user = player.name
  -- Update map_tag
  map_tag.created_by = player.name
  Cache.add_or_update_map_tag(player, map_tag)
  -- Sync favorite
  TagSync.sync_favorites(player, gps, input.is_favorite)
  return map_tag, chart_tag
end

-- Move a tag: create new chart_tag at new position, update map_tag, update favorites, delete old chart_tag
function TagSync.move_tag(player, old_gps, new_position)
  if type(old_gps) ~= "string" then
    error("[FavoriteTeleport][TagSync.move_tag] Expected old_gps as string, got " .. tostring(old_gps))
  end
  if type(new_position) ~= "table" or type(new_position.x) ~= "number" or type(new_position.y) ~= "number" then
    error("[FavoriteTeleport][TagSync.move_tag] Expected new_position as MapPosition table, got " .. tostring(new_position))
  end
  local old_chart_tag = Cache.find_chart_tag_by_gps(player, old_gps)
  local old_map_tag = Cache.find_map_tag_by_gps(player, old_gps)
  if not old_chart_tag or not old_map_tag then return nil, "Tag not found" end
  local new_gps = Helpers.format_gps(new_position.x, new_position.y, player.surface.index)
  -- Create new chart_tag
  local tag_spec = {
    position = new_position,
    icon = old_chart_tag.icon,
    text = old_chart_tag.text,
    last_user = player.name
  }
  local new_chart_tag = player.force.add_chart_tag(player.surface, tag_spec)
  if not new_chart_tag then return nil, "Failed to create new chart tag" end
  -- Update map_tag
  old_map_tag.gps = new_gps
  Cache.add_or_update_map_tag(player, old_map_tag)
  -- Update all player favorites
  for _, p in pairs(_G.game.players) do
    local faves = Cache.get_player_favorites(p)
    for _, fave in ipairs(faves) do
      if fave.gps == old_gps then
        fave.gps = new_gps
      end
    end
  end
  -- Delete old chart_tag
  pcall(function() old_chart_tag.destroy() end)
  return old_map_tag, new_chart_tag
end

-- Delete a tag (map_tag + chart_tag) and remove from all favorites
function TagSync.delete_tag(player, gps)
  if type(gps) ~= "string" then
    error("[FavoriteTeleport][TagSync.delete_tag] Expected gps as string, got " .. tostring(gps))
  end
  local map_tag = Cache.find_map_tag_by_gps(player, gps)
  local chart_tag = Cache.find_chart_tag_by_gps(player, gps)
  if map_tag then
    Cache.remove_map_tag(player, gps)
  end
  if chart_tag then
    pcall(function() chart_tag.destroy() end)
    -- After deleting a chart tag, reset the chart tag cache for the surface
    if player and player.surface and player.surface.index then
      Cache.reset_cached_chart_tags(player.surface.index)
    end
  end
  -- Remove from all player favorites
  for _, p in pairs(_G.game.players) do
    local faves = Cache.get_player_favorites(p)
    for i, fave in ipairs(faves) do
      if fave.gps == gps then
        faves[i] = { gps = "", slot_locked = false }
      end
    end
  end
  return true
end

-- Sync player favorites for a given gps: add or remove as favorite
function TagSync.sync_favorites(player, gps, is_favorite)
  if type(gps) ~= "string" then
    error("[FavoriteTeleport][TagSync.sync_favorites] Expected gps as string, got " .. tostring(gps))
  end
  local faves = Cache.get_player_favorites(player)
  local found = false
  for i, fave in ipairs(faves) do
    if fave.gps == gps then
      found = true
      if not is_favorite then
        faves[i] = { gps = "", slot_locked = false }
      end
    end
  end
  if is_favorite and not found then
    for i, fave in ipairs(faves) do
      if fave.gps == "" then
        faves[i] = { gps = gps, slot_locked = false }
        break
      end
    end
  end
end

return TagSync
