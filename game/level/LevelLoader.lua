local Logger = require "logger.Logger"

---@class LevelLoader
---@field private data table
local LevelLoader = {}
LevelLoader.__index = LevelLoader

local logger = Logger.new("LevelLoader")

function LevelLoader.new()
   local self = setmetatable({},LevelLoader)
   return self
end

function LevelLoader:load(path)
    self.data = require(path)
end

function LevelLoader:getLevelData(levelIndex)
    return self.data[levelIndex]
end

function LevelLoader:getLevelDataByLevelLabel(levelLabel)
    for index, value in ipairs(self.data) do
        if value.levelLabel == levelLabel then
            return value
        end
    end
    logger:error("level label not exists")
    return nil
end

return LevelLoader