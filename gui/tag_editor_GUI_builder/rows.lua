-- tag_editor_GUI_builder/rows.lua
-- Contains row-building helpers for tag editor GUI

local Rows = {}

--- Adds a row to the tag editor GUI
-- @param parent LuaGuiElement
-- @param name string
-- @param label_caption string|table
-- @param label_style string
-- @param element_def table (definition for the main element)
-- @param opts table|nil (optional styling)
-- @return row, label, element
function Rows.add_row(parent, name, label_caption, label_style, element_def, opts)
  opts = opts or {}
  local row = parent.add { type = "flow", direction = "horizontal", name = name }
  if opts.top_margin then row.style.top_margin = opts.top_margin end
  row.style.vertical_align = "center"
  local label = row.add { type = "label", caption = label_caption, style = label_style }
  if opts.label_margin then label.style.left_margin = opts.label_margin end
  -- Add the main element (button, textfield, etc)
  local element = row.add(element_def)
  return row, label, element
end

return Rows
