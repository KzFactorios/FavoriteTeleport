-- Tag editor GUI event handlers
local TagEditorGUIEvents = {}
local Storage = require('core.storage')
local Helpers = require('core.utils.helpers')
local TagSync = require('core.tag_sync.tag_sync_suite')

local GUICommands = {
  close = function(event, TagEditorGUI, player)
    return "close"
  end,
  icon_picker = function(event, TagEditorGUI, player)
    return "icon_picker"
  end,
  toggled_favorite_in_place = function(event, TagEditorGUI, player)
    -- Only toggle the icon, do not update storage
    if TagEditorGUI and TagEditorGUI.toggle_favorite_icon then
      TagEditorGUI.toggle_favorite_icon(player)
    end
    return "toggled_favorite_in_place"
  end,
  delete = function(event, TagEditorGUI, player)
    return "delete"
  end,
  confirm = function(event, TagEditorGUI, player)
    if player and TagEditorGUI and TagEditorGUI.handle_confirm then
      TagEditorGUI.handle_confirm(player)
      TagEditorGUI.close(player)
    end
    return "confirm"
  end,
  move = function(event, TagEditorGUI, player)
    return "move"
  end
}

-- Helper: returns true if the element is inside the tag editor frame
local function is_inside_tag_editor(element)
  while element do
    if element.name == "ft_tag_editor_outer_frame" then
      return true
    end
    element = element.parent
  end
  return false
end

-- Patch: ignore clicks outside tag editor when open
local old_on_click = TagEditorGUIEvents.on_click
function TagEditorGUIEvents.on_click(event, TagEditorGUIParam, player)
  local TagEditorGUI_local = TagEditorGUIParam
  if not TagEditorGUI_local then
    error("TagEditorGUI must be passed to on_click as a parameter to avoid circular require.")
  end
  if not event or not event.element or not event.element.valid then return end
  local gui_player = player or (event.player_index and _G and _G.game and _G.game.get_player and _G.game.get_player(event.player_index))
  local outer = nil
  if gui_player and gui_player.gui and gui_player.gui.screen then
    -- Use direct access, not require, to avoid runtime error
    for _, child in pairs(gui_player.gui.screen.children) do
      if child.name == "ft_tag_editor_outer_frame" then
        outer = child
        break
      end
    end
  end
  if outer then
    if not is_inside_tag_editor(event.element) and event.element.name ~= "ft_tag_editor_outer_frame" then
      -- Click was outside the tag editor, ignore
      return
    end
  end
  local name = event.element.name
  if name == "ft_tag_editor_x_btn" or name == "ft_tag_editor_close_btn" then
    return GUICommands.close(event, TagEditorGUI_local, player)
  elseif name == "tag-editor-icon" then
    return GUICommands.icon_picker(event, TagEditorGUI_local, player)
  elseif name == "ft_tag_editor_favorite_btn" then
    return GUICommands.toggled_favorite_in_place(event, TagEditorGUI_local, player)
  elseif name == "ft_tag_editor_delete_btn" then
    -- Remove chart_tag, map_tag, and manage favorites for the current tag editor position
    local tag_editor_positions = Storage.get().tag_editor_positions or {}
    local pos = tag_editor_positions[player.index]
    if pos then
      local gps = Helpers.format_gps(pos.x, pos.y, player.surface.index)
      TagSync.delete_tag(player, gps)
    end
    TagEditorGUI_local.close(player) -- Ensure the tag editor closes after delete
    return GUICommands.delete(event, TagEditorGUI_local, player)
  elseif name == "ft_tag_editor_move_btn" then
    -- Activate move mode: next valid left-click on map will trigger the move
    local tag_editor_positions = Storage.get().tag_editor_positions or {}
    local pos = tag_editor_positions[player.index]
    if pos then
      -- Set a flag in storage to indicate move mode for this player
      local storage = Storage.get()
      storage.ft_tag_editor_move_mode = storage.ft_tag_editor_move_mode or {}
      storage.ft_tag_editor_move_mode[player.index] = {
        active = true,
        surface_index = player.surface.index,
        gps = Helpers.format_gps(pos.x, pos.y, player.surface.index)
      }
      if Storage.save_data then Storage.save_data(storage) end
      -- The actual rendering of the move marker must be handled in control.lua on the next tick
      -- (see coding_standards.md for why rendering API is not available here)
      -- Optionally, show a flying text to indicate move mode
      player.create_local_flying_text{text = {"ft_tag_editor_move_mode_active"}, position = pos, color = {r=0.7,g=0.7,b=1}}
    end
    TagEditorGUI_local.close(player)
    return GUICommands.move(event, TagEditorGUI_local, player)
  end
end

-- Do NOT register runtime events here! Move marker flow event registration must be in control.lua, not in this GUI event handler file.

return TagEditorGUIEvents