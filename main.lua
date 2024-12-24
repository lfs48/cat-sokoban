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
        outOfBounds = '-'
    }

    --Initialize level
    Level = {
        {'-', '-', '#', '#', '#'},
        {'-', '-', '#', 'x', '#'},
        {'-', '-', '#', ' ', '#', '#', '#', '#'},
        {'#', '#', '#', '$', ' ', '$', 'x', '#'},
        {'#', 'x', ' ', '$', '@', '#', '#', '#'},
        {'#', '#', '#', '#', '$', '#'},
        {'-', '-', '-', '#', 'x', '#'},
        {'-', '-', '-', '#', '#', '#'},
    }

    --Initialize player position
    PlayerPos = {
        x = 5,
        y = 5,
    }

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

    local cellSize = 23

    local colors = {
        [Cells.player] = {.64, .53, 1},
        [Cells.playerOnStorage] = {.62, .47, 1},
        [Cells.box] = {1, .79, .49},
        [Cells.boxOnStorage] = {.59, 1, .5},
        [Cells.storage] = {.61, .9, 1},
        [Cells.wall] = {1, .58, .82},
        [Cells.empty] = {1, 1, 1},
    }

    --Draw level
    for y, row in ipairs(Level) do
        for x, cell in ipairs(row) do
            if cell ~= Cells.outOfBounds then

                --Draw cell bg
                local color = colors[cell]
                love.graphics.setColor(color)
                love.graphics.rectangle(
                    'fill',
                    (x - 1) * cellSize, --x pos
                    (y - 1) * cellSize, --y pos
                    cellSize, --width
                    cellSize --height
                )
                --Draw cell text
                love.graphics.setColor(1, 1, 1)
                local value = ''
                love.graphics.print(
                    Level[y][x], --value
                    (x - 1) * cellSize, --x pos
                    (y - 1) * cellSize --y pos
                )
            end
        end
    end
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
    if cell ~= Cells.empty then return false end

    return true
end

--Move player to new position and update position vars
function UpdatePlayerPos(pos)

    --Update position
    local prevPos = PlayerPos
    PlayerPos = pos

    --Update cells
    Level[prevPos.y][prevPos.x] = Cells.empty
    Level[PlayerPos.y][PlayerPos.x] = Cells.player
end