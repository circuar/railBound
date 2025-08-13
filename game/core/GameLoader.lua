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

local GameLoader             = {}
GameLoader.__index           = GameLoader

local logger                 = Logger.new("GameLoader")

local instance               = nil

local function constructor()
    local self = setmetatable({}, GameLoader)
    return self
end

function GameLoader.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
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

    api.setTimeout(function()
        CameraManager:gameMode()
        levelManager:playCutScenesIn()
        levelManager:loadLevel(levelId)
    end, Global.LOAD_UI_FADE_IN_OUT_TIME)

    api.setTimeout(function()
        levelManager:playCutScenesOut()
    end, Global.LOAD_UI_FADE_IN_OUT_TIME + 1.0)
end

function GameLoader:exitGame()
    self.levelManager:unLoad()
    SceneDispatcher:instance():dispatch(SceneNameEnum.LEVEL_SELECT_SCENE)
end

return GameLoader
