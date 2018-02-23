display.setStatusBar(display.HiddenStatusBar)
local composer = require('composer')
local sounds = require('libraries.sounds')
local http = require "socket.http"
local ltn12 = require("ltn12")
local build_version = system.getInfo( "appVersionString" )

-- Keeps the screen ON while idle.
system.setIdleTimer( false )

function CheckForUpdates()
    local latest_version_url = "https://pastebin.com/raw/Rw7GXN8z"
    local game = {version = build_version}
    local response = {}
    local a, b, c = http.request({url = latest_version_url, sink = ltn12.sink.table(response)})
    local latest_version = response[1]
    if latest_version ~= nil then
        if (string.find(latest_version, "%d%.%d.%d+") == 1) then
            -- application is up to date
            if game.version == latest_version then
                game_version = display.newText( "Version " .. latest_version, display.viewableContentWidth / 2, display.viewableContentHeight / 2, native.systemFontBold, 10 )
                game_version:setFillColor(1, 0.9, 0.5)
                game_version.x = display.contentCenterX
                game_version.y = display.contentCenterX + display.contentCenterY - 90
                game_version.alpha = 0.50
                -- an update is available
            elseif game.version < latest_version then
                local function onComplete( event )
                    if ( event.action == "clicked" ) then
                        local i = event.index
                        if ( i == 1 ) then
                            -- do nothing
                        elseif ( i == 2 ) then
                            -- opens google play app listing
                            system.openURL("https://play.google.com/store/apps/details?id=com.gmail.crosby227.jericho.ParticlePlex&hl=en")
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
                -- pastebin version is lower than the system version
            elseif game.version > latest_version then
                -- do nothing (version string will disappear)
            end
        end
    end
end
-- init check for updates
CheckForUpdates()

settings = { }
settings = {
    ["enableLevelSelection"] = true,
    ["animatePlayer"] = false,
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

function fullScreenListener()
    local platform = system.getInfo('platformName')
    if platform == 'Win' then
        Runtime:addEventListener('key',
            function(event)
                if event.phase == 'down' and ((platform == 'Win' and (event.keyName == 'f11' or (event.keyName == 'enter' and event.isAltDown)))) then
                    if native.getProperty('windowMode') == 'fullscreen' then
                        native.setProperty('windowMode', 'normal')
                    else
                        native.setProperty('windowMode', 'fullscreen')
                    end
                end
            end
        )
    end
end

local function onBackButtonPressed( event )
    if event.keyName == "back" then
        local platformName = system.getInfo( "platformName" )
        if (platformName == "Android") or (platformName == "WinPhone") then
            sounds.play('onTap')
            native.showAlert("Confirm Exit", "Are you sure you want to exit?", {"Yes", "No"},
                function(event)
                    if (event.action == 'clicked' and event.index == 1) then
                        native.requestExit()
                    end
                end
            )
            return true
        end
    end
    return false
end

Runtime:addEventListener( "key", onBackButtonPressed )
composer.gotoScene( "scenes.menu" )
fullScreenListener()
