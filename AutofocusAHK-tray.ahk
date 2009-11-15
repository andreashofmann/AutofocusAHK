; AutofocusAHK
;
; Sets up the menu you get if you right-click the tray icon.
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9
; @since     0.9

SetupTrayMenu()
{
	;; MENU CONSTRUCTION

	; Remove AutoHotkey standard menu items
	menu, tray, NoStandard

	; Add About/Help menu item
	menu, tray, add, About/Help

	; Add a separator
	menu, tray, add 

	; Add Exit menu item
	menu, tray, add, Exit

	; Make About/Help the default (if tray icon is double-clicked)
	menu, tray, default, About/Help
}

About/Help:
MsgBox, ,About/Help - %System% - AutofocusAHK %Ver%, CapsLock + a%A_Tab%Add task`nCapsLock + s%A_Tab%Show next tasks`nCapsLock + d%A_Tab%Start/Stop work`nCapsLock + 1%A_Tab%Toggle autostart`n`nAutofocus Time Management System`nCopyright (C) 2009 Mark Forster`nhttp://markforster.net`n`nAutofocusAHK`nCopyright (C) 2009 Andreas Hofmann`nhttp://andreashofmann.net
Return

Exit:
ExitApp, 0
Return
