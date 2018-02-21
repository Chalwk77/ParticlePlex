
local composer = require( "composer" )
local colors = require('classes.colors-rgb')
local scene = composer.newScene()
local widget = require("widget")
widget.setTheme ( "widget_theme_ios" )

local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

local function switchScene(event)
	local sceneID = event.target.id
	local options = {effect = "crossFade", time = 300}
	composer.gotoScene( sceneID, options )
	-- Show Options & About buttons in the Menu --
	if sceneID == "scenes.menu" then
		game_version.isVisible = true
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

	local xPos = screenLeft + 10
	local yPos = screenBottom - 10

	local backBtn = widget.newButton ({label = "Back", id = "scenes.menu", onRelease = switchScene})
	backBtn.anchorX = 0
	backBtn.anchorY = 1
	backBtn.x = xPos
	backBtn.y = yPos
	backBtn:scale(0.5, 0.5)
	grp:insert(backBtn)

	local helpText = [[
	* GAME INFORMATION COMING SOON!

	~ Food Icons designed by Freepik <https://www.freepik.com/>
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
		fontSize = 10,
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
	local copyright = display.newText( grp, "Copyright © 2018, Particle Plex, Jericho Crosby <jericho.crosby227@gmail.com>", 0, 0, native.systemFontBold, 8 )
	local spacing = 100
	copyright.x = xPos + spacing
	copyright.y = yPos
	copyright.anchorX = 0
	copyright.anchorY = 1
	copyright:setFillColor( colorsRGB.RGB("white") )
	copyright.alpha = 1
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
