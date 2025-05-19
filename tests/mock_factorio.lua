-- tests/mock_factorio.lua
-- Provides reusable mock factories for Factorio API objects for unit testing

local M = {}

function M.mock_force(overrides)
  local force = {
    name = "test-force",
    add_chart_tag = function() return {} end,
    find_chart_tags = function() return {} end,
    -- Add more methods as needed
  }
  if overrides then for k,v in pairs(overrides) do force[k] = v end end
  return force
end

function M.mock_surface(overrides)
  local surface = {
    index = 1,
    name = "nauvis",
    print = function() end,
    can_place_entity = function() return true end,
    find_non_colliding_position = function() return {x=0,y=0} end,
    is_chunk_generated = function() return true end,
    -- Add more methods as needed
  }
  if overrides then for k,v in pairs(overrides) do surface[k] = v end end
  return surface
end

function M.mock_entity(overrides)
  local entity = {
    valid = true,
    destroy = function() end,
    -- Add more as needed
  }
  if overrides then for k,v in pairs(overrides) do entity[k] = v end end
  return entity
end

function M.mock_gui_element(overrides)
  local elem = {}
  elem.style = {}
  elem.add = function() return elem end
  elem.destroy = function() end
  elem.valid = true
  -- Add more as needed
  if overrides then for k,v in pairs(overrides) do elem[k] = v end end
  return elem
end

function M.mock_gui(overrides)
  local gui = {
    screen = M.mock_gui_element(),
    center = M.mock_gui_element(),
    left = M.mock_gui_element(),
    top = M.mock_gui_element(),
    valid = true,
    -- Add more as needed
  }
  if overrides then for k,v in pairs(overrides) do gui[k] = v end end
  return gui
end

-- Patch mock_player to use robust mocks for all sub-objects
function M.mock_player(overrides)
  local player = {
    index = 1,
    name = "TestPlayer",
    valid = true,
    admin = false,
    connected = true,
    surface = M.mock_surface(),
    position = {x=0, y=0},
    force = M.mock_force(),
    mod_settings = {},
    teleport = function() return true end,
    print = function() end,
    character = M.mock_entity(),
    gui = M.mock_gui(),
    opened = nil,
    render_mode = "game",
    -- Add more fields/methods as needed
  }
  if overrides then for k,v in pairs(overrides) do player[k] = v end end
  return player
end

function M.mock_game(overrides)
  local game = {
    players = {[1] = M.mock_player()},
    forces = {[1] = M.mock_force()},
    surfaces = {[1] = M.mock_surface()},
    connected_players = {},
    print = function() end,
    tick = 0,
    valid = true,
    -- Add more as needed for strict type checking
  }
  if overrides then for k,v in pairs(overrides) do game[k] = v end end
  return game
end

return M
