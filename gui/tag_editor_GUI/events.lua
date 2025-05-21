-- Tag editor GUI event handlers
local TagEditorGUIEvents = {}
local Storage = require('core.storage')

local GUICommands = {
  close = function(event, TagEditorGUI, player)
    return "close"
  end,
  icon_picker = function(event, TagEditorGUI, player)
    return "icon_picker"
  end,
  toggled_favorite_in_place = function(event, TagEditorGUI, player)
    -- Only toggle the icon, do not update storage
    if TagEditorGUI and TagEditorGUI.toggle_favorite_icon then
      TagEditorGUI.toggle_favorite_icon(player)
    end
    return "toggled_favorite_in_place"
  end,
  delete = function(event, TagEditorGUI, player)
    return "delete"
  end,
  confirm = function(event, TagEditorGUI, player)
    if player and TagEditorGUI and TagEditorGUI.handle_confirm then
      TagEditorGUI.handle_confirm(player)
      TagEditorGUI.close(player)
    end
    return "confirm"
  end,
  move = function(event, TagEditorGUI, player)
    return "move"
  end
}

-- Helper: returns true if the element is inside the tag editor frame
local function is_inside_tag_editor(element)
  while element do
    if element.name == "ft_tag_editor_outer_frame" then
      return true
    end
    element = element.parent
  end
  return false
end

-- Patch: ignore clicks outside tag editor when open
local old_on_click = TagEditorGUIEvents.on_click
function TagEditorGUIEvents.on_click(event, TagEditorGUIParam, player)
  local TagEditorGUI_local = TagEditorGUIParam
  if not TagEditorGUI_local then
    error("TagEditorGUI must be passed to on_click as a parameter to avoid circular require.")
  end
  if not event or not event.element or not event.element.valid then return end
  local gui_player = player or (event.player_index and _G and _G.game and _G.game.get_player and _G.game.get_player(event.player_index))
  local outer = nil
  if gui_player and gui_player.gui and gui_player.gui.screen then
    -- Use direct access, not require, to avoid runtime error
    for _, child in pairs(gui_player.gui.screen.children) do
      if child.name == "ft_tag_editor_outer_frame" then
        outer = child
        break
      end
    end
  end
  if outer then
    if not is_inside_tag_editor(event.element) and event.element.name ~= "ft_tag_editor_outer_frame" then
      -- Click was outside the tag editor, ignore
      return
    end
  end
  local name = event.element.name
  if name == "ft_tag_editor_x_btn" or name == "ft_tag_editor_close_btn" then
    return GUICommands.close(event, TagEditorGUI_local, player)
  elseif name == "tag-editor-icon" then
    return GUICommands.icon_picker(event, TagEditorGUI_local, player)
  elseif name == "ft_tag_editor_favorite_btn" then
    return GUICommands.toggled_favorite_in_place(event, TagEditorGUI_local, player)
  elseif name == "ft_tag_editor_delete_btn" then
    return GUICommands.delete(event, TagEditorGUI_local, player)
  elseif name == "ft_tag_editor_save_btn" then
    return GUICommands.confirm(event, TagEditorGUI_local, player)
  elseif name == "ft_tag_editor_move_btn" then
    return GUICommands.move(event, TagEditorGUI_local, player)
  end
end

return TagEditorGUIEvents