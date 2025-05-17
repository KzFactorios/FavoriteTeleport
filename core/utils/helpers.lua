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
  local sign = n < 0 and "-" or ""
  return string.format("%s%03d", sign, abs_n)
end

function Helpers.format_gps(x, y, surface_index)
  return string.format("%s.%s.%s", format_coord(x), format_coord(y), tostring(surface_index))
end

--- Converts a MapPosition to a gps string (e.g., "000.-1350.1")
-- gps string format: "x coordinate as string, min 3 chars"."y coordinate as string, min 3 chars"."surface_index as string (no padding)"
-- @param map_pos MapPosition
-- @param surface_index integer|string
-- @return string
function Helpers.map_position_to_gps(map_pos, surface_index)
  if not map_pos then
    -- Log or handle the nil map_pos case here if needed
    return nil
  end
  return Helpers.format_gps(map_pos.x, map_pos.y, surface_index)
end

--- Converts a gps string to a MapPosition. Format: "xxx.yyy.surface_index" (surface_index is ignored here)
-- @param gps string
-- @return MapPosition
function Helpers.gps_to_map_position(gps)
  local x_str, y_str, _ = gps:match("([%-?%d]+)%.([%-?%d]+)%.([%-?%d]+)")
  local x = math.floor(x_str)
  local y = math.floor(y_str)
  if x == -0 then x = 0 end
  if y == -0 then y = 0 end
  return {
    x = x,
    y = y
  }
end

--- Returns the "xxx.yyy" portion from a gps string of the format "xxx.yyy.surface_index"
-- @param gps string
-- @return string
function Helpers.gps_map_position_string(gps)
  local split = Helpers.split_string(gps, '.')
  return string.format("%s.%s", split[1], split[2])
end

--- Returns the surface_index portion from a gps string of the format "xxx.yyy.surface_index"
-- @param gps string
-- @return string|nil
function Helpers.get_surface_index_from_gps(gps)
  if not gps then return nil end
  local _x, _y, surface_index = gps:match("([%-?%d]+)%.([%-?%d]+)%.([%-?%d]+)")
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

function Helpers.index_is_in_table(_table, idx)
  if type(_table) == "table" then
    for x, v in pairs(_table) do
      if v == idx then
        return true, x
      end
    end
  end
  return false, -1
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
  return not fav or (fav.map_tag == nil or fav.map_tag == {})
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

-- Splits a string by the given delimiter and returns an array of substrings
-- @param str string
-- @param delimiter string
-- @return table
function Helpers.split_string(str, delimiter)
  local result = {}
  if type(str) ~= "string" or type(delimiter) ~= "string" or delimiter == "" then
    return result
  end
  local pattern = string.format("([^%s]+)", delimiter:gsub("%%", "%%%%"))
  for match in str:gmatch(pattern) do
    table.insert(result, match)
  end
  return result
end

function Helpers.find_by_predicate(_table, predicate)
  if type(_table) ~= "table" or type(predicate) ~= "function" then
    return nil, nil
  end
  for k, v in pairs(_table) do
    if predicate(v, k) then
      return v, k
    end
  end
  return nil, nil
end

return Helpers
