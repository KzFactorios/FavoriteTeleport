-- error_handler.lua
-- Utility functions for error logging and reporting

local ErrorHandler = {}

local function safe_log(msg)
  if _G.log and type(_G.log) == "function" then
    _G.log(msg)
  end
end

--- Logs an error message to the Factorio log
-- @param msg string The error message to log
function ErrorHandler.log_error(msg)
  local log_msg = "[FavoriteTeleport][ERROR] " .. msg
  safe_log(log_msg)
end

return ErrorHandler
