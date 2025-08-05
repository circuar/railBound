local LogLevel = require "logger.LogLevel"

---@class Logger
---@field private logLevel LogLevel
---@field private channel string
local Logger = {
    logLevel = LogLevel.INFO
}
Logger.__index = Logger

local LOG_LEVEL_NAME = {
    [LogLevel.DEBUG] = "DEBUG",
    [LogLevel.INFO] = "INFO",
    [LogLevel.WARN] = "WARN",
    [LogLevel.ERROR] = "ERROR",
    [LogLevel.DISABLE] = "DISABLE"
}

---constructor
---@param channel string?
---@return Logger logger
function Logger.new(channel)
    local self = setmetatable({
        channel = channel or "DEFAULT"
    }, Logger)
    return self
end

---set global log level
---@param logLevel LogLevel
function Logger.setGlobalLogLevel(logLevel)
    Logger.logLevel = logLevel
end

---convert LogLevel enum to string name
---@param logLevel LogLevel
---@return string
function Logger.convertLogLevelToName(logLevel)
    return LOG_LEVEL_NAME[logLevel]
end

---print log message to console
---@param message string
---@param logLevel LogLevel
function Logger:log(message, logLevel)
    if logLevel < 0 or logLevel > 3 then
        error("[ ERROR ] @ " .. self.channel .. " ==> invalid log level: " .. logLevel)
    end
    if logLevel >= Logger.logLevel then
        print("[ " .. LOG_LEVEL_NAME[logLevel] .. " ] @ " .. self.channel .. " ==> " .. message)
    end
end

---output debug message
---@param message string
function Logger:debug(message)
    self:log(message, LogLevel.DEBUG)
end

---output info message
---@param message string
function Logger:info(message)
    self:log(message, LogLevel.INFO)
end

---output warn message
---@param message string
function Logger:warn(message)
    self:log(message, LogLevel.WARN)
end

---output error message
---@param message string
function Logger:error(message)
    self:log(message, LogLevel.ERROR)
end

return Logger
