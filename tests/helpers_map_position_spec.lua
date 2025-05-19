-- tests/helpers_map_position_spec.lua
-- Unit tests for core/utils/helpers.lua (map position and chunk position conversions)

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local Helpers = require("core.utils.helpers")

describe("Helpers: Map/Chunk Position", function()
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
end)
