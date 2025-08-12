local OperationStack = require "game.core.OperationStack"
local GameUI         = require "component.GameUI"
local Logger         = require "logger.Logger"
local CameraManager  = require "component.CameraManager"
local Global         = require "common.Global"
local api            = require "api"
---@class LevelManager
---@field levelFactory LevelFactory
---@field levelInstance Level
---@field currentLevelGridSize integer[]
local LevelManager   = {}
LevelManager.__index = LevelManager

local logger         = Logger.new("LevelManager")

local instance       = nil


local function constructor()
    local self = setmetatable({
        levelInstance = nil,
        levelFactory = nil,
        operationStack = OperationStack.new(),
    }, LevelManager)
    return self
end

local function renderCursor(row, col, status)
    
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

-- callback method =============================================================
function LevelManager:unLoad()
    self.levelInstance = nil
    self.currentLevelGridSize = nil
end

function LevelManager:levelSuccess(successGroupIndex)

end

function LevelManager:levelFailed(failedTrainId)

end

function LevelManager:click(position)

end

function LevelManager:slide(angle)
    
end

return LevelManager
