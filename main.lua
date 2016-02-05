require "gooi"
require "AnAL"
require "palette"
require "animManager"
require "colorManager"

function width()
	return love.graphics.getWidth()
end
function height()
	return love.graphics.getHeight()
end

function love.load()
	print("Save directory: "..love.filesystem.getSaveDirectory())
	gr = love.graphics
	kb = love.keyboard
	mo = love.mouse
	fs = love.filesystem
	-----------------------------------------------
	STATE_EDITING = 1
	STATE_SAVING = 2
	STATE_NEW = 3
	STATE_OPENING = 4
	STATE_OPTIONS = 5
	state = STATE_EDITING
	-----------------------------------------------
	MOUSE_LEFT = 1
	MOUSE_RIGHT = 2
	MOUSE_MIDDLE = 3
	-----------------------------------------------
	win = {}
	win.smaller = function()
		if width() < height() then return width() end
		return height()
	end
	--gr.setPointStyle("rough")
	bgC1 = {31, 21, 10}
	bgC2 = {22, 48, 0}
	bgC3 = {18, 41, 54}
	gr.setBackgroundColor(bgC1)
	loadFrames()
	imagesDir = "/images/"
	bgImage1 = gr.newImage(imagesDir.."bgImage1.png")
	bgImage2 = gr.newImage(imagesDir.."bgImage2.png")
	bgImage3 = gr.newImage(imagesDir.."bgImage3.png")
	bgDude1 = gr.newImage(imagesDir.."bgDude1.png")
	bgDude2 = gr.newImage(imagesDir.."bgDude2.png")
	bgDude3 = gr.newImage(imagesDir.."bgDude3.png")
	imgAlpha = gr.newImage(imagesDir.."alpha.png")
	imgStop = gr.newImage(imagesDir.."square.png")
	imgSave = gr.newImage(imagesDir.."save.png")
	imgSaveAs = gr.newImage(imagesDir.."saveAs.png")
	imgFill = gr.newImage(imagesDir.."fill.png")
	imgFill4 = gr.newImage(imagesDir.."fill4.png")
	imgFill8 = gr.newImage(imagesDir.."fill8.png")
	imgLeft = gr.newImage(imagesDir.."left.png")
	imgRight = gr.newImage(imagesDir.."right.png")
	imgAAArrow = gr.newImage(imagesDir.."aAarrow.png")
	bgDude1:setFilter("nearest", "nearest")
	bgDude2:setFilter("nearest", "nearest")
	bgDude3:setFilter("nearest", "nearest")
	bgImage1:setWrap("repeat", "repeat")
	bgImage2:setWrap("repeat", "repeat")
	bgImage3:setWrap("repeat", "repeat")
	
	------------------------------------------------------------------------
	love.window.setIcon(love.image.newImageData(imagesDir.."icon.png"))
	------------------------------------------------------------------------
	setBoundsPixel()
	setBoundsCanvas()
	lineAnchor = nil
	-----------------------------------------------
	mirrorX = false
	mirrorY = false
	playing = false
	animSaved = false
	-----------------------------------------------
	fillMode = nil
	brush = {}
	brush.color = {255, 0, 255, 255}
	colorIndicator = {0, 0, 0, 255}
	currentFrameIndex = 1
	aaDirection = 1-- Right.
	aaRotation = 0
	--palette.change()

	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- gooi:
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	font = gr.newFont("HussarPrintA.otf", 16)
	gooi.font = font
	debugFont = gr.newFont(width() / 70)
	finalW, finalH = 0, 0
	-- Edit gooi:
	gooi.newButton("btnNew", "", 10, 10, 50, 30, imagesDir.."new.png", "editing"):setToolTip("New animation")
	gooi.newButton("btnOpen", "", 70, 10, 50, 30, imagesDir.."open.png", "editing"):setToolTip("Open animation")
	gooi.newButton("btnPlay", "", 10, 50, 110, 30, imgRight, "editing").bgColor = {0, 255, 0, 127}
	gooi.newButton("btnSave", "", 10, 90, 50, 30, imgSave, "editing"):setToolTip("Save the animation")
	gooi.newButton("btnSaveAs", "", 70, 90, 50, 30, imgSaveAs, "editing"):setToolTip("Save as...")
	gooi.newButton("btnPrev", "", 10, 130, 50, 30, imgLeft, "editing").bgColor = {255, 127, 0, 127}
	gooi.newButton("btnNext", "", 70, 130, 50, 30, imgRight, "editing").bgColor = {255, 127, 0, 127}
	gooi.newButton("btnDel", "", 10, 170, 50, 30, imagesDir.."del.png", "editing"):setToolTip("Delete current frame")
	gooi.newButton("btnAdd", "", 70, 170, 50, 30, imagesDir.."add.png", "editing"):setToolTip("Add a new frame")
	gooi.newCheckbox("chbLoop", "Loop", 10, 210, 110, 30, true, "editing").bgColor = {0, 255, 255, 127}
	gooi.newSpinner("spiSpeed", 10, 250, 110, 30, 0.1, 0.01, 1, 0.01, "editing"):setToolTip("Delay in ms, of the animation")

	gooi.newCheckbox("chbGrid", "Grid", 10, 300, 110, 30, false, "editing").bgColor = {255, 255, 0, 127}
	gooi.newButton("btnMX", "", 70, 340, 50, 30, imagesDir.."mX.png", "editing").bgColor = {127, 127, 127, 127}
	gooi.newButton("btnMY", "", 10, 340, 50, 30, imagesDir.."mY.png", "editing").bgColor = {127, 127, 127, 127}
	gooi.newButton("btnCopyL", "", 10, 380, 50, 30, imagesDir.."copyL.png", "editing"):setToolTip("Copy frame from the left")
	gooi.newButton("btnCopyR", "", 70, 380, 50, 30, imagesDir.."copyR.png", "editing"):setToolTip("Copy frame from the right")
	gooi.newButton("btnAF", "", 10, 420, 50, 30, imagesDir.."osFolder.png", "editing").bgColor = {0, 0, 0, 127}
	gooi.newSlider("sliAlpha", 400, 10, 90, 30, 1, "editing"):setToolTip("Alpha of color picked")
	gooi.newCheckbox("chbAA", "Auto", 580, 10, 90, 30, false, "editing"):setToolTip("Auto animation, defines a pattern")
	gooi.newButton("btnAA", "", 580, 50, 30, 30, imagesDir.."n.png", "editing"):setToolTip("Direction of the autoanimation")
	gooi.newCheckbox("chbCyclic", "Cyclic", 620, 50, 90, 30, false, "editing").bgColor = {0, 255, 0, 127}
	gooi.newSpinner("spiStep", 720, 50, 90, 30, 1, 0, 20, 1, "editing").bgColor = {255, 127, 0, 127}
	gooi.newLabel("lblInd", "255", 490, 10, 70, 30, imagesDir.."n.png", "center", "editing")
	gooi.newButton("btnChangePalette", "Palette "..palette.which, 400, 50, 90, 30, imagesDir.."n.png", "editing");
	gooi.newButton("btnFill", "", 510, 50, 50, 30, imgFill, "editing").bgColor = {127, 127, 127, 127}

	gooi.newButton("btnFS", "", width() - 120, 10, 50, 30, imagesDir.."fs.png", "editing"):onRelease(function(c)
		love.window.setFullscreen(not love.window.getFullscreen())
		c.image = love.graphics.newImage(imagesDir.."fs.png")
		if love.window.getFullscreen() then
			c.image = love.graphics.newImage(imagesDir.."nofs.png")
		end
		c:setBounds(width() - 120, 10, 50, 30)
		gooi.get("btnOptions"):setBounds(width() - 60, 10, 50, 30)
		gooi.get("btnReturn"):setBounds(width() - 120, height() - 40, 110, 30)
	end
	).bgColor = {127, 0, 127, 127}
	gooi.newButton("btnOptions", "", width() - 60, 10, 50, 30, imagesDir.."spanner.png", "editing").bgColor = {127, 0, 127, 127}
	gooi.newButton("btnQuit", "", width() - 60, 50, 50, 30, imagesDir.."quit.png", "editing").bgColor = {255, 0, 0, 127}
	
	-- Change look:
	gooi.get("btnPlay"):setToolTip("Play/Stop the animation")
	gooi.get("chbGrid"):setToolTip("Show or hide the grid")
	gooi.get("chbLoop"):setToolTip("Loop or 'just once' animation")
	gooi.get("btnMY"):setToolTip("Mirror in Y")
	gooi.get("btnMX"):setToolTip("Mirror in X")
	gooi.get("btnPrev"):setToolTip("Previous frame")
	gooi.get("btnNext"):setToolTip("Next frame")
	gooi.get("btnQuit"):setToolTip("Quit Application")
	gooi.get("chbCyclic"):setToolTip("Cyclic autoanimation, this makes the animation to 'return' from the opposite side")
	gooi.get("spiStep"):setToolTip("Step of the autoanimation, in pixels")
	gooi.get("btnFill"):setToolTip("Fill in 4 or 8 directions")
	gooi.get("btnOptions"):setToolTip("Options")
	gooi.get("btnFS"):setToolTip("Toggle fullscreen")
	gooi.get("btnAF"):setToolTip("This is experimental, it opens the save directory with os.execute()")
	local btnAA = gooi.get("btnAA")
	btnAA.bgColor = {0, 255, 0, 127}
	btnAA.opaque = true
	btnAA.radiusCorner = btnAA.h / 2
	btnAA:generateBorder()
	btnAA:setEnabled(false)
	gooi.get("chbCyclic"):setEnabled(false)
	gooi.get("spiStep"):setEnabled(false)

	-- Saving gooi:
	gooi.newSlider("sliderSave", 10, 10, width() - 20, 30, .5, "saving").bgColor = {255, 255, 0, 127}
	gooi.newButton("btnCancelSave", "Cancel", width() - 200, height() - 40, 90, 30, imagesDir.."n.png", "saving").bgColor = {200, 0, 0, 127}
	gooi.newButton("btnConfirmSave", "Save",  width() - 100,  height() - 40, 90, 30, imagesDir.."n.png", "saving")
	gooi.newLabel("lblName","Name:", width() - 550, height() - 70)
	gooi.get("lblName").group = "saving"
	gooi.newTextfield("textName", "new.png", width() - 550, height() - 40, 300, 30, "saving")
	gooi.get("sliderSave")
	gooi.get("btnCancelSave")

	-- New animation gooi:
	gooi.newLabel("lblFrameNum:", "Frames:", width() - 450, 480, 120, 30, imagesDir.."fNum.png", "left", "new")
	gooi.newLabel("lblFrameW:", "Width:", width() - 450, 520, 120, 30, imagesDir.."fW.png", "left", "new")
	gooi.newLabel("lblFrameH:", "Height:", width() - 450, 560, 120, 30, imagesDir.."fH.png", "left", "new")
	gooi.newSpinner("spiFramesNum", width() - 330, 480, 100, 30, 10, 1, 50, 1, "new")
	gooi.newSpinner("spiNewW", width() - 330, 520, 100, 30, 16, 1, 32, 1, "new")
	gooi.newSpinner("spiNewH", width() - 330, 560, 100, 30, 16, 1, 32, 1, "new")
	gooi.newButton("btnCancelNew", "Cancel", width() - 220, height() - 40, 100, 30, imagesDir.."n.png", "new")
	gooi.newButton("btnOkNew", "Ok", width() - 110, height() - 40, 100, 30, imagesDir.."n.png", "new")

	gooi.get("btnCancelNew").bgColor = {255, 0, 0, 127}

	-- Options gooi:
	gooi.newRadio("radTheme1", "Theme 1", 10, 50, 150, 30, true, "grpTheme", "options").bgColor = {135, 136, 77, 200}
	gooi.newRadio("radTheme2", "Theme 2", 10, 90, 150, 30, false, "grpTheme", "options").bgColor = {80, 140, 16, 200}
	gooi.newRadio("radTheme3", "Theme 3", 10, 130, 150, 30, false, "grpTheme", "options").bgColor = {31, 119, 193, 200}
	gooi.newButton("btnReturn", "Return", width() - 120, height() - 40, 110, 30, imagesDir.."n.png", "options")
	gooi.newRadio("radBg1", "Background 1", 200, 50, 180, 30, true, "grpBG", "options")
	gooi.newRadio("radBg2", "Background 2", 200, 90, 180, 30, false, "grpBG", "options")
	gooi.newRadio("radBg3", "Background 3", 200, 130, 180, 30, false, "grpBG", "options")
	gooi.newCheckbox("chbAutosave", "Save animation when playing", 10, 190, 310, 30, true, "options").bgColor = {0, 255, 0, 127}
	
	-- Open gooi:
	gooi.newButton("btnOpenThis", "Open this", width() - 120, height() - 40, 110, 30, imagesDir.."n.png", "opening")
	gooi.newButton("btnCancelOpen", "Cancel", width() - 240, height() - 40, 110, 30, imagesDir.."n.png", "opening").bgColor = {255, 0, 0, 127}
	availableAnims = {}

	gooi.setGroupEnabled("saving", false)
	gooi.setGroupEnabled("opening", false)
	gooi.setGroupEnabled("new", false)
	gooi.setGroupEnabled("options", false)



	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- Events:
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	local function checkAutoAnim()
		gooi.get("btnAA"):setEnabled(gooi.get("chbAA").checked)
		gooi.get("chbCyclic"):setEnabled(gooi.get("chbAA").checked)
		gooi.get("spiStep"):setEnabled(gooi.get("chbAA").checked)
	end
	local function returnFromOpening()
		gooi.setGroupEnabled("open", false)
		gooi.setGroupEnabled("new", false)
		gooi.setGroupEnabled("options", false)
		gooi.setGroupEnabled("editing", true)
		gooi.get("btnAA"):setEnabled(gooi.get("chbAA").checked)
		gooi.get("chbCyclic"):setEnabled(gooi.get("chbAA").checked)
		checkAutoAnim()
		state = STATE_EDITING
	end
	function playOrStop(c)
		playing = not playing
		c.bgColor = {0, 255, 0, 127}
		c.image = imgRight
		currentFrameIndex = 1
		analAnim:reset()
		if playing then
			analAnim:play()
			c.bgColor = {255, 0, 0, 127}
			c.image = imgStop
		end
	end
	local function callSave(c)
		gooi.setGroupEnabled("saving", true)
		gooi.setGroupVisible("saving", true)
		gooi.setGroupEnabled("editing", false)
		state = STATE_SAVING
	end
	function performSave(c)
		imgAnalAnim, info = animManager.saveAnimation(gooi.get("textName").text, frames, finalW, finalH)
		analAnim = newAnimation(imgAnalAnim, info.fW, info.fH, gooi.get("spiSpeed").value, #frames)
		gooi.setGroupEnabled("saving", false)
		gooi.setGroupEnabled("editing", true)
		checkAutoAnim()
		gooi.get("btnSave"):setEnabled(false)
		animSaved = true
		state = STATE_EDITING
	end
	function setFillMode4(c)
		fillMode = "4"
		c.bgColor = {255, 127, 0, 127}
		c.image = imgFill4
	end
	function setFillMode8(c)
		fillMode = "8"
		c.bgColor = {255, 255, 0, 127}
		c.image = imgFill8
	end
	function setNoFillMode(c)
		fillMode = nil
		c.bgColor = {127, 127, 127, 127}
		c.image = imgFill
	end
	gooi.get("btnCopyL"):onRelease(function(c) copyPrevious() notifyNotSaved() end)
	gooi.get("btnCopyR"):onRelease(function(c) copyNext()     notifyNotSaved() end)
	gooi.get("btnPrev"):onRelease(function(c)  frameLeft() end)
	gooi.get("btnNext"):onRelease(function(c)  frameRight() end)
	gooi.get("btnPlay"):onRelease(function(c)
		playOrStop(c)
		print(tostring(gooi.get("chbAutosave").checked))
		if gooi.get("chbAutosave").checked then
			if animSaved then
				performSave()
			end
		end
	end)
	gooi.get("chbLoop"):onRelease(function(c)
		analAnim.mode = 1
		if not c.checked then
			analAnim.mode = 2
		end
	end)
	gooi.get("btnSave"):onRelease(function(c)
		if animSaved then
			performSave(c)
		else
			callSave(c)
		end
	end)
	gooi.get("btnSaveAs"):onRelease(function(c)
		callSave(c)
	end)
	gooi.get("btnDel"):onRelease(function(c)
		deleteFrame()
		notifyNotSaved()
	end)
	gooi.get("btnAdd"):onRelease(function(c)
		addNewFrame()
		notifyNotSaved()
	end)
	gooi.get("btnNew"):onRelease(function(c)
		gooi.setGroupEnabled("new", true)
		gooi.setGroupEnabled("saving", true)
		gooi.setGroupEnabled("editing", false)
		gooi.get("lblName"):setVisible(false)
		gooi.get("textName"):setVisible(false)
		gooi.get("btnCancelSave"):setVisible(false)
		gooi.get("btnConfirmSave"):setVisible(false)
		state = STATE_NEW
	end)
	gooi.get("btnOpen"):onRelease(function(c)
		gooi.setGroupEnabled("editing", false)
		gooi.setGroupEnabled("opening", true)
		availableAnims = animManager.loadAvailable()
		gooi.get("btnOpenThis"):setEnabled(not (#availableAnims == 0))
		state = STATE_OPENING
	end)
	gooi.get("btnCancelSave"):onRelease(function(c)
		gooi.setGroupEnabled("saving", false)
		gooi.setGroupEnabled("editing", true)
		checkAutoAnim()
		state = STATE_EDITING
	end)
	gooi.get("btnCancelOpen"):onRelease(function(c)
		returnFromOpening()
	end)
	gooi.get("btnOpenThis"):onRelease(function(c)
		setOpenedAnim()
		returnFromOpening()
	end)
	gooi.get("btnConfirmSave"):onRelease(function(c)
		performSave(c)
	end)
	-- Mirrors:
	gooi.get("btnMX"):onRelease(function(c)
		mirrorX = not mirrorX
		c.bgColor = {127, 127, 127, 127}
		if mirrorX then
			c.bgColor = {0, 255, 0, 127}
		end
	end)
	gooi.get("btnMY"):onRelease(function(c)
		mirrorY = not mirrorY
		c.bgColor = {127, 127, 127, 127}
		if mirrorY then
			c.bgColor = {0, 255, 0, 127}
		end
	end)
	gooi.get("btnCancelNew"):onRelease(function(c)
		gooi.setGroupEnabled("new", false)
		gooi.setGroupEnabled("saving", false)
		gooi.setGroupEnabled("editing", true)
		checkAutoAnim()
		state = STATE_EDITING
	end)
	gooi.get("btnOkNew"):onRelease(function(c)
		setNewAnim(gooi.get("spiFramesNum").value, gooi.get("spiNewW").value, gooi.get("spiNewH").value)
		checkAutoAnim()
		state = STATE_EDITING
	end)
	gooi.get("btnAA"):onRelease(function(c)
		local sense = 1

		if shiftDown() then sense = -1 end
		aaRotation = aaRotation + 45 * sense
		aaDirection = aaDirection + 1 * sense
		if aaRotation >= 360 then aaRotation = 0 end
		if aaDirection > 8 then aaDirection = 1 end
		if aaDirection < 1 then aaDirection = 8 end
	end)
	gooi.get("chbAA"):onRelease(function(c)
		checkAutoAnim()
	end)
	gooi.get("btnReturn"):onRelease(function(c)
		gooi.setGroupEnabled("options", false)
		gooi.setGroupEnabled("editing", true)
		checkAutoAnim()
		state = STATE_EDITING
	end)
	gooi.get("btnFill"):onRelease(function(c)
		if not fillMode then
			setFillMode4(c)
		elseif fillMode == "4" then
			setFillMode8(c)
		elseif fillMode == "8" then
			setNoFillMode(c)
		end
	end)
	gooi.get("btnChangePalette"):onRelease(function(c)
		palette.change()
		c.label = "Palette "..palette.which
	end)
	gooi.get("btnOptions"):onRelease(function(c)
		gooi.setGroupEnabled("editing", false)
		gooi.setGroupEnabled("options", true)
		state = STATE_OPTIONS
	end)
	gooi.get("btnQuit"):onRelease(function(c) exit() end)
	gooi.get("btnAF"):onRelease(function(c)
		openAnimsFolder()
	end)
end






---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- love.draw()
---------------------------------------------------------------------------
---------------------------------------------------------------------------

function love.update(dt)
	gooi.update(dt)

	if state == STATE_EDITING then
		if mo.isDown(MOUSE_LEFT) then
			setPixel(mo.getX(), mo.getY(), brush.color, true)
			updateAnchor(mo.getPosition())
		end
		gooi.get("sliAlpha").bgColor = brush.color
		local a = math.floor(gooi.get("sliAlpha").value * 255)
		gooi.get("sliAlpha").bgColor[4] = a
		gooi.get("lblInd").label = tostring(a)

		local btn = gooi.get("btnSave")
		btn.image = imgSave
		if shiftDown() then
			btn.image = imgSaveAs
		end
		-- Update color picked:
		if palette.mouseInside() then
			if mo.isDown(MOUSE_LEFT) then
				palette.pressed = true
				palette.changeSquare(mo.getX(), mo.getY())
				brush.color = palette.getColor()
			end
		elseif palette.pressed then
			local x = mo.getX()
			local y = mo.getY()
			if x >= palette.x + palette.w() then
				x = palette.x + palette.w() - palette.scale()
			end
			if x <= palette.x then x = palette.x end
			if y >= palette.y + palette.h() then
				y = palette.y + palette.h() - palette.scale()
			end
			if y <= palette.y then y = palette.y end
			palette.changeSquare(x, y)
			brush.color = palette.getColor(palette.xColor, palette.yColor)
		end
		-- Update color indicator:
		for i = 1, 3 do
			colorIndicator[i] = colorIndicator[i] - 500 * dt
			if colorIndicator[i] < 0 then colorIndicator[i] = 255 end
		end
		-- Update canvas position:
		if mo.isDown(MOUSE_MIDDLE) then
			xCanvas = mo.getX() - dispCX
			yCanvas = mo.getY() - dispCY
		end
		-- Update analAnim:
		if playing then
			analAnim:update(dt)
			currentFrameIndex = analAnim.position
			if not analAnim.playing then
				playOrStop(gooi.get("btnPlay"))
			end
		end
		-- Animation:
		analAnim:setFramesDelay(gooi.get("spiSpeed").value)
	elseif state == STATE_SAVING then

	elseif state == STATE_OPENING then

	end
end






---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- love.draw()
---------------------------------------------------------------------------
---------------------------------------------------------------------------

function love.draw()
	-- Background dude:
	gr.setColor(255, 255, 255)
	if gooi.get("radTheme1").selected  then
		gr.setBackgroundColor(bgC1)
		gr.draw(bgDude1, 135, height() - bgDude1:getHeight() * 30, 0, 30, 30)
	elseif gooi.get("radTheme2").selected  then
		gr.setBackgroundColor(bgC2)
		gr.draw(bgDude2, 400, 200, 0, 20, 20)
	elseif gooi.get("radTheme3").selected  then
		gr.setBackgroundColor(bgC3)
		gr.draw(bgDude3, width() - bgDude3:getWidth() * 16, 0, 0, 16, 16)
	end
	if v then gr.print("file saved", 10, 70) end
	if state == STATE_EDITING then

		drawCurrentFrame()

		-- Grid:
		if gooi.get("chbGrid").checked then
			gr.setLineStyle("rough")
			gr.setColor(127, 127, 127, 150)
			for i = 1, w - 1 do-- Vertical lines:
				gr.line(xCanvas + i * pS, yCanvas, xCanvas + i * pS, yCanvas + h * pS - 1)
			end
			for i = 1, h - 1 do-- Horizonal:
				gr.line(xCanvas, yCanvas + i * pS - 1, xCanvas + w * pS - 1, yCanvas + i * pS)
			end
			gr.setLineStyle("smooth")
		end
		-- Mirror lines:
		gr.setColor(0, 255, 0)
		if mirrorX then
			gr.line(xCanvas + w * pS / 2, yCanvas, xCanvas + w * pS / 2, yCanvas + h * pS)
		end
		if mirrorY then
			gr.line(xCanvas, yCanvas + h * pS / 2, xCanvas + w * pS, yCanvas + h * pS / 2)
		end
		-- Cursor:
		local x, y = getFixedPosition(mo.getPosition())
		if insideCanvas(mo.getPosition()) then
			gr.setColor(127, 127, 127, 127)
			gr.rectangle("fill", xCanvas + ((x - 1) * pS), yCanvas + ((y - 1) * pS), pS, pS)
			gr.rectangle("fill", xCanvas + ((x - 1) * pS) + pS / 4, yCanvas + ((y - 1) * pS) + pS / 4, pS / 2, pS / 2)
		end
		-- Line (if drawing a rect):
		if lineAnchor and shiftDown() and insideCanvas(mo.getPosition()) then
			local cF = frames[currentFrameIndex]
			bresenham(lineAnchor[1], lineAnchor[2],
					  x, y, #cF[1], #cF, cF, {127, 127, 127, 127}, true)
		end
		-------------------------------
		local p = palette
		-------------------------------
		gr.setColor(12, 183, 242)
		gr.rectangle("line", p.x - 1, p.y - 1, p.w() + 2, p.h() + 2)
		
		-- Toolbar margin:
		gr.setColor(0, 0, 0, 100)
		gr.rectangle("fill", 0, 0, width(), tbUpLimit)
		gr.rectangle("fill", 0, tbUpLimit, tbLeftLimit, height() - tbUpLimit)
		
		gr.setColor(6, 96, 128)
		-- Just some separators:
		gr.line(10, 290, 120, 290)
		gr.line(570, 10, 570, 80)

		-- Palette:
		gr.setColor(255, 255, 255)
		gr.draw(p.img(), p.x, p.y, 0, p.scale(), p.scale())
		-- Little indicator:
		gr.setLineStyle("rough")
		gr.setColor(colorIndicator)
		gr.rectangle("line", p.xColor, p.yColor, p.scale(), p.scale())
		gr.setLineStyle("smooth")
		-- Autoanimation:
		local btn = gooi.get("btnAA")
		-- Mini map:

		if w * pS > width() or h * pS > height() then
			gr.setLineStyle("rough")
			local mmPS = 4
			local mmX = width() - w * mmPS - 30
			local mmY = height() - h * mmPS - 30
			gr.setColor(0, 0, 0, 127)
			gr.rectangle("fill", mmX, mmY, w * mmPS, h * mmPS)
			gr.setColor(colorIndicator)
			gr.rectangle("line", mmX, mmY, w * mmPS + 1, h * mmPS + 1)

			-- frame of the animation:
			gr.setColor(255, 255, 255, 255)
			gr.draw(analAnim.img, analAnim.frames[currentFrameIndex], mmX, mmY, 0, mmPS, mmPS)

			local xMask = mmX - (mmPS * xCanvas / pS)
			local yMask = mmY - (mmPS * yCanvas / pS)
			local wMask = (w * mmPS) * width() / (w * pS)
			local hMask = (h * mmPS) * height() / (h * pS)
			gr.setColor(colorIndicator)
			gr.rectangle("line", xMask, yMask, wMask, hMask)
		end

		gr.setColor(255, 255, 255)
		gooi.draw("editing")

		gr.setColor(255, 255, 255)
		if not gooi.get("chbAA").checked then
			gr.setColor(127, 127, 127)
		end
		gr.draw(imgAAArrow, btn.x + btn.w / 2, btn.y + btn.h / 2,
			math.rad(aaRotation), 1, 1, imgAAArrow:getWidth() / 2, imgAAArrow:getHeight() / 2)
		gr.setColor(255, 0, 0)
	
	elseif state == STATE_SAVING then
		gooi.draw("saving")
		drawMatrixFrame()
	elseif state == STATE_NEW then
		gooi.draw("saving")
		gooi.draw("new")
		drawMatrixFrame()
		gr.print("New animation:", width() - 450, height() - 200)
	elseif state == STATE_OPENING then
		gooi.draw("opening")
		gr.print("Your animations:", 10, 10)
		for i = 1, #availableAnims do
			local item = availableAnims[i]
			gr.setColor(12, 183, 242, 127)
			local mode = "line"
			if item.selected then
				mode = "fill"
			end
			gr.rectangle(mode, item.x - 5, item.y - 5,
				gooi.getFont():getWidth(item.name) + 10,
				gooi.getFont():getHeight() + 10)
			gr.setColor(255, 255, 255)
			gr.print(item.name, item.x, item.y)
		end
	elseif state == STATE_OPTIONS then
		gr.print("Select a theme:", gooi.get("radTheme1").x, 10)
		gr.print("Anim background:", gooi.get("radBg1").x, 10)
		gr.draw(sBgImage(), 450, 32)
		gooi.draw("options")
	end
	gr.setColor(255, 255, 255)
	--gr.print(aaDirection, 200,200)
	gr.setFont(debugFont)
	gr.print("FPS: "..love.timer.getFPS()..", Frame: "..currentFrameIndex.."/"..#frames, 0, height() - debugFont:getHeight())
	--gr.print("dispCX: "..dispCX..", dispCY: "..dispCY, 0, height() - debugFont:getHeight() * 2)
end


----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------


function drawCurrentFrame()
	gr.setCanvas(bgC)
	gr.clear(0, 0, 0, 1)
	-- Draw background for the canvas:
	gr.draw(sBgImage(), gr.newQuad(xCanvas, yCanvas, w * pS, h * pS, sBgImage():getWidth(), sBgImage():getHeight()))
	
	gr.setCanvas()
	gr.setColor(255, 255, 255)

	gr.draw(bgC, xCanvas, yCanvas)
	gr.setColor(255, 255, 255)
	-- Draw AnAL animation or grid of pixels:
	if playing then
		analAnim:draw(xCanvas, yCanvas, 0, pS, pS)
	else
		local f = frames[currentFrameIndex]
		for i = 1, #f do
			for j = 1, #f[i] do
				local n, m = 0, 0
				if i == #f then m = 1 end
				if j == #f[i] then n = 1 end
				local p = f[i][j]
				gr.setColor(p.color)
				gr.rectangle("fill",
					(xCanvas) + (j - 1) * pS,
					(yCanvas) + (i - 1) * pS, pS - n, pS - m)
			end
		end
	end
end

function sBgImage()
	if gooi.get("radBg1").selected then return bgImage1 end
	if gooi.get("radBg2").selected then return bgImage2 end
	if gooi.get("radBg3").selected then return bgImage3 end
end

function drawMatrixFrame()
	-- Draw matrix of frames:
	local theW, theH = w, h
	local theFNumber = #frames

	if state == STATE_NEW then
		theW, theH = gooi.get("spiNewW").value, gooi.get("spiNewH").value
		theFNumber = gooi.get("spiFramesNum").value
	end

	local smaller, scale = theW, 1
	--[[if theH < theW then smaller = theH end
	if smaller <= 16 then
		scale = 2
		if smaller <= 8 then
			scale = 4
			if smaller <= 4 then
				scale = 8
			end 
		end
	end]]
	local s = gooi.get("sliderSave")
	local widthDesired = s.value * (s.w - s.h)
	local xDisp, yDisp = 0, 0
	local x0, y0, indexX, indexY = s.x + s.h / 2, s.y + s.h * 2, 1, 1
	local nW, nH = 1, 1
	for i = 1, theFNumber do
		if xDisp > (widthDesired) / scale then
			xDisp, indexX = 0, 0
			yDisp = yDisp + theH
			indexY = indexY + 1
			nH = nH + 1
		else
			indexX = indexX + 1
			if indexX > nW then nW = indexX - 1 end
		end

		gr.setColor(12, 183, 242)
		if (indexX + indexY) % 2 == 0 then gr.setColor(12, 183, 242, 127) end
		gr.rectangle("fill", x0 + xDisp * scale, y0 + yDisp * scale, theW * scale, theH * scale)

		xDisp = xDisp + theW

	end
	finalW = nW
	finalH = nH
	gr.setColor(0, 63, 63)
	local t = finalW.." x "..finalH
	local x = x0 + finalW * theW * scale / 2 - gooi.getFont():getWidth(t) / 2
	local y = y0 + finalH * theH * scale / 2 - gooi.getFont():getHeight() / 2

	--gr.print(t, x - gooi.getFont():getHeight() / 12, y - gooi.getFont():getHeight() / 12)
	gr.print(t, x0 - gooi.getFont():getHeight() / 12, y0 - 20 - gooi.getFont():getHeight() / 12)
	gr.setColor(255, 255, 255)
	--gr.print(t, x, y)
	gr.print(t, x0, y0 - 20)
	gr.setLineWidth(win.smaller() / 300)
	gr.rectangle("line", x0, y0, finalW * theW * scale, finalH * theH * scale)
end

function setOpenedAnim()
	currentFrameIndex = 1
	frames, imgAnalAnim, info = animManager.openAnimation(animManager.getSelectedItem().name)
	loadFrames(frames, imgAnalAnim, info)
	setBoundsPixel()
	setBoundsCanvas()
	analAnim.mode = 1
	if not gooi.get("chbLoop").checked then
		analAnim.mode = 2
	end
end

function setNewAnim(n, theW, theH)
	currentFrameIndex = 1
	frames = animManager.createFrames(n, theW, theH)
	h = #frames[1]
	w = #frames[1][1]
	setBoundsPixel()
	setBoundsCanvas()
	gooi.setGroupEnabled("saving", false)
	gooi.setGroupEnabled("new", false)
	gooi.setGroupEnabled("editing", true)
	performSave()
end

function loadFrames(f, img, info)
	if f then
		frames = f
		analAnim = newAnimation(img, info.fW, info.fH, gooi.get("spiSpeed").value, info.frameNum)
	else
		frames = animManager.createFrames(10, 16, 16)
		analAnim = newAnimation(love.graphics.newImage(love.image.newImageData(16 * #frames, 16)), 16, 16, 10, #frames)
	end
	h = #frames[1]
	w = #frames[1][1]
	saved = true
end

function setPixel(x, y, c, fromUpdate)
	-- Transform to the virtual pixels on the current frame:
	if insideCanvas(x, y) and y > tbUpLimit and x > tbLeftLimit and not playing then
		local fixedX, fixedY = getFixedPosition(x, y)
		local cF = frames[currentFrameIndex]
		local fW, fH = #cF[1], #cF
		--print(fixedX, fixedY)

		if kb.isDown("e") then
 			c = {0, 0, 0, 0}
		end

		if not fromUpdate then
			flood(fixedX, fixedY, cF, cF[fixedY][fixedX].color, brush.color)
		else
			cF[fixedY][fixedX]:setColor(c)
		end

		-- Draw a line if it's the case (Bresenham's Line Algorithm):
		if lineAnchor and shiftDown() then
			bresenham(lineAnchor[1], lineAnchor[2], fixedX, fixedY, fW, fH, cF,c)
		end

		-- Mirrors:
		drawMirrors(fixedX, fixedY, fW, fH, cF, c)
		
		-- Autoanimation:
		drawAutoAnim(fixedX, fixedY, fW, fH, cF, c)

		notifyNotSaved()
	end
end

function drawMirrors(fixedX, fixedY, fW, fH, cF, c)
	local fXM, fYM-- Fixed X-mirror and fixed Y-mirror.
	if mirrorX then
		fXM = fixedX + (fW / 2 - fixedX) * 2 + 1
		flood(fXM, fixedY, cF, cF[fixedY][fXM].color, c)
		cF[fixedY][fXM]:setColor(c)
		drawAutoAnim(fXM, fixedY, fW, fH, cF, c)
	end
	if mirrorY then
		fYM = fixedY + (fH / 2 - fixedY) * 2 + 1
		flood(fixedX, fYM, cF, cF[fYM][fixedX].color, c)
		cF[fYM][fixedX]:setColor(c)
		drawAutoAnim(fixedX, fYM, fW, fH, cF, c)
	end
	if mirrorX and mirrorY then
		fXM = fixedX + (fW / 2 - fixedX) * 2 + 1
		fYM = fixedY + (fH / 2 - fixedY) * 2 + 1
		flood(fXM, fYM, cF, cF[fYM][fXM].color, c)
		cF[fYM][fXM]:setColor(c)
		drawAutoAnim(fXM, fYM, fW, fH, cF, c)
	end
end

function flood(x, y, cF, tC, rC)
	if fillMode then
		if sameColor(tC, rC) then return end

		local stack = {}

		if sameColor(cF[y][x].color, tC) then
			table.insert(stack, cF[y][x])
		end

		while #stack > 0 do
			local p = pop(stack)
			x, y = p.x, p.y
			
			if sameColor(cF[y][x].color, tC) then
				-- 4 directions flood fill:
				cF[y][x]:setColor(rC)
				drawAutoAnim(x, y, #cF[1], #cF, cF, rC)
				if validPixel(cF, x + 1, y) then
					table.insert(stack, cF[y][x + 1])
				end
				if validPixel(cF, x - 1, y) then
					table.insert(stack, cF[y][x - 1])
				end
				if validPixel(cF, x, y + 1) then
					table.insert(stack, cF[y + 1][x])
				end
				if validPixel(cF, x, y - 1) then
					table.insert(stack, cF[y - 1][x])
				end

				-- 8 directions flood fill:
				if fillMode == "8" then
					if validPixel(cF, x - 1, y - 1) then
						table.insert(stack, cF[y - 1][x - 1])
					end
					if validPixel(cF, x + 1, y - 1) then
						table.insert(stack, cF[y - 1][x + 1])
					end
					if validPixel(cF, x - 1, y + 1) then
						table.insert(stack, cF[y + 1][x - 1])
					end
					if validPixel(cF, x + 1, y + 1) then
						table.insert(stack, cF[y + 1][x + 1])
					end
				end
			end
		end
	end
end

function validPixel(frame, x, y)
	return not (frame[y] == nil or frame[y][x] == nil)
end

function pop(t)
	local item = t[#t]
	table.remove(t, #t)
	return item
end

function sameColor(c1, c2)
	return
	c1[1] == c2[1] and
	c1[2] == c2[2] and
	c1[3] == c2[3] and
	c1[4] == c2[4]
end

function drawAutoAnim(fixedX, fixedY, fW, fH, cF, c)
	if gooi.get("chbAA").checked then
		local dx, dy = fixedX, fixedY -- Displacements.
		local s = gooi.get("spiStep").value
		for i = currentFrameIndex + 1, #frames do
			local f = frames[i]

			if aaDirection == 1 then dx = dx + s end
			if aaDirection == 2 then dx = dx + s dy = dy + s end
			if aaDirection == 3 then dy = dy + s end
			if aaDirection == 4 then dx = dx - s dy = dy + s end
			if aaDirection == 5 then dx = dx - s end
			if aaDirection == 6 then dx = dx - s dy = dy - s end
			if aaDirection == 7 then dy = dy - s end
			if aaDirection == 8 then dx = dx + s dy = dy - s end

			--[[
				This basically says: take whatever coordinate to the first
				frame coordinates, so we don't we a nil error:
			]]
			if gooi.get("chbCyclic").checked then
				if dx > fW then
					dx = math.abs(dx) % fW
					if dx == 0 then dx = fW end
				end
				if dx < 1  then
					--dx = (fW + 1) - math.abs(dx)
					dx = math.abs(dx) % fW
					if dx == 0 then dx = fW end
				end
				if dy > fH then
					dy = math.abs(dy) % fH
					if dy == 0 then dy = fH end
				end
				if dy < 1  then
					--dy = (fH + 1) - math.abs(dy)
					dy = math.abs(dy) % fH
					if dy == 0 then dy = fH end
				end
			end
			if f[dy] and f[dy][dx] then
				f[dy][dx]:setColor(cF[fixedY][fixedX].color)
			end
		end
	end
end

function bresenham(x1, y1, x2, y2, fW, fH, currentFrame, color, preDrawing)
	local function drawThisStuff()
		if preDrawing then
			gr.setColor(color)
			gr.rectangle("fill", xCanvas + (x1 - 1) * pS, yCanvas + (y1 - 1) * pS, pS, pS)
		else
			currentFrame[y1][x1]:setColor(color)
			drawAutoAnim(x1, y1, fW, fH, currentFrame, color)
			drawMirrors(x1, y1, fW, fH, currentFrame, color)
		end
	end
	
	delta_x = x2 - x1
	ix = delta_x > 0 and 1 or -1
	delta_x = 2 * math.abs(delta_x)

	delta_y = y2 - y1
	iy = delta_y > 0 and 1 or -1
	delta_y = 2 * math.abs(delta_y)
	drawThisStuff()

	if delta_x >= delta_y then
		err = delta_y - delta_x / 2

		while x1 ~= x2 do
			if (err >= 0) and ((err ~= 0) or (ix > 0)) then
				err = err - delta_x
				y1 = y1 + iy
			end

			err = err + delta_y
			x1 = x1 + ix

			drawThisStuff()
		end
	else
		err = delta_x - delta_y / 2

		while y1 ~= y2 do
			if (err >= 0) and ((err ~= 0) or (iy > 0)) then
				err = err - delta_y
				x1 = x1 + ix
			end

			err = err + delta_x
			y1 = y1 + iy

			drawThisStuff()
		end
	end
end

function notifyNotSaved()
	gooi.get("btnSave"):setEnabled(true)
end

function getFixedPosition(xm, ym)
	--local x = (xm - (width() / 2 - w / 2 * pS) - tbLeftLimit / 2) / pS
	--local y = (ym - (height() / 2 - h / 2 * pS) - tbUpLimit / 2) / pS
	--return x, yç
	local fixedX = math.floor((xm - xCanvas) / pS) + 1
	local fixedY = math.floor((ym - yCanvas) / pS) + 1
	return fixedX, fixedY
end

function insideCanvas(x, y)
	return not (
		x <= xCanvas or
		x >= xCanvas + pS * w or
		y <= yCanvas or
		y >= yCanvas + pS * h
	)
end

function setBoundsCanvas(xZoom, yZoom)
	local xCenter = (width() / 2)
	local yCenter = (height() / 2)
	local xHalf = (w / 2 * pS)
	local yHalf = (h / 2 * pS)
	if xZoom and yZoom then
		----
	end
	xCanvas = (xCenter - xHalf + tbLeftLimit / 2)
	yCanvas = (yCenter - yHalf + tbUpLimit / 2)
	bgC = gr.newCanvas(pS * w - 1, pS * h - 1)-- Background canvas.
end

function setBoundsPixel()
	local largerSide = w
	local largerRef = width()
	if h > w then
		largerSide = h
		largerRef = height()
	end
	--pS = math.floor((largerRef / largerSide) * .5)
	minPS = 4
	maxPS = 64
	pS = minPS

	if pS < minPS then pS = minPS end
	if pS > maxPS then pS = maxPS end
	
	tbUpLimit = 90
	tbLeftLimit = 130
	dispCX, dispCY = 0, 0
end

function frameLeft()
	currentFrameIndex = currentFrameIndex - 1
	if currentFrameIndex < 1 then
		currentFrameIndex = #frames
		analAnim:reset()
	end
end

function frameRight()
	currentFrameIndex = currentFrameIndex + 1
	if currentFrameIndex > #frames then
		currentFrameIndex = 1
		analAnim:reset()
	end
end

function copyPrevious()
	if currentFrameIndex - 1 > 0 then
		local pF = frames[currentFrameIndex - 1]
		local f = frames[currentFrameIndex]
		for x = 1, #f[1] do
			for y = 1, #f do
				f[y][x]:setColor(pF[y][x].color)
			end
		end
	end
end

function copyNext()
	if currentFrameIndex + 1 <= #frames then
		local pF = frames[currentFrameIndex + 1]
		local f = frames[currentFrameIndex]
		for x = 1, #f[1] do
			for y = 1, #f do
				f[y][x]:setColor(pF[y][x].color)
			end
		end
	end
end

function deleteFrame()
	if #frames > 1 then
		if shiftDown() then
			table.remove(frames, currentFrameIndex)
		else
			table.remove(frames)
		end
		if currentFrameIndex > #frames then
			currentFrameIndex = #frames
		end
	end
end

function addNewFrame()
	if shiftDown() then
		table.insert(frames, currentFrameIndex, animManager.newFrame(w, h))
	else
		table.insert(frames, animManager.newFrame(w, h))
	end
end

function clearFrame(i)
	local f = frames[i]
	for i = 1, #f do
		for j = 1, #f[i] do
			f[i][j]:setColor(0, 0, 0, 0)
		end
	end
end

function overAnItem(mx, my)
	local selected = nil
	for i = 1, #availableAnims do
		local item = availableAnims[i]
		if not (
			mx <= item.x - 5 or
			mx >= item.x + gooi.getFont():getWidth(item.name) + 10 or
			my <= item.y - 5 or
			my >= item.y + gooi.getFont():getHeight() + 10
		)
		then
			selected = item
			animManager.deselectItems()
			selected.selected = true
			break
		end
	end
	return selected
end

function love.wheelmoved(x, y)
	local zooming = 1
	if pS >= 4 then zooming = 2 end
	if pS >= 8 then zooming = 4 end
	if y > 0 then
		pS = pS + zooming
		if pS >= maxPS then pS = maxPS end
		setBoundsCanvas()
	elseif y < 0 then
		pS = pS - zooming
		if pS <= minPS then pS = minPS end
		setBoundsCanvas()
	end
end

function love.mousepressed(x, y, button)
	gooi.pressed()
	if state == STATE_EDITING then
		if button == "l" then
			if palette.mouseInside() then
				palette.pressed = true
				brush.color = palette.getColor()
				palette.changeSquare(x, y)
			else
				setPixel(x, y, brush.color)
				updateAnchor(x, y)
			end
		elseif button == MOUSE_MIDDLE then-- Drag canvas:
			dispCX = x - xCanvas
			dispCY = y - yCanvas
		end
	elseif state == STATE_OPENING then
		if overAnItem(x, y) then
			
		end
	end
end

function love.mousereleased(x, y, button)
	gooi.released()
	palette.pressed = false
end

-------------------------------------------------
function love.threaderror(thread, errorstr)
  error("Thread error!\n"..errorstr)
end
-------------------------------------------------

function love.textinput(key, code) gooi.textinput(key, code) end

function love.keypressed(key)
	gooi.keypressed(key)
	if state == STATE_EDITING then
		-- Fill mode:
		if key == "b" then
			setFillMode4(gooi.get("btnFill"))
			if ctrlDown() then
				setFillMode8(gooi.get("btnFill"))
			end
		elseif kb.isDown("b") then
			if isCtrl(key) then
				setFillMode8(gooi.get("btnFill"))
			end
		end
		-- Move throught frames:
		if key == "left" then
			frameLeft()
		elseif key == "right" then
			frameRight()
		end
		-- Some shortcuts:
		if ctrlDown() then
			if key == "g" then-- Show or hide grid:
				gooi.get("chbGrid"):change()
			elseif key == "f" then-- First frame:
				currentFrameIndex = 1;
			elseif key == "l" then-- Last one:
				currentFrameIndex = #frames
			elseif key == "a" then-- Add a new one:
				addNewFrame()
				notifyNotSaved()
			elseif key == "d" then-- Delete:
				deleteFrame()
				notifyNotSaved()
			end

			if shiftDown() then
				if key == "c" then
					clearFrame(currentFrameIndex)
				end
			end
		end

		if altDown() then
			if key == "c" then
				palette.change()
				brush.color = palette.getColor(palette.xColor, palette.yColor)
			end
		end
	end
end

function love.keyreleased(key)
	if isCtrl(key) then
		if kb.isDown("b") then
			setFillMode4(gooi.get("btnFill"))
		else
			setNoFillMode(gooi.get("btnFill"))
		end
	end
	if key == "b" then
		setNoFillMode(gooi.get("btnFill"))
	end
end

function updateAnchor(x, y)
	if insideCanvas(x, y) then
		lineAnchor = {getFixedPosition(x, y)}
	end
end

function love.resize(w, h)
	gooi.get("btnFS"):setBounds(width() - 120, 10, 50, 30)
	gooi.get("btnOptions"):setBounds(width() - 60, 10, 50, 30)
	gooi.get("btnQuit"):setBounds(width() - 60, 50, 50, 30)
	gooi.get("btnReturn"):setBounds(width() - 120, height() - 40, 110, 30)
end

function openAnimsFolder()
	local oS = love.system.getOS()
	local folder = love.filesystem.getSaveDirectory()
	local command = "nautilus "..folder
	print("command: "..command)
	if oS == "Linux" then
		if os.execute(command) == -1 then -- Not this.
			command = "thunar "..folder
			if os.execute(command) == -1 then -- Not this.
				os.execute("konqueror "..folder)-- Maybe this.
			end
		end
	elseif oS == "Windows" then
		os.execute("explorer "..love.filesystem.getSaveDirectory())
	end
end

function isShift(key)
	return key == "lshift" or key == "rshift"
end

function isCtrl(key)
	return key == "lctrl" or key == "rctrl"
end

function isAlt(key)
	return key == "lalt" or key == "ralt"
end

function shiftDown()
	return kb.isDown("lshift") or kb.isDown("rshift")
end

function ctrlDown()
	return kb.isDown("lctrl") or kb.isDown("rctrl")
end

function altDown()
	return kb.isDown("lalt") or kb.isDown("ralt")
end

function exit()
	love.event.quit()
end