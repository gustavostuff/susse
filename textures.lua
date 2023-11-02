local textures = {}

textures.chessPattern = love.graphics.newImage("images/chess-pattern.png")
textures.diamondPattern = love.graphics.newImage("images/diamond-pattern.png")
textures.whiteBg = love.graphics.newImage("images/white-bg.png")

textures.chessPattern:setWrap("repeat", "repeat")
textures.diamondPattern:setWrap("repeat", "repeat")
textures.whiteBg:setWrap("repeat", "repeat")

return textures
