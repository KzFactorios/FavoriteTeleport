-- validation.lua
-- Validation helpers for FavoriteTeleport

local Validation = {}

function Validation.is_valid_map_position(pos)
  return type(pos) == "table" and type(pos.x) == "number" and type(pos.y) == "number"
end

return Validation
