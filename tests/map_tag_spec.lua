_G._TEST = true
-- tests/map_tag_spec.lua
-- Unit tests for core/map_tag.lua
-- truepatch: disables type errors for test edge cases (see coding_standards.md)

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local Helpers = require("core.utils.helpers")
local MapTag = require("core.map_tag")

local function mock_player()
  return {
    name = "TestPlayer",
    index = 1,
    surface = { index = 1 },
    force = {
      add_chart_tag = function() return { valid = true, position = { x = 10, y = 20 }, icon = {}, text = "", last_user = "TestPlayer", print = function() end } end
    },
    character = true,
    gui = { screen = {} },
    print = function() end,
    opened = nil,
    mod_settings = {},
    valid = true
  }
end

local function dummy_chart_tag()
  return { valid = true, position = { x = 10, y = 20 }, icon = {}, text = "", last_user = "TestPlayer", print = function() end }
end

describe("MapTag", function()
  it("creates a new MapTag with valid data", function()
    ---@diagnostic disable-next-line: param-type-mismatch
    local player = mock_player()
    local tag = MapTag.new(player, { x = 10, y = 20 }, dummy_chart_tag(), true, "desc")
    assert.is_table(tag)
    assert.equals("TestPlayer", tag.created_by)
    assert.is_true(tag:is_player_favorite(player))
    assert.equals("desc", tag.description)
  end)

  it("returns false for is_player_favorite if not in faved_by_players", function()
    ---@diagnostic disable-next-line: param-type-mismatch
    local player = mock_player()
    local tag = MapTag.new(player, { x = 10, y = 20 }, dummy_chart_tag(), false, "desc")
    local other = mock_player(); other.index = 2
    assert.is_false(tag:is_player_favorite(other))
  end)

  it("returns false for is_tag_valid if chart_tag is nil", function()
    ---@diagnostic disable-next-line: param-type-mismatch
    local player = mock_player()
    ---@diagnostic disable-next-line: param-type-mismatch
    local tag = MapTag.new(player, { x = 10, y = 20 }, nil, false, "desc")
    assert.is_false(tag and tag:is_tag_valid() or false)
  end)

  it("returns true for is_tag_valid if chart_tag is valid", function()
    ---@diagnostic disable-next-line: param-type-mismatch
    local player = mock_player()
    local chart_tag = dummy_chart_tag()
    local tag = MapTag.new(player, { x = 10, y = 20 }, chart_tag, false, "desc")
    assert.is_true(tag and tag:is_tag_valid() or false)
  end)

  it("create_chart_tag_from_map_tag returns a chart_tag", function()
    ---@diagnostic disable-next-line: param-type-mismatch
    local player = mock_player()
    local tag = MapTag.new(player, { x = 10, y = 20 }, dummy_chart_tag(), false, "desc")
    local chart_tag = MapTag.create_chart_tag_from_map_tag(player, tag)
    assert.is_table(chart_tag)
    assert.is_true(chart_tag.valid)
  end)

  it("returns nil for invalid player or map_tag in create_chart_tag_from_map_tag", function()
    ---@diagnostic disable-next-line: param-type-mismatch
    local player = mock_player()
    assert.is_nil(MapTag.create_chart_tag_from_map_tag(nil, nil))
    assert.is_nil(MapTag.create_chart_tag_from_map_tag(player, nil))
    assert.is_nil(MapTag.create_chart_tag_from_map_tag(nil, { gps = "foo" }))
  end)
end)
