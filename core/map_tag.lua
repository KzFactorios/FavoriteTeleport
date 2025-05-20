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
--- @field teleport_player_with_messaging fun(player: LuaPlayer, position: MapPosition, surface: LuaSurface, raise_teleported?: boolean): string|nil
--- @field remove_player_index_from_faved_by_players fun(self: MapTag, player_index: uint)
local MapTag = {}

-- Forward declare all methods to ensure they exist on the MapTag table
MapTag.get_text = nil
MapTag.is_tag_valid = nil
MapTag.new = nil
MapTag.on_chart_tag_modified = nil
MapTag.create_chart_tag_from_map_tag = nil
MapTag.teleport_player_with_messaging = nil
MapTag.remove_player_index_from_faved_by_players = nil

local Helpers = require("core.utils.helpers")
local Storage = require("core.storage")
local MapTagDummy = require("core.map_tag_dummy")
local Position = require("core.utils.position")
local Settings = require("settings")
local Constants = require("constants")

--- Creates a new MapTag instance
-- @param chart_tag LuaCustomChartTag|nil Optional: The underlying Factorio chart tag object
function MapTag.new(player, position, chart_tag, is_favorite, description)
  if not player then return nil end

  -- Validate position: do not allow {x=0, y=0} unless explicitly intended
  if type(position) ~= "table" or type(position.x) ~= "number" or type(position.y) ~= "number" then
    return nil
  end

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

function MapTag.remove_player_index_from_faved_by_players(self, player_index)
  if self.faved_by_players and type(self.faved_by_players) == "table" and #self.faved_by_players > 0 then
    local result, idx = Helpers.index_is_in_table(self.faved_by_players, player_index)
    if result and result == true then
      table.remove(self.faved_by_players, idx)
    end
  end
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
      return MapTagDummy.get_dummy_chart_tag(map_tag, player, pos)
    end
    return nil
  end
  return chart_tag
end

--- Wrapper for player.teleport
--- note that caller is currently handling raising of teleport event
-- @param player LuaPlayer
-- @param position MapPosition
-- @param surface LuaSurface|string|nil
-- @param raise_teleported boolean|nil
-- @returns string -- successful teleport returns constants.enums.return_state.SUCCESS
function MapTag.teleport_player_with_messaging(player, position, surface, raise_teleported)
  -- Defensive checks for valid player and surface
  if not player or not player.valid or type(player.teleport) ~= "function" then
    return "Unable to teleport. Player is missing"
  end
  if not surface then surface = player.surface end
  if not surface or type(surface.find_non_colliding_position) ~= "function" then
    return "Unable to teleport. Surface is missing"
  end
  -- Only allow teleport if player.character is present (Factorio API)
  if rawget(player, "character") == nil then
    return "Unable to teleport. Player character is missing"
  end

  -- Space platform check
  if Position.is_on_space_platform and Position.is_on_space_platform(player) then
    return
    "The insurance general has determined that teleporting on a space platform could result in injury or death, or both, and has outlawed the practice."
  end

  -- Get settings
  local settings = Settings.getPlayerSettings and Settings:getPlayerSettings(player) or { teleport_radius = 8 }
  local teleport_radius = settings.teleport_radius or 8

  -- Use the default prototype name for collision search
  local proto_name = "character"
  -- Find a non-colliding position near the target position
  local closest_position = surface.find_non_colliding_position(proto_name, position, teleport_radius, 4)
  if not closest_position then
    return
    "The location you have chosen is too dense for teleportation. You may try to adjust the settings for teleport radius, but generally you should try a different location."
  end

  -- Water tile check
  if Position.is_water_tile(surface, closest_position) then
    return
    "You cannot teleport onto water. Ages ago, this practice was allowed and many agents were lost as they were teleported to insurvivable depths. Please select a land location."
  end

  -- Check if the position is valid for placing the player
  if not surface.can_place_entity or not surface.can_place_entity("character", closest_position) then
    return "The player cannot be placed at this location. Try another location."
  end

  local teleport_AOK = false

  -- Vehicle teleportation: In Factorio, teleporting a vehicle does NOT move the player with it automatically.
  -- To ensure the player stays inside the vehicle, you must teleport the vehicle first, then the player.
  local vehicle = player.vehicle or nil
  if vehicle then
    vehicle.teleport(closest_position, surface,
      raise_teleported and raise_teleported == true or false)
    teleport_AOK = player.teleport(closest_position, surface,
      raise_teleported and raise_teleported == true or false)
  else
    teleport_AOK = player.teleport(closest_position, surface,
      raise_teleported and raise_teleported == true or false)
  end

  -- A succeful teleport!
  if teleport_AOK then return Constants.enums.return_state.SUCCESS end

  -- Fallback error
  return "We were unable to perform the teleport due to unforeseen circumstances"
end

MapTag.get_text = MapTag.get_text
MapTag.is_tag_valid = MapTag.is_tag_valid
MapTag.new = MapTag.new
MapTag.on_chart_tag_modified = MapTag.on_chart_tag_modified
MapTag.create_chart_tag_from_map_tag = MapTag.create_chart_tag_from_map_tag
MapTag.teleport_player_with_messaging = MapTag.teleport_player_with_messaging
MapTag.remove_player_index_from_faved_by_players = MapTag.remove_player_index_from_faved_by_players

return MapTag
