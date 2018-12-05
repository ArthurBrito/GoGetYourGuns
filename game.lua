local composer = require("composer")

local scene = composer.newScene()

-- Global Variables
local score = 0
local lives = 3
local died = false
local pingeonsTable = {}
local balloonsTable = {}
local increasingDificult = 1
local pauseButtonImage
local retomarButton
local myRoundedRect
local menuButton

local musicTrack
local ballonBurst
local dyingAnimal

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the pingeon and balloons
local uiGroup = display.newGroup()    -- Display group for UI objects like the score and lives
local uiModal = display.newGroup()    -- Display group for Modals

-- Add Background Image
display.setStatusBar(display.HiddenStatusBar)

local background = display.newImageRect(backGroup, "sky_background.png", display.contentWidth, display.contentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

local livesText = display.newText(uiGroup, "Lives: ", 50, 30, native.systemFont, 20)
local livesValue = display.newText(uiGroup, lives, 80, 30, native.systemFont, 20)
local scoreValue = display.newText(uiGroup, score, 180, 30, native.systemFont, 20)

local physics = require("physics")
physics.start()

physics.setGravity(0, 0)

local function updateScore(points) 
  score = score + points
  scoreValue.text = score
end

local function endGame()
  composer.setVariable("score", score)
	composer.removeScene("menu")
  composer.removeScene("morreu")
  composer.removeScene("game")
	composer.gotoScene("dead", {time=500, effect="crossFade"})
end


local function tapBalloon(event) 
  updateScore(5)
  audio.play(ballonBurst)

  for i = #balloonsTable, 1, -1 do
    if (balloonsTable[i] == event.target) then
      table.remove(balloonsTable, i)
      display.remove(event.target)
      break
    end
  end
end

local function tapPingeon(event) 
  updateScore(10)
  audio.play(dyingAnimal)
  
  for i = #pingeonsTable, 1, -1 do
    if (pingeonsTable[i] == event.target) then
      table.remove(pingeonsTable, i)
      display.remove(event.target)
      break
    end
  end
end

local function createPingeon()
  local newPingeon = display.newImageRect(mainGroup, "pingeon.gif", 102, 85)
  table.insert(pingeonsTable, newPingeon)
  physics.addBody(newPingeon, "dynamic", { radius=5 })
  newPingeon.myName = "pingeon"
  newPingeon:addEventListener("tap", tapPingeon, newPingeon)

  local whereFrom = math.random(3)

  if (whereFrom == 1) then
    -- from the left
    newPingeon.x = -60
    newPingeon.y = math.random(500)
    newPingeon:setLinearVelocity(math.random(40,45), math.random(50,60))
  elseif (whereFrom == 2) then
    -- From the top
    newPingeon.x = math.random(display.contentWidth)
    newPingeon.y = -60
    newPingeon:setLinearVelocity(math.random(-40,40), math.random(40,120))
  elseif (whereFrom == 3) then
    -- From the right
    newPingeon.x = display.contentWidth + 60
    newPingeon.y = math.random(500)
    newPingeon:setLinearVelocity(math.random(-120,-40), math.random(20,60))
  end

end

local function createBallon()
  increasingDificult = increasingDificult + 0.05
  local balloon = display.newImageRect(mainGroup, "balloon.png", 102, 85)
  table.insert(balloonsTable, balloon)
  physics.addBody(balloon, "dynamic", { isSensor=true })
  balloon.myName = "balloon"
  balloon:addEventListener("tap", tapBalloon, balloon)
  -- from the left
  balloon.x = math.random(30, display.contentWidth - 30)
  balloon.y = display.contentHeight + 99
  balloon:setLinearVelocity(0,(increasingDificult * -50))

end

local function gameLoop()
  createPingeon()
  if (increasingDificult >= 3) then
    createPingeon()
  end 
  if (increasingDificult >= 5) then
    createPingeon()
  end
  if (increasingDificult >= 7) then
    createPingeon()
  end

  if (lives <= 0) then
    timer.performWithDelay(1000, endGame)
  end

  for i = #pingeonsTable, 1, -1 do
    local thisPingeon = pingeonsTable[i]
 
        if (thisPingeon.x < -100 or
             thisPingeon.x > display.contentWidth + 100 or
             thisPingeon.y < -100 or
             thisPingeon.y > display.contentHeight + 100)
        then
            display.remove(thisPingeon)
            table.remove(pingeonsTable, i)
        end
      end
end

local function ballonLoopTimer() 
  createBallon()
  if (increasingDificult >= 2) then
    createBallon()
  end 
  if (increasingDificult >= 4) then
    createBallon()
  end
  if (increasingDificult >= 6) then
    createBallon()
  end
  if (increasingDificult >= 8) then
    createBallon()
    createBallon()
  end

  for i = #balloonsTable, 1, -1 do
    local thisballoon = balloonsTable[i]
        if (thisballoon.y < -100)
        then
            display.remove(thisballoon)
            lives = lives -1
            livesValue.text = lives
            table.remove(balloonsTable, i)
        end
      end
end

local function menu()
  composer.removeScene("game")
  composer.gotoScene("menu", {time=500, effect="crossFade"})
  
end

local function retomar()
	physics.start()
	display.remove(myRoundedRect)
	display.remove(retomarButton)
  display.remove(menuButton)
  audio.play(1)
	timer.resume(gameLoopTimer)
  timer.resume(ballonLoopTimer)

end

local function pauseButton()
		local gradient = {
	        type="gradient",
	        color1={ 1, 1, 0 }, color2={ 0.8, 0.8, 0.8 }, direction="up"
    	}
    physics.pause()
    audio.stop(1)
    timer.pause(gameLoopTimer)
    timer.pause(ballonLoopTimer)
		myRoundedRect = display.newRoundedRect(uiModal, display.contentCenterX, display.contentCenterY, 200, 200, 12)
		myRoundedRect.strokeWidth = 3
		myRoundedRect:setFillColor(0.5)
		myRoundedRect:setStrokeColor(1, 1, 0)
		retomarButton = display.newText(uiModal, "Retomar", display.contentCenterX , display.contentCenterY -30, native.systemFontBold, 25)
		retomarButton:setFillColor(gradient)
		retomarButton:addEventListener("tap", retomar)
		menuButton = display.newText(uiModal, "Menu", display.contentCenterX , display.contentCenterY + 50, native.systemFontBold, 25)
		menuButton:setFillColor(gradient)
		menuButton:addEventListener("tap", menu)
end

-- create()
function scene:create(event)
  musicTrack = audio.loadStream("sounds/forest.wav")
  ballonBurst = audio.loadSound("sounds/ballon-burst.wav")
  dyingAnimal = audio.loadSound("sounds/bird.wav")
  
end

function scene:show(event)

	local sceneGroup = self.view
  local phase = event.phase
  
	if (phase == "will") then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

  elseif (phase == "did") then
    audio.play(musicTrack, { channel=1, loops=-1 })
    ballonLoopTimer = timer.performWithDelay(2000 , ballonLoopTimer, 0)
    gameLoopTimer = timer.performWithDelay(800, gameLoop, 0)
    physics.start()
    pauseButtonImage = display.newImageRect(uiGroup, "pause-button.png", 40, 40)
    pauseButtonImage.x = 290
    pauseButtonImage.y = 30
    pauseButtonImage:addEventListener("tap", pauseButton)
  end
end


function scene:hide(event)

	local sceneGroup = self.view
  local phase = event.phase
  print('hide')

	if (phase == "will") then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    timer.cancel(gameLoopTimer)
    timer.cancel(ballonLoopTimer)

	elseif (phase == "did") then
      physics.pause()
      musicTrack.pause()
      -- Stop the music!
        
	end
end

function scene:destroy(event)

  local sceneGroup = self.view
  timer.cancel(gameLoopTimer)
  timer.cancel(ballonLoopTimer)

  physics.pause()
  audio.stop(1)
  display.remove(uiGroup)
  display.remove(mainGroup)
  display.remove(backGroup)
  display.remove(uiModal)

  Runtime:removeEventListener("tap", pauseButton)
  Runtime:removeEventListener("tap", tapPingeon)
  Runtime:removeEventListener("tap", tapballoon)

	-- Code here runs prior to the removal of scene's view
	-- Dispose audio!

end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene