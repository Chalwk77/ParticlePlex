-- menu.lua for Particle Plex
-- Copyright 2017 Jericho Crosby. All Rights Reserved.

-- Corona Simulator "view as" settings:
-- 1080x1920
local widget = require('widget')
widget.setTheme ( 'widget_theme_ios' )
local composer = require( 'composer' )
local sounds = require('libraries.sounds')
local colors = require('classes.colors-rgb')
local relayout = require('libraries.relayout')
local scene = composer.newScene()
menu_alpha = 0.10

menu_physics = require("physics")
local menu_tPrevious = system.getTimer( )

healthRemaining = 100

-- most commonly used screen coordinates
local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

local onTouch
local specs = {
    {w = 191, h = 180},
    {w = 203, h = 185},
    {w = 196, h = 175},
    {w = 180, h = 182},
    {w = 185, h = 181}
}
local function switchScene(event)
    local sceneID = event.target.id
    local options = {effect = "crossFade", time = 200, params = {title = event.target.id}}
    composer.gotoScene( sceneID, options )
    sounds.play("onTap")
    -- hide buttons to prevent visual glitches --
    if (optionsBtn ~= nil) and (optionsBtn ~= nil) then
        optionsBtn.isVisible = false
        aboutBtn.isVisible = false
    end
    -- Show button particle effects
    if sceneID == "scenes.chooselevel" then
        game_version.isVisible = false
        local index = math.random(1, 5)
        local puff = display.newImageRect('images/particle effects/startBtnParticle.png', specs[index].w, specs[index].h)
        puff.x, puff.y = startbutton.x, startbutton.y
        local fromScale, toScale = math.random(0.1, 0.2), math.random(1, 2)
        puff:scale(fromScale, fromScale)
        puff:setFillColor(1, 0.9, 0.5)
        transition.to(puff, {time = math.random(200, 400), xScale = toScale, yScale = toScale, alpha = 0.35, onComplete = function(object)
            object:removeSelf()
        end})
    elseif sceneID == "scenes.options" then
        game_version.isVisible = false
        colorSelection.isVisible = true
        local index = math.random(1, 5)
        local puff = display.newImageRect('images/particle effects/optionsBtnParticle.png', specs[index].w, specs[index].h)
        puff.x, puff.y = optionsbutton.x, optionsbutton.y
        local fromScale, toScale = math.random(0.1, 0.2), math.random(1, 2)
        puff:scale(fromScale, fromScale)
        puff:setFillColor(1, 0.9, 0.5)
        transition.to(puff, {time = math.random(200, 400), xScale = toScale, yScale = toScale, alpha = 0.35, onComplete = function(object)
            object:removeSelf()
        end})
    elseif sceneID == "scenes.about" then
        game_version.isVisible = false
        local index = math.random(1, 5)
        local puff = display.newImageRect('images/particle effects/aboutBtnParticle.png', specs[index].w, specs[index].h)
        puff.x, puff.y = aboutbutton.x, aboutbutton.y
        local fromScale, toScale = math.random(0.1, 0.2), math.random(1, 2)
        puff:scale(fromScale, fromScale)
        puff:setFillColor(1, 0.9, 0.5)
        transition.to(puff, {time = math.random(200, 400), xScale = toScale, yScale = toScale, alpha = 0.35, onComplete = function(object)
            object:removeSelf()
        end})
        -- Show Help-Text paragraphs and background
        background.isVisible = true
        helptext.isVisible = true
        helpShade.alpha = 0.50
    elseif sceneID == "scenes.reload_game" then
        game_version.isVisible = false
        composer.setVariable( "levelNum", 1 )
        local index = math.random(1, 5)
        local puff = display.newImageRect('images/particle effects/startBtnParticle.png', specs[index].w, specs[index].h)
        puff.x, puff.y = startbutton.x, startbutton.y
        local fromScale, toScale = math.random(0.1, 0.2), math.random(1, 2)
        puff:scale(fromScale, fromScale)
        puff:setFillColor(1, 0.9, 0.5)
        transition.to(puff, {time = math.random(200, 400), xScale = toScale, yScale = toScale, alpha = 0.35, onComplete = function(object)
            object:removeSelf()
        end})
    end
    -- stop menu animation
    startMenuAnimation(false)
end

function startMenuAnimation(bool)
    if bool == true then
        menu_initSpawns()
    else
        canSpawnMenuObjects = false
        for key, menu_object in pairs ( menu_objects ) do
            menu_object.isVisible = false
            menu_object:removeSelf()
            Runtime:removeEventListener( "enterFrame", menu_animate );
        end
    end
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

function menu_logo_animation(bool, menu_dispaly_logo)
    if (bool == true) then
        local toScale = 0.6, 0.6
        local random_wise = math.random(1, 2)
        if random_wise == 1 then
            logoRotation = 360
        else
            logoRotation = -360
        end
        levelLogo_animation = transition.to(menu_dispaly_logo, {time = math.random(100, 250), iterations = 2, rotation = logoRotation, xScale = toScale, yScale = toScale, onComplete = function(object)
            object:scale(1, 1)
        end})
    end
end

local function setUpDisplay(grp)

    if credits ~= nil then
        credits = credits
    else
        credits = loadCredits( )
    end

    local screen_adjustment = 0.5
    local background = display.newImage(grp, "images/backgrounds/background.png")
    background.xScale = (screen_adjustment * background.contentWidth) / background.contentWidth
    background.yScale = background.xScale
    background.x = centerX
    background.y = centerY - 50
    background:scale(0.6, 0.6)
    background.alpha = 0.75

    local displayLogo = display.newImageRect( grp, "images/backgrounds/logo.png", 713, 85)
    displayLogo.x = centerX
    displayLogo.y = centerY - 120
    displayLogo:scale(0.6, 0.6)

    menu_dispaly_logo = displayLogo

    if settings["enableLevelSelection"] then
        levelselect_id = "scenes.chooselevel"
    else
        levelselect_id = "scenes.reload_game"
        levelNum = 1
    end

    local startBtn = widget.newButton ({
        id = levelselect_id,
        defaultFile = "images/backgrounds/start.png",
        overFile = "images/backgrounds/start.png",
        onRelease = switchScene
    })
    startBtn.x = centerX
    startBtn.y = centerY
    startBtn.alpha = 0
    startBtn:scale(5, 5)
    grp:insert(startBtn)
    startbutton = startBtn

    local alphaFrom = 0.25
    local alphaTo = 1
    local scaleFrom = 0.4
    local scaleTo = 0.6
    local animationTime = 450

    local function startButtonAnimation( )
        local scaleUp = function( )
            startButtonTween = transition.to( startBtn, { time = animationTime, alpha = alphaFrom, xScale = scaleFrom, yScale = scaleFrom, onComplete = startButtonAnimation } )
        end
        startButtonTween = transition.to( startBtn, { time = animationTime, alpha = alphaTo, xScale = scaleTo, yScale = scaleTo, onComplete = scaleUp } )
    end
    startButtonAnimation( )

    local spacing = 40
    local optionsBtn = widget.newButton ({
        label = "Options",
        id = "scenes.options",
        labelColor = {default = {colorsRGB.RGB("green")}, over = {colorsRGB.RGB("blue")}},
    onRelease = switchScene})
    optionsBtn.x = centerX
    optionsBtn.y = centerX + centerY - 175
    optionsBtn.width = 100
    optionsBtn.height = 25
    grp:insert(optionsBtn)
    optionsbutton = optionsBtn

    local aboutBtn = widget.newButton ({
        label = "About",
        id = "scenes.about",
        labelColor = {default = {colorsRGB.RGB("green")}, over = {colorsRGB.RGB("blue")}},
    onRelease = switchScene})
    aboutBtn.x = centerX
    aboutBtn.y = optionsBtn.y + spacing
    aboutBtn.width = 100
    aboutBtn.height = 25
    grp:insert(aboutBtn)
    aboutbutton = aboutBtn
end

-- "scene:create()"
function scene:create( event )
    local sceneGroup = self.view
    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    setUpDisplay(sceneGroup)
    --sounds.playStream('menu_music')
end

-- "scene:show()"
function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase
    if ( phase == "will" ) then
        if win_animate_transition ~= nil then
            timer.cancel(win_animate_transition)
        end

        menu_logo_animation(true, menu_dispaly_logo)

        if start_menu_animation == true then
            startMenuAnimation(true)
            start_menu_animation = false
        end

    elseif ( phase == "did" ) then
        gameHasStarted = false
    end
end

-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase
    if ( phase == "will" ) then
        -- do nothing
    elseif ( phase == "did" ) then
        start_menu_animation = true
    end
end

function scene:destroy( event )
    local sceneGroup = self.view
end

function showMenuButtons()
    if (optionsBtn ~= nil) and (aboutBtn ~= nil) then
        optionsBtn.isVisible = true
        aboutBtn.isVisible = true
    end
end
-------------------------------------------------------------------------------------
-- MENU ANIMATION STARTS --
menu_objects = {}
-------------------------------------------------------------------------------------
local function menu_randomSpeed( )
    return math.random(1, 3) / 10 * 1
end

function menu_initSpawns()
    canSpawnMenuObjects = true
    menu_objects = {}
    Runtime:addEventListener( "enterFrame", menu_animate );
    for key, menu_object in pairs ( menu_objects ) do
        menu_object.isVisible = true
        menu_object.alpha = menu_alpha
    end
    spawn_menu_objects( "food", 0, menu_randomSpeed() )
    spawn_menu_objects( "food", 0, - menu_randomSpeed() )
    spawn_menu_objects( "food", menu_randomSpeed(), 0 )
    spawn_menu_objects( "food", - menu_randomSpeed(), 0 )
    spawn_menu_objects( "poison", 0, menu_randomSpeed() )
    spawn_menu_objects( "poison", 0, - menu_randomSpeed() )
    spawn_menu_objects( "poison", menu_randomSpeed(), 0 )
    spawn_menu_objects( "poison", - menu_randomSpeed(), 0 )
    spawn_menu_objects( "reward", 0, menu_randomSpeed() )
    spawn_menu_objects( "reward", 0, - menu_randomSpeed() )
    spawn_menu_objects( "reward", menu_randomSpeed(), 0 )
    spawn_menu_objects( "reward", - menu_randomSpeed(), 0 )
end

function spawn_menu_objects( objectType, xVelocity, yVelocity )
    if (canSpawnMenuObjects == true) then
        local menu_object
        local sizeXY = math.random( 10, 20 )
        local startX
        local startY
        if 0 == xVelocity then
            startX = math.random( sizeXY, display.contentWidth - sizeXY )
        end
        if xVelocity < 0 then
            startX = display.contentWidth
        end
        if xVelocity > 0 then
            startX = -sizeXY
        end
        if 0 == yVelocity then
            startY = math.random( sizeXY, display.contentHeight - sizeXY )
        end
        if yVelocity < 0 then
            startY = display.contentHeight
        end
        if yVelocity > 0 then
            startY = -sizeXY
        end
        local collisionFilter = { categoryBits = 4, maskBits = 2 } -- collides with player only
        local body = { filter = collisionFilter, isSensor = true }
        if "food" == objectType or "poison" == objectType then
            local randomSize = math.random(1, 2)
            if randomSize == 1 then
                sizeXY = sizeXY - sizeXY + math.random(settings["minSize"], settings["maxSize"])
            else
                sizeXY = sizeXY
            end
            menu_object = display.newRect( startX, startY, sizeXY, sizeXY )
            menu_object.sizeXY = sizeXY
        end
        if "reward" == objectType or "penalty" == objectType then
            menu_object = display.newCircle( startX, startY, 15 )
            menu_object.sizeXY = 30
        end
        if "food" == objectType or "reward" == objectType then
            if "reward" == objectType then
                local rewardColor = {
                    type = "gradient",
                    color1 = { colorsRGB.RGB("purple") },
                    color2 = { colorsRGB.RGB("purple") },
                    direction = "up"
                }
                menu_object.fill = rewardColor
            elseif "food" == objectType then
                local foodColor = {
                    type = "gradient",
                    color1 = { 0, 255, 0 },
                    color2 = { 0, 255, 0 },
                    direction = "up"
                }
                menu_object.fill = foodColor
            end
        end
        if "poison" == objectType or "penalty" == objectType then
            if "poison" == objectType then
                local poisionColor = {
                    type = "gradient",
                    color1 = { 255, 0, 0 },
                    color2 = { 255, 0, 0 },
                    direction = "down"
                }
                menu_object.fill = poisionColor
            elseif "penalty" == objectType then
                local rewardColor = {
                    type = "gradient",
                    color1 = { colorsRGB.RGB("purple") },
                    color2 = { colorsRGB.RGB("purple") },
                    direction = "up"
                }
                menu_object.fill = rewardColor
            end
        end
        menu_object.objectType = objectType
        menu_object.xVelocity = xVelocity
        menu_object.yVelocity = yVelocity
        menu_physics.addBody( menu_object, body )
        menu_object.alpha = menu_alpha
        menu_object.isFixedRotation = true
        table.insert ( menu_objects, menu_object )
    end
end

function menu_animate( event )
    local tDelta = event.time - menu_tPrevious
    menu_tPrevious = event.time
    for _, menu_object in pairs ( menu_objects ) do
        local xDelta = menu_object.xVelocity * tDelta
        local yDelta = menu_object.yVelocity * tDelta
        local xPos = xDelta + menu_object.x
        local yPos = yDelta + menu_object.y
        if (yPos > display.contentHeight + menu_object.sizeXY) or (yPos < - menu_object.sizeXY) or
        (xPos > display.contentWidth + menu_object.sizeXY) or (xPos < - menu_object.sizeXY) then
            menu_object.isVisible = false
        end
        menu_object:translate(xDelta, yDelta)
    end
    for key, menu_object in pairs ( menu_objects ) do
        if false == menu_object.isVisible then
            local xVelocity = 0
            local yVelocity = 0
            if "food" == menu_object.objectType or "poison" == menu_object.objectType then
                if menu_object.xVelocity < 0 then
                    xVelocity = - menu_randomSpeed()
                elseif menu_object.xVelocity > 0 then
                    xVelocity = menu_randomSpeed()
                end
                if menu_object.yVelocity < 0 then
                    yVelocity = - menu_randomSpeed()
                elseif menu_object.yVelocity > 0 then
                    yVelocity = menu_randomSpeed()
                end
                if not gameIsPaused then
                    if settings["SpawnFoodAndPoison"] then
                        spawn_menu_objects(menu_object.objectType, xVelocity, yVelocity )
                    end
                end
            else
                local sign = {1, - 1}
                if 1 == math.random( 1, 2 ) then
                    xVelocity = menu_randomSpeed() * sign[math.random(1, 2)]
                else
                    yVelocity = menu_randomSpeed() * sign[math.random(1, 2)]
                end
                local item
                if "reward" == menu_object.objectType then
                    item = "penalty"
                else
                    item = "reward"
                end
                if settings["SpawnFoodAndPoison"] then
                    local closure = function() return spawn_menu_objects(item, xVelocity, yVelocity) end
                    chances = timer.performWithDelay ( math.random(6, 12) * settings["rewardChances"], closure, 1 )
                end
            end
            menu_object:removeSelf()
            table.remove(menu_objects, key)
        end
    end
end

---------------------------------------------------------------
-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

menu_physics.start()
menu_physics.setScale( 60 )
menu_physics.setGravity( 0, 0 )

Runtime:addEventListener( "enterFrame", menu_animate );
for _, menu_object in pairs ( menu_objects ) do
    menu_object.isVisible = true
    menu_object.alpha = menu_alpha
end

canSpawnMenuObjects = true
spawn_menu_objects( "food", 0, menu_randomSpeed() )
spawn_menu_objects( "food", 0, - menu_randomSpeed() )
spawn_menu_objects( "food", menu_randomSpeed(), 0 )
spawn_menu_objects( "food", - menu_randomSpeed(), 0 )
spawn_menu_objects( "poison", 0, menu_randomSpeed() )
spawn_menu_objects( "poison", 0, - menu_randomSpeed() )
spawn_menu_objects( "poison", menu_randomSpeed(), 0 )
spawn_menu_objects( "poison", - menu_randomSpeed(), 0 )
spawn_menu_objects( "reward", menu_randomSpeed(), 0 )
return scene
