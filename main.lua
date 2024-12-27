if arg[2] == "debug" then
    require("lldebugger").start()
end

Map = require('map')

Layouts = {
    {
        {'#', '#', '#', '#', '#'},
        {'#', '@', ' ', 'x', '#'},
        {'#', ' ', ' ', ' ', '#'},
        {'#', 'x', ' ', ' ', '#'},
        {'#', ' ', ' ', 'x', '#'},
        {'#', 'x', '$', 'x', '#'},
        {'#', 'x', '*', ' ', '#'},
        {'#', ' ', '*', 'x', '#'},
        {'#', ' ', '*', ' ', '#'},
        {'#', 'x', '*', 'x', '#'},
        {'#', '#', '#', '#', '#'},
    },
    {
        {'#', '#', '#', '#', '#', ' ', ' ', ' ', ' '},
        {'#', ' ', ' ', ' ', '#', ' ', ' ', ' ', ' '},
        {'#', '@', '$', ' ', '#', ' ', '#', '#', '#'},
        {'#', ' ', ' ', ' ', '#', ' ', '#', 'x', '#'},
        {'#', '#', '#', ' ', '#', '#', '#', 'x', '#'},
        {' ', '#', '#', ' ', ' ', ' ', ' ', 'x', '#'},
        {' ', '#', ' ', ' ', ' ', '#', ' ', ' ', '#'},
        {' ', '#', ' ', ' ', ' ', '#', '#', '#', '#'},
        {' ', '#', '#', '#', '#', '#', ' ', ' ', ' '},
    },
    {
        {' ', '#', '#', '#', '#', ' ', ' ', ' '},
        {' ', '#', '@', ' ', '#', '#', '#', ' '},
        {' ', '#', ' ', '$', ' ', ' ', '#', ' '},
        {'#', '#', '#', ' ', '#', ' ', '#', '#'},
        {'#', 'x', '#', ' ', '#', ' ', ' ', '#'},
        {'#', 'x', ' ', ' ', ' ', '#', ' ', '#'},
        {'#', 'x', ' ', ' ', ' ', ' ', ' ', '#'},
        {'#', '#', '#', '#', '#', '#', '#', '#'},
    },
}

function love.load()

    --Instantiate levels
    GameMaps = {}
    for i=1,#Layouts do
        local NewLevel = Map:new()
        GameMaps[i] = NewLevel
    end

    --Initialize first level
    ActiveMapIndex = 1
    GameMaps[1]:initialize(Layouts[1])

end

local function getCurrentLevel()
    return GameMaps[ActiveMapIndex]
end

local function advanceMap()
    ActiveMapIndex = (ActiveMapIndex + 1) % 3 + 1
    local layout = Layouts[ActiveMapIndex]
    GameMaps[ActiveMapIndex]:initialize(layout)
end

function love.keypressed(key)
    --If current level is uncompleted, capture keypress for level controls
    local level = getCurrentLevel()
    if not level.completed then
        getCurrentLevel():keypressed(key)
    --If current level is completed, press any key to continue to next level
    else
        advanceMap()
    end
end

function love.draw()
    --Draw level
    getCurrentLevel():draw()
end