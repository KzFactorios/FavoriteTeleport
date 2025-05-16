--- @class MapTag
--- Represents a map tag object for FavoriteTeleport mod
--- @field gps string The position string (e.g., "000.-1350")
--- @field tag LuaCustomChartTag|nil The underlying Factorio chart tag object
--- @field created_by string The player index who created the tag
--- @field text string|nil The text for the tag
--- @field description string|nil Additional text for the tag
--- @field faved_by_players uint[]
--- @field new fun(chart_tag:LuaCustomChartTag, position: MapPosition, player: LuaPlayer, is_favorite:boolean, icon: SignalID, text: string, description: string): MapTag|nil
--- @field is_tag_valid fun(self: MapTag):boolean
--- @field on_chart_tag_modified fun(event: any)
local MapTag = {}

local Helpers = require("core.utils.helpers") -- Adjust the path as needed to where your Helpers module is located

-- If you previously required 'core/chart_tag', update to 'core/maptag' in your codebase as needed.
-- All logic and type definitions are now in MapTag.

--- Creates a new MapTag instance
-- @param tag LuaCustomChartTag|nil Optional: The underlying Factorio chart tag object
-- @param map_position string
-- @param player_index uint
-- @param icon string|nil
-- @param text string|nil
-- @param description string|nil
-- @return MapTag
function MapTag.new(chart_tag, position, player, is_favorite, icon, text, description)
  if not player then return nil end

  local gps = Helpers.format_gps(player.surface.index, position.x, position.y)

  -- 'tag' is optional; handle nil as needed
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

  local faved_by_players = {}
  if is_favorite == true then
    table.insert(faved_by_players, player.index)
  end

  return {
    gps = gps,
    tag = chart_tag,
    created_by = player.name, -- Always use player.name for created_by (not index)
    text = text,
    description = description,
    faved_by_players = faved_by_players
  }
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

return MapTag
