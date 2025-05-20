-- tag_editor_GUI_builder/validation.lua
-- Validation logic for tag editor GUI fields

local Validation = {}

function Validation.validate_tag_name(name)
  -- Example: tag name must be non-empty and less than 50 chars
  return type(name) == "string" and #name > 0 and #name <= 50
end

function Validation.validate_icon(icon)
  -- Example: icon must be a string and not empty
  return type(icon) == "string" and #icon > 0
end

-- Add more validation functions as needed

return Validation
