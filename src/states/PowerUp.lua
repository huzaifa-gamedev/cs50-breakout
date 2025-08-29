PowerUp = Class{}

function PowerUp:init(skin,x,y )
    self.x = x
    self.y = y
    self.width = 16
    self.height = 16
    self.skin = skin
    self.dy = 25
end

-- Function to return a random power-up type based on conditions
function PowerUp:random(key, hp, pd)
    local powerup = {9, 5, 3, 10}  -- List of power-up types

    local max = 4  -- Maximum number of power-ups available

    -- Remove key power-up if key condition is met
    if key then
        max = max - 1
        table.remove(powerup, 4)
    end

    -- Remove heal power-up if health condition is met
    if hp then
        max = max - 1
        table.remove(powerup, 3)
    end

    -- Remove paddle-up power-up if paddle size condition is met
    if pd then
        max = max - 1
        table.remove(powerup, 2)
    end

    -- Select a random power-up from the remaining ones
    local rand = math.random(1, max)
    return powerup[rand]
end

-- Function to add a new ball at a given position
function PowerUp:addBall(x, y)
    local ball = Ball(math.random(7))  -- Create a new ball with a random skin

    ball.x = x
    ball.y = y
    ball.dy = math.random(50, 200)  -- Set a random vertical speed for the ball

    return ball
end

-- Function to heal the player by increasing their health
function PowerUp:heal(health)
    gSounds['recover']:play()
    return math.min(3, health + 1)  -- Increase health by 1, up to a maximum of 3
end

-- Function to increase the paddle size if it is below the maximum size
function PowerUp:paddleUp(size, max_size, width)
    if size < max_size then
        size = size + 1
        width = width + 32  -- Increase paddle width by 32 units
    end

    return size, width
end

-- Function to check if the power-up collides with a target (e.g., paddle)
function PowerUp:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end 

    return true
end

-- Function to update the position of the power-up
function PowerUp:update(dt)
    self.y = self.y + self.dy * dt  -- Move the power-up down the screen
end

-- Function to render the power-up on the screen
function PowerUp:render()
    love.graphics.draw(gTextures['main'], gFrames['powers'][self.skin],
        self.x, self.y)  -- Draw the power-up at its current position
end