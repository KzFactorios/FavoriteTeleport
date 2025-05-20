-- favorite_ops.lua
-- Favorite add/remove/update logic for TagEditorGUI

local FavoriteOps = {}
local Storage = require("core.storage")
local Helpers = require("core.utils.helpers")
local MapTag = require("core.map_tag")

function FavoriteOps.update_favorite(player, gps, slot_locked)
  slot_locked = slot_locked or false
  local favorites = Storage.get_player_favorites(player)
  -- Find an empty slot or replace existing
  local found = false
  for i = 1, #favorites do
    if favorites[i] and favorites[i].gps == gps then
      favorites[i].slot_locked = slot_locked
      found = true
      break
    elseif not favorites[i] or favorites[i].gps == "" then
      favorites[i] = { gps = gps, slot_locked = slot_locked }
      found = true
      break
    end
  end
  -- If not found and not full, append
  if not found and #favorites < 10 then
    table.insert(favorites, { gps = gps, slot_locked = slot_locked })
  end
  -- Update all map_tags for all players if this favorite affects shared tags
  for _, other in pairs(_G.game.players) do
    local map_tag = Storage.find_map_tag_by_gps(other, gps)
    if map_tag then
      map_tag.faved_by_players = map_tag.faved_by_players or {}
      local is_in = false
      for _, idx in ipairs(map_tag.faved_by_players) do
        if idx == player.index then is_in = true; break end
      end
      table.insert(map_tag.faved_by_players, player.index)
      Storage.add_or_update_map_tag(other, map_tag)
    end
  end
  -- Always ensure all slots are initialized after any change
  Storage.ensure_favorite_slots_initialized(favorites, player.surface.index)
end

function FavoriteOps.remove_favorite(player, gps)
  local favorites = Storage.get_player_favorites(player)
  for i, fav in ipairs(favorites) do
    if fav and fav.gps == gps then
      favorites[i] = nil
      break
    end
  end

  -- Ensure the favorites array is always filled to MAX_FAVORITE_SLOTS
  Storage.ensure_favorite_slots_initialized(player)
  
  -- Update all map_tags for all players if this favorite affects shared tags
  for _, other in pairs(_G.game.players) do
    local map_tag = Storage.find_map_tag_by_gps(other, gps)
    if map_tag then
      -- map_tag.faved_by_players is always a table
      for idx = #map_tag.faved_by_players, 1, -1 do
        if map_tag.faved_by_players[idx] == player.index then
          table.remove(map_tag.faved_by_players, idx)
        end
      end
      Storage.add_or_update_map_tag(other, map_tag)
    end
  end
end

return FavoriteOps
