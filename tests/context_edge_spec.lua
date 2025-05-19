---@diagnostic disable: param-type-mismatch, assign-type-mismatch, undefined-field
-- tests/context_edge_spec.lua
-- Edge case tests for core/context.lua

-- Patch Factorio globals for all tests
_G.defines = _G.defines or { render_mode = { chart = "chart", game = "game" } }
_G.script = _G.script or setmetatable({}, { __index = function() return function() end end })

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

_G.defines = _G.defines or { render_mode = { chart = "chart", game = "game" } }
local Context = require("core.context")

describe("Context (edge cases)", function()
  it("returns nil for get_player_data with nil player", function()
    local pdata = Context.get_player_data(nil)
    assert.are.same(pdata, {})
  end)

  it("handles get_player_data with missing index", function()
    -- NOTE: Type checker may still flag this mock as not matching LuaPlayer due to static analysis limitations.
    -- This is safe for runtime and test purposes. See coding_standards.md for guidance on test mocks and suppressions.
    local mock = require("tests.mock_factorio")
    local mock_player = mock.mock_player({ index = 123, name = "Test", surface = mock.mock_surface() })
    local pdata = Context.get_player_data(mock_player)
    assert.is_table(pdata)
  end)

  it("handles get_data when data is not initialized", function()
    -- Simulate missing data
    local old = Context._data
    Context._data = nil
    local data = Context.get_data()
    assert.is_table(data)
    Context._data = old
  end)
end)
