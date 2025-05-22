-- chart_tag_ops.lua
-- Chart tag and map tag creation/update logic for TagEditorGUI

local ChartTagOps = {}
local Cache = require("core.cache.init")
local Helpers = require("core.utils.helpers")
local MapTag = require("core.map_tag")
local Constants = require("constants")
local FavoriteSlots = require("core.utils.favorite_slots")
local TagSync = require("core.tag_sync.tag_sync_suite")

ChartTagOps.find_create_chart_tag_on_confirm = function(player, gps, input)
  -- Patch: TagSync.create_tag expects gps as string, not MapPosition
  return TagSync.create_tag(player, gps, input)
end

ChartTagOps.find_create_map_tag_on_confirm = function(player, gps, chart_tag, input, current_position)
  return TagSync.update_tag(player, gps, input)
end

ChartTagOps.update_chart_tag = function(player, chart_tag, input, map_position)
  return TagSync.update_tag(player, Helpers.format_gps(map_position.x, map_position.y, player.surface.index), input)
end

ChartTagOps.delete_chart_tag = function(player, chart_tag)
  local gps = Helpers.format_gps(chart_tag.position.x, chart_tag.position.y, player.surface.index)
  return TagSync.delete_tag(player, gps)
end

return ChartTagOps
