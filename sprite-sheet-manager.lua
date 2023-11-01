local globals = require 'globals'
local utils = require 'utils'
local keys = require 'keys'
local colors = require 'colors'

local spriteSheetManager = {}

function spriteSheetManager:init(data)
  data = data or {}
  self.animation = data.animation
  self.spriteSheetWidth = data.spriteSheetWidth
  self.spriteSheetHeight = data.spriteSheetHeight
  self.currentFrameIndex = 1
end

function spriteSheetManager:changeActiveFrame(direction)
  if direction == 'next' then
    self.currentFrameIndex = self.currentFrameIndex + 1
    if self.currentFrameIndex > self.animation.frameCount then
      self.currentFrameIndex = 1
    end
  elseif direction == 'previous' then
    self.currentFrameIndex = self.currentFrameIndex - 1
    if self.currentFrameIndex < 1 then
      self.currentFrameIndex = self.animation.frameCount
    end
  end
end

function spriteSheetManager:getQuadPosition()
  local x, y = 0, 0
  for i = 2, self.currentFrameIndex do
    x = x + self.animation.frameWidth
    if x >= self.spriteSheetWidth then
      x = 0
      y = y + self.animation.frameHeight
    end
  end

  return x, y
end

function spriteSheetManager:getQuadForCurrentFrameIndex()
  local x, y = self:getQuadPosition()
  local w, h = self.animation.frameWidth, self.animation.frameHeight

  return love.graphics.newQuad(x, y, w, h, self.spriteSheetWidth, self.spriteSheetHeight)
end

function spriteSheetManager:renderToOffscreenCanvas(activeAreaX, activeAreaY, zoom, quad)
	local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
	local aaW = self.animation.frameWidth * zoom
	local aaH = self.animation.frameWidth * zoom

	local px = math.floor((x - activeAreaX) / zoom)
	local py = math.floor((y - activeAreaY) / zoom)
	
	local blendModeBkp = love.graphics.getBlendMode()
	love.graphics.setBlendMode('replace')
	if keys.shiftDown() then
		love.graphics.setColor(colors.transparent)
	else
		love.graphics.setColor(color)
	end

	love.graphics.setScissor(unpack(quad))
	love.graphics.circle('fill',
		math.floor(px + quad[1]),
		math.floor(py + quad[2]), 3
	)
	love.graphics.setScissor()

	love.graphics.setBlendMode(blendModeBkp)
end

return spriteSheetManager
