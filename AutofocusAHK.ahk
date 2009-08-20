#Persistent

; CapsLock should not be triggered when pressed
SetCapslockState AlwaysOff

; Timer for checking whether the Script was modified
SetTimer,UPDATEDSCRIPT,1000

; End of auto-execute section
Return

; Add a task with CapsLock+a
CapsLock & a::
	InputBox, OutputVar, Add Task - AutofocusAHK,,,375,90
	if ErrorLevel != 1
		FileAppend, A%A_Now% %OutputVar%`n, %A_ScriptDir%\Tasks.txt
Return

; If the Script was modified, reload it
UPDATEDSCRIPT:
	FileGetAttrib,attribs,%A_ScriptFullPath%
	IfInString,attribs,A
	{
		FileSetAttrib,-A,%A_ScriptFullPath%
		SplashTextOn,,,Updated AutofocusAHK,
		Sleep,500
		SplashTextOff
		Reload
	}
Return 