-- tests/favorite_edge_spec.lua
-- Edge case tests for core/favorite.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local Favorite = require("core.favorite")

describe("Favorite (edge cases)", function()
  it("handles nil input for new", function()
    assert.has_no.errors(function() Favorite.new(nil, nil) end)
  end)

  it("get_map_tag does not error for nil gps", function()
    local fav = Favorite.new(nil)
    assert.has_no.errors(function() fav:get_map_tag() end)
  end)
end)
