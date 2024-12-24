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
    }

    --Initialize level
    Level = {
        {' ', ' ', '#', '#', '#'},
        {' ', ' ', '#', 'x', '#'},
        {' ', ' ', '#', ' ', '#', '#', '#', '#'},
        {'#', '#', '#', '$', ' ', '$', 'x', '#'},
        {'#', 'x', ' ', '$', '@', '#', '#', '#'},
        {'#', '#', '#', '#', '$', '#'},
        {' ', ' ', ' ', '#', 'x', '#'},
        {' ', ' ', ' ', '#', '#', '#'},
    }

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
    }

    --Draw level
    for y, row in ipairs(Level) do
        for x, cell in ipairs(row) do
            if cell ~= Cells.empty then

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
                love.graphics.print(
                    Level[y][x], --value
                    (x - 1) * cellSize, --x pos
                    (y - 1) * cellSize --y pos
                )
            end
        end
    end
end