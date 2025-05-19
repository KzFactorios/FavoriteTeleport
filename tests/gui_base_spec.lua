-- tests/gui_base_spec.lua
-- Unit tests for gui/gui_base.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local GuiBase = require("gui.gui_base")

describe("GuiBase", function()
  it("find_by_path returns nil for missing path", function()
    local frame = { children = {} }
    local result = GuiBase.find_by_path(frame, { "missing" })
    assert.is_nil(result)
  end)

  it("find_by_path returns element for valid path", function()
    local frame = { children = { [1] = { name = "foo" } }, foo = { name = "foo" } }
    local result = GuiBase.find_by_path(frame, { "foo" })
    assert.is_table(result)
    assert.equals("foo", result.name)
  end)
end)
