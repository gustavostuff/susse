pixel = {}
pixel.__index = pixel

function pixel.new(r, g, b, a, x, y)
	local p = {}
	p.x = x
	p.y = y
	p.r = r
	p.g = g
	p.b = b
	p.a = a or 255
	if not (r and g and b and a) then
		p.r, p.g, p.b, p.a = 255, 255, 127, 127
	end
	p.color = {p.r, p.g, p.b, p.a}
	return setmetatable(p, pixel)
end

function pixel:setColor(r, g, b, a)
	if type(r) == "table" then
		self.r = r[1]
		self.g = r[2]
		self.b = r[3]
		self.a = r[4] or 255
	else
		self.r, self.g, self.b, self.a = r, g, b, (a or 255)
	end
	self.color = {self.r, self.g, self.b, self.a}
end

function pixel:getColor()
	local color = {self.color[1], self.color[2], self.color[3], self.color[4] or 255}
	return color
end