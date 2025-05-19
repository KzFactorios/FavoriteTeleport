-- Syntax highlighting note:
-- The following Lua words are considered 'keywords' for editor colorization:
--   local, function, if, then, else, elseif, end, for, while, do, break, repeat, until, return, not, and, or, in
-- These are typically styled by the 'keyword' or 'editorKeyword.foreground' color in VS Code settings.

-- Validation and error handling for the tag editor
local TagEditorGUIValidation = {}

local MAX_TEXT_LENGTH = 75
local MAX_DESCRIPTION_LENGTH = 75

-- Strategy pattern: each rule is a function that returns true/false and an error key
local validation_strategies = {
  function(icon, text, description, player, position)
    if not position or type(position) ~= "table" or type(position.x) ~= "number" or type(position.y) ~= "number" then
      if player then player.print{"FavoriteTeleport.ft_tag_editor_error_invalid_position"} end
      return false, "FavoriteTeleport.ft_tag_editor_error_invalid_position"
    end
    return true
  end,
  function(icon, text, description, player)
    if (not icon or icon == "") and (not text or text == "") then
      return false, "FavoriteTeleport.ft_tag_editor_save_tooltip"
    end
    return true
  end,
  function(icon, text, description, player)
    if text and #text > MAX_TEXT_LENGTH then
      if player then player.print{"FavoriteTeleport.ft_tag_editor_error_text_length"} end
      return false
    end
    return true
  end,
  function(icon, text, description, player)
    if description and #description > MAX_DESCRIPTION_LENGTH then
      if player then player.print{"FavoriteTeleport.ft_tag_editor_error_description_length"} end
      return false
    end
    return true
  end
}

function TagEditorGUIValidation.validate_inputs(position, icon, text, description, player)
  local new_text, new_description = text, description
  for i, strategy in ipairs(validation_strategies) do
    local ok, t, d = strategy(icon, new_text, new_description, player, position)
    if not ok then
      return false
    end
    if t then new_text = t end
    if d then new_description = d end
  end
  return true, new_text, new_description
end

return TagEditorGUIValidation