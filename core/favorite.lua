--- @class Favorite
--- Represents a favorite teleport location for a player
--- @field surface_index uint
--- @field gps string
--- @field slot_locked boolean
local Favorite = {}

local Helpers = require("core.utils.helpers")
local storage = require("core.storage")

--- Creates a new Favorite instance for a given surface
-- @param surface_index uint The surface index
-- @param gps string The gps string for the favorite
-- @param slot_locked boolean Whether the slot is locked
-- @return Favorite
function Favorite.new(surface_index, gps, slot_locked)
  local self = setmetatable({}, { __index = Favorite })
  self.surface_index = surface_index
  self.gps = gps or ""
  self.slot_locked = slot_locked or false
  return self
end

--- Returns the map_tag for this favorite (from storage for this surface)
function Favorite:get_map_tag()
  return storage.find_map_tag_by_gps_for_surface(self.surface_index, self.gps)
end

return Favorite

