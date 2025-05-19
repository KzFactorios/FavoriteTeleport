-- tests/tag_editor_GUI_validation_edge_spec.lua
-- Edge case tests for gui/tag_editor_GUI_validation.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local TagEditorGUIValidation = require("gui.tag_editor_GUI_validation")

describe("TagEditorGUIValidation (edge cases)", function()
  it("invalidates nil icon, text, description, or player", function()
    assert.is_false(TagEditorGUIValidation.validate_inputs({x=1,y=2}, nil, nil, nil, nil))
  end)

  it("invalidates non-table position", function()
    local player = { print = function() end }
    assert.is_false(TagEditorGUIValidation.validate_inputs("not_a_pos", {name="signal-A"}, "Test", "Desc", player))
  end)
end)
