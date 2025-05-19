---@diagnostic disable: param-type-mismatch, assign-type-mismatch, undefined-field
-- tests/storage_spec.lua
-- Unit tests for core/storage.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local Storage = require("core.storage")
local mock = require("tests.mock_factorio")
_G.defines = _G.defines or { render_mode = { chart = "chart", game = "game" } }

describe("Storage", function()
  it("can set, get, and clear tag editor position", function()
    local player = mock.mock_player()
    Storage.set_tag_editor_position(player, { x = 10, y = 20 })
    local pos = Storage.get_tag_editor_position(player)
    assert.same({ x = 10, y = 20 }, pos)
    Storage.clear_tag_editor_position(player)
    assert.is_nil(Storage.get_tag_editor_position(player))
  end)

  it("returns a table for get_player_favorites", function()
    -- NOTE: Type checker may still flag this mock as not matching LuaPlayer due to static analysis limitations.
    -- This is safe for runtime and test purposes. See coding_standards.md for guidance on test mocks and suppressions.
    local player = mock.mock_player()
    local favs = Storage.get_player_favorites(player)
    assert.is_table(favs)
  end)

  it("returns a table for get_map_tags", function()
    local player = mock.mock_player()
    local tags = Storage.get_map_tags(player)
    assert.is_table(tags)
  end)

  it("can add and update a map tag", function()
    local player = mock.mock_player()
    local tag = { gps = "010.020.1", description = "desc" }
    assert.has_no.errors(function() Storage.add_or_update_map_tag(player, tag) end)
    local tags = Storage.get_map_tags(player)
    assert.is_table(tags)
  end)
end)
