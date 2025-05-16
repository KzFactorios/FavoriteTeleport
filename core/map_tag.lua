--- @class MapTag
--- Represents a map tag object for FavoriteTeleport mod
--- @field gps string The position string (e.g., "000.-1350")
--- @field tag LuaCustomChartTag|nil The underlying Factorio chart tag object
--- @field created_by string The player index who created the tag
--- @field get_text fun(self: MapTag): string|nil The text for the tag
--- @field description string|nil Additional text for the tag
--- @field faved_by_players uint[]
--- @field new fun(chart_tag:LuaCustomChartTag, position: MapPosition, player: LuaPlayer, is_favorite:boolean, icon: SignalID, text: string, description: string): MapTag|nil
--- @field is_tag_valid fun(self: MapTag):boolean
--- @field on_chart_tag_modified fun(event: any)
local MapTag = {}

local Helpers = require("core.utils.helpers")
local Storage = require("core.storage")

-- If you previously required 'core/chart_tag', update to 'core/maptag' in your codebase as needed.
-- All logic and type definitions are now in MapTag.

-- Helper: format GPS from position
local function get_gps(surface_index, position)
  return Helpers.format_gps(surface_index, position.x, position.y)
end

--- Creates a new MapTag instance
-- @param chart_tag LuaCustomChartTag|nil Optional: The underlying Factorio chart tag object
-- @param position MapPosition
-- @param player LuaPlayer
-- @param is_favorite boolean
-- @param icon string|nil
-- @param text string|nil
-- @param description string|nil
-- @return MapTag
function MapTag.new(chart_tag, position, player, is_favorite, icon, text, description)
  if not player then return nil end
  local surface_index = player.surface.index
  local gps = get_gps(surface_index, position)

  if not chart_tag then
    local tag_spec = {
      position = Helpers.gps_to_map_position(gps),
      icon = icon,
      text = text,
      last_user = player.name
    }
    chart_tag = player.force.add_chart_tag(player.surface, tag_spec)
    if not chart_tag then return nil end
  end

  local faved_by_players
  if is_favorite then
    faved_by_players = {player.index}
  end

  local obj = {
    gps = gps,
    tag = chart_tag,
    faved_by_players = faved_by_players,
    created_by = player.name, -- Always use player.name for created_by (not index)
    text = text,
    description = description
  }
  setmetatable(obj, { __index = MapTag })
  return obj
end

---@diagnostic disable-next-line: undefined-field
function MapTag:get_text()
  return (self.tag and self.tag.text) or self.text or nil
end

--- Checks if the underlying map tag is valid
-- @param self MapTag
-- @return boolean
function MapTag:is_tag_valid()
  return self.tag ~= nil and self.tag.valid == true
end

-- handle changes from the stock tag editor
-- see if we can throw this only when the gui-tag-edit (stock editor) makes changes
function MapTag.on_chart_tag_modified(event)
  -- TODO implement
end

--- Creates a chart tag from a map_tag table for the given player and surface.
-- @param map_tag table The map_tag data (must have gps, text, icon, etc.)
-- @param player LuaPlayer The player for whom to create the chart tag
-- @return LuaCustomChartTag|nil The created chart tag, or nil on failure
function MapTag.create_chart_tag_from_map_tag(player, map_tag)
  if not map_tag or not player or not player.valid then return nil end
  local pos = nil
  if map_tag.gps then
    pos = Helpers.gps_to_map_position(map_tag.gps)
  end
  if not pos then return nil end
  local tag_spec = {
    position = pos,
    icon = nil,
    text = map_tag.gps,
    last_user = player.name
  }
  local chart_tag = player.force.add_chart_tag(player.surface, tag_spec)
  Storage.reset_cached_chart_tags(player.surface.index)
  return chart_tag
end

return MapTag
