local colors = require 'colors'
local textures = require 'textures'
local globals = require 'globals'
local utils = require 'utils'
local zoomManager = {
  minZoom = 1,
  maxZoom = 10,
}

function zoomManager:init(data)
  data = data or {}
  self.zoom = 4

  self.activeArea = data.activeArea
  self.offScreenArea = data.offScreenArea
  self.currentFrameQuad = data.currentFrameQuad
  self.animation = data.animation
  self.activeQuad = love.graphics.newQuad(0, 0,
		globals.appWidth,
    globals.appHeight,
		textures.chessPattern:getDimensions()
	)
  self:refreshQuads(0, 0)
end

function zoomManager:refreshQuads(x, y)
  self.currentFrameQuad = love.graphics.newQuad(x, y,
		self.animation.frameWidth,
		self.animation.frameHeight,
		self.offScreenArea.canvas:getDimensions()
	)
end

function zoomManager:draw()
  self.activeArea.canvas:renderTo(function()
		love.graphics.clear(colors.transparent)
		love.graphics.setColor(colors.white)
		love.graphics.draw(self.offScreenArea.canvas, self.currentFrameQuad, 0, 0)
	end)

  love.graphics.draw(
    self.activeArea.canvas,
    self.activeArea.x,
    self.activeArea.y,
    0,
    self.zoom,
    self.zoom
  )
end

function zoomManager:wheelMoved(wheelY)
  -- if y > 0 then
  --   self.zoom = self.zoom < self.maxZoom and (self.zoom + 1) or self.maxZoom
  -- elseif y < 0 then
  --   self.zoom = self.zoom > self.minZoom and (self.zoom - 1) or self.minZoom
  -- end
  if y ~= 0 then
    local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)

    local offsetX = (x - self.activeArea.x) / self.zoom
    local offsetY = (y - self.activeArea.y) / self.zoom

    local scale = (wheelY > 0) and (self.zoom * 2) or (self.zoom / 2)
    self.zoom = ((scale > 8) and 8) or (scale < 1 and 1) or scale

    self.activeArea.x = math.floor(x - offsetX * self.zoom)
    self.activeArea.y = math.floor(y - offsetY * self.zoom)
  end
end

return zoomManager
