local Global            = require "common.Global"
local api               = require "api"
local GameResource      = require "common.GameResource"
local Logger            = require "logger.Logger"
local GridUnitFactory   = require "game.level.GridUnitFactory"
local GridUnitClassEnum = require "common.enum.GridUnitClassEnum"
local CameraManager     = require "component.CameraManager"
local Train             = require "game.object.Train"
-- Level.lua

-- This class should be used as a carrier for the data loaded by LevelLoader and
-- managed by LevelManager.

---@class Level
---@field initLevelInfo table
---@field levelIndex integer
---@field filterParam table
---@field backgroundSceneIndex integer
---@field cameraDistance number
---@field loadSceneEntity Unit
---@field remainRailCount integer
---@field gridRowSize integer
---@field gridColSize integer
---@field gridData table[][]
---@field grid GridUnit[][]
---@field gridPositionMap Vector3[][]
---@field trainData table[]
---@field trains Train[]
---@field trainGroupCount integer
---@field finalLinkedGridUnits FinalLinkedRail[]
---@field gridLineEntityList Unit[]
local Level             = {}
Level.__index           = Level

local logger            = Logger.new("Level")

---comment
---@param row integer
---@param col integer
---@param totalRow integer
---@param totalCol integer
---@return Vector3
local function calcUnitPosition(row, col, totalRow, totalCol)
    local xCenter = (col - 0.5 - totalCol / 2) * Global.GAME_GRID_SIZE
    local zCenter = (totalRow / 2 - row + 0.5) * Global.GAME_GRID_SIZE
    return math.Vector3(xCenter, 0, zCenter)
end

local function initObjectField(levelInfo)
    local self = {
        initLevelInfo = levelInfo,
        levelIndex = levelInfo.levelIndex,
        filterParam = levelInfo.filterParam,
        backgroundSceneIndex = levelInfo.backgroundSceneIndex,
        cameraDistance = levelInfo.cameraDistance,
        loadSceneEntity = nil,
        remainRailCount = levelInfo.levelData.remainRailCount,
        gridRowSize = levelInfo.levelData.gridSize.row,
        gridColSize = levelInfo.levelData.gridSize.col,
        gridData = levelInfo.levelData.gridData,
        grid = {},
        gridPositionMap = {},
        trainData = levelInfo.levelData.trainData,
        trains = {},
        trainGroupCount = levelInfo.levelData.groupChannelCount,
        finalLinkedGridUnits = {},

        gridLineEntityList = {},
    }
    -- init grid
    for rowIndex, row in ipairs(self.gridData) do
        -- initialize two-dimensional array
        self.grid[rowIndex] = {}
        self.gridPositionMap[rowIndex] = {}

        for colIndex, colElemData in ipairs(row) do
            local gridUnitPosition = calcUnitPosition(rowIndex, colIndex, self.gridRowSize, self.gridColSize)
            self.gridPositionMap[rowIndex][colIndex] = gridUnitPosition

            if colElemData.gridUnitType ~= GridUnitClassEnum.EMPTY then
                local gridUnitInstance = GridUnitFactory.getInstance(
                    colElemData.gridUnitType,
                    colElemData.directionMask,
                    colElemData.chiralityMask,
                    gridUnitPosition,
                    colElemData.extraData
                )
                self.grid[rowIndex][colIndex] = gridUnitInstance

                gridUnitInstance:render()

                if colElemData.gridUnitType == GridUnitClassEnum.RAIL_FINAL then
                    table.insert(self.finalLinkedGridUnits, gridUnitInstance)
                end
            end
        end
    end

    -- init train object
    for index, trainData in ipairs(self.trainData) do
        table.insert(self.trains, Train.new(
            trainData,
            self.gridPositionMap[trainData.position.row][trainData.position.col])
        )
    end

    return self
end

function Level.new(levelInfo)
    local self = initObjectField(levelInfo)
    setmetatable(self, Level)
    return self
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

function Level:setLevelCamera()
    local cameraManager = CameraManager.instance()
    cameraManager:setCameraDistance(self.cameraDistance)
end

function Level:destroy()
    self:clearSceneBackground()
    self:destroyGridLine()
end

return Level
