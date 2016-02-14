require "pixel"

animManager = {}
animManager.__index = animManager
animManager.frames = {}
local anims = {}

function animManager.createFrames(n, w, h)
	local frames = {}
	for i = 1, n do
		table.insert(frames, animManager.newFrame(w, h))
	end
	return frames
end

function animManager.newFrame(w, h)
	local frame = {}
	for i = 1, h do
		frame[i] = {}
		for j = 1, w do
			frame[i][j] = pixel.new(0, 0, 0, 0, j, i)
		end
	end
	return frame
end

function animManager.saveTableRepresentation(frames, name)
	local tableRep = "frames =\n{\n"
	for i = 1, #frames do
		tableRep = tableRep.."	{\n"
		local f = frames[i]
		for y = 1, #f do

			tableRep = tableRep.."		{"
			local row = f[i] 
			
			for x = 1, #row do
				local p = row[i]
				-- r, g, b, a:
				tableRep = tableRep.."{"..p.r..","..p.g..","..p.b..","..p.a.."},"
			end

			tableRep = tableRep.."},\n"

		end
		tableRep = tableRep.."	},\n"
	end
	tableRep = tableRep.."}"
	success = love.filesystem.write(name..".anim", tableRep)
	if not success then
		error("Error in animManager.saveTableRepresentation(), couldn't save the file.")
	end
end

function animManager.openAnimation(name)
	if not string.find(name, ".png") then
		name = name..".png"
	end
	local info = love.filesystem.load(name.."_info.lua")()
	
	local frames = animManager.createFrames(info.frameNum, info.fW, info.fH)

	-- Load image:
	local imageData = love.image.newImageData(name)
	
	-- Dump each pixel of the loaded image:
	local indexF = 0
	for i = 0, info.matrixH - 1 do
		for j = 0, info.matrixW - 1 do
			indexF = indexF + 1
			if indexF > #frames then break end
			local f = frames[indexF]
			for y = 0, #f - 1 do
				for x = 0, #f[y + 1] - 1 do
					local p = f[y +1][x + 1]
					local r, g, b, a = imageData:getPixel(j * info.fW + x, i * info.fH + y)
					p:setColor({r, g, b, a})
				end
			end	
		end
	end
	local img = love.graphics.newImage(imageData)
	return frames, img, info
end

function animManager.saveAnimation(name, frames, w, h)
	local fW = #frames[1][1]
	local fH = #frames[1]
	local imageData = love.image.newImageData(w * fW, h * fH)
	local indexF = 0
	-- Dump each pixel of the frames table on the new ImageData:
	for i = 0, h - 1 do
		for j = 0, w - 1 do
			indexF = indexF + 1
			if indexF > #frames then break end
			local f = frames[indexF]
			for y = 0, #f - 1 do
				for x = 0, #f[y + 1] - 1 do
					local p = f[y + 1][x + 1]
					imageData:setPixel(j * fW + x, i * fH + y, p.r, p.g, p.b, p.a)
				end
			end	
		end
	end
	-- Save info file
	--print(imageData:getWidth(), imageData:getHeight())
	if not string.find(name, ".png") then
		name = name..".png"
	end
	imageData:encode("png", name)
	local info =
		"info =\n"..
		"{\n"..
		"	frameNum = "..#frames..",\n"..
		"	fW = "..fW..",\n"..
		"	fH = "..fH..",\n"..
		"	matrixW = "..w..",\n"..
		"	matrixH = "..h..",\n"..
		"}\n"..
		"return info"
	love.filesystem.write(name.."_info.lua", info)
	info = love.filesystem.load(name.."_info.lua")()
	return love.graphics.newImage(imageData), info
end

function animManager.loadAvailable()
	local files = love.filesystem.getDirectoryItems("")
	anims = {}
	local n = 2
	for i = 1, #files do
		if love.filesystem.exists(files[i].."_info.lua") then
			local b = false
			if n == 2 then b = true end
			local item =
			{
				x = 30,
				y = n * 40,
				name = files[i],
				selected = b,
				index = i
			}
			table.insert(anims, item)
			n = n + 1
		end
	end
	return anims
end

function animManager.deselectItems()
	for i = 1, #anims do
		anims[i].selected = false
	end
end

function animManager.getSelectedItem()
	for i = 1, #anims do
		if anims[i].selected then
			return anims[i]
		end
	end
end