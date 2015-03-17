

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