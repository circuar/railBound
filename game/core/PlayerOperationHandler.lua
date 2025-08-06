local Logger = require "logger.Logger"
local api    = require "api"
local Event  = require "common.Event"

---@class PlayerOperationHandler
---@field levelManager LevelManager
---@field touchStatus boolean
---@field touchPosition Vector3
local PlayerOperationHandler = {}
PlayerOperationHandler.__index = PlayerOperationHandler

local logger = Logger.new("PlayerOperationHandler")

local instance = nil

local function constructor()
    local self = setmetatable({
        levelManager = nil,
        touchStatus = false,
        touchPosition = math.Vector3(0,0,0),
    }, PlayerOperationHandler)
    return self
end

function PlayerOperationHandler.instance()
    if instance == nil then
        instance = constructor()
    end
    return instance
end

function PlayerOperationHandler:proxy(levelManager)
    self.levelManager = levelManager
    logger:info("set player operation proxy, target: " .. tostring(levelManager))
end

function PlayerOperationHandler:registerHandlers()
    api.base.registerEventListener(Event.EVENT_GAME_OPERATION_TOUCH, function (data)
        self.touchPosition = data.position
        self.touchStatus = true
    end)
    api.base.registerEventListener(Event.EVENT_GAME_OPERATION_TOUCH_RELEASE, function ()
        self.touchStatus = false
    end)
    api.base.registerEventListener(Event.EVENT_GAME_OPERATION_SLIDE, function (data)
        local angle = data.angle



    end)
end










return PlayerOperationHandler