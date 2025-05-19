-- tests/tag_editor_GUI_validation_spec.lua
-- Unit tests for gui/tag_editor_GUI_validation.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local TagEditorGUIValidation = require("gui.tag_editor_GUI_validation")

local function mock_player()
  return {
    name = "TestPlayer",
    index = 1,
    surface = { index = 1 },
    print = function() end
  }
end

describe("TagEditorGUIValidation", function()
  it("validates a correct input", function()
    local player = mock_player()
    local valid, text, desc = TagEditorGUIValidation.validate_inputs({ x = 10, y = 20 }, { name = "signal-A" }, "Test", "Desc", player)
    assert.is_true(valid)
    assert.equals("Test", text)
    assert.equals("Desc", desc)
  end)

  it("invalidates missing position", function()
    local player = mock_player()
    local valid = TagEditorGUIValidation.validate_inputs(nil, { name = "signal-A" }, "Test", "Desc", player)
    assert.is_false(valid)
  end)

  it("invalidates too long text", function()
    local player = mock_player()
    local long_text = string.rep("a", 100)
    local valid = TagEditorGUIValidation.validate_inputs({ x = 10, y = 20 }, { name = "signal-A" }, long_text, "Desc", player)
    assert.is_false(valid)
  end)

  it("invalidates too long description", function()
    local player = mock_player()
    local long_desc = string.rep("a", 100)
    local valid = TagEditorGUIValidation.validate_inputs({ x = 10, y = 20 }, { name = "signal-A" }, "Test", long_desc, player)
    assert.is_false(valid)
  end)
end)
