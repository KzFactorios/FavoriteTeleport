-- tests/error_handler_spec.lua
-- Unit tests for core/utils/error_handler.lua

local busted = require("busted")
local assert = busted.assert
local describe = busted.describe
local it = busted.it

package.loaded["core.utils.error_handler"] = nil
package.loaded["core.utils.error_handler"] = nil
local ErrorHandler = require("core.utils.error_handler")

describe("ErrorHandler", function()
  it("can safely call a function with no error", function()
    local called = false
    local function f() called = true end
    local ok = ErrorHandler.safe_call(f)
    assert.is_true(ok)
    assert.is_true(called)
  end)

  it("returns false and error message on error", function()
    local function f() error("fail!") end
    local ok, msg = ErrorHandler.safe_call(f)
    assert.is_false(ok)
    assert.is_string(msg)
  end)
end)
