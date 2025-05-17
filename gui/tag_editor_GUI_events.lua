-- Tag editor GUI event handlers
local TagEditorGUIEvents = {}
local TagEditorGUI = nil -- Will be set by the caller

-- Command pattern: encapsulate each GUI action as a command object
local GUICommands = {
  close = function(event, TagEditorGUI, player)
    return "close"
  end,
  icon_picker = function(event, TagEditorGUI, player)
    return "icon_picker"
  end,
  toggled_favorite_in_place = function(event, TagEditorGUI, player)
    if event.element.sprite and event.element.sprite ~= "" then
      event.element.sprite = nil
    else
      event.element.sprite = "utility/check_mark_green"
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

function TagEditorGUIEvents.on_click(event, TagEditorGUIParam, player)
  local TagEditorGUI = TagEditorGUIParam or TagEditorGUI
  if not TagEditorGUI then
    error("TagEditorGUI must be passed to on_click as a parameter to avoid circular require.")
  end
  if not event or not event.element or not event.element.valid then return end
  local name = event.element.name
  if name == "ft_tag_editor_x_btn" or name == "ft_tag_editor_close_btn" then
    return GUICommands.close(event, TagEditorGUI, player)
  elseif name == "tag-editor-icon" then
    return GUICommands.icon_picker(event, TagEditorGUI, player)
  elseif name == "ft_tag_editor_favorite_btn" then
    return GUICommands.toggled_favorite_in_place(event, TagEditorGUI, player)
  elseif name == "ft_tag_editor_delete_btn" then
    return GUICommands.delete(event, TagEditorGUI, player)
  elseif name == "ft_tag_editor_save_btn" then
    return GUICommands.confirm(event, TagEditorGUI, player)
  elseif name == "ft_tag_editor_move_btn" then
    return GUICommands.move(event, TagEditorGUI, player)
  end
end

return TagEditorGUIEvents