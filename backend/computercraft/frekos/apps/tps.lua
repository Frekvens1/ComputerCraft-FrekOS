local lastClock = os.clock()
local lastReal = os.epoch("utc")

local samples = {}
local sampleCount = 10

local function addSample(value)
    table.insert(samples, value)
    if #samples > sampleCount then
        table.remove(samples, 1)
    end
end

local function average(table)
    local sum = 0
    for _, value in ipairs(table) do
        sum = sum + value
    end

    return sum / #table
end

while true do
    sleep(1)

    local nowClock = os.clock()
    local nowReal = os.epoch("utc")

    local tickDelta = nowClock - lastClock
    local realDelta = (nowReal - lastReal) / 1000

    local estimatedTPS = 20 * (tickDelta / realDelta)

    addSample(estimatedTPS)

    screen.clear()
    print(("TPS: %.2f (avg: %.2f)"):format(
            estimatedTPS,
            average(samples)
    ))

    lastClock = nowClock
    lastReal = nowReal
end
