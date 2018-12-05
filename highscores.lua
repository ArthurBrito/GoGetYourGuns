
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Initialize variables
--local soundHighscore

local fireSound

local json = require("json")
 
local scoresTable = {}
local menuButton
 
local filePath = system.pathForFile("highscores.json", system.DocumentsDirectory)

local function loadScores()
    local file = io.open( filePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scoresTable = json.decode( contents )
    end
 
    if ( scoresTable == nil or #scoresTable == 0 ) then
        scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    end
end

local function saveScores()
 
    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end
 
    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end
end

local function menu()
    composer.removeScene("highscores")
    composer.gotoScene("menu", {time=500, effect="crossFade"})
    
  end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
 
    loadScores()
 
    -- Insert the saved score from the last game into the table, then reset it
    table.insert( scoresTable, composer.getVariable( "score" ) )
    fireSound = audio.loadSound( "sounds/click-tick.wav" )

    composer.setVariable( "score", 0 )
 
    -- Sort the table entries from highest to lowest
    local function compare( a, b )
        return a > b
    end
    table.sort( scoresTable, compare )
 
    saveScores()
 
    local background = display.newImageRect( sceneGroup, "blackground.jpg", display.contentWidth, display.contentHeight)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
 
    local gradient = {
	    type="gradient",
	    color1={ 1, 1, 0 }, color2={ 0.8, 0.8, 0.8 }, direction="up"
	}

    local highScoreHeader = display.newText( sceneGroup, "HighScores", display.contentCenterX, 70, native.systemFontBold, 44 )
    highScoreHeader:setFillColor(gradient)
 
    for i = 1, 10 do
        if ( scoresTable[i] ) then
            local yPos = 90 + ( i * 36 )
 
            local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX-50, yPos, native.systemFont, 36 )
            rankNum:setFillColor( gradient )
            rankNum.anchorX = 1
  
            local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, native.systemFont, 36 )
            thisScore.anchorX = 0
            thisScore:setFillColor( 1,1,0 )
        end
    end
 
    menuButton = display.newImageRect(sceneGroup, "back-button.png", 40, 40)
    menuButton.x = 30
    menuButton.y = 30
    menuButton:addEventListener( "tap", menu )

end

function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		--audio.play( soundHighscore, { channel=3, loops=-1 } )
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
		--audio.stop( 3 )
	end
end

-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    Runtime:removeEventListener("tap", menuButton)

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
