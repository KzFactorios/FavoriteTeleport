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

--- Safely calls a function and catches errors, returning (true, ...) on success or (false, errmsg) on error
function ErrorHandler.safe_call(fn, ...)
  local ok, result_or_err, rest = pcall(fn, ...)
  if ok then
    return true, result_or_err, rest
  else
    ErrorHandler.log_error("safe_call error: " .. tostring(result_or_err))
    return false, tostring(result_or_err)
  end
end

return ErrorHandler
