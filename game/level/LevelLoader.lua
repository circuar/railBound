---@class LevelLoader
---@field private data table
local LevelLoader = {}
LevelLoader.__index = LevelLoader

function LevelLoader.new()
   local self = setmetatable({},LevelLoader)
   return self
end

function LevelLoader:load(path)
    self.data = require(path)
end

function LevelLoader:getLevelData(levelId)
    return {
        
    }
end

return LevelLoader