AF4_IsValidTask(TaskName, TaskStats)
{
  global
	If (TaskName == "Change to review mode")
	{
		Return 0
	}
	If (TaskName == "Change to forward mode")
	{
	Return 0
	}
	If (TaskName == "---")
	{
	  HasClosedList := 1
    LastTaskInClosedList := TaskCount
		Return 0
	}	
	Return 1
}

AF4_PostTaskLoad()
{
  global
	If (TaskCount >= TasksPerPage and HasClosedList == 0)
	{
	  HasClosedList := 1
    LastTaskInClosedList := TaskCount
		SaveTasks()
	}
  CurrentPass := 1  
	ActionOnCurrentPass := 0
	CurrentTask := 0
	SelectNextTask()
}

AF4_SelectNextTask()
{
	global
	If (UnactionedCount > 0)
	{
			Start := CurrentTask
			Loop
			{
   			CurrentTask := CurrentTask + 1
				If (HasClosedList and CurrentTask == LastTaskInClosedList+1)
				{
					If (ActionOnCurrentPass)
					{
    				CurrentPass := CurrentPass + 1
						CurrentTask := FirstTaskOnPage
						ActionOnCurrentPass := 0
					}
					Else
					{
 						If (CurrentPass == 1)
						{
              AF4_DismissTasks()
							CurrentPass := 1
							ActionOnCurrentPass := 0
							SelectNextActivePage()
						}
						Else
						{
							CurrentPass := 1
							ActionOnCurrentPass := 0
						}
					}
				}
				If (CurrentTask > TaskCount)
				{
						CurrentTask := 1
        }
				If (Tasks%CurrentTask%_3 == 0 or UnactionedCount == 0) 
				{
					Break
				}
			}
	}
}


AF4_Work()
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

SetBacklogStats()
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

AF4_DoMorningRoutine()
{
		SaveTasks()
		BackupTasks()
}

AF4_DismissTasks()
{
	global
	Message := ""
	Loop
	{
	  If (A_Index > LastTaskInClosedList)
	  {
      Break
    }
		If (Tasks%A_Index%_3 == 0)
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
	}
	LastTaskInClosedList := TaskCount
	SaveTasks()
}

AF4_GetWorkWindowTitle()
{
	global CurrentMode,OpenListMode,CurrentPass,ActionOnCurrentPass
	If (CurrentMode == OpenListMode)
	{
		Title := "Open List"
	}
	Else                                     
	{
		Title := "Pass " . CurrentPass
    If (ActionOnCurrentPass == 0)
    {
      Title .= "(!)"                                    D
    }
  }
	Title .= " - Closed List" . GetStandardWindowTitle()
	Return Title
}

AF4_GetReviewWindowTitle()
{
	Title := "Review"
	Title .= GetStandardWindowTitle()
	Return Title
}