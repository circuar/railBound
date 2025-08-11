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
    local levelInfo = self.levelLoader:getLevelInfo(levelId)
    return Level.new(levelInfo)
end


return LevelFactory