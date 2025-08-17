local Logger                   = require "logger.Logger"
local api                      = require "api"
local Event                    = require "common.Event"

---@class PlayerOperationHandler
---@field levelManager LevelManager
---@field touchStatus boolean
---@field touchPosition Vector3
local PlayerOperationHandler   = {}
PlayerOperationHandler.__index = PlayerOperationHandler

local logger                   = Logger.new("PlayerOperationHandler")

local instance                 = nil

local function constructor()
    local self = setmetatable({
        levelManager = nil,
        touchStatus = false,
        touchPosition = math.Vector3(0, 0, 0),
    }, PlayerOperationHandler)
    self:registerHandlers()
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
    api.base.registerDataEventListener(Event.EVENT_GAME_OPERATION_TOUCH, function(name, unit, data)
        self.touchPosition = data.position
        self.touchStatus = true
    end)
    api.base.registerDataEventListener(Event.EVENT_GAME_OPERATION_TOUCH_RELEASE, function(name, unit, data)
        self.touchStatus = false
    end)

    --[[
    slide handler
     --> gridX
    |         y(global: z)
    v gridY   ^
              |
      --------|-------> x
              |
              |
    y+:
    --]]
    api.base.registerDataEventListener(Event.EVENT_GAME_OPERATION_SLIDE, function(name, unit, data)
        local angle = data.angle
        if angle > 45 and angle <= 135 then

        elseif angle > 135 and angle <= 225 then

        elseif angle > 225 and angle <= 315 then

        else

        end
    end)
end

return PlayerOperationHandler
