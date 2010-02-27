; AutofocusAHK
;
; This file holds all functions specific to the Autofocus 3 system. 
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5.2
; @since     0.9

AF3_IsReviewOptional()
{
  WriteToLog("Function", "Begin AF3_IsReviewOptional()", 1)
  WriteToLog("Function", "End AF3_IsReviewOptional(), Return: 1", -1)
  Return 1
}

AF3_IsValidTask(TaskName, TaskStats, TaskIndex)
{
  global

  WriteToLog("Function", "Begin AF3_IsValidTask(" . TaskName . ", " . TaskStats . ", " . TaskIndex . ")", 1)
  Result := 1
  
  If (TaskName == "Change to review mode")
  {
    HasReviewModeTask := 1
  }
  Else If (TaskName == "Change to forward mode")
  {
    HasForwardModeTask := 1
  }
  Else If (TaskName == "---")
  {
    Result := 0
  }

  WriteToLog("Function", "End AF3_IsValidTask(" . TaskName . ", " . TaskStats . ", " . TaskIndex . "), Return: " . Result, -1)
  Return Result
}

AF3_PostTaskLoad()
{
  global

  WriteToLog("Function", "Begin AF3_PostTaskLoad()", 1)

  If (TaskCount >= TasksPerPage * 3 and HasForwardModeTask == 0)
  {
      RessourceTasksWriteAccess += 1
      TaskCount := TaskCount + 1
      UnactionedCount := UnactionedCount + 1
      Tasks%Taskcount%_1 := "Change to forward mode"
      Tasks%Taskcount%_2 := "A" . A_Now
      Tasks%Taskcount%_3 := ""
      Tasks%Taskcount%_4 := 0
      HasForwardModeTask := 1
      RessourceTasksWriteAccess -= 1
      SaveTasks()
  }

  CurrentTask := TaskCount + 1
  SelectNextTask()
  WriteToLog("Function", "End AF3_PostTaskLoad()", -1)
}

AF3_PostTaskAdd()
{
  WriteToLog("Function", "Begin AF3_PostTaskAdd()", 1)
  WriteToLog("Function", "End AF3_PostTaskAdd()", -1)
}

AF3_SelectNextTask()
{
  global

  WriteToLog("Function", "Begin AF3_SelectNextTask()", 1)

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

        If (Tasks%CurrentTask%_4 == 0) 
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
              RessourceTasksWriteAccess += 1
              CurrentMode := ReverseMode
              TaskCount := TaskCount + 1
              UnactionedCount := UnactionedCount + 1
              Tasks%Taskcount%_1 := "Change to forward mode"
              Tasks%Taskcount%_2 := "A" . A_Now
              Tasks%Taskcount%_3 := ""
              Tasks%Taskcount%_4 := 0
              HasForwardModeTask := 1
              RessourceTasksWriteAccess -= 1
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

        If (Tasks%CurrentTask%_4 == 0 or UnactionedCount == 0) 
        {
          Break
        }
      }
    }
  }

  WriteToLog("Function", "End AF3_SelectNextTask()", -1)
}

AF3_Work()
{
  global

  WriteToLog("Function", "Begin AF3_Work()", 1)

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

  WriteToLog("Function", "End AF3_Work()", -1)
}

SetForwardModeStats()
{
  global

  WriteToLog("Function", "Begin SetForwardModeStats()", 1)

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

  WriteToLog("Function", "End SetForwardModeStats()", -1)
}

AF3_DoMorningRoutine()
{
  WriteToLog("Function", "Begin AF3_DoMorningRoutine()", 1)
  DismissTasks()
  PutTasksOnNotice()
  WriteToLog("Function", "End AF3_DoMorningRoutine()", -1)
}

AF3_DismissTasks()
{
  global

  WriteToLog("Function", "Begin AF3_DismissTasks()", 1)
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
  WriteToLog("Function", "End AF3_DismissTasks()", -1)
}

AF3_GetWorkWindowTitle()
{
  Global CurrentMode, ForwardMode

  WriteToLog("Function", "Begin AF3_GetWorkWindowTitle()", 1)

  If (CurrentMode == ForwardMode)
  {
    Title := "Forward Mode"
  }
  Else
  {
    Title := "Reverse Mode"
  }

  Title .= GetStandardWindowTitle()
  WriteToLog("Function", "End AF3_GetWorkWindowTitle(), Return: " . Title, -1)

  Return Title
}

AF3_GetReviewWindowTitle()
{
  WriteToLog("Function", "Begin AF3_GetReviewWindowTitle()", 1)
  Title := "Review Mode"
  Title .= GetStandardWindowTitle()
  WriteToLog("Function", "End AF3_GetReviewWindowTitle(), Return: " . Title, -1)

  Return Title
}

AF3_PreShowTaskname()
{
  WriteToLog("Function", "Begin AF3_PreShowTaskname()", 1)
  WriteToLog("Function", "End AF3_PreShowTaskname()", -1)
}

AF3_PostShowTaskname()
{
  WriteToLog("Function", "Begin AF3_PostShowTaskname()", 1)
  WriteToLog("Function", "End AF3_PostShowTaskname()", -1)
}
