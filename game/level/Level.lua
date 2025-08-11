local Global       = require "common.Global"
local api          = require "api"
local GameResource = require "common.GameResource"
-- Level.lua

-- This class should be used as a carrier for the data loaded by LevelLoader and
-- managed by LevelManager.

---@class Level
---@field initLevelInfo table
---@field levelIndex integer
---@field filterParam table
---@field backgroundSceneIndex integer
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


local function initObjectField(levelInfo)
    local self = {
        initLevelInfo = levelInfo,
        levelIndex = levelInfo.levelIndex,
        filterParam = levelInfo.filterParam,
        backgroundSceneIndex = levelInfo.backgroundSceneIndex,
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
                math.Vector3(0, -19.90, yPos),
                math.Quaternion(0, 0, 0),
                math.Vector3(xLength, 0.2, 20)
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
                math.Vector3(xPos, -19.90, 0),
                math.Quaternion(0, 0, 0),
                math.Vector3(yLength, 0.2, 20)
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

function Level:renderFilter()

end

function Level:destroy()

end

return Level
