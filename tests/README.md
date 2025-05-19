# Test Mocking Strategy for FavoriteTeleport

This project uses a reusable mock factory for Factorio API objects in unit and integration tests. This approach ensures:
- Consistent, robust mocks for LuaPlayer, LuaForce, LuaSurface, etc.
- Easy extension for new API fields/methods as needed by tests.
- Suppression of strict type errors in test files via global diagnostic disables.

## Usage
- Import the mock factory in your test file:
  ```lua
  local mock = require("tests.mock_factorio")
  ```
- Create a mock player:
  ```lua
  local player = mock.mock_player()
  ```
- Override fields/methods as needed:
  ```lua
  local player = mock.mock_player({ name = "Alice", position = {x=10, y=20} })
  ```

## Type Checking
- All test files using Factorio object mocks should include at the top:
  ```lua
  ---@diagnostic disable: param-type-mismatch, assign-type-mismatch, undefined-field
  ```
- This disables strict type errors for incomplete mocks in test files only.

## Extending Mocks
- Add new fields/methods to `tests/mock_factorio.lua` as needed for your tests.

## See Also
- [core/types/factorio_api.lua](../core/types/factorio_api.lua) for expected Factorio API types.
