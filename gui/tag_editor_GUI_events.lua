-- Tag editor GUI event handlers
local TagEditorGUIEvents = {}

-- Command pattern: encapsulate each GUI action as a command object
local GUICommands = {
  close = function(event, TagEditorGUI)
    return "close"
  end,
  icon_picker = function(event, TagEditorGUI)
    return "icon_picker"
  end,
  toggled_favorite_in_place = function(event, TagEditorGUI)
    if event.element.sprite and event.element.sprite ~= "" then
      event.element.sprite = nil
    else
      event.element.sprite = "utility/check_mark_green"
    end
    return "toggled_favorite_in_place"
  end,
  delete = function(event, TagEditorGUI)
    return "delete"
  end,
  confirm = function(event, TagEditorGUI)
    return "confirm"
  end,
  move = function(event, TagEditorGUI)
    return "move"
  end
}

function TagEditorGUIEvents.on_click(event, TagEditorGUI)
  if not event or not event.element or not event.element.valid then return end
  local name = event.element.name
  if name == "ft_tag_editor_x_btn" or name == "ft_tag_editor_close_btn" then
    return GUICommands.close(event, TagEditorGUI)
  elseif name == "tag-editor-icon" then
    return GUICommands.icon_picker(event, TagEditorGUI)
  elseif name == "ft_tag_editor_favorite_btn" then
    return GUICommands.toggled_favorite_in_place(event, TagEditorGUI)
  elseif name == "ft_tag_editor_delete_btn" then
    return GUICommands.delete(event, TagEditorGUI)
  elseif name == "ft_tag_editor_save_btn" then
    return GUICommands.confirm(event, TagEditorGUI)
  elseif name == "ft_tag_editor_move_btn" then
    return GUICommands.move(event, TagEditorGUI)
  end
end

return TagEditorGUIEvents