local GameUtils = require("vim-be-good.game-utils")
local log = require("vim-be-good.log")

local boardSizeOptions = {
    noob = 3,
    easy = 5,
    medium = 7,
    hard = 8,
    nightmare = 9,
    tpope = 10
}

local instructions = {"Reorder 1, 2, 3, 4 to be in a ascending order.", "", ""}

local ReorderRound = {}
function ReorderRound:new(difficulty, window)
    log.info("New", difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty
    }

    self.__index = self
    return setmetatable(round, self)
end

function ReorderRound:getInstructions()
    return instructions
end

function ReorderRound:getConfig()
    log.info("getConfig", self.difficulty, GameUtils.difficultyToTime[self.difficulty])
    return {
        roundTime = GameUtils.difficultyToTime[self.difficulty]
    }
end

function ReorderRound:getRandomNumber(count)
    return math.random(1, count)
end

function checkAscending(lines)
    local last = 0
    for line in lines:gmatch("%S+") do
        local num = tonumber(line)
        if num == nil and not line:match("^[1-4]$") then
            return false
        end
        if num ~= last + 1 then
            return false
        end
        last = num
    end
    return true
end

function ReorderRound:checkForWin()
    local lines = self.window.buffer:getGameLines()

    return checkAscending(table.concat(lines, "\n"));
end

function shuffle(nums)
    for i = #nums, 2, -1 do
        local j = math.random(i)
        nums[i], nums[j] = nums[j], nums[i]
    end
    return nums
end

function ReorderRound:render()
    local boardSize = boardSizeOptions[self.difficulty]
    log.info("ReorderRound:render: " .. boardSize)
    local lines = GameUtils.createEmpty(boardSize)

    local xCol = 1
    local xLine = 1
    local cursorCol = 1
    local cursorLine = 1

    while (xLine == cursorLine or xCol == cursorCol) do
        xCol = self:getRandomNumber(boardSize)
        xLine = self:getRandomNumber(boardSize)
        cursorCol = self:getRandomNumber(boardSize)
        cursorLine = self:getRandomNumber(boardSize)
    end
    log.info("ReorderRound:render      xLine: ", xLine, "      xCol: ", xCol)
    log.info("ReorderRound:render cursorLine: ", cursorLine, " cursorCol: ", cursorCol)

    local numbers = shuffle({1, 2, 3, 4});

    local idx = 1
    while idx <= 4 do
        local line = lines[idx]
        line = tostring(numbers[idx])
        lines[idx] = line
        idx = idx + 1
    end

    return lines, cursorLine, cursorCol
end

function ReorderRound:name()
    return "reorder"
end

return ReorderRound

