-- chart_tag_ops.lua
-- Chart tag and map tag creation/update logic for TagEditorGUI

local ChartTagOps = {}
local Storage = require("core.storage")
local Helpers = require("core.utils.helpers")
local MapTag = require("core.map_tag")

function ChartTagOps.find_create_chart_tag_on_confirm(player, gps, input)
  local chart_tag = Storage.find_chart_tag_by_gps(player, gps)
  if not chart_tag then
    local tag_spec = {
      position = Helpers.gps_to_map_position(gps),
      icon = input.icon or {},
      text = input.text,
      last_user = player.name
    }
    chart_tag = player.force.add_chart_tag(player.surface, tag_spec)
    if not chart_tag then
      player.print { "FavoriteTeleport.ft_tag_editor_error_chart_tag_failed" }
      return nil
    end
  elseif chart_tag.last_user == player.name then
    chart_tag.icon = input.icon or {}
    chart_tag.text = input.text
    chart_tag.last_user = player.name
  end
  Storage.reset_chart_tags(player)
  return Storage.find_chart_tag_by_gps(player, gps)
end

function ChartTagOps.find_create_map_tag_on_confirm(player, gps, chart_tag, input, current_position)
  local map_tag = Storage.find_map_tag_by_gps(player, gps)
  local is_favorite = not not input.is_favorite
  local safe_chart_tag = chart_tag or player.force.add_chart_tag(player.surface, { position = Helpers.simplify_position(current_position), icon = {}, text = "", last_user = player.name })
  local simple_position = Helpers.simplify_position(current_position)
  if not map_tag then
    map_tag = MapTag.new(player, simple_position, safe_chart_tag, is_favorite, input.description)
  else
    map_tag.gps = gps
    map_tag.description = input.description
    map_tag.chart_tag = chart_tag
  end
  if map_tag then
    map_tag.faved_by_players = map_tag.faved_by_players or {}
    local is_in, t_idx = Helpers.index_is_in_table(map_tag.faved_by_players, player.index)
    if is_favorite and not is_in then
      table.insert(map_tag.faved_by_players, player.index)
    end
    Storage.add_or_update_map_tag(player, map_tag)
  end
  return map_tag
end

return ChartTagOps
