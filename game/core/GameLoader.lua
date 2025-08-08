local LevelFactory           = require "game.level.LevelFactory"
local LevelLoader            = require "game.level.LevelLoader"
local CameraManager          = require "component.CameraManager"
local SceneDispatcher        = require "game.core.SceneDispatcher"
local Logger                 = require "logger.Logger"
local SceneNameEnum          = require "common.enum.SceneNameEnum"
local PlayerOperationHandler = require "game.core.PlayerOperationHandler"
local LevelManager           = require "game.level.LevelManager"

local GameLoader             = {}
GameLoader.__index           = GameLoader

local logger                 = Logger.new("GameLoader")

local instance               = nil

local function constructor()
    local levelLoader = LevelLoader.new()
    levelLoader:load("resource.levelData")
    local self = setmetatable({
        levelManager           = LevelManager.instance(),
        playerOperationHandler = PlayerOperationHandler.instance(),
        levelFactory           = LevelFactory.new(levelLoader),
    }, GameLoader)
    self.playerOperationHandler:proxy(self.levelManager)
    return self
end

function GameLoader.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

--- load game environment
function GameLoader:initGame(levelId)
    SceneDispatcher:instance():dispatch(SceneNameEnum.GAME_SCENE)
    GameLoader.loadGame(levelId)
end

function GameLoader:loadGame(levelId)
    local levelLoader = LevelLoader.new()
    levelLoader:load("resource.levelData")

    local levelFactory = LevelFactory.new(levelLoader)
    local levelInstance = levelFactory:getInstance(levelId)

    GameLoader.levelManager:loadLevel(levelInstance)

    local cameraManager = CameraManager.instance()
    cameraManager:setCameraPosition()
    cameraManager:cameraMove()
end

function GameLoader:exitGame()
    self.levelManager:unLoad()
    SceneDispatcher:instance():dispatch(SceneNameEnum.LEVEL_SELECT_SCENE)
end

return GameLoader
