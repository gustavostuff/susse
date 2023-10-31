local globals = require("globals")
local keys = require("keys")
local utils = require("utils")
local colors = require("colors")
local textures = require("textures")
local spriteSheetManager = require("sprite-sheet-manager")

zoom = 4

local function initWorkspaceData()
	animation = {
		frameCount = 3,
		frameWidth = 24,
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
	offScreenArea.x = 50
	offScreenArea.y = 50

	activeArea = {
		canvas = love.graphics.newCanvas(animation.frameWidth, animation.frameHeight)
	}
	activeArea.x = 150
	activeArea.y = 20
	activeArea.canvas:setFilter('nearest', 'nearest')

	currentFrameQuad = love.graphics.newQuad(0, 0,
		animation.frameWidth,
		animation.frameHeight,
		offScreenArea.canvas:getDimensions()
	)
end

local function initTextures()
	textures.offScreenQuad = love.graphics.newQuad(0, 0,
		offScreenArea.canvas:getWidth(),
		offScreenArea.canvas:getHeight(),
		textures.chessPattern:getDimensions()
	)

	textures.activeQuad = love.graphics.newQuad(0, 0,
		activeArea.canvas:getWidth() * zoom,
		activeArea.canvas:getHeight() * zoom,
		textures.chessPattern:getDimensions()
	)
end

local function initCursors()
	emptyCursor = love.mouse.newCursor("images/empty.png", 0, 0)
	love.mouse.setCursor(emptyCursor)
end

function love.load()
	love.graphics.setLineStyle('rough')
	love.graphics.setLineWidth(1)
	initWorkspaceData()
	initCanvases()
	initTextures()
	initCursors()
end

function love.update(dt)

end

local function drawCursor()
	local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
	love.graphics.setColor(colors.flameOrange)
	love.graphics.rectangle('line', x - zoom, y - zoom, zoom + 1, zoom + 1)
end

local function drawAppCanvas()
	love.graphics.setColor(colors.white)
	love.graphics.draw(offScreenArea.canvas, offScreenArea.x, offScreenArea.y)
	love.graphics.draw(activeArea.canvas, activeArea.x, activeArea.y, 0, zoom, zoom)

	drawCursor()
end

local function drawCanvasesBgs()
	love.graphics.clear(colors.transparent)
	love.graphics.setColor(colors.white)

	love.graphics.draw(textures.chessPattern, textures.activeQuad, activeArea.x, activeArea.y)
	love.graphics.draw(textures.chessPattern, textures.offScreenQuad, offScreenArea.x, offScreenArea.y)
end

local function getScissorRect()
	local x, y, w, h = currentFrameQuad:getViewport()
	return {x = x, y = y, w = w, h = h}
end

local function renderToOffscreenCanvas(originX, originY)
	local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
	local px = math.floor((x - originX) / zoom)
	local py = math.floor((y - originY) / zoom)
	
	local blendModeBkp = love.graphics.getBlendMode()
	love.graphics.setBlendMode('replace')
	if keys.shiftDown() then
		love.graphics.setColor(colors.transparent)
	else
		love.graphics.setColor(color)
	end

	local rect = getScissorRect()
	-- love.graphics.setScissor(rect.x, rect.y, rect.w, rect.h)
	-- love.graphics.circle('fill', math.floor(px), math.floor(py), 2)
	local x, y, _, _ = currentFrameQuad:getViewport()
	love.graphics.points(
		math.floor(px + x),
		math.floor(py + y)
	)
	-- love.graphics.setScissor()

	love.graphics.setBlendMode(blendModeBkp)
end

local function drawActiveArea()
	love.graphics.setColor(colors.froly)
	local x, y, w, h = currentFrameQuad:getViewport()
	love.graphics.rectangle('line', offScreenArea.x + x, offScreenArea.y + y, w + 1, h + 1)
	offScreenArea.canvas:renderTo(function()
		if love.mouse.isDown(1) then
			renderToOffscreenCanvas(
				activeArea.x,
				activeArea.y
			)
		end
	end)

	activeArea.canvas:renderTo(function()
		love.graphics.clear(colors.transparent)
		love.graphics.setColor(colors.white)
		love.graphics.draw(offScreenArea.canvas, currentFrameQuad, 0, 0)
	end)
end

local function drawDebugInfo()
	local x, y, w, h = currentFrameQuad:getViewport()
	local items = {
		'FPS: ' .. love.timer.getFPS(),
		'off-screen area W: ' .. offScreenArea.canvas:getWidth(),
		'off-screen area H: ' .. offScreenArea.canvas:getHeight(),
		'current frame: ' .. spriteSheetManager.currentFrameIndex,
		'quad viewport: ' .. x .. ', ' .. y .. ', ' .. w .. ', ' .. h,
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
		currentFrameQuad:setViewport(newFrameQuad:getViewport())
	end

	-- debug stuff
	if key == keys.escape then
		love.event.quit()
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