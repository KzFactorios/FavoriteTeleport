--- @class uint: number
--- Unsigned integer type alias for documentation

---@class ChartTagSpec
---@field position MapPosition
---@field icon SignalID?
---@field text string?
---@field last_user string?

--- @class ChunkPosition
--- @field x number
--- @field y number
--- A MapPosition can be translated to a ChunkPosition by dividing the x/y values by 32.

--- @class LocalisedString : any

--- @class LuaCustomTable
--- Represents a custom table in Factorio, behaves like a Lua table but with additional API features
--- @field [any] any  -- Can be indexed with any key, returns any value
--- @return LuaCustomTable  -- Returns itself for chaining and compatibility

--- @class MapPosition
--- @field x number
--- @field y number

--- @class SignalID
--- @field type string?  
--- @field name string?  
--- @field quality string?  

--- @class LuaCustomChartTag
--- @field icon SignalID
--- @field last_user LuaPlayer?
--- @field position MapPosition
--- @field text string
--- @field surface LuaSurface
--- @field valid boolean
--- @field print fun(msg: string)
--- @field destroy fun()
--- Factorio API: https://lua-api.factorio.com/latest/classes/LuaCustomChartTag.html
--- Represents a custom chart tag in Factorio
--- 
--- @class LuaForce
--- @field name string
--- @field add_chart_tag fun(surface:LuaSurface, tag: ChartTagSpec):LuaCustomChartTag

--- @class LuaPlayer
--- Factorio API: https://lua-api.factorio.com/latest/classes/LuaPlayer.html
--- Represents a player in Factorio
--- @field admin boolean
--- @field name string
--- @field index uint
--- @field valid boolean
--- @field connected boolean
--- @field surface LuaSurface
--- @field position MapPosition
--- @field force LuaForce
--- @field mod_settings LuaCustomTable
--- @field teleport fun(pos: MapPosition, surface: LuaSurface, raise_teleported: boolean): boolean
--- @field print fun(msg: string)

--- @class LuaSurface
--- @field can_place_entity fun(name: string, position: MapPosition): boolean
--- @field find_non_colliding_position fun(name: string, center: MapPosition, radius: number, precision: number): MapPosition
--- @field is_chunk_generated fun(position: ChunkPosition): boolean
--- @field print fun(message: LocalisedString) prints a message to the players on a surface
--- @field name string
--- @field index uint