local Array = {}
Array.__index = Array

---search the first element that equals to param
---@param arr any[]
---@param elem any
---@param comparator? fun(arrayElem:any, specificElem:any):boolean
---@return integer
function Array.find(arr, elem, comparator)
    local cmp = comparator or function(a, b)
        return a == b
    end

    for index, value in ipairs(arr) do
        if cmp(value, elem) then
            return index
        end
    end
    return -1
end

---Count the number of specified elements in the array.
---@param arr any[]
---@param elem any
---@return integer
function Array.countElement(arr, elem)
    local count = 0
    for index, value in ipairs(arr) do
        if value == elem then
            count = count + 1
        end
    end
    return count
end

---comment
---@param arr any[]
---@param conditionFunction fun(elem:any, index:integer, arrLength:integer):boolean
function Array.countElemByCondition(arr, conditionFunction)
    local arrLength = #arr
    local count = 0

    for index, value in ipairs(arr) do
        if conditionFunction(value, index, arrLength) then
            count = count + 1
        end
    end
    return count
end

---comment
---@param arr any
---@return table
function Array.copy(arr)
    local newArray = {}
    for index, value in ipairs(arr) do
        newArray[index] = value
    end
    return newArray
end

function Array.removeElement(arr, elem)
    local writeIndex = 1
    for readIndex = 1, #arr do
        if arr[readIndex] ~= elem then
            arr[writeIndex] = arr[readIndex]
            writeIndex = writeIndex + 1
        end
    end

    for i = writeIndex, #arr do
        arr[i] = nil
    end
end

--- Check that the elements corresponding to each index of the two arrays are
--- equal.
--- @param arr1 any[]
--- @param arr2 any[]
--- @return boolean
function Array.equals(arr1, arr2)
    if #arr1 ~= #arr2 then
        return false
    end
    for index, value in ipairs(arr1) do
        if value ~= arr2[index] then
            return false
        end
    end
    return true
end

---Check if the specified element is included in the array.
---@param arr any[]
---@param elem any
---@return boolean
function Array.contains(arr, elem)
    for index, value in ipairs(arr) do
        if value == elem then
            return true
        end
    end
    return false
end

return Array
