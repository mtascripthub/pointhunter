local sx, sy = guiGetScreenSize()
local pointSize = 20

local cursorx, cursory = 0, 0
-- Point class
local points = {}
Point = {}
Point.__index = Point

function Point:create(x, y)
	local p = {}
	setmetatable(p, Point)
	p.id = #points + 1
	p.x, p.y = (x or 0), (y or 0)
	p.visible = false
	table.insert(points, p)
	return p
end

function Point:setPosition(x, y)
	self.x = x
	self.y = y
	self.visible = true
end


-- Game
local startTick
local score = 0
local timeLoad = 0

addEventHandler('onClientResourceStart', resourceRoot, function()
	addEventHandler('onClientRender', root, renderGame)
	showChat(false)
	showCursor(true)
	startTick = getTickCount()
	Point:create(100, 100)
	setTimer(setRandomPositions, 3000, 0)
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
	removeEventHandler('onClientRender', root, renderGame)
	showChat(true)
	showCursor(false)
end)

function setRandomPositions()
	for _, v in pairs(points) do
		v:setPosition(math.random(sx-pointSize), math.random(sy-pointSize))
	end
end

function playedTicks()
	return getTickCount() - startTick
end


function renderGame()
	cursorx, cursory = getCursorPosition()
	cursorx, cursory = cursorx*sx, cursory*sy
	
	timeLoad = playedTicks() % 3000
	
	dxDrawRectangle(0, 0, sx, sy, tocolor(0,0,0,255))
	if (playedTicks() < 3000) then return drawLoading() end
	
	dxDrawText('Score: ' .. tostring(score), 30, 30, 30, 30, tocolor(80,80,80,255), 1, 'default-bold')
	dxDrawRectangle(30, 50, 200, 20, tocolor(80,80,80,140))
	dxDrawRectangle(30, 50, timeLoad / 3000 * 200, 20, tocolor(80,80,80,230))
	for _, v in pairs(points) do
		if (v.visible) then 
			dxDrawRectangle(v.x, v.y, pointSize, pointSize, (mouseOnBox(v.x, v.y, pointSize, pointSize) and tocolor(255,255,0,255) or tocolor(255,255,255,255)))
		end
	end
end

function drawLoading()
	dxDrawText('pointhunter\nPublished on scripthub', sx/2, sy/2, sx/2, sy/2, tocolor(255,255,255,255), 3, 'sans', 'center', 'center')
end

function mouseOnBox(x, y, width, height)
	return (cursorx >= x and cursorx <= x + width) and (cursory >= y and cursory <= y + height)
end

function checkScore()
	if (#points < math.floor(score / 10) + 1) then
		Point:create(100, 100)
		playSound('levelup.mp3')
	end
end

addEventHandler('onClientClick', root, function(button, state, cursorx, cursory)
	if (button == 'left' and state == 'down') then
		for _, v in pairs(points) do
			if (v.visible and mouseOnBox(v.x, v.y, pointSize, pointSize)) then
				playSound('ding.mp3')
				score = score + 1
				checkScore()
				v.visible = false
			end
		end
	end
end)
