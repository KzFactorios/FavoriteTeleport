-- Tag editor GUI event handlers
local TagEditorGUIEvents = {}

function TagEditorGUIEvents.on_click(event, TagEditorGUI)
  if not event or not event.element or not event.element.valid then return end
  if event.element.name == "ft_tag_editor_x_btn" or event.element.name == "ft_tag_editor_close_btn" then
    return "close"
  end
  if event.element.name == "tag-editor-icon" then
    return "icon_picker"
  end
  if event.element.name == "ft_tag_editor_favorite_btn" then
    -- Toggle favorite state in-place using event.element
    if event.element.sprite and event.element.sprite ~= "" then
      event.element.sprite = nil
    else
      event.element.sprite = "utility/check_mark_green"
    end
    return "toggled_favorite_in_place"
  end
  if event.element.name == "ft_tag_editor_delete_btn" then
    return "delete"
  end
  if event.element.name == "ft_tag_editor_save_btn" then
    return "confirm"
  end
  if event.element.name == "ft_tag_editor_move_btn" then
    -- Optionally, add sound or visual feedback for button press
    return "move"
  end
end

return TagEditorGUIEvents