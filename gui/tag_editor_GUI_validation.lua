-- Validation and error handling for the tag editor
local TagEditorGUIValidation = {}

-- Strategy pattern: each rule is a function that returns true/false and an error key
local validation_strategies = {
  function(icon, text, description, player)
    if (not icon or icon == "") and (not text or text == "") then
      return false, "FavoriteTeleport.ft_tag_editor_save_tooltip"
    end
    return true
  end,
  function(icon, text, description, player)
    if text and #text > 75 then
      return false, "FavoriteTeleport.ft_tag_editor_error_text_length"
    end
    return true
  end,
  function(icon, text, description, player)
    if description and #description > 75 then
      return false, "FavoriteTeleport.ft_tag_editor_error_description_length"
    end
    return true
  end
}

function TagEditorGUIValidation.validate_inputs(icon, text, description, player)
  for _, strategy in ipairs(validation_strategies) do
    local ok, err_key = strategy(icon, text, description, player)
    if not ok then
      if player and err_key then player.print{err_key} end
      return false
    end
  end
  return true
end

return TagEditorGUIValidation