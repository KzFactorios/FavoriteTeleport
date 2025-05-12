-- _user.lua
-- Wrapper utility for LuaPlayer-related checks and helpers

local M = {}

--- Wrapper for a LuaPlayer object
-- @param player LuaPlayer: The player object
local User = {}
User.__index = User

function M.new(player)
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

M.User = User

return M
