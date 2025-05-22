local Constants = require("constants")
local Helpers = require("core.utils.helpers")
local Position = require("core.utils.position")
local Cache = require("core.cache.init")
local TopRow = require("gui.tag_editor_GUI_builder.top_row")
local ActionRow = require("gui.tag_editor_GUI_builder.action_row")
local ContentFrame = require("gui.tag_editor_GUI_builder.content_frame")

-- Optional: Patch for test environments where gui.tag_editor_gui_module does not exist
local ok, tag_editor_gui_module = pcall(require, "gui.tag_editor_gui_module")
if not ok then
  tag_editor_gui_module = { update_save_btn = function() end }
end

local TagEditorGUIBuilder = {}

-- Builder object for tag editor GUI
local TagEditorGUIBuilderClass = {}
TagEditorGUIBuilderClass.__index = TagEditorGUIBuilderClass

function TagEditorGUIBuilderClass:new(player, position, context)
  if not player or not position then return end
  -- Fix: Correct render_mode check
  if player.render_mode ~= _G.defines.render_mode.chart then return end

  if Position.is_on_space_platform and Position.is_on_space_platform(player) or player.character == nil then return end

  -- Snap to canonical position for tag creation
  position = Helpers.snap_position(position, Constants.settings.SNAP_SCALE_FOR_CLICKED_TAG)
  local position_can_be_tagged = Position.position_can_be_tagged(player, position)
  if not position_can_be_tagged then
    -- Show feedback if the position cannot be tagged
    player.create_local_flying_text{
      text = {'ft_tag_editor_cannot_tag_here'},
      position = position,
      color = {r=1, g=0.2, b=0.2}
    }
    return nil
  end

  --- @type LuaCustomChartTag|nil
  local chart_tag = nil
  -- Always use canonical GPS string for this surface/position
  local gps = Helpers.format_gps(position.x, position.y, player.surface.index)

  -- Check for colliding tag (edit mode)
  local position_has_colliding_tag =
      Position.position_has_colliding_tag(player, position, Constants.settings.BOUNDING_BOX_TOLERANCE)
  if position_has_colliding_tag ~= nil then
    -- Normalize to the colliding tag's canonical GPS
    local collide_gps = Helpers.format_gps(position_has_colliding_tag.x, position_has_colliding_tag.y, player.surface.index)
    local found_tag = Cache.find_chart_tag_by_gps(player, collide_gps)
    -- Update chart_tag to snapped/collided pos
    chart_tag = Cache.rehome_chart_tag(player, found_tag, collide_gps)
    gps = collide_gps
  end

  -- Always look up chart_tag and map_tag by canonical GPS
  chart_tag = Cache.find_chart_tag_by_gps(player, gps) or nil
  local map_tag = Cache.find_map_tag_by_gps(player, gps)

  local favorite_calc = map_tag and map_tag:is_player_favorite(player) or false

  -- Use the chart tag's position if available, else snapped position
  local effective_position = chart_tag and chart_tag.position or position

  -- Always set the tag editor position to the effective position
  Cache.set_tag_editor_position(player, effective_position)

  -- Always use canonical GPS for the builder object
  local canonical_gps = Helpers.format_gps(effective_position.x, effective_position.y, player.surface.index)

  local o = {
    player = player,
    position = effective_position, -- use the chart tag's pos if present
    is_favorite = favorite_calc,
    context = context,
    gui = player.gui.screen,
    outer_frame = nil,
    content_frame = nil,
    gps = canonical_gps,
    chart_tag = chart_tag,
    map_tag = map_tag
  }
  setmetatable(o, self)
  return o
end

function TagEditorGUIBuilderClass:build_outer_frame()
  -- Ensure no duplicate outer frame exists
  if self.gui.ft_tag_editor_outer_frame then
    self.gui.ft_tag_editor_outer_frame.destroy()
  end
  self.outer_frame = self.gui.add {
    type = "frame",
    name = "ft_tag_editor_outer_frame",
    direction = "vertical",
    style = "frame"
  }
  if self.outer_frame.force_auto_center then
    self.outer_frame.force_auto_center()
  end
  return self
end

function TagEditorGUIBuilderClass:build_titlebar()
  local titlebar_flow = self.outer_frame.add {
    type = "flow",
    direction = "horizontal",
    name = "ft_tag_editor_titlebar_flow"
  }
  titlebar_flow.style.horizontally_stretchable = true
  titlebar_flow.style.vertical_align = "center"
  titlebar_flow.style.top_padding = 2
  titlebar_flow.style.bottom_padding = 2

  local title_label = titlebar_flow.add {
    type = "label",
    caption = { "ft_tag_editor_title" },
    style = "frame_title"
  }
  title_label.style.left_margin = 4
  title_label.style.right_margin = 4

  local handle = titlebar_flow.add { type = "empty-widget", style = "draggable_space_header" }
  handle.style.horizontally_stretchable = true
  handle.style.height = 24
  handle.drag_target = self.outer_frame

  local close_btn = titlebar_flow.add {
    type = "sprite-button",
    name = "ft_tag_editor_x_btn",
    sprite = "utility/close",
    style = "frame_action_button"
  }
  -- The actual close logic is handled in the on_gui_click event in TagEditorGUI.on_click
  return self
end

function TagEditorGUIBuilderClass:build_content_frame()
  local frame = self.outer_frame.add {
    type = "frame",
    name = "ft_tag_editor_frame",
    caption = "",
    direction = "vertical",
    style = "inside_shallow_frame_with_padding",
    top_margin = 0
  }
  frame.style.horizontally_stretchable = true
  frame.style.vertically_stretchable = true
  frame.style.padding = 0

  -- Top row (last user, move/delete)
  TopRow:build( frame, self.player, self.chart_tag)

  -- Main content rows (teleport, favorite, icon, text, desc)
  ContentFrame.build(frame, self)

  return self
end

function TagEditorGUIBuilderClass:build_action_row()
  ActionRow.build(self.outer_frame, self.outer_frame)
  return self
end

function TagEditorGUIBuilderClass:finalize()
  self.player.opened = self.outer_frame -- Ensure ESC closes the tag editor
  if self.outer_frame.force_auto_center then
    self.outer_frame.force_auto_center()
  end
  return self.outer_frame
end

function TagEditorGUIBuilder.open(player, position, context)
  local type_check = type(player) == "table" or type(player) == "userdata"
  local pos_check = type(position) == "table"
  if not type_check or not pos_check then return nil end

  local builder = TagEditorGUIBuilderClass:new(player, position, context)
  if not builder then return nil end
  builder:build_outer_frame()
      :build_titlebar()
      :build_content_frame()
      :build_action_row()
  if tag_editor_gui_module and type(tag_editor_gui_module.update_save_btn) == "function" then
    local _ok, _err = pcall(tag_editor_gui_module.update_save_btn, player)
  end
  builder:finalize() -- Ensure ESC closes the tag editor
  return builder
end

function TagEditorGUIBuilder.close(player)
  local gui = player.gui.screen
  if gui.ft_tag_editor_outer_frame then
    gui.ft_tag_editor_outer_frame.destroy()
  end
  player.opened = nil -- Ensure vanilla ESC/game menu works when no dialogs are open
end

return TagEditorGUIBuilder

-- TODO: Modularize large logic blocks into gui/tag_editor_GUI_builder/ submodules and require them here.
