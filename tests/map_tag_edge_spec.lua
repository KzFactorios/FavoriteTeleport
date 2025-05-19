-- tests/map_tag_edge_spec.lua
-- Edge case tests for core/map_tag.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local MapTag = require("core.map_tag")

describe("MapTag (edge cases)", function()
  it("returns nil for new with nil player", function()
    assert.is_nil(MapTag.new(nil, {x=1,y=2}, nil, false, "desc"))
  end)

  it("returns nil for new with invalid position", function()
    local player = { name = "Test", index = 1, surface = { index = 1 } }
    assert.is_nil(MapTag.new(player, nil, nil, false, "desc"))
    assert.is_nil(MapTag.new(player, {}, nil, false, "desc"))
    assert.is_nil(MapTag.new(player, {x="a",y=2}, nil, false, "desc"))
  end)

  it("is_player_favorite returns false for nil self or faved_by_players", function()
    assert.is_false(MapTag.is_player_favorite(nil, { index = 1 }))
    assert.is_false(MapTag.is_player_favorite({ faved_by_players = nil }, { index = 1 }))
  end)

  it("is_tag_valid returns false for nil self or chart_tag", function()
    assert.is_false(MapTag.is_tag_valid(nil))
    assert.is_false(MapTag.is_tag_valid({ chart_tag = nil }))
  end)

  it("create_chart_tag_from_map_tag returns nil for invalid input", function()
    assert.is_nil(MapTag.create_chart_tag_from_map_tag(nil, nil))
    assert.is_nil(MapTag.create_chart_tag_from_map_tag({ valid = false }, nil))
    assert.is_nil(MapTag.create_chart_tag_from_map_tag(nil, { gps = "foo" }))
  end)
end)
