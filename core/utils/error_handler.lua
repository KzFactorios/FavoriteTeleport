-- error_handle.lua
-- Utility functions for error logging and reporting

local M = {}

local function safe_log(msg)
  if _G.log and type(_G.log) == "function" then
    _G.log(msg)
  end
end

--- Logs an error message to error-log.txt and optionally to the Factorio log
-- @param msg string The error message to log
function M.log_error(msg)
  -- Factorio does not provide standard Lua io/os libraries in runtime, so we only use log()
  local log_msg = "[FavoriteTeleport][ERROR] " .. msg
  if _G.log and type(_G.log) == "function" then
    _G.log(log_msg)
  end
end

return M
