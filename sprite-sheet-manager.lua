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

function spriteSheetManager:getStrokeColor()
  if keys.shiftDown() then
    return colors.transparent
  else
    -- return colors:getRandomColor()
    return colors.black
  end
end

--------------------
local spray = true
--------------------

function spriteSheetManager:renderSprayStroke(zoom, quad)
  local strokeX, strokeY = self:getStrokeCoords(zoom)

	local blendModeBkp = love.graphics.getBlendMode()
	love.graphics.setBlendMode('replace')
	love.graphics.setColor(self:getStrokeColor())

	love.graphics.setScissor(unpack(quad))
  local x = math.floor(strokeX + quad[1])
  local y = math.floor(strokeY + quad[2])

  for i = 1, 12 do
    local angle = love.math.random() * 2 * math.pi
    local radius = love.math.random() * 7
    local dx = math.floor(radius * math.cos(angle))
    local dy = math.floor(radius * math.sin(angle))

    love.graphics.rectangle('fill', x + dx, y + dy, 1, 1)
  end

	love.graphics.setScissor()
	love.graphics.setBlendMode(blendModeBkp)
end

function spriteSheetManager:renderMousePressedStroke(zoom, quad)
	local strokeX, strokeY = self:getStrokeCoords(zoom)

	local blendModeBkp = love.graphics.getBlendMode()
	love.graphics.setBlendMode('replace')
	love.graphics.setColor(self:getStrokeColor())

	love.graphics.setScissor(unpack(quad))
  local x = math.floor(strokeX + quad[1])
  local y = math.floor(strokeY + quad[2])
	love.graphics.rectangle('fill', x, y, 1, 1)

	love.graphics.setScissor()
	love.graphics.setBlendMode(blendModeBkp)
  self.lastPressedX = x
  self.lastPressedY = y
end

function spriteSheetManager:renderMouseMovedStroke(zoom, quad, dx, dy)
  local strokeX, strokeY = self:getStrokeCoords(zoom)

  local blendModeBkp = love.graphics.getBlendMode()
  love.graphics.setBlendMode('replace')
  love.graphics.setColor(self:getStrokeColor())

  love.graphics.setScissor(unpack(quad))

  local x = strokeX + quad[1]
  local y = strokeY + quad[2]
  -- if #self.pencilStrokePoints > 0 then
  --   local prevStroke = self.pencilStrokePoints[#self.pencilStrokePoints]
  --   local prevX = prevStroke.x
  --   local prevY = prevStroke.y
  --   -- print('stroke:', prevX, prevY, x, y)
  --   love.graphics.line(prevX + 1, prevY + 1, x + 1, y + 1)
  --   if prevX == x and prevY == y then
  --     -- love.graphics.setColor(0, 0, 0, 0.5)
  --     -- love.graphics.rectangle('fill', x, y, 1, 1)
  --   end
  -- else
  --   love.graphics.rectangle('fill', x, y, 1, 1)
  -- end
  -- table.insert(self.pencilStrokePoints, {x = x, y = y})

  if self.lastPressedX and self.lastPressedY then
    love.graphics.line(self.lastPressedX + 1, self.lastPressedY + 1, x + 1, y + 1)
    self.lastPressedX = x
    self.lastPressedY = y
  end

  love.graphics.setScissor()

  love.graphics.setBlendMode(blendModeBkp)
end

function spriteSheetManager:clearPencilStrokePoints()
  self.pencilStrokePoints = {}
end

return spriteSheetManager
