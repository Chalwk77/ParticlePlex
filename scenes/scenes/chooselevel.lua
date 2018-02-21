local composer = require( 'composer' )
local colors = require('classes.colors-rgb')
local sounds = require('libraries.sounds')
local scene = composer.newScene()
local widget = require('widget')
widget.setTheme ( 'widget_theme_ios' )

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

level = { }

local function switchScene(event)
	local sceneID = event.target.id
    local options = {effect="crossFade", time=300}
    composer.setVariable( "levelNum", event.target.levelNum )
    levelNum = event.target.levelNum
    if levelNum == 1 then 
        levelDefined = false
        level[1] = { "level 1", { 1, 2, 0.005 }, 30, "1"}
        level[2] = { "level 2", { 1, 2, 0.010 }, 60, "2"}
        level[3] = { "level 3", { 1, 2, 0.015 }, 90, "3"}
        level[4] = { "level 4", { 1, 2, 0.025 }, 120, "4"}
        level[5] = { "level 5", { 1, 2, 0.035 }, 150, "5"}
        level[6] = { "level 6", { 1, 2, 0.045 }, 180, "6"}
        level[7] = { "level 7", { 1, 2, 0.055 }, 210, "7"}
        level[8] = { "level 8", { 1, 2, 0.065 }, 240, "8"}
        level[9] = { "level 9", { 1, 2, 0.075 }, 270, "9"}
        level[10] = { "level 10", { 1, 2, 0.085 }, 300, "10"}
    elseif levelNum == 2 then
        levelDefined = true
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
    elseif levelNum == 3 then 
        levelDefined = true
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
    elseif levelNum == 4 then 
        levelDefined = true
        level[1] = { "level 1", { 1, 2, 0.010 },  nil, nil}
        level[2] = { "level 2", { 1, 2, 0.015 },  nil, nil}
        level[3] = { "level 3", { 1, 2, 0.025 }, 0, "3"}
        level[4] = { "level 4", { 1, 2, 0.035 }, 30, "4"}
        level[5] = { "level 5", { 1, 2, 0.045 }, 60, "5"}
        level[6] = { "level 6", { 1, 2, 0.055 }, 90, "6"}
        level[7] = { "level 7", { 1, 2, 0.065 }, 120, "7"}
        level[8] = { "level 8", { 1, 2, 0.075 }, 150, "8"}
        level[9] = { "level 9", { 1, 2, 0.085 }, 180, "9"}
        level[10] = { "level 10", { 1, 2, 0.085 }, 210, "10"}
    elseif levelNum == 5 then 
        levelDefined = true
        level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
        level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
        level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
        level[4] = { "level 4", { 1, 2, 0.035 },  0, "4"}
        level[5] = { "level 5", { 1, 2, 0.045 }, 30, "5"}
        level[6] = { "level 6", { 1, 2, 0.055 }, 60, "6"}
        level[7] = { "level 7", { 1, 2, 0.065 }, 90, "7"}
        level[8] = { "level 8", { 1, 2, 0.075 }, 120, "8"}
        level[9] = { "level 9", { 1, 2, 0.085 }, 150, "9"}
        level[10] = { "level 10", { 1, 2, 0.085 }, 180, "10"}
    elseif levelNum == 6 then 
        levelDefined = true
        level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
        level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
        level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
        level[4] = { "level 4", { 1, 2, 0.035 }, nil, nil}
        level[5] = { "level 5", { 1, 2, 0.045 },  0, "5"}
        level[6] = { "level 6", { 1, 2, 0.055 }, 30, "6"}
        level[7] = { "level 7", { 1, 2, 0.065 }, 60, "7"}
        level[8] = { "level 8", { 1, 2, 0.075 }, 90, "8"}
        level[9] = { "level 9", { 1, 2, 0.085 }, 120, "9"}
        level[10] = { "level 10", { 1, 2, 0.085 }, 150, "10"}
    elseif levelNum == 7 then 
        levelDefined = true
        level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
        level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
        level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
        level[4] = { "level 4", { 1, 2, 0.035 }, nil, nil}
        level[5] = { "level 5", { 1, 2, 0.045 }, nil, nil}
        level[6] = { "level 6", { 1, 2, 0.055 },  0, "6"}
        level[7] = { "level 7", { 1, 2, 0.065 }, 30, "7"}
        level[8] = { "level 8", { 1, 2, 0.075 }, 60, "8"}
        level[9] = { "level 9", { 1, 2, 0.085 }, 90, "9"}
        level[10] = { "level 10", { 1, 2, 0.085 }, 120, "10"}
    elseif levelNum == 8 then 
        levelDefined = true
        level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
        level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
        level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
        level[4] = { "level 4", { 1, 2, 0.035 }, nil, nil}
        level[5] = { "level 5", { 1, 2, 0.045 }, nil, nil}
        level[6] = { "level 6", { 1, 2, 0.055 }, nil, nil}
        level[7] = { "level 7", { 1, 2, 0.065 },  0, "7"}
        level[8] = { "level 8", { 1, 2, 0.075 }, 30, "8"}
        level[9] = { "level 9", { 1, 2, 0.085 }, 60, "9"}
        level[10] = { "level 10", { 1, 2, 0.085 }, 90, "10"}
    elseif levelNum == 9 then 
        levelDefined = true
        level[1] = { "level 1", { 1, 2, 0.010 }, nil, nil}
        level[2] = { "level 2", { 1, 2, 0.015 }, nil, nil}
        level[3] = { "level 3", { 1, 2, 0.025 }, nil, nil}
        level[4] = { "level 4", { 1, 2, 0.035 }, nil, nil}
        level[5] = { "level 5", { 1, 2, 0.045 }, nil, nil}
        level[6] = { "level 6", { 1, 2, 0.055 }, nil, nil}
        level[7] = { "level 7", { 1, 2, 0.065 }, nil, nil}
        level[8] = { "level 8", { 1, 2, 0.075 },  0, "8"}
        level[9] = { "level 9", { 1, 2, 0.085 }, 30, "9"}
        level[10] = { "level 10", { 1, 2, 0.085 }, 60, "10"}
    elseif levelNum == 10 then
        levelDefined = true
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
    if sceneID == "scenes.menu" then
        if (optionsBtn ~= nil) and (aboutBtn ~= nil) then
            optionsBtn.isVisible = true
            aboutBtn.isVisible = true
        end
    end
    sounds.play("onTap")
    runHealthAnimation = true
    composer.gotoScene( sceneID, options )
end

function level_select_logo_animation(bool, _temp_levelLogo)
    if (bool == true) then
        local toScale = math.random(0.1, 0.2)
        local random_wise = math.random(1,2)
        if random_wise == 1 then 
            logoRotation = 360
        else
            logoRotation = -360
        end
        levelLogo_animation = transition.to(_temp_levelLogo, {time = math.random(100, 250), delta = true, iterations=2, rotation = logoRotation, xScale = toScale, yScale = toScale, onComplete = function(object)
            object:scale(1, 1)
        end})
    end
end

local function setUpDisplay(grp)
    local screen_adjustment = 1
    local bg = display.newImage(grp, "images/backgrounds/levelselectbg.png")
    bg.xScale = (screen_adjustment  * bg.contentWidth)/bg.contentWidth
    bg.yScale = bg.xScale
    bg.x = centerX
    bg.y = centerY
	bg.alpha = 0.35
    bg:scale(0.5,0.5)
    
    local levelLogo = display.newImage(grp, "images/backgrounds/selectlevel.png")
    levelLogo.xScale = (screen_adjustment  * bg.contentWidth)/bg.contentWidth
    levelLogo.yScale = bg.xScale
    levelLogo.x = centerX
    levelLogo.y = centerY - 120
    levelLogo:scale(0.6, 1)
	levelLogo.alpha = 1
    
    _temp_levelLogo = levelLogo
    
	local backBtn = widget.newButton ({
        label="Back", 
        id="scenes.menu", 
        onRelease=switchScene, 
        labelColor = {default = {colorsRGB.RGB("black")}, over = {colorsRGB.RGB("white")}}
    })
	backBtn.anchorX = 0
	backBtn.anchorY = 1
	backBtn.x = screenLeft + 10
	backBtn.y = screenBottom - 10
    backBtn:scale(0.5, 0.5)
	grp:insert(backBtn)

	local x, y = -2, 0
	local spacing = 100
	for i = 1, 10 do
		local levelBtn = widget.newButton ({
            label="Level ".. i, 
            id="scenes.reload_game",
			labelColor = {default = {colorsRGB.RGB("black")}, over = {colorsRGB.RGB("white")}},
			font = native.systemFontBold,
			fontSize = 12,
			labelYOffset = -5,
			defaultFile = 'images/backgrounds/level.png',
			overFile = 'images/backgrounds/level-over.png',
			width = 64, height = 64,
			x = x * spacing + 240, 
            y = 100 + y * spacing + 25,
            onRelease=switchScene
        })
		levelBtn.levelNum = i
        levelBtn:scale(0.8,0.9)
		grp:insert(levelBtn)
		x = x + 1
		if x == 3 then
			x = -2
			y = y + 1
		end
	end
end

-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view
    setUpDisplay(sceneGroup)
    -- Initialize the scene here.
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.

end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        level_select_logo_animation(true, _temp_levelLogo)
        if win_animate_transition ~= nil then 
            timer.cancel(win_animate_transition)
        end
        -- Called when the scene is still off screen (but is about to come on screen).
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen.
        -- Insert code here to make the scene come alive.
        -- Example: start timers, begin animation, play audio, etc.
		composer.removeScene( "play" )
    end
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen).
        -- Insert code here to "pause" the scene.
        -- Example: stop timers, stop animation, stop audio, etc.
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


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
