local Level = require "game.level.Level"
---@class LevelFactory
---@field private levelLoader LevelLoader
local LevelFactory = {}
LevelFactory.__index = LevelFactory

function LevelFactory.new(levelLoader)
    local self = setmetatable({
        levelLoader = levelLoader
    }, LevelFactory)
    return self
end

function LevelFactory:getInstance(levelId)
    local levelData = self.levelLoader:getLevelData(levelId)
    



    return Level.new()
end


return LevelFactory