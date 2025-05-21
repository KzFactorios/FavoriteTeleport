require("prototypes/styles")

local Constants = require("constants")
local Context = require("core.context")

---@diagnostic disable-next-line: undefined-global
data:extend {
  {
    type = "font",
    name = "custom-tiny-font",
    from = "default",
    size = 8,      -- Adjust this size to be smaller than default-tiny
    border = false -- Set to true if you want better readability with a border
  },
  {
    type = "sprite",
    name = "default-map-tag",
    filename = "__FavoriteTeleport__/graphics/default_map_tag.png",
    priority = "extra-high",
    size = { 32, 49 },
    flags = { "gui-icon" },
  },
  {
    type = "sprite",
    name = "ft_move_tag_icon",
    filename = "__core__/graphics/icons/mip/move-tag.png",
    width = 32,
    height = 32,
    x = 0,
    y = 0,
    flags = { "icon" }
  },
  {
    type = "custom-input",
    name = Constants.events.TELEPORT_TO_FAVORITE .. "1",
    key_sequence = "CONTROL + 1",
    consuming = "game-only",
    order = "ca"
  },
  {
    type = "custom-input",
    name = Constants.events.TELEPORT_TO_FAVORITE .. "2",
    key_sequence = "CONTROL + 2",
    consuming = "game-only",
    order = "cb"
  },
  {
    type = "custom-input",
    name = Constants.events.TELEPORT_TO_FAVORITE .. "3",
    key_sequence = "CONTROL + 3",
    consuming = "game-only",
    order = "cc"
  },
  {
    type = "custom-input",
    name = Constants.events.TELEPORT_TO_FAVORITE .. "4",
    key_sequence = "CONTROL + 4",
    consuming = "game-only",
    order = "cd"
  },
  {
    type = "custom-input",
    name = Constants.events.TELEPORT_TO_FAVORITE .. "5",
    key_sequence = "CONTROL + 5",
    consuming = "game-only",
    order = "ce"
  },
  {
    type = "custom-input",
    name = Constants.events.TELEPORT_TO_FAVORITE .. "6",
    key_sequence = "CONTROL + 6",
    consuming = "game-only",
    order = "cf"
  },
  {
    type = "custom-input",
    name = Constants.events.TELEPORT_TO_FAVORITE .. "7",
    key_sequence = "CONTROL + 7",
    consuming = "game-only",
    order = "cg"
  },
  {
    type = "custom-input",
    name = Constants.events.TELEPORT_TO_FAVORITE .. "8",
    key_sequence = "CONTROL + 8",
    consuming = "game-only",
    order = "ch"
  },
  {
    type = "custom-input",
    name = Constants.events.TELEPORT_TO_FAVORITE .. "9",
    key_sequence = "CONTROL + 9",
    consuming = "game-only",
    order = "ci"
  },
  {
    type = "custom-input",
    name = Constants.events.TELEPORT_TO_FAVORITE .. "10",
    key_sequence = "CONTROL + 0",
    consuming = "game-only",
    order = "cj"
  },
  {
    name = Constants.events.STORAGE_DUMP,
    type = "custom-input",
    key_sequence = "CONTROL + F12",
    order = "zz"
  },
  {
    name = Constants.events.ON_OPEN_TAG_EDITOR,
    type = "custom-input",
    key_sequence = "mouse-button-2",
    consumin="game-only",
    order = "zz"
  },
  {
    type = "custom-input",
    name = "ft-dev-dump-chart-tags",
    key_sequence = "CONTROL + F9",
    order = "zz"
  },
  {
    type = "custom-input",
    name = "ft_gui_stack_esc",
    key_sequence = "ESCAPE",
    consuming = "game-only",
    order = "zz1"
  },
  {
    type = "custom-input",
    name = "ft_tag_editor_confirm",
    key_sequence = "E",
    consuming = "game-only",
    order = "zz2"
  },
  
}
