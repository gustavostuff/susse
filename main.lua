-- Todos:

-- Auto anti-aliasing, mix 2 colors and get the most similar color from the palette
-- stroke-replicator copy a stroke in all the frame, with or w/o offset
-- stroke-eraser erase a stroke in all the frame, with or w/o offset
-- add support for layers
-- add support for onion skin (maybe)
-- add support for animation preview (play button)
-- beizer curves over a timeline to determine the speed of the animation (per frame)
-- add support for animation export (gif, png, etc)
-- add urutora UI
-- create a file format to save the animation data
-- add support for ultra wide screens
-- support to paste images from a file or clipboard
-- compare to Gimp (like starting a line from the last click)

local katsudo = require 'lib.katsudo.katsudo'
local urutora = require 'lib.urutora'
u = urutora:new()
u.katsudo = katsudo

local globals = require 'globals'
local keys = require 'keys'
local utils = require 'utils'
local colors = require 'colors'
local textures = require 'textures'
local spriteSheetManager = require 'sprite-sheet-manager'
local viewportManager = require 'viewport-manager'

local function initWorkspaceData()
  animation = {
    frameCount = 8,
    frameWidth = 24,
    frameHeight = 24,
  }

  spriteSheetWidth, spriteSheetHeight = utils:calculateSpriteSheetSize(
    animation.frameCount,
    animation.frameWidth,
    animation.frameHeight
  )

  spriteSheetManager:init({
    animation = animation,
    spriteSheetWidth = spriteSheetWidth,
    spriteSheetHeight = spriteSheetHeight,
  })
end

local function initCanvases()
  appCanvas = love.graphics.newCanvas(globals.appWidth, globals.appHeight)
  appCanvas:setFilter('nearest', 'nearest')
  appCanvasScale = love.graphics.getWidth() / globals.appWidth

  offScreenArea = {
    canvas = love.graphics.newCanvas(spriteSheetWidth, spriteSheetHeight)
  }
  offScreenArea.x = 10
  offScreenArea.y = 50
  offScreenArea.canvas:setWrap('clampzero', 'clampzero')

  activeArea = {
    canvas = love.graphics.newCanvas(animation.frameWidth, animation.frameHeight)
  }
  activeArea.x = 150
  activeArea.y = 40
  activeArea.canvas:setFilter('nearest', 'nearest')

  spriteSheetManager.activeArea = activeArea
end

local function initTextures()
  textures.offScreenQuad = love.graphics.newQuad(0, 0,
    offScreenArea.canvas:getWidth(),
    offScreenArea.canvas:getHeight(),
    textures.chessPattern:getDimensions()
  )
end

local function initCursors()
  emptyCursor = love.mouse.newCursor("images/empty.png", 0, 0)
  -- love.mouse.setCursor(emptyCursor)
end

function love.load()
  love.graphics.setLineStyle('rough')
  love.graphics.setLineWidth(1)
  initWorkspaceData()
  initCanvases()
  initTextures()
  initCursors()
  viewportManager:init({
    activeArea = activeArea,
    offScreenArea = offScreenArea,
    currentFrameQuad = currentFrameQuad,
    animation = animation
  })
end

function love.update(dt)
  viewportManager:update(dt)
end

-- local function drawCursor()
-- 	local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
-- 	love.graphics.setColor(colors.flameOrange)
-- 	love.graphics.rectangle('line',
-- 		x - viewportManager.zoom,
-- 		y - viewportManager.zoom,
-- 		viewportManager.zoom + 1,
-- 		viewportManager.zoom + 1
-- 	)
-- end

local function drawAppCanvas()
  love.graphics.setColor(colors.white)
  viewportManager:draw()
  love.graphics.draw(offScreenArea.canvas, offScreenArea.x, offScreenArea.y)

  -- drawCursor()
end

local function drawCanvasesBgs()
  love.graphics.clear(colors.transparent)
  love.graphics.setColor(colors.white)

  love.graphics.setScissor(
    activeArea.x,
    activeArea.y,
    activeArea.canvas:getWidth() * viewportManager.zoom,
    activeArea.canvas:getHeight() * viewportManager.zoom
  )
  love.graphics.draw(textures.chessPattern, viewportManager.activeQuad, 0, 0)
  love.graphics.setScissor()
end

local function drawActiveArea()
  
end

local function drawDebugInfo()
  local x, y, w, h = viewportManager.currentFrameQuad:getViewport()
  local items = {
    'FPS: ' .. love.timer.getFPS(),
    'frame W: ' .. animation.frameWidth,
    'frame H: ' .. animation.frameHeight,
    '# of frames: ' .. animation.frameCount,
    'columns: ' .. (offScreenArea.canvas:getWidth() / animation.frameWidth),
    'rows: ' .. (offScreenArea.canvas:getHeight() / animation.frameHeight),
    'sprite sheet W: ' .. offScreenArea.canvas:getWidth(),
    'sprite sheet H: ' .. offScreenArea.canvas:getHeight(),
    'current frame: ' .. spriteSheetManager.currentFrameIndex,
    'quad viewport: ' .. x .. ', ' .. y .. ', ' .. w .. ', ' .. h,
    'zoom level: ' .. viewportManager.zoom
  }
  for i, item in ipairs(items) do
    love.graphics.print(item, 10, 10 + i * 20)
  end
end

function love.draw()
  love.graphics.setColor(colors.white)
  love.graphics.setCanvas(appCanvas)

  drawCanvasesBgs()
  drawAppCanvas()
  drawActiveArea()

  -- debug
  love.graphics.setColor(colors.froly)
  local x, y, w, h = viewportManager.currentFrameQuad:getViewport()
  love.graphics.rectangle('line', offScreenArea.x + x, offScreenArea.y + y, w + 1, h + 1)
  
  love.graphics.setCanvas()
  love.graphics.setColor(colors.white)
  love.graphics.draw(appCanvas, 0, 0, 0, appCanvasScale, appCanvasScale)
  drawDebugInfo()
  love.graphics.setColor(colors.white)
end

function love.keypressed(key, scancode, isrepeat)
  if keys.isAnyOf(key, {keys.left, keys.right}) then
    spriteSheetManager:changeActiveFrame(key == keys.right and 'next' or 'previous')
    local newFrameQuad = spriteSheetManager:getQuadForCurrentFrameIndex()
    viewportManager:refreshQuads(newFrameQuad:getViewport())
  end

  -- debug stuff
  if key == keys.escape then
    love.event.quit()
  end

  -- if key == keys.e then
  -- 	local imageData = offScreenArea.canvas:newImageData()
  -- 	imageData:encode('png', 'test_sprite_sheet.png')
  -- end

  if key == keys.c then
    offScreenArea.canvas:renderTo(function()
      love.graphics.clear(colors.transparent)
    end)
  end
end

local function paint(strokeType, dx, dy)
  if strokeType == 'press' then
    offScreenArea.canvas:renderTo(function()
      spriteSheetManager:renderMousePressedStroke(
        viewportManager.zoom,
        {viewportManager.currentFrameQuad:getViewport()}
      )
    end)
  elseif strokeType == 'move' then
    offScreenArea.canvas:renderTo(function()
      spriteSheetManager:renderMouseMovedStroke(
        viewportManager.zoom,
        {viewportManager.currentFrameQuad:getViewport()},
        dx,
        dy
      )
    end)
  end
end

function love.mousepressed(x, y, button, istouch, presses)
  if button == 1 then -- left click
    paint('press')
  elseif button == 2 then -- right click
    local x, y = utils:getScaledMouse(globals.appWidth, globals.appHeight)
    viewportManager.dragging = true
    viewportManager.draggingStartX = x
    viewportManager.draggingStartY = y
  end
end

function love.mousemoved(x, y, dx, dy, istouch)
  if love.mouse.isDown(1) then
    dx, dy = utils:getScaledDxDy(dx, dy)
    paint('move', dx, dy)
  end
end

function love.mousereleased(x, y, button, istouch, presses)
  if button == 2 then -- right click
    viewportManager.dragging = false
  elseif button == 1 then -- left click
    spriteSheetManager:clearPencilStrokePoints()
  end
end

function love.wheelmoved(x, y)
  viewportManager:wheelMoved(y)
  -- viewportManager:refreshQuads(spriteSheetManager:getQuadPosition())
end