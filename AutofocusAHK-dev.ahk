#Persistent
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Timer for checking whether the Script was modified
SetTimer,UPDATEDSCRIPT,1000
Run,  autohotkey.exe %A_ScriptDir%\AutofocusAHK.ahk,  %A_ScriptDir%,,AhkPID

; If the Script was modified, reload it
UPDATEDSCRIPT:
	FileGetAttrib,attribs,%A_ScriptDir%\AutofocusAHK.ahk
	IfInString,attribs,A
	{
		FileSetAttrib,-A,%A_ScriptDir%\AutofocusAHK.ahk
		Process, Close, %AhkPID%
		Run,  autohotkey.exe %A_ScriptDir%\AutofocusAHK.ahk,  %A_ScriptDir%,,AhkPID
	}
Return 

