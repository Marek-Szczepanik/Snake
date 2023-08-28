# Snake Game in Lua using LÖVE Framework

#### Video Demo: https://youtu.be/neNDCdkLVrg

#### Description:
This project is a simple Snake game implemented in Lua using the LÖVE framework. The game features a classic Snake gameplay, where the player controls a snake that grows in length as it consumes food items. The objective is to eat as much food as possible without colliding with the walls or the snake's own body.


### How to Play:
1. Start the game by pressing any key.
2. Control the snake's movement using the arrow keys.
3. Eat food to increase your score and snake's length.
4. Avoid collisions with walls and your own body.
5. Try to achieve a new high score!


### Implementation:
# Constants and Game Variables:
The game starts by defining constants and game variables. The GAME_STATE table represents different game states like START, PLAY, and GAME_OVER. The BLINK_INTERVAL sets the interval for blinking messages, and SNAKE_MOVE_DELAY determines the initial delay for the snake's movement.

# Loading Phase (love.load()):
In this phase, the game window is configured, graphics filters are set, and various assets like images for the background, food, snake segments, and fonts are loaded. Sound sources for background music, eating food, record achievement, and game over are initialized with volume levels. The initial game variables like tileSize, snake, food, direction, and timer are set up. The high score is also loaded from the file "highscore.txt."

# Update Phase (love.update(dt)):
In this phase, the game's logic is updated. If the game is in the PLAY state, the timer for snake movement is decremented. The snake's speed gradually increases every timeToIncreaseSpeed seconds, and its movement delay (SNAKE_MOVE_DELAY) decreases by a certain speedIncreaseAmount. When the timer reaches 0, the moveSnake() function is called to move the snake and check for collisions.

# Drawing Phase (love.draw()):
This phase handles rendering the game elements on the screen. Depending on the game state, different elements are drawn. During the PLAY state, the snake, food, score, and timer are drawn using relevant functions. In the START state, a blinking "Press any key to start" message is displayed. In the GAME_OVER state, the game over message is displayed, showing the player's score and possibly the new high score.

# User Input Handling (love.keypressed(key)):
This function handles user input. If the game is in the START state, pressing any key initiates the game by transitioning to the PLAY state. In the PLAY state, arrow keys control the snake's direction. In the GAME_OVER state, pressing the "space" key restarts the game with either a new high score or the existing high score, depending on the player's achievement.

# Snake Movement (moveSnake()):
This function calculates the next position of the snake's head based on the current direction. If the head collides with the food, the score is increased, and new food is spawned. Otherwise, the snake's tail is removed, simulating its movement.

# Collision Detection (checkCollision()):
This function checks for collisions between the snake's head and the walls or its own body. If a collision occurs, the game transitions to the GAME_OVER state.

# Food Spawning (spawnFood()):
This function spawns food on the game grid. It generates a list of available tiles that the snake is not occupying and removes tiles adjacent to the walls to prevent food from spawning in unreachable places. Then, a random tile from the remaining available tiles is chosen as the food's location.

# Drawing the Snake and Food:
The drawSnake() function is responsible for rendering the snake on the screen, including its head and body segments. The snake's head is rotated based on its movement direction, and the body segments are scaled and positioned accordingly. The drawFood() function renders the food item on the screen.

# Drawing Score and Time:
The drawScore() function displays the player's current score on the screen. The drawTime() function displays the elapsed time during gameplay.

# Game Reset (resetGame()):
This function resets the game variables and reloads the game assets, effectively restarting the game.

This Snake game implementation showcases a variety of game development concepts such as input handling, collision detection, sprite rendering, sound management, and game state management using Lua with the LÖVE framework. Players can enjoy the timeless Snake gameplay experience with updated features and visuals.
