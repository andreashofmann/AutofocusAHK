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
	AddTask()
Return

CapsLock & s::
	ShowNextTasks()
Return

CapsLock & c::
	ShowCurrentTask()
Return

CapsLock & x::
	SaveTasks()
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

; Save tasks to file Tasks.txt
SaveTasks()
{
	global TaskCount
	Content := ""
	Loop %TaskCount%
	{
		Content := Content . Tasks%A_Index%_1 . A_Tab . Tasks%A_Index%_2 . "`n"
	}
	FileDelete, %A_ScriptDir%\Tasks.txt
	FileAppend, %Content%, %A_ScriptDir%\Tasks.txt
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
	MsgBox % Tasks%CurrentTask%_2
}

;Add a New Task
AddTask()
{
	global
	InputBox, NewTask, Add Task - AutofocusAHK,,,375,90
	If (ErrorLevel != 1)
	{
		TaskCount := TaskCount + 1
		Tasks%Taskcount%_1 := "A" . A_Now
		Tasks%Taskcount%_2 := NewTask
		SaveTasks()
	}
}