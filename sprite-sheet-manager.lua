local globals = require 'globals'
local utils = require 'utils'
local keys = require 'keys'
local colors = require 'colors'

local spriteSheetManager = {
  pencilStrokePoints = {}
}

function spriteSheetManager:init(data)
  data = data or {}
  self.animation = data.animation
  self.spriteSheetWidth = data.spriteSheetWidth
  self.spriteSheetHeight = data.spriteSheetHeight
  self.activeArea = data.activeArea
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

function spriteSheetManager:getStrokeCoords(zoom)
  local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
	local strokeX = math.floor((x - self.activeArea.x) / zoom)
	local strokeY = math.floor((y - self.activeArea.y) / zoom)

  return strokeX, strokeY
end

function spriteSheetManager:renderMousePressedStroke(zoom, quad)
	local strokeX, strokeY = self:getStrokeCoords(zoom)

	local blendModeBkp = love.graphics.getBlendMode()
	love.graphics.setBlendMode('replace')
	if keys.shiftDown() then
		love.graphics.setColor(colors.transparent)
	else
		love.graphics.setColor(colors.blizzardBlue)
	end

	love.graphics.setScissor(unpack(quad))
  local x = math.floor(strokeX + quad[1])
  local y = math.floor(strokeY + quad[2])
	love.graphics.rectangle('fill', x, y, 1, 1)
	love.graphics.setScissor()

	love.graphics.setBlendMode(blendModeBkp)
end

function spriteSheetManager:renderMouseMovedStroke(zoom, quad, dx, dy)
  local strokeX, strokeY = self:getStrokeCoords(zoom)

  local blendModeBkp = love.graphics.getBlendMode()
  love.graphics.setBlendMode('replace')
  if keys.shiftDown() then
    love.graphics.setColor(colors.transparent)
  else
    love.graphics.setColor(colors.blizzardBlue)
  end

  love.graphics.setScissor(unpack(quad))

  local x = math.floor(strokeX + quad[1])
  local y = math.floor(strokeY + quad[2])
  if #self.pencilStrokePoints > 0 then
    local prevStroke = self.pencilStrokePoints[#self.pencilStrokePoints]
    local prevX = math.floor(prevStroke.x + quad[1])
    local prevY = math.floor(prevStroke.y + quad[2])
    love.graphics.line(prevX + 1, prevY + 1, x, y)
  else
    love.graphics.rectangle('fill', x, y, 1, 1)
  end
  table.insert(self.pencilStrokePoints, {x = x, y = y})

  love.graphics.setScissor()

  love.graphics.setBlendMode(blendModeBkp)
end

function spriteSheetManager:clearPencilStrokePoints()
  self.pencilStrokePoints = {}
end

return spriteSheetManager
