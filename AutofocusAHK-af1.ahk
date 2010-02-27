; AutofocusAHK
;
; This file holds all functions specific to the Autofocus 1 system. 
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5.3
; @since     0.9

AF1_IsReviewOptional()
{
  WriteToLog("Function", "Begin AF1_IsReviewOptional()", 1)
  WriteToLog("Function", "End AF1_IsReviewOptional(), Return: 1", -1)
  Return 1
}

AF1_IsValidTask(TaskName, TaskStats, TaskIndex)
{
  global

  WriteToLog("Function", "AF1_IsValidTask(" . TaskName . ", " . TaskStats . ", " . TaskIndex . ")", 1)
  Result := 1
  
  If (TaskName == "Change to review mode")
  {
    HasReviewModeTask := 1
  }
  Else If (TaskName == "Change to forward mode")
  {
    If (CurrentTask > TaskIndex) CurrentTask -= CurrentTask

    Result := 0
  }
  Else If (TaskName == "---")
  {
    Result := 0
  }

  WriteToLog("Function", "AF1_IsValidTask(" . TaskName . ", " . TaskStats . ", " . TaskIndex . "), Return: " . Result, -1)
  Return %Result%
}

AF1_PostTaskLoad()
{
  global

  WriteToLog("Function", "Begin AF1_PostTaskLoad()", 1)

  If (CurrentTask == 0 or CurrentTask > TaskCount or Tasks%CurrentTask%_3 == 4)
  {
    SelectNextTask()
  }

  WriteToLog("Function", "End AF1_PostTaskLoad()", -1)
}

AF1_PostTaskAdd()
{
  WriteToLog("Function", "Begin AF1_PostTaskAdd()", 1)
  WriteToLog("Function", "End AF1_PostTaskAdd()", -1)
}

AF1_SelectNextTask()
{
  global

  WriteToLog("Function", "Begin AF1_SelectNextTask()", 1)
  If (UnactionedCount > 0)
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
            AF1_DismissTasks()
            CurrentPass := 1
            ActionOnCurrentPass := 0
            SelectNextActivePage()
          }
          Else
          {
            CurrentPass := 1
            ActionOnCurrentPass := 0
            SelectNextActivePage()
          }
        }
      }

      If (Tasks%CurrentTask%_4 == 0 or UnactionedCount == 0) 
      {
        Break
      }
    }
  }
  WriteToLog("Function", "End AF1_SelectNextTask()", -1)
}

AF1_Work()
{
  global

  WriteToLog("Function", "Begin AF1_Work()", 1)

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

  WriteToLog("Function", "End AF1_Work()", -1)
}

AF1_DoMorningRoutine()
{
  WriteToLog("Function", "Begin AF1_DoMorningRoutine()", 1)
  WriteToLog("Function", "End AF1_DoMorningRoutine()", -1)
}

AF1_DismissTasks()
{
  global

  WriteToLog("Function", "Begin AF1_DismissTasks()", 1)
  RessourceTasksWriteAccess += 1
  Message := ""
  ToBeDismissed := FirstTaskOnPage

  Loop %TasksPerPage%
  {
    If (Tasks%ToBeDismissed%_4 == 0)
    {
      Tasks%ToBeDismissed%_2 := Tasks%ToBeDismissed%_2 . " R" . A_Now
      Tasks%ToBeDismissed%_4 := 1
      UnactionedCount := UnactionedCount - 1
      Message := Message . "- " . Tasks%ToBeDismissed%_1 . "`n"
    }

    ToBeDismissed += 1

    If (ToBeDismissed > LastTaskOnPage)
    {
      Break
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
  WriteToLog("Function", "End AF1_DismissTasks()", -1)
}

AF1_GetWorkWindowTitle()
{
  WriteToLog("Function", "Begin AF1_GetWorkWindowTitle()", 1)
  Title .= "Work" . GetStandardWindowTitle()
  WriteToLog("Function", "End AF1_GetWorkWindowTitle(), Return: " . Title, -1)

  Return Title
}

AF1_GetReviewWindowTitle()
{
  WriteToLog("Function", "Begin AF1_GetReviewWindowTitle()", 1)
  Title := "Review"
  Title .= GetStandardWindowTitle()
  WriteToLog("Function", "End AF1_GetReviewWindowTitle(), Return: " . Title, -1)

  Return Title
}

AF1_PreShowTaskname()
{
  WriteToLog("Function", "Begin AF1_PreShowTaskname()", 1)
  WriteToLog("Function", "End AF1_PreShowTaskname()", -1)
}

AF1_PostShowTaskname()
{
  WriteToLog("Function", "Begin AF1_PostShowTaskname()", 1)
  WriteToLog("Function", "End AF1_PostShowTaskname()", -1)
}
