---@diagnostic disable: undefined-global
-- control.lua
-- Main entry point for event registration and mod lifecycle

local Context = require("core/context")
local MapTag = require("core/map_tag")
local Constants = require("constants")
local FaveBarGUI = require("gui/fave_bar_GUI")
local TagEditorGUI = require("gui/tag_editor_GUI")
local Storage = require("core.storage")
local Helpers = require("core.utils.helpers")

local Control = {}

local RESPONSIVE_TICKS = 30 * 1

-- Utility: Show player position in top left corner in map view (dev-only, ultra-lean)
local CURSOR_LABEL_NAME = "ft_cursor_position_label"
local function update_cursor_position_label(player)
  if not player or not player.valid then return end
  local pos = player.position or { x = 0, y = 0 }
  local label = player.gui.screen[CURSOR_LABEL_NAME]
  local text = string.format("%.1f, %.1f", pos.x or 0, pos.y or 0)
  if not label then
    label = player.gui.screen.add {
      type = "label",
      name = CURSOR_LABEL_NAME,
      caption = text
    }
  else
    label.caption = text
  end
end

-- Main mod event registration and lifecycle management

script.on_init(function()
  Context.init()
  for _, player in pairs(game.players) do
    FaveBarGUI.build(player)
  end
end)

script.on_load(function()
  -- TODO: Restore runtime references if needed
  --Context.init()
end)

script.on_configuration_changed(function(event)
  --[[if event.mod_changes and event.mod_changes["FavoriteTeleport"] then
    local changes = event.mod_changes["FavoriteTeleport"]

    -- this condition indicates the mod was removed
    if changes.old_version and not changes.new_version then
      -- cleanup gui for all players
      for _, player in pairs(game.players) do
        add_tag_gui.on_player_removed(player)
        edit_fave_gui.on_player_removed(player)
        -- GuiBase.update_the_fav_bar(player) -- or .on_player_removed if needed (function not present in GuiBase)
      end
      -- Mod is being removed, clean up data
      context.map_tags = nil
    else
      for _, player in pairs(game.players) do
        control.initialize(player)
      end
    end
  end
  if migration.needs_migration(context) then
    migration.migrate(context)
  end
  ]]
  -- TODO: Handle migrations and config changes
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if not event then return end
  -- .player_index is optional in the API but we need the player index in our logic
  if not event.player_index then return end

  local player = game.get_player(event.player_index)
  if not player then return end

  local setting_name = event.setting
  local setting_type = event.setting_type

  if setting_type == "runtime-per-user" and setting_name == Constants.settings.FAVORITES_ON then
    --control.apply_favorites_on_off_state(player)
    --control.update_guis(player)
  end
end)

script.on_event(defines.events.on_chart_tag_modified, function(event)
  MapTag.on_chart_tag_modified(event)
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  if player then
    FaveBarGUI.build(player)
  end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  --STUB
end)

script.on_event(defines.events.on_player_left_game, function(event)
  -- cleanup player's data?
end)

script.on_event(defines.events.on_player_removed, function(event)
  -- cleanup player's data?
end)

script.on_event(defines.events.script_raised_teleported, function(event)
  -- STUB
end)

script.on_event(defines.events.on_player_changed_force, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  -- implemented to handle EditorExtensions incompat? 1/20/2025
  -- TODO when implemented pcall(context.reset_surface_chart_tags, player)
end)

--[[TODO decide if this is necessary to handle stock editor and/or should
      handle mod's additions for consistency
script.on_event(defines.events.on_chart_tag_added, function(event)
  .handle_chart_tag_added(event)
end)]]

script.on_event(defines.events.on_chart_tag_modified, function(event)
  -- TODO implement
end)

script.on_event(defines.events.on_chart_tag_removed, function(event)
  --.handle_chart_tag_removal(event)
end)

-- set events for hotkeys
for i = 1, 10 do
  script.on_event(Constants.events.TELEPORT_TO_FAVORITE .. i, function(event)
    local player_index = Helpers.find_player_index_in_event(event)
    if not player_index then return end
    local player = game.get_player(player_index)
    if not player then return end
    -- Hotkey teleport logic to be implemented
  end)
end

-- Register a custom input for right-click in chart view to open the tag editor
script.on_event(Constants.events.ON_OPEN_TAG_EDITOR, function(event)
  local player_index = Helpers.find_player_index_in_event(event)
  if not player_index then return end
  local player = game.get_player(player_index)
  if not player then return end

  -- Ignore right-clicks in render_mode.game or render_mode.chart_zoomed_in
  if player.render_mode == defines.render_mode.game or player.render_mode == defines.render_mode.chart_zoomed_in then
    return
  end
  -- Use event.cursor_position if available, otherwise fallback to player.position
  ---@diagnostic disable-next-line: undefined-field
  local pos = (event.cursor_position and type(event.cursor_position) == "table") and event.cursor_position or
      (player.position or { x = 0, y = 0 })
  local gps = Helpers.map_position_to_gps(player.surface.index, pos)

  local chart_tags = Storage.get_chart_tags(player)
  local chart_tag = nil

  -- if there is a matching chart_tag with matching gps
  for _, tag in pairs(chart_tags) do
    if gps == Helpers.map_position_to_gps(player.surface.index, tag.position) then
      chart_tag = tag
      break
    end
  end

  local map_tags = Storage.get_map_tags(player)
  local map_tag = nil
  for _, tag in pairs(map_tags) do
    if gps == tag.gps then
      map_tag = tag
      break
    end
  end

  -- this logic will build a matching map_tag upon tag_editor save
  if chart_tag ~= nil and (map_tag ~= nil or map_tag ~= {}) then
    -- build tag_editor with chart_tag and map_tag
    TagEditorGUI.open(player, chart_tag.position, false, context)
  elseif chart_tag ~= nil and not map_tag then
    -- build tag_editor with chart_tag only
    TagEditorGUI.open(player, chart_tag.position, false, context)
  elseif not chart_tag and not map_tag then
    -- build tag with the current event position
    TagEditorGUI.open(player, pos, false, context)
  elseif not chart_tag and map_tag ~= nil and map_tag ~= {} then
    -- create a matching chart_tag with text == gps
    MapTag.create_chart_tag_from_map_tag(player, map_tag)
    -- open the tag editor with data from map_tag and matching chart_tag
  end








  local surface_index = player.surface.index
  local storage = Storage.get()
  local surfaces = storage.surfaces or {}
  local map_tags = (surfaces[surface_index] and surfaces[surface_index].map_tags) or {}
  -- Find the chart tag under the cursor using a larger bounding box (using pos)
  local found_chart_tag = nil
  local half_size = 1.2
  for _, tag in pairs(chart_tags) do
    if pos.x >= tag.position.x - half_size and pos.x <= tag.position.x + half_size
        and pos.y >= tag.position.y - half_size and pos.y <= tag.position.y + half_size then
      found_chart_tag = tag
      break
    end
  end
  local found_tag
  local context
  if found_chart_tag then
    gps = Helpers.map_position_to_gps(found_chart_tag.position)
    for _, tag in pairs(map_tags) do
      if tag.gps == gps then
        found_tag = tag
        break
      end
    end
    context = found_tag and { tag_data = found_tag, is_edit = true } or
        { tag_data = { gps = gps }, is_edit = false }
    TagEditorGUI.open(player, found_chart_tag.position, false, context)
  else
    -- No chart tag found: open tag editor for creation at this position
    context = { tag_data = { gps = gps }, is_edit = false }
    TagEditorGUI.open(player, pos, false, context)
  end
end)

script.on_event(Constants.events.STORAGE_DUMP, function(event)
  local player_index = Helpers.find_player_index_in_event(event)
  if not player_index then return end
  local player = game.get_player(player_index)
  if not player then return end
  local storage = remote.call("FavoriteTeleport", "get_storage")
  if type(storage) ~= "table" then
    player.print("[FavoriteTeleport] Storage is not a table! Type: " .. type(storage))
    return
  end
  if serpent then
    player.print(serpent.block(storage, { comment = false }))
  else
    for k, v in pairs(storage) do
      player.print(tostring(k) .. ": " .. tostring(v))
    end
  end
end)

local _startup = nil

script.on_event(defines.events.on_tick, function(event)
  if not _startup then
    for _, player in pairs(game.players) do
      if not player then return end
      Control.update_guis(player)
    end
    startup = 1
  end
  script.on_event(defines.events.on_tick, nil)
end)

--[[script.on_nth_tick(RESPONSIVE_TICKS, function(event)
  if not game then return end

  for _, player in pairs(game.players) do
    if player.character then
      Control.close_guis(player)
    end
  end
end)]]

script.on_event(defines.events.on_gui_click, function(event)
  if not event or not event.element or not event.element.valid then return end
  -- Tag Editor GUI click handling
  local tag_action = TagEditorGUI.on_click(event)
  if tag_action == "close" then
    if not event.player_index then return end
    local player = game.get_player(event.player_index)
    if player then
      TagEditorGUI.close(player)
    end
    return
  end

  -- Handle FaveBarGUI button clicks (if needed)
  -- Add more GUI event handling here as you expand the GUIs
end)

-- Tag Editor GUI: Enable/disable save button based on text or icon
script.on_event(defines.events.on_gui_text_changed, function(event)
  if not event or not event.element or not event.element.valid then return end
  if event.element.name ~= "ft_tag_editor_textbox" then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  local frame = player.gui.screen.ft_tag_editor_outer_frame
  if not frame then return end
  local save_btn = frame.ft_tag_editor_frame
      and frame.ft_tag_editor_frame.ft_tag_editor_action_row
      and frame.ft_tag_editor_frame.ft_tag_editor_action_row.ft_tag_editor_save_btn
  if save_btn then
    -- Enable as soon as any text is present (including whitespace)
    save_btn.enabled = (#event.element.text > 0)
  end
end)

script.on_event(defines.events.on_gui_elem_changed, function(event)
  if not event or not event.element or not event.element.valid then return end
  if event.element.name ~= "tag-editor-icon" then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  local frame = player.gui.screen.ft_tag_editor_outer_frame
  if not frame then return end
  local save_btn = frame.ft_tag_editor_frame.ft_tag_editor_action_row.ft_tag_editor_save_btn
  local text_box = frame.ft_tag_editor_frame.ft_tag_editor_text_row.ft_tag_editor_textbox
  local text_val = text_box and text_box.text and text_box.text:match("%S")
  local icon_val = event.element.elem_value
  save_btn.enabled = (text_val ~= nil) or (icon_val ~= nil)
end)

-- Close tag editor GUI if ESC is pressed
script.on_event(defines.events.on_gui_closed, function(event)
  if not event or not event.element or not event.player_index then return end
  if event.element.name == "ft_tag_editor_outer_frame" and event.gui_type == defines.gui_type.custom then
    local player = game.get_player(event.player_index)
    if player then
      local gui = player.gui.screen
      if gui.ft_tag_editor_outer_frame then
        gui.ft_tag_editor_outer_frame.destroy()
      end
    end
  end
end)

local function destroy_tag_editor_frame(player)
  if player then
    for _, element in pairs(player.gui.screen.children) do
      if element.name == "ft_tag_editor_outer_frame" then
        element.destroy()
        break
      end
    end
  end
end

script.on_event(defines.events.on_player_changed_surface, function(event)
  local player = game.get_player(event.player_index)
  destroy_tag_editor_frame(player)
end)

script.on_event(defines.events.on_player_changed_position, function(event)
  local player = game.get_player(event.player_index)
  destroy_tag_editor_frame(player)
end)

script.on_event(defines.events.on_player_toggled_map_editor, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  destroy_tag_editor_frame(player)
end)

-- This occurs when a player switches between different controller modes,
--- such as moving from character control to god mode, spectator mode,
--- or any other available controller type in the game
--- ie: fave bar should only show in game mode
script.on_event(defines.events.on_player_controller_changed, function(event)
  if game then
    local player = game.get_player(event.player_index)
    if not player then return end

    -- if we are not in regular/game view and a fave bar exists
    if player.render_mode == defines.render_mode.game then
      destroy_tag_editor_frame(player)
    end
  end
end)

local function check_and_handle_render_mode_change(player)
  if not player then return end
  local pdata = Context.get_player_data(player.index)
  if not pdata then return end
  local last_mode = pdata.render_mode
  local current_mode = player.render_mode
  if last_mode ~= current_mode then
    pdata.render_mode = current_mode
    -- Handle leaving map view: close tag editor if switching to game mode
    if current_mode == defines.render_mode.game then
      local frame = player.gui.screen.ft_tag_editor_outer_frame
      if frame then frame.destroy() end
    end
    -- You can add more logic here for entering/leaving other modes
  end
end

script.on_nth_tick(RESPONSIVE_TICKS, function(event)
  for _, player in pairs(game.connected_players) do
    check_and_handle_render_mode_change(player)
  end
end)

script.on_nth_tick(5, function(event)
  for _, player in pairs(game.connected_players) do
    update_cursor_position_label(player)
  end
end)

-- DEV: Dump chart tags for current surface with CTRL+F9
script.on_event("ft-dev-dump-chart-tags", function(event)
  local player_index = Helpers.find_player_index_in_event(event)
  if not player_index then return end
  local player = game.get_player(player_index)
  if not player then return end
  local surface = player.surface
  local chart_tags = player.force.find_chart_tags(surface)
  if not chart_tags or #chart_tags == 0 then
    player.print("[DEV] No chart tags found on this surface.")
    return
  end
  for i, tag in ipairs(chart_tags) do
    local msg = {
      string.format("[DEV] Tag #%d:", i),
      "  position: " .. serpent.line(tag.position, { comment = false }),
      "  text: " .. tostring(tag.text),
      "  icon: " .. (tag.icon and tag.icon.type or "nil"),
      "  last_user: " .. tostring(tag.last_user),
      "  tag_number: " .. tostring(tag.tag_number),
      "  surface: " .. tostring(tag.surface and tag.surface.name or "nil"),
      "  force: " .. tostring(tag.force and tag.force.name or "nil"),
      "  valid: " .. tostring(tag.valid)
    }
    player.print(table.concat(msg, "\n"))
  end
end)

-- TODO: Register additional event handlers for player actions, GUI, etc.

function Control.close_guis(player)
  -- TODO handle any other frames
  destroy_tag_editor_frame(player)
end

function Control.update_guis(player)
  -- TODO implementation
end

remote.add_interface("FavoriteTeleport", {
  get_storage = function()
    return Storage.get()
  end
})

return Control
