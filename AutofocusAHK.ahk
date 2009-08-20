#Persistent

; CapsLock should not be triggered when pressed
SetCapslockState AlwaysOff

; Timer for checking whether the Script was modified
SetTimer,UPDATEDSCRIPT,1000

LoadTasks()

; End of auto-execute section
Return

; Add a task with CapsLock+a
CapsLock & a::
	InputBox, NewTask, Add Task - AutofocusAHK,,,375,90
	if ErrorLevel != 1
		FileAppend, A%A_Now%%A_Tab%%NewTask%`n, %A_ScriptDir%\Tasks.txt
Return

CapsLock & s::
	ShowNextTasks()
Return

CapsLock & c::
	ShowCurrentTask()
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

; Load tasks from file Tasks.txt
LoadTasks()
{
	global
	TaskCount := 0
	Loop, read, %A_ScriptDir%\Tasks.txt
	{
		TaskCount := TaskCount + 1
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
			Tasks%TaskCount%_%A_Index% := A_LoopField
		}
	} 
	CurrentTask := TaskCount

}

; Show Next Tasks
ShowNextTasks()
{
	global
	Message := ""
	Count := 30
	If (TaskCount < 30)
	{
		Count := TaskCount
	}
	Loop %Count%
	{
		Message := Message . Tasks%A_Index%_2 . "`n"
	}
	MsgBox %Message%
}

;Show Current Task
ShowCurrentTask()
{
	global
	MsgBox % Tasks%CurrentTask%
}
