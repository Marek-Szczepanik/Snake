-- Snake game in Lua using LÖVE framework

function love.load()
    love.window.setMode(1280, 720)
    love.window.setTitle("Snake Game")

    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- more "retro-looking" font object we can use for any text
    bigRetroFont = love.graphics.newFont('font.ttf', 72)

    -- set LÖVE2D's active font to the smallFont obect
    love.graphics.setFont(bigRetroFont)

    tileSize = 40
    snake = {
        {x = 3, y = 3},
        {x = 2, y = 3},
        {x = 1, y = 3}
    }
    food = {x = 10, y = 10}
    direction = "right"
    timer = 0.1
    gameOver = false
end

function love.update(dt)
    if not gameOver then
        timer = timer - dt

        if timer <= 0 then
            moveSnake()
            checkCollision()
            timer = 0.1
        end
    end
end

function love.draw()
    love.graphics.setColor(0.2, 0.6, 0.2)

    for _, segment in ipairs(snake) do
        love.graphics.rectangle("fill", (segment.x - 1) * tileSize, (segment.y - 1) * tileSize, tileSize, tileSize)
    end

    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.rectangle("fill", (food.x - 1) * tileSize, (food.y - 1) * tileSize, tileSize, tileSize)

    if gameOver then
        love.graphics.setColor(1, 1, 1)
        -- draw game over text toward the top of the screen
        love.graphics.printf('Game Over!', 0, 20, love.graphics.getWidth(), 'center')
    end
end

function love.keypressed(key)
    if key == "up" and direction ~= "down" then
        direction = "up"
    elseif key == "down" and direction ~= "up" then
        direction = "down"
    elseif key == "left" and direction ~= "right" then
        direction = "left"
    elseif key == "right" and direction ~= "left" then
        direction = "right"
    end
end

function moveSnake()
    local headX = snake[1].x
    local headY = snake[1].y

    if direction == "up" then
        headY = headY - 1
    elseif direction == "down" then
        headY = headY + 1
    elseif direction == "left" then
        headX = headX - 1
    elseif direction == "right" then
        headX = headX + 1
    end

    table.insert(snake, 1, {x = headX, y = headY})

    if headX == food.x and headY == food.y then
        spawnFood()
    else
        table.remove(snake)
    end
end

function checkCollision()
    local headX = snake[1].x
    local headY = snake[1].y

    if headX <= 0 or headX > love.graphics.getWidth() / tileSize or
       headY <= 0 or headY > love.graphics.getHeight() / tileSize then
        gameOver = true
    end

    for i = 2, #snake do
        if headX == snake[i].x and headY == snake[i].y then
            gameOver = true
        end
    end
end

function spawnFood()
    food.x = math.random(1, love.graphics.getWidth() / tileSize)
    food.y = math.random(1, love.graphics.getHeight() / tileSize)
end
