display.setStatusBar(display.HiddenStatusBar)
local composer = require('composer')
local sounds = require('libraries.sounds')
local https = require "socket.http"
local ltn12 = require("ltn12")
local build_version = system.getInfo( "appVersionString" )

function CheckForUpdates()
    local latest_version_url = "https://pastebin.com/raw/Rw7GXN8z"
    local game = {version = build_version }
    local response = {}
    local a, b, c = https.request({url = latest_version_url, sink = ltn12.sink.table(response)})
    local latest_version = response[1]
    if (string.find(latest_version, "%d%.%d.%d+") == 1) then
        if game.version == latest_version then
            game_version = display.newText( "Version " .. latest_version, display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFontBold, 10 )
            game_version:setFillColor(1, 0.9, 0.5)
            game_version.x = display.contentCenterX
            game_version.y = display.contentCenterX + display.contentCenterY - 90
            game_version.alpha = 0.50
        elseif game.version < latest_version then
            local function onComplete( event )
                if ( event.action == "clicked" ) then
                    local i = event.index
                    if ( i == 1 ) then
                        -- do nothing
                    elseif ( i == 2 ) then
                        -- temporary page
                        system.openURL("https://pastebin.com/raw/BNPhMuZD")
                    end
                end
            end
            local function onTextClick( event )
                if ( event.phase == "began" ) then
                    local alert = native.showAlert( "Download Latest Update", "Would you like to download the latest update?", { "No", "Yes" }, onComplete )
                end
                return true
            end
            game_version = display.newText( "Version " .. latest_version .. " is available!", display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFontBold, 10 )
            game_version:setFillColor(1, 0.9, 0.5)
            game_version.x = display.contentCenterX
            game_version.y = display.contentCenterX + display.contentCenterY - 90
            game_version.alpha = 0.50
            game_version:addEventListener( "touch", onTextClick )
        end
    end
end
-- init check for updates
CheckForUpdates()

settings = { }
settings = {
    ["enableLevelSelection"] = true,
    ["animatePlayer"] = false,
    ["useOtherPlayer"] = true,
    ["useOtherFood"] = true,
    ["enableSidebarMenu"] = true,
    ["scorelimit"] = 500,
    ["rewardChances"] = 1000,
    ["delayAnimate"] = false,
    ["FoodContaminatedTime"] = 5000,
    ["CancelMovementOnKeyRelease"] = true,
    -- min | max size of poison and food
    ["minSize"] = 6,
    ["maxSize"] = 25,
    ["SpawnFoodAndPoison"] = true,
    -- keyboard movement velocity
    ["movementVelocity"] = 5,
    -- invulnerable settings: player is invulnerable for 1000/ms when the game starts
    ["delayOnTouch"] = false,
    ["delayCollision"] = true,
    ["invulnerableTimer"] = 1000,
    ["collisions"] = 2,
    -- Show/Hide previous score when the game opens
    ["showPreviousScore"] = false,
    -- combo scoring --
    ["useCombos"] = false
}

-- Exit and enter fullscreen mode
-- CMD+CTRL+F on OS X
-- F11 or ALT+ENTER on Windows
local platform = system.getInfo('platformName')
if platform == 'Mac OS X' or platform == 'Win' then
    Runtime:addEventListener('key', function(event)
        if event.phase == 'down' and (
        (platform == 'Mac OS X' and event.keyName == 'f' and event.isCommandDown and event.isCtrlDown) or
        (platform == 'Win' and (event.keyName == 'f11' or (event.keyName == 'enter' and event.isAltDown)))
    ) then
        if native.getProperty('windowMode') == 'fullscreen' then
            native.setProperty('windowMode', 'normal')
        else
            native.setProperty('windowMode', 'fullscreen')
        end
    end
end)
end

-- Add support for back button on Android and Window Phone
local function onBackButtonPressed( event )
if event.keyName == "back" then
    local platformName = system.getInfo( "platformName" )
    if (platformName == "Android") or (platformName == "WinPhone") then
        sounds.play('onTap')
        native.showAlert("Confirm Exit", "Are you sure you want to exit?", {"Yes", "No"}, function(event)
            if (event.action == 'clicked' and event.index == 1) then
            native.requestExit()
        end
    end)
    return true
end
end
return false
end

Runtime:addEventListener( "key", onBackButtonPressed )
-- Entry point
composer.gotoScene( "scenes.menu" )

-- Check for Updates