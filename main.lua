push = require 'push'

Class = require 'class'

require 'Paddle'

require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest','nearest')

    love.window.setTitle('Pong')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('/fonts/font.ttf',8)
    largeFont = love.graphics.newFont('/fonts/font.ttf', 16)
    scoreFont = love.graphics.newFont('/fonts/font.ttf',32)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH-15, VIRTUAL_HEIGHT-50, 5, 20)

    ball = Ball(VIRTUAL_WIDTH/2-2, VIRTUAL_HEIGHT/2-2, 4 ,4)

    player1Score = 0
    player2Score = 0

    servingPlayer = 1
    winningPlayer = 0

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    --change the velocity according to ther serving player
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140,200)
        else
            ball.dx = -math.random(140,200)
        end
    elseif gameState == 'play' then
        --if collision occurs then reverse the velocity and set x away from paddle
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5
            --randomise y velocity
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            --play sound
            sounds['paddle_hit']:play()
        end
        --if collision occurs then reverse the velocity and set x away from paddle
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4
            --randomise y velocity
            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
            --play sound
            sounds['paddle_hit']:play()
        end

        -- detect upper and lower screen boundary collision and reverse if collided
        if ball.y <= 5 then
            ball.y = 5
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        -- 4 to account for the ball's size
        if ball.y >= VIRTUAL_HEIGHT - 9 then
            ball.y = VIRTUAL_HEIGHT - 9
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
    elseif gameState == 'over' then
        ball:reset()
        -- reset scores to 0
        player1Score = 0
        player2Score = 0

        -- decide serving player as the opposite of who won
        if winningPlayer == 1 then
            servingPlayer = 2
        else
            servingPlayer = 1
        end
    end


     --inrement score
    if ball.x < 0 then
        servingPlayer = 1
        player2Score = player2Score + 1
        sounds['score']:play()
        if player2Score == 10 then
            winningPlayer = 2
            gameState = 'over'
        else
            gameState = 'serve'
            ball:reset()
        end
    elseif ball.x > VIRTUAL_WIDTH - 4 then
        servingPlayer = 2
        player1Score = player1Score + 1
        sounds['score']:play()
        if player1Score == 10 then
            winningPlayer = 1
            gameState = 'over'
        else
            gameState = 'serve'
            ball:reset()
        end
    end

    --player1 movement
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    --computer movement
    -- if gameState == "play" then
    -- if ball.x > VIRTUAL_WIDTH / 2 - 30 then
    --     if ball.y < math.random(player2.y,player2.y-5) then
    --         player2.dy = -PADDLE_SPEED
    --     elseif ball.y > math.random(player2.y,player2.y+5) then
    --         player2.dy = PADDLE_SPEED
    --     else
    --         player2.dy = 0
    --     end
    -- else
    --     player2.dy = 0
    -- end
--end


    --ballmovement
    if gameState == 'play' then
        ball:update(dt)
    end
 
    player1:update(dt)
    player2:update(dt)

end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'over' then
            gameState = 'serve'
            ball:reset()

            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(30/255, 35/255, 42/255, 255/255)

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
        -- no UI messages to display in play
    elseif gameState == 'over' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    displayScore()

    player1:render()
    player2:render()
    ball:render()

    displayFPS()

    push:apply('end')
end

function displayScore()
    -- score display
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end

function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 20, 10)
    love.graphics.setColor(1, 1, 1, 1)
end