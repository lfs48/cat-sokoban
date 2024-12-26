--Cell size
local cellSize = 23

--Level cell symbols and colors
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

Level = {}

--Constructor
function Level:new(o)
    local level = o or {}
    setmetatable(level, self)
    self.__index = self

    --Initialize player position
    level.playerPos = {
        x = 0,
        y = 0,
    }
    for y, row in ipairs(level) do
        for x, cell in ipairs(row) do
            if cell == cells.player or cell == cells.playerOnStorage then
                level.playerPos.x = x
                level.playerPos.y = y
                break
            end
        end
    end

    --Field to track level completion
    level.completed = false

    return level
end

--Player controls
function Level:keypressed(key)

    --Only accept controls if level is not completed
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
                --Update level with movement
                self:updatePositions(nextPos, dx, dy)
                --Determine if level is complete
                if self:isComplete() then
                    self.completed = true
                end
            end
        end
    end
end

--Determine if player can move to a position
function Level:isValidMove(pos, dx, dy, isPush)
    local x = pos.x
    local y = pos.y

    --Prevent movement out of bounds
    if y < 1 or y > #self then return false end
    if x < 1 or x > #self[y] then return false end

    local cell = self[y][x]

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

--Update player and box positions based on movement
function Level:updatePositions(pos, dx, dy)

    --Update position
    local prevPos = self.playerPos
    local prevCell = self[prevPos.y][prevPos.x]
    local nextCell = self[pos.y][pos.x]
    self.playerPos = pos

    --If pushing, update next cell and one cell ahead
    if pushPrevCells[nextCell] then
        local pushX = pos.x + dx
        local pushY = pos.y + dy
        local pushCell = self[pushY][pushX]
        --Update cell being pushed
        self[pos.y][pos.x] = pushPrevCells[nextCell]
        --Update push destination cell
        self[pushY][pushX] = pushNextCells[pushCell]
    --If not pushing, then moving
    else
        --Update cell being moved into
        self[pos.y][pos.x] = moveNextCells[nextCell]
    end

    --Update cell being moved from
    self[prevPos.y][prevPos.x] = movePrevCells[prevCell]

end

--Determine if level has been completed
--A level is complete if there are no unstored boxes
function Level:isComplete()
    for y, row in ipairs(self) do
        for x, cell in ipairs(row) do
            if cell == cells.box then
                return false
            end
        end
    end
    return true
end

--Draw level
function Level:draw()
    --Calc level width and height
    local width = #self[1] * cellSize
    local height = #self * cellSize
    
    --Center
    local windowWidth, windowHeight = love.window.getMode()
    local dx = (windowWidth - width) / 2
    local dy = (windowHeight - height) / 2
    love.graphics.translate(dx, dy)

    for y, row in ipairs(self) do
        for x, cell in ipairs(row) do
            if cell ~= cells.outOfBounds then
                self:drawCell(x, y, cell)
            end
        end
    end

    love.graphics.translate(-dx, -dy)

    if self.completed then
        self:drawComplete()
    end
end

--Draw a level cell
function Level:drawCell(tableX, tableY, cell)
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
        self[tableY][tableX], --value
        x, --x pos
        y --y pos
    )
end

--Draw level complete message
function Level:drawComplete()
    local message = 'Level Complete'
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

    --Draw cell text
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(
        message, --value
        0, --x pos
        height / 2, --y pos
        width, --limit
        "center"
    )
end