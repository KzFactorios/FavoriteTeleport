-- favorite_ops.lua
-- Favorite add/remove/update logic for TagEditorGUI

local FavoriteOps = {}
local Storage = require("core.storage")
local Helpers = require("core.utils.helpers")
local MapTag = require("core.map_tag")
local TagSync = require("core.tag_sync.tag_sync_suite")

-- Replace direct favorite logic with TagSync
function FavoriteOps.update_favorite(player, gps)
  return TagSync.sync_favorites(player, gps, true)
end

function FavoriteOps.remove_favorite(player, gps)
  return TagSync.sync_favorites(player, gps, false)
end

return FavoriteOps
