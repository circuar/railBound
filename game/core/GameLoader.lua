local LevelFactory           = require "game.level.LevelFactory"
local LevelLoader            = require "game.level.LevelLoader"
local CameraManager          = require "component.CameraManager"
local SceneDispatcher        = require "game.core.SceneDispatcher"
local Logger                 = require "logger.Logger"
local SceneNameEnum          = require "common.enum.SceneNameEnum"
local PlayerOperationHandler = require "game.core.PlayerOperationHandler"
local LevelManager           = require "game.level.LevelManager"
local api                    = require "api"
local Global                 = require "common.Global"
local Event                  = require "common.Event"

---@class GamerLoader
---@field private cameraManagerRef CameraManager
---@field private levelManagerRef LevelManager
local GameLoader             = {}
GameLoader.__index           = GameLoader

local logger                 = Logger.new("GameLoader")

local instance               = nil

local function constructor()
    local self = setmetatable({
        cameraManagerRef = CameraManager.instance(),
        levelManagerRef = nil
    }, GameLoader)
    return self
end

function GameLoader.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

function GameLoader:registerGameEventListener()
    -- exit game listener.
    api.base.registerEventListener(Event.EVENT_EXIT_GAME, function()
        self:exitGame()
    end)

    -- Camera zoom in.
    api.base.registerEventListener(Event.EVENT_GAME_CAMERA_ZOOM_IN, function()
        local cameraDistance = self.cameraManagerRef:getCameraDistance()
        local restrictedDist = math.max(Global.GAME_CAMERA_MIN_DISTANCE, cameraDistance - 10)
        self.cameraManagerRef:setCameraDistance(restrictedDist, 0.3)
    end)

    -- Camera zoom out
    api.base.registerEventListener(Event.EVENT_GAME_CAMERA_ZOOM_OUT, function()
        local cameraDistance = self.cameraManagerRef:getCameraDistance()
        local restrictedDist = math.min(Global.GAME_CAMERA_MAX_DISTANCE, cameraDistance + 10)
        self.cameraManagerRef:setCameraDistance(restrictedDist, 0.3)
    end)
end

--- load game environment
--- if first load gameScene, use this method to init game environment.
function GameLoader:initGame(levelId)
    -- load game scene
    SceneDispatcher:instance():dispatch(SceneNameEnum.GAME_SCENE, false)

    local levelLoader = LevelLoader.new()
    levelLoader:load("resource.levelData")
    local levelFactory = LevelFactory.new(levelLoader)

    local levelManager = LevelManager.instance()
    levelManager:setLevelFactory(levelFactory)
    local playerOperationHandler = PlayerOperationHandler.instance()
    playerOperationHandler:proxy(levelManager)
    self.levelManagerRef = levelManager

    api.setTimeout(function()
        self.cameraManagerRef:gameMode()
        levelManager:playCusSceneIn()
        levelManager:loadLevel(levelId)

        self:registerGameEventListener()
    end, Global.LOAD_UI_FADE_IN_OUT_TIME)

    api.setTimeout(function()
        levelManager:playCusSceneOut()
    end, Global.LOAD_UI_FADE_IN_OUT_TIME + 1.0)
end

function GameLoader:exitGame()
    self.levelManagerRef:unLoadLevel()
    SceneDispatcher:instance():dispatch(SceneNameEnum.LEVEL_SELECT_SCENE)
end

return GameLoader
