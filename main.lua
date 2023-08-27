-- Snake game in Lua using LÖVE framework

local gameState = 1 -- 1: Start of game, 2: Game logic, 3: Game over
local score = 0
local highScore = 0

local blinkTimer = 0.8 -- Adjust this value for a slower blinking interval
local blinkVisible = true

function love.load()
    -- Set up the game window
    love.window.setMode(1280, 720)
    love.window.setTitle("Snake Game")

    -- Set the default graphics filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Load retro-looking fonts
    bigRetroFont = love.graphics.newFont('font.ttf', 72)
    smallRetroFont = love.graphics.newFont('font.ttf', 36)

    -- Set the active font to the bigRetroFont
    love.graphics.setFont(bigRetroFont)

    -- Set up game variables
    tileSize = 40
    snake = {
        {x = 3, y = 3},
        {x = 2, y = 3},
        {x = 1, y = 3}
    }
    food = {x = 10, y = 10}
    direction = "right"
    timer = 0.1

    -- Reset the score and load the high score from storage
    score = 0
    local highScoreString = love.filesystem.read("highscore.txt")
    highScore = tonumber(highScoreString) or 0
end

function love.update(dt)
    if gameState == 2 then
        -- Update game logic
        timer = timer - dt

        if timer <= 0 then
            moveSnake()
            checkCollision()
            timer = 0.1
        end
    elseif gameState == 1 or gameState == 3 then
        -- Implement the blinking effect for messages
        blinkTimer = blinkTimer - dt
        if blinkTimer <= 0 then
            blinkVisible = not blinkVisible -- Toggle visibility
            blinkTimer = 0.8 -- Set the slower blinking interval
        end
    end
end

function love.draw()
    if gameState == 2 then
        -- Draw the game elements
        love.graphics.setColor(0.2, 0.6, 0.2)
        for _, segment in ipairs(snake) do
            love.graphics.rectangle("fill", (segment.x - 1) * tileSize, (segment.y - 1) * tileSize, tileSize, tileSize)
        end
        love.graphics.setColor(0.8, 0.1, 0.1)
        love.graphics.rectangle("fill", (food.x - 1) * tileSize, (food.y - 1) * tileSize, tileSize, tileSize)
        -- Display the score during gameplay (gameState 2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(smallRetroFont)
        love.graphics.print('Score: ' .. score, love.graphics.getWidth() - 160, 20)

    elseif gameState == 1 then
        -- Draw the "Press any key to start" message with blinking
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(bigRetroFont)
        love.graphics.printf('Press any key to start', 0, 300, love.graphics.getWidth(), 'center')
        
    elseif gameState == 3 then
        -- Draw the appropriate game over messages with blinking
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(bigRetroFont)
        if score > highScore then
            love.graphics.printf('Score: ' .. score, 0, 300, love.graphics.getWidth(), 'center')
            love.graphics.setFont(smallRetroFont)
            if blinkVisible then
            love.graphics.printf('Congratulations! You made a new record', 0, 150, love.graphics.getWidth(), 'center')
            end
        else
            love.graphics.printf('Score: ' .. score .. '\nHigh Score: ' .. highScore, 0, 300, love.graphics.getWidth(), 'center')
            love.graphics.setFont(smallRetroFont)
            if blinkVisible then
            love.graphics.printf('Game Over! Press any key to restart', 0, 150, love.graphics.getWidth(), 'center')
            end
        end
    end
end

function love.keypressed(key)
    if gameState == 1 then
        gameState = 2
    elseif gameState == 2 then
        -- Handle player input during gameplay
        if key == "up" and direction ~= "down" then
            direction = "up"
        elseif key == "down" and direction ~= "up" then
            direction = "down"
        elseif key == "left" and direction ~= "right" then
            direction = "left"
        elseif key == "right" and direction ~= "left" then
            direction = "right"
        end
    elseif gameState == 3 then
        -- Update the high score and save it to storage
        if score > highScore then
            highScore = score
            love.filesystem.write("highscore.txt", tostring(highScore))
        end
        -- Reset game state for restart
        love.load()
        gameState = 1
    end
end

function moveSnake()
    -- Move the snake and handle collision with food
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
        score = score + 1 -- Increase the score
        spawnFood()
    else
        table.remove(snake)
    end
end

function checkCollision()
    -- Check collision with walls and snake's body
    local headX = snake[1].x
    local headY = snake[1].y

    if headX <= 0 or headX > love.graphics.getWidth() / tileSize or
       headY <= 0 or headY > love.graphics.getHeight() / tileSize then
        gameState = 3 -- Game Over
    end

    for i = 2, #snake do
        if headX == snake[i].x and headY == snake[i].y then
            gameState = 3 -- Game Over
        end
    end
end

function spawnFood()
    -- Generate random food position
    food.x = math.random(1, love.graphics.getWidth() / tileSize)
    food.y = math.random(1, love.graphics.getHeight() / tileSize)
end
