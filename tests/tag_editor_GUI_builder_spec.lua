-- tests/tag_editor_GUI_builder_spec.lua
-- Unit tests for gui/tag_editor_GUI_builder.lua

_G.TEST_ENV = true

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local TagEditorGUIBuilder = require("gui.tag_editor_GUI_builder")
local Storage = require("core.storage")
local Helpers = require("core.utils.helpers")

_G.defines = _G.defines or { render_mode = { chart = "chart", game = "game" } }

local function dummy_gui_element()
  local elem = {}
  elem.style = {}
  elem.add = function() return elem end
  elem.destroy = function() end
  return elem
end

local function mock_player()
  local player = {
    name = "TestPlayer",
    index = 1,
    surface = {
      index = 1,
      get_tile = function() return { valid = true, prototype = { collision_mask = {} } } end
    },
    force = {
      find_chart_tags = function() return {} end,
      is_chunk_charted = function() return true end
    },
    character = {},
    gui = { screen = dummy_gui_element() },
    print = function() end,
    opened = nil
  }
  return player
end

describe("TagEditorGUIBuilder", function()
  it("returns nil if player or position is missing", function()
    assert.is_nil(TagEditorGUIBuilder.open(nil, { x = 10, y = 20 }, {}))
    assert.is_nil(TagEditorGUIBuilder.open(mock_player(), nil, {}))
  end)

  it("returns a builder object for valid input", function()
    local player = mock_player()
    local builder = TagEditorGUIBuilder.open(player, { x = 10, y = 20 }, {})
    assert.is_truthy(builder)
  end)
end)
