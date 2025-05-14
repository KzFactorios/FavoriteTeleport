-- tests/helpers_spec.lua
-- Unit tests for core/utils/helpers.lua

-- Make sure busted globals are available
local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local Helpers = require("core.utils.helpers")

describe("Helpers", function()
  it("converts MapPosition to ChunkPosition", function()
    local map_pos = {x = 65, y = -33}
    local chunk_pos = Helpers.map_position_to_chunk_position(map_pos)
    assert.are.same({x = 2, y = -2}, chunk_pos)
  end)

  it("converts ChunkPosition to MapPosition", function()
    local chunk_pos = {x = 3, y = -1}
    local map_pos = Helpers.chunk_position_to_map_position(chunk_pos)
    assert.are.same({x = 96, y = -32}, map_pos)
  end)

  it("converts pos_string to MapPosition", function()
    local pos_string = "065.-033"
    local map_pos = Helpers.pos_string_to_map_position(pos_string)
    assert.are.same({x = 65, y = -33}, map_pos)
  end)

  it("converts MapPosition to pos_string", function()
    local map_pos = {x = 65, y = -33}
    local pos_string = Helpers.map_position_to_pos_string(map_pos)
    assert.equals("065.-033", pos_string)
  end)

  it("converts pos_string with negative zero to MapPosition with zero", function()
    local pos_string = "-0.000"
    local map_pos = Helpers.pos_string_to_map_position(pos_string)
    assert.are.same({x = 0, y = 0}, map_pos)
  end)
end)
