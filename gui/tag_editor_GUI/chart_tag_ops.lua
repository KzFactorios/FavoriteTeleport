-- chart_tag_ops.lua
-- Chart tag and map tag creation/update logic for TagEditorGUI

local ChartTagOps = {}
local Storage = require("core.storage")
local Helpers = require("core.utils.helpers")
local MapTag = require("core.map_tag")
local Constants = require("constants")
local FavoriteSlots = require("core.utils.favorite_slots")

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
  elseif chart_tag.last_user.name == player.name then
    chart_tag.icon = input.icon or {}
    chart_tag.text = input.text
    chart_tag.last_user = player.name
  end
  Storage.reset_cached_chart_tags(player.surface.index)

  return Storage.find_chart_tag_by_gps(player, gps)
end

function ChartTagOps.find_create_map_tag_on_confirm(player, gps, chart_tag, input, current_position)
  local map_tag = Storage.find_map_tag_by_gps(player, gps)
  local is_favorite = not not input.is_favorite
  local safe_chart_tag = chart_tag or
      player.force.add_chart_tag(player.surface,
        { position = Helpers.simplify_position(current_position), icon = {}, text = "", last_user = player.name })
  local simple_position = Helpers.simplify_position(current_position)
  if not map_tag then
    map_tag = MapTag.new(player, simple_position, safe_chart_tag, is_favorite)
  else
    map_tag.gps = gps
    map_tag.created_by = player.name
  end

  if map_tag then
    map_tag.faved_by_players = map_tag.faved_by_players or {}

    local player_favorites = Storage.get_player_favorites(player)
    local found_fave, _ = FavoriteSlots.find_favorite_by_gps(player_favorites, gps)
    local count = Storage.get_available_favorite_slots_count()

    if is_favorite and count < Constants.MAX_FAVORITE_SLOTS then
      MapTag.add_player_to_faved_by_players(map_tag, player)
      if not found_fave then
        for _, fave in pairs(player_favorites) do
          if fave.gps == "" then
            fave = {
              gps = gps,
              slot_locked = false
            }
            break
          end
        end
      end
    else                          -- not a favorite
      MapTag.remove_player_index_from_faved_by_players(map_tag, player.index)
      if found_fave ~= nil then   -- if not a favorite
        -- reset the found_fave
        found_fave = {
          gps = "",
          slot_locked = false
        }
      end
    end

    Storage.add_or_update_map_tag(player, map_tag)
  end
  return map_tag
end

--- position is read-only, so if we need to change the position,
--- delete the old and make a new one
function ChartTagOps.update_chart_tag(player, chart_tag, input, map_position)
  if not player or not chart_tag then return end
  local changed = false

  if (chart_tag.position.x ~= map_position.x or chart_tag.position.y ~= map_position.y) then
    local tag_spec = {
      position = map_position,
      icon = input.icon,
      text = input.text,
      last_user = player.name
    }
    chart_tag.destroy()
    chart_tag = _G.game.forces["player"].add_chart_tag(player.surface, tag_spec)
    changed = true
  end

  if not Helpers.tables_equal(chart_tag.icon, input.icon) then
    chart_tag.icon = input.icon
    changed = true
  end

  if chart_tag.text ~= input.text then
    chart_tag.text = input.text
    changed = true
  end

  if chart_tag.last_user and chart_tag.last_user.name ~= player.name then
    chart_tag.last_user = player.name
    changed = true
  end

  ---@diagnostic disable-next-line: unnecessary-if
  if changed == true then
    Storage.reset_cached_chart_tags(player.surface.index)
    chart_tag = Storage.find_chart_tag_by_gps(player,
      Helpers.format_gps(chart_tag.position.x, chart_tag.position.y, player.surface.index))
  end

  return chart_tag
end

function ChartTagOps.delete_chart_tag(player, chart_tag)
  if not player or not chart_tag.valid then return false end
  local gps = Helpers.format_gps(chart_tag.position.x, chart_tag.position.y, player.surface.index)
  -- get any matching map_tags and delete them first
  local map_tag = Storage.find_chart_tag_by_gps(player, gps)
  if map_tag ~= nil then
    -- cycle thru other players that have faved and erase their favorite
    for _, p in pairs(map_tag.faved_by_players) do
      local pdata = Storage.get_player_data_by_player_index(p.index) or {}
      local faves = pdata.surfaces[player.surface.index].favorites
      for i = 1, #faves do
        if faves[i].gps == gps then
          faves[i] = {
            gps = "",
            slot_locked = false
          }
        end
      end
    end
    -- delete the map_tag & chart_tag
    map_tag.destroy()
    chart_tag.destroy()
    return true
  end
  return false
end

return ChartTagOps
