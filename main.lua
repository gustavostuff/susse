local globals = require("globals")
local keys = require("keys")
local utils = require("utils")
local colors = require("colors")
local textures = require("textures")

rad = 5

local function initCanvases()
	appCanvas = love.graphics.newCanvas(globals.appWidth, globals.appHeight)
	appCanvas:setFilter('nearest', 'nearest')
	appCanvasScale = love.graphics.getWidth() / globals.appWidth

	offScreenArea = {
		canvas = love.graphics.newCanvas(64, 64)
	}
	offScreenArea.x = 30
	offScreenArea.y = 20

	activeArea = {
		canvas = love.graphics.newCanvas(16, 16)
	}
	activeArea.x = 200
	activeArea.y = 20
end

local function initTextures()
	textures.offScreenQuad = love.graphics.newQuad(0, 0,
		offScreenArea.canvas:getWidth(),
		offScreenArea.canvas:getHeight(),
		textures.chessPattern:getDimensions()
	)

	textures.activeQuad = love.graphics.newQuad(0, 0,
		activeArea.canvas:getWidth(),
		activeArea.canvas:getHeight(),
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

	local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
	love.graphics.setColor(colors.flameOrange)
	love.graphics.circle('fill', x, y, rad)

	love.graphics.setCanvas()
	love.graphics.setColor(colors.white)
	love.graphics.draw(appCanvas, 0, 0, 0, appCanvasScale, appCanvasScale)

	love.graphics.setColor(colors.white)
end

local function drawOffScreenArea()
	love.graphics.setColor(colors.white)
	love.graphics.setCanvas(appCanvas)
	love.graphics.clear(colors.transparent)
	love.graphics.setColor(colors.white)

	love.graphics.draw(textures.chessPattern, textures.offScreenQuad, offScreenArea.x, offScreenArea.y)

	offScreenArea.canvas:renderTo(function()
		if love.mouse.isDown(1) then
			local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
			local blendModeBkp = love.graphics.getBlendMode()
			love.graphics.setBlendMode('replace')
			if keys.shiftDown() then
				love.graphics.setColor(colors.transparent)
			else
				love.graphics.setColor(color)
			end
			love.graphics.circle('fill', x - offScreenArea.x, y - offScreenArea.y, rad)
			love.graphics.setBlendMode(blendModeBkp)
		end
	end)
end

local function drawActiveArea()
	love.graphics.setColor(colors.white)
	love.graphics.setCanvas(appCanvas)
	love.graphics.clear(colors.transparent)
	love.graphics.setColor(colors.white)

	love.graphics.draw(textures.chessPattern, textures.activeQuad, activeArea.x, activeArea.y)

	activeArea.canvas:renderTo(function()
		if love.mouse.isDown(1) then
			local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
			local blendModeBkp = love.graphics.getBlendMode()
			love.graphics.setBlendMode('replace')
			if keys.shiftDown() then
				love.graphics.setColor(colors.transparent)
			else
				love.graphics.setColor(color)
			end
			love.graphics.circle('fill', x - activeArea.x, y - activeArea.y, rad)
			love.graphics.setBlendMode(blendModeBkp)
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
	drawOffScreenArea()
	drawActiveArea()
	drawAppCanvas()
	drawDebugInfo()
end

function love.keypressed(key, scancode, isrepeat)
	if key == keys.escape then
		love.event.quit()
	end

	if key == keys.c then
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