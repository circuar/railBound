local Array = {}
Array.__index = Array

---search the first element that equals to param
---@param arr any[]
---@param elem any
---@param comparator? fun(a:any, b:any):boolean
---@return integer
function Array.find(arr, elem, comparator)
    local cmp = comparator or function (a, b)
        return a == b
    end

    for index, value in ipairs(arr) do
        if cmp(value, elem) then
            return index
        end
    end
    return -1
end


return Array