defaults() {
	global
	SetMouseDelay, -1
	
	;;;;
	;;
	;;;;
	#MaxHotKeysPerInterval 200
	
	;;;;
	;;
	;;;;
	delimiter = `r`n
	;;;;
	;;
	;;;;
	blank = __
	
	;;;;
	;;
	;;;;
	resolution = 10
	;;;;
	;;
	;;;;
	inverted := true ? 1 : -1
	;;;;
	;;
	;;;;
	tolerance = 5
}
defaults()

;;;;
;; Sends a right click when win + left click is fired.
;;;;
#LButton::
	Send { RButton }
	return

;;;;
;; Scrolls the mouse wheel left when win + scroll up is fired.
;;;;
#WheelUp::
	Send { WheelLeft }
	return

;;;;
;; Scrolls the mouse wheel right when win + scroll down is fired.
;;;;
#WheelDown::
	Send { WheelRight }
	return

;;;;
;; Appends the hightlighted text to the clipboard, delimited by a delimiter.
;;;;
Insert::
	buffer = %clipboard%
	Send, ^c
	clipboard = %buffer%%delimiter%%clipboard%
	return

;;;;
;; Replaces the blank with the highlighted text.
;;;;
^Insert::
	buffer = %clipboard%
	Send, ^c
	StringReplace, clipboard, buffer, %blank%, %clipboard%
	Send, ^v
	clipboard = %buffer%
	return

;;;;
;; Pans the window when holding the middle mouse button and moving the mouse.
;;;;
MButton::
	MouseGetPos, xi, yi
	x0 := xi
	y0 := yi
	
	while (GetKeyState("MButton", "P")) {
		Sleep, %resolution%
		MouseGetPos, x1, y1
		previousX := horizontalMButton(x0, x1, previousX)
		previousY := verticalMButton(y0, y1, previousY)
	}
	
	MouseGetPos, xf, yf
	if (xf = xi and yf = yi) {
		Click, Middle
	}
	return	

;;;;
;; Helper function that handles horizontal scrolls.
;;;;
horizontalMButton(byref x0, x1, previousX) {
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

;;;;
;; Helper function that handles vertical scrolls.
;;;;
verticalMButton(byref y0, y1, previousY) {
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
;; Moves cursor through text until either the beginning of a word or the end of a word.
;;;;
^Right::
	buffer := clipboard
	previous := clipboard
	Send ^+{ Right }
	
	while (!word() and previous != clipboard) {
		previous := clipboard
		Send, ^+{ Right }
	}
	Send { Right }
	clipboard := buffer
	return

;;;;
;;
;;;;
+^Right::
	buffer := clipboard
	previous := clipboard
	Send ^+{ Right }

	while (!wordEnd() and previous != clipboard) {
		previous := clipboard
		Send, ^+{ Right }
	}
	clipboard := buffer
	return

;;;;
;;
;;;;
^Left::
	buffer := clipboard
	previous := clipboard
	Send ^+{ Left }
	
	while (!word() and previous != clipboard) {
		previous := clipboard
		Send, ^+{ Left }
	}
	Send { Left }
	clipboard := buffer
	return

;;;;
;;
;;;;
+^Left::
	buffer := clipboard
	previous := clipboard
	Send ^+{ Left }

	while (word() != 1 and previous != clipboard) {
		previous := clipboard
		Send, ^+{ Left }
	}
	clipboard := buffer
	return

; how to handle when text is already highlighted
; how to handle ctrl up and down

; ideally, would scroll by paragraphs
; paragraph is a new line
; search for consecutive new line char

; control up - hit up arow x times

; work out edge cases, what if reach the end or the beginning of a line

word() {
	clipboard = 
	Send, ^c
	ClipWait
	return RegExMatch(clipboard, "[a-zA-Z0-9]")
}

wordEnd() {
	clipboard = 
	Send, ^c
	ClipWait
	return RegExMatch(clipboard, "[a-zA-Z0-9]$")
}

paragraph() {
	return RegExMatch(clipboard, %delimiter%%delimiter%)
}

;ListVars
;Pause