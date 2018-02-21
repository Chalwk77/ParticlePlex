
local composer = require( "composer" )
local colors = require('classes.colors-rgb')
local scene = composer.newScene()
local widget = require("widget")
widget.setTheme ( "widget_theme_ios" )

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

-- -------------------------------------------------------------------------------

local function switchScene(event)
	local sceneID = event.target.id
	local options = {effect = "crossFade", time = 300}
	composer.gotoScene( sceneID, options )
	-- Show Options & About buttons in the Menu --
	if sceneID == "scenes.menu" then
		if (optionsBtn ~= nil) and (aboutBtn ~= nil) then
			optionsBtn.isVisible = true
			aboutBtn.isVisible = true
		end
		background.isVisible = false
		helptext.isVisible = false
		helpShade.alpha = 0
	end
end

local function setUpDisplay(grp)

	local backBtn = widget.newButton ({label = "Back", id = "scenes.menu", onRelease = switchScene})
	backBtn.anchorX = 0
	backBtn.anchorY = 1
	backBtn.x = screenLeft + 10
	backBtn.y = screenBottom - 10
	backBtn:scale(0.5, 0.5)
	grp:insert(backBtn)

	local helpText = [[
    Particle Plex

    You are a hungry square that wants to eat food...
    Green food is Healthy. Red food is poisonous.
    If you eat the red food you lose the game.
    Every time you eat a piece of green food, your square will get bigger!

    Random power ups and penalties will spawn - there are three of each.

    ~~ Powerups ~~
        [1] Weight Loss: Your square will shrink to half its current size
        [2] All you can Eat: Eat red & green food for a limited time
        [3] Traffic Jam: All objects will slow down for a limited time

    ~~ Penalties ~~
        [1] Weight Gain: Your square will double in size
        [2] Food Contaminated: All food is bad for a limited time, so don't touch it!
        [3] Rush Hour: All objects will speed up for a limited time

    ~~ Controls ~~
        Movement
            - WASD, Arrow Keys or Mouse (Best played with mouse)
        Action Keys
            - ENTER = Start Game (From the menu)
            - Escape = pause game
            - F11 = fullscreen mode or normal window mode


			~ Food Icons designed by Freepik
    ]]

	local paragraphs = {}
	local paragraph
	local tmpString = helpText

	-- Help Scene background
	background = display.newImageRect( "images/backgrounds/background.png", display.contentWidth + 550, display.contentHeight + 1000)
	background.alpha = 0.50

	-- Text Options
	local options = {
		text = "",
		width = display.contentWidth,
		fontSize = 7,
		align = "left",
	}

	local yOffset = 10
	helpShade = display.newRect( 0, 0, display.contentWidth, display.contentHeight)
	helpShade.x = display.viewableContentWidth / 2
	helpShade.y = display.viewableContentHeight / 2
	helpShade:setFillColor ( colorsRGB.RGB("blue") )
	helpShade.alpha = 0.50
	repeat
		local b, e = string.find(tmpString, "\r\n")
		if b then
			paragraph = string.sub(tmpString, 1, b - 1)
			tmpString = string.sub(tmpString, e + 1)
		else
			paragraph = tmpString
			tmpString = ""
		end
		options.text = paragraph
		paragraphs[#paragraphs + 1] = display.newText( options )
		paragraphs[#paragraphs].anchorX = 0
		paragraphs[#paragraphs].anchorY = 0
		paragraphs[#paragraphs].x = 10
		paragraphs[#paragraphs].y = yOffset
		paragraphs[#paragraphs]:setFillColor( colorsRGB.RGB("white") )
		paragraphs[#paragraphs].alpha = 1
		helptext = paragraphs[#paragraphs]
		yOffset = yOffset + paragraphs[#paragraphs].height
	until tmpString == nil or string.len( tmpString ) == 0
	-- Create Copyright Notice
	local crMessage = display.newText( grp, "Copyright © 2017 Particle Plex, by Jericho Crosby", 0, 0, native.systemFontBold, 10 )
	crMessage.x = centerX
	crMessage.y = centerY + 125
	crMessage:setFillColor( colorsRGB.RGB("white") )
	crMessage.alpha = 1
end

-- "scene:create()"
function scene:create( event )

	local sceneGroup = self.view

	-- Initialize the scene here.
	-- Example: add display objects to "sceneGroup", add touch listeners, etc.

	setUpDisplay(sceneGroup)

end


-- "scene:show()"
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Called when the scene is still off screen (but is about to come on screen).
	elseif ( phase == "did" ) then
		-- Called when the scene is now on screen.
		-- Insert code here to make the scene come alive.
		-- Example: start timers, begin animation, play audio, etc.

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
