local api = require "api"

---@class SimpleTimer
---@field interval number
---@field immediate boolean
---@field task fun():nil
---@field taskPerformCount integer
---@field stopFlag boolean
local SimpleTimer = {}
SimpleTimer.__index = SimpleTimer

---Constructor
---@param interval number
---@param immediate boolean
function SimpleTimer.new(interval, immediate)
    local self = setmetatable({
        interval = interval,
        immediate = immediate,
        task = function() end,
        taskPerformCount = 0,
        stopFlag = false
    }, SimpleTimer)
    return self
end

function SimpleTimer:setTask(task)
    self.task = task
end

function SimpleTimer:getIntervalFrame()
    return self.interval
end

function SimpleTimer:isImmediate()
    return self.immediate
end

function SimpleTimer:run()
    local function taskWrapper()
        if self.stopFlag then
            return
        end
        self.task()
        self.taskPerformCount = self.taskPerformCount + 1
        api.setTimeout(taskWrapper, self.interval)
    end

    if self.immediate then
        taskWrapper()
    else
        api.setTimeout(taskWrapper, self.interval)
    end
end

function SimpleTimer:stop()
    self.stopFlag = true
end

function SimpleTimer:isStop()
    return self.stopFlag
end

return SimpleTimer
