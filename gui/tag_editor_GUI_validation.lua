-- Validation and error handling for the tag editor
local TagEditorGUIValidation = {}

function TagEditorGUIValidation.validate_inputs(icon, text, description, player)
  if (not icon or icon == "") and (not text or text == "") then
    player.print{"FavoriteTeleport.ft_tag_editor_save_tooltip"}
    return false
  end
  if text and #text > 75 then
    player.print{"FavoriteTeleport.ft_tag_editor_error_text_length"}
    return false
  end
  if description and #description > 75 then
    player.print{"FavoriteTeleport.ft_tag_editor_error_description_length"}
    return false
  end
  return true
end

return TagEditorGUIValidation