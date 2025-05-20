-- core/storage/chart_tags.lua
-- Chart tag and map tag storage/lookup for FavoriteTeleport

local ChartTags = {}
local Constants = require("constants")
local Helpers = require("core.utils.helpers")
local StorageInit = require("core.storage.init")

--- Returns the chart_tags for the player's current surface, populating from the game if missing or empty.
function ChartTags.get_chart_tags(player)
  if not player or not player.valid then return nil end
  local chart_tags = StorageInit.get_surface_data(player).chart_tags
  return chart_tags or {}
end

return ChartTags
