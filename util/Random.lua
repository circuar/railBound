-- Random.lua

-- 实现说明：
--  - 使用 splitmix64 对输入 seed 进行扩展以初始化 4x64-bit 状态
--  - 核心算法为 xoshiro256++：输出 = rol64(s0 + s3, 23) + s0
--  - 状态转移遵循官方实现（左移/异或/旋转）
--  - 提供 jump/longJump 常量（来自 xoshiro 作者），用于并行子序列

local Random = {}
Random.__index = Random

-- 64-bit mask（用于截断到 64-bit）
local UINT64_MAX = 0xFFFFFFFFFFFFFFFF 

-- Ensure we have a mask constant as number (Lua 5.3 integer)
-- If the above didn't produce a numeric value (some Lua interpreters), construct via arithmetic:
if type(UINT64_MAX) ~= "number" then
    -- 2^64 - 1
    UINT64_MAX = (2 ^ 32 - 1) * (2 ^ 32) + (2 ^ 32 - 1)
end

-- Helper: force to unsigned 64-bit (masking)
local function toUint64(x)
    -- bit-and with mask. Works for negative signed ints too (bitwise treat as two's complement).
    return x & UINT64_MAX
end

-- rotate-left for 64-bit
local function rol64(x, r)
    r = r % 64
    if r == 0 then return toUint64(x) end
    -- (x << r) | (x >> (64 - r))
    return toUint64(((x << r) | (x >> (64 - r))))
end

-- splitmix64 for seeding (from Sebastiano Vigna)
-- constants: increment = 0x9E3779B97F4A7C15
local function makeSplitMix64(seed)
    local state = toUint64(seed)
    return function()
        state = toUint64(state + 0x9E3779B97F4A7C15)
        local z = state
        z = toUint64((z ~ (z >> 30)) * (0xBF58476D1CE4E5B))
        z = toUint64((z ~ (z >> 27)) * (0x94D049BB133111EB))
        z = toUint64(z ~ (z >> 31))
        return z
    end
end

-- xoshiro256++ core next() — 返回 64-bit unsigned result 并推进状态
local function xoshiro256plusplusNext(state)
    -- state: table {s0, s1, s2, s3} (each uint64)
    local s0 = state[1]
    local s1 = state[2]
    local s2 = state[3]
    local s3 = state[4]

    local result = toUint64(rol64(toUint64(s0 + s3), 23) + s0)

    local t = toUint64(s1 << 17)

    s2 = toUint64(s2 ~ s0)
    s3 = toUint64(s3 ~ s1)
    s1 = toUint64(s1 ~ s2)
    s0 = toUint64(s0 ~ s3)

    s2 = toUint64(s2 ~ t)
    s3 = rol64(s3, 45)

    state[1] = s0
    state[2] = s1
    state[3] = s2
    state[4] = s3

    return result
end

-- jump / longJump constants for xoshiro256++ (官方给定)
local JUMP = {
    0x180ec6d33cfd0aba,
    0xd5a61266f0c9392c,
    0xa9582618e03fc9aa,
    0x39abdc4529b1661c
}
local LONG_JUMP = {
    0x76e15d3efefdcbbf,
    0xc5004e441c522fb3,
    0x77710069854ee241,
    0x39109bb02acbe635
}

-- Constructor
--- 创建并返回一个 Random 实例
-- @param seed 可选：任意整数种子。如果不传，会用 os.time() 与 math.random() 混合生成种子（非安全但实用）
-- @return Random 实例（使用 : 方法调用）
function Random.new(seed)
    local self = setmetatable({}, Random)

    if seed == nil then
        -- 尝试生成一个不易重复的 64-bit 种子（注意：非安全）
        -- 使用 os.time() 与 math.random() 的混合，然后扩展/混淆
        local t = os.time()
        local r = math.random() * 2 ^ 31
        seed = toUint64((t * 1000003) ~ math.floor(r))
    end
    seed = toUint64(seed)

    local sm = makeSplitMix64(seed)
    local s = { sm(), sm(), sm(), sm() }

    -- 防止全 0 状态（xoshiro 的坏态）
    if s[1] == 0 and s[2] == 0 and s[3] == 0 and s[4] == 0 then
        s[1] = 0x9E3779B97F4A7C15
        s[2] = 0x243F6A8885A308D3
        s[3] = 0x13198A2E03707344
        s[4] = 0xA4093822299F31D0
    end

    self._state = s
    return self
end

--- 使用指定 seed 重置 RNG（接受整数）
function Random:setSeed(seed)
    seed = toUint64(seed)
    local sm = makeSplitMix64(seed)
    local s = { sm(), sm(), sm(), sm() }
    if s[1] == 0 and s[2] == 0 and s[3] == 0 and s[4] == 0 then
        s[1] = 0x9E3779B97F4A7C15
        s[2] = 0x243F6A8885A308D3
        s[3] = 0x13198A2E03707344
        s[4] = 0xA4093822299F31D0
    end
    self._state = s
    return self
end

-- 内部：生成 bits (1..64) 随机位，返回无符号整数
function Random:_nextBits(bits)
    if bits <= 0 or bits > 64 then
        error("bits must be in 1..64")
    end
    local r = xoshiro256plusplusNext(self._state)
    if bits == 64 then
        return r
    else
        return r >> (64 - bits)
    end
end

--- 返回一个 32-bit 带符号整数（类似 Java 的 nextInt()）
function Random:nextInt()
    local x = self:_nextBits(32)
    -- unsigned -> signed 32
    if x >= 0x80000000 then
        return x - 0x100000000
    end
    return x
end

--- 返回一个 [0, bound) 的非负整数（参数必须为正整数）
-- 使用拒绝采样，基于 63-bit 随机源确保无偏
function Random:nextIntBound(bound)
    if not bound or bound <= 0 then
        error("bound must be positive")
    end
    bound = math.floor(bound)
    -- 优先处理 power-of-two
    if (bound & (bound - 1)) == 0 then
        -- 使用 31 or 63 位：这里使用 31 位以兼容 signed-int, 但也可以用 63 位
        local r = self:_nextBits(31)
        return r & (bound - 1)
    end
    -- 使用 63-bit 随机数（非负）
    while true do
        local r = self:_nextBits(63) -- 0..2^63-1
        local val = r % bound
        if r - val + (bound - 1) >= 0 then
            return val
        end
    end
end

--- 返回一个 64-bit（signed）整数（Lua 平台若为 64-bit integer，这将返回整数）
function Random:nextLong()
    local x = self:_nextBits(64)
    -- 转换为有符号 64（如果需要），但通常 Lua 的整数是带符号 64 位
    if x >= 0x8000000000000000 then
        return x - 0x10000000000000000
    end
    return x
end

--- 返回一个 double（[0, 1)）
-- 使用 53-bit 精度（与 IEEE double mantissa 一致）
function Random:nextDouble()
    local a = self:_nextBits(26) -- 26 bits
    local b = self:_nextBits(27) -- 27 bits -> total 53
    local x = a * (2 ^ 27) + b
    return x / (2 ^ 53)
end

--- 返回布尔值
function Random:nextBoolean()
    return (self:_nextBits(1) ~= 0)
end

--- 返回 [0,1) 单精度近似（24-bit）
function Random:nextFloat()
    local x = self:_nextBits(24)
    return x / (2 ^ 24)
end

--- 生成 n 个随机字节并返回一个字符串（每字节 0..255）
function Random:nextBytes(n)
    n = math.max(0, tonumber(n) or 0)
    if n == 0 then return "" end
    local parts = {}
    local idx = 1
    -- 每次取 64-bit，分成 8 个字节
    while n > 0 do
        local v = self:_nextBits(64)
        -- 提取 8 个字节（从低字节到高字节）
        for i = 1, 8 do
            if n <= 0 then break end
            local byte = v & 0xFF
            parts[idx] = string.char(byte)
            idx = idx + 1
            n = n - 1
            v = v >> 8
        end
    end
    return table.concat(parts)
end

--- 克隆当前 RNG（返回状态独立拷贝）
function Random:clone()
    local cp = setmetatable({}, Random)
    local s = self._state
    cp._state = { s[1], s[2], s[3], s[4] }
    return cp
end

--- jump()：跳过 2^128 步（官方 jump），可用于生成并行子序列
function Random:jump()
    local s = self._state
    local t1, t2, t3, t4 = 0, 0, 0, 0
    for i = 1, #JUMP do
        local jc = JUMP[i]
        for b = 0, 63 do
            if ((jc >> b) & 1) ~= 0 then
                t1 = t1 ~ s[1]
                t2 = t2 ~ s[2]
                t3 = t3 ~ s[3]
                t4 = t4 ~ s[4]
            end
            xoshiro256plusplusNext(s)
        end
    end
    s[1] = toUint64(t1)
    s[2] = toUint64(t2)
    s[3] = toUint64(t3)
    s[4] = toUint64(t4)
    return self
end

--- longJump()：跳过 2^192 步（官方 long jump）
function Random:longJump()
    local s = self._state
    local t1, t2, t3, t4 = 0, 0, 0, 0
    for i = 1, #LONG_JUMP do
        local jc = LONG_JUMP[i]
        for b = 0, 63 do
            if ((jc >> b) & 1) ~= 0 then
                t1 = t1 ~ s[1]
                t2 = t2 ~ s[2]
                t3 = t3 ~ s[3]
                t4 = t4 ~ s[4]
            end
            xoshiro256plusplusNext(s)
        end
    end
    s[1] = toUint64(t1)
    s[2] = toUint64(t2)
    s[3] = toUint64(t3)
    s[4] = toUint64(t4)
    return self
end

return Random
