-- context.lua
--- Handles persistent mod data and schema management for FavoriteTeleport
-- This module acts as an abstraction layer over the core persistent cache (see core/cache.lua).
-- While currently a thin wrapper, it is intended for future-proofing:
--   - Centralizing schema migrations and version upgrades
--   - Supporting multi-mod or cross-mod data integration
--   - Adding validation, access control, or data transformation logic
--   - Decoupling the rest of the mod from direct cache implementation details
--
-- All persistent data access should go through Context, not Cache, to allow for future extensibility.

--- @class Context
--- @field _data table
--- @field get_player_data fun(player: LuaPlayer): table
--- @field player LuaPlayer
local Context = {}

local Cache = require("core.cache.init")

--- Initializes the persistent cache schema if needed
function Context.init()
  Cache.init()
end

--- Gets the mod's global persistent data
-- @return table
function Context.get_data()
  if type(Context) ~= "table" then return {} end
  if type(Context._data) ~= "table" then
    Context._data = Cache.get_data() or {}
  end
  return Context._data
end

--- Gets persistent data for a specific player by index
-- @param player LuaPlayer|nil
-- @return table
function Context.get_player_data(player)
  if not player then return {} end
  if not Context.player then Context.player = player end
  local pdata = Cache.get_player_data(player)
  if type(pdata) ~= "table" then return {} end
  return pdata
end

--- Saves the mod's persistent data
-- @param data table
function Context.save_data(data)
  -- No-op: saving is handled by Factorio's global table
end

return Context
