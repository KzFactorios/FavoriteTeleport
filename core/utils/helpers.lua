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
  return { x = Helpers.math_round(x_num), y = Helpers.math_round(y_num) }
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

--- Recursively search for a child element by name in a GUI tree, starting from a parent name.
--- If root is not provided, will search in all standard player GUI roots.
-- @param player LuaPlayer The player whose GUI to search
-- @param parent_name string The name of the parent element to search from
-- @param target_name string The name of the child element to find
-- @return LuaGuiElement|nil The found element or nil
local function find_gui_element_by_name(player, parent_name, target_name)
  if not player or not player.valid or not player.gui then return nil end
  local roots = { player.gui.screen, player.gui.left, player.gui.top, player.gui.center, player.gui.relative }
  local function find_parent(element)
    if not element or not element.valid then return nil end
    if element.name == parent_name then return element end
    for _, child in pairs(element.children) do
      local found = find_parent(child)
      if found then return found end
    end
    return nil
  end
  local parent = nil
  for _, root in ipairs(roots) do
    parent = find_parent(root)
    if parent then break end
  end
  if not parent then return nil end
  -- If looking for the parent itself, return it
  if parent_name == target_name then return parent end
  local function find_child(element)
    if not element or not element.valid then return nil end
    if element.name == target_name then return element end
    for _, child in pairs(element.children) do
      local found = find_child(child)
      if found then return found end
    end
    return nil
  end
  return find_child(parent)
end

Helpers.find_gui_element_by_name = find_gui_element_by_name

-- Deep equality check for two Lua tables (objects)
function Helpers.tables_equal(a, b)
  if a == b then return true end
  if type(a) ~= "table" or type(b) ~= "table" then return false end
  for k, v in pairs(a) do
    if type(v) == "table" and type(b[k]) == "table" then
      if not Helpers.tables_equal(v, b[k]) then return false end
    elseif v ~= b[k] then
      return false
    end
  end
  for k in pairs(b) do
    if a[k] == nil then return false end
  end
  return true
end

--- Returns a string in the format XXX.YYY from a map position table or string
function Helpers.map_position_to_pos_string(map_pos)
  if type(map_pos) == "string" then
    local x_str, y_str = map_pos:match("([%-?%d]+)%.([%-?%d]+)")
    if not x_str or not y_str then return nil end
    local x = tonumber(x_str)
    local y = tonumber(y_str)
    if not x or not y then return nil end
    map_pos = { x = x, y = y }
  end
  if type(map_pos) ~= "table" or type(map_pos.x) ~= "number" or type(map_pos.y) ~= "number" then return nil end
  local function pad(n)
    local sign = n < 0 and "-" or ""
    return string.format("%s%03d", sign, math.abs(Position.math_round(n)))
  end
  return string.format("%s.%s", pad(map_pos.x), pad(map_pos.y))
end

return Helpers
