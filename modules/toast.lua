module(..., package.seeall)
local trueDestroy
local destroy

local colors = require('classes.colors-rgb')
function trueDestroy(toast)
    toast:removeSelf();
    toast = nil;
end

local actualContent = {
    height = display.actualContentHeight,
    top = (display.contentHeight - display.actualContentHeight) / 2,
    moreHeight = display.actualContentHeight - display.contentHeight,
}

local function newToast(pText, pTime)
    local pText = pText or nil
    local pTime = pTime or 3000;
    local toast = display.newGroup();
    toast.text = display.newText(toast, pText, 0, 0, native.systemFont, 32);
    toast.text:setTextColor(1, 1, 1)
    toast.background = display.newRoundedRect(toast, 0, 0, toast.text.width + 24, toast.text.height + 24, 16);
    toast.background.strokeWidth = 4
    if bgColor == "red" then 
        toast.background:setFillColor(colorsRGB.RGB("red"))
    elseif bgColor == "yellow" then
        toast.background:setFillColor(colorsRGB.RGB("yellow"))
    elseif bgColor == "pink" then
        toast.background:setFillColor(colorsRGB.RGB("pink"))
    elseif bgColor == "green" then
        toast.background:setFillColor(colorsRGB.RGB("green"))
    elseif bgColor == "purple" then
        toast.background:setFillColor(colorsRGB.RGB("purple"))
    elseif bgColor == "orange" then
        toast.background:setFillColor(colorsRGB.RGB("orange"))
    elseif bgColor == "blue" then
        toast.background:setFillColor(colorsRGB.RGB("blue"))
    elseif bgColor == "black" then
        toast.background:setFillColor(colorsRGB.RGB("black"))
    elseif bgColor == "white" then
        toast.text:setTextColor(colorsRGB.RGB("black"))
        toast.background:setFillColor(colorsRGB.RGB("white"))
    end
    toast.background:setStrokeColor(0, 0, 0)
    toast.text:toFront();
    toast.alpha = 0;
    toast.transition = transition.to(toast, { time = 250, alpha = 1 });
    if pTime ~= nil then
        timer.performWithDelay(pTime, function() destroy(toast) end);
    end
    toast.x = display.contentWidth * .5
    toast.y = actualContent.height * .8
    return toast;
end

function new(pText, pTime)
    newToast(pText, pTime)
end

destroy = function(toast)
    toast.transition = transition.to(toast, { time = 250, alpha = 0, onComplete = function() trueDestroy(toast) end });
end