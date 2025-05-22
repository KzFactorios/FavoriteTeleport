-- core/control/lifecycle.lua
-- Handles mod lifecycle events for FavoriteTeleport

local Cache = require("core.cache.init")
local Context = require("core.context")

local Lifecycle = {}

function Lifecycle.on_init()
  -- Initialize persistent cache and context
  Cache.init()
  Context.init()
end

function Lifecycle.on_load()
  -- Re-initialize runtime-only state if needed
  -- (Factorio automatically reloads global, but you may need to re-register observers, GUIs, etc.)
end

function Lifecycle.on_configuration_changed(event)
  -- Handle migrations or schema upgrades if needed
  Cache.init() -- Ensure cache is up to date
  Context.init()
end

return Lifecycle
