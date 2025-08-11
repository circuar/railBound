local Global       = require "common.Global"
local api          = require "api"
local GameResource = require "common.GameResource"
local Logger       = require "logger.Logger"
-- Level.lua

-- This class should be used as a carrier for the data loaded by LevelLoader and
-- managed by LevelManager.

---@class Level
---@field initLevelInfo table
---@field levelIndex integer
---@field filterParam table
---@field backgroundSceneIndex integer
---@field loadSceneEntity Unit
---@field remainRailCount integer
---@field gridRowSize integer
---@field gridColSize integer
---@field gridData table[][]
---@field grid GridUnit[][]
---@field gridPositionMap Vector3[][]
---@field trainData table[]
---@field trains Train[]
---@field finalLinkedGridUnitData table
---@field finalLinkedGridUnits GridUnit[]
---@field gridLineEntityList Unit[]
local Level        = {}
Level.__index      = Level

local logger       = Logger.new("Level")

local function initObjectField(levelInfo)
    local self = {
        initLevelInfo = levelInfo,
        levelIndex = levelInfo.levelIndex,
        filterParam = levelInfo.filterParam,
        backgroundSceneIndex = levelInfo.backgroundSceneIndex,
        loadSceneEntity = nil,
        remainRailCount = levelInfo.remainRailCount,
        gridRowSize = levelInfo.levelData.gridSize.row,
        gridColSize = levelInfo.levelData.gridSize.col,
        gridData = levelInfo.levelData.grid,
        grid = {},
        gridPositionMap = {},
        trainData = levelInfo.trainData,
        trains = {},
        finalLinkedGridUnitData = levelInfo.finalLinkedPositionData,
        finalLinkedGridUnits = {},

        gridLineEntityList = {}
    }
    return self
end

function Level.new(levelInfo)
    local self = initObjectField(levelInfo)
    setmetatable(self, Level)
    return self
end

function Level:getGrid()
    return self.grid
end

function Level:renderGridLine()
    -- render x direction line
    local referenceY = -(self.gridRowSize * Global.GAME_GRID_SIZE) / 2
    for i = 1, self.gridRowSize + 1, 1 do
        local yPos = (i - 1) * Global.GAME_GRID_SIZE + referenceY
        local xLength = self.gridColSize * Global.GAME_GRID_SIZE
        table.insert(
            self.gridLineEntityList, api.base.createEntity(
                GameResource.GAME_GRID_EDGE_LINE_PRESET_ID,
                math.Vector3(0, -20, yPos),
                math.Quaternion(0, 0, 0),
                math.Vector3(xLength, 20.2, 0.2)
            )
        )
        logger:debug("create grid line at: " .. tostring(math.Vector3(0, -20, yPos)))
    end

    -- render y direction line
    local referenceX = -(self.gridColSize * Global.GAME_GRID_SIZE) / 2
    for i = 1, self.gridColSize + 1, 1 do
        local xPos = (i - 1) * Global.GAME_GRID_SIZE + referenceX
        local yLength = self.gridRowSize * Global.GAME_GRID_SIZE
        table.insert(
            self.gridLineEntityList, api.base.createEntity(
                GameResource.GAME_GRID_EDGE_LINE_PRESET_ID,
                math.Vector3(xPos, -20, 0),
                math.Quaternion(0, 0, 0),
                math.Vector3(0.2, 20.2, yLength)
            )
        )
    end
end

function Level:destroyGridLine()
    for index, value in ipairs(self.gridLineEntityList) do
        api.base.destroyEntity(value)
        self.gridLineEntityList[index] = nil
    end
end

function Level:renderGridUnit()

end

function Level:clearGridUnitEntity()

end

function Level:renderSceneBackground()
    local entityId = GameResource.GAME_SCENE_BACKGROUND_ENTITY_ID_LIST[self.backgroundSceneIndex]
    local sceneEntity = api.base.getEntityById(entityId)
    self.loadSceneEntity = sceneEntity
    api.base.setEntityPosition(sceneEntity, math.Vector3(0, 0, 0))
    logger:info("set scene background, index: " .. self.backgroundSceneIndex)
end

function Level:clearSceneBackground()
    if self.loadSceneEntity == nil then
        logger:info("Scene background without loading.")
        return
    end
    api.base.setEntityPosition(self.loadSceneEntity, math.Vector3(0, 0, 500))
    self.loadSceneEntity = nil
end

function Level:renderFilter()

end

function Level:destroy()

end

return Level
