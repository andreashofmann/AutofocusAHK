; AutofocusAHK
;
; This file holds all functions specific to the Autofocus 2 system. 
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.2
; @since     0.9

AF2_IsReviewOptional()
{
    Return 1
}

AF2_IsValidTask(TaskName, TaskStats)
{
  global
	If (TaskName == "Change to review mode")
	{
		HasReviewModeTask := 1
		Return 1
	}
	If (TaskName == "Change to forward mode")
	{
		Return 0
	}
	If (TaskName == "---")
	{
		Return 0
	}	
	Return 1
}

AF2_PostTaskLoad()
{
  global
	CurrentTask := TaskCount + 1
	SelectNextTask()

}

AF2_PostTaskAdd()
{
}

AF2_SelectNextTask()
{
	global
	If (UnactionedCount > 0)
	{
		Loop
		{
			CurrentTask := CurrentTask - 1
			If (CurrentTask == 0)
			{
				CurrentTask := TaskCount
			}
			If (Tasks%CurrentTask%_4 == 0 or UnactionedCount == 0) 
			{
				Break
			}
		}
	}
}


AF2_Work()
{
	global
	
	If (CurrentMode == ReviewMode)
	{
		ShowReviewWindow()
	}
	Else If (Active == 1)
	{
		ShowDoneWindow()
	}
	Else
	{
		If (UnactionedCount <= 0)
		{
			MsgBox No unactioned tasks!
			Return
		}
		ShowWorkWindow()
	}
}

AF2_DoMorningRoutine()
{
		DismissTasks()
		PutTasksOnNotice()
}

AF2_DismissTasks()
{
	global
	Message := ""
	Loop %TaskCount%
	{
		If (Tasks%A_Index%_4 == 0 and InStr(Tasks%A_Index%_2, "N"))
		{
			Tasks%A_Index%_2 := Tasks%A_Index%_2 . " R" . A_Now
			Tasks%A_Index%_4 := 1
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
			Tasks%Taskcount%_3 := ""
			Tasks%Taskcount%_4 := 0
			HasReviewModeTask := 1
		}
	}
}

AF2_GetWorkWindowTitle()
{
	Title .= "Work" . GetStandardWindowTitle()
	Return Title
}

AF2_GetReviewWindowTitle()
{
	Title := "Review" . GetStandardWindowTitle()
	Return Title
}