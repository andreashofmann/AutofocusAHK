; AutofocusAHK
;
; This file contains the initial values for global variables.
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.2
; @since     0.9

Initialize()
{
	global 
	
	; Version number that is displayed in GUI windows
	Ver := "0.9.2.1"

	; Is the user currently working on a task?
	Active := 0

	; The different Modi
	ReverseMode := 0
	ForwardMode := 1
	ReviewMode  := 2

	; Always start in Reverse Mode
	CurrentMode := ReverseMode
	PreviousMode := ReverseMode

	; Does a "change to review mode" task exist?
	HasReviewModeTask := 0

	; Does a "change to forward mode" task exist?
	HasForwardModeTask := 0
	
	; Does a closed list exist?
	HasClosedList := 0

	; Setup tray menu
	SetupTrayMenu()

	; Load configuration form AutofocusAHK.ini
	LoadConfig()

	; Load tasks from Tasks.txt
	LoadTasks()

	; Start the morning routine (if applicable)
	DoMorningRoutine()
}

Work()
{
	global System
	%System%_Work()
}

SelectNextTask()
{
	global System
	%System%_SelectNextTask()
}

ReAddTask()
{
	global
	TaskCount := TaskCount + 1
	UnactionedCount := UnactionedCount + 1
	GuiControlGet,RephraseBoxContent,,RephraseBox
	If (RephraseBoxContent)
	{
        Tasks%Taskcount%_1 := RephraseBoxContent ;Tasks%CurrentTask%_1
    }
    Else
    {
        Tasks%Taskcount%_1 := Tasks%CurrentTask%_1
    }
	Tasks%Taskcount%_2 := "A" . A_Now
	GuiControlGet,ShowNotesBoxContent,,ShowNotesBox
	If (ShowNotesBoxContent)
	{
        Tasks%Taskcount%_3 := ShowNotesBoxContent ;Tasks%CurrentTask%_3
	}
	Else
	{
        Tasks%Taskcount%_3 := Tasks%CurrentTask%_3
    }
    Tasks%Taskcount%_4 := 0
	MarkAsDone()
	%System%_PostTaskAdd()
}

MarkAsDone()
{
	global
	Tasks%CurrentTask%_2 := Tasks%CurrentTask%_2 . " D" . A_Now . " T" . TimePassed
	Tasks%CurrentTask%_4 := 1
	UnactionedCount := UnactionedCount - 1
	SaveTasks()
	If (System == "AF2" or (System == "AF3" and CurrentMode == ReverseMode))
	{
		CurrentTask := TaskCount + 1
	}
	SelectNextTask()
}

DoMorningRoutine()
{
	global
	if (((Now - LastRoutine) == 1 and (Hour - StartRoutineAt) >= 0) or (Now - LastRoutine) > 1)
	{
		%System%_DoMorningRoutine()
	}
	SaveTasks()
	BackupTasks()
	LastRoutine := Now
	IniWrite, %Now%, %A_ScriptDir%\AutofocusAHK.ini, ReviewMode, LastRoutine
	If (Tasks%CurrentTask%_4 == 1) 
	{
		SelectNextTask()
	}

}                                                         

DismissTasks()
{
	%System%_DismissTasks()
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
			If (Tasks%A_Index%_4 == 1)
			{
				Break
			}
			if (Tasks%A_Index%_1 != "Change to review mode" and Tasks%A_Index%_1 != "Change to forward mode")
			{
				Tasks%A_Index%_2 := Tasks%A_Index%_2 . " N"
				Message := Message . "- " . Tasks%A_Index%_1 . "`n"
			}
		}
		Else
		{
			If (Tasks%A_Index%_4 == 0 && Tasks%A_Index%_1 != "Change to review mode" and Tasks%A_Index%_1 != "Change to forward mode")
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
	ReviewTask := 0
	SelectNextReviewTask()
}

SelectNextActivePage()
{
	global
	If (UnactionedCount > 0)
	{
		Loop
		{
			If (Tasks%CurrentTask%_4 == 0)
			{
				Break
			}
			CurrentTask := CurrentTask +1
		}
		SetForwardModeStats()
		CurrentTask := FirstTaskOnPage - 1
	}
}

GetCurrentMetadata()
{
	global
	GetTaskMetadata(CurrentTask)
	CurrentDone := TaskDone
	CurrentReview := TaskReview
	CurrentAdded := TaskAdded
}

GetTaskMetadata(Task)
{
	global
	TaskDone := ""
	TaskReview := ""
	TaskAdded := ""
	Loop, Parse, Tasks%Task%_2, %A_Space%
	{
		If (InStr(A_LoopField, "D"))
		{
			TaskDone := SubStr(A_LoopField, 2)
			FormatTime, TaskDone, %TaskDone%, yyyy-MM-dd H:mm
		}
		If (InStr(A_LoopField, "R"))
		{
			TaskReview := SubStr(A_LoopField, 2)
			FormatTime, TaskReview, %TaskReview%, yyyy-MM-dd H:mm
		}
		If (InStr(A_LoopField, "A"))
		{
			TaskAdded := SubStr(A_LoopField, 2)
			FormatTime, TaskAdded, %TaskAdded%, yyyy-MM-dd H:mm
		}
	}
}

MorningRoutine:
	FormatTime, Now, , yyyyMMdd
	FormatTime, Hour, , H
	DoMorningRoutine()
Return

GetStandardWindowTitle()
{
	Global
	Title := " - " . System . " - AutofocusAHK " . Ver
	Return Title
}
