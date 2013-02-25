; AutofocusAHK
;
; This file contains the initial values for global variables.
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5.4
; @since     0.9

Initialize()
{
  global
  
  ; Application Name
  ApplicationName := "AutofocusAHK"
  
  ; Version number that is displayed in GUI windows
  Ver := "0.9.5.4"

  InitializeLog()
  WriteToLog("Application", ApplicationName . " " . Ver . " started", 1)

  RessourceTasksWriteAccess := 0
  
  ; Is the user currently working on a task?
  Active := 0

  ; The different Modi
  ReverseMode := 0
  ForwardMode := 1
  ReviewMode  := 2

  ; Always start in Reverse Mode
  CurrentMode := ReverseMode
  PreviousMode := ReverseMode

  ; Does a "change to review mode" task exist?
  HasReviewModeTask := 0

  ; Does a "change to forward mode" task exist?
  HasForwardModeTask := 0
  
  ; Does a closed list exist?
  HasClosedList := 0

  ; Load configuration form AutofocusAHK.ini
  LoadConfig()
  
  ; Setup tray menu
  SetupTrayMenu()

  ; Load tasks from Tasks.txt
  LoadTasks()

  ; Start the morning routine (if applicable)
  DoMorningRoutine()
}

Work()
{
  global System

  WriteToLog("Function", "Begin Work()", 1)
  %System%_Work()
  WriteToLog("Function", "End Work()", -1)
}

SelectNextTask()
{
  global System, CurrentTask,CurrentPass,ActionOnCurrentPass,ApplicationName

  WriteToLog("Function", "Begin SelectNextTask()", 1)
  %System%_SelectNextTask()
  SaveSetting("CurrentTask", CurrentTask, "General")
  SaveSetting("CurrentPass", CurrentPass, "General")
  SaveSetting("ActionOnCurrentPass", ActionOnCurrentPass, "General")
  WriteToLog("Function", "End SelectNextTask()", -1)
}

ReAddTask()
{
  global

  WriteToLog("Function", "Begin ReAddTask()", 1)
  RessourceTasksWriteAccess += 1
  TaskCount := TaskCount + 1
  UnactionedCount := UnactionedCount + 1
  GuiControlGet,RephraseBoxContent,,RephraseBox

  If (RephraseBoxContent)
  {
    Tasks%Taskcount%_1 := RephraseBoxContent ;Tasks%CurrentTask%_1
  }
  Else
  {
    Tasks%Taskcount%_1 := Tasks%CurrentTask%_1
  }

  Added := A_Now
  Expires := Added
  Expires += %ExpirationReAdd%, days
  Tasks%Taskcount%_2 := "A" . Added . " E" . Expires
  GuiControlGet,ShowNotesBoxContent,,ShowNotesBox
  Tasks%Taskcount%_3 := ShowNotesBoxContent
  GuiControlGet,ShowUrlBoxContent,,ShowUrlBox
  Tasks%Taskcount%_URL := ShowUrlBoxContent ;Tasks%CurrentTask%_3
  Tasks%Taskcount%_URL := Tasks%CurrentTask%_URL
  Tasks%Taskcount%_4 := 0
  RessourceTasksWriteAccess -= 1
  MarkAsDone()
  %System%_PostTaskAdd()
  WriteToLog("Function", "End ReAddTask()", -1)
}

MarkAsDone()
{
  global

  WriteToLog("Function", "Begin MarkAsDone()", 1)
  RessourceTasksWriteAccess += 1
  Tasks%CurrentTask%_2 := Tasks%CurrentTask%_2 . " D" . A_Now . " T" . TimePassed
  Tasks%CurrentTask%_4 := 1
  UnactionedCount := UnactionedCount - 1
  RessourceTasksWriteAccess -= 1
  SaveTasks()

  If (System == "AF2" or (System == "AF3" and CurrentMode == ReverseMode))
  {
    CurrentTask := TaskCount + 1
  }

  SelectNextTask()
  WriteToLog("Function", "End MarkAsDone()", -1)
}

DoMorningRoutine()
{
  global

  WriteToLog("Function", "Begin DoMorningRoutine()", 1)
  if (((Now - LastRoutine) == 1 and (Hour - StartRoutineAt) >= 0) or (Now - LastRoutine) > 1)
  {
    CheckTicklers()
    SaveTasks()
    BackupTasks()
    LastRoutine := Now
    SaveSetting("LastRoutine", Now, "ReviewMode")
    %System%_DoMorningRoutine()
    If (Tasks%CurrentTask%_4 == 1) 
    {
      SelectNextTask()
    }
  }

  WriteToLog("Function", "End DoMorningRoutine()", -1)
}

DismissTasks()
{
  WriteToLog("Function", "Begin DismissTasks()", 1)
  %System%_DismissTasks()
  WriteToLog("Function", "End DismissTasks()", -1)
}

PutTasksOnNotice()
{
  global

  WriteToLog("Function", "Begin PutTasksOnNotice()", 1)
  BlockStarted := 0
  Message := ""

  Loop %TaskCount%
  {
    If (BlockStarted)
    {
      If (Tasks%A_Index%_4 == 1)
      {
        Break
      }

      if (Tasks%A_Index%_1 != "Change to review mode" and Tasks%A_Index%_1 != "Change to forward mode")
      {
        Tasks%A_Index%_2 := Tasks%A_Index%_2 . " N"
        Message := Message . "- " . Tasks%A_Index%_1 . "`n"
      }
    }
    Else
    {
      If (Tasks%A_Index%_4 == 0 && Tasks%A_Index%_1 != "Change to review mode" and Tasks%A_Index%_1 != "Change to forward mode")
      {
        BlockStarted := 1
        Tasks%A_Index%_2 := Tasks%A_Index%_2 . " N"
        Message := Message . "- " . Tasks%A_Index%_1 . "`n"
      }
    }
  }

  If (Message != "")
  {
    MsgBox The following tasks are now on notice for review:`n`n%Message%
  }

  WriteToLog("Function", "End PutTasksOnNotice()", -1)
}

DoReview()
{
  global

  WriteToLog("Function", "Begin DoReview()", 1)
  ReviewComplete := 1
  ReviewTask := 0
  SelectNextReviewTask()
  WriteToLog("Function", "End DoReview()", -1)
}

SelectNextActivePage()
{
  global

  WriteToLog("Function", "Begin SelectNextActivePage()", 1)

  If (UnactionedCount > 0)
  {
    Loop
    {
      If (Tasks%CurrentTask%_4 == 0)
      {
        Break
      }

      CurrentTask := CurrentTask +1
    }

    SetForwardModeStats()
    CurrentTask := FirstTaskOnPage - 1
  }

  WriteToLog("Function", "End SelectNextActivePage()", -1)
}

GetCurrentMetadata()
{
  global

  WriteToLog("Function", "Begin GetCurrentMetadata()", 1)
  GetTaskMetadata(CurrentTask)
  CurrentDone := TaskDone
  CurrentReview := TaskReview
  CurrentAdded := TaskAdded
  CurrentExpires := TaskExpires
  WriteToLog("Function", "End GetCurrentMetadata()", -1)
}

GetTaskMetadata(Task)
{
  global

  WriteToLog("Function", "Begin GetTaskMetadata(" . Task . ")", 1)
  TaskDone := ""
  TaskReview := ""
  TaskAdded := ""
  TaskExpires := ""

  Loop, Parse, Tasks%Task%_2, %A_Space%
  {
    If (InStr(A_LoopField, "D"))
    {
      TaskDone := SubStr(A_LoopField, 2)
      FormatTime, TaskDone, %TaskDone%, yyyy-MM-dd H:mm
    }

    If (InStr(A_LoopField, "R"))
    {
      TaskReview := SubStr(A_LoopField, 2)
      FormatTime, TaskReview, %TaskReview%, yyyy-MM-dd H:mm
    }

    If (InStr(A_LoopField, "A"))
    {
      TaskAdded := SubStr(A_LoopField, 2)
      FormatTime, TaskAdded, %TaskAdded%, yyyy-MM-dd H:mm
    }

    If (InStr(A_LoopField, "E"))
    {
      TaskExpires := SubStr(A_LoopField, 2)
      FormatTime, TaskExpires, %TaskExpires%, yyyy-MM-dd
      FormatTime, Today,, yyyy-MM-dd
      Tomorrow := A_Now
      Tomorrow += 1, days
      FormatTime, Tomorrow, %Tomorrow%, yyyy-MM-dd
      If (TaskExpires == Today)

      {
        TaskExpires := "Today"
      }
      Else If (TaskExpires == Tomorrow)
      {
        TaskExpires := "Tomorrow"
      }
    }
  }
  WriteToLog("Function", "End GetTaskMetadata(" . Task . ")", -1)
}

MorningRoutine:
  FormatTime, Now, , yyyyMMdd
  FormatTime, Hour, , H
  DoMorningRoutine()
Return

GetStandardWindowTitle()
{
  Global

  Title := " - " . System . " - " . ApplicationName . " " . Ver
  Return Title
}

CheckCapsLock:
  SetCapslockState, Off
  SetCapslockState, AlwaysOff
Return

CheckForBrowserUrl()
{
  WriteToLog("Function", "Begin CheckForBrowserUrl()", 1)
  Url := ""
  WinGetActiveTitle, BrowserTitle

  If (InStr(Browsertitle, "Internet Explorer"))
  {
    Clipboard =
    Send !d
    Sleep 200
    Send ^c
    ClipWait, 0.5
    Url := Clipboard 
  } 
  Else If (InStr(Browsertitle, "Mozilla Firefox") or InStr(Browsertitle, "Google Chrome") or InStr(Browsertitle, "Opera"))
  {
    Clipboard =
    Send ^l
    Sleep 200
    Send ^c
    ClipWait, 0.5
    Url := Clipboard 
  } 

  WriteToLog("Function", "End CheckForBrowserUrl(), Return: " . Url, -1)
  Return Url  
}

AddTask(Description, Notes, Url, TickleDate)
{
  global

  WriteToLog("Function", "Begin AddTask(" . Description . ", " . Notes . ", " . Url . ", " . TickleDate . ")", 1)
  RessourceTasksWriteAccess += 1
  FormatTime, today, ,yyyyMMdd
  TaskCount := TaskCount + 1

  If (UnactionedCount == 0)
  {
    CurrentTask := TaskCount
  }

  UnactionedCount := UnactionedCount + 1
  Tasks%Taskcount%_1 := Description

  If (TickleDate <= today)
  {
    Added := A_Now
    Expires := Added
    Expires += %ExpirationNew%, days
    Tasks%Taskcount%_2 := "A" . Added . " E" . Expires
    Tasks%Taskcount%_4 := 0
  }
  Else
  {
    Tickled := TickleDate . "000000"
    Expires := TickleDate
    Expires += %ExpirationNew%, days
    Tasks%Taskcount%_2 := "S" . Tickled . " E" . Expires
    Tasks%Taskcount%_4 := 1
  }

  StringReplace, Notes, Notes,%A_Tab%,\t, All
  StringReplace, Notes, Notes,`n,\n, All
  Tasks%Taskcount%_3 := Notes
  Tasks%Taskcount%_URL := Url
  %System%_PostTaskAdd()
  RessourceTasksWriteAccess -= 1
  SaveTasks()
  WriteToLog("Function", "End AddTask(" . Description . ", " . Notes . ", " . Url . ", " . TickleDate . ")", -1)
}

CheckTicklers()
{
  global

  WriteToLog("Function", "Begin CheckTicklers()", 1)
  Loop, %TaskCount%
  {
    If (TicklePos := InStr(Tasks%A_Index%_2, "S"))
    {
      FormatTime, Today,, yyyyMMdd
      If (SubStr(Tasks%A_Index%_2, TicklePos+1, 8) <= Today)
      {
        StringReplace, Tasks%A_Index%_2, Tasks%A_Index%_2, S, U 
        NewTitle := Tasks%A_Index%_1
        If (TicklerPrefix)
        {
            NewTitle := TicklerPrefix . " " . NewTitle
        }
        AddTask(NewTitle, Tasks%A_Index%_3, Tasks%A_Index%_URL, Today)
      }
    }
  }
  WriteToLog("Function", "End CheckTicklers()", -1)
}
