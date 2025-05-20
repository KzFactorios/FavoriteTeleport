-- core/control/lifecycle.lua
-- Handles mod lifecycle events for FavoriteTeleport

local Storage = require("core.storage")
local Context = require("core.context")

local Lifecycle = {}

function Lifecycle.on_init()
  -- Initialize persistent storage and context
  Storage.init()
  Context.init()
end

function Lifecycle.on_load()
  -- Re-initialize runtime-only state if needed
  -- (Factorio automatically reloads global, but you may need to re-register observers, GUIs, etc.)
end

function Lifecycle.on_configuration_changed(event)
  -- Handle migrations or schema upgrades if needed
  Storage.init() -- Ensure storage is up to date
  Context.init()
end

return Lifecycle
