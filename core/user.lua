-- _user.lua
-- Wrapper utility for LuaPlayer-related checks and helpers

--- @class User
--- @field player LuaPlayer
--- Wrapper for a LuaPlayer object with helper methods
local User = {}
User.__index = User

--- Creates a new User instance
-- @param player LuaPlayer
-- @return User
function User.new(player)
  local self = setmetatable({}, User)
  self.player = player
  return self
end

--- Checks if the player is an admin
function User:is_admin()
  return self.player and self.player.admin == true
end

--- Returns the player's name
function User:name()
  return self.player and self.player.name or nil
end

--- Returns the player's index
function User:index()
  return self.player and self.player.index or nil
end

--- Returns true if the player is valid and connected
function User:is_valid()
  return self.player and self.player.valid and self.player.connected
end

--- Returns the player's online status
function User:is_online()
  return self.player and self.player.connected == true
end

--- Returns the player's current surface index
function User:surface_index()
  return self.player and self.player.surface and self.player.surface.index or nil
end

--- Returns the player's position as a MapPosition
function User:position()
  return self.player and self.player.position or nil
end

--- Teleports the player to a given MapPosition
-- @param pos MapPosition
-- @return boolean success
function User:teleport(pos, surface, raise_teleported)
  if self:is_valid() and pos then
    return self.player.teleport and self.player.teleport(pos, surface, raise_teleported)
  end
  return false
end

--- Sends a message to the player
-- @param msg string
function User:print(msg)
  if self:is_valid() and msg then
    self.player.print(msg)
  end
end

--- Returns the player's force name
function User:force_name()
  return self.player and self.player.force and self.player.force.name or nil
end

return User
