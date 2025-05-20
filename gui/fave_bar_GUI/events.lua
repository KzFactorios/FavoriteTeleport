-- events.lua
-- Handles all event registration and callbacks for the favorites bar GUI

local Events = {}

local map_tag = require("core.map_tag")
local Storage = require("core.storage.init")
local DragAndDrop = require("gui.drag_and_drop")
local Slots = require("gui.fave_bar_GUI.slots")
local Helpers = require("core.utils.helpers")

local storage = _G.storage and _G.storage.FavoriteTeleport or {}

--- Handles click events on the favorites bar
-- @param event EventData.on_gui_click
function Events.on_click(event)
    if not event or not event.element or not event.element.valid then return end
    local name = event.element.name
    if not name or type(name) ~= "string" then return end
    local player = _G.game.get_player(event.player_index)
    if not player then return end

    -- Only handle favorite bar slot buttons
    local slot = name:match("^ft_fave_slot_(%d+)$")
    if slot then
        slot = tonumber(slot)
        Storage.ensure_favorite_slots_initialized(player)
        local favorites = Storage.get_player_favorites(player)
        local fav = favorites[slot]
        if event.button == _G.defines.mouse_button_type.left then
            if not fav.gps or fav.gps == "" then
                player.print("[FavoriteTeleport] This favorite slot is empty.")
                return
            end
            if fav.slot_locked then
                player.print("[FavoriteTeleport] This favorite slot is locked.")
                return
            end
            local result = nil
            local pos = fav.gps
            local surface = player.surface
            local success, err = pcall(function()
                result = map_tag.teleport_player_with_messaging(player, pos, surface, true)
            end)
            if not success then
                player.print("[FavoriteTeleport] Teleport failed: " .. (err or "Unknown error"))
            elseif result ~= nil then
                player.print("[Favorite Teleport] " .. result)
            end
        elseif event.button == _G.defines.mouse_button_type.right then
            -- Only proceed if slot is not blank
            if not fav.gps or fav.gps == "" then
                player.print("[FavoriteTeleport] This favorite slot is empty.")
                return
            end
            if fav.slot_locked then
                player.print("[FavoriteTeleport] This favorite slot is locked.")
                return
            end
            -- Only open tag editor if in chart view
            local pdata = storage.players and storage.players[player.index] or {}
            local render_mode = pdata.render_mode or player.render_mode
            if render_mode == _G.defines.render_mode.chart or render_mode == _G.defines.render_mode.chart_zoomed_in then
                require("gui.tag_editor_GUI").open(player, Helpers.gps_to_map_position(fav.gps), { opened_via_fave_bar = true, slot_index = slot })
            end
            return
        end
        return
    end
    -- Drag-and-drop and other bar logic handled elsewhere
end

--- Handles drag-and-drop events for the favorites bar
-- @param event EventData.on_gui_elem_changed or custom drag event
function Events.on_drag(event)
    if not event or not event.element or not event.element.valid then return end
    local name = event.element.name
    if not name or type(name) ~= "string" then return end
    local player = _G.game.get_player(event.player_index)
    if not player then return end
    local from_slot = name:match("^ft_fave_slot_(%d+)$")
    local to_slot = event.target and event.target.name and event.target.name:match("^ft_fave_slot_(%d+)$")
    from_slot = from_slot and tonumber(from_slot) or nil
    to_slot = to_slot and tonumber(to_slot) or nil
    if from_slot and to_slot and type(from_slot) == "number" and type(to_slot) == "number" then
        if from_slot == to_slot then return end
        local favorites = Storage.get_player_favorites(player)
        Storage.ensure_favorite_slots_initialized(favorites, player.surface.index)
        local ok = DragAndDrop.move_slot(favorites, from_slot, to_slot)
        if ok then
            -- Persist and update UI
            if Storage.save_data then Storage.save_data(Storage.get()) end
            Slots.update_slots(player)
        else
            player.print("[FavoriteTeleport] Cannot move locked slot.")
        end
    end
end

--- Handles the on_player_teleported event (on_raise_teleported)
-- @param event EventData.on_player_teleported
function Events.on_raise_teleported(event)
    if not event or not event.player_index then return end
    local player = _G.game.get_player(event.player_index)
    if not player then return end

    local pos = player.position or { x = 0, y = 0 }
    if type(player.print) == "function" then
        player.print(player.name .. { "teleported_to" } .. " x: " .. pos.x .. ", y: " .. pos.y .. "")
    end
    --Slots.update_slots(player)
end

--- Handles the on_player_created event
-- @param event EventData.on_player_created
function Events.on_player_created(event)
    local player = _G.game.get_player(event.player_index)
    if not player then return end
    -- Ensure favorite slots are initialized for this player
    Storage.ensure_favorite_slots_initialized(player)
    -- Update the favorites bar GUI for this player
    Slots.update_slots(player)
end

return Events
