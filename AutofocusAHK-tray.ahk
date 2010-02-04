; AutofocusAHK
;
; Sets up the menu you get if you right-click the tray icon.
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.3.1
; @since     0.9

SetupTrayMenu()
{
	;; MENU CONSTRUCTION

	; Remove AutoHotkey standard menu items
	menu, tray, NoStandard

	menu, tray, add, Add Task, AddTask
	menu, tray, add, Show Next Tasks, ShowNextTasks
	menu, tray, add, Work

	; Add a separator
	menu, tray, add 

	menu, tray, add, Preferences

	; Add About/Help menu item
	menu, tray, add, About/Help, About

	; Add a separator
	menu, tray, add 

	; Add Exit menu item
	menu, tray, add, Exit

	; Make Add Task the default (if tray icon is double-clicked)
	menu, tray, default, About/Help
}


AddTask:
		AddTask()
Return

ShowNextTasks:
  ShowNextTasks()
Return

Work:
  Work()
Return

About:
  MsgBox, ,%ApplicationName% %Ver%, CapsLock + a%A_Tab%Add task`nCapsLock + s%A_Tab%Show next tasks`nCapsLock + d%A_Tab%Start/Stop work`nCapsLock + e%A_Tab%Create HTML Export`nCapsLock + p%A_Tab%Show preferences`nCapsLock + r%A_Tab%Reload tasks list`nCapsLock + q%A_Tab%Quit application`n`nAutofocus Time Management System`nCopyright (C) 2009 Mark Forster`nhttp://markforster.net`n`n%ApplicationName%`nCopyright (C) 2009 Andreas Hofmann`nhttp://andreashofmann.net
Return

Preferences:
  ShowPreferences()
Return

Exit:
  ExitApp, 0
Return
