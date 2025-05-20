--- tag_editor_GUI.lua
--- Handles the tag editor dialog for FavoriteTeleport mod

local Constants = require("constants")
local Helpers = require("core.utils.helpers")
local Storage = require("core.storage")
local TagEditorGUIBuilder = require("gui.tag_editor_GUI_builder")
local TagEditorGUIValidation = require("gui.tag_editor_GUI.validation")
local TagEditorGUIEvents = require("gui.tag_editor_GUI.events")
local GuiBase = require("gui.gui_base")
local MapTag = require("core.map_tag")
local ChartTagOps = require("gui.tag_editor_GUI.chart_tag_ops")
local FavoriteOps = require("gui.tag_editor_GUI.favorite_ops")
local Actions = require("gui.tag_editor_GUI.actions")

local TagEditorGUI = {}
TagEditorGUI.current_position = nil -- Stores the current MapPosition for the open tag editor

function TagEditorGUI.open(player, position, context)
  Storage.set_tag_editor_position(player, position)
  return TagEditorGUIBuilder.open(player, position, context)
end

function TagEditorGUI.get_current_position(player)
  return Storage.get_tag_editor_position(player)
end

function TagEditorGUI.close(player)
  Storage.clear_tag_editor_position(player)
  return TagEditorGUIBuilder.close(player)
end

TagEditorGUI.add_row = TagEditorGUIBuilder.add_row
TagEditorGUI.on_click = TagEditorGUIEvents.on_click

--- Extracts icon, text, description, and favorite state from the tag editor GUI
-- @param frame LuaGuiElement (ft_tag_editor_frame)
-- @return table {icon, text, description, is_favorite, favorite_btn, icon_picker, text_box, desc_box}
function TagEditorGUI.get_gui_input(frame, player)
  local favorite_btn = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "ft_tag_editor_favorite_btn")
  local icon_picker = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "tag-editor-icon")
  local text_box = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "ft_tag_editor_textbox")
  local desc_box = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "ft_tag_editor_descbox")
  local icon = icon_picker and icon_picker.elem_value or nil
  local text = text_box and (text_box.text or ""):gsub("^%s*(.-)%s*$", "%1") or ""
  local description = desc_box and (desc_box.text or ""):gsub("^%s*(.-)%s*$", "%1") or ""
  local is_favorite = (favorite_btn and favorite_btn.sprite and favorite_btn.sprite ~= "")
  return {
    icon = icon,
    text = text,
    description = description,
    is_favorite = is_favorite,
    favorite_btn = favorite_btn,
    icon_picker = icon_picker,
    text_box = text_box,
    desc_box = desc_box
  }
end

TagEditorGUI.find_create_chart_tag_on_confirm = ChartTagOps.find_create_chart_tag_on_confirm
TagEditorGUI.find_create_map_tag_on_confirm = function(player, gps, chart_tag, input)
  return ChartTagOps.find_create_map_tag_on_confirm(player, gps, chart_tag, input,
    TagEditorGUI.get_current_position(player))
end
TagEditorGUI.handle_confirm = function(player)
  return Actions.handle_confirm(TagEditorGUI, player)
end
TagEditorGUI.update_favorite = FavoriteOps.update_favorite
TagEditorGUI.remove_favorite = FavoriteOps.remove_favorite

--- Handles tag editor actions (confirm, delete, move)
-- @param player LuaPlayer
-- @param action string
function TagEditorGUI.handle_action(player, action)
  if not player then return end
  local gui = player.gui.screen
  local frame = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "ft_tag_editor_frame")
  if not frame then return end

  local surface = player.surface
  local surface_index = surface.index
  local player_index = player.index

  if action == "confirm" then
    TagEditorGUI.handle_confirm(player)
  elseif action == "delete" then
    local gps = frame.ft_tag_editor_teleport_row.ft_tag_editor_pos_btn.caption
    -- Use the new storage method to destroy the chart tag and remove from storage
    local destroyed = Storage.destroy_chart_tag(player, gps)
    -- Remove map tag if present
    local map_tags = Storage.get_map_tags(player)
    local map_tag, map_idx = Storage.find_map_tag_by_gps(player, gps)
    if map_tag and map_idx then
      table.remove(map_tags, map_idx)
    end
    Storage.reset_chart_tags(player)
    if Storage.save_data then Storage.save_data(Storage.get()) end
    TagEditorGUI.close(player)
    return
  elseif action == "move" then
    local storage = Storage.get()
    storage.ft_tag_editor_move_mode = storage.ft_tag_editor_move_mode or {}
    storage.ft_tag_editor_move_mode[player.index] = {
      active = true,
      surface_index = player.surface.index,
      gps = frame.ft_tag_editor_teleport_row.ft_tag_editor_pos_btn.caption
    }
    if Storage.save_data then Storage.save_data(storage) end

    TagEditorGUI.close(player)
    return
  end
end

-- Helper: update the confirm/save <button> state and tooltip in the tag editor
function TagEditorGUI.update_save_btn(player)
  if not player then return end
  local gui = player.gui.screen
  local outer = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "ft_tag_editor_outer_frame")
  if not outer then return end
  local frame = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "ft_tag_editor_frame")
  if not frame then return end
  local content_frame = frame.ft_tag_editor_content_frame
  if not content_frame then return end
  local action_row = outer.ft_tag_editor_action_row
  local save_btn = action_row and action_row.ft_tag_editor_save_btn
  local text_box = GuiBase.find_by_path(content_frame, { "ft_tag_editor_text_row", "ft_tag_editor_textbox" })
  local icon_picker = GuiBase.find_by_path(content_frame, { "ft_tag_editor_icon_row", "tag-editor-icon" })
  if not save_btn then return end
  local text_val = text_box and text_box.text and text_box.text:match("%S") or ""
  local icon_val = icon_picker and icon_picker.elem_value or ""
  local icon_selected = false
  if type(icon_val) == "table" then
    icon_selected = icon_val.name ~= nil and icon_val.name ~= ""
  elseif type(icon_val) == "string" then
    icon_selected = icon_val ~= ""
  end
  -- Enable if either text is non-empty or icon is selected
  save_btn.enabled = (text_val ~= "") or icon_selected
  if save_btn.enabled then
    save_btn.tooltip = ""
  else
    save_btn.tooltip = { "ft_tag_editor_save_tooltip" }
  end
end

-- Helper: returns true if the element is inside the tag editor frame
local function click_is_inside_tag_editor(element)
  while element do
    if element.name == "ft_tag_editor_outer_frame" then
      return true
    end
    element = element.parent
  end
  return false
end

-- Helper: returns player_index from event, fallback if Helpers.find_player_index_in_event is missing
local function get_player_index_from_event(event)
  if Helpers and Helpers.find_player_index_in_event then
    return Helpers.find_player_index_in_event(event)
  end
  return event and event.player_index or nil
end

-- Patch: ignore clicks outside tag editor when open
-- In TagEditorGUI.on_click, handle the close button
function TagEditorGUI.on_click(event)
  if not event or not event.player_index then return end
  local player_index = event.player_index
  local player = _G.game.get_player(player_index)
  if not player then return end
  local gui = player.gui.screen
  -- NOTE: This check is valid. find_gui_element_by_name now returns the parent if parent_name == target_name.
  local outer = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "ft_tag_editor_outer_frame")
  if outer then
    local element = event.element
    if element and element.valid then
      if element.name == "ft_tag_editor_x_btn" then
        TagEditorGUI.close(player)
        return
      elseif element.name == "ft_tag_editor_favorite_btn" then
        TagEditorGUI.toggle_favorite_icon(player)
        return
      end
    end
  end
  -- ...existing code...
end

function TagEditorGUI.on_open_tag_editor(event)
  if not event or not event.player_index then return end
  ---@diagnostic disable-next-line: undefined-global
  local player = game.get_player(event.player_index)
  if not player then return end
  -- Prevent opening in map editor mode
  ---@diagnostic disable-next-line: undefined-global
  if player.render_mode ~= defines.render_mode.chart then
    return
  end
  -- Open the tag editor at the player's current position; adjust as needed for your context
  TagEditorGUI.open(player, event.cursor_position or player.position, {})
end

-- Patch: update only the favorite button icon when toggled, do not refresh the whole GUI
function TagEditorGUI.toggle_favorite_icon(player)
  if not player then return end
  local favorite_btn = Helpers.find_gui_element_by_name(player, "ft_tag_editor_outer_frame", "ft_tag_editor_favorite_btn")
  if not favorite_btn or not favorite_btn.valid then return end
  favorite_btn.sprite = (favorite_btn.sprite == "utility/check_mark_green") and "" or "utility/check_mark_green"
end

function TagEditorGUI.on_text_changed(event)
  if not event or not event.element or not event.element.valid then return end
  local player = _G.game.get_player(event.player_index)
  if not player then return end
  -- Only update if the changed element is the tag editor text field (not desc field)
  if event.element.name == "ft_tag_editor_textbox" then
    TagEditorGUI.update_save_btn(player)
  end
end

function TagEditorGUI.on_elem_changed(event)
  if not event or not event.element or not event.element.valid then return end
  local player = _G.game.get_player(event.player_index)
  if not player then return end
  -- Only update if the changed element is the tag editor icon picker
  if event.element.name == "tag-editor-icon" then
    TagEditorGUI.update_save_btn(player)
  end
end

return TagEditorGUI
