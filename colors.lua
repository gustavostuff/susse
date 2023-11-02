-- color palette from https://lospec.com/palette-list/dawnbringer-32

local colors = {
  amaranthPink = {love.math.colorFromBytes(215, 123, 186)}, -- #D77BBB
  antiqueRuby = {love.math.colorFromBytes(102, 57, 49)}, -- #663931
  battleshipGray = {love.math.colorFromBytes(155, 173, 183)}, -- #9BADB7
  black = {love.math.colorFromBytes(0, 0, 0)}, -- #000000
  blizzardBlue = {love.math.colorFromBytes(95, 205, 228)}, -- #5FCCE4
  burlywood = {love.math.colorFromBytes(217, 160, 102)}, -- #D9A066
  charcoal = {love.math.colorFromBytes(50, 60, 57)}, -- #323C39
  copper = {love.math.colorFromBytes(143, 86, 59)}, -- #8F563B
  cornflowerBlue = {love.math.colorFromBytes(91, 110, 225)}, -- #5B6EE1
  darkOliveGreen = {love.math.colorFromBytes(82, 75, 36)}, -- #524B24
  davysGray = {love.math.colorFromBytes(105, 106, 106)}, -- #696A6A
  fernGreen = {love.math.colorFromBytes(106, 190, 48)}, -- #6ABE30
  flameOrange = {love.math.colorFromBytes(223, 113, 38)}, -- #DF7126
  froly = {love.math.colorFromBytes(217, 87, 99)}, -- #D95763
  goldenrod = {love.math.colorFromBytes(138, 111, 48)}, -- #8A6F30
  inchwormGreen = {love.math.colorFromBytes(153, 229, 80)}, -- #99E550
  lightCornflowerBlue = {love.math.colorFromBytes(99, 155, 255)}, -- #639BFF
  mindaro = {love.math.colorFromBytes(251, 242, 54)}, -- #FBF236
  mulberry = {love.math.colorFromBytes(69, 40, 60)}, -- #45283C
  oceanGreen = {love.math.colorFromBytes(55, 148, 110)}, -- #37946E
  oliveDrab = {love.math.colorFromBytes(75, 105, 47)}, -- #4B692F
  oliveDrabGreen = {love.math.colorFromBytes(143, 151, 74)}, -- #8F974A
  peachPuff = {love.math.colorFromBytes(238, 195, 154)}, -- #EEC39A
  pebbleGray = {love.math.colorFromBytes(89, 86, 82)}, -- #595652
  periwinkle = {love.math.colorFromBytes(203, 219, 252)}, -- #CBDBFC
  purpleHeart = {love.math.colorFromBytes(63, 63, 116)}, -- #3F3F74
  raisinBlack = {love.math.colorFromBytes(34, 32, 52)}, -- #222034
  steelBlue = {love.math.colorFromBytes(48, 96, 130)}, -- #306082
  studio = {love.math.colorFromBytes(118, 66, 138)}, -- #763E8A
  taupeGray = {love.math.colorFromBytes(132, 126, 135)}, -- #847E87
  thunderbird = {love.math.colorFromBytes(172, 50, 50)}, -- #AC3232
  white = {love.math.colorFromBytes(255, 255, 255)}, -- #FFFFFF
  transparent = {love.math.colorFromBytes(0, 0, 0, 0)}, -- extra
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
