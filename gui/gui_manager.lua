--- gui_manager.lua
--- Provides common methods and utilities for all GUIs in FavoriteTeleport

local GuiManager = {}

--- Safely destroys a GUI element by name if it exists in the given parent
-- @param parent LuaGuiElement The parent GUI element (e.g., player.gui.screen)
-- @param name string The name of the child element to destroy
function GuiManager.destroy_if_exists(parent, name)
    if not parent or not name then return end
    for _, child in pairs(parent.children) do
        if child.name == name then
            child.destroy()
            return true
        end
    end
    return false
end

--- Sets a GUI element as the currently opened dialog for the player
-- @param player LuaPlayer
-- @param element LuaGuiElement
function GuiManager.set_opened(player, element)
    if not player or not element then return end
    player.opened = element
end

--- Utility to add a flow with horizontal direction
-- @param parent LuaGuiElement
-- @param name string
-- @return LuaGuiElement
function GuiManager.add_horizontal_flow(parent, name)
    return parent.add {
        type = "flow",
        name = name,
        direction = "horizontal"
    }
end

return GuiManager
