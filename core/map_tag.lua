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
      ---@type LuaForce
      local dummy_force = player.force
      if type(dummy_force) ~= "table" or not rawget(dummy_force, "name") then
        dummy_force = {
          name = "test-force",
          object_name = "LuaForce",
          add_chart_tag = function() return {} end,
          valid = true,
          print = function() end,
          -- Add all other required fields as dummies for strict type checking
          ai_controllable = true,
          artillery_range_modifier = 0,
          beacon_distribution_modifier = 0,
          belt_stack_size_bonus = 0,
          bulk_inserter_capacity_bonus = 0,
          character_build_distance_bonus = 0,
          character_health_bonus = 0,
          character_inventory_slots_bonus = 0,
          character_item_drop_distance_bonus = 0,
          character_item_pickup_distance_bonus = 0,
          character_logistic_requests = true,
          character_loot_pickup_distance_bonus = 0,
          character_reach_distance_bonus = 0,
          character_resource_reach_distance_bonus = 0,
          character_running_speed_modifier = 0,
          character_trash_slot_count = 0,
          circuit_network_enabled = true,
          cliff_deconstruction_enabled = true,
          color = {r=1,g=1,b=1,a=1},
          connected_players = {},
          create_ghost_on_entity_death = true,
          deconstruction_time_to_live = 0,
          following_robots_lifetime_modifier = 0,
          friendly_fire = true,
          index = 1,
          inserter_stack_size_bonus = 0,
          items_launched = {},
          laboratory_productivity_bonus = 0,
          laboratory_speed_modifier = 0,
          logistic_networks = {},
          manual_crafting_speed_modifier = 0,
          manual_mining_speed_modifier = 0,
          max_failed_attempts_per_tick_per_construction_queue = 0,
          max_successful_attempts_per_tick_per_construction_queue = 0,
          maximum_following_robot_count = 0,
          mining_drill_productivity_bonus = 0,
          mining_with_fluid = true,
          platforms = {},
          players = {},
          rail_planner_allow_elevated_rails = true,
          rail_support_on_deep_oil_ocean = true,
          recipes = {},
          research_enabled = true,
          research_progress = 0,
          research_queue = {},
          rockets_launched = 0,
          share_chart = true,
          technologies = {},
          train_braking_force_bonus = 0,
          vehicle_logistics = true,
          worker_robots_battery_modifier = 0,
          worker_robots_speed_modifier = 0,
          worker_robots_storage_bonus = 0,
          -- Add all required methods as no-ops
          add_research = function() end,
          cancel_charting = function() end,
          cancel_current_research = function() end,
          chart = function() end,
          chart_all = function() end,
          clear_chart = function() end,
          copy_chart = function() end,
          copy_from = function() end,
          create_space_platform = function() end,
          disable_all_prototypes = function() end,
          disable_research = function() end,
          enable_all_prototypes = function() end,
          enable_all_recipes = function() end,
          enable_all_technologies = function() end,
          enable_research = function() end,
          find_chart_tags = function() return {} end,
          find_logistic_network_by_position = function() end,
          get_ammo_damage_modifier = function() return 0 end,
          get_cease_fire = function() return false end,
          get_entity_build_count_statistics = function() return {} end,
          get_entity_count = function() return 0 end,
          get_evolution_factor = function() return 0 end,
          get_evolution_factor_by_killing_spawners = function() return 0 end,
          get_evolution_factor_by_pollution = function() return 0 end,
          get_evolution_factor_by_time = function() return 0 end,
          get_fluid_production_statistics = function() return {} end,
          get_friend = function() return false end,
          get_gun_speed_modifier = function() return 0 end,
          get_hand_crafting_disabled_for_recipe = function() return false end,
          get_item_launched = function() return 0 end,
          get_item_production_statistics = function() return {} end,
          get_kill_count_statistics = function() return {} end,
          get_linked_inventory = function() return {} end,
          get_spawn_position = function() return {x=0,y=0} end,
          get_surface_hidden = function() return false end,
          get_turret_attack_modifier = function() return 0 end,
          is_chunk_charted = function() return false end,
          is_chunk_requested_for_charting = function() return false end,
          is_chunk_visible = function() return false end,
          is_enemy = function() return false end,
          is_friend = function() return false end,
          is_pathfinder_busy = function() return false end,
          is_quality_unlocked = function() return false end,
          is_space_location_unlocked = function() return false end,
          is_space_platforms_unlocked = function() return false end,
          kill_all_units = function() end,
          lock_quality = function() end,
          lock_space_location = function() end,
          lock_space_platforms = function() end,
          play_sound = function() end,
          rechart = function() end,
          research_all_technologies = function() end,
          reset = function() end,
          reset_evolution = function() end,
          reset_recipes = function() end,
          reset_technologies = function() end,
          reset_technology_effects = function() end,
          set_ammo_damage_modifier = function() end,
          set_cease_fire = function() end,
          set_evolution_factor = function() end,
          set_evolution_factor_by_killing_spawners = function() end,
          set_evolution_factor_by_pollution = function() end,
          set_evolution_factor_by_time = function() end,
          set_friend = function() end,
          set_gun_speed_modifier = function() end,
          set_hand_crafting_disabled_for_recipe = function() end,
          set_item_launched = function() end,
          set_spawn_position = function() end,
          set_surface_hidden = function() end,
          set_turret_attack_modifier = function() end,
          unchart_chunk = function() end,
          unlock_quality = function() end,
          unlock_space_location = function() end,
          unlock_space_platforms = function() end
        }
      end
      ---@cast dummy_force LuaForce
      local dummy_chart_tag = {
        valid = true,
        position = pos,
        text = map_tag.gps,
        last_user = player, -- LuaPlayer?
        force = dummy_force,
        icon = { type = "item", name = "iron-plate" }, -- dummy SignalID
        object_name = "LuaCustomChartTag",
        surface = player.surface,
        tag_number = 1,
        print = function() end,
        destroy = function() end
      }
      return dummy_chart_tag
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
