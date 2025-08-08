local OperationStack = require "game.core.OperationStack"
---@class LevelManager
---@field levelInstance Level
local LevelManager = {}
LevelManager.__index = LevelManager

local function constructor()
    local self = setmetatable({
        levelInstance = nil,
        operationStack = OperationStack.new(),
    }, LevelManager)
    return self
end

local instance = nil

function LevelManager.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

function LevelManager:loadLevel(level)
    self.levelInstance = level
end

function LevelManager:unLoad()
    self.levelInstance = nil
end


return LevelManager