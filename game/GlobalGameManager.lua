local Logger        = require "logger.Logger"
local api           = require "api"
local Global        = require "common.Global"
local LevelSelector = require "game.core.LevelSelector"
local GameUI        = require "component.GameUI"
local Event         = require "common.Event"
local GlobalDispatcher = require "game.GlobalDispatcher"



---@class GlobalGameManager
---@field private initialized boolean whether the Game Manager is already initialized
local GlobalGameManager = {}
GlobalGameManager.__index = GlobalGameManager

local logger = Logger.new("GlobalGameManager")

local function init()
    -- do some initialize work here

    -- register exit game event
    api.base.registerEventListener(Event.EVENT_EXIT_GAME, GlobalGameManager.exit)

    -- initialized end

    GlobalGameManager.initialized = true
end


-- show load ui
function GlobalGameManager.showLoadUI(duration)
    logger:info("show load ui, duration: " .. duration)
end

function GlobalGameManager.run()
    -- boot
    logger:info("global game manager run")
    if GlobalGameManager.initialized then
        logger:warn("the Game Manager has been initialized, skipped")
    else
        init()
    end

    -- game starts showing the level selection screen by default.
    GlobalDispatcher.dispatcher(nil, LevelSelector)

end

---exit game
function GlobalGameManager.exit()
    api.base.endGame()
end

return GlobalGameManager
