--- tag_editor_GUI.lua
--- Handles the tag editor dialog for FavoriteTeleport mod

local TagEditorGUI = {}

local Constants = require("constants")
local ErrorHandler = require("core/utils/error_handler")

--- Opens the tag editor GUI for a player
-- @param player LuaPlayer
-- @param position MapPosition|nil The map position that was clicked (optional)
function TagEditorGUI.open(player, position)
  TagEditorGUI.close(player) -- Ensure only one instance

  local gui = player.gui.screen
  local frame = gui.add{
    type = "frame",
    name = "ft_tag_editor_frame",
    caption = "Tag Editor",
    direction = "vertical",
    style = "inside_shallow_frame_with_padding" -- Added appropriate style for a dialog frame
  }
  frame.style.width = 200
  frame.style.height = 200

  -- Title label (large, bold)
  frame.add{
    type = "label",
    caption = "[font=default-large-bold]Tag Editor[/font]",
    style = "bold_label"
  }

  -- Position label
  if position then
    frame.add{
      type = "label",
      caption = string.format("Position: [%.2f, %.2f]", position.x, position.y)
    }
  end

  -- Close button (bottom)
  frame.add{
    type = "button",
    name = "ft_tag_editor_close_btn",
    caption = "Close"
  }

  -- X button (top right)
  local x_btn = frame.add{
    type = "sprite-button",
    name = "ft_tag_editor_x_btn",
    sprite = "utility/close",
    style = "frame_action_button"
  }
  x_btn.style.top_margin = -32
  x_btn.style.right_margin = -8

  player.opened = frame
end

--- Closes the tag editor GUI for a player
-- @param player LuaPlayer
function TagEditorGUI.close(player)
  local gui = player.gui.screen
  if gui.ft_tag_editor_frame then
    gui.ft_tag_editor_frame.destroy()
  end
end

--- Handles GUI click events for the tag editor
-- @param event EventData.on_gui_click
function TagEditorGUI.on_click(event)
  -- This handler must be registered in control.lua where 'game' is defined
  if not event or not event.player_index then return end
  -- The player will be resolved in the event handler in control.lua
  if event.element and (event.element.name == "ft_tag_editor_close_btn" or event.element.name == "ft_tag_editor_x_btn") then
    return "close"
  end
end

return TagEditorGUI
