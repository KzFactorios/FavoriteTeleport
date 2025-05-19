-- helpers.lua
-- Utility functions for FavoriteTeleport mod

local Helpers = {}

--- Have we selected a point that is not in the fog of war? Not on water, etc
--- For our chart_tags, since they are being used for teleportation, they need
--- to be checked for a valid landing spot
function Helpers.position_can_be_tagged(player, map_position)
  if not player then return false end
  local chunk_position = {
    x = Helpers.math_round(map_position.x / 32),
    y = Helpers.math_round(map_position.y / 32)
  }

  if not player.force.is_chunk_charted(player.surface, chunk_position) then
    return false
  end

  -- Check if the tile at the position is water (by collision mask)
  local tile = player.surface.get_tile(math.floor(map_position.x), math.floor(map_position.y))
  if tile and tile.valid and tile.prototype and tile.prototype.collision_mask then
    for _, mask in pairs(tile.prototype.collision_mask) do
      if mask["water_tile"] and mask["water_tile"] == true then
        return false
      end
    end
  end

  return true
end

--- evaluates player surface and determines if player is in space
function Helpers.is_on_space_platform(player)
  if not player then return false end
  if not player.surface.map_gen_settings then return false end

  -- Planets have either default/custom terrain gen or specific planet presets
  local map_gen = player.surface.map_gen_settings
  return map_gen.preset == "space-platform" or map_gen.preset == "space"
end

--- returns the position of the first colliding tag in the area
--- @params player LuaPlayer
--- @params map_position MapPosition
--- @params snap_scale number
--- @returns table|nil
function Helpers.position_has_colliding_tag(player, map_position, snap_scale)
  if not player then return nil end

  local collision_area = {
    left_top = {
      x = map_position.x - snap_scale + 0.1,
      y = map_position.y - snap_scale + 0.1
    },
    right_bottom = {
      x = map_position.x + snap_scale - 0.1,
      y = map_position.y + snap_scale - 0.1
    }
  }

  local colliding_tags = player.force.find_chart_tags(player.surface, collision_area)
  if colliding_tags and #colliding_tags > 0 then
    return colliding_tags[1].position
  end

  return nil
end

function Helpers.has_decimal_point(s)
  return tostring(s):find("%.") ~= nil
end

--- convert a position to whole number coordinates
--- @returns MapPosition
function Helpers.simplify_position(pos)
  local x = (pos and type(pos.x) == "number" or pos and type(pos.x) == "string") and pos.x or 0
  local y = (pos and type(pos.y) == "number" or pos and type(pos.y) == "string") and pos.y or 0
  if Helpers.has_decimal_point(tostring(x)) then
    x = Helpers.math_round(x)
  end
  if Helpers.has_decimal_point(tostring(y)) then
    y = Helpers.math_round(y)
  end
  return { x = x, y = y }
end

--- Helper function for rounding numbers since Lua does not have math.round by default
--- @return integer
function Helpers.math_round(n)
  if type(n) ~= "number" then return 0 end
  local rounded = n >= 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
  if tostring(rounded) == "-0" then
    rounded = 0
  end
  return rounded
end

function Helpers.snap_position(position, snap_scale)
  return {
    x = Helpers.math_round(position.x / snap_scale) * snap_scale,
    y = Helpers.math_round(position.y / snap_scale) * snap_scale
  }
end

--- Converts a MapPosition to a ChunkPosition by dividing x and y by 32
-- @param map_pos MapPosition
-- @return ChunkPosition
function Helpers.map_position_to_chunk_position(map_pos)
  return {
    x = Helpers.math_round(map_pos.x / 32),
    y = Helpers.math_round(map_pos.y / 32)
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
  local _n = math.abs(Helpers.math_round(n))
  local sign = n < 0 and "-" or ""
  return string.format("%s%03d", sign, _n)
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
  if not map_pos then return nil end
  return Helpers.format_gps(Helpers.math_round(map_pos.x), Helpers.math_round(map_pos.y), surface_index)
end

--- Converts a gps string to a MapPosition without surface info. Format: "xxx.yyy"
-- @param gps string
-- @return MapPosition
function Helpers.gps_to_map_position(gps)
  local x_str, y_str, _ = gps:match("([%-?%d]+)%.([%-?%d]+)%.([%-?%d]+)")
  if not x_str or not y_str then return end
  local x_num = tonumber(x_str)
  local y_num = tonumber(y_str)
  if not x_num or not y_num then return end
  local x = Helpers.math_round(x_num)
  local y = Helpers.math_round(y_num)
  return { x = x, y = y }
end

--- Returns the "xxx.yyy" portion from a gps. No surface info
-- @param gps string
-- @return string
function Helpers.gps_to_map_position_string(gps)
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

function Helpers.format_sprite_path(type, name, is_signal)
  -- TODO what to do if type is signal?
  if not name then name = "" end
  if not type then type = "" end

  if type == "" and not is_signal then type = "item" end
  if type == "virtual" then
    type = "virtual-signal"
  end
  if type ~= "" then
    type = type .. "/"
  end

  local sprite_path = type .. name
  if not _G.helpers.is_valid_sprite_path(sprite_path) then
    -- TODO better user messaging on error
    return ""
  end

  return sprite_path
end

--- when you want to find a uint in an array of uints
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

--- Returns a new array with slot_num set and sorted by index order
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

--- Finds a favorite by gps in the given array. eg: a player's surface favorites array
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

--- @returns any|nil, int|nil 
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

--- Validation helpers ---
function Helpers.is_valid_map_position(pos)
  return type(pos) == "table" and type(pos.x) == "number" and type(pos.y) == "number"
end

function Helpers.is_nonempty_string(s)
  return type(s) == "string" and s:match("%S") ~= nil
end

--- Table/array utility: shallow copy
function Helpers.shallow_copy(tbl)
  local t = {}
  for k, v in pairs(tbl) do t[k] = v end
  return t
end

--- Table/array utility: remove by value (first occurrence)
function Helpers.remove_first(tbl, value)
  for i, v in ipairs(tbl) do
    if v == value then table.remove(tbl, i); return true end
  end
  return false
end

return Helpers
