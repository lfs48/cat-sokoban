if arg[2] == "debug" then
    require("lldebugger").start()
end

function love.load()

    --Level cell symbols
    Cells = {
        player = '@',
        playerOnStorage = '+',
        box = '$',
        boxOnStorage = '*',
        storage = 'x',
        wall = '#',
        empty = ' ',
        outOfBounds = '-',
    }
    CellSize = 23
    CellColors = {
        [Cells.player] = {.64, .53, 1},
        [Cells.playerOnStorage] = {.62, .47, 1},
        [Cells.box] = {1, .79, .49},
        [Cells.boxOnStorage] = {.59, 1, .5},
        [Cells.storage] = {.61, .9, 1},
        [Cells.wall] = {1, .58, .82},
        [Cells.empty] = {1, 1, 1},
    }

    --Initialize level
    Level = {
        {'#', '#', '#', '#', '#'},
        {'#', '@', ' ', 'x', '#'},
        {'#', ' ', '$', ' ', '#'},
        {'#', 'x', '$', ' ', '#'},
        {'#', ' ', '$', 'x', '#'},
        {'#', 'x', '$', 'x', '#'},
        {'#', 'x', '*', ' ', '#'},
        {'#', ' ', '*', 'x', '#'},
        {'#', ' ', '*', ' ', '#'},
        {'#', 'x', '*', 'x', '#'},
        {'#', '#', '#', '#', '#'},
    }

    PlayerPos = {
        x = 0,
        y = 0,
    }
    --Initialize player position
    for y, row in ipairs(Level) do
        for x, cell in ipairs(row) do
            if cell == Cells.player or cell == Cells.playerOnStorage then
                PlayerPos.x = x
                PlayerPos.y = y
                break
            end
        end
    end

end

--Player controls
function love.keypressed(key)

    --On arrow key press, move player in direction pressed
    if key == 'up' or key == 'down' or key == 'left' or key == 'right' then
        local dx = 0
        local dy = 0
        if key == 'left' then dx = -1 end
        if key == 'right' then dx = 1 end
        if key == 'up' then dy = -1 end
        if key == 'down' then dy = 1 end

        local nextPos = {
            x = PlayerPos.x + dx,
            y = PlayerPos.y + dy,
        }

        if IsValidPos(nextPos) then
            UpdatePlayerPos(nextPos)
        end

    end
end

function love.draw()

    --Draw level
    for y, row in ipairs(Level) do
        for x, cell in ipairs(row) do
            if cell ~= Cells.outOfBounds then
                DrawCell(x, y, cell)
            end
        end
    end
end

function DrawCell(tableX, tableY, cell)
    --Calc graphics position based on table coords
    local x = (tableX - 1) * CellSize
    local y = (tableY - 1) * CellSize

    --Draw cell bg
    local color = CellColors[cell]
    love.graphics.setColor(color)
    love.graphics.rectangle(
        'fill',
        x, --x pos
        y, --y pos
        CellSize, --width
        CellSize --height
    )

    --Draw cell text
    love.graphics.setColor(1, 1, 1)
    local value = ''
    love.graphics.print(
        Level[tableY][tableX], --value
        x, --x pos
        y --y pos
    )
end

--Determine if player can move to a position
function IsValidPos(pos)
    local x = pos.x
    local y = pos.y

    --Prevent movement out of bounds
    if y < 1 or y > #Level then return false end
    if x < 1 or x > #Level[y] then return false end

    --Prevent movement to non-empty cells
    local cell = Level[pos.y][pos.x]
    if cell == Cells.empty or cell == Cells.storage then return true end

    return false
end

--Move player to new position and update position vars
function UpdatePlayerPos(pos)

    --Update position
    local prevPos = PlayerPos
    local prevCell = Level[prevPos.y][prevPos.x]
    PlayerPos = pos

    --Update cell being moved to
    local nextCell = Level[pos.y][pos.x]
    --If player is moving onto storage, update to player on storage char
    if nextCell == Cells.storage then
        Level[pos.y][pos.x] = Cells.playerOnStorage
    --Else update to player char
    else
        Level[pos.y][pos.x] = Cells.player
    end

    --Update cell being moved from
    --If player was on storage, update prev cell to storage
    if prevCell == Cells.playerOnStorage then
        Level[prevPos.y][prevPos.x] = Cells.storage
    --Else update prev cell to empty
    else
        Level[prevPos.y][prevPos.x] = Cells.empty
    end
end