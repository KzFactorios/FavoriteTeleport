-- constants.lua
-- Defines mod constants
--- @class Constants
local constants = {}

constants.PREFIX = "ft_"
local PRE = constants.PREFIX

constants.TELEPORT_RADIUS_DEFAULT = 8
constants.TELEPORT_RADIUS_MIN = 1
constants.TELEPORT_RADIUS_MAX = 64
constants.MAX_FAVORITE_SLOTS = 10

constants.events = {
  ADD_TAG_INPUT = "add-tag-input",
  --TELEPORT_INPUT = PRE .. "teleport-input",
  --CLOSE_WITH_TOGGLE_MAP = PRE .. "close-with-toggle-map",
  --OPEN_STOCK_GUI = PRE .. "open-stock-gui",
  --FAVE_ORDER_UPDATED = "fave-order-updated",
  --SELECTED_FAVE_CHANGED = "selected-fave-changed",
  TELEPORT_TO_FAVORITE = "teleport_to_favorite-",
  ON_OPEN_TAG_EDITOR = "on_open_tag_editor",
  CACHE_DUMP = "cache_dump"
}

constants.settings = {
  FAVORITES_ON = PRE .. "favorites_on",
  BOUNDING_BOX_TOLERANCE = 10,
  SNAP_SCALE_FOR_CLICKED_TAG = 4
}

constants.enums = {
  return_state = {
    SUCCESS = "sucess",
    FAILURE = "failure"
  }
}

return constants
