-- core/control/events.lua
-- Handles event registration for FavoriteTeleport

-- luacheck: globals script defines
---@diagnostic disable: undefined-global

local TagEditorGUI = require("gui.tag_editor_GUI")
local FaveBarGUI = require("gui.fave_bar_GUI")
local Observer = require("core.observer")
local Constants = require("constants")

local Events = {}

function Events.register()
  -- Register GUI click events
  script.on_event(defines.events.on_gui_click, function(event)
    -- Route to both GUIs as needed
    FaveBarGUI.on_click(event)
    TagEditorGUI.on_click(event)
  end)

  -- Register drag events for the favorites bar
  script.on_event(defines.events.on_gui_elem_changed, FaveBarGUI.on_drag)

  -- Register custom input for opening tag editor (right-click or hotkey)
  script.on_event(Constants.events.ON_OPEN_TAG_EDITOR, function(event)
    TagEditorGUI.on_open_tag_editor(event)
  end)

  -- Register teleport hotkeys (loop for all slots)
  for i = 1, Constants.MAX_FAVORITE_SLOTS do
    local event_name = Constants.events.TELEPORT_TO_FAVORITE .. tostring(i)
    script.on_event(event_name, function(event)
      FaveBarGUI.on_teleport_to_favorite(event, i)
    end)
  end

  -- Register storage dump/dev events if needed
  script.on_event(Constants.events.STORAGE_DUMP, function(event)
    -- Implement storage dump logic if desired
  end)
end

return Events
