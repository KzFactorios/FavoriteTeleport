local Helpers = require("core.utils.helpers")
local Constants = require("constants")

-- Storage.lua
-- Centralized persistent storage handler for mod
-- Handles saving, loading, and schema management for mod data
local Storage = {}

--- Initializes the storage structure if not present
function Storage.init()
  if not Storage._data then
    Storage._data = {
      mod_version = nil,
      players = {},
      surfaces = {},
    }
  end
end

--- Returns the root storage table
function Storage.get()
  if not Storage._data then Storage.init() end
  return Storage._data
end

--[[players = {
    [player_index] = {
      show_fave_bar_buttons = boolean,
      render_mode = string,
      -- ...other per-player data
      surfaces = {
        [surface_index] = {
          favorites = {]]

--- lazy loading getter. Initrializes the storage.players structure
--- Returns the player-specific storage table
-- @param player_index integer
function Storage.get_player_data(player)
  if not player then return {} end
  local player_index = player.index
  local surface_index = player.surface.index

  local storage = Storage.get()

  if not storage.players[player_index] then storage.players[player_index] = {} end
  local pdata = storage.players[player_index]

  if not pdata["show_fave_bar_buttons"] then pdata["show_fave_bar_buttons"] = true end

---@diagnostic disable-next-line: undefined-global
  if not pdata["render_mode"] then pdata["render_mode"] = defines.render_mode.game end

  if not pdata.surfaces then pdata.surfaces = {} end
  if not pdata.surfaces[surface_index] then pdata.surfaces[surface_index] = {} end
  if not pdata.surfaces[surface_index]["favorites"] then
    pdata.surfaces[surface_index].favorites = {}
  end

  local pFaves = pdata.surfaces[surface_index].favorites
  if #pFaves < Constants.MAX_FAVORITE_SLOTS then
    for i = 1, Constants.MAX_FAVORITE_SLOTS do
      if not pFaves[i] then
        pFaves[i] = {
          gps = nil,
          slot_locked = false
        }
      end
    end
  end

  return storage.players[player_index]
end

--- lazy loading getter. Initrializes the storage.surfaces structure
local function get_surfaces_data(surface_index)
  if not surface_index then return nil end
  local storage = Storage.get()
  if not storage.surfaces then storage.surfaces = {} end
  if not storage.surfaces[surface_index] then
    storage.surfaces[surface_index] = {}
  end
  if not storage.surfaces[surface_index].chart_tags then
    storage.surfaces[surface_index].chart_tags = {}
  end
  if not storage.surfaces[surface_index].map_tags then
    storage.surfaces[surface_index].map_tags = {}
  end

  return storage.surfaces[surface_index]
end

--- Returns the chart_tags for the player's current surface, populating from the game if missing or empty.
-- @param player LuaPlayer
function Storage.get_chart_tags(player)
  if not player or not player.valid then return nil end

  local surface_data = get_surfaces_data(player.surface.index) -- storage.surfaces[surface_index]
  if not surface_data then return {} end                       -- the initalizer guarantees this

  if not surface_data.chart_tags or surface_data.chart_tags == {} or #surface_data.chart_tags == 0 then
    if player.force and player.force.valid then
      surface_data.chart_tags = player.force.find_chart_tags(player.surface)
    end
  end

  return surface_data.chart_tags or {}
end

function Storage.reset_chart_tags(player)
  if not player or not player.valid then return nil end
  local surface_data = get_surfaces_data(player.surface.index) -- storage.surfaces[surface_index]
  if not surface_data then return {} end                       -- the initalizer guarantees this
  surface_data.chart_tags = nil
end

--- Returns the map_tags for the player's current surface
function Storage.get_map_tags(player)
  if not player or not player.valid then return {} end

  local surface_data = get_surfaces_data(player.surface.index) -- storage.surfaces[surface_index]
  if not surface_data then return {} end

  return surface_data.map_tags or {}
end

--- Finds a map_tag by gps in the given surface's map_tags
function Storage.find_map_tag_by_gps(player, gps)
  local map_tags = Storage.get_map_tags(player)
  for _, map_tag in ipairs(map_tags) do
    if map_tag.gps == gps then return map_tag end
  end
  return nil
end

function Storage.find_chart_tag_by_gps(player, gps)
  local chart_tags = Storage.get_chart_tags(player)
  if chart_tags then
    for _, chart_tag in ipairs(chart_tags) do
      if Helpers.format_gps(chart_tag.position.x, chart_tag.position.y, player.surface.index) 
        == gps then return chart_tag end
    end
  end
  return nil
end

--- Adds or updates a map_tag in the given surface's map_tags (by gps)
function Storage.add_or_update_map_tag(player, map_tag)
  local map_tags = Storage.get_map_tags(player)
  for i, mt in ipairs(map_tags) do
    if mt.gps == map_tag.gps then
      map_tags[i] = map_tag
      return
    end
  end
  --if not found then--
  table.insert(map_tags, map_tag)
end

--[[[player_index] = {
      surfaces = {
        [surface_index] = {
          favorites = { ]]
function Storage.get_ALL_player_favorites(player)
  if not player or not player.valid then return {} end
  local faves = {}
  local pdata = Storage.get_player_data(player)
  local favorites = {}
  for i = 1, #pdata.surfaces do
    for _, v in ipairs(pdata.surfaces[i]) do
      table.insert(favorites, v)
    end
  end
  return favorites
end

--- Returns the favorites array for a player on their current surface, initializing any missing slots.
--- Only favorites for the player's current surface are returned. For all surfaces, use a different accessor.
---@param player LuaPlayer
---@return table[]
function Storage.get_player_favorites(player)
  if not player or not player.valid then return {} end
  local pdata = Storage.get_player_data(player)
  local surface_index = player.surface.index

  pdata.favorites = pdata.favorites or {}
  if not pdata.favorites[surface_index] then
    pdata.favorites[surface_index] = {}
  end
  local faves = pdata.favorites[surface_index]
  if not faves or #faves < Constants.MAX_FAVORITE_SLOTS then
    faves = Storage.ensure_favorite_slots_initialized(faves, surface_index)
  end

  return faves
end

--- Ensures all slots are initialized for a favorites array (helper)
---@param slots table[]
---@param surface_index integer
function Storage.ensure_favorite_slots_initialized(slots, surface_index)
  if #slots < Constants.MAX_FAVORITE_SLOTS then
    for slot = 1, Constants.MAX_FAVORITE_SLOTS do
      if not slots[slot] then
        slots[slot] = {
          surface_index = surface_index,
          gps = "",
          map_tag = nil,
          slot_locked = false
        }
      end
    end
  end
  return slots
end

--- Finds a favorite by gps for a player and surface
function Storage.find_favorite_by_gps(player, gps)
  local favorites = Storage.get_player_favorites(player)
  return Helpers.find_favorite_by_gps(favorites, gps)
end

--- Returns true if the favorite slot is empty for a player and surface
function Storage.favorite_slot_is_empty(player, slot)
  local favorites = Storage.get_player_favorites(player)
  return Helpers.favorite_slot_is_empty(favorites[slot])
end

--- Returns the number of used slots in a player's favorites for a surface
function Storage.count_used_favorite_slots(player)
  local favorites = Storage.get_player_favorites(player)
  return Helpers.count_used_favorite_slots(favorites)
end

--- Called when a player leaves the game; cleans up their tag ownership and favorites
-- @param player_index integer
-- @param player_name string
function Storage.on_player_left_game(player_index, player_name)
  local storage = Storage.get()
  -- Remove player_index from all faved_by_players and set last_user to nil if owned
  for surface_index, surface_data in pairs(storage.surfaces) do
    -- Clean up chart_tags
    if surface_data.chart_tags then
      for _, tag in pairs(surface_data.chart_tags) do
        if tag.last_user == player_name then
          tag.last_user = nil
        end
        if tag.faved_by_players then
          for i = #tag.faved_by_players, 1, -1 do
            if tag.faved_by_players[i] == player_index then
              table.remove(tag.faved_by_players, i)
            end
          end
        end
      end
    end
    -- Clean up ext_tags if present
    if surface_data.ext_tags then
      for _, tag in pairs(surface_data.ext_tags) do
        if tag.last_user == player_name then
          tag.last_user = nil
        end
        if tag.faved_by_players then
          for i = #tag.faved_by_players, 1, -1 do
            if tag.faved_by_players[i] == player_index then
              table.remove(tag.faved_by_players, i)
            end
          end
        end
      end
    end
  end
end

--- Invalidates the chart tag cache for a given surface index by setting chart_tags to nil.
-- @param surface_index integer
function Storage.reset_cached_chart_tags(surface_index)
  local storage = Storage.get()
  if storage.surfaces and storage.surfaces[surface_index] then
    storage.surfaces[surface_index].chart_tags = nil
  end
end

return Storage
