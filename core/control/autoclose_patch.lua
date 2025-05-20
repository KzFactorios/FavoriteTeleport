-- core/control/autoclose_patch.lua
-- Patches TagEditorGUI.open/close to start/stop autoclose only once per session

local TagEditorGUI = require("gui.tag_editor_GUI")

local function patch_tag_editor_autoclose(Control)
  if TagEditorGUI._autoclose_patched then return end
  local _orig_tag_editor_open = TagEditorGUI.open
  local _orig_tag_editor_close = TagEditorGUI.close
  TagEditorGUI.open = function(player, position, context)
    local result = _orig_tag_editor_open(player, position, context)
    Control.start_tag_editor_autoclose(player)
    return result
  end
  TagEditorGUI.close = function(player)
    Control.stop_tag_editor_autoclose(player)
    return _orig_tag_editor_close(player)
  end
  TagEditorGUI._autoclose_patched = true
end

return patch_tag_editor_autoclose
