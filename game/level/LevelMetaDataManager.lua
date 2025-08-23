local Logger = require "logger.Logger"


---@class LevelMetaDataManager
---@field private levelMetaData table
---@field private levelCount integer
local LevelMetaDataManager = {}
LevelMetaDataManager.__index = LevelMetaDataManager

local logger = Logger.new("LevelMetaDataManager")

local instance = nil


local function constructor()
    local levelMetaData = require "resource.levelMetaData"
    -- The number of level pages is not calculated here, and it is fixed at 13
    -- in the constant.
    local self = setmetatable({
        levelMetaData = levelMetaData,
        levelCount = #levelMetaData
    }, LevelMetaDataManager)
    return self
end

function LevelMetaDataManager.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

function LevelMetaDataManager:getLevelMetaData(levelIndex)
    if levelIndex > self.levelCount then
        logger:error("invalid level index value")
    end
    return self.levelMetaData[levelIndex]
end

function LevelMetaDataManager:checkLevelUnlock(levelIndex, mainLevelProgress)
    local mainLevelIndexTempPointer = levelIndex
    local loopCount = 0
    local maxSearchLoopCount = 10

    while self.levelMetaData[mainLevelIndexTempPointer].isExtraLevel == true do
        mainLevelIndexTempPointer = self.levelMetaData[mainLevelIndexTempPointer].preLevelIndex
        loopCount = loopCount + 1
        if loopCount > maxSearchLoopCount then
            logger:error(
                "When searching for the front root level node in the level " ..
                "tree, the maximum search loop count is exceeded. Please " ..
                "check the writing of levelMetaData.lua. There may be an " ..
                "index pointing error.")
            error()
        end
    end
    return mainLevelIndexTempPointer <= mainLevelProgress + 1
end

function LevelMetaDataManager:getLevelMetaDataList()
    return self.levelMetaData
end

function LevelMetaDataManager:getLevelLabel(levelIndex)
    return self.levelMetaData[levelIndex].levelLabel
end

return LevelMetaDataManager
