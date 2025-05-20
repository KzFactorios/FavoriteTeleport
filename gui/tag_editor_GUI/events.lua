-- Tag editor GUI event handlers
local TagEditorGUIEvents = {}
local Storage = require('core.storage')

-- Command pattern: encapsulate each GUI action as a command object
local GUICommands = {
  close = function(event, TagEditorGUI, player)
    return "close"
  end,
  icon_picker = function(event, TagEditorGUI, player)
    return "icon_picker"
  end,
  toggled_favorite_in_place = function(event, TagEditorGUI, player)
    ---@diagnostic disable-next-line: undefined-global
    player = player or (event.player_index and game.get_player and game.get_player(event.player_index) or nil)
    if not player then return end
    -- Try to get GPS from the GUI
    local gps = nil
    local gui = player.gui.screen
    local outer = gui.ft_tag_editor_outer_frame
    if outer then
      local frame = outer.ft_tag_editor_frame
      if frame then
        for _, child in pairs(frame.children) do
          if child.name == "ft_tag_editor_teleport_row" then
            for _, btn in pairs(child.children) do
              if btn.name == "ft_tag_editor_pos_btn" then
                gps = btn.caption
                break
              end
            end
          end
        end
      end
    end
    if not gps then return end
    local Storage = require('core.storage')
    local map_tag = Storage.find_map_tag_by_gps(player, gps)
    if map_tag and type(map_tag.is_player_favorite) == "function" then
      if map_tag:is_player_favorite(player) then
        if type(map_tag.remove_favorite) == "function" then map_tag:remove_favorite(player) end
      else
        if type(map_tag.add_favorite) == "function" then map_tag:add_favorite(player) end
      end
    else
      local favorites = Storage.get_player_favorites(player)
      for _, fav in pairs(favorites) do
        if fav.gps == gps then
          fav.is_favorite = not fav.is_favorite
        end
      end
    end
    -- Only update the favorite button icon, do not refresh the whole GUI
    if TagEditorGUI and TagEditorGUI.toggle_favorite_icon then
      TagEditorGUI.toggle_favorite_icon(player)
    end

    -- After toggling, update the button icon to match the new favorite state
    local favorite_btn = require('gui.gui_base').find_by_path(
      player.gui.screen.ft_tag_editor_outer_frame.ft_tag_editor_frame.ft_tag_editor_content_frame,
      {"ft_tag_editor_favorite_row", "ft_tag_editor_favorite_btn"}
    )
    if favorite_btn and favorite_btn.valid then
      local is_favorite = false
      local map_tag = Storage.find_map_tag_by_gps(player, gps)
      if map_tag and type(map_tag.is_player_favorite) == "function" then
        is_favorite = map_tag:is_player_favorite(player)
      else
        local favorites = Storage.get_player_favorites(player)
        for _, fav in pairs(favorites) do
          if fav.gps == gps then
            is_favorite = fav.is_favorite
            break
          end
        end
      end
      favorite_btn.sprite = is_favorite and "utility/check_mark_green" or nil
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
  if gui_player and gui_player.gui and gui_player.gui.screen and gui_player.gui.screen.ft_tag_editor_outer_frame then
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
    return GUICommands.delete(event, TagEditorGUI_local, player)
  elseif name == "ft_tag_editor_save_btn" then
    return GUICommands.confirm(event, TagEditorGUI_local, player)
  elseif name == "ft_tag_editor_move_btn" then
    return GUICommands.move(event, TagEditorGUI_local, player)
  end
end

return TagEditorGUIEvents