if arg[2] == "debug" then
    require("lldebugger").start()
end

require('level')

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
    GameLevels = {}
    for i=1,#Layouts do
        local NewLevel = Level:new()
        GameLevels[i] = NewLevel
    end

    --Initialize first level
    ActiveLevelIndex = 1
    GameLevels[1]:initialize(Layouts[1])

end

local function getCurrentLevel()
    return GameLevels[ActiveLevelIndex]
end

local function advanceLevel()
    ActiveLevelIndex = (ActiveLevelIndex + 1) % 3 + 1
    local layout = Layouts[ActiveLevelIndex]
    GameLevels[ActiveLevelIndex]:initialize(layout)
end

function love.keypressed(key)
    --If current level is uncompleted, capture keypress for level controls
    local level = getCurrentLevel()
    if not level.completed then
        getCurrentLevel():keypressed(key)
    --If current level is completed, press any key to continue to next level
    else
        advanceLevel()
    end
end

function love.draw()
    --Draw level
    getCurrentLevel():draw()
end