local Logger        = require "logger.Logger"
local api           = require "api"
local Event         = require "common.Event"
local SceneDispatcher  = require "game.core.SceneDispatcher"
local SceneNameEnum    = require "common.enum.SceneNameEnum"
local LevelSelectScene = require "game.scene.LevelSelectScene"
local GameScene        = require "game.scene.GameScene"

---@class GlobalGameManager
---@field private initialized boolean whether the Game Manager is already initialized
local GlobalGameManager = {}
GlobalGameManager.__index = GlobalGameManager

local logger = Logger.new("GlobalGameManager")

local function init()
    -- do some initialize work here

    -- register exit game event
    api.base.registerEventListener(Event.EVENT_EXIT, GlobalGameManager.exit)

    -- initialize sceneDispatcher
    local sceneDispatcher = SceneDispatcher.instance()
    sceneDispatcher:registerScene(SceneNameEnum.LEVEL_SELECT_SCENE, LevelSelectScene.instance())
    sceneDispatcher:registerScene(SceneNameEnum.GAME_SCENE, GameScene.instance())

    -- initialized end

    GlobalGameManager.initialized = true
end

---run game
function GlobalGameManager.run()
    -- boot
    logger:info("global game manager run")
    if GlobalGameManager.initialized then
        logger:warn("the Game Manager has been initialized, skipped")
        return
    end

    init()
    -- game starts showing the level select screen by default.
    local sceneDispatcher = SceneDispatcher.instance()
    sceneDispatcher:dispatch(SceneNameEnum.LEVEL_SELECT_SCENE, false)
end

---exit game
function GlobalGameManager.exit()
    api.base.endGame()
end

return GlobalGameManager
