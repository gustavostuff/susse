local colors = require 'colors'
local textures = require 'textures'
local globals = require 'globals'
local utils = require 'utils'
local viewportManager = {
  minZoom = 2,
  maxZoom = 16,
  draggingStartX = 0,
  draggingStartY = 0
}

function viewportManager:init(data)
  data = data or {}
  self.zoom = self.minZoom

  self.activeArea = data.activeArea
  self.offScreenArea = data.offScreenArea
  self.currentFrameQuad = data.currentFrameQuad
  self.animation = data.animation
  self.activeQuad = love.graphics.newQuad(0, 0,
		globals.appWidth,
    globals.appHeight,
		textures.bgTexture:getDimensions()
	)
  self:refreshQuads(0, 0)
end

function viewportManager:update(dt)
  if self.dragging then
    local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
    local dx = x - self.draggingStartX
    local dy = y - self.draggingStartY
    self.activeArea.x = math.floor(self.activeArea.x + dx)
    self.activeArea.y = math.floor(self.activeArea.y + dy)

    -- Save the current mouse position for the next frame
    self.draggingStartX = x
    self.draggingStartY = y
  end
end

function viewportManager:refreshQuads(x, y)
  self.currentFrameQuad = love.graphics.newQuad(x, y,
		self.animation.frameWidth,
		self.animation.frameHeight,
		self.offScreenArea.canvas:getDimensions()
	)
end

function viewportManager:renderActiveArea()
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

function viewportManager:renderGrid(canvas)
  local aa = self.activeArea
  local anim = self.animation

  canvas:renderTo(function()
    love.graphics.clear()
    love.graphics.setColor(colors.periwinkle)
    love.graphics.line(
      aa.x,
      aa.y - 1,
      aa.x,
      aa.y + anim.frameHeight * self.zoom
    )
    for x = 1, anim.frameWidth do
      love.graphics.line(
        aa.x + x * self.zoom,
        aa.y,
        aa.x + x * self.zoom,
        aa.y + anim.frameHeight * self.zoom
      )
    end
    love.graphics.line(
      aa.x - 1,
      aa.y,
      aa.x + anim.frameWidth * self.zoom,
      aa.y
    )
    for y = 1, anim.frameHeight do
      love.graphics.line(
        aa.x,
        aa.y + y * self.zoom,
        aa.x + anim.frameWidth * self.zoom,
        aa.y + y * self.zoom
      )
    end
  end)

  love.graphics.setColor(colors.white)
  love.graphics.draw(canvas, 0, 0)
end

function viewportManager:wheelMoved(wheelY)
  if y ~= 0 then
    local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)

    local offsetX = (x - self.activeArea.x) / self.zoom
    local offsetY = (y - self.activeArea.y) / self.zoom

    local scale = (wheelY > 0) and (self.zoom + 1) or (self.zoom - 1)
    self.zoom = ((scale > self.maxZoom) and self.maxZoom) or
      (scale < self.minZoom and self.minZoom) or scale

    self.activeArea.x = math.floor(x - offsetX * self.zoom)
    self.activeArea.y = math.floor(y - offsetY * self.zoom)
  end
end

return viewportManager
