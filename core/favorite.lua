--- @class Favorite
--- Represents a favorite teleport location for a player
--- @field maptag MapTag 
--- @field created_by string
local Favorite = {}

--- Creates a new Favorite instance
-- @param maptag MapTag The associated map tag
-- @param created_by string The player index or name who created the favorite
-- @return Favorite
function Favorite.new(maptag, created_by)
  local self = setmetatable({}, { __index = Favorite })
  self.maptag = maptag
  self.created_by = created_by
  return self
end

return Favorite
