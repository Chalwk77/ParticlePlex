local math, physics = require("math"), require('physics')

physics.start()
physics.setGravity( 0, 0 )

display.setStatusBar( display.HiddenStatusBar )

local screenW, screenH = display.contentWidth, display.contentHeight
local playerX, playerY = (screenW / 2), (screenH / 2)

local player = display.newRect( 0, 0, 30, 30 )
player.x = playerX
player.y = playerY

-- local sinT = display.newText("", 100, 10)
-- local cosT = display.newText("", 100, 30)
local angleT = display.newText("", 100, 70)

local function onScreenTouch( event )
    if (event.phase == "began") then
        speed = 3
        deltaX = event.x - playerX
        deltaY = event.y - playerY

        angle = math.atan2( deltaY, deltaX ) * 180 / math.pi

        -- sin, cos = math.sin( angle ), math.cos( angle )

        -- sinT.text = sin
        -- cosT.text = cos
        angleT.text = angle

        bullet = display.newRect( 0, 0, 6, 6 )
        bullet.x = playerX
        bullet.y = playerY

        physics.addBody( bullet )

        bullet:setLinearVelocity( math.cos( angle ) * speed, math.sin( angle ) * speed )
    end
end

Runtime:addEventListener( "touch", onScreenTouch )
