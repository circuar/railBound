local api = require "api"

---@class FrameTimer
---@field intervalFrame integer
---@field immediate boolean
---@field task fun():nil
---@field taskPerformCount integer
---@field stopFlag boolean
local FrameTimer = {}
FrameTimer.__index = FrameTimer

---Constructor
---@param intervalFrame number
---@param immediate boolean
function FrameTimer.new(intervalFrame, immediate)
    local self = setmetatable({
        intervalFrame = intervalFrame,
        immediate = immediate,
        task = function() end,
        taskPerformCount = 0,
        stopFlag = false
    }, FrameTimer)
    return self
end

function FrameTimer:setTask(task)
    self.task = task
end

function FrameTimer:getIntervalFrame()
    return self.intervalFrame
end

function FrameTimer:isImmediate()
    return self.immediate
end

function FrameTimer:run()
    local function taskWrapper()
        if self.stopFlag then
            return
        end
        self.task()
        self.taskPerformCount = self.taskPerformCount + 1
        api.setTimeout(taskWrapper, self.intervalFrame, true)
    end

    if self.immediate then
        taskWrapper()
    else
        api.setTimeout(taskWrapper, self.intervalFrame, true)
    end
end

function FrameTimer:stop()
    self.stopFlag = true
end

function FrameTimer:isStop()
    return self.stopFlag
end

return FrameTimer
