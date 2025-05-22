-- Rendering marker for tag move mode
-- This file is required by control.lua to handle rendering of the move marker
-- Use the global 'rendering' API provided by Factorio, do NOT require it
local Helpers = require('core.utils.helpers')

local MoveMarker = {}

-- Store marker ids per player
local marker_ids = {}

-- Forward declare rendering as global for linter/IDE, but do not assign
---@diagnostic disable-next-line: undefined-global
local rendering = rendering

function MoveMarker.show_marker(player, gps)
  if not (player and player.valid and gps) then return end
  local surface_index = Helpers.get_surface_index_from_gps(gps)
  local surface = player.surface -- Use player.surface instead of game.surfaces
  if not surface then return end
  local pos = Helpers.gps_to_map_position(gps)
  -- Remove any existing marker for this player
  MoveMarker.remove_marker(player)
  marker_ids[player.index] = rendering.draw_sprite{
    sprite = 'utility/location',
    target = pos,
    surface = surface,
    x_scale = 1.5,
    y_scale = 1.5,
    tint = {r=0.7,g=0.7,b=1,a=0.7},
    players = {player.index},
    render_layer = 'object',
    only_in_alt_mode = false
  }
end

function MoveMarker.remove_marker(player)
  local id = marker_ids[player.index]
  if id and rendering.is_valid(id) then
    rendering.destroy(id)
  end
  marker_ids[player.index] = nil
end

return MoveMarker
