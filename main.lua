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
    love.window.setMode(1280, 768)
    love.window.setTitle("Snake Game")

    -- Set the default graphics filter
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Load custom sprites
    background = love.graphics.newImage("sprites/backgroundGrey.png")
    foodImage = love.graphics.newImage("sprites/apple.png")
    snakeHead = love.graphics.newImage("sprites/snakeHead.png")
    snakeBody = love.graphics.newImage("sprites/snakeBody.png")

    -- Load retro-looking fonts
    hugeRetroFont = love.graphics.newFont('font.ttf', 100)
    bigRetroFont = love.graphics.newFont('font.ttf', 72)
    smallRetroFont = love.graphics.newFont('font.ttf', 36)

    -- Set the active font to the bigRetroFont
    love.graphics.setFont(bigRetroFont)

    -- Load sound files
    backgroundMusic = love.audio.newSource("sounds/Music_Loop.wav", "stream")
    foodEatSound = love.audio.newSource("sounds/Action_Eat_03.wav", "static")
    recordSound = love.audio.newSource("sounds/Jingle_Bonus.wav", "static")
    gameOverSound = love.audio.newSource("sounds/Jingle_Game_Over_02.wav", "static")

    -- Set volume levels
    backgroundMusic:setVolume(1) -- Adjust the volume as needed
    foodEatSound:setVolume(2) -- Adjust the volume as needed

    -- Start playing background music
    backgroundMusic:setLooping(true)
    backgroundMusic:play()

    -- Set up game variables
    tileSize = 1280/20
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
        -- Draw the background image
        love.graphics.draw(background, 0, 0)

    if gameState == GAME_STATE.PLAY then
        -- Draw game elements...
        drawSnake()
        drawFood()
        drawScore()
        drawTime()
    elseif gameState == GAME_STATE.START then
        -- Draw the "Press any key to start" message with blinking
        love.graphics.setFont(hugeRetroFont)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf('SNAKE GAME', 0, 100, love.graphics.getWidth(), 'center')

        love.graphics.setFont(smallRetroFont)
        if blinkVisible then
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf('Press any key to start', 0, 300, love.graphics.getWidth(), 'center')
        end
        love.graphics.setColor(1, 1, 1) -- Set default color
        
        
    elseif gameState == GAME_STATE.GAME_OVER then
        -- Draw the appropriate game over messages with blinking
        love.graphics.setFont(bigRetroFont)
        drawGameOverMessage()
    end
end

function love.keypressed(key)
    if gameState == GAME_STATE.START then
        -- Reset timeElapsed when the game starts
        timeElapsed = 0
        gameState = GAME_STATE.PLAY
    elseif gameState == GAME_STATE.PLAY then
        -- Handle player input during gameplay
        handlePlayerInput(key)
    elseif gameState == GAME_STATE.GAME_OVER then
        backgroundMusic:stop()
        if key == "space" then
            if score > highScore then
                highScore = score
                love.filesystem.write("highscore.txt", tostring(highScore))
                resetGame() -- Reset the game if a new record is achieved
            else
                gameState = GAME_STATE.START -- Start a new game if space is pressed
                resetGame()
            end
        end
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

        -- Play the food eat sound
        foodEatSound:play()
    else
        table.remove(snake)
    end
end

function drawSnake()
    -- Draw the snake's head
    local headSegment = snake[1]
    local headX = (headSegment.x - 1) * tileSize
    local headY = (headSegment.y - 1) * tileSize

    love.graphics.setColor(1, 1, 1)

    -- Determine the rotation angle based on the snake's movement direction
    local rotation = 0
    if direction == "up" then
        rotation = math.rad(270) -- Rotate by 270 degrees (counterclockwise)
    elseif direction == "down" then
        rotation = math.rad(90) -- Rotate by 90 degrees (counterclockwise)
    elseif direction == "left" then
        rotation = math.rad(180) -- Rotate by 180 degrees (counterclockwise)
    elseif direction == "right" then
        rotation = 0
    end

    -- Adjust rotation based on the sprite's default orientation
    rotation = rotation + math.rad(90)

    -- Draw the snake's head with rotation and scaling using snakeHead image
    local centerX = headX + tileSize / 2
    local centerY = headY + tileSize / 2
    local scale = 2 -- Scale the head to twice its size
    love.graphics.draw(snakeHead, centerX, centerY, rotation, scale, scale, snakeHead:getWidth() / 2, snakeHead:getHeight() / 2)

    -- Draw the rest of the body using snakeBody sprite
    for i = 2, #snake do
        local segment = snake[i]
        local segmentX = (segment.x - 1) * tileSize
        local segmentY = (segment.y - 1) * tileSize
        
        -- Scale the body segments and adjust position for centering
        local bodyScale = 1
        local offsetX = (tileSize - snakeBody:getWidth() * bodyScale) / 2
        local offsetY = (tileSize - snakeBody:getHeight() * bodyScale) / 2
        
        love.graphics.draw(snakeBody, segmentX + offsetX, segmentY + offsetY, 0, bodyScale)
    end
end

function drawFood()
    love.graphics.setColor(1, 1, 1)
    local scale = tileSize / foodImage:getWidth() -- Calculate the scale based on tileSize
    love.graphics.draw(foodImage, (food.x - 1) * tileSize, (food.y - 1) * tileSize, 0, scale, scale)
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
    backgroundMusic:stop()
    if score > highScore then
        recordSound:play()
        love.graphics.printf('Score: ' .. score, 0, 300, love.graphics.getWidth(), 'center')
        love.graphics.setFont(smallRetroFont)
        if blinkVisible then
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf('Congratulations! You made a new record', 0, 150, love.graphics.getWidth(), 'center')
        end
        love.graphics.setColor(1, 1, 1) -- restart colors
        love.graphics.printf('Press SPACE to restart', 0, 600, love.graphics.getWidth(), 'center')
    else
        gameOverSound:play()
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf('Score: ' .. score .. '\nHigh Score: ' .. highScore, 0, 300, love.graphics.getWidth(), 'center')
        love.graphics.setFont(smallRetroFont)
        if blinkVisible then
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf('Game Over! Press SPACE to restart', 0, 150, love.graphics.getWidth(), 'center')
        end
        love.graphics.setColor(1, 1, 1) -- restart colors
    end
end

function resetGame()
    SNAKE_MOVE_DELAY = 0.1 -- Reset the snake's initial move delay
    love.load()
    gameState = GAME_STATE.START
end

function checkCollision()
    -- Check collision with walls and snake's body
    local headX = snake[1].x
    local headY = snake[1].y

    -- Check collision with walls (2 rows from each side)
    if headX <= 1 or headX > love.graphics.getWidth() / tileSize - 1 or
       headY <= 1 or headY > love.graphics.getHeight() / tileSize - 1 then
        gameState = GAME_STATE.GAME_OVER -- Game Over
    end

    for i = 2, #snake do
        if headX == snake[i].x and headY == snake[i].y then
            gameState = GAME_STATE.GAME_OVER -- Game Over
        end
    end
end


function spawnFood()
    local maxX = love.graphics.getWidth() / tileSize - 1
    local maxY = love.graphics.getHeight() / tileSize - 1

    local availableTiles = {}

    -- Create a list of tiles that the snake is not occupying
    for x = 2, maxX do
        for y = 2, maxY do
            local isOccupied = false
            for i = 1, #snake do
                if x == snake[i].x and y == snake[i].y then
                    isOccupied = true
                    break
                end
            end
            if not isOccupied then
                table.insert(availableTiles, {x = x, y = y})
            end
        end
    end

    -- Remove tiles adjacent to the walls from the available tiles
    local function isAdjacentToWall(tile)
        return tile.x <= 2 or tile.x >= maxX or tile.y <= 2 or tile.y >= maxY
    end

    for i = #availableTiles, 1, -1 do
        if isAdjacentToWall(availableTiles[i]) then
            table.remove(availableTiles, i)
        end
    end

    -- Choose a random tile from the remaining available tiles for food spawn
    if #availableTiles > 0 then
        local randomIndex = love.math.random(1, #availableTiles)
        food.x = availableTiles[randomIndex].x
        food.y = availableTiles[randomIndex].y
    end
end



function drawTime()
    love.graphics.setFont(smallRetroFont)
    local formattedTime = string.format("Time: %.2f", timeElapsed)
    love.graphics.print(formattedTime, 20, 20)
end
