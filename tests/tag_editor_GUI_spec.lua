-- tests/tag_editor_GUI_spec.lua
-- Unit tests for gui/tag_editor_GUI.lua and related tag editor logic

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it
local spy = require("luassert.spy")

-- Mocks and stubs for Factorio API and mod dependencies
local function mock_player()
    return {
        name = "TestPlayer",
        index = 1,
        surface = { index = 1 },
        force = {
            add_chart_tag = function() return { valid = true, position = { x = 10, y = 20 }, icon = {}, text = "", last_user =
                "TestPlayer" } end
        },
        character = true,
        gui = {
            screen = {},
        },
        print = function() end,
        opened = nil
    }
end

local function mock_helpers()
    return {
        gps_to_map_position = function(gps) return { x = 10, y = 20 } end,
        map_position_to_gps = function(pos, surf) return "010.020.1" end,
        format_gps = function(x, y, surf) return "[gps=" .. x .. "," .. y .. "," .. surf .. "]" end,
        is_valid_map_position = function(pos) return pos and pos.x and pos.y end,
        snap_position = function(pos, scale) return pos end,
        position_can_be_tagged = function(player, pos) return true end,
        position_has_colliding_tag = function(player, pos, tol) return nil end,
        simplify_position = function(pos) return pos end,
        find_by_predicate = function(tbl, pred) return nil, nil end,
        index_is_in_table = function(tbl, idx) return false, nil end,
        gps_to_map_position_string = function(gps) return "[gps=10,20,1]" end
    }
end

local function mock_storage()
    local tags = {}
    return {
        set_tag_editor_position = function(player, pos) player._tag_editor_pos = pos end,
        get_tag_editor_position = function(player) return player._tag_editor_pos end,
        clear_tag_editor_position = function(player) player._tag_editor_pos = nil end,
        find_chart_tag_by_gps = function(player, gps) return nil end,
        find_map_tag_by_gps = function(player, gps) return nil end,
        add_or_update_map_tag = function(player, tag) tags["gps"] = tag end,
        get_player_favorites = function(player) return {} end,
        get_next_available_favorite_slot = function(player) return 1 end,
        get_available_favorite_slots_count = function(player) return 1 end,
        get_map_tags = function(player) return tags end,
        destroy_chart_tag = function(player, gps) return true end,
        reset_chart_tags = function(player) end,
        save_data = function(data) end,
        get = function() return {} end
    }
end

local function mock_gui_base()
    return {
        find_by_path = function(frame, path)
            return
            {
                caption = "[gps=10,20,1]",
                text = "Test",
                elem_value = { name = "signal-A" },
                sprite = "utility/check_mark_green",
                children = {}
            }
        end
    }
end

local function mock_tag_editor_gui_builder()
    return {
        open = function(player, pos, ctx, mod) return true end,
        close = function(player) return true end,
        add_row = function() end
    }
end

local function mock_tag_editor_gui_validation()
    return {
        validate_inputs = function(pos, icon, text, desc, player) return true, text, desc end
    }
end

local function mock_map_tag()
    return {
        new = function(player, pos, chart_tag, is_fav, desc) return { gps = "010.020.1", faved_by_players = { 1 }, description =
            desc, created_by = player.name, is_player_favorite = function(self, p) return true end } end
    }
end

-- Patch package.loaded to inject mocks
package.loaded["core.utils.helpers"] = mock_helpers()
package.loaded["core.storage"] = mock_storage()
package.loaded["gui.gui_base"] = mock_gui_base()
package.loaded["gui.tag_editor_GUI_builder"] = mock_tag_editor_gui_builder()
package.loaded["gui.tag_editor_GUI_validation"] = mock_tag_editor_gui_validation()
package.loaded["core.map_tag"] = mock_map_tag()

local TagEditorGUI = require("gui.tag_editor_GUI")

-- Tests

describe("TagEditorGUI", function()
    it("opens and closes the tag editor", function()
        local player = mock_player()
        assert.is_true(TagEditorGUI.open(player, { x = 10, y = 20 }, {}))
        assert.is_true(TagEditorGUI.close(player))
    end)

    it("gets and sets current position", function()
        local player = mock_player()
        TagEditorGUI.open(player, { x = 10, y = 20 }, {})
        assert.same({ x = 10, y = 20 }, TagEditorGUI.get_current_position(player))
        TagEditorGUI.close(player)
        assert.is_nil(TagEditorGUI.get_current_position(player))
    end)

    it("handles confirm action with valid input", function()
        local player = mock_player()
        TagEditorGUI.open(player, { x = 10, y = 20 }, {})
        -- Should not error
        assert.has_no.errors(function() TagEditorGUI.handle_confirm(player) end)
    end)

    it("handles favorite add/remove logic", function()
        local player = mock_player()
        -- Patch global game for tests that require it
        _G.game = _G.game or { players = { [1] = player } }
        TagEditorGUI.update_favorite(player, "010.020.1")
        TagEditorGUI.remove_favorite(player, "010.020.1")
        -- Should not error
        assert.is_true(true)
    end)

    it("handles action dispatch for confirm/delete/move", function()
        local player = mock_player()
        TagEditorGUI.open(player, { x = 10, y = 20 }, {})
        assert.has_no.errors(function() TagEditorGUI.handle_action(player, "confirm") end)
        assert.has_no.errors(function() TagEditorGUI.handle_action(player, "delete") end)
        assert.has_no.errors(function() TagEditorGUI.handle_action(player, "move") end)
    end)

    it("updates save button state", function()
        local player = mock_player()
        TagEditorGUI.open(player, { x = 10, y = 20 }, {})
        assert.has_no.errors(function() TagEditorGUI.update_save_btn(player) end)
    end)

    it("ignores clicks outside tag editor", function()
        local player = mock_player()
        local event = { element = { name = "not_tag_editor", valid = true, parent = nil }, player_index = 1 }
        assert.has_no.errors(function() TagEditorGUI.on_click(event) end)
    end)
end)
