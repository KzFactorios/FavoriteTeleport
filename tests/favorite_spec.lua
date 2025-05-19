-- tests/favorite_spec.lua
-- Unit tests for core/favorite.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local Favorite = require("core.favorite")

describe("Favorite", function()
  it("can create a new Favorite", function()
    local fav = Favorite.new("010.020.1", true)
    assert.is_table(fav)
    assert.equals("010.020.1", fav.gps)
    assert.is_true(fav.slot_locked)
  end)

  it("returns false for slot_locked if not set", function()
    local fav = Favorite.new("010.020.1")
    assert.is_false(fav.slot_locked)
  end)

  it("get_map_tag does not error", function()
    local fav = Favorite.new("010.020.1")
    assert.has_no.errors(function() fav:get_map_tag() end)
  end)
end)
