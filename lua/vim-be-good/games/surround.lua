local GameUtils = require("vim-be-good.game-utils")
local log = require("vim-be-good.log")

local instructions = { "Surround text inside of ^ (inclusive) with \".", "", "" }

local SurroundRound = {}
function SurroundRound:new(difficulty, window)
    log.info("New", difficulty, window)
    local round = {
        window = window,
        difficulty = difficulty,
    }

    self.__index = self
    self.__winLine = ""
    return setmetatable(round, self)
end

function SurroundRound:getInstructions()
    return instructions
end

function SurroundRound:getConfig()
    log.info("getConfig", self.difficulty, GameUtils.difficultyToTime[self.difficulty])
    return {
        roundTime = GameUtils.difficultyToTime[self.difficulty]
    }
end

function SurroundRound:checkForWin()
    local lines = self.window.buffer:getGameLines()
    local found = false
    found = lines[1] == self.__winLine
    return found
end

function SurroundRound:render()
    local sentence = GameUtils:getRandomSentence()
    local lines = GameUtils.createEmpty(2)

    lines[1] = sentence

    local location = math.random(1, string.len(sentence) / 2)

    local location2 = -1
    while location2 == -1 or location2 <= location do
        location2 = math.random(1, string.len(sentence))
    end

    local pointerLine = ""
    local winSentence = ""
    for idx = 1, #sentence do
        local c = sentence:sub(idx, idx)
        if idx == location or idx == location2 then
            pointerLine = pointerLine .. "^"
            if idx == location then
                winSentence = winSentence .. '"' .. c
            else
                winSentence = winSentence .. c .. '"'
            end
        else
            pointerLine = pointerLine .. " "
            winSentence = winSentence .. c
        end
    end
    lines[2] = pointerLine

    log.info("Surround: Win string", winSentence);

    self.__winLine = winSentence

    local cursorIdx = 1

    return lines, cursorIdx
end

function SurroundRound:name()
    return "surround"
end

return SurroundRound
