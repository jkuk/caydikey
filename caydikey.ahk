;;;;
;; Global settings.
;;;;
Init() {
	global

	#NoEnv
	SetBatchLines, -1
	SetMouseDelay, -1
	SetKeyDelay, -1, -1
	ListLines, Off

	;;;;
	;; Variables for insert commands.
	;;;;
	blank = __
	newline = "\r\n"

	;;;;
	;; Variables for panning.
	;;;;
	resolution = 1
	inverted := true ? 1 : -1
	tolerance = 5
}
Init()

;;;;
;; Navigation commands.
;;;;
#LButton::
	SendInput { RButton }
	return

#WheelUp::
	SendInput { WheelLeft }
	return

#WheelDown::
	SendInput { WheelRight }
	return

#LAlt::
	SendInput { LButton Down }
	KeyWait, LAlt
	SendInput { LButton Up }
	return

RAlt::
	SendInput { RButton Down }
	KeyWait, RAlt
	SendInput { RButton }
	return

;;;;
;; Insert commands.
;;;;

; Appends the selected text to the clipboard, delimited by a newline.
Insert::
	buffer = %clipboard%
	clipboard = 
	SendInput, ^c
	ClipWait
	clipboard = %buffer%%newline%%clipboard%
	return

; Replaces the blank with the highlighted text.
^Insert::
	buffer = %clipboard%
	clipboard = 
	SendInput, ^c
	ClipWait
	StringReplace, clipboard, buffer, %blank%, %clipboard%
	SendInput, ^v
	clipboard = %buffer%
	return

;;;;
;; Panning commands.
;;;

; Pans the window when holding the middle mouse button and moving the mouse.
MButton::
	MouseGetPos, xi, yi
	x0 := xi
	y0 := yi

	while (GetKeyState("MButton", "P")) {
		Sleep, %resolution%
		MouseGetPos, x1, y1
		previousX := HorizontalMButton(x0, x1, previousX)
		previousY := VerticalMButton(y0, y1, previousY)
	}

	MouseGetPos, xf, yf
	if (xf = xi and yf = yi) {
		Click, Middle
	}
	return

; Helper function that handles horizontal scrolls.
HorizontalMButton(byref x0, x1, previousX) {
	global
	deltaX := inverted * (x1 - x0)
	if (deltaX >= tolerance and previousX >= tolerance) {
		Click, WheelLeft, , , %deltaX%
		x0 := x1
	}
	else if (deltaX <= -tolerance and previousX <= -tolerance) {
		deltaX := -1 * deltaX
		Click, WheelRight, , , %deltaX%
		x0 := x1
	}
	return deltaX
}

; Helper function that handles vertical scrolls.
VerticalMButton(byref y0, y1, previousY) {
	global
	deltaY := inverted * (y1 - y0)
	if (deltaY >= tolerance and previousY >= tolerance) {
		Click, WheelUp, , , %deltaY%
		y0 := y1
	}
	else if (deltaY <= -tolerance and previousY <= tolerance) {
		deltaY := -1 * deltaY
		Click, WheelDown, , , %deltaY%
		y0 := y1
	}
	return deltaY
}

;;;;
;; Text navigation commands.
;;;;

; Move the cursor to the end of a word.
^Right::
	SelectRight()
	SendInput { Right }
	return

; Select to the end of a word.
+^Right::
	SelectRight()
	return

;
SelectRight() {
	buffer := clipboard
	previous := clipboard
	SendInput ^+{ Right }

	while (!WordRight() and previous != clipboard) {
		previous := clipboard
		SendInput, ^+{ Right }
	}
	clipboard := buffer
	return
}

;
WordRight() {
	clipboard = 
	SendInput, ^c
	ClipWait
	if (NonWord(SubStr(clipboard, 0))) {
		return false
	}
	return true
}

;
^Left::
	SelectLeft()
	SendInput { Left }
	return

;
+^Left::
	SelectLeft()
	return

;
SelectLeft() {
	buffer := clipboard
	previous := clipboard
	SendInput ^+{ Left }

	while (!WordLeft() and previous != clipboard) {
		previous := clipboard
		SendInput, ^+{ Left }
	}
	clipboard := buffer
	return
}

;
WordLeft() {
	clipboard = 
	SendInput, ^c
	ClipWait
	if (NonWord(SubStr(clipboard, 1, 1))) {
		return false
	}
	return true
}

NonWord(char) {
	return RegExMatch(char, "\W")
}

;
^Up::
	SelectUp()
	SendInput { Home }
	SendInput { Down }
	SendInput { Home }
	return

+^Up::
	SelectUp()
	SendInput +{ Home }
	SendInput +{ Down }
	SendInput +{ Home }
	return

SelectUp() {
	buffer := clipboard
	previous := clipboard
	SendInput +{ Up }

	while (!BlockUp() and previous != clipboard) {
		previous := clipboard
		SendInput, +{ Up }
		SendInput, +{ End }
	}
	clipboard := buffer
	return
}

BlockUp() {
	clipboard = 
	SendInput, ^c
	ClipWait
	if (Block(SubStr(clipboard, 1, 4))) {
		return true
	}
	return false
}

;
^Down::
	SelectDown()
	SendInput { End }
	SendInput { Up }
	SendInput { End }
	return

+^Down::
	SelectDown()
	SendInput +{ End }
	SendInput +{ Up }
	SendInput +{ End }
	return

SelectDown() {
	buffer := clipboard
	previous := clipboard
	SendInput +{ Down }

	while (!BlockDown() and previous != clipboard) {
		previous := clipboard
		SendInput, +{ Down }
		SendInput, +{ Home }
	}
	clipboard := buffer
	return
}

BlockDown() {
	clipboard = 
	SendInput, ^c
	ClipWait
	if (Block(SubStr(clipboard, -3))) {
		return true
	}
	return false
}

Block(line) {
	return RegExMatch(line, "\r\n\r\n")
}

;; need something for direction

;ListVars
;Pause