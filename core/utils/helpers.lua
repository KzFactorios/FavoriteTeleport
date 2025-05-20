-- helpers.lua
-- Utility functions for FavoriteTeleport mod

local Position = require("core.utils.position")
local StringUtils = require("core.utils.string_utils")
local TableUtils = require("core.utils.table_utils")
local FavoriteSlots = require("core.utils.favorite_slots")
local Validation = require("core.utils.validation")


local Helpers = {}

-- Math/position helpers
Helpers.math_round = Position.math_round
Helpers.has_decimal_point = Position.has_decimal_point
Helpers.simplify_position = Position.simplify_position
Helpers.snap_position = Position.snap_position
Helpers.map_position_to_chunk_position = Position.map_position_to_chunk_position
Helpers.chunk_position_to_map_position = Position.chunk_position_to_map_position

-- String helpers
Helpers.split_string = StringUtils.split_string
Helpers.is_nonempty_string = StringUtils.is_nonempty_string

-- Table/array helpers
Helpers.shallow_copy = TableUtils.shallow_copy
Helpers.remove_first = TableUtils.remove_first
Helpers.table_is_empty = TableUtils.table_is_empty
Helpers.create_empty_indexed_array = TableUtils.create_empty_indexed_array
Helpers.array_sort_by_index = TableUtils.array_sort_by_index
Helpers.index_is_in_table = TableUtils.index_is_in_table
Helpers.find_by_predicate = TableUtils.find_by_predicate

-- Favorite slot helpers
Helpers.init_favorite_slots = FavoriteSlots.init_favorite_slots
Helpers.is_valid_favorite_slot = FavoriteSlots.is_valid_favorite_slot
Helpers.find_favorite_by_gps = FavoriteSlots.find_favorite_by_gps
Helpers.format_favorite_tooltip = FavoriteSlots.format_favorite_tooltip
Helpers.map_position_to_pos_string = FavoriteSlots.map_position_to_pos_string

-- Validation helpers
Helpers.is_valid_map_position = Validation.is_valid_map_position

function Helpers.format_gps(x, y, surface_index)
  local function format_coord(n)
    local _n = math.abs(Helpers.math_round(n))
    local sign = n < 0 and "-" or ""
    return string.format("%s%03d", sign, _n)
  end
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

--- Converts a gps string to a MapPosition without surface info. Format: "{X: x, y: y}"
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
  local sprite_path = (type ~= "" and (type .. "/") or "") .. name
  if not (_G.helpers and _G.helpers.is_valid_sprite_path and _G.helpers.is_valid_sprite_path(sprite_path)) then
    -- TODO better user messaging on error
    return ""
  end
  return sprite_path
end

return Helpers
