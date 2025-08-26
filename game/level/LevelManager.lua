local OperationStack = require "game.core.OperationStack"
local GameUI = require "component.GameUI"
local Logger = require "logger.Logger"
local CameraManager = require "component.CameraManager"
local Global = require "common.Global"
local api = require "api"
local GameResource = require "common.GameResource"
local CursorStatusEnum = require "common.enum.CursorStatusEnum"
local Array = require "util.Array"
local Common = require "util.Common"
local FrameTimer = require "game.core.FrameTimer"
local LevelMetaDataManager = require "game.level.LevelMetaDataManager"
local GameUIRunBtnStatusEnum = require "common.enum.GameUIRunBtnStatusEnum"
local TrainTypeEnum = require "common.enum.TrainTypeEnum"
local MovableRail = require "game.object.grid.MovableRail"
local PositionDirectionEnum = require "common.enum.PositionDirectionEnum"


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
---@field hinderTrainFinalArray Train[]
---@field trainSuccessArray Train[]
---@field trainWaitArray Train[]
---@field trainGroupSuccessArray integer[]
---@field gameLoopTimer FrameTimer
---@field delayTaskTimers FrameTimer[]
local LevelManager = {}
LevelManager.__index = LevelManager

local logger = Logger.new("LevelManager")

local instance = nil

--- Constructor.
local function constructor()
    local normalCursorEntity = api.base.getEntityById(GameResource.GAME_GRID_NORMAL_CURSOR_ENTITY_ID)
    api.base.setEntityPosition(normalCursorEntity, math.Vector3(0, -50, 0))

    local deleteCursorEntity = api.base.getEntityById(GameResource.GAME_GRID_DELETE_CURSOR_ENTITY_ID)
    api.base.setEntityPosition(deleteCursorEntity, math.Vector3(0, -50, 0))

    local self = setmetatable({
        levelFactory = nil,
        levelInstance = nil,
        cursorEntity = {
            [CursorStatusEnum.NORMAL] = normalCursorEntity,
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
        hinderTrainFinalArray = {},
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

function LevelManager:setLevelFactory(levelFactory)
    self.levelFactory = levelFactory
end

function LevelManager:changeCursor(row, col, status)
    local centerX = (col - 0.5 - self.currentLevelGridSize.col / 2) * Global.GAME_GRID_SIZE
    local centerZ = -(row - 0.5 - self.currentLevelGridSize.row / 2) * Global.GAME_GRID_SIZE
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

    levelInstance:setLevelManagerRef(self)

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

---@param grid GridUnit[][]
---@param gridSize table
---@param train Train
---@param forward table
---@param forwardDirection table
---@param cache Train[]
local function checkTrainWillFault(grid, gridSize, train, forward, forwardDirection, cache)
    if Array.contains(cache, train) then
        return false
    end

    table.insert(cache, train)

    local nextPosition = forward[train:getTrainId()]

    local boundFaultCondition = (
        nextPosition.row < 1
        or nextPosition.row > gridSize.row
        or nextPosition.col < 1
        or nextPosition.row > gridSize.col
    )

    if boundFaultCondition then
        return true
    end

    local nextGridUnit = grid[nextPosition.row][nextPosition.col]
    local logicFaultCondition = (
        nextGridUnit == nil
        or not nextGridUnit:checkEnterPermit(
            Common.directionReverse(forwardDirection[train:getTrainId()])
        )
        or nextGridUnit:isFault()
        or nextGridUnit:isWaiting()
    )

    if logicFaultCondition then
        return true
    end

    if nextGridUnit:isBusy() then
        local nextTrainInstance = nextGridUnit:getSingleHoldingTrain()
        return checkTrainWillFault(grid, gridSize, nextTrainInstance, forward, forwardDirection, cache)
    end

    return false
end

function LevelManager:runLevel()
    local trains = self.levelInstance.trains
    local intermediateTimeSlice = false
    local grid = self.levelInstance.grid

    local forward = {}
    local forwardDirection = {}

    for index, train in ipairs(trains) do
        forward[train:getTrainId()] = { row = train:initForward().row, col = train:initForward().col }
        forwardDirection[train:getTrainId()] = train:initForwardDirection()
    end

    ---@return Train[]
    local function selectOperationTrains()
        local operationTrains = {}

        for index, train in ipairs(trains) do
            local selectCondition = not (
                Array.contains(self.trainSuccessArray, train)
                or Array.contains(self.trainWaitArray, train)
                or Array.contains(self.trainFaultArray, train)
            )

            if selectCondition then
                table.insert(operationTrains, train)
            end
        end

        return operationTrains
    end

    local function toggleTimeSliceHandler()
        local operationTrains = selectOperationTrains()

        for index, train in ipairs(operationTrains) do
            local currentPosition = train:getGridPosition()
            local currentGridUnit = grid[currentPosition.row][currentPosition.col]

            currentGridUnit:onLeave()
        end
        for index, train in ipairs(operationTrains) do
            local nextPosition = forward[train:getTrainId()]
            local nextGridUnit = grid[nextPosition.row][nextPosition.col]
            local enterDirection = Common.directionReverse(forwardDirection[train:getTrainId()])

            nextGridUnit:preEnter(train, enterDirection)
        end

        for index, train in ipairs(operationTrains) do
            local nextPosition = forward[train:getTrainId()]
            local nextGridUnit = grid[nextPosition.row][nextPosition.col]
            local enterDirection = Common.directionReverse(forwardDirection[train:getTrainId()])

            train:setGridPosition(nextPosition.row, nextPosition.col)
            logger:debug("Train enter gridUnit grid position: row = " ..
                nextPosition.row .. ", col = " .. nextPosition.col)

            forward[train:getTrainId()] = nextGridUnit:forward(enterDirection)
            forwardDirection[train:getTrainId()] = nextGridUnit:forwardDirection(enterDirection)

            nextGridUnit:onEnter(train)
        end
    end

    local function intermediateTimeSliceHandler()
        local beforeSignalOperationTrains = selectOperationTrains()

        for index, train in ipairs(beforeSignalOperationTrains) do
            local currentGridPosition = train:getGridPosition()
            local currentGridUnit = grid[currentGridPosition.row][currentGridPosition.col]

            currentGridUnit:preSignal()
        end

        for index, waitTrain in ipairs(self.trainWaitArray) do
            local waitingForGridPosition = forward[waitTrain:getTrainId()]
            local waitingForGridUnit = grid[waitingForGridPosition.row][waitingForGridPosition.col]

            if not waitingForGridUnit:isBlocking() then
                Array.removeElement(self.trainWaitArray, waitTrain)
            end
        end

        local afterSignalOperationTrains = selectOperationTrains()

        for index, train in ipairs(afterSignalOperationTrains) do
            local currentGridPosition = train:getGridPosition()
            local currentGridUnit = grid[currentGridPosition.row][currentGridPosition.col]

            local gridSize = {
                row = self.levelInstance.gridRowSize,
                col = self.levelInstance.gridColSize,
            }

            local trainId = train:getTrainId()

            if checkTrainWillFault(grid, gridSize, train, forward, forwardDirection, {}) then
                table.insert(self.trainFaultArray, train)
                currentGridUnit:setFault()
            else
                local nextEnterDirection = Common.directionReverse(forwardDirection[trainId])
                local nextGridPosition = currentGridUnit:forward(nextEnterDirection)
                local nextGridUnit = grid[nextGridPosition.row][nextGridPosition.col]

                if nextGridUnit:isBlocking() then
                    currentGridUnit:wait()
                else
                    currentGridUnit:onIntermediate()
                end
            end
        end
    end

    --                      ┌──┬─── toggleTimeSliceHandler()
    --                      │  │
    --
    --               ┌───────┐┌───────┐
    --               │       ││       │
    --  TRAIN ────►  │       ││       │ ────► TRAIN
    --               │   │   ││   │   │
    --               └───┼───┘└───┼───┘
    --                   │   ▲▲   ├─┐
    --                       ││   │ └─onIntermediateTimeSlice() ──┐
    --                       ││   │          2                    ├──► IntermediateTimeSliceHandler()
    --                       ││   preSignal() ────────────────────┘
    --                       ││          1
    --             onLeave() ┘└─ onEnter()
    --                3             4
    local loopTimer = FrameTimer.new(Global.GAME_GRID_LOOP_FRAME_COUNT, true)
    loopTimer:setTask(function()
        intermediateTimeSlice = not intermediateTimeSlice

        logger:debug("Current time slice type: " ..
            Common.ternary(intermediateTimeSlice, "intermediateTimeSlice", "toggleTimeSlice"))

        if intermediateTimeSlice then
            intermediateTimeSliceHandler()
        else
            toggleTimeSliceHandler()
        end
    end)

    self.gameLoopTimer = loopTimer
    loopTimer:run()
end

-- callback method =============================================================

--- Called when the carriages of the current group are fully connected
--- correctly.
---
--- This function call must have a delay compared to the last taskLoop.
--- @param groupId integer
function LevelManager:trainGroupSuccessSignal(groupId)
    table.insert(self.trainGroupSuccessArray, groupId)
    if self.levelInstance.trainGroupCount == #self.trainGroupSuccessArray then
        for index, finalRail in ipairs(self.levelInstance.finalLinkedGridUnits) do
            finalRail:launch()
        end
    end
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
---@param successTrainInstance Train
function LevelManager:trainSuccessSignal(successTrainInstance)
    table.insert(self.trainFaultArray, self.levelInstance.trains[successTrainInstance])
    if #self.trainSuccessArray == self.levelInstance.normalTrainCount then
        -- GameUI.hide
        GameUI.hideGameSceneUI()
        self.gameLoopTimer:stop()
    end
end

--- It is called when the train breaks down, including collisions, incorrect
--- connection sequences, etc.
---
--- This function is called at the same time as
--- trainSuccessSignal(successTrainId).
---@param failedTrainInstance Train
function LevelManager:trainFailedSignal(failedTrainInstance)
    if failedTrainInstance:getTrainType() == TrainTypeEnum.HINDER then
        table.insert(self.hinderTrainFinalArray, failedTrainInstance)
        logger:debug("The current failed train type is Hinder, skip the failed registration.")
        return
    end

    table.insert(self.trainFaultArray, self.levelInstance.trains[failedTrainInstance])
    if #self.trainFaultArray == self.levelInstance.normalTrainCount then
        GameUI.setGameUIRunBtnStatus(GameUIRunBtnStatusEnum.FAILURE)
        self.gameLoopTimer:stop()
    end
end

---Obtain the path mask in the four directions of the specified GridUnit.
---@param grid GridUnit[][]
---@param rowSize integer
---@param colSize integer
---@param row integer
---@param col integer
local function getGridUnitAroundChannelMask(grid, rowSize, colSize, row, col)
    local topMask = 0
    local rightMask = 0
    local bottomMask = 0
    local leftMask = 0

    if row > 1 and grid[row - 1][col]:getDirectionMask()[PositionDirectionEnum.BOTTOM] == 1 then
        topMask = 1
    end

    if row < rowSize and grid[row + 1][col]:getDirectionMask()[PositionDirectionEnum.TOP] == 1 then
        bottomMask = 1
    end

    if col > 1 and grid[row][col - 1]:getDirectionMask()[PositionDirectionEnum.RIGHT] == 1 then
        leftMask = 1
    end

    if col < colSize and grid[row][col + 1]:getDirectionMask()[PositionDirectionEnum.LEFT] == 1 then
        rightMask = 1
    end

    return { topMask, rightMask, bottomMask, leftMask }
end


---@param position Vector3
function LevelManager:click(position)
    local GAME_SCENE_CENTER_POSITION = { x = 0, y = 0, z = 0 }

    local rowSize = self.levelInstance.gridRowSize
    local colSize = self.levelInstance.gridColSize


    local posX = position.x
    local posZ = position.z

    local stdX = colSize * Global.GAME_GRID_SIZE / 2 + (posX - GAME_SCENE_CENTER_POSITION.x)

    local clickCol = math.tointeger(math.floor(stdX / Global.GAME_GRID_SIZE) + 1)
    if clickCol > colSize or clickCol < 1 then
        self.effectiveClick = false
        return
    end

    local stdZ = rowSize * Global.GAME_GRID_SIZE / 2 - (posZ - GAME_SCENE_CENTER_POSITION.z)

    local clickRow = math.tointeger(math.floor(stdZ / Global.GAME_GRID_SIZE) + 1)
    if clickRow > rowSize or clickRow < 1 then
        self.effectiveClick = false
        return
    end

    self.effectiveClick = true
    self.clickPosition = position
    self.clickGrid = { row = clickRow, col = clickCol }

    logger:debug("Player click operation, click: row = " .. clickRow ..
        ", col = " .. clickCol)

    local grid = self.levelInstance.grid

    if grid[clickRow][clickCol] ~= nil and grid[clickRow][clickCol]:isFixed() then
        logger:debug("Click grid unit is fixed, skipped.")
        return
    end

    ---@type MovableRail
    ---@diagnostic disable-next-line: assign-type-mismatch
    local targetGridUnit = grid[clickRow][clickCol]

    if self.deleteMode then
        -- create cursor
        self:changeCursor(clickRow, clickCol, CursorStatusEnum.DELETE)

        -- delete grid unit
        if targetGridUnit ~= nil then
            targetGridUnit:destroy()

            ---@diagnostic disable-next-line: need-check-nil
            grid[clickRow][clickCol] = nil

            -- Push grid unit object into operation stack.
            local operationStatus = {
                row = clickRow,
                col = clickCol,
                gridUnitRef = targetGridUnit
            }
            self.operationStack:push(operationStatus)
        end
    else
        -- create cursor
        self:changeCursor(clickRow, clickCol, CursorStatusEnum.NORMAL)
        if targetGridUnit == nil then
            ---@diagnostic disable-next-line: param-type-mismatch
            local channelMask = getGridUnitAroundChannelMask(grid, rowSize, colSize, clickRow, clickRow)




            --create logic
            -- local createdGridUnit = MovableRail.new(directionMask, chiralityMask, gridPosition, position, extraData,
            --     levelManager)
        else
            --click operation
        end
    end
end

function LevelManager:cancelClick(position)
    if self.effectiveClick == false then
        return
    end

    self.effectiveClick = false
    self:hideCursor()

    local directionVector = position - self.clickPosition
    if directionVector:length() < 5.0 then
        return
    end
end

function LevelManager:undo()

end

return LevelManager
