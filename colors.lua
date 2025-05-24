-- color palette from https://lospec.com/palette-list/dawnbringer-32

local colors = {
  white = {1, 1, 1},
  black = {0, 0, 0},
  gray = {0.5, 0.5, 0.5},
  transparent = {0, 0, 0, 0},
}

function colors:translucent(key, opacity)
  local c = self[key]
  return {c[1], c[2], c[3], opacity}
end

function colors:getRandomColor()
  return {
    love.math.random(),
    love.math.random(),
    love.math.random(),
  }
end

return colors
