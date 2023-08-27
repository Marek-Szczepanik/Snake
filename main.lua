-- Snake game in Lua using LÖVE framework

-- Constants
local GAME_STATE = {
    START = 1,
    PLAY = 2,
    GAME_OVER = 3
}

local BLINK_INTERVAL = 0.8
local SNAKE_MOVE_DELAY = 0.1

-- Game variables
-- Score
local gameState = GAME_STATE.START
local score = 0
local highScore = 0

-- Blinking effect
local blinkTimer = BLINK_INTERVAL
local blinkVisible = true

-- Snake
local SNAKE_MOVE_DELAY = 0.1 -- Initial move delay
local timeElapsed = 0
local timeToIncreaseSpeed = 10 -- Increase speed every 10 seconds
local speedIncreaseAmount = 0.02 -- Amount to decrease SNAKE_MOVE_DELAY by

-- ...

function love.load()
    -- Set up the game window
    love.window.setMode(1280, 720)
    love.window.setTitle("Snake Game")

    -- Set the default graphics filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Load retro-looking fonts
    hugeRetroFont = love.graphics.newFont('font.ttf', 100)
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
    timer = SNAKE_MOVE_DELAY

    -- Reset the score and load the high score from storage
    score = 0
    local highScoreString = love.filesystem.read("highscore.txt")
    highScore = tonumber(highScoreString) or 0
end

function love.update(dt)
    if gameState == GAME_STATE.PLAY then
        -- Update game logic
        timer = timer - dt
        timeElapsed = timeElapsed + dt

        if timeElapsed >= timeToIncreaseSpeed then
            timeToIncreaseSpeed = timeToIncreaseSpeed + 10 -- Increase the time to trigger next speed increase
            SNAKE_MOVE_DELAY = SNAKE_MOVE_DELAY - speedIncreaseAmount -- Decrease the move delay
        end

        if timer <= 0 then
            moveSnake()
            checkCollision()
            timer = SNAKE_MOVE_DELAY
        end
    elseif gameState == GAME_STATE.START or gameState == GAME_STATE.GAME_OVER then
        -- Implement the blinking effect for messages
        blinkTimer = blinkTimer - dt
        if blinkTimer <= 0 then
            blinkVisible = not blinkVisible -- Toggle visibility
            blinkTimer = BLINK_INTERVAL -- Set the slower blinking interval
        end
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1) -- Set default color

    if gameState == GAME_STATE.PLAY then
        -- Draw game elements...
        drawSnake()
        drawFood()
        drawScore()
        drawTime()
    elseif gameState == GAME_STATE.START then
        -- Draw the "Press any key to start" message with blinking
        love.graphics.setFont(hugeRetroFont)
        love.graphics.setColor(0.2, 0.6, 0.2)
        love.graphics.printf('SNAKE GAME', 0, 100, love.graphics.getWidth(), 'center')

        love.graphics.setFont(bigRetroFont)
        love.graphics.setColor(1, 1, 1) -- Set default color
        love.graphics.printf('Press any key to start', 0, 300, love.graphics.getWidth(), 'center')
        
    elseif gameState == GAME_STATE.GAME_OVER then
        -- Draw the appropriate game over messages with blinking
        love.graphics.setFont(bigRetroFont)
        drawGameOverMessage()
        drawTime()
    end
end

function love.keypressed(key)
    if gameState == GAME_STATE.START then
        gameState = GAME_STATE.PLAY
    elseif gameState == GAME_STATE.PLAY then
        -- Handle player input during gameplay
        handlePlayerInput(key)
    elseif gameState == GAME_STATE.GAME_OVER then
        -- Update the high score and save it to storage
        if score > highScore then
            highScore = score
            love.filesystem.write("highscore.txt", tostring(highScore))
        end
        -- Reset game state for restart
        resetGame()
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

function drawSnake()
    love.graphics.setColor(0.2, 0.6, 0.2)
    for _, segment in ipairs(snake) do
        love.graphics.rectangle("fill", (segment.x - 1) * tileSize, (segment.y - 1) * tileSize, tileSize, tileSize)
    end
end

function drawFood()
    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.rectangle("fill", (food.x - 1) * tileSize, (food.y - 1) * tileSize, tileSize, tileSize)
end

function drawScore()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(smallRetroFont)
    love.graphics.print('Score: ' .. score, love.graphics.getWidth() - 180, 20)
end

function handlePlayerInput(key)
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

function drawGameOverMessage()
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

function resetGame()
    love.load()
    gameState = GAME_STATE.START
end

function checkCollision()
    -- Check collision with walls and snake's body
    local headX = snake[1].x
    local headY = snake[1].y

    if headX <= 0 or headX > love.graphics.getWidth() / tileSize or
       headY <= 0 or headY > love.graphics.getHeight() / tileSize then
        gameState = GAME_STATE.GAME_OVER -- Game Over
    end

    for i = 2, #snake do
        if headX == snake[i].x and headY == snake[i].y then
            gameState = GAME_STATE.GAME_OVER -- Game Over
        end
    end
end

function spawnFood()
    -- Generate random food position
    food.x = math.random(1, love.graphics.getWidth() / tileSize)
    food.y = math.random(1, love.graphics.getHeight() / tileSize)
end

function drawTime()
    love.graphics.setFont(smallRetroFont)
    local formattedTime = string.format("Time: %.2f", timeElapsed)
    love.graphics.print(formattedTime, 20, 20)
end
