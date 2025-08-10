local OperationStack = require "game.core.OperationStack"
local GameUI         = require "component.GameUI"
local Logger         = require "logger.Logger"
local CameraManager  = require "component.CameraManager"
local Global         = require "common.Global"
local api            = require "api"
---@class LevelManager
---@field levelFactory LevelFactory
---@field levelInstance Level
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
    self.levelInstance = self.levelFactory:getInstance(level)
end

function LevelManager:renderLevel()
    
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



function LevelManager:unLoad()
    self.levelInstance = nil
end

return LevelManager
