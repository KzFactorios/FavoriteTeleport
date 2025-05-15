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

--- Converts a pos_string (e.g., "000.-1350") to a MapPosition
-- @param pos_string string
-- @return MapPosition
function Helpers.pos_string_to_map_position(pos_string)
  local x_str, y_str = pos_string:match("([%-?%d]+)%.([%-?%d]+)")
  local x = tonumber(x_str)
  local y = tonumber(y_str)
  if x == -0 then x = 0 end
  if y == -0 then y = 0 end
  return {
    x = x,
    y = y
  }
end

--- Converts a MapPosition to a pos_string (e.g., "000.-1350")
-- @param map_pos MapPosition
-- @return string
function Helpers.map_position_to_pos_string(map_pos)
  if not map_pos then
    -- Log or handle the nil map_pos case here if needed
    return "nil"
  end
  local function format_coord(n)
    local abs_n = math.abs(math.floor(n))
    local sign = n < 0 and "-" or ""
    return string.format("%s%03d", sign, abs_n)
  end
  return string.format("%s.%s", format_coord(map_pos.x), format_coord(map_pos.y))
end

return Helpers
