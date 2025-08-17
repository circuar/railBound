local OperationStack        = require "game.core.OperationStack"
local GameUI                = require "component.GameUI"
local Logger                = require "logger.Logger"
local CameraManager         = require "component.CameraManager"
local Global                = require "common.Global"
local api                   = require "api"
local GameResource          = require "common.GameResource"
local CursorStatusEnum      = require "common.enum.CursorStatusEnum"
local Array                 = require "util.Array"
local GridUnitFactory       = require "game.level.GridUnitFactory"
local GridUnitClassEnum     = require "common.enum.GridUnitClassEnum"
local Train                 = require "game.object.Train"
local PositionDirectionEnum = require "common.enum.PositionDirectionEnum"
local Common                = require "util.Common"
local FrameTimer            = require "game.core.FrameTimer"
local LevelMetaDataManager  = require "game.level.LevelMetaDataManager"


---@class LevelManager
---@field levelFactory LevelFactory
---@field levelInstance Level
---@field cursorEntity Unit
---@field currentLevelGridSize table
---@field effectiveClick boolean
---@field clickPosition Vector3
---@field clickGrid table
---@field operationStack OperationStack
---@field deleteMode boolean
---@field levelRunning boolean
---@field trainFaultArray Train[]
---@field trainSuccessArray Train[]
---@field trainWaitArray Train[]
---@field trainGroupSuccessArray integer[]
---@field gameLoopTimer FrameTimer
local LevelManager   = {}
LevelManager.__index = LevelManager

local logger         = Logger.new("LevelManager")

local instance       = nil

local function createUnitGridRail(grid, row, col, centerPosition)
    local gridUnitRef = grid[row][col]
    if gridUnitRef ~= nil then
        logger:error("This grid unit slot already has a object.")
        error()
    end
    local gridUnit = GridUnitFactory.getInstance(
        GridUnitClassEnum.RAIL_MOVABLE,
        { 0, 1, 0, 1 },
        1,
        centerPosition
    )
    grid[row][col] = gridUnit
    return gridUnit
end


---comment
---@param grid MovableRail[][]
---@param row integer
---@param col integer
local function clickMovableGridUnitRail(grid, row, col)
    local gridUnitRef = grid[row][col]
    if gridUnitRef:isFixed() then
        logger:warn("This is a fixed grid unit, skipped.")
        return
    end
    local channelCount = Array.countElement(grid, 1)
    if channelCount ~= 3 then
        return
    end
    gridUnitRef:mirror()
end

local function slideMovableGridUnitRail(grid, row, col, slideDirection)

end

local function calcNextEnterDirection(currentRow, currentCol, nextRow, nextCol)
    if (currentCol - nextCol) * (currentRow - nextRow) ~= 0 then
        logger:error("Wrong grid movement direction.")
        error()
    end

    if currentRow == nextRow and currentCol == nextCol then
        return PositionDirectionEnum.CENTER
    end

    if nextRow - currentRow == 1 then
        return PositionDirectionEnum.TOP
    elseif nextRow - currentRow == -1 then
        return PositionDirectionEnum.BOTTOM
    elseif nextCol - currentCol == 1 then
        return PositionDirectionEnum.LEFT
    else
        return PositionDirectionEnum.RIGHT
    end
end

local function calcNextEnterDirectionMask(currentRow, currentCol, nextRow, nextCol)
    if (currentCol - nextCol) * (currentRow - nextRow) ~= 0 then
        logger:error("Wrong grid movement direction.")
        error()
    end
    local directionMask = {}
    directionMask[1] = Common.ternary(nextRow - currentRow > 0, 1, 0)
    directionMask[2] = Common.ternary(nextCol - currentCol < 0, 1, 0)
    directionMask[3] = Common.ternary(nextRow - currentRow < 0, 1, 0)
    directionMask[4] = Common.ternary(nextCol - currentCol > 0, 1, 0)
    return directionMask
end

local function calcGridPositionOffset(row, col, directionMask)
    if directionMask[1] == 1 then
        return { row = row - 1, col = col }
    elseif directionMask[2] == 1 then
        return { row = row, col = col + 1 }
    elseif directionMask[3] then
        return { row = row + 1, col = col }
    else
        return { row = row, col = col - 1 }
    end
end
-- constructor =================================================================


local function constructor()
    local createCursorEntity = api.base.getEntityById(GameResource.GAME_GRID_CREATE_CURSOR_ENTITY_ID)
    api.base.setEntityPosition(createCursorEntity, math.Vector3(0, -50, 0))

    local deleteCursorEntity = api.base.getEntityById(GameResource.GAME_GRID_DELETE_CURSOR_ENTITY_ID)
    api.base.setEntityPosition(deleteCursorEntity, math.Vector3(0, -50, 0))

    local self = setmetatable({
        levelFactory = nil,
        levelInstance = nil,
        cursorEntity = {
            [CursorStatusEnum.CREATE] = createCursorEntity,
            [CursorStatusEnum.DELETE] = deleteCursorEntity,
        },
        currentLevelGridSize = {},
        effectiveClick = false,
        clickPosition = nil,
        clickGrid = {},
        operationStack = OperationStack.new(),
        deleteMode = false,
        levelRunning = false,
        trainFaultArray = {},
        trainSuccessArray = {},
        trainWaitArray = {},
        trainGroupSuccessArray = {}
    }, LevelManager)
    return self
end

function LevelManager.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

-- public method ===============================================================

function LevelManager:setLevelFactory(levelFactory)
    self.levelFactory = levelFactory
end

function LevelManager:changeCursor(row, col, status)
    local centerX = (col - 0.5 - self.currentLevelGridSize.col / 2) * Global.GAME_GRID_SIZE
    local centerZ = (row - 0.5 - self.currentLevelGridSize.row / 2) * Global.GAME_GRID_SIZE
    api.base.setEntityPosition(self.cursorEntity[status], math.Vector3(centerX, -20, centerZ))
    for key, cursorEntity in pairs(self.cursorEntity) do
        if key ~= status then
            api.base.setEntityPosition(cursorEntity, math.Vector3(0, -50, 0))
        end
    end
end

function LevelManager:hideCursor()
    for key, cursorEntity in pairs(self.cursorEntity) do
        api.base.setEntityPosition(cursorEntity, math.Vector3(0, -50, 0))
    end
end

--- Load level by levelIndex.
---@param levelIndex integer
function LevelManager:loadLevel(levelIndex)
    if self.levelFactory == nil then
        logger:error("level factory not set")
    end
    local levelInstance = self.levelFactory:getInstance(levelIndex)

    self.levelInstance = levelInstance
    self.currentLevelGridSize = { row = levelInstance.gridRowSize, col = levelInstance.gridColSize }


    levelInstance:renderFilter()
    levelInstance:setLevelCamera()
    levelInstance:renderGridLine()
    levelInstance:renderSceneBackground()

    GameUI.setGameUIRailCount(self.levelInstance.remainRailCount)
    GameUI.setGameUILevelName(LevelMetaDataManager.instance():getLevelLabel(levelIndex))
end

function LevelManager:playCusSceneIn()
    local cameraManager = CameraManager.instance()
    local cameraMoveVelocity = math.Vector3(-50, 0, 0)
    local cameraMoveDistance = 50.0
    local cameraMoveDuration = cameraMoveDistance / cameraMoveVelocity:length()
    cameraManager:cameraMove(cameraMoveVelocity, cameraMoveDuration)
    api.setTimeout(function()
        GameUI.showLevelSwitchAnimIn()
    end, cameraMoveDuration - Global.LEVEL_SWITCH_ANIM_IN_OUT_DURATION)
end

function LevelManager:playCusSceneOut()
    local cameraManager = CameraManager.instance()
    local cameraMoveVelocity = math.Vector3(50, 0, 0)
    local cameraMoveDistance = 50.0
    local cameraMoveDuration = cameraMoveDistance / cameraMoveVelocity:length()

    --- initial camera position
    cameraManager:setCameraPosition(Global.GAME_CAMERA_CENTER_REFERENCE_POINT - cameraMoveVelocity * cameraMoveDuration)

    cameraManager:cameraMove(cameraMoveVelocity, cameraMoveDuration)
    GameUI.showLevelSwitchAnimOut()
end

---comment
---@param status boolean
function LevelManager:setDeleteMode(status)
    self.deleteMode = status
    if status then
        GameUI.showDeleteUIBorder()
    else
        GameUI.hideDeleteUIBorder()
    end
end

function LevelManager:unLoadLevel()
    -- unload level instance
    self.levelInstance:destroy()
    self.levelInstance = nil

    self.currentLevelGridSize = nil
    self.operationStack:clear()
    self.trainFaultArray = {}
end

function LevelManager:runLevel()
    self.levelRunning = true

    local trains = self.levelInstance.trains
    local rowSize = self.levelInstance.gridRowSize
    local colSize = self.levelInstance.gridColSize
    local grid = self.levelInstance.grid

    local forwardArray = {}

    -- Preparation after clicking the start button.
    --
    -- At this time, the train is in the starting GridUnit, the train is held by
    -- the GridUnit and waiting, you need to manually judge whether the next
    -- gridUnit is blocked, if it is not blocked, cancel the wait, call resume()
    -- to switch to the normal state and leave the current GridUnit, at this
    -- time it is ready to enter the GridUnit loop.
    --
    -- The judgment of the fault state is also handed over to the subsequent
    -- loop.
    for index, train in ipairs(trains) do
        local trainNextGridPos = train:initForward()
        local trainCurrentGridPos = train:getCurrentGridPosition()
        table.insert(forwardArray, trainNextGridPos)
        local nextGridUnit = grid[trainNextGridPos.row][trainNextGridPos.col]

        if nextGridUnit == nil or not nextGridUnit:await() then
            grid[trainCurrentGridPos.row][trainCurrentGridPos.col]:resume()
        end
    end

    local gameLoopTimer = FrameTimer.new(Global.GAME_GRID_LOOP_FRAME_COUNT, true)
    self.gameLoopTimer = gameLoopTimer

    gameLoopTimer:setTask(function()
        -- Filter out the train instances that need to be performed in this loop.
        --
        -- Trains in success, failure, wait state do not enter the loop.
        local loopOperationTrains = {}
        for index, train in ipairs(trains) do
            local selectCondition = not (
                Array.contains(self.trainSuccessArray, train)
                or Array.contains(self.trainFaultArray, train)
                or Array.contains(self.trainWaitArray, train)
            )

            if selectCondition then
                local currentRow = train:getCurrentGridPosition().row
                local currentCol = train:getCurrentGridPosition().col
                local nextRow = forwardArray[train.trainId].row
                local nextCol = forwardArray[train.trainId].col

                local faultCondition = (
                    nextRow < 1 or nextRow > rowSize
                    or nextCol < 1 or nextCol > colSize
                    or grid[nextRow][nextCol] == nil
                    or grid[nextRow][nextCol]:isFault()
                    or not grid[nextRow][nextCol]:checkEnterPermit(calcNextEnterDirection(
                        currentRow,
                        currentCol,
                        nextRow,
                        nextCol
                    ))
                )

                -- If there will be a fault, the fault logic will be executed at
                -- this time, and the instance will be added to the fault array, and
                -- the subsequent logic will not be executed in this loop.
                --
                -- TODO check game over
                if faultCondition then
                    train:fault()
                    table.insert(self.trainFaultArray, train)
                    grid[currentRow][currentCol]:fault()
                else
                    table.insert(loopOperationTrains, train)
                end
            end
        end

        for index, train in ipairs(loopOperationTrains) do
            local currentRow = train:getCurrentGridPosition().row
            local currentCol = train:getCurrentGridPosition().col

            local nextRow = forwardArray[train.trainId].row
            local nextCol = forwardArray[train.trainId].col
            local nextGridUnit = grid[nextRow][nextCol]

            local forwardPosition = calcGridPositionOffset(nextRow, nextCol,
                nextGridUnit:forward(calcNextEnterDirectionMask(currentRow, currentCol, nextRow,
                    nextCol)))
            local forwardRow = forwardPosition.row
            local forwardCol = forwardPosition.col

            forwardArray[train.trainId] = { row = forwardRow, col = forwardCol }


            if grid[forwardRow][forwardCol]:await() then
                nextGridUnit:wait(train)
            else
                nextGridUnit:onEnter(train)
            end
        end
    end)
    api.setTimeout(function()
        gameLoopTimer:run()
    end, Train.getInitForwardDuration())
end

-- callback method =============================================================

--- Called when the carriages of the current group are fully connected
--- correctly.
---
--- This function call must have a delay compared to the last taskLoop.
--- @param groupId integer
function LevelManager:trainGroupSuccessSignal(groupId)

end

--- Called when the carriage enters the terminal GridUnit and will be
--- successfully connected.
---
--- This method is called when the train instance enters the endpoint gridUnit,
--- that is, in the onEnter() function. The game cannot be completely finished
--- in this function, because there is still some distance between the
--- carriages, and there should be time for the carriages to be fully linked.
---
--- This is designed so that the cycle timer can stop as early as possible.
--- Avoid players operating between two timer loops, causing data changes in the
--- grid and causing the timer to stop properly.
---@param successTrainId integer
function LevelManager:trainSuccessSignal(successTrainId)
    table.insert(self.trainFaultArray, self.levelInstance.trains[successTrainId])
end

--- It is called when the train breaks down, including collisions, incorrect
--- connection sequences, etc.
---
--- This function is called at the same time as
--- trainSuccessSignal(successTrainId).
---@param failedTrainId integer
function LevelManager:trainFailedSignal(failedTrainId)
    table.insert(self.trainFaultArray, self.levelInstance.trains[failedTrainId])
end

---@param position Vector3
function LevelManager:click(position)
    local posX = position.x
    local posZ = position.z
    local stdX = self.currentLevelGridSize.col / 2 + posX
    local clickCol = math.floor(stdX / Global.GAME_GRID_SIZE) + 1
    if clickCol > self.currentLevelGridSize.col or clickCol < 1 then
        self.effectiveClick = false
        return
    end
    local stdY = self.currentLevelGridSize.row / 2 + posZ
    local clickRow = self.currentLevelGridSize.row - (math.floor(stdY / Global.GAME_GRID_SIZE))
    if clickRow > self.currentLevelGridSize.row or clickRow < 1 then
        self.effectiveClick = false
        return
    end
    self.effectiveClick = true
    self.clickPosition = position
    self.clickGrid = { row = clickRow, col = clickCol }
    logger:info("player click operation, click: row = " .. clickRow ..
        ", col = " .. clickCol)

    if self.deleteMode then
        -- create cursor
        self:changeCursor(clickRow, clickCol, CursorStatusEnum.DELETE)
        -- delete grid unit logic
    else
        local clickGridUnitRef = self.levelInstance.grid[clickRow][clickCol]
        if clickGridUnitRef == nil then
            --create logic
            self:changeCursor(clickRow, clickCol, CursorStatusEnum.CREATE)
        else
        end
    end
end

function LevelManager:slide(angle)
    if self.effectiveClick == false then
        return
    end
end

function LevelManager:cancelClick()
    if self.effectiveClick == false then
        return
    end
    self:hideCursor()
end

return LevelManager
