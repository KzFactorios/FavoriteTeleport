-- string_utils.lua
-- String-related helpers for FavoriteTeleport

local StringUtils = {}

function StringUtils.split_string(str, delimiter)
  local result = {}
  if type(str) ~= "string" or type(delimiter) ~= "string" or delimiter == "" then
    return result
  end
  local pattern = string.format("([^%s]+)", delimiter:gsub("%%", "%%%%"))
  for match in str:gmatch(pattern) do
    table.insert(result, match)
  end
  return result
end

function StringUtils.is_nonempty_string(s)
  return type(s) == "string" and s:match("%S") ~= nil
end

return StringUtils
