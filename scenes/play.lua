-- play.lua for Particle Plex
-- Copyright 2018 Jericho Crosby
local _W = display.contentWidth
local composer = require('composer')
local widget = require('widget')
local sounds = require('libraries.sounds')
local databox = require('libraries.databox')
local colors = require('classes.colors-rgb')
local relayout = require('libraries.relayout')
local slide = require('modules.slide_menu')
local toast = require('modules.toast')
local health = require('modules.healthbar')
local scene = composer.newScene()
widget.setTheme("widget_theme_ios")
-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called.
-- -----------------------------------------------------------------------------------------------------------------

-- most commonly used screen coordinates
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

local sidebar = { }
local sidebar_group = display.newGroup()

local visualButtons = { }
local soundsButtons = { }
iconWidth = 32
iconHeight = 38

-- Used to control the various game modes.
local spawnConstraint = "no"
local player
-- Used to calculate the time delta between calls of the _animate function.
local tPrevious = system.getTimer( )
-- The objects table holds all _animated objects except the player and the menu.
objects = {}
-- Used to alter the speed of the red and green squares. Normal speed. Traffic rush. Traffic jam.
local speedFactor = 1

-- used for collision combos -
local collisionCombo = 0
comboCount = {}
comboCount[1] = {2}
comboCount[2] = {4}
comboCount[3] = {5}
comboCount[4] = {6}
comboCount[5] = {7}
comboCount[6] = {8}
comboCount[7] = {9}
comboCount[8] = {10}
comboCount[9] = {11}
comboCount[10] = {12}
-------------------------------
-- default health --
healthRemaining = 100

-- Particle specs
local specs = {
    {w = 191, h = 180},
    {w = 203, h = 185},
    {w = 196, h = 175},
    {w = 180, h = 182},
    {w = 185, h = 181}
}
local collision_dimentions = {
    {w = 191, h = 180},
    {w = 203, h = 185},
    {w = 196, h = 175},
    {w = 180, h = 182},
}

colors = { }
colors[1] = { "red" }
colors[2] = { "yellow" }
colors[3] = { "pink" }
colors[4] = { "green" }
colors[5] = { "purple" }
colors[6] = { "orange" }
colors[7] = { "blue" }
colors[8] = { "indigo" }
colors[9] = { "violet" }
colors[10] = { "white" }
colors[11] = { "black" }

--------------- FUNCTION VARIABLES ---------------
-- Variables to hold the function pointers.
-- This is only to have one place to show them off.
local gameHasStarted = true
local loadScores
local saveScores

local loadCredits
local saveCredits

local createPlayer
local calculateNewVelocity
local OnNewGame
local createMenu
local OnGameEnd
local ConstrainToScreen
local onTouch
local spawn
local gameSpecial
local onCollision
local OnTick
local randomSpeed
local gamereset = false
local menu_bool = false

--------------- VARIABLES ---------------
local background
local menu
local score
local points = 0
local collisions = 0
local highScore
local invulnerable = true
canSpawnItems = true
local scoreLabel
local rewardLabel
local rewardBar
local penaltyLabel
local penaltyBar
local physics
local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY

--------------- FUNCTIONS ---------------
-- Load scores from file. Returns the score and the highScore. In this order.
loadScores = function( )
    local scores = {}
    local str = ""
    local n = 1
    local path = system.pathForFile( "score.txt", system.DocumentsDirectory )
    local file = io.open ( path, "r" )
    if file == nil then
        return 0, 0
    end
    local contents = file:read( "*a" )
    file:close()
    for i = 1, string.len( contents ) do
        local char = string.char( string.byte( contents, i ) )
        if char ~= "|" then
            str = str..char
        else
            scores[n] = tonumber( str )
            n = n + 1
            str = ""
        end
    end
    return scores[1], scores[2]
end

-- Stores scores to file. Takes two parameters. The last score and the highest score.
saveScores = function( s, hs )
    local path = system.pathForFile( "score.txt", system.DocumentsDirectory )
    local file = io.open ( path, "w" )
    local contents = tostring( s ).."|"..tostring(hs).."|"
    file:write( contents )
    file:close( )
end

-- Stores credits to file. Takes one parameter: credits
saveCredits = function( cr )
    local path = system.pathForFile( "credits.txt", system.DocumentsDirectory )
    local file = io.open ( path, "w" )
    local contents = tostring( cr ).."|"
    file:write( contents )
    file:close( )
end

-- Load credits from file. Returns credits
loadCredits = function( )
    local cr = {}
    local str = ""
    local n = 1
    local path = system.pathForFile( "credits.txt", system.DocumentsDirectory )
    local file = io.open ( path, "r" )
    if file == nil then
        return 0, 0
    end
    local contents = file:read( "*a" )
    file:close()
    for i = 1, string.len( contents ) do
        local char = string.char( string.byte( contents, i ) )
        if char ~= "|" then
            str = str..char
        else
            cr[n] = tonumber( str )
            n = n + 1
            str = ""
        end
    end
    return cr[1]
end

-- Creates and returns a new player.
function createPlayer( x, y, width, height, rotation, visible )
    local playerCollisionFilter = { categoryBits = 2, maskBits = 5 }
    local playerBodyElement = { filter = playerCollisionFilter }
    if settings["useOtherPlayer"] then
        local p = display.newImageRect('player.png', width, height)
        playerObject = p
    else
        local p = display.newRect(x, y, width, height)
        playerObject = p
    end
    if bgColor == "red" then
        playerObject:setFillColor(colorsRGB.RGB("red"))
    elseif bgColor == "yellow" then
        playerObject:setFillColor(colorsRGB.RGB("yellow"))
    elseif bgColor == "pink" then
        playerObject:setFillColor(colorsRGB.RGB("pink"))
    elseif bgColor == "green" then
        playerObject:setFillColor(colorsRGB.RGB("green"))
    elseif bgColor == "purple" then
        playerObject:setFillColor(colorsRGB.RGB("purple"))
    elseif bgColor == "orange" then
        playerObject:setFillColor(colorsRGB.RGB("orange"))
    elseif bgColor == "blue" then
        playerObject:setFillColor(colorsRGB.RGB("blue"))
    elseif bgColor == "black" then
        playerObject:setFillColor(colorsRGB.RGB("black"))
    elseif bgColor == "white" then
        playerObject:setFillColor(colorsRGB.RGB("white"))
    else
        playerObject:setFillColor(colorsRGB.RGB("white"))
    end
    playerObject.isBullet = true
    playerObject.objectType = "player"
    physics.addBody ( playerObject, "dynamic", playerBodyElement )
    playerObject.isVisible = visible
    playerObject.rotation = rotation
    playerObject.resize = false
    playerObject.isSleepingAllowed = false

    if settings["useOtherPlayer"] then
        playerObject.x = x
        playerObject.y = y
    end

    playerObject.anchorX = 0.5
    playerObject.anchorY = 0.5
    return playerObject
end

-- Returns a random speed
function randomSpeed( )
    if (speedMin ~= nil) or (speedMax ~= nil) then
        return math.random(speedMin, speedMax) / 10 * speedFactor + offset
    else
        return math.random(1, 2) / 10 * speedFactor
    end
end

-- Cycles through all objects to adjust the velocity.
calculateNewVelocity = function( t )
    for _, object in pairs ( t ) do
        object.xVelocity = object.xVelocity * speedFactor
        object.yVelocity = object.yVelocity * speedFactor
    end
end

-- Starts a new game round. Resets some properties first.
function OnNewGame()
    canSpawnItems = true
    if nextGameBool then
        healthRemaining = 100
        nextGameBool = false
        healthAnimation( )
    end
    if win_reset_bool then
        runHealthAnimation = true
        healthRemaining = 100
        nextGameBool = false
        win_reset_bool = false
        healthAnimation( )
    end

    gameIsOver = false
    score = 0
    if credits ~= nil then
        credits = credits
    else
        credits = 0
    end
    gameHasStarted = true
    gamestarted = true
    if settings["delayCollision"] then
        timer.performWithDelay( settings["invulnerableTimer"], checkInvulnerability )
    end
    player.width = 20
    player.height = 20
    player.x = centerX
    player.y = centerY
    player.resize = true
    speedFactor = 1
    scoreLabel.text = tostring ( score )
    scoreLabel.isVisible = true
    ingameHighestScoreLabel.text = tostring ( "highest score: " .. highScore )
    ingameHighestScoreLabel.isVisible = true
    player.isVisible = true
    topLine:setStrokeColor(colorsRGB.RGB("blue"))
    bottomLine:setStrokeColor(colorsRGB.RGB("blue"))
    rightLine:setStrokeColor(colorsRGB.RGB("blue"))
    leftLine:setStrokeColor(colorsRGB.RGB("blue"))
    topLine.alpha = 0.35
    bottomLine.alpha = 0.35
    rightLine.alpha = 0.35
    leftLine.alpha = 0.35
end

-- Saves the scores, shows the menu etc.
function OnGameEnd( )
    nextGameBool = true

    healthLabel1.isVisible = false
    healthLabel2.isVisible = false
    healthLabel3.isVisible = false
    healthLabel4.isVisible = false
    healthLabel5.isVisible = false

    if collisionTimer ~= nil then
        timer.cancel(collisionTimer)
    end
    if singleGrab ~= nil then
        singleGrab.alpha = 0
    end

    -- reset collisionCombo --
    collisionCombo = 0

    gameIsOver = true
    gameHasStarted = false
    invulnerable = true

    if credits > 0 then
        credits = credits
    end

    if score > highScore then
        highScore = score
        newHighScore = true
        sounds.play( "onWin" )
    else
        newHighScore = false
        sounds.play( "onFailed" )
    end

    -- save score | highscore | credits
    saveScores( score, highScore )
    saveCredits( credits )

    rewardLabel.alpha = 0
    penaltyLabel.alpha = 0
    penaltyBar.alpha = 0
    rewardBar.alpha = 0
    spawnConstraint = "no"
    player.isVisible = false
    changeBorderColor = false
    rewardBar.isVisible = false
    penaltyBar.isVisible = false
    levelLabel.isVisible = false
    scoreLabel.isVisible = false
    scoreRemaining.isVisible = false
    ingameHighestScoreLabel.isVisible = false
    topLine:setStrokeColor(0, 0, 0)
    bottomLine:setStrokeColor(0, 0, 0)
    rightLine:setStrokeColor(0, 0, 0)
    leftLine:setStrokeColor(0, 0, 0)
    topLine.alpha = 0
    bottomLine.alpha = 0
    rightLine.alpha = 0
    leftLine.alpha = 0

    local spacing = 30
    lastScoreLabel = display.newText( "score: " .. score, 0, 0, native.systemFont, 15 )
    lastScoreLabel.x = centerX
    lastScoreLabel.y = centerY - 20
    lastScoreLabel:setFillColor( colorsRGB.RGB("white") )
    lastScoreLabel.alpha = 0.55

    highScoreLabel = display.newText( "highest score: " .. highScore, 0, 0, native.systemFont, 15 )
    HighScoreLabel = highScoreLabel
    highScoreLabel.x = centerX
    highScoreLabel.y = lastScoreLabel.y + spacing
    highScoreLabel:setFillColor( colorsRGB.RGB("white") )
    highScoreLabel.alpha = 0.55

    gamereset = true
    canSpawnItems = false
    Runtime:removeEventListener( "enterFrame", OnTick )
    Runtime:removeEventListener( "collision", onCollision )
end

-- Saves the scores, shows the menu etc.
gameOverWon = function( )
    gameIsOver = true
    if score > highScore then
        highScore = score
        newHighScore = true
        sounds.play( "onWin" )
    else
        if (wonTheGame == true) then
            wonTheGame = false
            sounds.play( "onWin" )
        else
            newHighScore = false
            sounds.play( "onFailed" )
        end
    end

    healthLabel1.isVisible = false
    healthLabel2.isVisible = false
    healthLabel3.isVisible = false
    healthLabel4.isVisible = false
    healthLabel5.isVisible = false

    -- save score | highscore | credits
    saveScores( score, highScore )
    saveCredits( credits )

    rewardLabel.alpha = 0
    penaltyLabel.alpha = 0
    penaltyBar.alpha = 0
    rewardBar.alpha = 0
    spawnConstraint = "no"
    player.isVisible = false
    changeBorderColor = false
    rewardBar.isVisible = false
    penaltyBar.isVisible = false
    levelLabel.isVisible = false
    scoreLabel.isVisible = false
    scoreRemaining.isVisible = false
    ingameHighestScoreLabel.isVisible = false
    topLine:setStrokeColor(0, 0, 0)
    bottomLine:setStrokeColor(0, 0, 0)
    rightLine:setStrokeColor(0, 0, 0)
    leftLine:setStrokeColor(0, 0, 0)
    topLine.alpha = shade
    bottomLine.alpha = shade
    rightLine.alpha = shade
    leftLine.alpha = shade
    for _, object in pairs ( objects ) do
        object.alpha = gameIsOver and 20 / 255 or 255 / 255
    end
    local options = {effect = "crossFade", time = 200}
    composer.gotoScene( 'scenes.win_scene', options )
end

-- Forces the object (player) to stay within the visible screen bounds.
ConstrainToScreen = function( object )
    if object.x < object.width then
        object.x = object.width
    end
    if object.x > display.viewableContentWidth - object.width then
        object.x = display.viewableContentWidth - object.width
    end
    if object.y < object.height then
        object.y = object.height
    end
    if object.y > display.viewableContentHeight - object.height then
        object.y = display.viewableContentHeight - object.height
    end
end

-- Processes the touch events on the background. Moves the player object accordingly.
onTouch = function(event)
    if gameIsOver then return end
    if event.phase == "began" then
        if settings["delayOnTouch"] then invulnerable = false end
        player.isFocus = true
        player.x0 = event.x - player.x
        player.y0 = event.y - player.y
        keyisup = false
        keyisdown = false
        keyisleft = false
        keyisright = false
        if gameHasStarted and slideMenuOpen and not colorUpdated then slide:hide_slide_menu() end
    elseif player.isFocus then
        if event.phase == "moved" then
            player.x = event.x - player.x0
            player.y = event.y - player.y0
            ConstrainToScreen( player )
        elseif event.phase == "ended" or event.phase == "cancelled" then
            player.isFocus = false
        end
    end
    return true
end

-- objectType is "food", "poison", "reward", or "penalty"
function spawn( objectType, xVelocity, yVelocity )
    if ( canSpawnItems ) then
        local object
        local sizeXY = math.random( 10, 20 )
        local startX
        local startY
        if 0 == xVelocity then
            -- Object moves along the y-axis
            startX = math.random( sizeXY, display.contentWidth - sizeXY )
        end
        if xVelocity < 0 then
            -- Object moves to the left
            startX = display.contentWidth
        end
        if xVelocity > 0 then
            -- Object moves to the right
            startX = -sizeXY
        end
        if 0 == yVelocity then
            -- Object moves along the x-axis
            startY = math.random( sizeXY, display.contentHeight - sizeXY )
        end
        if yVelocity < 0 then
            -- Object moves to the top
            startY = display.contentHeight
        end
        if yVelocity > 0 then
            -- Object moves to the bottom
            startY = -sizeXY
        end
        local collisionFilter = { categoryBits = 4, maskBits = 2 } -- collides with player only
        local body = { filter = collisionFilter, isSensor = true }
        if "food" == objectType then
            local healthyFood_W = 32
            local healthyFood_H = 32
            local randomNumber = math.random(1, 100)
            object = display.newImageRect('images/healthy food/'..randomNumber..'.png', healthyFood_W, healthyFood_H)
            object.x = startX
            object.y = startY
            object.sizeXY = sizeXY
        elseif "poison" == objectType then
            local randomSize = math.random(1, 2)
            if randomSize == 1 then
                sizeXY = sizeXY - sizeXY + math.random(settings["minSize"], settings["maxSize"])
            else
                sizeXY = sizeXY
            end
            local poisonousFood_W = 32
            local poisonousFood_H = 32
            local random_number = math.random(1, 3)
            object = display.newImageRect('images/poisonous food/'..random_number..'.png', poisonousFood_W, poisonousFood_H)
            object.x = startX
            object.y = startY
            object.sizeXY = sizeXY
        end
        if "reward" == objectType or "penalty" == objectType then
            object = display.newImageRect('images/powerups/powerup.png', 32, 32)
            object.x = startX
            object.y = startY
            object.sizeXY = 0
            local alphaFrom = 0.25
            local alphaTo = 1
            local scaleFrom = 0.7
            local scaleTo = 1
            local animationTime = 250
            local function animate_powerup( )
                local scaleUp = function( )
                    powerup_animation = transition.to( object, { time = animationTime, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = animate_powerup } )
                end
                powerup_animation = transition.to( object, { time = animationTime, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp } )
            end
            -- initialize animation
            animate_powerup( )
        end
        object.objectType = objectType
        object.xVelocity = xVelocity
        object.yVelocity = yVelocity
        physics.addBody( object, body )
        object.alpha = 1
        object.isFixedRotation = true
        table.insert ( objects, object )
    end
end

-- The game has different modes to make it interesting.
gameSpecial = function( objectType )
    local random_powerup = math.random ( 1, 4 )

    local removeLoadingIcon = function()
        revolving_loading.isVisible = false
    end

    if "reward" == objectType then
        objectWasReward = true
        -- Decide which reward we are playing
        if (random_powerup == 1) then
            -- Play weight loss - small player
            player.width = 15
            player.height = 15
            player.resize = true
            rewardLabel.text = "weight loss"
            rewardLabel.alpha = 0.75
            Time = 1000
            transition.to ( rewardLabel, { time = Time, alpha = 0, delay = 3000 } )
        elseif (random_powerup == 2) then
            -- Play all you can eat - all enemies will turn into food
            rewardLabel.text = "all you can eat"
            rewardLabel.alpha = 0.75
            transition.to ( rewardLabel, { time = 1500, alpha = 0, delay = 4500 } )
            rewardBar.isVisible = true
            spawnConstraint = "allyoucaneat"
            local closure = function()
                spawnConstraint = "no"
                rewardBar.width = 280
                rewardBar.isVisible = false
            end
            Time = 5000
            transition.to ( rewardBar, { time = Time, width = 0, onComplete = closure } )
        elseif (random_powerup == 3) then
            -- Play traffic jam - all objects move with half the speed
            if speedFactor ~= 1 then
                -- Skip this special, because rush hour seems to be running
                return
            end
            rewardLabel.text = "traffic jam"
            rewardLabel.alpha = 0.75
            transition.to ( rewardLabel, { time = 500, alpha = 0, delay = 4500 } )
            speedFactor = 0.5
            calculateNewVelocity( objects )
            rewardBar.isVisible = true
            local closure = function()
                speedFactor = 2
                calculateNewVelocity( objects )
                speedFactor = 1
                rewardBar.width = 280
                rewardBar.isVisible = false
            end
            Time = 5000
            transition.to ( rewardBar, { time = Time, width = 0, onComplete = closure } )
        else
            if healthRemaining < 100 then
                -- Give Extra Health
                local healthbonus = 25
                healthRemaining = healthRemaining + 25
                rewardLabel.text = "+" .. tostring(healthbonus) .. " health"
                rewardLabel.alpha = 0.75
                Time = 1000
                transition.to ( rewardLabel, { time = Time, alpha = 0, delay = 3000 } )
            end
        end
    elseif "penalty" == objectType then
        -- Decide which penalty we are playing
        if (random_powerup == 1) then
            -- Play weight gain - big player
            player.width = 50
            player.height = 50
            player.resize = true
            penaltyLabel.text = "weight gain"
            penaltyLabel.alpha = 0.75
            Time = 1000
            transition.to ( penaltyLabel, { time = Time, alpha = 0, delay = 3000 } )
        elseif (random_powerup == 2) then
            -- Play food contaminated - all food will turn into enemies
            penaltyLabel.text = "food contaminated"
            penaltyLabel.alpha = 0.75
            penaltyLabel.time = settings["FoodContaminatedTime"]
            transition.to ( penaltyLabel, { time = 500, alpha = 0, delay = 4500 } )
            penaltyBar.isVisible = true
            spawnConstraint = "foodcontaminated"
            local closure = function()
                spawnConstraint = "no"
                penaltyBar.width = 280
                penaltyBar.isVisible = false;
            end
            Time = settings["FoodContaminatedTime"]
            transition.to ( penaltyBar, { time = Time, width = 0, onComplete = closure } )
        else
            -- Play rush hour - all objects move with double speed
            if speedFactor ~= 1 then
                -- Skip this special, because traffic jam seems to be running
                return
            end
            penaltyLabel.text = "sugar rush!"
            penaltyLabel.alpha = 0.75
            transition.to ( penaltyLabel, { time = 500, alpha = 0, delay = 4500 } )
            speedFactor = 2
            calculateNewVelocity( objects )
            penaltyBar.isVisible = true
            local closure = function()
                speedFactor = 0.5
                calculateNewVelocity( objects )
                speedFactor = 1
                penaltyBar.width = 280
                penaltyBar.isVisible = false;
            end
            Time = 5000
            transition.to ( penaltyBar, { time = Time, width = 0, onComplete = closure } )
        end
    end
    local loadingIconGroup = display.newGroup()
    loadingIconGroup.x = rewardBar.x
    loadingIconGroup.y = rewardBar.y
    relayout.add(loadingIconGroup)
    for i = 1, 1 do
        revolving_loading = display.newImageRect(loadingIconGroup, 'images/loading/loading2.png', 64, 64)
        revolving_loading.x = 0
        revolving_loading.y = 0
        revolving_loading.anchorX = 0.5
        revolving_loading.anchorY = 0.5
        revolving_loading.rotation = 120 * i
        revolving_loading.alpha = 0.15
        transition.to(revolving_loading, {time = Time, rotation = 360, delta = true, onComplete = removeLoadingIcon})
    end
    rewardLabel.x = display.viewableContentWidth / 2
    rewardLabel.y = display.viewableContentHeight / 2 - 75
end

function checkInvulnerability()
    invulnerable = false
end

local seconds = 5
function countdown()
    seconds = seconds - 1
    secondsLeft = secondsToTime(seconds)
end

function secondsToTime(seconds)
    seconds = seconds % 60
    return seconds
end

collisionTimer = timer.performWithDelay(1000, countdown, seconds)

-- We want to get notified when a collision occurs
function onCollision( event )
    if gameIsOver then
        return
    end
    if "began" == event.phase then
        local o
        local ot
        if "player" == event.object1.objectType then
            o = event.object2
            ot = event.object2.objectType
        else
            o = event.object1
            ot = event.object1.objectType
        end
        if ("food" == ot and "no" == spawnConstraint) or "allyoucaneat" == spawnConstraint then
            -- Increase the score
            score = score + 1
            points = points + 1
            collisions = collisions + 1
            credits = credits + 1

            for i = 1, #level do
                if tonumber(score) == tonumber(level[i][3]) then
                    timer.performWithDelay( 100, levelupAnimation )
                end
            end

            -- ================== [ C O L L I S I O N   C O M B O S ] =============================================================--
            if settings["useCombos"] then
                collisionCombo = collisionCombo + 1
                if (tonumber(collisionCombo) > 5 and tonumber(collisionCombo) < 11) and (secondsLeft >= 1) then
                    comboText = display.newText( "combo +" .. collisionCombo, 0, 0, native.systemFontBold, 18 )
                    comboText.x = player.x
                    comboText.y = player.y
                    comboText:setFillColor( colorsRGB.RGB("blue") )
                    comboText.alpha = 1
                    sounds.play('onCombo')
                    score = score + collisionCombo
                    comboTimer = transition.to(comboText, { time = 1000, alpha = 0, x = player.x, y = player.y})
                    local index = math.random(1, 4)
                    local comboParticle = display.newImageRect('images/particle effects/combo particles/' .. index .. '.png', collision_dimentions[index].w, collision_dimentions[index].h)
                    comboParticle.x, comboParticle.y = player.x, player.y
                    local fromScale, toScale = math.random(0.1, 0.2), math.random(0.8, 0.8)
                    comboParticle:scale(fromScale, fromScale)
                    comboParticle:setFillColor(1, 0.9, 0.5)
                    comboParticleTimer = transition.to(comboParticle, {time = math.random(200, 400), xScale = toScale, yScale = toScale, alpha = 0.50, onComplete = function(object)
                        object:removeSelf()
                    end})
                end
                singleGrab = display.newText( "+" .. collisionCombo, 0, 0, native.systemFontBold, 16 )
                singleGrab.x = player.x + 45
                singleGrab.y = player.y
                singleGrab:setFillColor( colorsRGB.RGB("white") )
                singleTimer = transition.to(singleGrab, { time = 300, alpha = 0, x = player.x + 25, y = player.y})
                if secondsLeft ~= nil then
                    if secondsLeft <= 0 then
                        collisionCombo = 0
                        --print("Time ran out. Restarting collisionTimer.")
                        if collisionTimer ~= nil then timer.cancel(collisionTimer) end
                        collisionTimer = timer.performWithDelay(1000, countdown, seconds)
                    end
                    if collisionCombo >= 11 then collisionCombo = 0 seconds = 0 end
                end
            end
            -- ====================================================================================================================--
            if collisions == settings["collisions"] then invulnerable = false end
            scoreLabel.text = tostring(score)
            sounds.play("onPickup")
            for i = 1, #level do
                if tonumber(score) == tonumber(level[i][3]) then
                    sounds.play("onLevelup")
                    break
                end
            end
            if tonumber(score) >= tonumber(level[10][3]) then
                wonTheGame = true
                gameOverWon()
            end
            if player.width < 50 then
                player.width = player.width + 1
                player.height = player.height + 1
                player.resize = true
            end
            o.isVisible = false
        elseif "poison" == ot or "foodcontaminated" == spawnConstraint then
            local options = {effect = "crossFade", time = 200}
            healthRemaining = healthRemaining - 25
            if settings["delayCollision"] then
                if (invulnerable == false) then
                    if healthRemaining <= -25 then
                        current_level = levelNum
                        gameisrunning = false
                        canSpawnItems = false
                        gameIsOver = true
                        OnGameEnd()
                        composer.gotoScene( 'scenes.gameover', options )
                        if revolving_loading then revolving_loading.isVisible = false end
                    elseif healthRemaining >= 0 then
                        sounds.play("onDamage")
                        hitPoints = display.newText( "-" .. healthRemaining, 0, 0, native.systemFontBold, 18 )
                        hitPoints.x = player.x + 45
                        hitPoints.y = player.y
                        hitPoints:setFillColor( 255, 0, 0 )
                        hpTimer = transition.to(hitPoints, { time = 450, alpha = 0, x = player.x + 25, y = player.y})
                        -- disabled for now
                        --plTimer = transition.to(player, { time = 250, alpha = 0, iterations = 2, onComplete = function(player) player.alpha = 1 end})
                        local hitDisplay = display.newImageRect('images/particle effects/hit_sparks.png', 180, 182)
                        hitDisplay.x, hitDisplay.y = player.x, player.y
                        local fromScale, toScale = 0.3, 0.7
                        hitDisplay:scale(fromScale, fromScale)
                        hitDisplay:setFillColor(1, 0.9, 0.5)
                        transition.to(hitDisplay, {time = 250, xScale = toScale, yScale = toScale, alpha = 0.30, onComplete = function(object)
                            object:removeSelf()
                        end})
                    end
                end
            else
                if healthRemaining <= -25 then
                    current_level = levelNum
                    OnGameEnd()
                    canSpawnItems = false
                    composer.gotoScene( 'scenes.gameover', options )
                    if revolving_loading then revolving_loading.isVisible = false end
                    gameisrunning = false
                    gameIsOver = true
                elseif healthRemaining >= 0 then
                    sounds.play("onDamage")
                end
            end
            -- Object type is "reward" or "penalty"
        elseif "reward" == ot or "penalty" == ot then
            if settings["delayCollision"] then
                if (invulnerable == false) then
                    sounds.play( "onPickup" )
                    o.isVisible = false
                    gameSpecial(ot)
                else
                    -- delay collision
                end
            else
                sounds.play( "onPickup" )
                o.isVisible = false
                gameSpecial(ot)
            end
        end
        -- Particle Effects --
        if settings["delayCollision"] then
            if (invulnerable == false) then
                if ("food" == ot and "no" == spawnConstraint) then
                    local index = math.random(1, 5)
                    local foodParticle = display.newImageRect('images/particle effects/' .. index .. '.png', specs[index].w, specs[index].h)
                    foodParticle.x, foodParticle.y = player.x, player.y
                    local fromScale, toScale = math.random(0.1, 0.2), math.random(1, 2)
                    foodParticle:scale(fromScale, fromScale)
                    foodParticle:setFillColor(1, 0.9, 0.5)
                    transition.to(foodParticle, {time = math.random(200, 400), xScale = toScale, yScale = toScale, alpha = 0.15, onComplete = function(object)
                        object:removeSelf()
                    end})
                end
                if ("reward" == ot) then
                    sounds.play( "onPowerup" )
                    local index = math.random(1, 5)
                    local rewardParticle = display.newImageRect('images/particle effects/onPowerup.png', specs[index].w, specs[index].h)
                    rewardParticle.x, rewardParticle.y = player.x, player.y
                    local fromScale, toScale = math.random(0.1, 0.2), math.random(1, 2)
                    rewardParticle:scale(fromScale, fromScale)
                    rewardParticle:setFillColor(1, 0.9, 0.5)
                    transition.to(rewardParticle, {time = math.random(200, 400), xScale = toScale, yScale = toScale, alpha = 0.50, onComplete = function(object)
                        object:removeSelf()
                    end})
                elseif ("penalty" == ot) then
                    sounds.play( "onPenalty" )
                    local index = math.random(1, 5)
                    local penaltyParticle = display.newImageRect('images/particle effects/onPenalty.png', specs[index].w, specs[index].h)
                    penaltyParticle.x, penaltyParticle.y = player.x, player.y
                    local fromScale, toScale = math.random(0.1, 0.2), math.random(1, 2)
                    penaltyParticle:scale(fromScale, fromScale)
                    penaltyParticle:setFillColor(1, 0.9, 0.5)
                    transition.to(penaltyParticle, {time = math.random(200, 400), xScale = toScale, yScale = toScale, alpha = 0.75, onComplete = function(object)
                        object:removeSelf()
                    end})
                end
            end
        end
    end
end

function levelupAnimation()
    local index = math.random(1, 4)
    local comboParticle = display.newImageRect('images/particle effects/combo particles/' .. index .. '.png', collision_dimentions[index].w, collision_dimentions[index].h)
    comboParticle.x, comboParticle.y = player.x, player.y
    local fromScale, toScale = math.random(0.1, 0.2), math.random(0.8, 0.8)
    comboParticle:scale(fromScale, fromScale)
    comboParticle:setFillColor(1, 0.9, 0.5)
    comboParticleTimer = transition.to(comboParticle, {time = math.random(200, 400), xScale = toScale, yScale = toScale, alpha = 0.50, onComplete = function(object)
        object:removeSelf()
    end})
end

-- Animates all objects. Also resizes the player by removing and readding it to the physics world.
function OnTick( event )
    if not gameIsOver then
        local tDelta = event.time - tPrevious
        tPrevious = event.time
        for _, object in pairs ( objects ) do
            local xDelta = object.xVelocity * tDelta
            local yDelta = object.yVelocity * tDelta
            local xPos = xDelta + object.x
            local yPos = yDelta + object.y
            if (yPos > display.contentHeight + object.sizeXY) or (yPos < - object.sizeXY) or
            (xPos > display.contentWidth + object.sizeXY) or (xPos < - object.sizeXY) then
                object.isVisible = false
            end
            object:translate(xDelta, yDelta)
        end

        -- next game level handler --
        if gotoNextLevel == true then
            if levelNum == 1 then
                gotoNextLevel = false
                level[1] = { "level 1", { 1, 2, 0.010 }, 0, "1"}
                level[2] = { "level 2", { 1, 2, 0.015 }, 30, "2"}
                level[3] = { "level 3", { 1, 2, 0.025 }, 60, "3"}
                level[4] = { "level 4", { 1, 2, 0.035 }, 90, "4"}
                level[5] = { "level 5", { 1, 2, 0.045 }, 120, "5"}
                level[6] = { "level 6", { 1, 2, 0.055 }, 150, "6"}
                level[7] = { "level 7", { 1, 2, 0.065 }, 180, "7"}
                level[8] = { "level 8", { 1, 2, 0.075 }, 210, "8"}
                level[9] = { "level 9", { 1, 2, 0.085 }, 240, "9"}
                level[10] = { "level 10", { 1, 2, 0.085 }, 270, "10"}
            elseif levelNum == 2 then
                gotoNextLevel = false
                level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
                level[2] = { "level 2", { 1, 2, 0.015 }, 0, "2"}
                level[3] = { "level 3", { 1, 2, 0.025 }, 30, "3"}
                level[4] = { "level 4", { 1, 2, 0.035 }, 60, "4"}
                level[5] = { "level 5", { 1, 2, 0.045 }, 90, "5"}
                level[6] = { "level 6", { 1, 2, 0.055 }, 120, "6"}
                level[7] = { "level 7", { 1, 2, 0.065 }, 150, "7"}
                level[8] = { "level 8", { 1, 2, 0.075 }, 180, "8"}
                level[9] = { "level 9", { 1, 2, 0.085 }, 210, "9"}
                level[10] = { "level 10", { 1, 2, 0.085 }, 240, "10"}
            elseif levelNum == 3 then
                gotoNextLevel = false
                level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
                level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
                level[3] = { "level 3", { 1, 2, 0.025 }, 0, "3"}
                level[4] = { "level 4", { 1, 2, 0.035 }, 30, "4"}
                level[5] = { "level 5", { 1, 2, 0.045 }, 60, "5"}
                level[6] = { "level 6", { 1, 2, 0.055 }, 90, "6"}
                level[7] = { "level 7", { 1, 2, 0.065 }, 120, "7"}
                level[8] = { "level 8", { 1, 2, 0.075 }, 150, "8"}
                level[9] = { "level 9", { 1, 2, 0.085 }, 180, "9"}
                level[10] = { "level 10", { 1, 2, 0.085 }, 210, "10"}
            elseif levelNum == 4 then
                gotoNextLevel = false
                level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
                level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
                level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
                level[4] = { "level 4", { 1, 2, 0.035 }, 0, "4"}
                level[5] = { "level 5", { 1, 2, 0.045 }, 30, "5"}
                level[6] = { "level 6", { 1, 2, 0.055 }, 60, "6"}
                level[7] = { "level 7", { 1, 2, 0.065 }, 90, "7"}
                level[8] = { "level 8", { 1, 2, 0.075 }, 120, "8"}
                level[9] = { "level 9", { 1, 2, 0.085 }, 150, "9"}
                level[10] = { "level 10", { 1, 2, 0.085 }, 180, "10"}
            elseif levelNum == 5 then
                gotoNextLevel = false
                level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
                level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
                level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
                level[4] = { "level 4", { 1, 2, 0.035 }, nil, nil}
                level[5] = { "level 5", { 1, 2, 0.045 }, 0, "5"}
                level[6] = { "level 6", { 1, 2, 0.055 }, 30, "6"}
                level[7] = { "level 7", { 1, 2, 0.065 }, 60, "7"}
                level[8] = { "level 8", { 1, 2, 0.075 }, 90, "8"}
                level[9] = { "level 9", { 1, 2, 0.085 }, 120, "9"}
                level[10] = { "level 10", { 1, 2, 0.085 }, 150, "10"}
            elseif levelNum == 6 then
                gotoNextLevel = false
                level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
                level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
                level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
                level[4] = { "level 4", { 1, 2, 0.035 }, nil, nil}
                level[5] = { "level 5", { 1, 2, 0.045 }, nil, nil}
                level[6] = { "level 6", { 1, 2, 0.055 }, 0, "6"}
                level[7] = { "level 7", { 1, 2, 0.065 }, 30, "7"}
                level[8] = { "level 8", { 1, 2, 0.075 }, 60, "8"}
                level[9] = { "level 9", { 1, 2, 0.085 }, 90, "9"}
                level[10] = { "level 10", { 1, 2, 0.085 }, 120, "10"}
            elseif levelNum == 7 then
                gotoNextLevel = false
                level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
                level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
                level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
                level[4] = { "level 4", { 1, 2, 0.035 }, nil, nil}
                level[5] = { "level 5", { 1, 2, 0.045 }, nil, nil}
                level[6] = { "level 6", { 1, 2, 0.055 }, nil, nil}
                level[7] = { "level 7", { 1, 2, 0.065 }, 0, "7"}
                level[8] = { "level 8", { 1, 2, 0.075 }, 30, "8"}
                level[9] = { "level 9", { 1, 2, 0.085 }, 60, "9"}
                level[10] = { "level 10", { 1, 2, 0.085 }, 90, "10"}
            elseif levelNum == 8 then
                gotoNextLevel = false
                level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
                level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
                level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
                level[4] = { "level 4", { 1, 2, 0.035 }, nil, nil}
                level[5] = { "level 5", { 1, 2, 0.045 }, nil, nil}
                level[6] = { "level 6", { 1, 2, 0.055 }, nil, nil}
                level[7] = { "level 7", { 1, 2, 0.065 }, nil, nil}
                level[8] = { "level 8", { 1, 2, 0.075 }, 0, "8"}
                level[9] = { "level 9", { 1, 2, 0.085 }, 30, "9"}
                level[10] = { "level 10", { 1, 2, 0.085 }, 60, "10"}
            elseif levelNum == 9 then
                gotoNextLevel = false
                level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
                level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
                level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
                level[4] = { "level 4", { 1, 2, 0.035 }, nil, nil}
                level[5] = { "level 5", { 1, 2, 0.045 }, nil, nil}
                level[6] = { "level 6", { 1, 2, 0.055 }, nil, nil}
                level[7] = { "level 7", { 1, 2, 0.065 }, nil, nil}
                level[8] = { "level 8", { 1, 2, 0.075 }, nil, nil}
                level[9] = { "level 9", { 1, 2, 0.085 }, 0, "9"}
                level[10] = { "level 10", { 1, 2, 0.085 }, 30, "10"}
            end
        end

        -- set level --
        for i = 1, #level do
            if tonumber(score) == tonumber(level[i][3]) then
                levelNum = tonumber(level[i][4]) + 1
                break
            end
        end

        if gameHasStarted then
            if not settings["showPreviousScore"] then
                if levelNum ~= #level + 1 then
                    speed_tbl = level[levelNum][2]
                    if speed_tbl then
                        speedMin = tonumber(speed_tbl[1])
                        speedMax = tonumber(speed_tbl[2])
                        offset = tonumber(speed_tbl[3])
                    end
                end
            else
                speedMin = 1
                speedMax = 2
                offset = 0
            end
        end
        if gameHasStarted then
            if levelNum ~= #level + 1 then
                levelLabel.text = tostring(level[levelNum][1]) .. "/"..#level
                levelLabel.isVisible = true
                scoreRemaining.text = "Points: " .. points .. "/" .. level[levelNum][3]
                scoreRemaining.isVisible = true
            end
            if settings["delayCollision"] then
                if (invulnerable == false) then
                    local HealthBarDelay = 100
                    if healthRemaining == 100 then
                        health.new("IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII", HealthBarDelay)
                    elseif healthRemaining == 75 then
                        health.new("IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII", HealthBarDelay)
                    elseif healthRemaining == 50 then
                        health.new("IIIIIIIIIIIIIIIIIIII", HealthBarDelay)
                    elseif healthRemaining == 25 then
                        health.new("IIIII", HealthBarDelay)
                    elseif healthRemaining == 0 then
                        health.new("I", HealthBarDelay)
                    end
                end
            end
        else
            levelLabel.isVisible = false
            scoreRemaining.isVisible = false
        end
        if (level[2][3] ~= nil and tonumber(score) == tonumber(level[2][3])) then
            color = "red"
            changeBorderColor = true
        elseif (level[3][3] ~= nil and tonumber(score) == tonumber(level[3][3])) then
            color = "yellow"
            changeBorderColor = true
        elseif (level[4][3] ~= nil and tonumber(score) == tonumber(level[4][3])) then
            color = "pink"
            changeBorderColor = true
        elseif (level[5][3] ~= nil and tonumber(score) == tonumber(level[5][3])) then
            color = "green"
            changeBorderColor = true
        elseif (level[6][3] ~= nil and tonumber(score) == tonumber(level[6][3])) then
            color = "purple"
            changeBorderColor = true
        elseif (level[7][3] ~= nil and tonumber(score) == tonumber(level[7][3])) then
            color = "orange"
            changeBorderColor = true
        elseif (level[8][3] ~= nil and tonumber(score) == tonumber(level[8][3])) then
            color = "blue"
            changeBorderColor = true
        elseif (level[9][3] ~= nil and tonumber(score) == tonumber(level[9][3])) then
            color = "indigo"
            changeBorderColor = true
        elseif (level[10][3] ~= nil and tonumber(score) == tonumber(level[10][3])) then
            color = "violet"
            changeBorderColor = true
        else
            changeBorderColor = false
        end
        if (changeBorderColor == true) then
            topLine:setStrokeColor(colorsRGB.RGB(color))
            bottomLine:setStrokeColor(colorsRGB.RGB(color))
            rightLine:setStrokeColor(colorsRGB.RGB(color))
            leftLine:setStrokeColor(colorsRGB.RGB(color))
            topLine.alpha = 0.35
            bottomLine.alpha = 0.35
            rightLine.alpha = 0.35
            leftLine.alpha = 0.35
        end
        if colorUpdated and gameHasStarted then
            --local player2 = createPlayer( player.x - player.width / 2, player.y - player.height / 2, player.width, player.height, player.rotation, player.isVisible )
            local player2 = createPlayer( player.x, player.y, player.width, player.height, player.rotation, player.isVisible )
            if player.isFocus then
                player2.isFocus = player.isFocus
                player2.x0 = player.x0
                player2.y0 = player.y0
            end
            player2.resize = false
            colorUpdated = false
            player:removeSelf()
            player = player2
        end
        -- The player.resize stuff is a hack. When you resize a display object, this doesn't get reflected in the physics world.
        -- Therefore we create a new player with the same properties but a differnt size and remove the old player.
        -- Hopefully this gets fixed in a future version of Corona SDK.
        if player.resize then
            --local player2 = createPlayer( player.x - player.width / 2, player.y - player.height / 2, player.width, player.height, player.rotation, player.isVisible )
            local player2 = createPlayer( player.x, player.y, player.width, player.height, player.rotation, player.isVisible )
            if player.isFocus then
                player2.isFocus = player.isFocus
                player2.x0 = player.x0
                player2.y0 = player.y0
            end
            player2.resize = false
            player:removeSelf()
            player = player2
            loggedWidth = player.width
            loggedHeight = player.height
            if settings["animatePlayer"] then
                local function PA_Closure()
                    player.width = loggedWidth
                    player.height = loggedHeight
                    player.alpha = 1
                end
                playerAnimation = transition.to(player, {time = 300, alpha = 0, xScale = 1, yScale = 1, onComplete = PA_Closure})
            end
        end
        -- basic keyboard controls
        if (keyisup == true) then
            player.y = player.y - settings["movementVelocity"]
            Runtime:addEventListener( "enterFrame", function( ) player.rotation = 180; end )
        end
        if (keyisdown == true) then
            player.y = player.y + settings["movementVelocity"]
            Runtime:addEventListener( "enterFrame", function( ) player.rotation = 0; end )
        end
        if (keyisleft == true) then
            player.x = player.x - settings["movementVelocity"]
            Runtime:addEventListener( "enterFrame", function( ) player.rotation = 90; end )
        end
        if (keyisright == true) then
            player.x = player.x + settings["movementVelocity"]
            Runtime:addEventListener( "enterFrame", function( ) player.rotation = 270; end )
        end
        -- up: left|right angle
        if (keyisup == true and keyisleft == true) then
            Runtime:addEventListener( "enterFrame", function( ) player.rotation = 135; end )
        elseif (keyisup == true and keyisright == true) then
            Runtime:addEventListener( "enterFrame", function( ) player.rotation = -135; end )
        end
        -- down: left|right angle
        if (keyisdown == true and keyisleft == true) then
            Runtime:addEventListener( "enterFrame", function( ) player.rotation = 45; end )
        elseif (keyisdown == true and keyisright == true) then
            Runtime:addEventListener( "enterFrame", function( ) player.rotation = -45; end )
        end
        ConstrainToScreen( player )
        for key, object in pairs ( objects ) do
            if false == object.isVisible then
                local xVelocity = 0
                local yVelocity = 0
                if "food" == object.objectType or "poison" == object.objectType then
                    -- New object should move in same direction as the one which will be deleted
                    if object.xVelocity < 0 then
                        xVelocity = - randomSpeed()
                    elseif object.xVelocity > 0 then
                        xVelocity = randomSpeed()
                    end
                    if object.yVelocity < 0 then
                        yVelocity = - randomSpeed()
                    elseif object.yVelocity > 0 then
                        yVelocity = randomSpeed()
                    end
                    -- Create new food and new enemies instantly
                    if not gameIsPaused then
                        if settings["SpawnFoodAndPoison"] then
                            spawn(object.objectType, xVelocity, yVelocity )
                        end
                    end
                else
                    -- Create new rewards and new penalties after a random delay
                    local sign = {1, - 1}
                    if 1 == math.random( 1, 2 ) then
                        -- Move along x-axis. From top to bottom or bottom to top.
                        xVelocity = randomSpeed() * sign[math.random(1, 2)]
                    else
                        -- Move along y-axis. From top to bottom or bottom to top.
                        yVelocity = randomSpeed() * sign[math.random(1, 2)]
                    end
                    local item
                    -- Rewards and penalties will be spawned on a rotating basis.
                    if "reward" == object.objectType then
                        item = "penalty"
                    else
                        item = "reward"
                    end
                    if settings["SpawnFoodAndPoison"] then
                        local closure = function() return spawn(item, xVelocity, yVelocity) end
                        chances = timer.performWithDelay ( math.random(6, 12) * settings["rewardChances"], closure, 1 )
                    end
                end
                object:removeSelf()
                table.remove(objects, key)
            end
        end
    end
    return levelNum
end

function switchScene(event)
    local sceneID = event.target.id
    local options = {}
    if player ~= nil then player.isVisible = false end
    if sceneID == "scenes.pause" then
        gameIsPaused = true
        --sidebar:show()
        options = {effect = "fromTop", time = 300, isModal = true}
        composer.showOverlay( sceneID, options )
        scoreLabel.isVisible = false
        ingameHighestScoreLabel.isVisible = false
        levelLabel.isVisible = false
        scoreRemaining.isVisible = false
        player.isVisible = false
        canSpawnItems = false
        topLine:setStrokeColor(colorsRGB.RGB("red"))
        bottomLine:setStrokeColor(colorsRGB.RGB("red"))
        rightLine:setStrokeColor(colorsRGB.RGB("red"))
        leftLine:setStrokeColor(colorsRGB.RGB("red"))
        topLine.alpha = 1
        bottomLine.alpha = 1
        rightLine.alpha = 1
        leftLine.alpha = 1
    else
        options = {effect = "crossFade", time = 300}
        composer.showOverlay( sceneID, options )
    end
end

function returnToMenu(event)
    local sceneID = event.target.id
    local options = {}
    if sceneID == "scenes.menu" then
        menu_bool = true
        sidebar:hide()
        slide:hide_slide_menu()
        options = {effect = "fromTop", time = 300, isModal = true}
        composer.showOverlay( sceneID, options )
        spawnConstraint = "no"
        player.isVisible = false
        rewardBar.isVisible = false
        scoreLabel.isVisible = false
        levelLabel.isVisible = false
        penaltyBar.isVisible = false
        pauseButton.isVisible = false
        rewardLabel.isVisible = false
        penaltyLabel.isVisible = false

        healthLabel1.isVisible = false
        healthLabel2.isVisible = false
        healthLabel3.isVisible = false
        healthLabel4.isVisible = false
        healthLabel5.isVisible = false

        scoreRemaining.isVisible = false
        ingameHighestScoreLabel.isVisible = false
        topLine.alpha = 0
        bottomLine.alpha = 0
        rightLine.alpha = 0
        leftLine.alpha = 0
        pauseShade.alpha = 0
        resumeLogo:removeSelf()
        if revolving_loading ~= nil then
            revolving_loading.isVisible = false
        end
    end
end

local function setUpDisplay(grp)
    local screen_adjustment = 1
    local bgMain = display.newImage(grp, "images/backgrounds/background.png")
    bgMain.xScale = (screen_adjustment * bgMain.contentWidth) / bgMain.contentWidth
    bgMain.yScale = bgMain.xScale
    bgMain.x = display.contentWidth / 2
    bgMain.y = display.contentHeight / 2
    bgMain.alpha = 0.30
    bgMain:addEventListener( "touch", onTouch)
    pauseButton = widget.newButton({
        defaultFile = 'images/buttons/menu.png',
        overFile = 'images/buttons/menu-over.png',
        id = 'scenes.pause',
        width = 42,
        height = 42,
        onRelease = switchScene
    })
    pauseButton.anchorX = 0
    pauseButton.anchorY = 0
    pauseButton.x = screenLeft + 15
    pauseButton.y = screenTop + 15
    pauseButton:scale(0.8, 0.8)
    grp:insert(pauseButton)
end

-- "scene:create()"
function scene:create( event )
    local sceneGroup = self.view
    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    setUpDisplay(sceneGroup)
    sounds.playStream('game_music')
end

-- "scene:show()"
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    if ( phase == "will" ) then
        local sidebarGroup = display.newGroup()
        local sidebar_data = {}
        sidebar_data.bg = "images/backgrounds/sidebar.png"
        sidebarGroup:insert(sidebar:create(sidebar_data))
        slide:hide_slide_menu()
        sidebar:hide()
        if points ~= nil then points = 0 end
    elseif ( phase == "did" ) then
        if gamereset then
            Runtime:addEventListener( "enterFrame", OnTick )
            Runtime:addEventListener( "collision", onCollision )
        end
        if (gameresumed == true) then
            gameresumed = false
            initSpawns()
        end
        if (menu_bool == true) then
            menu_bool = false
            initSpawns()
        end
        OnNewGame()
        gameIsPaused = false
        if (lastScoreLabel ~= nil) and (highScoreLabel ~= nil) then
            lastScoreLabel.isVisible = false
            highScoreLabel.isVisible = false
        end
    end
end

function initSpawns()
    spawn( "food", 0, randomSpeed() )
    spawn( "food", 0, - randomSpeed() )
    spawn( "food", randomSpeed(), 0 )
    spawn( "food", - randomSpeed(), 0 )
    spawn( "poison", 0, randomSpeed() )
    spawn( "poison", 0, - randomSpeed() )
    spawn( "poison", randomSpeed(), 0 )
    spawn( "poison", - randomSpeed(), 0 )
    spawn( "reward", randomSpeed(), 0 )
end

-- "scene:hide()"
function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
        -- remove objects from scene --
        local function removeBlocks()
            if (object ~= nil) or (objects ~= nil) then
                for _, object in pairs ( objects ) do
                    object.alpha = 0
                end
            end
        end
        local seconds = 0
        removeblocks = timer.performWithDelay(1000 * seconds, removeBlocks )

    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen.
    end
end


-- "scene:destroy()"
function scene:destroy( event )
    local sceneGroup = self.view
    -- Called prior to the removal of scene's view ("sceneGroup").
    -- Insert code here to clean up the scene.
    -- Example: remove display objects, save state, etc.
end

local function onKeyPressed( event )
    local keyName = event.keyName
    if (event.phase == "down") then
        if (keyName == "up" or keyName == "w") then
            keyisup = true
            return true
        end
        if (keyName == "down" or keyName == "s") then
            keyisdown = true
            return true
        end
        if (keyName == "left" or keyName == "a") then
            keyisleft = true
            return true
        end
        if (keyName == "right" or keyName == "d") then
            keyisright = true
            return true
        end
        if (keyName == "enter") then
            if not gameHasStarted then
                OnNewGame()
                return true
            end
        end
        if (keyName == "escape") then
            if (gameHasStarted == true) then
                -- showPauseMenu(true)
                --print("play.lua - escape key pressed")
                return true
            end
        end
    elseif (event.phase == "up") then
        if settings["CancelMovementOnKeyRelease"] then
            keyisup = false
            keyisdown = false
            keyisleft = false
            keyisright = false
        end
    end
    return false
end
Runtime:addEventListener( "key", onKeyPressed )
Runtime:addEventListener( "touch", onKeyPressed )

-- Labels need to be centered after creation.
alignmentX = display.viewableContentWidth / 2
alignmentY = display.viewableContentHeight / 2 - 75

-- Load the last score and highest score
score, highScore = loadScores( )
-- Load the last credits
credits = loadCredits( )

-- Score Label (Center Screen)
scoreLabel = display.newText( score, display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFontBold, 120 )
scoreLabel:setFillColor( colorsRGB.RGB("white") )
scoreLabel.x = display.viewableContentWidth / 2
scoreLabel.y = display.viewableContentHeight / 2
scoreLabel.alpha = 0.20
scoreLabel.isVisible = false

-- In-Game Highest Score Label
ingameHighestScoreLabel = display.newText( score, display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFontBold, 10 )
ingameHighestScoreLabel:setFillColor( colorsRGB.RGB("white") )
ingameHighestScoreLabel.x = display.viewableContentWidth / 2
ingameHighestScoreLabel.y = display.viewableContentHeight / 2 - 135
ingameHighestScoreLabel.alpha = 0.35
ingameHighestScoreLabel.isVisible = false

-- In-Game Current level Label
levelLabel = display.newText( score, display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFontBold, 20 )
levelLabel:setFillColor( colorsRGB.RGB("white") )
levelLabel.x = _W - 65
levelLabel.y = 80
levelLabel.alpha = 0.50
levelLabel.isVisible = false

-- comboText = display.newText( score, display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFontBold, 10 )
-- comboText:setFillColor( colorsRGB.RGB("white") )
-- comboText.x = player.x
-- comboText.y = player.y
-- comboText.alpha = 1
-- comboText.isVisible = false

scoreRemaining = display.newText( score, display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFontBold, 12 )
scoreRemaining:setFillColor( colorsRGB.RGB("white") )
scoreRemaining.x = _W - 65
scoreRemaining.y = 120
scoreRemaining.alpha = 0.50
scoreRemaining.isVisible = false

-- Rewards
rewardLabel = display.newText( "reward", alignmentX, alignmentY, native.systemFontBold, 18 )
rewardLabel:setFillColor( colorsRGB.RGB("green") )
rewardLabel.x = alignmentX
rewardLabel.y = alignmentY
rewardLabel.alpha = 0

-- Reward Bar
rewardBar = display.newRect( 0, alignmentX, alignmentY, 30 )
rewardBar:setFillColor ( colorsRGB.RGB("white") )
rewardBar.x = rewardLabel.x
rewardBar.y = rewardLabel.y
rewardBar.alpha = 0.20
rewardBar.isVisible = false

-- Penalty
penaltyLabel = display.newText( "penalty", alignmentX, alignmentY, native.systemFontBold, 18 )
penaltyLabel:setFillColor( colorsRGB.RGB("red") )
penaltyLabel.x = rewardBar.x
penaltyLabel.y = rewardBar.y
penaltyLabel.alpha = 0

-- Penalty Bar
penaltyBar = display.newRect( 0, alignmentX, alignmentY, 30 )
penaltyBar.x = penaltyLabel.x
penaltyBar.y = penaltyLabel.y
penaltyBar:setFillColor ( colorsRGB.RGB("white") )
penaltyBar.alpha = 0.20
penaltyBar.isVisible = false

-- health labels --
healthLabel1 = display.newImageRect( "images/backgrounds/heart1.png", 12, 12)
healthLabel1.x = centerX + 170
healthLabel1.y = centerY - 120
healthLabel1.alpha = 0.75

healthLabel2 = display.newImageRect( "images/backgrounds/heart2.png", 12, 12)
healthLabel2.x = centerX + 170
healthLabel2.y = centerY - 120
healthLabel2.alpha = 0.75

healthLabel3 = display.newImageRect( "images/backgrounds/heart3.png", 12, 12)
healthLabel3.x = centerX + 170
healthLabel3.y = centerY - 120
healthLabel3.alpha = 0.75

healthLabel4 = display.newImageRect( "images/backgrounds/heart4.png", 12, 12)
healthLabel4.x = centerX + 170
healthLabel4.y = centerY - 120
healthLabel4.alpha = 0.75

healthLabel5 = display.newImageRect( "images/backgrounds/heart5.png", 12, 12)
healthLabel5.x = centerX + 170
healthLabel5.y = centerY - 120
healthLabel5.alpha = 0.75

local alphaFrom = 0.20
local alphaTo = 1
local scaleFrom = 1
local scaleTo = 2

function healthAnimation( )
    if runHealthAnimation then
        local scaleUp = function( )
            if healthRemaining == 100 then
                local HeartRate = 500
                h1Animation = transition.to( healthLabel1, { time = HeartRate, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = healthAnimation } )
            elseif healthRemaining == 75 then
                local HeartRate = 400
                h2Animation = transition.to( healthLabel2, { time = HeartRate, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = healthAnimation } )
            elseif healthRemaining == 50 then
                local HeartRate = 300
                h3Animation = transition.to( healthLabel3, { time = HeartRate, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = healthAnimation } )
            elseif healthRemaining == 25 then
                local HeartRate = 200
                h4Animation = transition.to( healthLabel4, { time = HeartRate, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = healthAnimation } )
            elseif healthRemaining == 0 then
                local HeartRate = 100
                h5Animation = transition.to( healthLabel5, { time = HeartRate, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = healthAnimation } )
            end
        end
        local animationRate = 100
        if healthRemaining == 100 then
            healthLabel1.isVisible = true
            healthLabel2.isVisible = false
            healthLabel3.isVisible = false
            healthLabel4.isVisible = false
            healthLabel5.isVisible = false
            h1Animation = transition.to( healthLabel1, { time = animationRate, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp } )
        elseif healthRemaining == 75 then
            healthLabel1.isVisible = false
            healthLabel2.isVisible = true
            healthLabel3.isVisible = false
            healthLabel4.isVisible = false
            healthLabel5.isVisible = false
            h2Animation = transition.to( healthLabel2, { time = animationRate, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp } )
        elseif healthRemaining == 50 then
            healthLabel1.isVisible = false
            healthLabel2.isVisible = false
            healthLabel3.isVisible = true
            healthLabel4.isVisible = false
            healthLabel5.isVisible = false
            h3Animation = transition.to( healthLabel3, { time = animationRate, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp } )
        elseif healthRemaining == 25 then
            healthLabel1.isVisible = false
            healthLabel2.isVisible = false
            healthLabel3.isVisible = false
            healthLabel4.isVisible = true
            healthLabel5.isVisible = false
            h4Animation = transition.to( healthLabel4, { time = animationRate, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp } )
        elseif healthRemaining == 0 then
            healthLabel1.isVisible = false
            healthLabel2.isVisible = false
            healthLabel3.isVisible = false
            healthLabel4.isVisible = false
            healthLabel5.isVisible = true
            h5Animation = transition.to( healthLabel5, { time = animationRate, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp } )
        end
    end
end
healthAnimation( )

-- borders
shade = 0.25
local topY = display.screenOriginY
local bottomY = display.contentHeight - display.screenOriginY

local leftX = display.screenOriginX
local rightX = display.contentWidth - display.screenOriginX

local screenW = rightX - leftX
local screenH = bottomY - topY

topLine = display.newLine(leftX + screenW / 47, topY, rightX - screenW / 47, topY)
topLine.strokeWidth = screenH / 15.5
topLine:setStrokeColor(0, 0, 0)
topLine.alpha = shade

bottomLine = display.newLine(leftX + screenW / 47, bottomY, rightX - screenW / 47, bottomY)
bottomLine.strokeWidth = screenH / 15.5
bottomLine:setStrokeColor(0, 0, 0)
bottomLine.alpha = shade

rightLine = display.newLine(leftX + screenW / 1, topY, leftX + screenW / 1, bottomY)
rightLine.strokeWidth = screenH / 15.7
rightLine:setStrokeColor(0, 0, 0)
rightLine.alpha = shade

leftLine = display.newLine(0, topY, 0, bottomY)
leftLine.strokeWidth = screenH / 15.7
leftLine:setStrokeColor(0, 0, 0)
leftLine.alpha = shade

--Set up the physics world
physics = require("physics")
physics.start()
--physics.setDrawMode( "hybrid" )
physics.setScale( 60 )
-- Overhead view: No gravity.
physics.setGravity( 0, 0 )

player = createPlayer( display.viewableContentWidth / 2, display.viewableContentHeight / 2, 20, 20, 0, false )
--Runtime:addEventListener( "enterFrame", function( ) player.rotation = player.rotation + 1; end )
--Runtime:addEventListener( "enterFrame", function( ) player.rotation = 180; end )

Runtime:addEventListener( "enterFrame", OnTick );
Runtime:addEventListener ( "collision", onCollision )

spawn( "food", 0, randomSpeed() )
spawn( "food", 0, - randomSpeed() )
spawn( "food", randomSpeed(), 0 )
spawn( "food", - randomSpeed(), 0 )
spawn( "poison", 0, randomSpeed() )
spawn( "poison", 0, - randomSpeed() )
spawn( "poison", randomSpeed(), 0 )
spawn( "poison", - randomSpeed(), 0 )

local function init_spawn_reward()
    local random_number = math.random(1, 4)
    if (random_number == 1) then
        spawn( "reward", 0, - randomSpeed() )
    elseif (random_number == 2) then
        spawn( "reward", randomSpeed(), 0 )
    elseif (random_number == 3) then
        spawn( "reward", - randomSpeed(), 0 )
    elseif (random_number == 4) then
        spawn( "reward", randomSpeed(), 0 )
    end
end
init_spawn_reward()
--==========================================================================================--
--==========================================================================================--
function sidebar:create(params)
    local button_group = display.newGroup()
    local params = params or {}
    local bg = params.bg or nil
    local background
    if bg then
        background = display.newImage(sidebar_group, "images/backgrounds/sidebar.png", true)
        background.x = display.viewableContentWidth / 2 - 215
        background.y = display.viewableContentHeight / 2 + 250
        background.width = 50
        background.height = display.viewableContentHeight
    end
    local function updateDataboxAndVisibility()
        databox.isSoundOn = sounds.isSoundOn
        soundsButtons.on.isVisible = false
        soundsButtons.off.isVisible = false
        if databox.isSoundOn then
            soundsButtons.on.isVisible = true
        else
            soundsButtons.off.isVisible = true
        end
    end
    menubutton = widget.newButton({
        defaultFile = 'images/buttons/menu.png',
        overFile = 'images/buttons/menu-over.png',
        id = 'scenes.menu',
        onRelease = returnToMenu
    })
    soundsButtons.on = widget.newButton({
        defaultFile = 'images/buttons/sounds_on.png',
        overFile = 'images/buttons/sounds_on-over.png',
        onRelease = function()
            sounds.play('onTap')
            sounds.isSoundOn = false
            SoundIsOff = false
            updateDataboxAndVisibility()
        end
    })
    soundsButtons.on.isRound = true
    soundsButtons.off = widget.newButton({
        defaultFile = 'images/buttons/sounds_off.png',
        overFile = 'images/buttons/sounds_off-over.png',
        onRelease = function()
            sounds.play('onTap')
            sounds.isSoundOn = true
            SoundIsOff = true
            updateDataboxAndVisibility()
        end
    })
    soundsButtons.off.isRound = true
    exitButton = widget.newButton({
        defaultFile = 'images/buttons/exit.png',
        overFile = 'images/buttons/exit-over.png',
        onRelease = function()
            sounds.play('onTap')
            native.showAlert('Confirm Exit', 'Are you sure you want to exit?', {'Yes', 'No'}, function(event)
                if event.action == 'clicked' and event.index == 1 then
                native.requestExit()
            end
        end)
    end
})
colorSelectionButton = widget.newButton({
    defaultFile = 'images/buttons/colorSelection.png',
    overFile = 'images/buttons/colorSelection-over.png',
    onRelease = function()
        sounds.play('onTap')
        if slideMenuOpen then
            slide:hide_slide_menu()
        else
            slide:show_slide_menu()
        end
    end
})
-- [[ BUTTON DISPLAY SETTINGS ]] --
    local button_width = display.viewableContentWidth - 455
    local heightFromTop = 280
    local spacing = 50

    -- Menu Button Display Settings
    menubutton.x = button_width
    menubutton.y = heightFromTop
    menubutton.width = 32
    menubutton.height = 38

    -- Sound-On Button Display Settings
    soundsButtons.on.x = button_width
    soundsButtons.on.y = menubutton.y + spacing
    soundsButtons.on.width = 32
    soundsButtons.on.height = 38

    -- Sound-Off Button Display Settings
    soundsButtons.off.x = button_width
    soundsButtons.off.y = soundsButtons.on.y
    soundsButtons.off.width = 32
    soundsButtons.off.height = 38

    -- Color-Selection Button Display Settings
    colorSelectionButton.x = button_width
    colorSelectionButton.y = soundsButtons.off.y + spacing
    colorSelectionButton.width = 32
    colorSelectionButton.height = 38

    -- Exit Button Display Settings
    exitButton.x = button_width
    exitButton.y = colorSelectionButton.y + spacing
    exitButton.width = 32
    exitButton.height = 38

    -- [ INSERT BUTTONS ] --
    button_group:insert(menubutton)
    button_group:insert(soundsButtons.on)
    button_group:insert(soundsButtons.off)
    button_group:insert(colorSelectionButton)
    button_group:insert(exitButton)

    sidebar_group:insert(button_group)
    sidebar_group.y = -250
    sidebar_group.x = 0

	updateDataboxAndVisibility()
	table.insert(visualButtons, soundsButtons.on)
	table.insert(visualButtons, soundsButtons.off)
    return sidebar_group
end

function sidebar:show()
    sidebarOpen = true
    local x1 = display.viewableContentWidth - 410
    local x2 = display.viewableContentHeight - 280
    transition.to(sidebar_group, { time = 300, alpha = 1, x = 0, y = sidebar_group.y})
end

function sidebar:hide()
    sidebarOpen = false
    local x1 = display.viewableContentWidth - 445
    local x2 = display.viewableContentHeight - 280
    transition.to(sidebar_group, { time = 300, alpha = 1, x = -50, y = sidebar_group.y })
end
--==========================================================================================--
--==========================================================================================--

local _W = display.contentWidth
local group = display.newGroup()

local data = {}
data.over = {}
data.default = {}
data.text = {}
data.bg = "images/color data/bgstyle2.png"
data.back_image_press = "images/color data/backbutton-over.png"
data.back_image = "images/color data/backbutton.png"

data.event = function(one)
    slide:hide_slide_menu()
    if (colorId == 1) then
        local delay = 750
        bgColor = "red"
        toast.new("red", delay)
    elseif (colorId == 2) then
        bgColor = "yellow"
        toast.new("yellow", delay)
    elseif (colorId == 3) then
        bgColor = "pink"
        toast.new("pink", delay)
    elseif (colorId == 4) then
        bgColor = "green"
        toast.new("green", delay)
    elseif (colorId == 5) then
        bgColor = "purple"
        toast.new("purple", delay)
    elseif (colorId == 6) then
        bgColor = "orange"
        toast.new("orange", delay)
    elseif (colorId == 7) then
        bgColor = "blue"
        toast.new("blue", delay)
    end
    return true
end

for i = 1, 9 do
    local name = "images/color data/slide_menu" .. i .. ".png"
    local name2 = "images/color data/slide_menu" .. i .. "_press.png"
    table.insert(data.over, name2)
    table.insert(data.default, name)
    table.insert(data.text, "button " .. i)
end

group:insert(slide:new(data))

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
