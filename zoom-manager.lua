local colors = require 'colors'
local textures = require 'textures'
local zoomManager = {
  minZoom = 1,
  maxZoom = 10,
  zoom = 1
}

function zoomManager:init(data)
  data = data or {}
  self.zoom = 4

  self.activeArea = data.activeArea
  self.offScreenArea = data.offScreenArea
  self.currentFrameQuad = data.currentFrameQuad
  self.animation = data.animation
  self:refreshQuads(0, 0)
end

function zoomManager:refreshQuads(x, y)
  self.currentFrameQuad = love.graphics.newQuad(x, y,
		self.animation.frameWidth,
		self.animation.frameHeight,
		self.offScreenArea.canvas:getDimensions()
	)

  self.activeQuad = love.graphics.newQuad(0, 0,
		self.activeArea.canvas:getWidth() * self.zoom,
		self.activeArea.canvas:getHeight() * self.zoom,
		textures.chessPattern:getDimensions()
	)
end

function zoomManager:draw()
  self.activeArea.canvas:renderTo(function()
		love.graphics.clear(colors.transparent)
		love.graphics.setColor(colors.white)
		love.graphics.draw(self.offScreenArea.canvas, self.currentFrameQuad, 0, 0)
	end)

  love.graphics.draw(activeArea.canvas, activeArea.x, activeArea.y, 0, self.zoom, self.zoom)
end

function zoomManager:wheelMoved(y)
  if y > 0 then
    self.zoom = self.zoom < self.maxZoom and (self.zoom + 1) or self.maxZoom
  elseif y < 0 then
    self.zoom = self.zoom > self.minZoom and (self.zoom - 1) or self.minZoom
  end
end

return zoomManager
