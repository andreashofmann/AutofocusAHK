#Persistent

; CapsLock should not be triggered when pressed
SetCapslockState AlwaysOff

; Timer for checking whether the Script was modified
SetTimer,UPDATEDSCRIPT,1000
SetTimer,MorningRoutine,300000

; Modi
ReverseMode := 0
ForwardMode := 1
ReviewMode  := 2

HasReviewModeTask := 0
HasForwardModeTask := 0
Ver := "0.6"

Test := "CapsLock & p"
Hotkey, %Test%, MyLabelForNotepad

menu, tray, NoStandard
menu, tray, add, About/Help
menu, tray, add 
menu, tray, add, Exit
menu, tray, default, About/Help

Active := 0
; Always start in Reverse Mode
LoadConfig()
SetMode(ReverseMode)
PreviousMode := ReverseMode
LoadTasks()
DoMorningRoutine()

; End of auto-execute section
Return

; Add a task with CapsLock+a
TriggerAddTask:
	AddTask()
Return

; Show next tasks with CapsLock+s
TriggerShowNextTasks:
	ShowNextTasks()
Return

; Show current task with CapsLock+c
TriggerShowCurrentTask:
	ShowCurrentTask()
Return

; Start working with CapsLock+d
TriggerWork:
	Work()
Return

TriggerToggleAutostart:
	ToggleStartup()
Return

TriggerShowOnNotice:
	ShowOnNotice()
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
	UnactionedCount := 0
	Loop, read, %A_ScriptDir%\Tasks.txt
	{
		TaskCount := TaskCount + 1
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
			Tasks%TaskCount%_%A_Index% := A_LoopField
		}
		If (InStr(Tasks%TaskCount%_2, "D") or InStr(Tasks%TaskCount%_2, "R"))
		{
			Tasks%TaskCount%_3 := 1
			If (!InStr(Tasks%TaskCount%_2, "D") and InStr(Tasks%TaskCount%_2, "R"))
			{
				HasTasksOnReview := 1
			}
		}
		Else
		{
			Tasks%TaskCount%_3 := 0
			UnactionedCount := UnactionedCount +1
			If (Tasks%TaskCount%_1 == "Change to review mode")
			{
				HasReviewModeTask := 1
			}
			If (Tasks%TaskCount%_1 == "Change to forward mode")
			{
				HasForwardModeTask := 1
			}
		}
	}
	If (TaskCount >= TasksPerPage * 3 and HasForwardModeTask == 0)
	{
			TaskCount := TaskCount + 1
			UnactionedCount := UnactionedCount + 1
			Tasks%Taskcount%_1 := "Change to forward mode"
			Tasks%Taskcount%_2 := "A" . A_Now
			Tasks%Taskcount%_3 := 0
			HasForwardModeTask := 1
			SaveTasks()
	}
	CurrentTask := TaskCount + 1
	SelectNextTask()
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
	If (UnactionedCount <= 0)
	{
		MsgBox No unactioned tasks!
		Return
	}

	Message := ""
	Count := 30
	If (TaskCount < 30)
	{
		Count := TaskCount
	}
	Loop %Count%
	{
		If (Tasks%A_Index%_3 == 0)
		{
			Message := Message . Tasks%A_Index%_1 . "`n"
		}
	}
	MsgBox,,AutofocusAHK %Ver%, %Message%
}

;Show Current Task
ShowCurrentTask()
{
	global
	If (UnactionedCount <= 0)
	{
		MsgBox No unactioned tasks!
		Return
	}
	
	MsgBox % Tasks%CurrentTask%_1
}

;Add a New Task
AddTask()
{
	global
	InputBox, NewTask, Add Task - AutofocusAHK %Ver%,,,375,90
	If (ErrorLevel != 1)
	{
		TaskCount := TaskCount + 1
		UnactionedCount := UnactionedCount + 1
		Tasks%Taskcount%_1 := NewTask
		Tasks%Taskcount%_2 := "A" . A_Now
		Tasks%Taskcount%_3 := 0
		SaveTasks()
	}
}

;Set the current mode
SetMode(Mode)
{
	global CurrentMode, ReverseMode, ForwardMode, ReviewMode
	CurrentMode := Mode
}

;Work
Work()
{
	global
	If (UnactionedCount <= 0)
	{
		MsgBox No unactioned tasks!
		Return
	}
	
	If (Active == 1)
	{
		MsgBox, 3, AutofocusAHK %Ver%, % "You were working on`n`n" . Tasks%CurrentTask%_1 . "`n`nDo you want to re-add this task?"
		IfMsgBox Yes
		{
			ReAddTask()
		}
		IfMsgBox No
		{
			MarkAsDone()
		}
		Active := 0
		If (CurrentMode == ForwardMode)
		{
			ActionOnCurrentPass := 1
		}
	}
	
	Loop
	{
		MsgBox, 3, AutofocusAHK %Ver%, % Tasks%CurrentTask%_1 . "`n`nDoes this task feel ready to be done?"
		IfMsgBox Yes
		{
			Active := 1
			If (Tasks%CurrentTask%_1 == "Change to review mode")
			{
				Active := 0
				PreviousMode := CurrentMode
				CurrentMode := ReviewMode
				DoReview()
			}
			Else If (Tasks%CurrentTask%_1 == "Change to forward mode")
			{
				MsgBox Change to forward mode!
				Active := 0
				CurrentMode := ForwardMode
				CurrentPass := 1
				ActionOnCurrentPass := 0
				Tasks%CurrentTask%_2 := Tasks%CurrentTask%_2 . " D" . A_Now
				Tasks%CurrentTask%_3 := 1
				UnactionedCount := UnactionedCount - 1
				SaveTasks()
				CurrentTask := 1
				SelectNextActivePage()
				SelectNextTask()
				Continue
			}
			Break
		}
		IfMsgBox No
		{
			SelectNextTask()
			Continue
		}
		IfMsgBox Cancel
		{
			Break
		}
	}
}

;Select Next Task
SelectNextTask()
{
	global
	If (UnactionedCount > 0)
	{
		If (CurrentMode == ReverseMode)
		{
			Loop
			{
				CurrentTask := CurrentTask - 1
				If (CurrentTask == 0)
				{
					CurrentTask := TaskCount
				}
				If (Tasks%CurrentTask%_3 == 0) 
				{
					Break
				}
			}
		}
		Else If (CurrentMode == ForwardMode)
		{
			Start := CurrentTask
			Loop
			{
				CurrentTask := CurrentTask + 1
				If (CurrentTask > LastTaskOnPage)
				{
					If (ActionOnCurrentPass)
					{
						CurrentTask := FirstTaskOnPage
						CurrentPass := CurrentPass + 1
						ActionOnCurrentPass := 0
					}
					Else
					{
						If (CurrentPass == 1)
						{
							CurrentMode := ReverseMode
							TaskCount := TaskCount + 1
							UnactionedCount := UnactionedCount + 1
							Tasks%Taskcount%_1 := "Change to forward mode"
							Tasks%Taskcount%_2 := "A" . A_Now
							Tasks%Taskcount%_3 := 0
							HasForwardModeTask := 1
							SaveTasks()
							CurrentTask := TaskCount + 1
							SelectNextTask()
							Break
						}
						Else
						{
							CurrentPass := 1
							ActionOnCurrentPass := 0
							SelectNextActivePage()
						}
					}
				}
				If (Tasks%CurrentTask%_3 == 0) 
				{
					Break
				}
			}
		}
	}
}

ReAddTask()
{
	global
	TaskCount := TaskCount + 1
	UnactionedCount := UnactionedCount + 1
	Tasks%Taskcount%_1 := Tasks%CurrentTask%_1
	Tasks%Taskcount%_2 := "A" . A_Now
	Tasks%Taskcount%_3 := 0
	MarkAsDone()
}

MarkAsDone()
{
	global
	Tasks%CurrentTask%_2 := Tasks%CurrentTask%_2 . " D" . A_Now
	Tasks%CurrentTask%_3 := 1
	UnactionedCount := UnactionedCount - 1
	SaveTasks()
	If (CurrentTask == ReverseMode)
	{
		CurrentTask := TaskCount + 1
	}
	SelectNextTask()
}

LoadConfig()
{
	global
	FormatTime, Now, , yyyyMMdd
	FormatTime, Hour, , H
	IniRead, StartWithWindows, %A_ScriptDir%\AutofocusAHK.ini, General, StartWithWindows
	If (StartWithWindows == "ERROR")
	{
		StartWithWindows := 0
		ToggleStartup()
	}
	IniRead, DoBackups, %A_ScriptDir%\AutofocusAHK.ini, General, DoBackups
	If (DoBackups == "ERROR")
	{
		DoBackups := 1
		IniWrite, %DoBackups%, %A_ScriptDir%\AutofocusAHK.ini, General, DoBackups
	}
	IniRead, BackupsToKeep, %A_ScriptDir%\AutofocusAHK.ini, General, BackupsToKeep
	If (BackupsToKeep == "ERROR")
	{
		BackupsToKeep := 10
		IniWrite, %BackupsToKeep%, %A_ScriptDir%\AutofocusAHK.ini, General, BackupsToKeep
	}
	IniRead, LastRoutine, %A_ScriptDir%\AutofocusAHK.ini, ReviewMode, LastRoutine
	If (LastRoutine == "ERROR")
	{
		LastRoutine := Now
		IniWrite, %LastRoutine%, %A_ScriptDir%\AutofocusAHK.ini, ReviewMode, LastRoutine
	}
	IniRead, StartRoutineAt, %A_ScriptDir%\AutofocusAHK.ini, ReviewMode, StartRoutineAt
	If (StartRoutineAt == "ERROR")
	{
		StartRoutineAt := 6
		IniWrite, %StartRoutineAt%, %A_ScriptDir%\AutofocusAHK.ini, ReviewMode, StartRoutineAt
	}
	IniRead, TasksPerPage, %A_ScriptDir%\AutofocusAHK.ini, ForwardMode, TasksPerPage
	If (TasksPerPage == "ERROR")
	{
		TasksPerPage := 20
		IniWrite, %TasksPerPage%, %A_ScriptDir%\AutofocusAHK.ini, ForwardMode, TasksPerPage
	}
	IniRead, HKAddTask, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKAddTask
	If (HKAddTask == "ERROR")
	{
		HKAddTask := "CapsLock & a"
		IniWrite, %HKAddTask%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKAddTask
	}
	Hotkey, %HKAddTask%, TriggerAddTask
	IniRead, HKWork, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKWork
	If (HKWork == "ERROR")
	{
		HKWork := "CapsLock & d"
		IniWrite, %HKWork%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKWork
	}
	Hotkey, %HKWork%, TriggerWork
	IniRead, HKShowNextTasks, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKShowNextTasks
	If (HKShowNextTasks == "ERROR")
	{
		HKShowNextTasks := "CapsLock & s"
		IniWrite, %HKShowNextTasks%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKShowNextTasks
	}
	Hotkey, %HKShowNextTasks%, TriggerShowNextTasks
	IniRead, HKShowCurrentTask, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKShowCurrentTask
	If (HKShowCurrentTask == "ERROR")
	{
		HKShowCurrentTask := "CapsLock & c"
		IniWrite, %HKShowCurrentTask%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKShowCurrentTask
	}
	Hotkey, %HKShowCurrentTask%, TriggerShowCurrentTask
	IniRead, HKShowOnNotice, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKShowOnNotice
	If (HKShowOnNotice == "ERROR")
	{
		HKShowOnNotice := "CapsLock & n"
		IniWrite, %HKShowOnNotice%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKShowOnNotice
	}
	Hotkey, %HKShowOnNotice%, TriggerShowOnNotice
	IniRead, HKToggleAutostart, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKToggleAutostart
	If (HKToggleAutostart == "ERROR")
	{
		HKToggleAutostart := "CapsLock & 1"
		IniWrite, %HKToggleAutostart%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKToggleAutostart
	}
	Hotkey, %HKToggleAutostart%, TriggerToggleAutostart

}

DoMorningRoutine()
{
	global
	if (((Now - LastRoutine) == 1 and (Hour - StartRoutineAt) >= 0) or (Now - LastRoutine) > 1)
	{
		DismissTasks()
		PutTasksOnNotice()
		SaveTasks()
		BackupTasks()
		LastRoutine := Now
		IniWrite, %Now%, %A_ScriptDir%\AutofocusAHK.ini, ReviewMode, LastRoutine
		If (Tasks%CurrentTask%_3 == 1) 
		{
			SelectNextTask()
		}
	}
}

DismissTasks()
{
	global
	Message := ""
	Loop %TaskCount%
	{
		If (Tasks%A_Index%_3 == 0 and InStr(Tasks%A_Index%_2, "N"))
		{
			Tasks%A_Index%_2 := Tasks%A_Index%_2 . " R" . A_Now
			Tasks%A_Index%_3 := 1
			UnactionedCount := UnactionedCount - 1
			Message := Message . "- " . Tasks%A_Index%_1 . "`n"
		}
	}
	If (Message != "")
	{
		MsgBox The following tasks are now on review:`n`n%Message%
		HasTasksOnReview := 1
		If (HasReviewModeTask == 0)
		{
			TaskCount := TaskCount + 1
			UnactionedCount := UnactionedCount + 1
			Tasks%Taskcount%_1 := "Change to review mode"
			Tasks%Taskcount%_2 := "A" . A_Now
			Tasks%Taskcount%_3 := 0
			HasReviewModeTask := 1
		}
	}
}

PutTasksOnNotice()
{
	global
	BlockStarted := 0
	Message := ""
	Loop %TaskCount%
	{
		If (BlockStarted)
		{
			If (Tasks%A_Index%_3 == 1)
			{
				Break
			}
			if (Tasks%A_Index%_1 != "Change to review mode")
			{
				Tasks%A_Index%_2 := Tasks%A_Index%_2 . " N"
				Message := Message . "- " . Tasks%A_Index%_1 . "`n"
			}
		}
		Else
		{
			If (Tasks%A_Index%_3 == 0 && Tasks%A_Index%_1 != "Change to review mode")
			{
				BlockStarted := 1
				Tasks%A_Index%_2 := Tasks%A_Index%_2 . " N"
				Message := Message . "- " . Tasks%A_Index%_1 . "`n"
			}
		}
	}
	If (Message != "")
	{
		MsgBox The following tasks are now on notice for review:`n`n%Message%
	}
}

DoReview()
{
	global
	ReviewComplete := 1
	Loop, %TaskCount%
	{
		If (Tasks%A_Index%_3 == 1 and !InStr(Tasks%A_Index%_2, "D") and InStr(Tasks%A_Index%_2, "R"))
		{
			MsgBox, 3, Review Mode - AutofocusAHK %Ver%, % Tasks%A_Index%_1 . "`n`nDo you want to re-add this task?"
			IfMsgBox Yes
			{
				Tasks%A_Index%_2 := Tasks%A_Index%_2 . " D" . A_Now
				Tasks%A_Index%_3 := 1

				TaskCount := TaskCount + 1
				UnactionedCount := UnactionedCount + 1
				Tasks%Taskcount%_1 := Tasks%A_Index%_1
				Tasks%Taskcount%_2 := "A" . A_Now
				Tasks%Taskcount%_3 := 0

			}
			IfMsgBox No
			{
				ReviewComplete := 0
			}
			IfMsgBox Cancel
			{
				ReviewComplete := 0
				Break
			}
		}
	}
	CurrentMode := PreviousMode
	If (!ReviewComplete)
	{
		ReAddTask()
	}
	Else
	{
		MarkAsDone()
	}
}

BackupTasks()
{
	global DoBackups, BackupsToKeep
	If (DoBackups)
	{
		If (!FileExist(A_ScriptDir . "\Backups"))
		{
			FileCreateDir, %A_ScriptDir%\Backups
		}
		FormatTime, BackupTime, , yyyy-MM-dd
		FileCopy, %A_ScriptDir%\Tasks.txt, %A_ScriptDir%\Backups\Tasks-%BackupTime%.txt
		
		Count := 0
		Loop, %A_ScriptDir%\Backups\*.*
		{
			Count := Count + 1
			FileList = %FileList%%A_LoopFileName%`n
			Sort, FileList
		}
		If (Count > BackupsToKeep)
		{
			FilesToDelete := Count - BackupsToKeep
			Count := 0
			Loop, parse, FileList, `n
			{
				if (A_LoopField == "")
				{
					Continue
				}
				Count := Count + 1
				If (Count > FilesToDelete)
				{
					Break
				}
				FileDelete, %A_ScriptDir%\Backups\%A_LoopField%
			}
		}
	}
}

ToggleStartup()
{
	If (StartWithWindows)
	{
		Message := "Autostart is currently enabled."
	}
	Else 
	{
		Message := "Autostart is currently disabled."
	}
	Message := Message . "`n`nDo you want AutofocusAHK to start with Windows in the future?"

	MsgBox, 4, AutofocusAHK %Ver%, %Message%
	IfMsgBox Yes
	{
		FileCreateShortcut, "%A_ScriptFullPath%", %A_Startup%\AutofocusAHK.lnk, %A_ScriptDir% 
		StartWithWindows := 1
		IniWrite, 1, %A_ScriptDir%\AutofocusAHK.ini, General, StartWithWindows
	}
	IfMsgBox No
	{
		FileDelete, %A_Startup%\AutofocusAHK.lnk
		StartWithWindows := 0
		IniWrite, 0, %A_ScriptDir%\AutofocusAHK.ini, General, StartWithWindows
	}
}

ShowOnNotice()
{
	global
	Message := ""
	Loop %TaskCount%
	{
		If (Tasks%A_Index%_3 == 0 and InStr(Tasks%A_Index%_2, "N"))
		{
			Message := Message . "- " . Tasks%A_Index%_1 . "`n"
		}
	}
	If (Message != "")
	{
		MsgBox The following tasks are on notice:`n`n%Message%
	}
	Else
	{
		MsgBox There are currently no tasks on notice.
	}
}

SetForwardModeStats()
{
	global
	CurrentPage := Ceil(CurrentTask/TasksPerPage)
	If (TaskCount < TasksPerPage)
	{
		LastTaskOnPage := TaskCount
		FirstTaskOnPage := 1
	}
	Else
	{
		LastTaskOnPage := CurrentPage * TasksPerPage
		FirstTaskOnPage := LastTaskOnPage - TasksPerPage + 1
		If (LastTaskOnPage > TaskCount)
		{
			LastTaskOnPage := TaskCount
		}
	}
}

SelectNextActivePage()
{
	global
	Loop
	{
		If (Tasks%CurrentTask%_3 == 0)
		{
			Break
		}
		CurrentTask := CurrentTask +1
	}
	SetForwardModeStats()
	CurrentTask := FirstTaskOnPage - 1
}

About/Help:
MsgBox, ,About/Help - AutofocusAHK %Ver%, CapsLock + a%A_Tab%Add task`nCapsLock + c%A_Tab%Show current task`nCapsLock + s%A_Tab%Show next tasks`nCapsLock + d%A_Tab%Start/Stop work`nCapsLock + 1%A_Tab%Toggle autostart`n`nAutofocus Time Management System`nCopyright (C) 2009 Mark Forster`nhttp://markforster.net`n`nAutofocusAHK`nCopyright (C) 2009 Andreas Hofmann`nhttp://andreashofmann.net
Return

Exit:
ExitApp, 0
Return

MorningRoutine:
	FormatTime, Now, , yyyyMMdd
	FormatTime, Hour, , H
	DoMorningRoutine()
Return

MyLabelForNotepad:
	MsgBox Jo!
Return