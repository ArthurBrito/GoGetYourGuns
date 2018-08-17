-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Add Background Image
local background = display.newImageRect("sky_background.png", display.contentWidth, display.contentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

local floor = display.newImageRect("wood.png", display.contentWidth,50)
floor.x = display.contentCenterX
floor.y = display.contentHeight

local balloon = display.newImage("balloon.png", display.contentCenterX, display.contentCenterY)
balloon:scale(0.2, 0.2)
balloon.y = display.contentCenterY

local physics = require("physics")
physics.start()

physics.addBody(balloon, {radius = 100})
physics.addBody(floor, "static")

local function push()
  balloon:applyLinearImpulse(0, -2, balloon.x, balloon.y)
end

balloon:addEventListener("tap", push)