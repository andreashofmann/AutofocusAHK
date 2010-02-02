; AutofocusAHK
;
; This file holds all functions specific to the Autofocus 5 system. 
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.3
; @since     0.9.3

AF5_IsReviewOptional()
{
    Return 0
}

AF5_IsValidTask(TaskName, TaskStats)
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
	Return 0
	}	
	Return 1
}

AF5_PostTaskLoad()
{
  global
	If (TaskCount >= TasksPerPage and HasClosedList == 0)
	{
	  HasClosedList := 1
    LastTaskInClosedList := TaskCount
		SaveTasks()
	}
  If (CurrentTask == 0 or Tasks%CurrentTask%_3 == 4)
  {
  	SelectNextTask()
  }
}

AF5_PostTaskAdd()
{
  global
	If (TaskCount >= TasksPerPage and HasClosedList == 0)
	{
	  HasClosedList := 1
    LastTaskInClosedList := TaskCount
		SaveTasks()
	}
}

AF5_SelectNextTask()
{
	global
	If (UnactionedCount > 0)
	{
			Start := CurrentTask
			Loop
			{
      			CurrentTask := CurrentTask + 1
				If (CurrentTask > TaskCount)
				{
						CurrentTask := 0
        }
				If (Tasks%CurrentTask%_4 == 0 or UnactionedCount == 0) 
				{
					Break                          
				}
			}
	}
}


AF5_Work()
{
	global
    If (Active == 1)
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


AF5_DoMorningRoutine()
{
		SaveTasks()
		BackupTasks()
}

AF5_DismissTasks()
{
	global
	Message := ""
	Loop
	{
	  If (A_Index > LastTaskInClosedList)
	  {
      Break
    }
		If (Tasks%A_Index%_4 == 0)
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
	}
	LastTaskInClosedList := TaskCount
	SaveTasks()
}

AF5_GetWorkWindowTitle()
{
	global CurrentTask,LastTaskInClosedList,CurrentPass,ActionOnCurrentPass
	If (CurrentTask > LastTaskInClosedList)
	{
		Title := "Open List"
	}
	Else                                     
	{
		Title := "Pass " . CurrentPass
      If (ActionOnCurrentPass == 0)
      {
        Title .= "(!)"                                   
      }
      Title .= " - Closed List"
    }
	Title .= GetStandardWindowTitle()
	Return Title
}

AF5_GetReviewWindowTitle()
{
	Title := "Review"
	Title .= GetStandardWindowTitle()
	Return Title
}