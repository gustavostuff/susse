local utils = {}

function utils:getScaledMouse(canvasW, canvasH)
  local x, y = love.mouse.getPosition()
  local scale = canvasW / love.graphics.getWidth()
  return math.floor(x * scale), math.floor(y * scale)
end

return utils
