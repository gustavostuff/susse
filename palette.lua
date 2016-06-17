palette = {}

palette =
{
	number = 6,
	x = 106,
	y = 6,
	xColor = 106,
	yColor = 6
}

for i = 1, palette.number do
	palette["img"..i] = love.graphics.newImage("/images/palette"..i..".png")
end

palette.which = 1
palette.pressed = false

for i = 1, palette.number do
	palette["iD"..i] = love.image.newImageData("/images/palette"..i..".png")
	palette["img"..i]:setFilter("nearest", "nearest")
end

palette.img = function()
	return palette["img"..palette.which]
end

palette.iD = function()
	return palette["iD"..palette.which]
end

palette.scales = {[1] = 8, [2] = 8, [3] = 8, [4] = 32, [5] = 32, [6] = 8}

palette.scale = function()
	return palette.scales[palette.which]
end

palette.w = function()
	return palette.img():getWidth() * palette.scale()
end

palette.h = function()
	return palette.img():getHeight() * palette.scale()
end

palette.mouseInside = function()
	return not (
		love.mouse.getX() <= palette.x or
		love.mouse.getY() <= palette.y or
		love.mouse.getX() >= palette.x + palette.w() or
		love.mouse.getY() >= palette.y + palette.h()
	)
end

palette.getColor = function(theX, theY)
	local x, y = love.mouse.getX(), love.mouse.getY()
	if theX and theY then
		x, y = theX, theY
	end
	local rx = math.floor((x - palette.x) / palette.scale())
	local ry = math.floor((y - palette.y) / palette.scale())
	--print(rx, ry)
	local r, g, b, a = palette.iD():getPixel(rx, ry)
	local c = {r, g, b, a}
	--print(r, g, b, a)
	return c
end

palette.change = function()
	palette.which = palette.which + 1
	if palette.which > palette.number then
		palette.which = 1
	end
	palette.changeSquare(palette.xColor, palette.yColor)
end

palette.changeSquare = function(x, y)
	 palette.xColor = palette.x + math.floor((x - palette.x) / palette.scale()) * palette.scale()
	 palette.yColor = palette.y + math.floor((y - palette.y) / palette.scale()) * palette.scale()
end

palette.getSquare = function(x, y, scale)
	local x = palette.x + math.floor((x - palette.x) / scale) * scale
	local y = palette.y + math.floor((y - palette.y) / scale) * scale
	return x, y, scale, scale
end

palette.__index = palette