-- tests/tag_editor_GUI_edge_spec.lua
-- Edge case tests for gui/tag_editor_GUI.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local TagEditorGUI = require("gui.tag_editor_GUI")

describe("TagEditorGUI (edge cases)", function()
  it("handle_confirm does not error with nil player", function()
    assert.has_no.errors(function() TagEditorGUI.handle_confirm(nil) end)
  end)

  it("handle_action does not error with nil player or action", function()
    assert.has_no.errors(function() TagEditorGUI.handle_action(nil, nil) end)
  end)

  it("update_save_btn does not error with nil player", function()
    assert.has_no.errors(function() TagEditorGUI.update_save_btn(nil) end)
  end)

  it("on_click does not error with nil event", function()
    assert.has_no.errors(function() TagEditorGUI.on_click(nil) end)
  end)
end)
