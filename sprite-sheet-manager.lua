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

function spriteSheetManager:getQuadForCurrentFrameIndex()
  local x, y, w, h = 0, 0, self.animation.frameWidth, self.animation.frameHeight
  for i = 2, self.currentFrameIndex do
    x = x + self.animation.frameWidth
    if x >= self.spriteSheetWidth then
      x = 0
      y = y + self.animation.frameHeight
    end
  end

  return love.graphics.newQuad(x, y, w, h, self.spriteSheetWidth, self.spriteSheetHeight)
end

return spriteSheetManager
