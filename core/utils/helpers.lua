-- helpers.lua
-- Utility functions for FavoriteTeleport mod

local Helpers = {}

--- Converts a MapPosition to a ChunkPosition by dividing x and y by 32
-- @param map_pos MapPosition
-- @return ChunkPosition
function Helpers.map_position_to_chunk_position(map_pos)
  return {
    x = math.floor(map_pos.x / 32),
    y = math.floor(map_pos.y / 32)
  }
end

--- Converts a ChunkPosition to the top-left MapPosition of the chunk by multiplying x and y by 32
-- @param chunk_pos ChunkPosition
-- @return MapPosition
function Helpers.chunk_position_to_map_position(chunk_pos)
  return {
    x = chunk_pos.x * 32,
    y = chunk_pos.y * 32
  }
end

local function format_coord(n)
  local abs_n = math.abs(math.floor(n))
  local sign = n < 0 and ""
  return string.format("%s%03d", sign, abs_n)
end

function Helpers.format_gps(surface_index, x, y)
  return string.format("%s.%s.%s", tostring(surface_index), format_coord(x), format_coord(y))
end

--- Converts a gps (e.g., "2.000.-1350") to a MapPosition - surface index is not considered here
-- @param gps string
-- @return MapPosition
function Helpers.gps_to_map_position(gps)
  local _, x_str, y_str = gps:match("([%-?%d]+)%.([%-?%d]+)%.([%-?%d]+)")
  local x = tonumber(x_str)
  local y = tonumber(y_str)
  if x == -0 then x = 0 end
  if y == -0 then y = 0 end
  return {
    x = x,
    y = y
  }
end

--- Converts a MapPosition to a gps string (e.g., "000.-1350")
-- @param map_pos MapPosition
-- @return string
function Helpers.map_position_to_gps(surface_index, map_pos)
  if not map_pos then
    -- Log or handle the nil map_pos case here if needed
    return nil
  end
  return Helpers.format_gps(surface_index, map_pos.x, map_pos.y)
end

function Helpers.gps_from_map_tag(map_tag)
  if not map_tag then return nil end
  return Helpers.format_gps(map_tag.surface_index, map_tag.gps)
end

function Helpers.get_surface_index_from_gps(gps)
  if not gps then return nil end
  local surface_index, _x, _y = gps:match("([%-?%d]+)%.([%-?%d]+)%.([%-?%d]+)")
  return surface_index
end

-- Defensive: iterate event table to find player_index
function Helpers.find_player_index_in_event(event)
  for k, v in pairs(event) do
    if tostring(k) == "player_index" then
      return v
    end
  end
  return nil
end

-- Returns a new array with slot_num set and sorted by index order
function Helpers.array_sort_by_index(array)
  local arr = {}
  for i, item in ipairs(array) do
    if type(item) == "table" then
      item.slot_num = i
      arr[#arr + 1] = item
    end
  end
  return arr
end

--- Creates an index-based array of empty tables of given length
-- @param count integer
-- @return table
function Helpers.create_empty_indexed_array(count)
  local arr = {}
  for i = 1, count do
    arr[i] = {}
  end
  return arr
end

--- Returns true if the given table is empty, false otherwise
-- @param tbl table
-- @return boolean
function Helpers.table_is_empty(tbl)
  if type(tbl) ~= "table" then return true end
  return next(tbl) == nil
end

--- Returns true if the favorite slot is empty (no gps and no map_tag)
-- @param fav table
-- @return boolean
function Helpers.favorite_slot_is_empty(fav)
  return not fav or (fav.gps == nil or fav.gps == "")
end

--- Finds a favorite by gps in a surface's favorites array
-- @param favorites table[]
-- @param gps string
-- @return table|nil, integer|nil
function Helpers.find_favorite_by_gps(favorites, gps)
  for i, fav in ipairs(favorites) do
    if fav and fav.gps == gps then
      return fav, i
    end
  end
  return nil, nil
end

--- Returns a slot-accurate array of favorites for a surface, sorted by slot, filling missing slots with nil.
-- @param favorites table[]
-- @param max_slots integer
-- @return table[]
function Helpers.get_surface_favorites_array(favorites, max_slots)
  local arr = {}
  for i = 1, max_slots do
    arr[i] = favorites[i] or nil
  end
  return arr
end

return Helpers
