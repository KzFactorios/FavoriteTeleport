--- @class MapTag
--- Represents a map tag object for FavoriteTeleport mod
--- @field tag LuaCustomChartTag|nil The underlying Factorio chart tag object
--- @field pos_string string The position string (e.g., "000.-1350")
--- @field created_by uint The player index who created the tag
--- @field icon string|nil The icon name for the tag
--- @field text string|nil The text for the tag
--- @field display_text string|nil Additional text for the tag
--- @field new fun(tag:LuaCustomChartTag, pos_string: string, player_index: uint, icon: SignalID, text: string, display_text: string): MapTag
local MapTag = {}

-- If you previously required 'core/chart_tag', update to 'core/map_tag' in your codebase as needed.
-- All logic and type definitions are now in MapTag.

--- Creates a new MapTag instance
-- @param tag LuaCustomChartTag|nil
-- @param pos_string string
-- @param player_index uint
-- @param icon string|nil
-- @param text string|nil
-- @param display_text string|nil
-- @return MapTag
function MapTag.new(tag, pos_string, player_index, icon, text, display_text)
  return {
    tag = tag,
    pos_string = pos_string,
    created_by = player_index,
    icon = icon,
    text = text,
    display_text = display_text
  }
end

--- Checks if the underlying map tag is valid
-- @return boolean
function MapTag:is_tag_valid()
  return self.tag ~= nil and self.tag.valid == true
end

-- handle changes from the stock tag editor
-- see if we can throw this only when the gui-tag-edit (stock editor) makes changes
function MapTag:on_chart_tag_modified(event)
  -- TODO implement
end




return MapTag
