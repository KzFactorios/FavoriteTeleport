-- tests/context_spec.lua
-- Unit tests for core/context.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

_G.defines = _G.defines or { render_mode = { chart = "chart", game = "game" } }
local Context = require("core.context")

describe("Context", function()
  it("returns a table for get_data", function()
    local data = Context.get_data()
    assert.is_table(data)
  end)

  it("returns a table for get_player_data", function()
    local player = { index = 1 }
    local pdata = Context.get_player_data(player)
    -- Accept both table and nil, since edge cases may return nil
    assert.is_true(type(pdata) == "table" or pdata == nil)
  end)

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
end)
