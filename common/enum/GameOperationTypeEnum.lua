---@alias GameOperationTypeEnum integer
---| 1 CREATE
---| 2 DELETE
---| 3 ALTER
local GameOperationTypeEnum = {
    CREATE = 1,
    DELETE = 2,
    ALTER = 3
}

return GameOperationTypeEnum