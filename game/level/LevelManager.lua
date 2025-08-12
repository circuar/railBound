local OperationStack   = require "game.core.OperationStack"
local GameUI           = require "component.GameUI"
local Logger           = require "logger.Logger"
local CameraManager    = require "component.CameraManager"
local Global           = require "common.Global"
local api              = require "api"
local GameResource     = require "common.GameResource"
local CursorStatusEnum = require "common.enum.CursorStatusEnum"
local Array            = require "util.Array"
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
local LevelManager     = {}
LevelManager.__index   = LevelManager

local logger           = Logger.new("LevelManager")

local instance         = nil


local function constructor()
    local createCursorEntity = api.base.createEntity(GameResource.GAME_GRID_CREATE_CURSOR_ENTITY_ID,
        math.Vector3(0, -50, 0), math.Quaternion(0, 0, 0), math.Vector3(1, 1, 1))
    local deleteCursorEntity = api.base.createEntity(GameResource.GAME_GRID_DELETE_CURSOR_ENTITY_ID,
        math.Vector3(0, -50, 0), math.Quaternion(0, 0, 0), math.Vector3(1, 1, 1))
    local alterCursorEntity = api.base.createEntity(GameResource.GAME_GRID_ALTER_CURSOR_ENTITY_ID,
        math.Vector3(0, -50, 0), math.Quaternion(0, 0, 0), math.Vector3(1, 1, 1))
    local self = setmetatable({
        levelFactory = nil,
        levelInstance = nil,
        cursorEntity = {
            [CursorStatusEnum.CREATE] = createCursorEntity,
            [CursorStatusEnum.DELETE] = deleteCursorEntity,
            [CursorStatusEnum.ALTER] = alterCursorEntity
        },
        currentLevelGridSize = {},
        effectiveClick = false,
        clickPosition = nil,
        clickGrid = {},
        operationStack = OperationStack.new(),
        deleteMode = false
    }, LevelManager)
    return self
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

function LevelManager.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

function LevelManager:setLevelFactory(levelFactory)
    self.levelFactory = levelFactory
end

function LevelManager:loadLevel(level)
    if self.levelFactory == nil then
        logger:error("level factory not set")
    end
    local levelInstance = self.levelFactory:getInstance(level)

    -- Set the levelManager for the level instance, used for game state
    -- communication.
    levelInstance:setLevelManager(self)

    self.levelInstance = levelInstance
    self.currentLevelGridSize = levelInstance:getGridSize()
end

function LevelManager:render()
    self.levelInstance:renderGridLine()
    self.levelInstance:renderFilter()
    self.levelInstance:renderSceneBackground()
    self.levelInstance:renderGridUnit()
end

function LevelManager:playCutScenesIn()
    local cameraManager = CameraManager.instance()
    local cameraMoveVelocity = math.Vector3(0.8660, 0, 0.5000) * 10.0
    local cameraMoveDistance = 10.0
    local cameraMoveDuration = cameraMoveDistance / cameraMoveVelocity:length()
    cameraManager:cameraMove(cameraMoveVelocity, cameraMoveDuration)
    api.setTimeout(function()
        GameUI.showLevelSwitchOutAnim()
    end, cameraMoveDuration - Global.LEVEL_SWITCH_ANIM_IN_OUT_DURATION)
end

function LevelManager:playCutScenesOut()
    local cameraManager = CameraManager.instance()
    local cameraMoveVelocity = math.Vector3(0.8660, 0, 0.5000) * 10.0
    local cameraMoveDistance = 10.0
    local cameraMoveDuration = cameraMoveDistance / cameraMoveVelocity:length()

    --- initial camera position
    cameraManager:setCameraPosition(Global.GAME_CAMERA_CENTER_REFERENCE_POINT - cameraMoveVelocity * cameraMoveDuration)

    cameraManager:cameraMove(cameraMoveVelocity, cameraMoveDuration)
    GameUI.showLevelSwitchInAnim()
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

local function putUnitGridRail(grid, row, col)
    local gridUnitRef = grid[row][col]
    if gridUnitRef ~= nil then
        logger:error("This grid unit slot already has a object.")
        error()
    end
    
end


---comment
---@param grid GridUnit[][]
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
-- callback method =============================================================
function LevelManager:unLoad()
    self.levelInstance = nil
    self.currentLevelGridSize = nil
end

function LevelManager:levelSuccess(successGroupIndex)

end

function LevelManager:levelFailed(failedTrainId)

end

---
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
        local clickGridUnitRef = self.levelInstance:getGrid()[clickRow][clickCol]
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
