local Logger                   = require "logger.Logger"
local api                      = require "api"
local Event                    = require "common.Event"
local PositionDirectionEnum    = require "common.enum.PositionDirectionEnum"

---@class PlayerOperationHandler
---@field levelManager LevelManager
local PlayerOperationHandler   = {}
PlayerOperationHandler.__index = PlayerOperationHandler

local logger                   = Logger.new("PlayerOperationHandler")

local instance                 = nil

local function constructor()
    local self = setmetatable({
        levelManager = nil,
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
        local position = data.position
        logger:debug("Player game operation: click, position = " .. tostring(position))
        self.levelManager:click(position)
    end)
    api.base.registerDataEventListener(Event.EVENT_GAME_OPERATION_TOUCH_RELEASE, function(name, unit, data)
        local position = data.position
        logger:debug("Player game operation: click release, position = " .. tostring(position))
        self.levelManager:cancelClick(position)
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
    -- api.base.registerDataEventListener(Event.EVENT_GAME_SLIDE_OPERATION, function(name, unit, data)
    --     local angle = data.angle

    --     logger:debug("Player game operation: slide, angle = " .. angle)

    --     if angle > 30 and angle <= 120 then
    --         self.levelManager:slide(PositionDirectionEnum.TOP)
    --     elseif angle > 120 and angle <= 210 then
    --         self.levelManager:slide(PositionDirectionEnum.LEFT)
    --     elseif angle > 210 and angle <= 300 then
    --         self.levelManager:slide(PositionDirectionEnum.BOTTOM)
    --     else
    --         self.levelManager:slide(PositionDirectionEnum.RIGHT)
    --     end
    -- end)
end

return PlayerOperationHandler
