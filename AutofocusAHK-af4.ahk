; AutofocusAHK
;
; This file holds all functions specific to the Autofocus 4 system. 
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5.4
; @since     0.9

AF4_IsReviewOptional()
{
  WriteToLog("Function", "Begin AF4_IsReviewOptional()", 1)
  WriteToLog("Function", "End AF4_IsReviewOptional(), Return: 0", -1)
  Return 0
}

AF4_IsValidTask(TaskName, TaskStats, TaskIndex)
{
  global

  WriteToLog("Function", "Begin AF4_IsValidTask(" . TaskName . ", " . TaskStats . ", " . TaskIndex . ")", 1)
  Result := 1

  If (TaskName == "Change to review mode")
  {
    If (CurrentTask > TaskIndex) CurrentTask -= CurrentTask
    Result :=  0
  }
  Else If (TaskName == "Change to forward mode")
  {
    If (CurrentTask > TaskIndex) CurrentTask -= CurrentTask
    Result :=  0
  }
  Else If (TaskName == "---")
  {
    HasClosedList := 1
    LastTaskInClosedList := TaskCount
    Result := 0
  }

  WriteToLog("Function", "End AF4_IsValidTask(" . TaskName . ", " . TaskStats . ", " . TaskIndex . "), Return: " . Result, -1)

  Return Result
}

AF4_PostTaskLoad()
{
  global

  WriteToLog("Function", "Begin AF4_PostTaskLoad()", 1)

  If (TaskCount >= TasksPerPage and HasClosedList == 0)
  {
    HasClosedList := 1
    LastTaskInClosedList := TaskCount
    SaveTasks()
  }

  If (CurrentTask == 0 or CurrentTask > TaskCount or Tasks%CurrentTask%_4 == 1)
  {
    SelectNextTask()
  }

  WriteToLog("Function", "End AF4_PostTaskLoad()", -1)
}

AF4_PostTaskAdd()
{
  global

  WriteToLog("Function", "Begin AF4_PostTaskAdd()", 1)

  If (TaskCount >= TasksPerPage and HasClosedList == 0)
  {
    HasClosedList := 1
    LastTaskInClosedList := TaskCount
    SaveTasks()
  }

  WriteToLog("Function", "End AF4_PostTaskAdd()", -1)
}

AF4_SelectNextTask()
{
  global

  WriteToLog("Function", "Begin AF4_SelectNextTask()", 1)

  If (UnactionedCount > 0 or HasTasksOnReview)
  {
    Start := CurrentTask
    Loop
    {
      CurrentTask := CurrentTask + 1

      If (!InStr(Tasks%CurrentTask%_2, "D") and InStr(Tasks%CurrentTask%_2, "R"))
      {
        If (CurrentMode != ReviewMode)
        {
          ReviewComplete := 1
          ReviewTask := CurrentTask
          PreviousMode := CurrentMode
          CurrentMode := ReviewMode
        }
      }

      If (HasClosedList and CurrentTask == LastTaskInClosedList+1)
      {
        If (ActionOnCurrentPass or (ActionOnCurrentPass and CreatingList))
        {
          If (!CreatingList)
          {
            CurrentPass := CurrentPass + 1
            ActionOnCurrentPass := 0
          }
          CurrentTask := 0
        }
        Else If (!CreatingList)
        {
          If (CurrentPass == 1)
          {
            AF4_DismissTasks()
            CurrentPass := 1
            ActionOnCurrentPass := 0
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
        CurrentTask := 0
        ActionOnCurrentPass := 0
      }

      If (Tasks%CurrentTask%_4 == 0 or (UnactionedCount == 0 and HasTasksOnReview == 0) (UnactionedCount == 0 and CurrentMode == ReviewMode and HasTasksOnReview == 1)) 
      {
        Break
      }
    }
  }

  WriteToLog("Function", "End AF4_SelectNextTask()", -1)
}


AF4_Work()
{
  global

  WriteToLog("Function", "Begin AF4_Work()", 1)

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
    If (HasClosedList == 0)
    {
      HasClosedList := 1
      LastTaskInClosedList := TaskCount
      SaveTasks()
    }
    ShowWorkWindow()
  }

  WriteToLog("Function", "End AF4_Work()", -1)
}

SetBacklogStats()
{
  global

  WriteToLog("Function", "Begin SetBacklogStats()", 1)

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

  WriteToLog("Function", "End SetBacklogStats()", -1)
}

AF4_DoMorningRoutine()
{
  WriteToLog("Function", "Begin AF4_DoMorningRoutine()", 1)
  SaveTasks()
  BackupTasks()
  WriteToLog("Function", "End AF4_DoMorningRoutine()", -1)
}

AF4_DismissTasks()
{
  global

  WriteToLog("Function", "Begin AF4_DismissTasks()", 1)
  RessourceTasksWriteAccess += 1
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
  RessourceTasksWriteAccess -= 1
  SaveTasks()
  WriteToLog("Function", "End AF4_DismissTasks()", -1)
}

AF4_GetWorkWindowTitle()
{
  global CurrentTask,LastTaskInClosedList,CurrentPass,ActionOnCurrentPass

  WriteToLog("Function", "Begin AF4_GetWorkWindowTitle()", 1)

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
  WriteToLog("Function", "End AF4_GetWorkWindowTitle(), Return: " . Title, -1)

  Return Title
}

AF4_GetReviewWindowTitle()
{
  WriteToLog("Function", "Begin AF4_GetReviewWindowTitle()", 1)
  Title := "Review"
  Title .= GetStandardWindowTitle()
  WriteToLog("Function", "End AF4_GetReviewWindowTitle(), Return: " . Title, -1)

  Return Title
}

AF4_PreShowTaskname()
{
  WriteToLog("Function", "Begin AF4_PreShowTaskname()", 1)
  WriteToLog("Function", "End AF4_PreShowTaskname()", -1)
}

AF4_PostShowTaskname()
{
  WriteToLog("Function", "Begin AF4_PostShowTaskname()", 1)
  WriteToLog("Function", "End AF4_PostShowTaskname()", -1)
}
