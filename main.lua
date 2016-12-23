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
	save_dir = love.filesystem.getSaveDirectory()
	print("GÖÖi save directory: "..save_dir)
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
	states = {}-- For Ctrl + Z
	indexStates = 1
	timerCopied = 0
	-----------------------------------------------
	win = {}
	win.smaller = function()
		if width() < height() then return width() end
		return height()
	end
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
	imgPalette1 = gr.newImage(imagesDir.."palette1.png")
	imgPalette2 = gr.newImage(imagesDir.."palette2.png")
	imgPalette3 = gr.newImage(imagesDir.."palette3.png")
	imgContrast = gr.newImage(imagesDir.."contrast.png")
	imgContrastSmall = gr.newImage(imagesDir.."contrastSmall.png")

	bgDude1:setFilter("nearest", "nearest")
	bgDude2:setFilter("nearest", "nearest")
	bgDude3:setFilter("nearest", "nearest")
	imgPalette1:setFilter("nearest", "nearest")
	imgPalette2:setFilter("nearest", "nearest")
	imgPalette3:setFilter("nearest", "nearest")
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
	animSaved = true
	savedOnce = false
	just_copied = false
	-----------------------------------------------
	fillMode = nil
	brush = {}
	brush.color = {0, 0, 0, 255}
	colorIndicator = {0, 0, 0, 255}
	currentFrameIndex = 1
	aaDirection = 1-- Right.
	aaRotation = 0
	palette.change(1)

	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	-- gooi:
	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	font = gr.newFont("fonts/HussarPrintA.otf", 16)
	fontLetter = gr.newFont(30)
	style = {
		font = font,
		bgColor = "218AB8cc",
		round = .1,
		roundInside = .2,
		showBorder = true
		--mode3d = true,
		--glass = true
	}

	gooi.setStyle(style)
	debugFont = gr.newFont(width() / 70)
	finalW, finalH = 0, 0
	-- Edit gooi:
	
	btnNew = gooi.newButton({icon = imagesDir.."new.png"}):setTooltip("Create a new animation")
	btnOpen = gooi.newButton({icon = imagesDir.."open.png"}):setTooltip("Open an animation")
	btnPlay = gooi.newButton({icon = imgRight}):bg("#00ff0088"):setTooltip("Play the animacion")
	btnSave = gooi.newButton({icon = imgSave}):setTooltip("Save current animation")
	btnSaveAs = gooi.newButton("as.."):setTooltip("Save as...")
	btnPrev = gooi.newButton({icon = imgLeft}):bg("#ff880088"):setTooltip("Change to the previous frame")
	btnNext = gooi.newButton({icon = imgRight}):bg("#ff880088"):setTooltip("Change to the next frame")
	btnDel = gooi.newButton({icon = imagesDir.."del.png"}):setTooltip("Deletes the last frame (Shift to delete current)")
	btnAdd = gooi.newButton({icon = imagesDir.."add.png"}):setTooltip("Add a new frame (Shift to add in current position)")
	chbLoop = gooi.newCheck("Loop"):change():bg("#FFFF0088"):setTooltip("Loop animation")
	sliSpeed = gooi.newSlider(0.1):setTooltip("Delay in seconds for each frame"):setTooltip("Speed in seconds for each frame")
	lblSpeed = gooi.newLabel("0.1"):setOrientation("center")
	chbGrid = gooi.newCheck("Grid"):change():setTooltip("Show/Hide grid")
	btnMX = gooi.newButton({icon = imagesDir.."mX.png"}):bg("#88888888"):setTooltip("Mirror in X axis")
	btnMY = gooi.newButton({icon = imagesDir.."mY.png"}):bg("#88888888"):setTooltip("Mirror in Y axis")
	btnCopyL = gooi.newButton({icon = imagesDir.."copyL.png"}):setTooltip("Copy frame from the left")
	btnCopyR = gooi.newButton({icon = imagesDir.."copyR.png"}):setTooltip("Copy frame from the left")
	------------
	spinAlpha = gooi.newSpinner(0, 255, 255):setTooltip("Alpha of picked color")
	chbAA = gooi.newCheck("Autoanimate"):setTooltip("'Moves' the drawn pixels to the indicated direction, with the given step size")
	btnAA = gooi.newButton(""):setTooltip("Direction of the autoanimation")
	chbCyclic = gooi.newCheck("Turn"):bg("#ff880088"):setTooltip("Makes the pixels to 'return' from the opposite side")
	spiStep = gooi.newSpinner(0, 5, 1):setTooltip("Step size for the autoanimation")
	--lblInd = gooi.newLabel("255"):setOrientation("center")
	btnFill = gooi.newButton({icon = imgFill}):bg("#88888888"):setTooltip("Fill in 4 or 8 directions")
	--[[
	btnFS = gooi.newButton({icon = imagesDir.."fs.png"}):onRelease(function(c)
		love.window.setFullscreen(not love.window.getFullscreen())
		c.image = love.graphics.newImage(imagesDir.."fs.png")
		if love.window.getFullscreen() then
			c.image = love.graphics.newImage(imagesDir.."nofs.png")
		end
		--btnOptions:setBounds(width() - 60, 10, 50, 30)
		--btnReturn:setBounds(width() - 120, height() - 40, 110, 30)
	end
	):bg({127, 0, 127, 127}):setTooltip("Fullscreen")
	]]

	--gooi.newButton("btnOptions", "", width() - 60, 10, 50, 30, imagesDir.."spanner.png", "editing").bgColor = {127, 0, 127, 127}
	btnOptions = gooi.newButton({icon = imagesDir.."spanner.png"}):setTooltip("See options")
	--gooi.newButton("btnQuit", "", width() - 60, 50, 50, 30, imagesDir.."quit.png", "editing").bgColor = {255, 0, 0, 127}
	--btnQuit = gooi.newButton({icon = imagesDir.."quit.png"}):bg("#ff000088")

	btnCopyCB = gooi.newButton("Copy SD", 110, height() - 30, 110, 25):onRelease(function(c)
		c:setText("Copied!"):bg("#FF880088")
		just_copied = true
		love.system.setClipboardText(lblCopySD.text)
	end):setGroup("editing")

	lblCopySD = gooi.newLabel(save_dir, 230, height() - 30, width() - 235, 25):setGroup("editing"):setOrientation("left")
	:setOpaque(true):bg("#000000BB")

	-- Put them in the panel:
	panelEdit = gooi.newPanel(3, 3, 100, 550, "grid 16x2")
	:setColspan(2, 1, 2)-- Play
	:setColspan(6, 1, 2)
	:setColspan(7, 1, 2)
	:setColspan(8, 1, 2)
	:setColspan(9, 1, 2)
	:setColspan(12, 1, 2)
	:add(
		btnNew,
		btnOpen,
		btnPlay,
		btnSave,
		btnSaveAs,
		btnPrev,
		btnNext,
		btnDel,
		btnAdd,
		chbLoop,
		sliSpeed,
		lblSpeed,
		chbGrid,
		btnMX,
		btnMY,
		btnCopyL,
		btnCopyR,
		btnCopyCB
	):setGroup("editing")

	panelEdit2 = gooi.newPanel(510, 3, 400, 70, "grid 2x8")
	panelEdit2.layout.debug = false

	panelEdit2
	:setColspan(1, 1, 4)-- Autoanimate
	:setColspan(1, 5, 2)-- Turn
	:setColspan(2, 1, 3)-- Alpha
	:setColspan(2, 5, 2)-- Step
	--[[
	:setColspan(1, 1, 2)-- 255
	:setColspan(1, 3, 4)-- Autoanimate
	:setColspan(1, 7, 2)-- Turn
	:setColspan(2, 1, 3)-- Slider alpha
	:setColspan(2, 4, 2)-- Step
	:setColspan(2, 6, 2)-- Fill
	:add(
		--lblInd,
		chbAA,
		chbCyclic,
		btnAA,
		--btnChangePalette,
		--spiStep,
		btnFill,
		spinAlpha
		--btnFS,
		--btnOptions
	)
	]]
	:add(
		chbAA,
		chbCyclic,
		btnAA,
		btnOptions,
		spinAlpha,
		btnFill,
		spiStep
	)
	:setGroup("editing")
	--panelEdit2.layout.debug = true

	panelPalettes = gooi.newPanel(435, 3, 70, 70, "grid 3x1"):add(
		gooi.newRadio("          ", "g_palettes"):onRelease(function(c)
			palette.change(1)
			brush.color = palette.getColor(palette.xColor, palette.yColor)
		end):select(),
		gooi.newRadio("          ", "g_palettes"):onRelease(function(c)
			palette.change(2)
			brush.color = palette.getColor(palette.xColor, palette.yColor)
		end),
		gooi.newRadio("          ", "g_palettes"):onRelease(function(c)
			palette.change(3)
			brush.color = palette.getColor(palette.xColor, palette.yColor)
		end)
	):setGroup("editing")

	local function getColor(c)
		if shiftDown() then
			local bg = {brush.color[1], brush.color[2], brush.color[3], brush.color[4] or 255}
			c:bg(bg)
			c.hasColor = true
			c.showBorder = true
		else
			if c.hasColor then
				brush.color = {c.bgColor[1], c.bgColor[2], c.bgColor[3], c.bgColor[4] or 255}
				spinAlpha.bg(brush.color)
			end
		end
	end
	local ttfc = "Shift + click to pick, normal click to use"

	radioPicked1 = gooi.newRadio(" ", "grp_frequent"):bg("#888888"):onRelease(getColor):setTooltip(ttfc)
	radioPicked2 = gooi.newRadio(" ", "grp_frequent"):bg("#888888"):onRelease(getColor):setTooltip(ttfc)
	radioPicked3 = gooi.newRadio(" ", "grp_frequent"):bg("#888888"):onRelease(getColor):setTooltip(ttfc)
	radioPicked4 = gooi.newRadio(" ", "grp_frequent"):bg("#888888"):onRelease(getColor):setTooltip(ttfc)
	radioPicked5 = gooi.newRadio(" ", "grp_frequent"):bg("#888888"):onRelease(getColor):setTooltip(ttfc)
	radioPicked6 = gooi.newRadio(" ", "grp_frequent"):bg("#888888"):onRelease(getColor):setTooltip(ttfc)

	radioPicked1:border(3).showBorder = false
	radioPicked2:border(3).showBorder = false
	radioPicked3:border(3).showBorder = false
	radioPicked4:border(3).showBorder = false
	radioPicked5:border(3).showBorder = false
	radioPicked6:border(3).showBorder = false

	panelColors = gooi.newPanel(103, 3, 70, 70, "grid 3x2"):add(
		radioPicked1,
		radioPicked2,
		radioPicked3,
		radioPicked4,
		radioPicked5,
		radioPicked6
	):setGroup("editing")
	--panelColors.layout.debug = true

	btnAA:bg({0, 255, 0, 127})
	btnAA:setEnabled(false)
	chbCyclic:setEnabled(false)
	spiStep:setEnabled(false)
	--palette.changeSquare()

	-- Saving gooi:
	sliderSave = gooi.newSlider(0, 50, 50, 600, 30):setGroup("saving")
	btnCancelSave = gooi.newButton("Cancel", width() - 220, height() - 40, 100, 30):setGroup("saving"):bg("#ff000088")
	btnConfirmSave = gooi.newButton("Save", width() - 110, height() - 40, 100, 30):setGroup("saving")
	lblName = gooi.newLabel("Name:", width() - 540, height() - 40, 100, 30):setGroup("saving")
	textName = gooi.newText("new.png", width() - 430, height() - 40, 200, 30):setGroup("saving")

	-- New animation gooi:
	gooi.newLabel              ("Width:", 420, 440, 120, 30):setGroup("new")
	gooi.newLabel              ("Height:",420, 480, 120, 30):setGroup("new")
	lblFrameNum = gooi.newLabel("Frames", 420, 520, 120, 30):setGroup("new")
	spiNewW =      gooi.newSpinner(1, 32, 16, 540, 440, 120, 30):setGroup("new")
	spiNewH =      gooi.newSpinner(1, 32, 16, 540, 480, 120, 30):setGroup("new")
	spiFramesNum = gooi.newSpinner(1, 50, 10, 540, 520, 120, 30):setGroup("new")
	--textNameNew = gooi.newText("", width() - 450, height() - 40, 220, 30):setGroup("new")
	btnCancelNew = gooi.newButton("Cancel", width() - 220, height() - 40, 100, 30):setGroup("new"):bg("#ff000088")
	btnOkNew = gooi.newButton("OK", width() - 110, height() - 40, 100, 30):setGroup("new")

	--gooi.get("btnCancelNew").bgColor = {255, 0, 0, 127}

	-- Options gooi:
	
	radTheme1 = gooi.newRadio("Theme 1", "grpTheme", 50, 50, 150, 30):setGroup("options")
	radTheme2 = gooi.newRadio("Theme 2", "grpTheme", 50, 90, 150, 30):setGroup("options"):select()
	radTheme3 = gooi.newRadio("Theme 3", "grpTheme", 50, 130, 150, 30):setGroup("options")

	btnReturn = gooi.newButton("Return", width() - 110, height() - 40, 100, 30):setGroup("options")

	radBg1 = gooi.newRadio("Background 1", "grpBG", 220, 50, 200, 30):setGroup("options"):select()
	radBg2 = gooi.newRadio("Background 2", "grpBG", 220, 90, 200, 30):setGroup("options")
	radBg3 = gooi.newRadio("Background 3", "grpBG", 220, 130, 200, 30):setGroup("options")
	
	chbAutosave = gooi.newCheck("Save animation when playing", 50, 170, 370, 30):setGroup("options"):change()
	
	-- Open gooi:
	btnOpenThis = gooi.newButton("Open this", width() - 110, height() - 40, 100, 30):setGroup("opening")
	btnCancelOpen = gooi.newButton("Cancel", width() - 220, height() - 40, 100, 30):setGroup("opening"):bg("#ff000088")
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
		btnAA:setEnabled(chbAA.checked)
		chbCyclic:setEnabled(chbAA.checked)
		spiStep:setEnabled(chbAA.checked)
	end
	local function returnFromOpening()
		gooi.setGroupEnabled("open", false)
		gooi.setGroupEnabled("new", false)
		gooi.setGroupEnabled("options", false)
		gooi.setGroupEnabled("editing", true)
		btnAA:setEnabled(chbAA.checked)
		chbCyclic:setEnabled(chbAA.checked)
		checkAutoAnim()
		state = STATE_EDITING
	end
	function playOrStop(c)
		playing = not playing
		c:bg({0, 255, 0, 127})
		c.icon = imgRight
		currentFrameIndex = 1
		analAnim:reset()
		if playing then
			analAnim:play()
			c:bg({255, 0, 0, 127})
			c.icon = imgStop
		end
	end
	function callSave(c)
		gooi.setGroupEnabled("saving", true)
		gooi.setGroupVisible("saving", true)
		gooi.setGroupEnabled("editing", false)
		state = STATE_SAVING
	end
	function performSave(c)
		--print(finalW, finalH)
		imgAnalAnim, info = animManager.saveAnimation(textName.text, frames, finalW, finalH)
		local millis = sliSpeed.value
		analAnim = newAnimation(imgAnalAnim, info.fW, info.fH, millis, #frames)
		gooi.setGroupEnabled("saving", false)
		gooi.setGroupEnabled("editing", true)
		checkAutoAnim()
		btnSave:setEnabled(false)
		animSaved = true
		savedOnce = true
		state = STATE_EDITING
	end
	function setFillMode4(c)
		fillMode = "4"
		c:bg({255, 127, 0, 127})
		c.icon = imgFill4
	end
	function setFillMode8(c)
		fillMode = "8"
		c:bg({255, 255, 0, 127})
		c.icon = imgFill8
	end
	function setNoFillMode(c)
		fillMode = nil
		c:bg({127, 127, 127, 127})
		c.icon = imgFill
	end
	btnCopyL:onRelease(function(c) copyPrevious() end)
	btnCopyR:onRelease(function(c) copyNext() end)
	btnPrev:onRelease(function(c)  frameLeft() end)
	btnNext:onRelease(function(c)  frameRight() end)
	btnPlay:onRelease(function(c)
		playOrStop(c)
		--print(tostring(chbAutosave.checked))
		if chbAutosave.checked then
			--if animSaved then
				performSave()
			--end
		end
	end)
	chbLoop:onRelease(function(c)
		analAnim.mode = 1
		if not c.checked then
			analAnim.mode = 2
		end
	end)
	btnSave:onRelease(function(c)
		if savedOnce then
			performSave(c)
		else
			callSave(c)
		end
	end)
	btnSaveAs:onRelease(function(c)
		callSave(c)
	end)
	btnDel:onRelease(function(c)
		deleteFrame()
		notifyNotSaved()
	end)
	btnAdd:onRelease(function(c)
		addNewFrame()
		notifyNotSaved()
	end)
	btnNew:onRelease(function(c)
		gooi.setGroupEnabled("new", true)
		gooi.setGroupEnabled("saving", true)
		gooi.setGroupEnabled("editing", false)
		lblName:setVisible(false)
		textName:setVisible(false)
		btnCancelSave:setVisible(false)
		btnConfirmSave:setVisible(false)
		state = STATE_NEW
	end)
	btnOpen:onRelease(function(c)
		gooi.setGroupEnabled("editing", false)
		gooi.setGroupEnabled("opening", true)
		availableAnims = animManager.loadAvailable()
		btnOpenThis:setEnabled(not (#availableAnims == 0))
		state = STATE_OPENING
	end)
	btnCancelSave:onRelease(function(c)
		gooi.setGroupEnabled("saving", false)
		gooi.setGroupEnabled("editing", true)
		checkAutoAnim()
		state = STATE_EDITING
	end)
	btnCancelOpen:onRelease(function(c)
		returnFromOpening()
	end)
	btnOpenThis:onRelease(function(c)
		setOpenedAnim()
		returnFromOpening()
	end)
	btnConfirmSave:onRelease(function(c)
		performSave(c)
	end)
	-- Mirrors:
	btnMX:onRelease(function(c)
		mirrorX = not mirrorX
		c:bg({127, 127, 127, 127})
		if mirrorX then
			c:bg({0, 255, 0, 127})
		end
	end)
	btnMY:onRelease(function(c)
		mirrorY = not mirrorY
		c:bg({127, 127, 127, 127})
		if mirrorY then
			c:bg({0, 255, 0, 127})
		end
	end)
	btnCancelNew:onRelease(function(c)
		gooi.setGroupEnabled("new", false)
		gooi.setGroupEnabled("saving", false)
		gooi.setGroupEnabled("editing", true)
		checkAutoAnim()
		state = STATE_EDITING
	end)
	btnOkNew:onRelease(function(c)
		setNewAnim(spiFramesNum.value, spiNewW.value, spiNewH.value)
		checkAutoAnim()
		state = STATE_EDITING
		savedOnce = false
	end)
	btnAA:onRelease(function(c)
		local sense = 1

		if shiftDown() then sense = -1 end
		aaRotation = aaRotation + 45 * sense
		aaDirection = aaDirection + 1 * sense
		if aaRotation >= 360 then aaRotation = 0 end
		if aaDirection > 8 then aaDirection = 1 end
		if aaDirection < 1 then aaDirection = 8 end
	end)
	chbAA:onRelease(function(c)
		checkAutoAnim()
	end)
	btnReturn:onRelease(function(c)
		gooi.setGroupEnabled("options", false)
		gooi.setGroupEnabled("editing", true)
		checkAutoAnim()
		state = STATE_EDITING
	end)
	btnFill:onRelease(function(c)
		if not fillMode then
			setFillMode4(c)
		elseif fillMode == "4" then
			setFillMode8(c)
		elseif fillMode == "8" then
			setNoFillMode(c)
		end
	end)
	--[[
	btnChangePalette:onRelease(function(c)
		palette.change()
		c.label = "Palette "..palette.which
		brush.color = palette.getColor(palette.xColor, palette.yColor)
		c:bg({r(), r(), r(), 127})
	end)
	]]
	btnOptions:onRelease(function(c)
		gooi.setGroupEnabled("editing", false)
		gooi.setGroupEnabled("options", true)
		state = STATE_OPTIONS
	end)
	--btnQuit:onRelease(function(c) exit() end)

	-- Load first "ctrl+z" state:
	table.insert(states, {
		frame = copyCurrent()
	})

	btnSave:setEnabled(false)
	gooi.desktopMode()
end






---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- love.update()
---------------------------------------------------------------------------
---------------------------------------------------------------------------

function love.update(dt)
	gooi.update(dt)

	if state == STATE_EDITING then
		if mo.isDown(MOUSE_LEFT) and not gooi.showingDialog then
			setPixel(mo.getX(), mo.getY(), brush.color, true)
			updateAnchor(mo.getPosition())
		end
		spinAlpha:bg(brush.color)
		local a = math.floor(spinAlpha.value)
		spinAlpha.bgColor[4] = a
		--lblInd.text = tostring(a)

		lblCopySD:setVisible(btnCopyCB:overIt())

		local btn = btnSave
		btn.image = imgSave
		if shiftDown() then
			btn.image = imgSaveAs
		end

		if just_copied then
			timerCopied = timerCopied + dt
			if timerCopied >= 1 then
				timerCopied = 0
				just_copied = false
				btnCopyCB:setText("Copy SD"):bg(component.style.bgColor)
			end
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
		if mo.isDown(MOUSE_MIDDLE) and not gooi.showingDialog then
			xCanvas = mo.getX() - dispCX
			yCanvas = mo.getY() - dispCY
		end
		-- Update analAnim:
		if playing then
			analAnim:update(dt)
			currentFrameIndex = analAnim.position
			if not analAnim.playing then
				playOrStop(btnPlay)
			end
		end
		-- Animation:
		analAnim:setFramesDelay(sliSpeed.value)
		lblSpeed:setText(string.sub(tostring(sliSpeed.value), 0, 4))
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
	if radTheme1.selected  then
		gr.setBackgroundColor(bgC1)
		gr.draw(bgDude1, 135, height() - bgDude1:getHeight() * 30, 0, 30, 30)
	elseif radTheme2.selected  then
		gr.setBackgroundColor(bgC2)
		gr.draw(bgDude2, 400, 200, 0, 20, 20)
	elseif radTheme3.selected  then
		gr.setBackgroundColor(bgC3)
		gr.draw(bgDude3, width() - bgDude3:getWidth() * 16, 0, 0, 16, 16)
	end
	if v then gr.print("file saved", 10, 70) end
	if state == STATE_EDITING then

		drawCurrentFrame()

		-- Grid:
		if chbGrid.checked then
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
		--gr.rectangle("line", p.x - 1, p.y - 1, p.w() + 2, p.h() + 2)
		
		-- Toolbar margin:
		gr.setColor(0, 0, 0, 180)
		gr.rectangle("fill", 0, 0, width(), tbUpLimit)
		gr.rectangle("fill", 0, tbUpLimit, tbLeftLimit, height() - tbUpLimit)

		-- Contrast images:
		gr.setColor(255, 255, 255)
		gr.draw(imgContrast, spinAlpha.x, spinAlpha.y)

		gr.draw(imgContrastSmall, 106, 6)
		gr.draw(imgContrastSmall, 141, 6)

		gr.draw(imgContrastSmall, 106, 29)
		gr.draw(imgContrastSmall, 141, 29)

		gr.draw(imgContrastSmall, 106, 52)
		gr.draw(imgContrastSmall, 141, 52)

		gr.setColor(6, 96, 128)

		-- Palette:
		gr.setColor(255, 255, 255)
		gr.draw(p.img(), p.x, p.y, 0, p.scale(), p.scale())
		-- Little indicator:
		gr.setLineStyle("rough")
		gr.setColor(colorIndicator)
		gr.rectangle("line", p.xColor, p.yColor, p.scale(), p.scale())
		gr.setLineStyle("smooth")
		-- Autoanimation:
		local btn = btnAA
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

		-- Frame indicator:
		prevFont = gr.getFont()
		gr.setFont(fontLetter)
		local wFontLetter = fontLetter:getWidth(""..currentFrameIndex) + 10
		local hFontLetter = fontLetter:getHeight()

		gr.setColor(255, 255, 255)
		gr.print(currentFrameIndex.."/"..#frames, 10, height() - hFontLetter)
	
		gr.setFont(prevFont)


		---------------------------------------------
		---------------------------------------------
		gooi.draw("editing")
		---------------------------------------------
		---------------------------------------------
		
		gr.setColor(255, 255, 255)
		if not chbAA.checked then
			gr.setColor(127, 127, 127)
		end
		gr.draw(imgAAArrow, btn.x + btn.w / 2, btn.y + btn.h / 2,
			math.rad(aaRotation), 1, 1, imgAAArrow:getWidth() / 2, imgAAArrow:getHeight() / 2)
		gr.setColor(255, 0, 0)

		-- Palette radios:
		gr.setColor(255, 255, 255)
		if gooi.showingDialog then
			gr.setColor(127, 127, 127)
		end
		gr.draw(imgPalette1, 460, 11, 0, 1, 1)
		gr.draw(imgPalette2, 460, 34, 0, 4, 4)
		gr.draw(imgPalette3, 460, 57, 0, 4, 4)
	
	elseif state == STATE_SAVING then
		gooi.draw("saving")
		drawMatrixFrame()
	elseif state == STATE_NEW then
		gooi.draw("saving")
		gooi.draw("new")
		drawMatrixFrame()
	elseif state == STATE_OPENING then
		gooi.draw("opening")
		gr.print("Your animations:", 10, 10)
		local prevFont = gr.getFont()
		gr.setFont(gooi.getFont())
		gr.setLineStyle("smooth")
		for i = 1, #availableAnims do
			local item = availableAnims[i]
			gr.setColor(12, 183, 242, 127)
			local w, h = 200, 25
			if item.selected then
				gr.rectangle("fill",
					item.x,
					item.y,
					w,
					h, 10, 10)
			end
			gr.rectangle("line",
				item.x,
				item.y,
				w,
				h, 10, 10)
			gr.setColor(255, 255, 255)
			gr.print(item.name,
				math.floor(item.x + w / 2 - gooi.getFont():getWidth(item.name) / 2),
				math.floor(item.y + h / 2 - gooi.getFont():getHeight() / 2))
		end
		gr.setFont(prevFont)
	elseif state == STATE_OPTIONS then
		gr.print("Select a theme:", radTheme1.x, 10)
		gr.print("Anim background:", radBg1.x, 10)
		gr.draw(sBgImage(), 450, 32)
		gooi.draw("options")
	end
	gr.setColor(255, 255, 255)
	--gr.print(aaDirection, 200,200)
	gr.setFont(debugFont)
	local fpsText = "FPS: "..love.timer.getFPS()
	gr.print(fpsText, width() - debugFont:getWidth(fpsText), height() - debugFont:getHeight())
	--gr.print("dispCX: "..dispCX..", dispCY: "..dispCY, 0, height() - debugFont:getHeight() * 2)
end


----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------


function drawCurrentFrame()
	gr.setLineWidth(1)
	gr.setCanvas(bgC)
	gr.clear(0, 0, 0, 1)
	-- Draw background for the canvas:
	gr.draw(
		sBgImage(),
		gr.newQuad(
			xCanvas,
			yCanvas,
			w * pS,
			h * pS,
			sBgImage():getWidth(),
			sBgImage():getHeight()
		)
	)
	
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
	if radBg1.selected then return bgImage1 end
	if radBg2.selected then return bgImage2 end
	if radBg3.selected then return bgImage3 end
end

function drawMatrixFrame()
	-- Draw matrix of frames:
	local theW, theH = w, h
	local theFNumber = #frames

	if state == STATE_NEW then
		theW, theH = spiNewW.value, spiNewH.value
		theFNumber = spiFramesNum.value
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
	local s = sliderSave
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
	frames, imgAnalAnim, info, finalW, finalH = animManager.openAnimation(animManager.getSelectedItem().name)
	loadFrames(frames, imgAnalAnim, info)
	setBoundsPixel()
	setBoundsCanvas()
	analAnim.mode = 1
	if not chbLoop.checked then
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
		local millis = sliSpeed.value
		analAnim = newAnimation(img, info.fW, info.fH, millis, info.frameNum)
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

		flood(fixedX, fixedY, cF, cF[fixedY][fixedX].color, brush.color)
		cF[fixedY][fixedX]:setColor(c)

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
			--print(x, y)
			
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
	if chbAA.checked then
		local dx, dy = fixedX, fixedY -- Displacements.
		local s = spiStep.value
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
			if chbCyclic.checked then
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
	btnSave:setEnabled(true)
	animSaved = false
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
	xCanvas = math.floor(xCenter - xHalf + tbLeftLimit / 2)
	yCanvas = math.floor(yCenter - yHalf + tbUpLimit / 2)
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
	pS = 16

	if pS < minPS then pS = minPS end
	if pS > maxPS then pS = maxPS end
	
	tbUpLimit = 75
	tbLeftLimit = 105
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
		notifyNotSaved()
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
		notifyNotSaved()
	end
end

function copyCurrent()
	local f = frames[currentFrameIndex]
	local newFrame = animManager.newFrame(w, h)

	for i = 1, #f do
		newFrame[i] = {}
		for j = 1, #f[i] do
			newFrame[i][j] = pixel.new(0, 0, 0, 0, j, i)
			newFrame[i][j]:setColor(f[i][j]:getColor())
		end
	end
	return newFrame
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
		notifyNotSaved()
	end
end

function addNewFrame()
	if shiftDown() then
		table.insert(frames, currentFrameIndex, animManager.newFrame(w, h))
	else
		table.insert(frames, animManager.newFrame(w, h))
	end
	notifyNotSaved()
end

function clearFrame(i)
	local f = frames[i]
	for i = 1, #f do
		for j = 1, #f[i] do
			f[i][j]:setColor(0, 0, 0, 0)
		end
	end
	notifyNotSaved()
end

function overAnItem(mx, my)
	local selected = nil
	local w, h = 200, 25
	for i = 1, #availableAnims do
		local item = availableAnims[i]
		if not (
			mx <= item.x - 5 or
			mx >= item.x + 200 + 10 or
			my <= item.y - 5 or
			my >= item.y + 25 + 10
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
		if not gooi.showingDialog then
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
		end
	elseif state == STATE_OPENING then
		if overAnItem(x, y) then
			
		end
	end
end

function love.mousereleased(x, y, button)
	gooi.released()
	palette.pressed = false

	if insideCanvas(mo.getX(), mo.getY()) then
		saveState()
	end
end

-------------------------------------------------
function love.threaderror(thread, errorstr)
  error("Thread error!\n"..errorstr)
end
-------------------------------------------------

function love.textinput(text) gooi.textinput(text) end

function love.keypressed(key)
	gooi.keypressed(key)
	if state == STATE_EDITING then
		-- Fill mode:
		if key == "b" then
			setFillMode4(btnFill)
			if ctrlDown() then
				setFillMode8(btnFill)
			end
		elseif kb.isDown("b") then
			if isCtrl(key) then
				setFillMode8(btnFill)
			end
		elseif key == "z" then
			if ctrlDown() then
				loadPrevState()
			end
		elseif key == "y" then
			if ctrlDown() then
				loadNextState()
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
				chbGrid:change()
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
				--btnChangePalette.label = "Palette "..palette.which
			end
		end
	end
end

function love.keyreleased(key)
	if isCtrl(key) then
		if kb.isDown("b") then
			setFillMode4(btnFill)
		else
			setNoFillMode(btnFill)
		end
	end
	if key == "b" then
		setNoFillMode(btnFill)
	end
end

function updateAnchor(x, y)
	if insideCanvas(x, y) then
		lineAnchor = {getFixedPosition(x, y)}
	end
end

function love.resize(w, h)
	btnOkNew:setBounds(width() - 110, height() - 40, 100, 30)
	--textNameNew:setBounds(width() - 450, height() - 40, 220, 30)
	btnCancelNew:setBounds(width() - 220, height() - 40, 100, 30)

	btnOpenThis:setBounds(width() - 110, height() - 40, 100, 30)
	btnCancelOpen:setBounds(width() - 220, height() - 40, 100, 30);

	btnCancelSave:setBounds(width() - 220, height() - 40, 100, 30)
	btnConfirmSave:setBounds(width() - 110, height() - 40, 100, 30)
	lblName:setBounds(width() - 540, height() - 40, 100, 30)
	textName:setBounds(width() - 430, height() - 40, 200, 30)

	lblCopySD:setBounds(230, height() - 30, width() - 235, 25)

	btnReturn:setBounds(width() - 110, height() - 40, 100, 30)

	setBoundsCanvas()
end

function love.quit()
	if not animSaved then
		gooi.confirm("Save changes?", function()
			callSave(btnSaveAs)
		end, function()
			animSaved = true
			exit()
		end)
		return true
	else
		return false
	end
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

-- For ctrl + Z:

function saveState()
	table.insert(states, {
		frame = copyCurrent()
	})
	indexStates = #states
	--print(#states)
end

function loadPrevState()
	indexStates = indexStates - 1;
	if indexStates < 1 then indexStates = 1 end

	frames[currentFrameIndex] = states[indexStates].frame
end

function loadNextState()
	indexStates = indexStates + 1;
	if indexStates > #states then indexStates = #states end

	frames[currentFrameIndex] = states[indexStates].frame
end

function r() return love.math.random(0, 255) end

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