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
    --Cell to render in player's next position when moving
    --Also serves as list of cells that can be moved into
    MoveNextCells = {
        [Cells.empty] = Cells.player,
        [Cells.storage] = Cells.playerOnStorage,
    }
    --Cell to render in player's previous position when moving
    MovePrevCells = {
        [Cells.player] = Cells.empty,
        [Cells.playerOnStorage] = Cells.storage,
    }
    --Cell to render in pushable object's previous position when pushing
    --Also serves as list of cells that can be pushed
    PushPrevCells = {
        [Cells.box] = Cells.player,
        [Cells.boxOnStorage] = Cells.playerOnStorage,
    }
    --Cell to render in pushable object's next position when pushing
    PushNextCells = {
        [Cells.empty] = Cells.box,
        [Cells.storage] = Cells.boxOnStorage,
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

        if IsValidMove(nextPos, dx, dy, false) then
            UpdatePlayerPos(nextPos, dx, dy)
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
    love.graphics.print(
        Level[tableY][tableX], --value
        x, --x pos
        y --y pos
    )
end

--Determine if player can move to a position
function IsValidMove(pos, dx, dy, isPush)
    local x = pos.x
    local y = pos.y

    --Prevent movement out of bounds
    if y < 1 or y > #Level then return false end
    if x < 1 or x > #Level[y] then return false end

    local cell = Level[pos.y][pos.x]

    --Allow moving into pushable cell if one cell ahead is also valid
    if not isPush and PushPrevCells[cell] then
        local pushPos = {
            x = pos.x + dx,
            y = pos.y + dy,
        }
        return IsValidMove(pushPos, 0, 0, true)
    end

    --Allow moving into movable cells
    if MoveNextCells[cell] then return true end

    return false
end

--Move player to new position and update level cells
function UpdatePlayerPos(pos, dx, dy)

    --Update position
    local prevPos = PlayerPos
    local prevCell = Level[prevPos.y][prevPos.x]
    local nextCell = Level[pos.y][pos.x]
    PlayerPos = pos

    --If pushing, update next cell and one cell ahead
    if PushPrevCells[nextCell] then
        local pushX = pos.x + dx
        local pushY = pos.y + dy
        local pushCell = Level[pushY][pushX]
        --Update cell being pushed
        Level[pos.y][pos.x] = PushPrevCells[nextCell]
        --Update push destination cell
        Level[pushY][pushX] = PushNextCells[pushCell]
    --If not pushing, then moving
    else
        --Update cell being moved into
        Level[pos.y][pos.x] = MoveNextCells[nextCell]
    end

    --Update cell being moved from
    Level[prevPos.y][prevPos.x] = MovePrevCells[prevCell]

end