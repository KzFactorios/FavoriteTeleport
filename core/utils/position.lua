-- position.lua
-- Math, position, and tagging helpers for FavoriteTeleport

local Position = {}

-- Math/position helpers
function Position.math_round(n)
  if type(n) ~= "number" then return 0 end
  local rounded = n >= 0 and math.floor(n + 0.5) or math.ceil(n - 0.5)
  if tostring(rounded) == "-0" then
    rounded = 0
  end
  return rounded
end

function Position.has_decimal_point(s)
  return tostring(s):find("%.") ~= nil
end

function Position.simplify_position(pos)
  local x = (pos and type(pos.x) == "number" or pos and type(pos.x) == "string") and pos.x or 0
  local y = (pos and type(pos.y) == "number" or pos and type(pos.y) == "string") and pos.y or 0
  if Position.has_decimal_point(tostring(x)) then
    x = Position.math_round(x)
  end
  if Position.has_decimal_point(tostring(y)) then
    y = Position.math_round(y)
  end
  return { x = x, y = y }
end

function Position.snap_position(position, snap_scale)
  return {
    x = Position.math_round(position.x / snap_scale) * snap_scale,
    y = Position.math_round(position.y / snap_scale) * snap_scale
  }
end

function Position.map_position_to_chunk_position(map_pos)
  return {
    x = math.floor(map_pos.x / 32),
    y = math.floor(map_pos.y / 32)
  }
end

function Position.chunk_position_to_map_position(chunk_pos)
  return {
    x = chunk_pos.x * 32,
    y = chunk_pos.y * 32
  }
end

-- Tagging and map position helpers
function Position.position_can_be_tagged(player, map_position)
  if not player then return false end
  local chunk_position = {
    x = Position.math_round(map_position.x / 32),
    y = Position.math_round(map_position.y / 32)
  }
  if not player.force.is_chunk_charted(player.surface, chunk_position) then
    return false
  end
  local tile = player.surface.get_tile(math.floor(map_position.x), math.floor(map_position.y))
  for _, mask in pairs(tile.prototype.collision_mask) do
    if mask == "water-tile" then
      return false
    end
  end
  return true
end

--- Returns true if the player is on a space platform (stub, always returns false unless you have space platforms mod integration)
function Position.is_on_space_platform(player)
  -- If you have a space platform mod, check for the surface name or property here
  if not player or not player.surface or not player.surface.name then return false end
  -- Example: if surface name contains 'space' or is exactly 'space-platform'
  local name = player.surface.name:lower()
  return name:find("space") ~= nil or name == "space-platform"
end

function Position.position_has_colliding_tag(player, map_position, snap_scale)
  if not player then return nil end
  local collision_area = {
    left_top = {
      x = map_position.x - snap_scale + 0.1,
      y = map_position.y - snap_scale + 0.1
    },
    right_bottom = {
      x = map_position.x + snap_scale - 0.1,
      y = map_position.y + snap_scale - 0.1
    }
  }
  local colliding_tags = player.force.find_chart_tags(player.surface, collision_area)
  if colliding_tags and #colliding_tags > 0 then
    return colliding_tags[1].position
  end
  return nil
end

--- Utility: Check if a position is a water tile (Factorio runtime only)
---@diagnostic disable
function Position.is_water_tile(surface, pos)
  if surface and surface.get_tile then
    local tile = surface.get_tile(math.floor(pos.x), math.floor(pos.y))
    if tile and tile.prototype and tile.prototype.collision_mask then
      for _, mask in pairs(tile.prototype.collision_mask) do
        if mask == "water-tile" then
          return true
        end
      end
    end
  end
  return false
end
---@diagnostic enable

return Position
