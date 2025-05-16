-- context.lua
-- Persistent data storage and schema management

--- @class Context
--- @field get_player_data fun(player_index: uint): table
--- Handles persistent mod data and schema management for FavoriteTeleport
--
-- This module acts as an abstraction layer over the core persistent storage (see core/storage.lua).
-- While currently a thin wrapper, it is intended for future-proofing:
--   - Centralizing schema migrations and version upgrades
--   - Supporting multi-mod or cross-mod data integration
--   - Adding validation, access control, or data transformation logic
--   - Decoupling the rest of the mod from direct storage implementation details
--
-- All persistent data access should go through Context, not Storage, to allow for future extensibility.
local Context = {}

local Storage = require("core/storage")

--- Initializes the persistent storage schema if needed
function Context.init()
  Storage.init()
end

--- Gets the mod's global persistent data
-- @return table
function Context.get_data()
  return Storage.get_data()
end

--- Gets persistent data for a specific player by index
-- @param player_index integer
-- @return table
function Context.get_player_data(player_index)
  return Storage.get_player_data(player_index)
end

--- Saves the mod's persistent data
-- @param data table
function Context.save_data(data)
  Storage.save_data(data)
end

return Context
