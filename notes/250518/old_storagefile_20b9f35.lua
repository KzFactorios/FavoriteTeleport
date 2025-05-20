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

function Storage.get_data()
  return Storage.get()
end

--[[players = {
    [player_index] = {
      toggle_fave_bar_buttons = boolean,
      render_mode = string,
      -- ...other per-player data
      surfaces = {
        [surface_index] = {
          favorites = {]]

--- lazy loading getter. Initializes the storage.players structure
--- Returns the player-specific storage table
-- @param player LuaPlayer
function Storage.get_player_data(player)
  -- Always return a table with the expected structure, even for nil/invalid players
  if not player or not player.surface or not player.index then
    -- Return a dummy table (not a reference to real storage)
    return {
      toggle_fave_bar_buttons = true,
      render_mode = (_G.defines and _G.defines.render_mode and _G.defines.render_mode.game) or "game",
      surfaces = {},
    }
  end
  local player_index = player.index
  local surface_index = player.surface.index

  local storage = Storage.get()

  if not storage.players[player_index] then storage.players[player_index] = {} end
  local pdata = storage.players[player_index]

  -- Ensure all required fields are present and robustly initialized
  if pdata.toggle_fave_bar_buttons == nil then pdata.toggle_fave_bar_buttons = true end

  if pdata.render_mode == nil then
    if _G.defines and _G.defines.render_mode and _G.defines.render_mode.game then
      pdata.render_mode = _G.defines.render_mode.game
    else
      pdata.render_mode = "game"
    end
  end

  if not pdata.surfaces or type(pdata.surfaces) ~= "table" then pdata.surfaces = {} end
  if not pdata.surfaces[surface_index] or type(pdata.surfaces[surface_index]) ~= "table" then pdata.surfaces[surface_index] = {} end
  if not pdata.surfaces[surface_index].favorites or type(pdata.surfaces[surface_index].favorites) ~= "table" then
    pdata.surfaces[surface_index].favorites = {}
  end

  local pFaves = pdata.surfaces[surface_index].favorites
  if #pFaves < Constants.MAX_FAVORITE_SLOTS then
    for i = 1, Constants.MAX_FAVORITE_SLOTS do
      if not pFaves[i] or type(pFaves[i]) ~= "table" then
        pFaves[i] = {
          gps = nil,
          slot_locked = false
        }
      end
    end
  end

  return pdata
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
    -- Accept chart_tag.valid == nil for test/mocks, or true for real chart tags
    if (chart_tag.valid == nil or chart_tag.valid) and chart_tag.position then
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

--- Returns true if the player is in chart view (for test, always true if not present)
function Storage.player_in_chart_view(player)
  if not player then return false end
  if player.render_mode then
    return player.render_mode == ((_G.defines and _G.defines.render_mode and _G.defines.render_mode.chart) or "chart")
  end
  -- For test/mocks, assume true
  return true
end

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
  if type(player) ~= "table" or not player.valid or not player.surface or not player.surface.index then return {} end
  local pdata = Storage.get_player_data(player)
  local surface_index = player.surface.index
  pdata.favorites = pdata.favorites or {}
  if not pdata.favorites[surface_index] then
    pdata.favorites[surface_index] = {}
  end
  return pdata.favorites[surface_index]
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

-- Destroys a chart_tag from the game/force and removes it from storage if successful
-- @param player LuaPlayer
-- @param gps string (gps string for the tag)
-- @return boolean true if destroyed, false otherwise
function Storage.destroy_chart_tag(player, gps)
  if not player or not gps then return false end
  local surface = player.surface
  local surface_index = surface.index
  local storage = Storage.get()
  local surface_data = storage.surfaces and storage.surfaces[surface_index]
  if not surface_data or not surface_data.chart_tags then return false end

  -- Find the chart_tag in storage
  local chart_tags = surface_data.chart_tags
  for idx, tag in pairs(chart_tags) do
    if tag and tag.gps == gps then
      -- Look up the runtime chart tag using the position
      local pos = tag.position or (tag.chart_tag and tag.chart_tag.position)
      if pos then
        local tags = player.force.find_chart_tags(surface, { left_top = pos, right_bottom = pos })
        for _, runtime_tag in pairs(tags) do
          if runtime_tag.position.x == pos.x and runtime_tag.position.y == pos.y then
            pcall(function() runtime_tag.destroy() end)
            break
          end
        end
      end
      -- Remove from storage
      chart_tags[idx] = nil
      return true
    end
  end
  return false
end

-- Rehomes a chart_tag to a new GPS if needed
-- @param player LuaPlayer
-- @param chart_tag LuaCustomChartTag (runtime object)
-- @param gps string (target GPS string)
-- @return LuaCustomChartTag (the new or original chart tag)
function Storage.rehome_chart_tag(player, chart_tag, gps)
  if not player or not chart_tag or not gps then return chart_tag end
  local surface = player.surface
  local surface_index = surface.index
  local gps_from_chart_tag = Helpers.format_gps(chart_tag.position.x, chart_tag.position.y, surface_index)
  if gps_from_chart_tag == gps then
    return chart_tag
  end

  -- find any matching map_tags/favorites that have this chart_tag
  local matching_favorites = {}
  local found_map_tag = Storage.find_map_tag_by_gps(gps)

  if found_map_tag then
    for _, players in pairs(_G.game.players) do
      for _, favorite in pairs(Storage.get_player_favorites(player)) do
        if favorite.gps == gps then
          table.insert(matching_favorites, favorite)
        end
      end
    end
  end

  -- Create new chart tag at the new GPS position
  local new_pos = Helpers.gps_to_map_position(gps)
  if not new_pos then return chart_tag end

  local tag_spec = {
    position = new_pos,
    icon = chart_tag.icon,
    text = chart_tag.text,
    last_user = chart_tag.last_user,
    -- Add any other fields you want to copy
  }
  local new_chart_tag = player.force.add_chart_tag(surface, tag_spec)

  if new_chart_tag then
    local update_gps = 
    Helpers.format_gps(new_chart_tag.position.x, new_chart_tag.position.y, player.surface.index)
    for _, favorite in pairs(matching_favorites) do
      favorite.gps = update_gps
    end

    if found_map_tag then
      found_map_tag.gps = update_gps
      found_map_tag.chart_tag = new_chart_tag
    end
    -- Destroy the old chart tag
    pcall(function() chart_tag.destroy() end)
  end

  return new_chart_tag or chart_tag

end

-- In core/storage.lua, add per-player tag editor position storage
local tag_editor_positions = {}

function Storage.set_tag_editor_position(player, pos)
  if not player or type(player) ~= "table" or not player.index then return end
  tag_editor_positions[player.index] = pos
end

function Storage.get_tag_editor_position(player)
  if not player or type(player) ~= "table" or not player.index then return nil end
  return tag_editor_positions[player.index]
end

function Storage.clear_tag_editor_position(player)
  if not player or type(player) ~= "table" or not player.index then return end
  tag_editor_positions[player.index] = nil
end

return Storage