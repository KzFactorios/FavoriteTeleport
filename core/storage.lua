local Storage = require("core.storage")
local Constants = require("constants")
local Helpers = require("core.utils.helpers")

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
    surface_data.chart_tags = player.force.find_chart_tags(player.surface)
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
  if not chart_tags then return nil end
  local target_pos = Helpers.gps_to_map_position(gps)
  if not target_pos then return nil end
  for _, chart_tag in ipairs(chart_tags) do
    if chart_tag.position then
      local dx = math.abs(chart_tag.position.x - target_pos.x)
      local dy = math.abs(chart_tag.position.y - target_pos.y)
      if dx <= Constants.settings.BOUNDING_BOX_TOLERANCE and dy <= Constants.settings.BOUNDING_BOX_TOLERANCE then
        return chart_tag
      end
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

  -- Remove any runtime object references before storing
  if map_tag.tag then map_tag.tag = nil end
  -- Only store serializable fields (gps, faved_by_players, created_by, text, description, etc)
  for k, v in pairs(map_tag) do
    if type(v) == "table" and v.__self then
      map_tag[k] = nil
    end
  end

  table.insert(map_tags, map_tag)
end

--[[[player_index] = {
      surfaces = {
        [surface_index] = {
          favorites = { ]]
function Storage.get_ALL_player_favorites(player)
  if not player or not player.valid then return {} end
  local pdata = Storage.get_player_data(player)
  local favorites = {}
  for _, surface_data in pairs(pdata.surfaces) do
    if surface_data.favorites then
      for _, v in ipairs(surface_data.favorites) do
        table.insert(favorites, v)
      end
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
  if not faves then
    faves = {}
    pdata.favorites[surface_index] = faves
  end
  if #faves < Constants.MAX_FAVORITE_SLOTS then
    faves = Storage.ensure_favorite_slots_initialized(faves, surface_index)
    pdata.favorites[surface_index] = faves
  end

  return faves
end

--- Ensures all slots are initialized for a favorites array (helper)
---@param slots table[]
---@param surface_index uint
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

--- Finds a single favorite by gps for a player and surface
function Storage.find_favorite_by_gps(player, gps)
  local favorites = Storage.get_player_favorites(player)
  return Helpers.find_favorite_by_gps(favorites, gps)
end

--- Returns true if the favorite slot is empty for a player and surface
function Storage.favorite_slot_is_empty(player, slot)
  local favorites = Storage.get_player_favorites(player)
  if not favorites[slot] then
    return true
  end
---@diagnostic disable-next-line: need-check-nil
  return not favorites[slot].map_tag or favorites[slot].map_tag == {}
end

--- Returns the number of used slots in a player's favorites for a surface
function Storage.count_used_favorite_slots(player)
  local favorites = Storage.get_player_favorites(player)
  return Helpers.count_used_favorite_slots(favorites)
end

--- Returns the number of available favorite slots for a player
function Storage.get_available_favorite_slots_count(player)
  local favorites = Storage.get_player_favorites(player)
  local max_slots = Constants.MAX_FAVORITE_SLOTS
  local count = 0
  for i = 1, max_slots do
---@diagnostic disable-next-line: need-check-nil
    if not favorites[i] or not favorites[i].map_tag and favorites[i].map_tag ~= {} then
      count = count + 1
    end
  end
  return count
end

--- Returns the next available favorite slot index for a player, or nil if none
function Storage.get_next_available_favorite_slot(player)
  local favorites = Storage.get_player_favorites(player)
  local max_slots = Constants.MAX_FAVORITE_SLOTS
  for i = 1, max_slots do
    if not favorites[i] then return i end
  end
  return nil
end

--- Returns true if the player has at least one available favorite slot
function Storage.has_available_favorite_slots(player)
  local favorites = Storage.get_player_favorites(player)
  local max_slots = Constants.MAX_FAVORITE_SLOTS
  for i = 1, max_slots do
    if not favorites[i] then return true end
  end
  return false
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

--- Populates chart_tags for all surfaces and all forces in the game.
-- @param game LuaGameScript
function Storage.populate_all_chart_tags(game)
  if not game or not game.surfaces or not game.forces then
    return
  end
  for _, surface in pairs(game.surfaces) do
    local surface_index = surface.index
    local surface_data = get_surfaces_data(surface_index)
    local chart_tags = {}
    for _, force in pairs(game.forces) do
      local force_index = force.index
      local tags = force.find_chart_tags(surface) or {}
      if type(tags) ~= "table" then tags = {} end
      chart_tags[force_index] = tags
    end
    surface_data.chart_tags = chart_tags
  end
end

return Storage
