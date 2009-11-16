AF3_IsValidTask(TaskName, TaskStats)
{
  global
	If (TaskName == "Change to review mode")
	{
		HasReviewModeTask := 1
		Return 1
	}
	If (TaskName == "Change to forward mode")
	{
		HasForwardModeTask := 1
		Return 1
	}
	If (TaskName == "---")
	{
		Return 0
	}	
	Return 1
}

AF3_PostTaskLoad()
{
  global
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


AF3_SelectNextTask()
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
					If (ActionOnCurrentPass or CreatingList)
					{
						CurrentTask := FirstTaskOnPage
						If (!CreatingList)
						{
							CurrentPass := CurrentPass + 1
							ActionOnCurrentPass := 0
						}
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


AF3_Work()
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

AF3_DoMorningRoutine()
{
		DismissTasks()
		PutTasksOnNotice()
}

AF3_DismissTasks()
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

AF3_GetWorkWindowTitle()
{
	Global CurrentMode, ForwardMode
	If (CurrentMode == ForwardMode)
	{
		Title := "Forward Mode"
	}
	Else
	{
		Title := "Reverse Mode"
	}
	Title .= GetStandardWindowTitle()
	Return Title
}

AF3_GetReviewWindowTitle()
{
	Title := "Review Mode"
	Title .= GetStandardWindowTitle()
	Return Title
}