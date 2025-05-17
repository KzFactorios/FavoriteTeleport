--- gui_base.lua
--- Provides common methods and utilities for all GUIs in FavoriteTeleport

local GuiBase = {}

--- Safely destroys a GUI element by name if it exists in the given parent
-- @param parent LuaGuiElement The parent GUI element (e.g., player.gui.screen)
-- @param name string The name of the child element to destroy
function GuiBase.destroy_if_exists(parent, name)
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
function GuiBase.set_opened(player, element)
    if not player or not element then return end
    player.opened = element
end

--- Utility to add a flow with horizontal direction
-- @param parent LuaGuiElement
-- @param name string
-- @return LuaGuiElement
function GuiBase.add_horizontal_flow(parent, name)
    return parent.add {
        type = "flow",
        name = name,
        direction = "horizontal"
    }
end

--- Safely finds a child element by name in a parent (searches .children if direct lookup fails)
function GuiBase.find_child_by_name(parent, name)
    if not parent or not name then return nil end
    if parent[name] then return parent[name] end
    for _, child in pairs(parent.children or {}) do
        if child.name == name then return child end
    end
    return nil
end

return GuiBase
