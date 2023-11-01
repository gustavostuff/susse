local globals = require 'globals'
local keys = require 'keys'
local utils = require 'utils'
local colors = require 'colors'
local textures = require 'textures'
local spriteSheetManager = require 'sprite-sheet-manager'
local zoomManager = require 'zoom-manager'

local function initWorkspaceData()
	animation = {
		frameCount = 9,
		frameWidth = 12,
		frameHeight = 16,
	}

	spriteSheetWidth, spriteSheetHeight = utils:calculateSpriteSheetSize(
		animation.frameCount,
		animation.frameWidth,
		animation.frameHeight
	)

	spriteSheetManager:init({
		animation = animation,
		spriteSheetWidth = spriteSheetWidth,
		spriteSheetHeight = spriteSheetHeight,
	})
end

local function initCanvases()
	appCanvas = love.graphics.newCanvas(globals.appWidth, globals.appHeight)
	appCanvas:setFilter('nearest', 'nearest')
	appCanvasScale = love.graphics.getWidth() / globals.appWidth

	offScreenArea = {
		canvas = love.graphics.newCanvas(spriteSheetWidth, spriteSheetHeight)
	}
	offScreenArea.x = 10
	offScreenArea.y = 50
	offScreenArea.canvas:setWrap('clampzero', 'clampzero')

	activeArea = {
		canvas = love.graphics.newCanvas(animation.frameWidth, animation.frameHeight)
	}
	activeArea.x = 150
	activeArea.y = 40
	activeArea.canvas:setFilter('nearest', 'nearest')
end

local function initTextures()
	textures.offScreenQuad = love.graphics.newQuad(0, 0,
		offScreenArea.canvas:getWidth(),
		offScreenArea.canvas:getHeight(),
		textures.chessPattern:getDimensions()
	)
end

local function initCursors()
	emptyCursor = love.mouse.newCursor("images/empty.png", 0, 0)
	-- love.mouse.setCursor(emptyCursor)
end

function love.load()
	love.graphics.setLineStyle('rough')
	love.graphics.setLineWidth(1)
	initWorkspaceData()
	initCanvases()
	initTextures()
	initCursors()
	zoomManager:init({
		activeArea = activeArea,
		offScreenArea = offScreenArea,
		currentFrameQuad = currentFrameQuad,
		animation = animation
	})
end

function love.update(dt)

end

-- local function drawCursor()
-- 	local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
-- 	love.graphics.setColor(colors.flameOrange)
-- 	love.graphics.rectangle('line',
-- 		x - zoomManager.zoom,
-- 		y - zoomManager.zoom,
-- 		zoomManager.zoom + 1,
-- 		zoomManager.zoom + 1
-- 	)
-- end

local function drawAppCanvas()
	love.graphics.setColor(colors.white)
	love.graphics.draw(offScreenArea.canvas, offScreenArea.x, offScreenArea.y)
	zoomManager:draw()

	-- drawCursor()
end

local function drawCanvasesBgs()
	love.graphics.clear(colors.transparent)
	love.graphics.setColor(colors.white)

	love.graphics.setScissor(
		activeArea.x,
		activeArea.y,
		activeArea.canvas:getWidth() * zoomManager.zoom,
		activeArea.canvas:getHeight() * zoomManager.zoom
	)
	love.graphics.draw(textures.chessPattern, zoomManager.activeQuad, 0, 0)
	love.graphics.setScissor()
end

local function drawActiveArea()
	offScreenArea.canvas:renderTo(function()
		if love.mouse.isDown(1) then
			spriteSheetManager:renderToOffscreenCanvas(
				activeArea.x,
				activeArea.y,
				zoomManager.zoom,
				{zoomManager.currentFrameQuad:getViewport()}
			)
		end
	end)
end

local function drawDebugInfo()
	local x, y, w, h = zoomManager.currentFrameQuad:getViewport()
	local items = {
		'FPS: ' .. love.timer.getFPS(),
		'frame W: ' .. animation.frameWidth,
		'frame H: ' .. animation.frameHeight,
		'# of frames: ' .. animation.frameCount,
		'columns: ' .. (offScreenArea.canvas:getWidth() / animation.frameWidth),
		'rows: ' .. (offScreenArea.canvas:getHeight() / animation.frameHeight),
		'sprite sheet W: ' .. offScreenArea.canvas:getWidth(),
		'sprite sheet H: ' .. offScreenArea.canvas:getHeight(),
		'current frame: ' .. spriteSheetManager.currentFrameIndex,
		'quad viewport: ' .. x .. ', ' .. y .. ', ' .. w .. ', ' .. h,
		'zoom level: ' .. zoomManager.zoom
	}
	for i, item in ipairs(items) do
		love.graphics.print(item, 10, 10 + i * 20)
	end
end

function love.draw()
	love.graphics.setColor(colors.white)
	love.graphics.setCanvas(appCanvas)

	drawCanvasesBgs()
	drawActiveArea()
	drawAppCanvas()

	-- debug
	love.graphics.setColor(colors.froly)
	local x, y, w, h = zoomManager.currentFrameQuad:getViewport()
	love.graphics.rectangle('line', offScreenArea.x + x, offScreenArea.y + y, w + 1, h + 1)
	
	love.graphics.setCanvas()
	love.graphics.setColor(colors.white)
	love.graphics.draw(appCanvas, 0, 0, 0, appCanvasScale, appCanvasScale)
	drawDebugInfo()
	love.graphics.setColor(colors.white)
end

function love.keypressed(key, scancode, isrepeat)
	if keys.isAnyOf(key, {keys.left, keys.right}) then
		spriteSheetManager:changeActiveFrame(key == keys.right and 'next' or 'previous')
		local newFrameQuad = spriteSheetManager:getQuadForCurrentFrameIndex()
		zoomManager:refreshQuads(newFrameQuad:getViewport())
	end

	-- debug stuff
	if key == keys.escape then
		love.event.quit()
	end

	if key == keys.e then
		local imageData = offScreenArea.canvas:newImageData()
		imageData:encode('png', 'test_sprite_sheet.png')
	end

	if key == keys.c then
		activeArea.canvas:renderTo(function()
			love.graphics.clear(colors.transparent)
		end)
		offScreenArea.canvas:renderTo(function()
			love.graphics.clear(colors.transparent)
		end)
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	if button == 1 then
		color = {
			love.math.random(),
			love.math.random(),
			love.math.random(),
		}
	end
end

function love.wheelmoved(x, y)
	zoomManager:wheelMoved(y)
	-- zoomManager:refreshQuads(spriteSheetManager:getQuadPosition())
end