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
	frequency = 100
	period := 1000 / frequency
	inverted := true ? 1 : -1
	speed = 1.0
	tolerance = 25
}
Init()

;;;;
;; Navigation commands.
;;;;
#LAlt::
	Click Down Left
	KeyWait, LAlt
	Click Up Left
	return

#Space::
	Click Down Right
	KeyWait, Space
	Click Up Right
	return

#LButton::
	Click Down Right
	KeyWait, LButton
	Click Up Right
	return

#WheelUp::
	Click WheelLeft
	return

#WheelDown::
	Click WheelRight
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
	firstX = true
	firstY = true

	while (GetKeyState("MButton", "P")) {
		Sleep, %period%
		MouseGetPos, x1, y1
		firstX := HorizontalMButton(x0, x1, firstX)
		firstY := VerticalMButton(y0, y1, firstY)
	}

	MouseGetPos, xf, yf
	if (xf = xi and yf = yi) {
		Click, Middle
	}
	return

; Helper function that handles horizontal scrolls.
HorizontalMButton(byref x0, x1, firstX) {
	global
	deltaX := inverted * (x1 - x0)
	;deltaX := deltaX * speed
	if (firstX) {
		if (deltaX > tolerance) {
			deltaX := deltaX - tolerance
		}
		else if (deltaX < -tolerance) {
			deltaX := deltaX + tolerance
		}
		else {
			return true
		}
	}
	if (deltaX > 0) {
		Click, WheelLeft, , , %deltaX%
		x0 := x1
	}
	else if (deltaX < 0) {
		deltaX := -1 * deltaX
		Click, WheelRight, , , %deltaX%
		x0 := x1
	}
	return false
}

; Helper function that handles vertical scrolls.
VerticalMButton(byref y0, y1, firstY) {
	global
	deltaY := inverted * (y1 - y0)
	;deltaY := deltaY * speed
	if (firstY) {
		if (deltaY > tolerance) {
			deltaY := deltaY - tolerance
		}
		else if (deltaY < -tolerance) {
			deltaY := deltaY + tolerance
		}
		else {
			return true
		}
	}
	if (deltaY > 0) {
		Click, WheelUp, , , %deltaY%
		y0 := y1
	}
	else if (deltaY < 0) {
		deltaY := -1 * deltaY
		Click, WheelDown, , , %deltaY%
		y0 := y1
	}
	return false
}

;; need something for direction

;ListVars
;Pause