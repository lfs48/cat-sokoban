--Debug
if arg[2] == "debug" then
    require("lldebugger").start()
end

--Imports
Level = require('level')
Map = require('map')

--Vars
local gameLevels = {}
local activeLevelIndex = 0
local levelLayouts = {
    --Level 1
    {
        --Level 1 Map 1
        {
            {'#', '#', '#', '#', '#'},
            {'#', '@', ' ', ' ', '#'},
            {'#', ' ', '$', ' ', '#'},
            {'#', 'x', ' ', ' ', '#'},
            {'#', '#', '#', '#', '#'},
        },
        --Level 1 Map 2
        {
            {'#', '#', '#', '#', '#'},
            {'#', ' ', ' ', '@', '#'},
            {'#', ' ', '$', ' ', '#'},
            {'#', 'x', ' ', ' ', '#'},
            {'#', '#', '#', '#', '#'},
        },
    },
    --Level 2
    {
        --Level 2 Map 1
        {
            {'#', '#', '#', '#', '#'},
            {'#', ' ', ' ', '@', '#'},
            {'#', ' ', '$', ' ', '#'},
            {'#', 'x', ' ', ' ', '#'},
            {'#', '#', '#', '#', '#'},
        },
        --Level 2 Map 2
        {
            {'#', '#', '#', '#', '#'},
            {'#', '@', ' ', ' ', '#'},
            {'#', ' ', '$', ' ', '#'},
            {'#', 'x', ' ', ' ', '#'},
            {'#', '#', '#', '#', '#'},
        },
    },
}

function love.load()

    --Instantiate levels
    for _, layouts in ipairs(levelLayouts) do
        local level = Level:new()
        table.insert(gameLevels, level)
        --Populate level with maps
        local maps = {}
        for _, layout in ipairs(layouts) do
            local map = Map:new(layout)
            table.insert(maps, map)
        end
        level:initialize(maps)
    end

    activeLevelIndex = 1

end

--Return the current level
local function getCurrentLevel()
    return gameLevels[activeLevelIndex]
end

--Advance game to the next level
local function advanceLevel()
    activeLevelIndex = activeLevelIndex + 1
end

function love.keypressed(key)
    --If current level is uncompleted, pass input to level
    local level = getCurrentLevel()
    if not level:isComplete() then
        level:keypressed(key)
    --If current level is completed, press any key to continue to next level
    else
        advanceLevel()
    end
end

function love.draw()
    --Draw level
    getCurrentLevel():draw()
end