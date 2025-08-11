local UnitTest = {}
UnitTest.__index = UnitTest

-- constructor
function UnitTest.new()
    return setmetatable({ testCount = 0, passed = 0, failed = {} }, UnitTest)
end

function UnitTest:assertEqual(expected, actual, message)
    self.testCount = self.testCount + 1
    if expected ~= actual then
        table.insert(self.failed, string.format(
            "FAIL: %s\n\tExpected: %s\n\tActual: %s",
            message or "Assertion failed",
            tostring(expected),
            tostring(actual)
        ))
        return false
    end
    self.passed = self.passed + 1
    return true
end

function UnitTest:assertNotEqual(unexpected, actual, message)
    self.testCount = self.testCount + 1
    if unexpected == actual then
        table.insert(self.failed, string.format(
            "FAIL: %s\n\tShould not be: %s",
            message or "Assertion failed",
            tostring(unexpected))
        )
        return false
    end
    self.passed = self.passed + 1
    return true
end

function UnitTest:assertTrue(condition, message)
    self.testCount = self.testCount + 1
    if not condition then
        table.insert(self.failed, "FAIL: " .. (message or "Expected true"))
        return false
    end
    self.passed = self.passed + 1
    return true
end

function UnitTest:assertFalse(condition, message)
    return self:assertTrue(not condition, message or "Expected false")
end

function UnitTest:assertNil(value, message)
    self.testCount = self.testCount + 1
    if value ~= nil then
        table.insert(self.failed, string.format(
            "FAIL: %s\n\tExpected nil, got: %s",
            message or "Assertion failed",
            type(value))
        )
        return false
    end
    self.passed = self.passed + 1
    return true
end

function UnitTest:assertNotNil(value, message)
    self.testCount = self.testCount + 1
    if value == nil then
        table.insert(self.failed, "FAIL: " .. (message or "Expected non-nil value"))
        return false
    end
    self.passed = self.passed + 1
    return true
end

function UnitTest:assertError(func, ...)
    self.testCount = self.testCount + 1
    local success, _ = pcall(func, ...)
    if success then
        table.insert(self.failed, "FAIL: Expected error but none occurred")
        return false
    end
    self.passed = self.passed + 1
    return true
end

function UnitTest:assertNoError(func, ...)
    self.testCount = self.testCount + 1
    local success, err = pcall(func, ...)
    if not success then
        table.insert(self.failed, "FAIL: Unexpected error: " .. tostring(err))
        return false
    end
    self.passed = self.passed + 1
    return true
end

function UnitTest:printSummary()
    print(string.format("\n===== Test Results ====="))
    print(string.format("Tests run: %d", self.testCount))
    print(string.format("Passed: %d", self.passed))
    print(string.format("Failed: %d", #self.failed))

    if #self.failed > 0 then
        print("\nFailure Details:")
        for i, msg in ipairs(self.failed) do
            print(string.format("%d. %s", i, msg))
        end
    end
    print("========================")
end

return UnitTest
