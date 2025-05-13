--- @class uint: number
--- Unsigned integer type alias for documentation

--- @class ChunkPosition
--- @field x number
--- @field y number
--- A MapPosition can be translated to a ChunkPosition by dividing the x/y values by 32.

--- @class LocalisedString : any

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
--- Factorio API: https://lua-api.factorio.com/latest/classes/LuaCustomChartTag.html
--- Represents a custom chart tag in Factorio
--- 
--- @class LuaForce
--- @field name string

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
--- @field teleport fun(pos: MapPosition, surface: LuaSurface, raise_teleported: boolean): boolean
--- @field print fun(msg: string)

--- @class LuaSurface
--- @field can_place_entity fun(name: string, position: MapPosition): boolean
--- @field find_non_colliding_position fun(name: string, center: MapPosition, radius: number, precision: number): MapPosition
--- @field is_chunk_generated fun(position: ChunkPosition): boolean
--- @field print fun(message: LocalisedString) prints a message to the players on a surface
--- @field name string
--- @field index uint