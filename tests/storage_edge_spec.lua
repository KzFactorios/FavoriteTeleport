---@diagnostic disable: param-type-mismatch, assign-type-mismatch, undefined-field
-- tests/storage_edge_spec.lua
-- Edge case tests for core/storage.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

local Storage = require("core.storage")
local mock = require("tests.mock_factorio")

describe("Storage (edge cases)", function()
  it("handles nil player for tag editor position", function()
    assert.has_no.errors(function() Storage.set_tag_editor_position(nil, {x=1,y=2}) end)
    assert.is_nil(Storage.get_tag_editor_position(nil))
    assert.has_no.errors(function() Storage.clear_tag_editor_position(nil) end)
  end)

  it("handles nil player for favorites and map tags", function()
    assert.is_table(Storage.get_player_favorites(nil))
    assert.is_table(Storage.get_map_tags(nil))
  end)

  it("handles nil player for add_or_update_map_tag", function()
    assert.has_no.errors(function() Storage.add_or_update_map_tag(nil, {gps="foo"}) end)
  end)
end)
