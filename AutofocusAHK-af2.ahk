; AutofocusAHK
;
; This file holds all functions specific to the Autofocus 2 system. 
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5.4
; @since     0.9

AF2_IsReviewOptional()
{
  WriteToLog("Function", "Begin AF2_IsReviewOptional()", 1)
  WriteToLog("Function", "End AF2_IsReviewOptional(), Return: 1", -1)
  Return 1
}

AF2_IsValidTask(TaskName, TaskStats, TaskIndex)
{
  global

  WriteToLog("Function", "Begin AF2_IsValidTask(" . TaskName . ", " . TaskStats . ", " . TaskIndex . ")", 1)
  Result := 1
  
  If (TaskName == "Change to review mode")
  {
    HasReviewModeTask := 1
  }
  Else If (TaskName == "Change to forward mode")
  {
    Result := 0
  }
  Else If (TaskName == "---")
  {
    Result := 0
  }

  WriteToLog("Function", "End AF2_IsValidTask(" . TaskName . ", " . TaskStats . ", " . TaskIndex . "), Return: " . Result, -1)

  Return Result
}

AF2_PostTaskLoad()
{
  global

  WriteToLog("Function", "Begin AF2_PostTaskLoad()", 1)
  CurrentTask := TaskCount + 1
  SelectNextTask()
  WriteToLog("Function", "End AF2_PostTaskLoad()", -1)
}

AF2_PostTaskAdd()
{
  WriteToLog("Function", "Begin AF2_PostTaskAdd()", 1)
  WriteToLog("Function", "End AF2_PostTaskAdd()", -1)
}

AF2_SelectNextTask()
{
  global

  WriteToLog("Function", "Begin AF2_SelectNextTask()", 1)

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

  WriteToLog("Function", "End AF2_SelectNextTask()", -1)
}

AF2_Work()
{
  global

  WriteToLog("Function", "Begin AF2_Work()", 1)

  If (CurrentMode == ReviewMode)
  {
    ShowReviewWindow()
  }
  Else If (Active == 1)
  {
    ShowDoneWindow()
  }
  Else If (UnactionedCount <= 0)
  {
    MsgBox No unactioned tasks!
  }
  Else
  {
    ShowWorkWindow()
  }

  WriteToLog("Function", "End AF2_Work()", -1)
}

AF2_DoMorningRoutine()
{
  WriteToLog("Function", "Begin AF2_DoMorningRoutine()", 1)
  DismissTasks()
  PutTasksOnNotice()
  WriteToLog("Function", "End AF2_DoMorningRoutine()", -1)
}

AF2_DismissTasks()
{
  global

  WriteToLog("Function", "Begin AF2_DismissTasks()", 1)
  RessourceTasksWriteAccess += 1
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

  RessourceTasksWriteAccess -= 1
  SaveTasks()
  WriteToLog("Function", "End AF2_DismissTasks()", -1)
}

AF2_GetWorkWindowTitle()
{
  WriteToLog("Function", "Begin AF2_GetWorkWindowTitle()", 1)
  Title .= "Work" . GetStandardWindowTitle()
  WriteToLog("Function", "End AF2_GetWorkWindowTitle(), Return: " . Title, -1)

  Return Title
}

AF2_GetReviewWindowTitle()
{
  WriteToLog("Function", "Begin AF2_GetReviewWindowTitle()", 1)
  Title := "Review" . GetStandardWindowTitle()
  WriteToLog("Function", "End AF2_GetReviewWindowTitle(), Return: " . Title, -1)

  Return Title
}

AF2_PreShowTaskname()
{
  WriteToLog("Function", "Begin AF2_PreShowTaskname()", 1)
  WriteToLog("Function", "End AF2_PreShowTaskname()", -1)
}

AF2_PostShowTaskname()
{
  WriteToLog("Function", "Begin AF2_PostShowTaskname()", 1)
  WriteToLog("Function", "End AF2_PostShowTaskname()", -1)
}
