; AutofocusAHK
;
; This file holds all functions specific to the Day/Week/Month system. 
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5.2
; @since     0.9.3

DWM_IsReviewOptional()
{
  WriteToLog("Function", "Begin DWM_IsReviewOptional()", 1)
  WriteToLog("Function", "End DWM_IsReviewOptional()", 1)
  Return 0
}

DWM_IsValidTask(TaskName, TaskStats, TaskIndeX)
{
  global

  WriteToLog("Function", "Begin DWM_IsValidTask(" . TaskName . ", " . TaskStats . ")", 1)
  Result := 1
  
  If (TaskName == "Change to review mode")
  {
    If (CurrentTask > 0 and CurrentTask > TaskIndex)
    {
      CurrentTask -= 1
    }

    Result := 0
  }
  Else If (TaskName == "Change to forward mode")
  {
    If (CurrentTask > 0 and CurrentTask > TaskIndex)
    {
      CurrentTask -= 1
    }

    Result := 0
  }
  Else If (TaskName == "---")
  {
    Result := 0
  }
  Else If (ePos := InStr(TaskStats, "E"))
  {
    Expires := SubStr(TaskStats, ePos + 1, 8)
    FormatTime, Today, , yyyyMMdd

    If (Today > Expires)
    {
      If (!InStr(TaskStats, "D"))
      {
        ListOfExpiredTasks .= TaskName . "`n"
      }
      
      If (CurrentTask > 0 and CurrentTask > TaskIndex)
      {
        CurrentTask -= 1
      }

      Result := 0
    }
  }
  Else
  {
    If (CurrentTask > 0 and CurrentTask > TaskIndex)
    {
      CurrentTask -= 1
    }

    Result := 0
  }

  WriteToLog("Function", "End DWM_IsValidTask(" . TaskName . ", " . TaskStats . "), Result: " . Result, -1)
  Return %Result%
}

DWM_PostTaskLoad()
{
  global

  WriteToLog("Function", "Begin DWM_PostTaskLoad()", 1)
  If (CurrentTask <= 0 or CurrentTask > TaskCount or Tasks%CurrentTask%_4 == 1)
  {
    SelectNextTask()
  }

  If (ListOfExpiredTasks)
  {
    MsgBox, 0 , Expiration - %System% - %ApplicationName% %Ver%, The following tasks expired:`n`n%ListOfExpiredTasks%
    ListOfExpiredTasks := ""
  }
  SaveTasks()
  WriteToLog("Function", "End DWM_PostTaskLoad()", -1)
}

DWM_PostTaskAdd()
{
  global

  WriteToLog("Function", "Begin DWM_PostTaskAdd()", 1)
  NewExpires := SubStr(Tasks%TaskCount%_2, ePos + 1, 8)
  AddedTask_1 := Tasks%TaskCount%_1
  AddedTask_2 := Tasks%TaskCount%_2
  AddedTask_3 := Tasks%TaskCount%_3
  AddedTask_4 := Tasks%TaskCount%_4
  AddedTask_URL := Tasks%TaskCount%_URL
  Counter := TaskCount

  RessourceTasksWriteAccess += 1
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

    LogMessage := NewExpires . " >= " .  Expires . " ? "
    If (NewExpires >= Expires)
    {
      LogMessage .= "Yes, drop task at position " . OldCounter
      WriteToLog("Variable", LogMessage)
      Break
    }

    LogMessage .= "No"
    WriteToLog("Variable", LogMessage)
    Tasks%OldCounter%_1 := Tasks%Counter%_1
    Tasks%OldCounter%_2 := Tasks%Counter%_2
    Tasks%OldCounter%_3 := Tasks%Counter%_3
    Tasks%OldCounter%_4 := Tasks%Counter%_4 
    Tasks%OldCounter%_URL := Tasks%Counter%_URL 
  }
  RessourceTasksWriteAccess -= 1

  If (OldCounter != TaskCount)
  {
    RessourceTasksWriteAccess += 1
    Tasks%OldCounter%_1 := AddedTask_1
    Tasks%OldCounter%_2 := AddedTask_2
    Tasks%OldCounter%_3 := AddedTask_3
    Tasks%OldCounter%_4 := AddedTask_4    
    Tasks%OldCounter%_URL := AddedTask_URL    
    RessourceTasksWriteAccess -= 1

    SaveTasks()
  }

  If (CurrentTask < 0 or Tasks%CurrentTask%_4 == 1)
  {
    SelectNextTask()
  }
  WriteToLog("Function", "End DWM_PostTaskAdd()", -1)
}

DWM_SelectNextTask()
{
  global

  WriteToLog("Function", "Begin DWM_SelectNextTask()", 1)

  If (UnactionedCount > 0)
  {
    Start := CurrentTask

    RessourceTasksWriteAccess += 1

    Loop
    {
      CurrentTask := CurrentTask + 1
      If (CurrentTask > TaskCount)
      {
        CurrentTask := 0
      }
      If (Tasks%CurrentTask%_4 == 0 or UnactionedCount == 0) 
      {
        FormatTime, Today, , yyyyMMdd 
        Expires := SubStr(Tasks%CurrentTask%_2, InStr(Tasks%CurrentTask%_2, "E")+1,8)

        If (Expires < Today)
        {
          Tasks%CurrentTask%_4 := 1
        }

        Break
      }
    }

    RessourceTasksWriteAccess -= 1
  }

  WriteToLog("Function", "End DWM_SelectNextTask()", -1)
}

DWM_Work()
{
  global

  WriteToLog("Function", "Begin DWM_Work()", 1)

  If (Active == 1)
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

  WriteToLog("Function", "End DWM_Work()", -1)
}


DWM_DoMorningRoutine()
{
  WriteToLog("Function", "Begin DWM_DoMorningRoutine()", 1)
  LoadTasks()
  WriteToLog("Function", "Begin DWM_DoMorningRoutine()", -1)
}

DWM_DismissTasks()
{
  global

  WriteToLog("Function", "Begin DWM_DismissTasks()", 1)
  Message := ""

  RessourceTasksWriteAccess += 1

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

  RessourceTasksWriteAccess -= 1

  If (Message != "")
  {
    MsgBox The following tasks are now on review:`n`n%Message%
    HasTasksOnReview := 1
  }

  LastTaskInClosedList := TaskCount
  SaveTasks()
  WriteToLog("Function", "End DWM_DismissTasks()", -1)
}

DWM_GetWorkWindowTitle()
{
  global CurrentExpires

  WriteToLog("Function", "Begin DWM_GetWorkWindowTitle()", 1)
  GetCurrentMetadata()
  Title := "Work - Expires " . CurrentExpires
  Title .= GetStandardWindowTitle()
  WriteToLog("Function", "End DWM_GetWorkWindowTitle(), Return: " . Title, -1)

  Return Title
}

DWM_GetReviewWindowTitle()
{
  WriteToLog("Function", "Begin DWM_GetReviewWindowTitle()", 1)
  Title := "Review"
  Title .= GetStandardWindowTitle()
  WriteToLog("Function", "End DWM_GetReviewWindowTitle(), Return: " . Title, 1)

  Return Title
}

DWM_PreShowTaskname()
{
  global CurrentExpires

  WriteToLog("Function", "Begin DWM_PreShowTaskname()", 1)
  GetCurrentMetadata()

  If (CurrentExpires = "Today")
  {
    Gui, Color, FFDDDD
  }
  Else If (CurrentExpires = "Tomorrow")
  {
    Gui, Color, FFFFBB
  }
  WriteToLog("Function", "End DWM_PreShowTaskname()", -1)
}

DWM_PostShowTaskname()
{
  global

  WriteToLog("Function", "Begin DWM_PostShowTaskname()", 1)
  GuiControl, Hide, TaskControl  
  GuiControl, +Background00FF00, TaskControl
  GuiControl, Show, TaskControl
  WriteToLog("Function", "End DWM_PostShowTaskname()", -1)
}
