-- core/storage/chart_tags.lua
-- Chart tag and map tag storage/lookup for FavoriteTeleport

local ChartTags = {}
local Constants = require("constants")
local Helpers = require("core.utils.helpers")

--- This avoids circular dependency that was happening with Storage
--- Returns the chart_tags for the player's current surface, populating from the game if missing or empty.
function ChartTags.get_chart_tags(player)
  if not player or not player.valid then return {} end
  if not player.surface or not player.surface.index then return {} end
  _G.storage = _G.storage or {}
  local storage = _G.storage.FavoriteTeleport or {}
  local surfaces = storage.surfaces or {}
  local surface_data = surfaces[player.surface.index] or {}
  return surface_data.chart_tags or {}
end

return ChartTags
