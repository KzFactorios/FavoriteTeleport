-- tests/gui_base_edge_spec.lua
-- Edge case tests for gui/gui_base.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local GuiBase = require("gui.gui_base")

describe("GuiBase (edge cases)", function()
  it("find_by_path returns nil for nil frame or path", function()
    assert.is_nil(GuiBase.find_by_path(nil, {"foo"}))
    assert.is_nil(GuiBase.find_by_path({}, nil))
  end)

  it("find_by_path returns nil for empty path", function()
    assert.is_nil(GuiBase.find_by_path({}, {}))
  end)
end)
