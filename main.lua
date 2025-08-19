-- main.lua

local Logger            = require "logger.Logger"
local GlobalGameManager = require "game.GlobalGameManager"
local LogLevel          = require "logger.LogLevel"
local api               = require "api"
local Train             = require "game.object.Train"

Logger.setGlobalLogLevel(LogLevel.DEBUG)

local logger = Logger.new("main")
logger:info("start ...")

-- GlobalGameManager.run()

local train = Train.new({
    trainId = 1,
    sequenceId = 1,
    trainType = "NORMAL",
    trainGroup = 1,
    gridPosition = { row = 1, col = 1 },
    directionMask = { 0, 1, 0, 0 }
}, math.Vector3(-22, 2, -345))
train:render()
local position = math.Vector3(-22, 2, -345)
api.setTimeout(function()
    local timer = require "game.core.FrameTimer".new(15, true)
    timer:setTask(function()
        train:straight(position, 2, { row = 1, col = 2 })
        position = position + math.Vector3(10, 0, 0)
    end)
    timer:run()
end, 5.0)





for index, value in pairs(train.entities) do
    print(value.get_children())
    for i, v in ipairs(value.get_children()[1].get_children()) do
        print(v)
    end
end
