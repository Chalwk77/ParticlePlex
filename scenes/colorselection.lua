local composer = require( 'composer' )
local colors = require('classes.colors-rgb')
local sounds = require('libraries.sounds')
local toast = require('modules.toast')
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

local function switchScene(event)
	local sceneID = event.target.id
    local options = {effect="crossFade", time=300}
    composer.gotoScene( sceneID, options )
    sounds.play("onTap")
    if sceneID == "scenes.options" then
        if (colorSelection ~= nil) then
            colorSelection.isVisible = true
        end
    end
end

local function setUpDisplay(grp)
	
    local screen_adjustment = 1
    local bg = display.newImage(grp, "images/backgrounds/colorselectbg.png")
    bg.xScale = (screen_adjustment  * bg.contentWidth)/bg.contentWidth
    bg.yScale = bg.xScale
    bg.x = centerX
    bg.y = centerY
	bg.alpha = 1
    bg:scale(1,1)
    
    local colorLogo = display.newImage(grp, "images/backgrounds/colorselect.png")
    colorLogo.xScale = (screen_adjustment  * bg.contentWidth)/bg.contentWidth
    colorLogo.yScale = bg.xScale
    colorLogo.x = centerX
    colorLogo.y = centerY - 110
    colorLogo:scale(0.23, 0.23)
	colorLogo.alpha = 1
    
	local backBtn = widget.newButton ({
        label="Back", 
        id="scenes.options", 
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
	for i = 1, 9 do
		local colors = widget.newButton ({
			defaultFile = 'images/color data/slide_menu' .. i .. '.png',
			overFile = 'images/color data/slide_menu' .. i .. '_press.png',
			width = 64, height = 64,
			x = x * spacing + 240, 
            y = 100 + y * spacing + 25,
            onRelease = function()
                delay = 750
                if (i == 1) then
                    bgColor = "red"
                    toast.new("red", delay)
                elseif (i == 2) then
                    bgColor = "yellow"
                    toast.new("yellow", delay)
                elseif (i == 3) then
                    bgColor = "pink"
                    toast.new("pink", delay)
                elseif (i == 4) then
                    bgColor = "green"
                    toast.new("green", delay)
                elseif (i == 5) then
                    bgColor = "purple"
                    toast.new("purple", delay)
                elseif (i == 6) then
                    bgColor = "orange"
                    toast.new("orange", delay)
                elseif (i == 7) then
                    bgColor = "blue"
                    toast.new("blue", delay)
                elseif (i == 8) then
                    bgColor = "white"
                    toast.new("white", delay)
                elseif (i == 9) then
                    bgColor = "black"
                    toast.new("black", delay)
                end
            end
        })
        colors:scale(0.5,0.5)
        grp:insert(colors)
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
