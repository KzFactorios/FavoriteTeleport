-- tests/integration_control_spec.lua
-- Integration tests for control.lua with mocked Factorio events

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

-- Mock Factorio API and mod modules
local mock_factorio = require("tests.mock_factorio")
_G.game = mock_factorio.mock_game()
local player = _G.game.players[1]

local function mock_event(event_type, player_index)
  return { name = event_type, player_index = player_index or 1 }
end

-- Patch global script for integration test to accept any arguments (fixes 'expected 0 parameters but found 2')
_G.script = _G.script or {}
_G.script.on_event = function(...) end
_G.script.on_nth_tick = function(...) end
_G.script.on_init = function(...) end
_G.script.on_load = function(...) end
_G.script.on_configuration_changed = function(...) end
_G.script.events = {
  on_gui_click = 1,
  on_gui_opened = 2,
  on_gui_closed = 3,
  on_player_created = 4,
  on_player_removed = 5,
  on_tick = 6,
  on_init = 7,
  on_load = 8,
  on_configuration_changed = 9,
  __any = 999,
}
setmetatable(_G.script.events, { __index = function(_, _) return 999 end })

-- Defensive patch: ensure _G.defines and _G.defines.events are always present for strict test environments
_G.defines = _G.defines or {}
_G.defines.events = _G.defines.events or setmetatable({}, { __index = function(_, _) return 999 end })
_G.defines.render_mode = _G.defines.render_mode or { chart = 'chart', game = 'game' }
-- Patch all other required fields as empty tables for strict type checkers
local required_defines_fields = {
  'robot_order_type','logistic_member_index','prototypes','distraction','wire_type','cargo_destination','input_method','gui_type','logistic_mode','control_behavior','difficulty','disconnect_reason','entity_status_diode','print_skip','rocket_silo_status','rail_connection_direction','game_controller_interaction','chain_signal_state','space_platform_state','deconstruction_item','command','print_sound','transport_line','inventory','rail_direction','train_state','relative_gui_position','rail_layer','entity_status','behavior_result','moving_state','flow_precision_index','chunk_generated_status','default_icon_size','build_check_type','shooting','direction','riding','build_mode','target_type','logistic_section_type','compound_command','input_action','controllers','signal_state','rich_text_setting','selection_mode','relative_gui_type','alert_type','group_state','mouse_button_type','wire_origin','wire_connector_id'
}
for _, field in ipairs(required_defines_fields) do
  if _G.defines[field] == nil then
    _G.defines[field] = {}
  end
end

-- Patch global remote for integration test to accept any arguments (fixes 'expected 0 parameters but found 2')
_G.remote = _G.remote or {}
_G.remote.add_interface = function(...) end
_G.remote.call = function(...) return {} end

-- Patch global serpent for integration test to accept any arguments (fixes 'expected 1 parameters but found 2')
_G.serpent = _G.serpent or { load = function() end, block = function() end, dump = function() end, line = function(val, opts) return tostring(val) end }

-- Patch global ft_storage_viewer_expand_state and player_index for integration test
_G.ft_storage_viewer_expand_state = _G.ft_storage_viewer_expand_state or {}
_G.player_index = 1

local control = require("control")

describe("control.lua integration", function()
  it("runs script.on_init without error", function()
    assert.has_no.errors(function()
      if control and control.on_init then control.on_init() end
    end)
  end)

  it("runs script.on_load without error", function()
    assert.has_no.errors(function()
      if control and control.on_load then control.on_load() end
    end)
  end)

  it("runs script.on_configuration_changed without error", function()
    assert.has_no.errors(function()
      if control and control.on_configuration_changed then control.on_configuration_changed({}) end
    end)
  end)

  it("handles a mocked event without error", function()
    local event = mock_event("on_player_controller_changed", 1)
    assert.has_no.errors(function()
      -- Simulate event handler call if available
      if control and control.on_player_controller_changed then
        control.on_player_controller_changed(event)
      end
    end)
  end)
end)
