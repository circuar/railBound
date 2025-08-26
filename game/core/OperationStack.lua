---@class OperationStack
local OperationStack = {}
OperationStack.__index = OperationStack

function OperationStack.new()
    local self = setmetatable({
        stack = {},
        stackPointer = 0,
    }, OperationStack)
    return self
end

function OperationStack:push(e)
    table.insert(self.stack, e)
    self.stackPointer = self.stackPointer + 1
end

function OperationStack:pop()
    if self.stackPointer == 0 then
        return nil
    end

    local elem        = table.remove(self.stack, self.stackPointer)
    self.stackPointer = self.stackPointer - 1
    return elem
end

function OperationStack:isEmpty()
    return self.stackPointer == 0
end

function OperationStack:clear()
    self.stackPointer = 0
    self.stack = {}
end

return OperationStack
