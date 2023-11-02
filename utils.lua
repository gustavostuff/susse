local globals = require 'globals'

local utils = {}

function utils:getScaledMouse(canvasW, canvasH)
  local x, y = love.mouse.getPosition()
  local scale = canvasH / love.graphics.getHeight()
  return math.floor(x * scale), math.floor(y * scale)
end

function utils:getScaledDxDy(dx, dy)
  local scale = globals.appHeight / love.graphics.getHeight()
  return math.floor(dx * scale), math.floor(dy * scale)
end

function utils:calculateSpriteSheetSize(numFrames, frameWidth, frameHeight)
  local totalArea = numFrames * frameWidth * frameHeight
  local squareSide = math.ceil(math.sqrt(totalArea))
  local spriteSheetWidth = squareSide + (frameWidth - squareSide % frameWidth) % frameWidth
  local spriteSheetHeight = math.ceil(totalArea / spriteSheetWidth)
  
  spriteSheetHeight = spriteSheetHeight + (frameHeight - spriteSheetHeight % frameHeight) % frameHeight

  return spriteSheetWidth, spriteSheetHeight
end

return utils
