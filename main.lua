if arg[2] == "debug" then
    require("lldebugger").start()
end

require('level')

function love.load()

    --Instantiate example level
    ExampleLevel = Level:new{
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

end

function love.keypressed(key)
    --Capture keypress for level controls
    ExampleLevel:keypressed(key)
end

function love.draw()
    --Draw level
    ExampleLevel:draw()
end