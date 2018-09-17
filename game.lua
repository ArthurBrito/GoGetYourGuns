local composer = require( "composer" )

local scene = composer.newScene()

-- Global Variables
local score = 0
local lives = 3
local died = false
local pingeonsTable = {}
local balloonsTable = {}
local musicTrack

-- Set up display groups
local backGroup = display.newGroup()  -- Display group for the background image
local mainGroup = display.newGroup()  -- Display group for the pingeon and balloons
local uiGroup = display.newGroup()    -- Display group for UI objects like the score and lives

-- Add Background Image
display.setStatusBar( display.HiddenStatusBar )

local background = display.newImageRect(backGroup, "sky_background.png", display.contentWidth, display.contentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

local livesText = display.newText(uiGroup, "Lives: ", 50, 30, native.systemFont, 20)
local livesValue = display.newText(uiGroup, lives, 80, 30, native.systemFont, 20)
local scoreValue = display.newText(uiGroup, score, 300, 30, native.systemFont, 20)
  
local physics = require("physics")
physics.start()

physics.setGravity( 0, 0 )

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


local function tapballoon(event) 
  updateScore(5)
  ballonBurst = audio.loadSound( "./sounds/balloon-burst.wav" )
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
  fireSound = audio.loadSound( "./sounds/gun-fire.aiff" )
  dyingAnimal = audio.loadSound( "./sounds/bird-scream.wav" )
  audio.play(fireSound)
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
  local newPingeon = display.newImageRect( mainGroup, "pingeon.gif", 102, 85)
  table.insert(pingeonsTable, newPingeon)
  physics.addBody( newPingeon, "dynamic", { radius=5 } )
  newPingeon.myName = "pingeon"
  newPingeon:addEventListener("tap", tapPingeon, newPingeon)

  local whereFrom = math.random( 3 )

  if ( whereFrom == 1 ) then
    -- from the left
    newPingeon.x = -60
    newPingeon.y = math.random( 500 )
    newPingeon:setLinearVelocity( math.random( 40,45 ), math.random( 50,60 ) )
  elseif ( whereFrom == 2 ) then
    -- From the top
    newPingeon.x = math.random( display.contentWidth )
    newPingeon.y = -60
    newPingeon:setLinearVelocity( math.random( -40,40 ), math.random( 40,120 ) )
  elseif ( whereFrom == 3 ) then
    -- From the right
    newPingeon.x = display.contentWidth + 60
    newPingeon.y = math.random( 500 )
    newPingeon:setLinearVelocity( math.random( -120,-40 ), math.random( 20,60 ) )
  end

end

local function createBallon()
  local balloon = display.newImageRect( mainGroup, "balloon.png", 102, 85)
  table.insert(balloonsTable, balloon)
  physics.addBody( balloon, "dynamic", { isSensor=true })
  balloon.myName = "balloon"
  balloon:addEventListener("tap", tapballoon, balloon)
  -- from the left
  balloon.x = math.random( 30, display.contentWidth - 30 )
  balloon.y = display.contentHeight + 99
  balloon:setLinearVelocity( 0, -50 )

end

local function gameLoop()
  createPingeon()

  if (lives <= 0) then
    timer.performWithDelay(1000, endGame)
  end

  for i = #pingeonsTable, 1, -1 do
    local thisPingeon = pingeonsTable[i]
 
        if ( thisPingeon.x < -100 or
             thisPingeon.x > display.contentWidth + 100 or
             thisPingeon.y < -100 or
             thisPingeon.y > display.contentHeight + 100 )
        then
            display.remove( thisPingeon )
            table.remove( pingeonsTable, i )
        end
      end
end

local function ballonLoopTimer() 
  createBallon()

  for i = #balloonsTable, 1, -1 do
    local thisballoon = balloonsTable[i]
        if (thisballoon.y < -100 )
        then
            display.remove( thisballoon )
            lives = lives -1
            livesValue.text = lives
            table.remove( balloonsTable, i )
        end
      end
end

ballonLoopTimer = timer.performWithDelay( 2000, ballonLoopTimer, 0 )
gameLoopTimer = timer.performWithDelay( 800, gameLoop, 0 )


-- create()
function scene:create( event )
  musicTrack = audio.loadStream( "./sounds/forest.wav" )
  
end

function scene:show( event )

	local sceneGroup = self.view
  local phase = event.phase
  audio.play( musicTrack, { channel=1, loops=-1 } )

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
     -- Code here runs when the scene is entirely on screen

       	physics.start()
        
	end
end


function scene:hide( event )

	local sceneGroup = self.view
  local phase = event.phase
  print('hide')

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
    timer.cancel(gameLoopTimer)
    timer.cancel(ballonLoopTimer)

	elseif ( phase == "did" ) then
      physics.pause()
      musicTrack.pause()
      -- Stop the music!
        
	end
end

function scene:destroy( event )

  local sceneGroup = self.view
  print('destroy')
    timer.cancel(gameLoopTimer)
    timer.cancel(ballonLoopTimer)

    physics.pause()
    audio.stop( 1 )
    display.remove(uiGroup)
    display.remove(mainGroup)
    display.remove(backGroup)
        
  -- timer.cancel(gameLoop)
  -- timer.cancel(ballonLoopTimer)
	-- Code here runs prior to the removal of scene's view
	-- Dispose audio!

end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene