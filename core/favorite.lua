--- Represents a favorite teleport location for a player
--- @class Favorite
--- @field gps string
--- @field slot_locked boolean
local Favorite = {}

local Storage = require("core.storage")
local Helpers = require("core.utils.helpers")

--- Creates a new Favorite instance for a given surface
-- @param surface_index uint The surface index
-- @param gps string The gps string for the favorite
-- @param slot_locked boolean Whether the slot is locked
-- @return Favorite
function Favorite.new(gps, slot_locked)
  local self = setmetatable({}, { __index = Favorite })
  self.gps = gps or ""
  self.slot_locked = slot_locked or false
  return self
end

--- Returns the map_tag for this favorite (from storage for this surface)
function Favorite:get_map_tag()
  return Storage.find_map_tag_by_gps(self.gps)
end

return Favorite

