local composer = require( 'composer' )
local scene = composer.newScene()
local widget = require('widget')
local sounds = require('libraries.sounds')
local databox = require('libraries.databox')
local colors = require('classes.colors-rgb')

widget.setTheme ( 'widget_theme_ios' )

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local screenLeft = display.screenOriginX
local screenWidth = display.viewableContentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = display.screenOriginY
local screenHeight = display.viewableContentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight

local visualButtons = {}
local soundsButtons = {}

local function switchScene(event)
	local sceneID = event.target.id
	local options = {effect = "crossFade", time = 300, params = {title = event.target.id}}
	composer.gotoScene( sceneID, options )
	-- Show Options & About buttons in the Menu --
	if sceneID == "scenes.menu" then
		game_version.isVisible = true
		if (optionsBtn ~= nil) and (aboutBtn ~= nil) then
			optionsBtn.isVisible = true
			aboutBtn.isVisible = true
		end
		colorSelection.isVisible = false
	end
	if (sceneID == "scenes.colorselection") then
		if (colorSelection ~= nil) then
			colorSelection.isVisible = false
		end
	end
	soundBtn_group.isVisible = false
end

function logoAnimation(bool, _temp_displayLogo)
	if (bool == true) then
		local toScale = math.random(0.1, 0.2)
		local random_sise = math.random(1, 2)
		if random_sise == 1 then
			logoRotation = 360
		else
			logoRotation = -360
		end
		levelLogo_animation = transition.to(_temp_displayLogo, {time = math.random(100, 250), delta = true, iterations = 2, rotation = logoRotation, xScale = toScale, yScale = toScale, onComplete = function(object)
			object:scale(1, 1)
		end})
	end
end

local function setUpDisplay(grp)

	local background = display.newRect( grp, centerX, centerY, screenWidth, screenHeight )
	local gradient_options = {
		type = "gradient",
		color1 = { 0 / 255, 0 / 255, 0 / 255 },
		color2 = { 50 / 255, 50 / 255, 50 / 255 },
		direction = "up"
	}
	background:setFillColor(gradient_options)

	local displayLogo = display.newImageRect( grp, "images/backgrounds/options2.png", 636, 208)
	displayLogo.x = centerX
	displayLogo.y = centerY - 80
	displayLogo:scale(0.6, 0.6)

	_temp_displayLogo = displayLogo

	local backBtn = widget.newButton ({label = "Back", id = "scenes.menu", onRelease = switchScene})
	backBtn.anchorX = 0
	backBtn.anchorY = 1
	backBtn.x = screenLeft + 10
	backBtn.y = screenBottom - 10
	backBtn:scale(0.5, 0.5)
	grp:insert(backBtn)
	--=========================================================================================--
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

	soundsButtons.on = widget.newButton({
		label = "Turn sound Off",
		labelColor = {default = {colorsRGB.RGB("red")}, over = {colorsRGB.RGB("blue")}},
		onRelease = function()
			sounds.isSoundOn = false
			SoundIsOff = false
			updateDataboxAndVisibility()
		end
	})
	soundsButtons.off = widget.newButton({
		label = "Turn sound On",
		labelColor = {default = {colorsRGB.RGB("blue")}, over = {colorsRGB.RGB("red")}},
		onRelease = function()
			audio.stop()
			sounds.isSoundOn = true
			SoundIsOff = true
			updateDataboxAndVisibility()
		end
	})
	colorSelection = widget.newButton({
		label = "Color Selection",
		id = "scenes.colorselection",
		labelColor = {default = {colorsRGB.RGB("blue")}, over = {colorsRGB.RGB("green")}},
		onRelease = switchScene,
	})

	local spacing = 30

	soundBtn_group = display.newGroup()
	-- Sound-On Button Display Settings
	soundsButtons.on.x = centerX
	soundsButtons.on.y = centerX + centerY - 180
	soundsButtons.on.width = 100
	soundsButtons.on.height = 25

	-- Sound-Off Button Display Settings
	soundsButtons.off.x = soundsButtons.on.x
	soundsButtons.off.y = soundsButtons.on.y
	soundsButtons.off.width = 100
	soundsButtons.off.height = 25

	-- Sound-Off Button Display Settings
	colorSelection.x = soundsButtons.off.x
	colorSelection.y = soundsButtons.off.y + spacing
	colorSelection.width = 100
	colorSelection.height = 25

	soundBtn_group:insert(soundsButtons.on)
	soundBtn_group:insert(soundsButtons.off)

	updateDataboxAndVisibility()
	table.insert(visualButtons, soundsButtons.on)
	table.insert(visualButtons, soundsButtons.off)
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
		logoAnimation(true, _temp_displayLogo)
		if soundBtn_group ~= nil then
			soundBtn_group.isVisible = true
		end
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
