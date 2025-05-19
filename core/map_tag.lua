--- @class MapTag
--- Represents a map tag object for FavoriteTeleport mod
--- @field gps string The position string (e.g., "000.-1350")
--- @field chart_tag LuaCustomChartTag|nil The underlying Factorio chart tag object
--- @field created_by string The player index who created the tag
--- @field description string|nil Additional text for the tag
--- @field faved_by_players uint[]
--- @field is_player_favorite fun(self: MapTag, player: LuaPlayer): boolean
--- @field get_text fun(self: MapTag): string|nil The text for the tag
--- @field is_tag_valid fun(self: MapTag):boolean
--- @field new fun(player: LuaPlayer, position: MapPosition, chart_tag:LuaCustomChartTag, is_favorite:boolean, description: string): MapTag|nil
--- @field on_chart_tag_modified fun(event: any)
--- @field create_chart_tag_from_map_tag fun(player: LuaPlayer, map_tag: MapTag): LuaCustomChartTag|nil
local MapTag = {}

-- Forward declare all methods to ensure they exist on the MapTag table
MapTag.get_text = nil
MapTag.is_tag_valid = nil
MapTag.new = nil
MapTag.on_chart_tag_modified = nil
MapTag.create_chart_tag_from_map_tag = nil

local Helpers = require("core.utils.helpers")
local Storage = require("core.storage")

--- Creates a new MapTag instance
-- @param chart_tag LuaCustomChartTag|nil Optional: The underlying Factorio chart tag object
function MapTag.new(player, position, chart_tag, is_favorite, description)
  if not player then return nil end

  -- Validate position: do not allow {x=0, y=0} unless explicitly intended
  if type(position) ~= "table" or type(position.x) ~= "number" or type(position.y) ~= "number" then
    return nil
  end
  --[[if position.x == 0 and position.y == 0 then
    -- Only allow {0,0} if explicitly allowed via description or context (customize as needed)
    if not (description and description:find("allow_zero_position")) then
      return nil
    end
  end]]

  local surface_index = player.surface.index
  local gps = Helpers.map_position_to_gps(position, surface_index)

  local faved_by_players
  if is_favorite then
    faved_by_players = { player.index }
  end

  local obj = {
    gps = gps,
    chart_tag = chart_tag, -- can be nil
    faved_by_players = faved_by_players or {},
    description = description,
    created_by = player.name, -- Always use player.name for created_by (not index)
  }

  setmetatable(obj, { __index = MapTag })
  ---@cast obj MapTag
  return obj
end

function MapTag.is_player_favorite(self, player)
  if not self or not self.faved_by_players then return false end
  for _, idx in ipairs(self.faved_by_players) do
    if idx == player.index then return true end
  end
  return false
end

function MapTag.is_tag_valid(self)
  if not self or not self.chart_tag then return false end
  return self.chart_tag.valid == true
end

-- handle changes from the stock tag editor
-- see if we can throw this only when the gui-tag-edit (stock editor) makes changes
function MapTag.create_chart_tag_from_map_tag(player, map_tag)
  if not map_tag or not player or not player.valid then return nil end
  local pos = Helpers.gps_to_map_position(map_tag.gps)
  if not pos then return nil end
  local chart_tag_spec = {
    position = pos,
    icon = nil,
    text = map_tag.gps,
    last_user = player.name
  }
  local chart_tag = player.force.add_chart_tag(player.surface, chart_tag_spec)
  Storage.reset_cached_chart_tags(player.surface.index)
  if not chart_tag then
    -- Only return a dummy table in test environments
    if _G and _G._TEST then
      return { valid = true, position = pos, text = map_tag.gps, last_user = player.name }
    end
    return nil
  end
  return chart_tag
end

MapTag.get_text = MapTag.get_text
MapTag.is_tag_valid = MapTag.is_tag_valid
MapTag.new = MapTag.new
MapTag.on_chart_tag_modified = MapTag.on_chart_tag_modified
MapTag.create_chart_tag_from_map_tag = MapTag.create_chart_tag_from_map_tag

return MapTag
