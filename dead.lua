
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Initialize variables
local soundHighscore

local finalScore

local function gotoGame()
    clickTick = audio.loadSound( "sounds/click-tick.wav" )
    audio.play(clickTick)
    composer.removeScene("game")
    composer.gotoScene( "game", { time=500, effect="crossFade" } )
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
    finalScore =  composer.getVariable( "score" )
 
    local background = display.newImageRect( sceneGroup, "sky_background.png", display.contentWidth, display.contentHeight)	
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    background.fill.effect = "filter.grayscale"
    
    local lapide = display.newImageRect( sceneGroup, "lapide.png", 130, 150 )
    lapide.x = display.contentCenterX
    lapide.y = display.contentCenterY+250
    lapide.fill.effect = "filter.grayscale"

    local gradient = {
        type="gradient",
        color1={ 1, 0, 0 }, color2={ 0.8, 0.8, 0.8 }, direction="up"
    }

    local highScoresHeader = display.newText( sceneGroup, "You lost!", display.contentCenterX, 100, native.systemFontBold, 44 )
    highScoresHeader:setFillColor(gradient)

    local pontuacao = display.newText( sceneGroup, "Score: "..finalScore, display.contentCenterX, 250, native.systemFontBold, 35 )
    pontuacao:setFillColor(gradient)
 
    local menuButton = display.newText( sceneGroup, "Play again?", display.contentCenterX, 350, native.systemFontBold, 35 )
    menuButton:setFillColor(gradient)
    menuButton:addEventListener( "tap", gotoGame )

    -- soundHighscore = audio.loadStream( "audio/slow-atmosphere.wav")
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		audio.play( soundHighscore, { channel=3, loops=-1 } )
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		audio.stop( 3 )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	audio.dispose( soundHighscore )
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
