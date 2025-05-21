-- favorite_slots.lua
-- Favorite slot helpers for FavoriteTeleport

local FavoriteSlots = {}
local StringUtils = require("core.utils.string_utils")
local Position = require("core.utils.position")

function FavoriteSlots.init_favorite_slots(slots, max_slots)
  for i = 1, max_slots do
    if not slots[i] or type(slots[i]) ~= "table" then
      slots[i] = { gps = "", slot_locked = false }
    end
  end
  -- Remove any extra slots
  for i = #slots, max_slots + 1, -1 do
    slots[i] = nil
  end
  return slots
end

function FavoriteSlots.is_valid_favorite_slot(fav)
  return type(fav) == "table" and type(fav.gps) == "string" and fav.gps ~= "" and not fav.slot_locked
end

function FavoriteSlots.find_favorite_by_gps(favorites, gps)
  for i, fav in ipairs(favorites) do
    if fav and fav.gps == gps then
      return fav, i
    end
  end
  return nil, nil
end

function FavoriteSlots.format_favorite_tooltip(fav)
  if not fav or not fav.gps or fav.gps == "" then return "Empty favorite slot" end
  local Helpers = require("core.utils.helpers")
  local tooltip = Helpers.map_position_to_pos_string(fav.gps)
  if fav and fav.map_tag ~= nil and type(fav.map_tag) == "table" and fav.map_tag.text ~= nil and fav.map_tag.text ~= "" then
    tooltip = tooltip .. "\n" .. fav.map_tag.text
  end
  return tooltip
end


return FavoriteSlots
