--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.level = params.level
  

    self.hasKey = true

-- Iterate through the bricks to check for a key
for _, brick in pairs(self.bricks) do
    if brick.key then
        self.hasKey = false
        break
    end
end

-- Initialize the balls table with the given ball
self.balls = {
    params.ball
}

-- Initialize the powers table as an empty table
self.powers = {}


self.recoverPoints = 6000
self.hitsLastDrop = 0

    -- give ball random starting velocity
    self.balls[1].dx = math.random(-200, 200)
    self.balls[1].dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        -- If the game is paused and the space key is pressed, unpause the game
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        -- If the game is not paused and the space key is pressed, pause the game
        self.paused = true
        gSounds['pause']:play()
        return
    end
    
    -- Update positions based on velocity
    self.paddle:update(dt)
    
    for _, ball in pairs(self.balls) do
        ball:update(dt)
    end
    
    for _, power in pairs(self.powers) do
        power:update(dt)
    end
    
    for i = #self.powers, 1, -1 do
        -- Check for collision between power-ups and the paddle
        if self.powers[i]:collides(self.paddle) then
            -- Add balls power-up
            if self.powers[i].skin == 9 then
                ball1 = self.powers[i]:addBall(self.paddle.x + (self.paddle.width / 2) - 2, self.paddle.y - 8)
                ball2 = self.powers[i]:addBall(self.paddle.x + (self.paddle.width / 2) - 6, self.paddle.y - 8)
                table.insert(self.balls, ball1)
                table.insert(self.balls, ball2)
            
            -- Heal power-up
            elseif self.powers[i].skin == 3 then
                self.health = self.powers[i]:heal(self.health)
            
            -- Grow paddle power-up
            elseif self.powers[i].skin == 5 then
                self.paddle.size, self.paddle.width = self.powers[i]:paddleUp(self.paddle.size, 4, self.paddle.width)
            
            -- Found key
            elseif self.powers[i].skin == 10 and not self.hasKey then
                for _, brick in pairs(self.bricks) do
                    if brick.key then
                        brick.found = true
                    end
                    self.hasKey = true
                end
            end
            
            -- Remove the power-up from the list after applying its effect
            table.remove(self.powers, i)
        end
    end
    
    for _, ball in pairs(self.balls) do
        if ball:collides(self.paddle) then
            -- Raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy
            
            -- Additional power-up drop chance
            -- Purpose: not to get stuck with the key brick
            self.hitsLastDrop = self.hitsLastDrop + 1
    
            --
            -- Tweak angle of bounce based on where it hits the paddle
            --
    
            -- If we hit the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            
            -- Else if we hit the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end
    
            gSounds['paddle-hit']:play()
        end
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        for _, ball in pairs(self.balls) do

        -- only check collision if we're in play
        if brick.inPlay and ball:collides(brick) then
            self.hitsLastDrop = self.hitsLastDrop + 1

            -- 10% base probability + 1% for each hit on brick or paddle
     if math.random(0, 100) <= self.hitsLastDrop + 10 then

    -- Check if health is at or above maximum (3)
    local hp = self.health >= 3
    
    -- Check if paddle size is at or above maximum (4)
    local pd = self.paddle.size >= 4
    
    -- Insert a new power-up into the powers table
    -- PowerUp:random() determines the type of power-up to generate based on current game state
    table.insert(self.powers, PowerUp(PowerUp:random(self.hasKey, hp, pd), brick.x, brick.y))
    
    -- Reset the hit counter for the next drop calculation
    self.hitsLastDrop = 0
    
     end

            -- add to score
            if not brick.key or brick.found then
            self.score = self.score + (brick.tier * 200 + brick.color * 25)
            end
            -- trigger the brick's hit function, which removes it from play
            brick:hit()

            -- if we have enough points, recover a point of health
            if self.score > self.recoverPoints then

                -- can't go above 3 health
                self.health = math.min(3, self.health + 1)

            -- for peddle size and width increase
            if self.paddle.size < 4 then
                -- Increase the paddle size by 1 if it is less than the maximum size (4)
                self.paddle.size = self.paddle.size + 1
                
                -- Increase the paddle width by 32 units to match the new size
                self.paddle.width = self.paddle.width + 32
            end

                -- multiply recover points by 2
                self.recoverPoints = self.recoverPoints + math.min(100000, self.recoverPoints * 2)

                -- play recover sound effect
                gSounds['recover']:play()
            end

            -- go to our victory screen if there are no more bricks left
            if self:checkVictory() then
                gSounds['victory']:play()

                gStateMachine:change('victory', {
                    level = self.level,
                    paddle = self.paddle,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    ball = ball,
                    recoverPoints = self.recoverPoints
                })
            end

            --
            -- collision code for bricks
            --
            -- we check to see if the opposite side of our velocity is outside of the brick;
            -- if it is, we trigger a collision on that side. else we're within the X + width of
            -- the brick and should check to see if the top or bottom edge is outside of the brick,
            -- colliding on the top or bottom accordingly 
            --

            -- left edge; only check if we're moving right, and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            if ball.x + 2 < brick.x and ball.dx > 0 then
                
                -- flip x velocity and reset position outside of brick
                ball.dx = -ball.dx
                ball.x = brick.x - 8
            
            -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
            -- so that flush corner hits register as Y flips, not X flips
            elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                
                -- flip x velocity and reset position outside of brick
                ball.dx = -ball.dx
                ball.x = brick.x + 32
            
            -- top edge if no X collisions, always check
            elseif ball.y < brick.y then
                
                -- flip y velocity and reset position outside of brick
                ball.dy = -ball.dy
                ball.y = brick.y - 8
            
            -- bottom edge if no X collisions or top collision, last possibility
            else
                
                -- flip y velocity and reset position outside of brick
                ball.dy = -ball.dy
                ball.y = brick.y + 16
            end

            -- slightly scale the y velocity to speed up the game, capping at +- 150
            if math.abs(ball.dy) < 150 then
                ball.dy = ball.dy * 1.02
            end

            -- only allow colliding with one brick, for corners
            break
        end
    end
end

-- Remove power-ups that have fallen off the screen
 for i = #self.powers, 1, -1 do
    -- Check if the power-up's y-coordinate is greater than or equal to the virtual screen height
    if self.powers[i].y >= VIRTUAL_HEIGHT then
        -- Remove the power-up from the powers table
        table.remove(self.powers, i)
    end
 end


    -- If ball goes below bounds, remove it from the game
for i = #self.balls, 1, -1 do
    if self.balls[i].y >= VIRTUAL_HEIGHT then
        table.remove(self.balls, i)
    end
end

-- If no balls are left, revert to serve state and decrease health
if #self.balls == 0 then
    -- Reduce paddle size if it's greater than the minimum size (2)
    if self.paddle.size > 2 then
        self.paddle.size = self.paddle.size - 1
        self.paddle.width = self.paddle.width - 32
    end

    -- Decrease player's health
    self.health = self.health - 1
    gSounds['hurt']:play()

    -- If health reaches 0, change to game-over state
    if self.health == 0 then
        gStateMachine:change('game-over', {
            score = self.score,
            highScores = self.highScores
        })
    else
        -- Otherwise, change to serve state to continue playing
        gStateMachine:change('serve', {
            paddle = self.paddle,
            bricks = self.bricks,
            health = self.health,
            score = self.score,
            highScores = self.highScores,
            level = self.level,
            recoverPoints = self.recoverPoints
        })
    end
end

-- Update particle systems for all bricks
for k, brick in pairs(self.bricks) do
    brick:update(dt)
end

-- Quit the game if 'escape' key is pressed
if love.keyboard.wasPressed('escape') then
    love.event.quit()
end
end
-- Function to render the play state
function PlayState:render()
    -- Render all bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- Render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    -- Render the paddle
    self.paddle:render()

    -- Render all balls
    for _, ball in pairs(self.balls) do
        ball:render()
    end

    -- Render all power-ups
    for _, power in pairs(self.powers) do
        power:render()
    end

    -- Render the score and health
    renderScore(self.score)
    renderHealth(self.health)

    -- Display pause text if the game is paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

-- Function to check for victory (all bricks are destroyed)
function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end