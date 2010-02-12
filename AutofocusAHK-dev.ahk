; AutofocusAHK
;
; Start this script if you want to work on AutofocusAHK source in real-time.
; It monitors all source files and restarts the main script if it detects
; changes.
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.4.1
; @since     0.9

#Persistent
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Timer for checking whether the Script was modified
SetTimer,UPDATEDSCRIPT,1000
Run,  autohotkey.exe %A_ScriptDir%\AutofocusAHK.ahk,  %A_ScriptDir%,,AhkPID

; If the Script was modified, reload it
UPDATEDSCRIPT:
	allattribs := ""
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK.ahk
	allattribs .= attribs
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK-system.ahk
	allattribs .= attribs
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK-tray.ahk
	allattribs .= attribs
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK-triggers.ahk
	allattribs .= attribs
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK-files.ahk
	allattribs .= attribs
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK-gui.ahk
	allattribs .= attribs
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK-af1.ahk
	allattribs .= attribs
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK-af2.ahk
	allattribs .= attribs
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK-af3.ahk
	allattribs .= attribs
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK-af4.ahk
	allattribs .= attribs
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK-dwm.ahk
	allattribs .= attribs
	IfInString,allattribs,A
	{
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK.ahk
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK-system.ahk
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK-tray.ahk
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK-triggers.ahk
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK-files.ahk
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK-gui.ahk
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK-af1.ahk
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK-af2.ahk
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK-af3.ahk
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK-af4.ahk
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK-dwm.ahk
		Process, Close, %AhkPID%
		Run,  autohotkey.exe %A_ScriptDir%\AutofocusAHK.ahk,  %A_ScriptDir%,,AhkPID
	}
Return 

