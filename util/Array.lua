local Array = {}
Array.__index = Array

function Array.find(arr, elem)
    for index, value in ipairs(arr) do
        if value == elem then
            return index
        end
    end
    return -1
end

return Array