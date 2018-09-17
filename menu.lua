local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local clickTick = audio.loadSound( "sounds/click-tick.wav" )
local musicTrack

local function gotoGame()
	audio.play(clickTick)
  composer.removeScene("game")
  composer.gotoScene("game", {time=500, effect="crossFade"})
end
 
local function gotoHighScores()
	audio.play(clickTick)
  composer.removeScene("highscores")
  composer.gotoScene("highscores", {time=500, effect="crossFade"})
end

local function gotoInstrucoes()
	-- audio.play(clickTick)
	-- composer.removeScene("instrucoes")
	-- composer.gotoScene("instrucoes", {time=500, effect="crossFade"})
end

local function gotoSobre()
	-- audio.play(clickTick)
	-- composer.removeScene("sobre")
	-- composer.gotoScene("sobre", {time=500, effect="crossFade"})
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	display.setStatusBar( display.HiddenStatusBar )
	musicTrack = audio.loadStream( "./sounds/begining-adventure.wav" )

	local sceneGroup = self.view
	local background = display.newImageRect( sceneGroup, "sky_background.png", display.contentWidth, display.contentHeight)	
  background.x = display.contentCenterX
  background.y = display.contentCenterY

	local gradient = {
	    type="gradient",
	    color1={ 1, 1, 0 }, color2={ 0.8, 0.8, 0.8 }, direction="up"
	}

  local title = display.newText(sceneGroup, "Go Get Your Gun", display.contentCenterX, 80, native.systemFontBold, 35)
  title:setFillColor(gradient)

	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 200, native.systemFontBold, 44 )
	playButton:setFillColor( gradient )
 
	local highScoresButton = display.newText( sceneGroup, "HighScore", display.contentCenterX, 280, native.systemFontBold, 35 )
	highScoresButton:setFillColor( gradient )

	local instrucoesButton = display.newText( sceneGroup, "Instructions", display.contentCenterX, 360, native.systemFontBold, 35 )
	instrucoesButton:setFillColor( gradient )

	local sobreButton = display.newText( sceneGroup, "About", display.contentCenterX, 440, native.systemFontBold, 35 )
	sobreButton:setFillColor( gradient )

	playButton:addEventListener( "tap", gotoGame )
	highScoresButton:addEventListener( "tap", gotoHighScores )
	instrucoesButton:addEventListener("tap", gotoInstrucoes)
	sobreButton:addEventListener( "tap", gotoSobre)

end


-- show()
function scene:show( event )
	audio.play( musicTrack, { channel=1, loops=-1 } )

	local sceneGroup = self.view
	local phase = event.phase

end


-- hide()
function scene:hide( event )
	audio.stop( 1 )

	local sceneGroup = self.view
  local phase = event.phase
  
end


-- destroy()
function scene:destroy( event )

	audio.stop( 1 )
	local sceneGroup = self.view
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
