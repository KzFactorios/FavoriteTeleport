-- context.lua
-- Persistent data storage and schema management

--- @class Context
--- @field get_player_data fun(player_index: uint): table
--- Handles persistent mod data and schema management for FavoriteTeleport
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
