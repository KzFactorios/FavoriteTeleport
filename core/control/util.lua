-- core/control/util.lua
-- Utility functions for control logic in FavoriteTeleport

-- luacheck: globals game
---@diagnostic disable: undefined-global

local Util = {}

--- Safely get a player by index
-- @param player_index integer
-- @return LuaPlayer|nil
function Util.get_player(player_index)
  if game and game.get_player then
    return game.get_player(player_index)
  end
  return nil
end

--- Helper to safely call a function and catch errors
-- @param fn function
-- @param ... any
-- @return any|nil, string|nil
function Util.safe_call(fn, ...)
  local ok, result = pcall(fn, ...)
  if not ok then
    if game and game.print then
      game.print("[FavoriteTeleport][ERROR] " .. tostring(result))
    end
    return nil, result
  end
  return result
end

return Util
