-- Validation and error handling for the tag editor
local TagEditorGUIValidation = {}

local MAX_TEXT_LENGTH = 75
local MAX_DESCRIPTION_LENGTH = 75

-- Strategy pattern: each rule is a function that returns true/false and an error key
local validation_strategies = {
  function(icon, text, description, player)
    if (not icon or icon == "") and (not text or text == "") then
      return false, "FavoriteTeleport.ft_tag_editor_save_tooltip"
    end
    return true
  end,
  function(icon, text, description, player)
    if text and #text > MAX_TEXT_LENGTH then
      -- Truncate and trim excess
      local truncated = text:sub(1, MAX_TEXT_LENGTH)
      if player and truncated ~= text then
        player.print{"FavoriteTeleport.ft_tag_editor_error_text_length"}
      end
      return true, truncated
    end
    return true
  end,
  function(icon, text, description, player)
    if description and #description > MAX_DESCRIPTION_LENGTH then
      -- Truncate and trim excess
      local truncated = description:sub(1, MAX_DESCRIPTION_LENGTH)
      if player and truncated ~= description then
        player.print{"FavoriteTeleport.ft_tag_editor_error_description_length"}
      end
      return true, nil, truncated
    end
    return true
  end
}

function TagEditorGUIValidation.validate_inputs(icon, text, description, player)
  local new_text, new_description = text, description
  for i, strategy in ipairs(validation_strategies) do
    local ok, t, d = strategy(icon, new_text, new_description, player)
    if not ok then
      return false
    end
    if t then new_text = t end
    if d then new_description = d end
  end
  return true, new_text, new_description
end

return TagEditorGUIValidation