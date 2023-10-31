local globals = require("globals")
local keys = require("keys")
local utils = require("utils")
local colors = require("colors")
local textures = require("textures")

zoom = 4

local function initCanvases()
	appCanvas = love.graphics.newCanvas(globals.appWidth, globals.appHeight)
	appCanvas:setFilter('nearest', 'nearest')
	appCanvasScale = love.graphics.getWidth() / globals.appWidth

	offScreenArea = {
		canvas = love.graphics.newCanvas(64, 64)
	}
	offScreenArea.x = 100
	offScreenArea.y = 20

	activeArea = {
		canvas = love.graphics.newCanvas(16, 16)
	}
	activeArea.x = 200
	activeArea.y = 20
	activeArea.canvas:setFilter('nearest', 'nearest')
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
	initCanvases()
	initTextures()
	initCursors()
end

function love.update(dt)

end

local function drawAppCanvas()
	love.graphics.setColor(colors.white)
	love.graphics.draw(offScreenArea.canvas, offScreenArea.x, offScreenArea.y)
	love.graphics.draw(activeArea.canvas, activeArea.x, activeArea.y, 0, zoom, zoom)

	local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
	love.graphics.setColor(colors.flameOrange)
	love.graphics.points(x, y)
end

local function drawCanvasesBgs()
	love.graphics.clear(colors.transparent)
	love.graphics.setColor(colors.white)

	love.graphics.draw(textures.chessPattern, textures.activeQuad, activeArea.x, activeArea.y)
	love.graphics.draw(textures.chessPattern, textures.offScreenQuad, offScreenArea.x, offScreenArea.y)
end

local function activeToOffScreenRenderer(mode)
	local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
	local px, py = (x - activeArea.x) / zoom, (y - activeArea.y) / zoom
	
	local blendModeBkp = love.graphics.getBlendMode()
	love.graphics.setBlendMode('replace')
	if keys.shiftDown() then
		love.graphics.setColor(colors.transparent)
	else
		love.graphics.setColor(color)
	end
	love.graphics.points(px, py)
	love.graphics.setBlendMode(blendModeBkp)
end

local function drawActiveArea()
	activeArea.canvas:renderTo(function()
		if love.mouse.isDown(1) then
			activeToOffScreenRenderer('active')
		end
	end)
	offScreenArea.canvas:renderTo(function()
		if love.mouse.isDown(1) then
			activeToOffScreenRenderer('offscreen')
		end
	end)
end

local function drawDebugInfo()
	local items = {
		'FPS: ' .. love.timer.getFPS(),
		'off-screen area W: ' .. offScreenArea.canvas:getWidth(),
		'off-screen area H: ' .. offScreenArea.canvas:getHeight(),
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