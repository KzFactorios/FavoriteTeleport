-- tests/helpers_pos_string_spec.lua
-- Unit tests for core/utils/helpers.lua (pos_string conversions)

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

package.loaded["core.utils.helpers"] = nil
package.loaded["core.utils.helpers"] = nil
local Helpers = require("core.utils.helpers")

describe("Helpers: Pos String", function()
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
