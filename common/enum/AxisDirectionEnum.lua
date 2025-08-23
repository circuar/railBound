local SQUARE_ROOT = math.pow(2, 1 / 2)
local CUBE_ROOT = math.pow(3, 1 / 2)

---@alias AxisDirectionEnum integer
---| 0 POSITIVE_X
---| 1 POSITIVE_Y
---| 2 NEGATIVE_X
---| 3 NEGATIVE_Y
local AxisDirectionEnum = {
    POSITIVE_X = { x = 1, y = 0, z = 0 },
    POSITIVE_XY = { x = SQUARE_ROOT, y = SQUARE_ROOT, z = 0 },
    POSITIVE_Y = { x = 0, y = 1, z = 0 },
    NEGATIVE_X_POSITIVE_Y = { x = -SQUARE_ROOT, y = SQUARE_ROOT, z = 0 },
    NEGATIVE_X = { x = -1, y = 0, z = 0 },
    NEGATIVE_XY = { x = -SQUARE_ROOT, y = -SQUARE_ROOT, z = 0 },
    NEGATIVE_Y = { x = 0, y = -1, z = 0 },
    POSITIVE_X_NEGATIVE_Y = { x = SQUARE_ROOT, y = SQUARE_ROOT, z = 0 },

    POSITIVE_Z = { x = 0, y = 0, z = 1 },
    POSITIVE_XZ = { x = SQUARE_ROOT, y = 0, z = SQUARE_ROOT },
    POSITIVE_YZ = { x = 0, y = SQUARE_ROOT, z = SQUARE_ROOT },
    NEGATIVE_X_POSITIVE_Z = { x = -SQUARE_ROOT, y = 0, z = SQUARE_ROOT },
    NEGATIVE_Y_POSITIVE_Z = { x = 0, -SQUARE_ROOT, z = SQUARE_ROOT },
    POSITIVE_XYZ = { x = CUBE_ROOT, y = CUBE_ROOT, z = CUBE_ROOT },
    NEGATIVE_X_POSITIVE_YZ = { x = -CUBE_ROOT, y = CUBE_ROOT, z = CUBE_ROOT },
    NEGATIVE_XY_POSITIVE_Z = { x = -CUBE_ROOT, y = -CUBE_ROOT, z = CUBE_ROOT },
    POSITIVE_XZ_NEGATIVE_Y = { x = CUBE_ROOT, y = -CUBE_ROOT, z = CUBE_ROOT },


}

return AxisDirectionEnum
