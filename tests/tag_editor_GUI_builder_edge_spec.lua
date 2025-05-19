-- tests/tag_editor_GUI_builder_edge_spec.lua
-- Edge case tests for gui/tag_editor_GUI_builder.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local TagEditorGUIBuilder = require("gui.tag_editor_GUI_builder")

_G.defines = _G.defines or { render_mode = { chart = "chart", game = "game" } }

describe("TagEditorGUIBuilder (edge cases)", function()
  it("returns nil for invalid player or position types", function()
    assert.is_nil(TagEditorGUIBuilder.open(123, {x=1,y=2}, {}))
    assert.is_nil(TagEditorGUIBuilder.open({name="foo"}, "not_a_pos", {}))
  end)
end)
