local GameUI           = require "component.GameUI"
local LevelFactory     = require "game.level.LevelFactory"
local LevelLoader      = require "game.level.LevelLoader"
local CameraManager    = require "component.CameraManager"
local SceneDispatcher  = require "game.core.SceneDispatcher"
local GameScene        = require "game.scene.GameScene"
local LevelSelectScene = require "game.scene.LevelSelectScene"
local Logger           = require "logger.Logger"

local GameLoader       = {}
GameLoader.__index     = GameLoader

local logger = Logger.new("GameLoader")

local levelLoader = LevelLoader.new()
levelLoader:load("resource.levelData")
local levelFactory = LevelFactory.new(levelLoader)

--- load game environment
function GameLoader.initGame(levelId)
    local levelInstance = levelFactory:getInstance(levelId)
    levelInstance:renderGridLine()
    levelInstance:renderGrid()
    GameUI.showLevelLoadUI()
    local cameraManager = CameraManager.instance()
    cameraManager:setCameraPosition()
    cameraManager:cameraMove()
end

function GameLoader.loadGame(levelId)

end

function GameLoader.exitGame()
    SceneDispatcher.dispatcher(GameScene.instance(), LevelSelectScene.instance())
end

return GameLoader
