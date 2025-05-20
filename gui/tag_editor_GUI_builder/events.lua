-- tag_editor_GUI_builder/events.lua
-- Event handler registration for tag editor GUI

local Events = {}

function Events.register_tag_editor_events(player, gui_elements, callbacks)
  -- Example: register events for text fields, icon pickers, etc.
  -- gui_elements: table of elements to register
  -- callbacks: table of callback functions (e.g., on_text_changed, on_icon_changed)
  for name, element in pairs(gui_elements) do
    if element and element.valid then
      if element.type == "textfield" and callbacks.on_text_changed then
        element.on_text_changed = callbacks.on_text_changed
      elseif element.type == "choose-elem-button" and callbacks.on_icon_changed then
        element.on_elem_changed = callbacks.on_icon_changed
      end
    end
  end
end

-- Add more event registration helpers as needed

return Events
