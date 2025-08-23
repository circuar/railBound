local OperationStack         = require "game.core.OperationStack"
local GameUI                 = require "component.GameUI"
local Logger                 = require "logger.Logger"
local CameraManager          = require "component.CameraManager"
local Global                 = require "common.Global"
local api                    = require "api"
local GameResource           = require "common.GameResource"
local CursorStatusEnum       = require "common.enum.CursorStatusEnum"
local Array                  = require "util.Array"
local GridUnitFactory        = require "game.level.GridUnitFactory"
local GridUnitClassEnum      = require "common.enum.GridUnitClassEnum"
local Train                  = require "game.object.Train"
local PositionDirectionEnum  = require "common.enum.PositionDirectionEnum"
local Common                 = require "util.Common"
local FrameTimer             = require "game.core.FrameTimer"
local LevelMetaDataManager   = require "game.level.LevelMetaDataManager"
local GameUIRunBtnStatusEnum = require "common.enum.GameUIRunBtnStatusEnum"
local TrainTypeEnum          = require "common.enum.TrainTypeEnum"


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
local LevelManager   = {}
LevelManager.__index = LevelManager

local logger         = Logger.new("LevelManager")

local instance       = nil

-- local function createUnitGridRail(grid, row, col, centerPosition)
--     local gridUnitRef = grid[row][col]
--     if gridUnitRef ~= nil then
--         logger:error("This grid unit slot already has a object.")
--         error()
--     end
--     local gridUnit = GridUnitFactory.getInstance(
--         GridUnitClassEnum.RAIL_MOVABLE,
--         { 0, 1, 0, 1 },
--         1,
--         centerPosition
--     )
--     grid[row][col] = gridUnit
--     return gridUnit
-- end


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
    local nextGridUnit = grid[nextPosition.row][nextPosition.col]

    local faultCondition = (
        nextPosition.row < 1
        or nextPosition.row > gridSize.row
        or nextPosition.col < 1
        or nextPosition.row > gridSize.col

        or nextGridUnit == nil
        or not nextGridUnit:checkEnterPermit(
            Common.directionReverse(forwardDirection[train:getTrainId()])
        )
        or nextGridUnit:isFault()
        or nextGridUnit:isWaiting()
    )

    if faultCondition then
        return true
    end

    if nextGridUnit:isBusy() then
        local nextTrainInstance = nextGridUnit:getSingleHoldingTrain()
        return checkTrainWillFault(grid, gridSize, nextTrainInstance, forward, forwardDirection, cache)
    end

    return false
end


-- function LevelManager:runLevel()
--     -- 重复运行校验：
--     if self.levelRunning then
--         logger:error("Level already running, repeated triggering.")
--         error()
--     end
--     self.levelRunning = true

--     local trains = self.levelInstance.trains
--     local grid = self.levelInstance.grid
--     local forward = {}
--     local forwardDirection = {}

--     -- 初始化 WartArray：
--     for index, train in ipairs(trains) do
--         table.insert(self.trainWaitArray, train)
--     end

--     -- train 初始化逻辑
--     for index, train in ipairs(trains) do
--         -- Get train init next grid position and direction of leave the init
--         -- grid unit.
--         --
--         -- ┌─ ─┐┌─ ─┐┌─
--         -- │ I ││   ││
--         -- └─ ─┘└─ ─┘└─
--         --   ▲    ▲
--         --   │    │
--         -- init   │
--         --     initForward
--         local nextPosition = train:initForward()
--         local initLeaveDirection = train:initForwardDirection()
--         local trainId = train:getTrainId()

--         forward[trainId] = nextPosition
--         forwardDirection[trainId] = initLeaveDirection

--         -- 在初始时，Train实例全部处于等待状态，需要判断是否能够恢复正常运行状态
--         --
--         -- 首先要保证Train的下一个网格单元不是边界条件，如果是边界条件，触发
--         -- Train实例的initBoundFault()
--         local resumeCondition = (
--             grid[nextPosition.row][nextPosition.col] == nil
--             or not grid[nextPosition.row][nextPosition.col]:isBlocking()
--         )

--         if resumeCondition then
--             local currentPosition = train:getGridPosition()
--             local currentRow      = currentPosition.row
--             local currentCol      = currentPosition.col
--             grid[currentRow][currentCol]:resume()
--         end
--     end

--     local loopTimer = FrameTimer.new(Global.GAME_GRID_LOOP_FRAME_COUNT, true)
--     self.gameLoopTimer = loopTimer

--     loopTimer:setTask(function()
--         ---@type Train[]
--         local loopOperationTrains = {}

--         for index, train in ipairs(trains) do
--             local selectCondition = not (
--                 Array.contains(self.trainWaitArray, train)
--                 or Array.contains(self.trainFaultArray, train)
--                 or Array.contains(self.trainSuccessArray, train)
--             )
--             if selectCondition then
--                 local currentPosition = train:getGridPosition()
--                 local gridSize = {
--                     row = self.levelInstance.gridRowSize,
--                     col = self.levelInstance.gridColSize,
--                 }

--                 if checkTrainWillFault(self.levelInstance.grid, gridSize, train, forward, forwardDirection, {}) then
--                     train:fault()
--                     grid[currentPosition.row][currentPosition.col]:setFault()
--                     self:trainFailedSignal(train)
--                 else
--                     table.insert(loopOperationTrains, train)
--                     grid[currentPosition.row][currentPosition.col]:onLeave(train)
--                 end
--             end
--         end

--         ---@type GridUnit[]
--         local updateGridUnitList = {}

--         for index, train in ipairs(loopOperationTrains) do
--             local trainId = train:getTrainId()
--             local currentLeaveDirection = forwardDirection[trainId]

--             local nextPos = forward[trainId]
--             local nextGridUnit = grid[nextPos.row][nextPos.col]
--             local nextLeaveDirection = nextGridUnit:forwardDirection(
--                 Common.directionReverse(currentLeaveDirection)
--             )

--             local forwardPos = nextGridUnit:forward(
--                 Common.directionReverse(currentLeaveDirection)
--             )
--             local forwardGridUnit = grid[forwardPos.row][forwardPos.col]

--             forwardDirection[trainId] = nextLeaveDirection
--             forward[trainId] = forwardPos

--             if forwardGridUnit ~= nil and forwardGridUnit:supportsBlockSignal() then
--                 forwardGridUnit:addBlockAffectedGridUnit(nextGridUnit)

--                 if forwardGridUnit:isBlocking() then
--                     if not Array.contains(updateGridUnitList, nextGridUnit) then
--                         table.insert(updateGridUnitList, nextGridUnit)
--                     end
--                 end

--                 nextGridUnit:wait(train)
--             else
--                 nextGridUnit:onEnter(train)

--                 if not Array.contains(updateGridUnitList, nextGridUnit) then
--                     table.insert(updateGridUnitList, nextGridUnit)
--                 end
--             end
--         end

--         for i, gridUnit in ipairs(updateGridUnitList) do
--             gridUnit:update()
--         end
--     end)

--     api.setTimeout(function()
--         loopTimer:run()
--     end, Train.getInitForwardDuration())
-- end

function LevelManager:runLevel()
    local trains = self.levelInstance.trains
    local intermediateTimeSlice = false
    local grid = self.levelInstance.grid

    local forward = {}
    local forwardDirection = {}

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

            forward[train:getTrainId()] = nextGridUnit:forward(enterDirection)
            forwardDirection[train:getTrainId()] = nextGridUnit:forwardDirection(enterDirection)

            nextGridUnit:preEnter(train)
        end

        for index, train in ipairs(operationTrains) do
            local nextPosition = forward[train:getTrainId()]
            local nextGridUnit = grid[nextPosition.row][nextPosition.col]
            local enterDirection = Common.directionReverse(forwardDirection[train:getTrainId()])

            nextGridUnit:onEnter(train, enterDirection)
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
                    currentGridPosition:onIntermediateTimeSlice(train)
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

---comment
---@param waitTrainInstance Train
function LevelManager:trainWaitSignal(waitTrainInstance)
    table.insert(self.trainWaitArray, waitTrainInstance)
end

---
---@param resumeTrainIdInstance Train
function LevelManager:trainResumeSignal(resumeTrainIdInstance)
    Array.removeElement(self.trainWaitArray, resumeTrainIdInstance)
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

    logger:debug("Player click operation, click: row = " .. clickRow ..
        ", col = " .. clickCol)

    local grid = self.levelInstance.grid

    if grid[clickRow][clickRow] ~= nil and grid[clickRow][clickRow]:isFixed() then
        logger:debug("Click grid unit is fixed, skipped.")
        return
    end

    ---@type MovableRail
    ---@diagnostic disable-next-line: assign-type-mismatch
    local targetGridUnit = grid[clickRow][clickRow]

    if self.deleteMode then
        -- create cursor
        self:changeCursor(clickRow, clickCol, CursorStatusEnum.DELETE)

        -- delete grid unit
        if targetGridUnit ~= nil then
            targetGridUnit:destroy()
            grid[clickRow][clickCol] = nil
        end
    else
        -- create cursor
        self:changeCursor(clickRow, clickCol, CursorStatusEnum.CREATE)
        if targetGridUnit == nil then
            --create logic
        else
            targetGridUnit:mirror()
        end
    end
end

function LevelManager:undo()

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
    self.effectiveClick = false
    self:hideCursor()
end

return LevelManager
