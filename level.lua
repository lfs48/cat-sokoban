local Level = {}

--Constructor
function Level:new()
    local level = {}
    setmetatable(level, self)
    self.__index = self
    return level
end

--Initialize level
function Level:initialize(maps)
    --Initialize level maps
    self.maps = maps
end

--Determine if level is complete by checking if all of its maps are complete
function Level:isComplete()
    for _, map in ipairs(self.maps) do
        if not map.completed then return false end
    end
    return true
end

--Propagates keypresses to all maps in level
function Level:keypressed(key)
    for _, map in ipairs(self.maps) do
        map:keypressed(key)
    end
end

--Draws levels in map
function Level:draw()

    local windowWidth, windowHeight = love.window.getMode()
    local partitionWidth = windowWidth / (#self.maps + 1)

    --Center vertically
    love.graphics.translate(0, windowHeight / 2)

    for _, map in ipairs(self.maps) do
    love.graphics.translate(partitionWidth, 0)
        map:draw()
    end
end

return Level