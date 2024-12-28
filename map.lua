local util = require('util')

local Map = {}

--Cell size
local cellSize = 23

--Map cell symbols and colors
local cells = {
    player = '@',
    playerOnStorage = '+',
    box = '$',
    boxOnStorage = '*',
    storage = 'x',
    wall = '#',
    empty = ' ',
    outOfBounds = '-',
}

local cellColors = {
    [cells.player] = {.64, .53, 1},
    [cells.playerOnStorage] = {.62, .47, 1},
    [cells.box] = {1, .79, .49},
    [cells.boxOnStorage] = {.59, 1, .5},
    [cells.storage] = {.61, .9, 1},
    [cells.wall] = {1, .58, .82},
    [cells.empty] = {1, 1, 1},
}

--Cell to render in player's next position when moving
--Also serves as list of cells that can be moved into
local moveNextCells = {
    [cells.empty] = cells.player,
    [cells.storage] = cells.playerOnStorage,
}
--Cell to render in player's previous position when moving
local movePrevCells = {
    [cells.player] = cells.empty,
    [cells.playerOnStorage] = cells.storage,
}
--Cell to render in pushable object's previous position when pushing
--Also serves as list of cells that can be pushed
local pushPrevCells = {
    [cells.box] = cells.player,
    [cells.boxOnStorage] = cells.playerOnStorage,
}
--Cell to render in pushable object's next position when pushing
local pushNextCells = {
    [cells.empty] = cells.box,
    [cells.storage] = cells.boxOnStorage,
}

--Static helper functions

--Determine player x and y position from gamestate
local function findPlayerPos(state)
    for y, row in ipairs(state) do
        for x, cell in ipairs(row) do
            if cell == cells.player or cell == cells.playerOnStorage then
                return {
                    x = x,
                    y = y
                }
            end
        end
    end

    error("No player found")
end

--Constructor
function Map:new(initialState)
    local map = {}
    setmetatable(map, self)
    self.__index = self
    if initialState then map:initialize(initialState) end
    return map
end

--Initialize Map
function Map:initialize(initialState)
    --Initialize gamestate
    self.states = {
        util.deepClone(initialState)
    }

    --Initialize player position
    self.playerPos = findPlayerPos(initialState)

    --Field to track map completion
    self.completed = false

    --Field used for anchor point to draw map from
    self.anchor = {
        x = 0,
        y = 0,
    }
end

--Setters
function Map:setAnchor(x, y)
    self:setAnchor({
        x = x,
        y = y,
    })
end

--Get current gamestate (last entry in states table)
function Map:currentState()
    return self.states[#self.states]
end

--Update gamestate and player position
function Map:advanceState(gameState, playerPos)
    table.insert(self.states, gameState)
    self.playerPos = playerPos
end

--Player controls
function Map:keypressed(key)

    --Only accept controls if Map is not completed
    if not self.completed then
        --On arrow key or WASD press, move player in direction pressed
        local dx = 0
        local dy = 0
        if key == 'left' or key == 'a' then dx = -1 end
        if key == 'right' or key == 'd' then dx = 1 end
        if key == 'up' or key == 'w' then dy = -1 end
        if key == 'down' or key == 's' then dy = 1 end

        if dx ~= 0 or dy ~= 0 then

            local nextPos = {
                x = self.playerPos.x + dx,
                y = self.playerPos.y + dy,
            }

            if self:isValidMove(nextPos, dx, dy, false) then
                --Update gamestate
                local newState = self:calcNewState(nextPos, dx, dy)
                self:advanceState(newState, nextPos)
                --Determine if map is complete
                if self:isComplete() then
                    self.completed = true
                end
            end
        end

        --On Z key press, undo last move
        if key == 'z' and #self.states > 1 then
            self:undoLastMove()
        end

        --On R press, reset Map to initial state
        if key =='r' then
            self:reset()
        end
    end
end

--Determine if player can move to a position
function Map:isValidMove(pos, dx, dy, isPush)
    local x = pos.x
    local y = pos.y

    --Prevent movement out of bounds
    if y < 1 or y > #self:currentState() then return false end
    if x < 1 or x > #self:currentState()[y] then return false end

    local cell = self:currentState()[y][x]

    --Allow moving into pushable cell if one cell ahead is also valid
    if not isPush and pushPrevCells[cell] then
        local pushPos = {
            x = x + dx,
            y = y + dy,
        }
        return self:isValidMove(pushPos, 0, 0, true)
    end

    --Allow moving into movable cells
    if moveNextCells[cell] then return true end

    return false
end

--Determine and return new gamestate
function Map:calcNewState(newPos, dx, dy)
    local newState = util.deepClone(self:currentState())

    --Update position
    local prevCell = newState[self.playerPos.y][self.playerPos.x]
    local nextCell = newState[newPos.y][newPos.x]

    --If pushing, update next cell and one cell ahead
    if pushPrevCells[nextCell] then
        local pushPos = {
            x = newPos.x + dx,
            y = newPos.y + dy,
        }
        local pushCell = newState[pushPos.y][pushPos.x]
        --Update cell being pushed
        newState[newPos.y][newPos.x] = pushPrevCells[nextCell]
        --Update push destination cell
        newState[pushPos.y][pushPos.x] = pushNextCells[pushCell]
    --If not pushing, then moving
    else
        --Update cell being moved into
        newState[newPos.y][newPos.x] = moveNextCells[nextCell]
    end

    --Update cell being moved from
    newState[self.playerPos.y][self.playerPos.x] = movePrevCells[prevCell]

    return newState
end

--Determine if map has been completed
--A map is complete if there are no unstored boxes
function Map:isComplete()
    for y, row in ipairs(self:currentState()) do
        for x, cell in ipairs(row) do
            if cell == cells.box then
                return false
            end
        end
    end
    return true
end

--Undo last move by returning to previous gamestate
function Map:undoLastMove()
    table.remove(self.states)
    self.playerPos = findPlayerPos(self:currentState())
end

--Reset Map to initial state
function Map:reset()
    local layout = util.deepClone(self.states[1])
    self:initialize(layout)
end

--Draw map
function Map:draw()
    --Calc Map width and height
    -- local width = #self:currentState()[1] * cellSize
    -- local height = #self:currentState() * cellSize
    
    -- --Center
    -- local windowWidth, windowHeight = love.window.getMode()
    -- local dx = (windowWidth - width) / 2
    -- local dy = (windowHeight - height) / 2
    -- love.graphics.translate(dx, dy)

    for y, row in ipairs(self:currentState()) do
        for x, cell in ipairs(row) do
            if cell ~= cells.outOfBounds then
                self:drawCell(x, y, cell)
            end
        end
    end

    -- love.graphics.translate(-dx, -dy)

    -- if self.completed then
    --     self:drawComplete()
    -- end
end

--Draw a map cell
function Map:drawCell(tableX, tableY, cell)
    --Calc graphics position based on table coords
    local x = (tableX - 1) * cellSize
    local y = (tableY - 1) * cellSize

    --Draw cell bg
    local color = cellColors[cell]
    love.graphics.setColor(color)
    love.graphics.rectangle(
        'fill',
        x, --x pos
        y, --y pos
        cellSize, --width
        cellSize --height
    )

    --Draw cell text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(
        self:currentState()[tableY][tableX], --value
        x, --x pos
        y --y pos
    )
end

--Draw map complete message
function Map:drawComplete()
    local line1 = 'Map Complete'
    local line2 = 'Press any key to continue'
    local width = 200
    local height = 100
    local offset = 200

    --Center
    local windowWidth, windowHeight = love.window.getMode()
    local dx = (windowWidth - width) / 2
    local dy = (windowHeight - height) / 2 + offset
    love.graphics.translate(dx, dy)

    --Draw bg
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle(
        'fill',
        0, --x pos
        0, --y pos
        width, --width
        height --height
    )

    --Draw text
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(
        line1, --value
        0, --x pos
        height / 3, --y pos
        width, --limit
        "center" --justify
    )
    love.graphics.printf(
        line2, --value
        0, --x pos
        2 * height / 3, --y pos
        width, --limit
        "center" --justify
    )
end

return Map