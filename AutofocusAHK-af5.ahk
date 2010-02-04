; AutofocusAHK
;
; This file holds all functions specific to the Autofocus 5 system. 
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.3.1
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
	
  If (ePos := InStr(TaskStats, "E"))
  {
    Expires := SubStr(TaskStats, ePos + 1, 8)
    
    FormatTime, Today, , yyyyMMdd
    
    If (Today > Expires)
    {
      ListOfExpiredTasks .= TaskName . "`n"
      Return 0
    }
  }
  Else
  {
    Return 0
  }  	
	Return 1
}

AF5_PostTaskLoad()
{
  global
  If (CurrentTask == 0 or Tasks%CurrentTask%_4 == 1)
  {
  	SelectNextTask()
  }
  
  If (ListOfExpiredTasks)
  {
    MsgBox, 0 , Expiration - AF5 - AutofocusAHK %Ver%, The following tasks expired:`n`n%ListOfExpiredTasks% 
  }
}

AF5_PostTaskAdd()
{
  global
  FormatTime, NewExpires, %Expires%, yyyyMMdd
  NewTask_1 := Tasks%TaskCount%_1
  NewTask_2 := Tasks%TaskCount%_2
  NewTask_3 := Tasks%TaskCount%_3
  NewTask_4 := Tasks%TaskCount%_4
  Counter := TaskCount
  
  Loop, %TaskCount%
  {
    OldCounter := Counter
    Counter -= 1
    
    
    If (Counter == 0)
    {
      Break
    }
    
    
    ePos := InStr(Tasks%Counter%_2, "E")
  
    Expires := SubStr(Tasks%Counter%_2, ePos + 1, 8)
    
    
    If (NewExpires >= Expires)
    {
      Break
    }

    Tasks%OldCounter%_1 := Tasks%Counter%_1
    Tasks%OldCounter%_2 := Tasks%Counter%_2
    Tasks%OldCounter%_3 := Tasks%Counter%_3
    Tasks%OldCounter%_4 := Tasks%Counter%_4 
    
  }
  
  If (OldCounter != TaskCount)
  {
    Tasks%OldCounter%_1 := NewTask_1
    Tasks%OldCounter%_2 := NewTask_2
    Tasks%OldCounter%_3 := NewTask_3
    Tasks%OldCounter%_4 := NewTask_4    
    
    SaveTasks()
  }
  
  If (Tasks%CurrentTask%_4 == 1)
  {
    SelectNextTask()
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
		LoadTasks()
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