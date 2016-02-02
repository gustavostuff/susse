palette =
{
	["img1"] = love.graphics.newImage("/images/palette1.png"),
	["img2"] = love.graphics.newImage("/images/palette2.png"),
	["img3"] = love.graphics.newImage("/images/palette3.png"),
	x = 135,
	y = 12,
	xColor = 135,
	yColor = 12
}

palette.which = 1
palette.pressed = false

palette["iD1"] = love.image.newImageData("/images/palette1.png")
palette["iD2"] = love.image.newImageData("/images/palette2.png")
palette["iD3"] = love.image.newImageData("/images/palette3.png")

palette.img = function()
	return palette["img"..palette.which]
end

palette.iD = function()
	return palette["iD"..palette.which]
end


palette.img1:setFilter("nearest", "nearest")
palette.img2:setFilter("nearest", "nearest")
palette.img3:setFilter("nearest", "nearest")

palette.scale = function()
	if palette.which == 1 then return 32 end
	if palette.which == 2 then return 8 end
	if palette.which == 3 then return 1 end
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
		love.mouse.getX() >= palette.x + palette.img():getWidth() * palette.scale() or
		love.mouse.getY() >= palette.y + palette.img():getHeight() * palette.scale()
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
	return c
end

palette.change = function()
	palette.which = palette.which + 1
	if palette.which > 3 then
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