local textures = {}

textures.chessPattern = love.graphics.newImage("images/chess-pattern.png")
textures.diamondPattern = love.graphics.newImage("images/diamond-pattern.png")
textures.chessPattern:setWrap("repeat", "repeat")

return textures
