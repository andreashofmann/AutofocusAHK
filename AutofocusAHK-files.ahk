; AutofocusAHK
;
; Functions that read from or write to the file system
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5
; @since     0.9

; Load tasks from file Tasks.txt
LoadTasks()
{
  global
  TaskCount := 0
  UnactionedCount := 0
  Loop, read, %A_ScriptDir%\Tasks.txt
  {
     NewTask_1 := ""
     NewTask_2 := ""
     NewTask_3 := ""
     NewTask_4 := ""
    Loop, parse, A_LoopReadLine, %A_Tab%
    {
      NewTask_%A_Index% := A_LoopField
    }
    IsValidTask := %System%_IsValidTask(NewTask_1, NewTask_2, TaskCount)

    if (IsValidTask)
    {
      TaskCount := TaskCount + 1
      Tasks%TaskCount%_1 := NewTask_1
      Tasks%TaskCount%_2 := NewTask_2
    If (NewTask_3)
    {
        Tasks%TaskCount%_3 := NewTask_3  
      }
      Else
      {
        Tasks%TaskCount%_3 := ""
      }
    If (NewTask_4)
    {
        Tasks%TaskCount%_URL := NewTask_4  
      }
      Else
      {
        Tasks%TaskCount%_4 := ""
      }  
      If (InStr(Tasks%TaskCount%_2, "D") or InStr(Tasks%TaskCount%_2, "R"))
      {
        Tasks%TaskCount%_4 := 1
        If (!InStr(Tasks%TaskCount%_2, "D") and InStr(Tasks%TaskCount%_2, "R"))
        {
          HasTasksOnReview := 1
        }
      }
      Else
      {
        Tasks%TaskCount%_4 := 0
        UnactionedCount := UnactionedCount +1
         If (!InStr(Tasks%TaskCount%_2, "E"))
         {
           Expires := A_Now
           Expires += %ExpirationNew%, days
           Tasks%TaskCount%_2 .= " E" . Expires
         }
      }
    }
  }
  %System%_PostTaskLoad()
}

; Save tasks to file Tasks.txt
SaveTasks()
{
  global
  Content := ""
  Loop %TaskCount%
  {
    StringReplace, NotesToBeSaved, Tasks%A_Index%_3,%A_Tab%,\t, All
    StringReplace, NotesToBeSaved, NotesToBeSaved,`n,\n, All

    Content := Content . Tasks%A_Index%_1 . A_Tab . Tasks%A_Index%_2 . A_Tab . NotesToBeSaved . A_Tab . Tasks%A_Index%_URL . "`n"
    If (System == "AF4" and HasClosedList and A_Index == LastTaskInClosedList)
    {
      Content := Content . "---`n"    
    }
  }
  FileDelete, %A_ScriptDir%\Tasks.txt
  FileAppend, %Content%, %A_ScriptDir%\Tasks.txt
}

; Load configuration from AutofocusAHK.ini
LoadConfig()
{
  global
  FirstStart := 0
  FormatTime, Now, , yyyyMMdd
  FormatTime, Hour, , H
  IniRead, System, %A_ScriptDir%\%ApplicationName%.ini, General, System
  If (System == "ERROR")
  {
    FirstStart := 1
    System := "AF4"
    IniWrite, %System%, %A_ScriptDir%\%ApplicationName%.ini, General, System
  }
  If (System == "AF5")
  {
    System := "DWM"
    IniWrite, %System%, %A_ScriptDir%\%ApplicationName%.ini, General, System
  }
  IniRead, StartWithWindows, %A_ScriptDir%\%ApplicationName%.ini, General, StartWithWindows
  If (StartWithWindows == "ERROR")
  {
    StartWithWindows := 0
    IniWrite, %StartWithWindows%, %A_ScriptDir%\%ApplicationName%.ini, General, StartWithWindows
  }
  IniRead, DoBackups, %A_ScriptDir%\%ApplicationName%.ini, General, DoBackups
  If (DoBackups == "ERROR")
  {
    DoBackups := 1
    IniWrite, %DoBackups%, %A_ScriptDir%\%ApplicationName%.ini, General, DoBackups
  }
  IniRead, BackupsToKeep, %A_ScriptDir%\%ApplicationName%.ini, General, BackupsToKeep
  If (BackupsToKeep == "ERROR")
  {
    BackupsToKeep := 10
    IniWrite, %BackupsToKeep%, %A_ScriptDir%\%ApplicationName%.ini, General, BackupsToKeep
  }
  IniRead, LastRoutine, %A_ScriptDir%\%ApplicationName%.ini, ReviewMode, LastRoutine
  If (LastRoutine == "ERROR")
  {
    LastRoutine := Now
    IniWrite, %LastRoutine%, %A_ScriptDir%\%ApplicationName%.ini, ReviewMode, LastRoutine
  }
  IniRead, StartRoutineAt, %A_ScriptDir%\%ApplicationName%.ini, ReviewMode, StartRoutineAt
  If (StartRoutineAt == "ERROR")
  {
    StartRoutineAt := 6
    IniWrite, %StartRoutineAt%, %A_ScriptDir%\%ApplicationName%.ini, ReviewMode, StartRoutineAt
  }
  IniRead, TasksPerPage, %A_ScriptDir%\%ApplicationName%.ini, ForwardMode, TasksPerPage
  If (TasksPerPage == "ERROR")
  {
    TasksPerPage := 20
    IniWrite, %TasksPerPage%, %A_ScriptDir%\%ApplicationName%.ini, ForwardMode, TasksPerPage
  }
  IniRead, CurrentTask, %A_ScriptDir%\%ApplicationName%.ini, General, CurrentTask
  If (CurrentTask == "ERROR")
  {
    CurrentTask := 0
    IniWrite, %CurrentTask%, %A_ScriptDir%\%ApplicationName%.ini, General, CurrentTask
  }
  IniRead, ActionOnCurrentPass, %A_ScriptDir%\%ApplicationName%.ini, General, ActionOnCurrentPass
  If (ActionOnCurrentPass == "ERROR")
  {
    ActionOnCurrentPass := 0
    IniWrite, %ActionOnCurrentPass%, %A_ScriptDir%\%ApplicationName%.ini, General, ActionOnCurrentPass
  }
  IniRead, CurrentPass, %A_ScriptDir%\%ApplicationName%.ini, General, CurrentPass
  If (CurrentPass == "ERROR")
  {
    CurrentPass := 1
    IniWrite, %CurrentPass%, %A_ScriptDir%\%ApplicationName%.ini, General, CurrentPass
  }

  IniRead, ExpirationNew, %A_ScriptDir%\%ApplicationName%.ini, DWM, ExpirationNew
  If (ExpirationNew == "ERROR")
  {
    ExpirationNew := 28
    IniWrite, %ExpirationNew%, %A_ScriptDir%\%ApplicationName%.ini, DWM, ExpirationNew
  }

  IniRead, ExpirationReAdd, %A_ScriptDir%\%ApplicationName%.ini, DWM, ExpirationReAdd
  If (ExpirationReAdd == "ERROR")
  {
    ExpirationReAdd := 7
    IniWrite, %ExpirationReAdd%, %A_ScriptDir%\%ApplicationName%.ini, DWM, ExpirationReAdd
  }
  
  SetHotkeys := ""

  IniRead, HKAddTask, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKAddTask
  If (HKAddTask == "ERROR")
  {
    HKAddTask := "CapsLock & a"
    IniWrite, %HKAddTask%, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKAddTask
  }
  Hotkey, %HKAddTask%, TriggerAddTask
  SetHotkeys .= HKAddTask  
  
  IniRead, HKWork, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKWork
  If (HKWork == "ERROR")
  {
    HKWork := "CapsLock & d"
    IniWrite, %HKWork%, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKWork
  }
  Hotkey, %HKWork%, TriggerWork
  SetHotkeys .= HKWork  

  IniRead, HKShowNextTasks, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKShowNextTasks
  If (HKShowNextTasks == "ERROR")
  {
    HKShowNextTasks := "CapsLock & s"
    IniWrite, %HKShowNextTasks%, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKShowNextTasks
  }
  Hotkey, %HKShowNextTasks%, TriggerShowNextTasks
  SetHotkeys .= HKShowNextTasks  

  IniRead, HKToggleAutostart, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKToggleAutostart
  If (HKToggleAutostart != "ERROR")
  {
    IniDelete, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKToggleAutostart
  }

  IniRead, HKExport, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKExport
  If (HKExport == "ERROR")
  {
    HKExport := "CapsLock & e"
    IniWrite, %HKExport%, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKExport
  }
  Hotkey, %HKExport%, TriggerExport
  SetHotkeys .= HKExport  

  IniRead, HKPreferences, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKPreferences
  If (HKPreferences == "ERROR")
  {
    HKPreferences := "CapsLock & p"
    IniWrite, %HKPreferences%, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKPreferences
  }
  Hotkey, %HKPreferences%, TriggerPreferences
  SetHotkeys .= HKPreferences  

  IniRead, HKReload, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKReload
  If (HKReload == "ERROR")
  {
    HKReload := "CapsLock & r"
    IniWrite, %HKReload%, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKReload
  }
  Hotkey, %HKReload%, TriggerReload
  SetHotkeys .= HKReload  

  IniRead, HKSearch, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKSearch
  If (HKSearch == "ERROR")
  {
    HKSearch := "CapsLock & f"
    IniWrite, %HKSearch%, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKSearch
  }
  Hotkey, %HKSearch%, TriggerSearch
  SetHotkeys .= HKSearch  

  IniRead, HKQuit, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKQuit
  If (HKQuit == "ERROR")
  {
    HKQuit := "CapsLock & q"
    IniWrite, %HKQuit%, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKQuit
  }
  Hotkey, %HKQuit%, TriggerQuit
  SetHotkeys .= HKQuit
  
  If (InStr(SetHotkeys,"CapsLock"))
  {
      SetTimer, CheckCapslock, 1000
  }  

  If (FirstStart == 1)
  {
    ShowPreferences()
  }
}

BackupTasks()
{
  global DoBackups, BackupsToKeep
  If (DoBackups)
  {
    If (!FileExist(A_ScriptDir . "\Backups"))
    {
      FileCreateDir, %A_ScriptDir%\Backups
    }
    FormatTime, BackupTime, , yyyy-MM-dd
    FileCopy, %A_ScriptDir%\Tasks.txt, %A_ScriptDir%\Backups\Tasks-%BackupTime%.txt
    
    Count := 0
    Loop, %A_ScriptDir%\Backups\*.*
    {
      Count := Count + 1
      FileList = %FileList%%A_LoopFileName%`n
      Sort, FileList
    }
    If (Count > BackupsToKeep)
    {
      FilesToDelete := Count - BackupsToKeep
      Count := 0
      Loop, parse, FileList, `n
      {
        if (A_LoopField == "")
        {
          Continue
        }
        Count := Count + 1
        If (Count > FilesToDelete)
        {
          Break
        }
        FileDelete, %A_ScriptDir%\Backups\%A_LoopField%
      }
    }
  }
}

Export()
{
  global
  If (!FileExist(A_ScriptDir . "\Export"))
  {
    FileCreateDir, %A_ScriptDir%\Export
  }
  FormatTime, ExportTime, , yyyy-MM-dd-hh-mm-ss
  Export := ""
  Export := "<!doctype html>" 
    . "<html><head><title>Export " . ExportTime . " - " . ApplicationName . "</title>"
    . "<style type=""text/css"">"
    . "body {background-color: #FFF;font-family: Corbel, ""Lucida Grande"", ""Lucida Sans Unicode"", ""Lucida Sans"", ""DejaVu Sans"", ""Bitstream Vera Sans"", ""Liberation Sans"", Verdana, ""Verdana Ref"", sans-serif;} "
    . "table {width:90%; margin:0 auto;border-collapse: collapse;border-spacing: 0;} "
    . "th,td {border:1px solid #666;} "
    . ".done {background:#CDFF7F;} "
    . ".review {background:#F5FF7F;} "
    . ".current {font-weight:bold;} "
    . ".datefield {whitespace:nowrap;} "
    . ".hidedone .done {display:none;} "
    . ".hidereview .review {display:none;} "
    . ".hideunactioned .unactioned {display:none;} "
    . "th {text-align:center;background:#DDD; font-weight:bold;} "
    . "th,td {padding:0.3em;} "
    . "h1 {font-size:16px; color:#666; padding:0; margin:0.5em 0;}"
    . "h2 {font-size:24px; color:#666; padding:0; margin:0.5em 0;}"
    . "#header {margin:0.5em auto; width:90%; position:relative;}"
    . "#displaysettings {display:none;position:absolute;top:0;right:0;margin:0;padding:0;list-style:none;}"
    . "#displaysettings li {cursor:pointer;float:left;margin:0 0.3em; padding:0.2em 0.5em;}"
    . "#displaysettings:before {content: ""Show:"" float:left;}"
    . "#uaswitch { background-color:#999; color:#FFF; border:1px solid #999;}"
    . ".hideunactioned #uaswitch {background-color:#FFF; color:#AAA; border:1px solid #AAA;}"
    . "#rswitch { background-color:#990; color:#FFF; border:1px solid #990;}"
    . ".hidereview #rswitch {background-color:#FFF; color:#AA0; border:1px solid #AA0;}"
    . "#dswitch { background-color:#090; color:#FFF; border:1px solid #090;}"
    . ".hidedone #dswitch {background-color:#FFF; color:#0A0; border:1px solid #0A0;}"
    . ".today {color:#900; }"
    . ".today th { background:#FDD; border:1px solid #900; }"
    . ".today td { border:1px solid #900; }"
    . ".tomorrow {color:#770; }"
    . ".tomorrow th { background:#FFB; border:1px solid #770; }"
    . ".tomorrow td { border:1px solid #770; }"
    . ".has,.hideunactioned .hasUnactioned,.hidedone .hasDone,.hidereview .hasReview,.hideunactioned.hidedone .hasUnactionedDone,.hideunactioned.hidereview .hasUnactionedReview,.hidedone.hidereview .hasDoneReview,.hideunactioned.hidedone.hidereview hasUnactionedDoneReview { display: none;}"
    . ".hidedone .doneCol,.hidereview .reviewCol { display:none;}"
    . "</style>"
    . "</head><body class=""hidedone hidereview"">"
    . "<div id=""header"">"
    . "<h1>" . ApplicationName . "</h1>"
    . "<h2>Export " . ExportTime . "</h2>"
    . "<ul id=""displaysettings"">"
    . "<li id=""uaswitch"" onclick=""toggleUnactioned()"">unactioned</li>"
    . "<li id=""dswitch"" onclick=""toggleDone()"">done</li>"
  If (System != "DWM")
  {
    Export .= "<li id=""rswitch"" onclick=""toggleReview()"">on review</li></ul>"
  }
  Export .= "</div>"
    . "<table cellspacing=""0"">"

  AllCounter := 0
  UnactionedCounter := 0
  DoneCounter := 0
  ReviewCounter := 0
  ExportHeader := ""

  If (and System == "AF1" or System == "AF3")
  {
    ExportHeader := "<tr class=""CONSISTCLASS""><th colspan=""5"">Page 1</th></tr>"
    ExportHeader .= "<tr class=""CONSISTCLASS""><th>Task</th><th>Added</th><th class=""reviewCol"">On&nbsp;Review</th><th class=""doneCol""><nobr>Done/Re-Added</nobr></th><th class=""doneCol"">Time</th></tr>"
  }
  
  If (System == "AF4")
  {
    ExportHeader := "<tr class=""CONSISTCLASS""><th colspan=""5"">"
    If (HasClosedList)
    {
      ExportHeader .= "Closed List"
    }
    Else
    {
      ExportHeader .= "Open List"
    }
          ExportHeader .= "</th></tr>"
    ExportHeader .= "<tr class=""CONSISTCLASS""><th>Task</th><th>Added</th><th class=""reviewCol"">On&nbsp;Review</th><th class=""doneCol""><nobr>Done/Re-Added</nobr></th><th class=""doneCol"">Time</th></tr>"
  }

  ExportPage := 1
  FormatTime, Today,, yyyyMMdd
  Tomorrow := A_Now
  Tomorrow += 1, days
  FormatTime, Tomorrow, %Tomorrow%, yyyyMMdd    
  ExprtCurrentExpires := 0

  Loop, %TaskCount%
  {
    ExportAdded := ""
    ExportReview := ""
    ExportDone := ""
    ExprtTime := ""
    
    AllCounter += 1
    Loop, Parse, Tasks%A_Index%_2, %A_Space%
    {
      If (InStr(A_LoopField, "D"))
      {
        ExportDone := SubStr(A_LoopField, 2)
        FormatTime, ExportDone, %ExportDone%, yyyy-MM-dd'&nbsp;'H:mm
      }
      If (InStr(A_LoopField, "R"))
      {
        ExportReview := SubStr(A_LoopField, 2)
        FormatTime, ExportReview, %ExportReview%, yyyy-MM-dd'&nbsp;'H:mm
      }
      If (InStr(A_LoopField, "A"))
      {
        ExportAdded := SubStr(A_LoopField, 2)                               
        FormatTime, ExportAdded, %ExportAdded%, yyyy-MM-dd'&nbsp;'H:mm
      }
      If (InStr(A_LoopField, "T"))
      {
        ExprtTime := SubStr(A_LoopField, 2)
        ExprtTime := SecondsToFormattedTime(ExprtTime)
      }

      WarningClass := ""
      If (System == "DWM" and InStr(A_LoopField, "E"))
      {
        ExprtExpires := SubStr(A_LoopField, 2,8)
        If (ExprtCurrentExpires < ExprtExpires)
        {
          ExprtCurrentExpires := ExprtExpires
          If (ExprtCurrentExpires == Today)
          {
            ExprtHeading := "Expiring Today"
            WarningClass := " class=""today CONSISTCLASS"""
          }
          Else If (ExprtCurrentExpires == Tomorrow)
          {
            ExprtHeading := "Expiring Tomorrow"
            WarningClass := " class=""tomorrow CONSISTCLASS"""
          }
          Else
          {
            FormatTime, ExprtFormattedExpires, %ExprtCurrentExpires%, yyyy-MM-dd
            ExprtHeading := "Expiring " . ExprtFormattedExpires
            WarningClass := " class=""CONSISTCLASS"""
          }
        
          If (ExportHeader != "")
          {
            If (AllCounter > 0)
            {
              HeaderClass := "has"
              If (UnactionedCounter > 0)
              {
                HeaderClass .= "Unactioned"
              }
              If (DoneCounter > 0)
              {
                HeaderClass .= "Done"
              }
              If (ReviewCounter > 0)
              {
                HeaderClass .= "Review"
              }
              StringReplace, ExportHeader, ExportHeader, CONSISTCLASS, %HeaderClass%, All
              
              Export .= ExportHeader . ExportSegment
            }
            ExportSegment := ""
            AllCounter := 0
            UnactionedCounter := 0
            DoneCounter := 0
            ReviewCounter := 0
          }
          
          ExportHeader := "<tr" . WarningClass . "><th colspan=""5"">" . ExprtHeading . "</th></tr>"
            . "<tr" . WarningClass . "><th>Task</th><th>Added</th><th class=""reviewCol"">On Review</th><th class=""doneCol""><nobr>Done/Re-Added</nobr></th><th class=""doneCol"">Time</th></tr>"
        }
      }

    }
    If ((System == "AF1" or System == "AF3") and ExportPage < ceil(A_Index/TasksPerPage))
    {
      ExportPage += 1
      If (AllCounter > 0)
      {
        HeaderClass := "has"
        If (UnactionedCounter > 0)
        {
          HeaderClass .= "Unactioned"
        }
        If (DoneCounter > 0)
        {
          HeaderClass .= "Done"
        }
        If (ReviewCounter > 0)
        {
          HeaderClass .= "Review"
        }
        StringReplace, ExportHeader, ExportHeader, CONSISTCLASS, %HeaderClass%, All
        
        Export .= ExportHeader . ExportSegment
      }
      ExportSegment := ""
      AllCounter := 0
      UnactionedCounter := 0
      DoneCounter := 0
      ReviewCounter := 0
      ExportHeader := "<tr class=""CONSISTCLASS""><th colspan=""5"">Page " . ExportPage . "</th></tr>"
        . "<tr class=""CONSISTCLASS""><th>Task</th><th>Added</th><th class=""reviewCol"">On Review</th><th class=""doneCol""><nobr>Done/Re-Added</nobr></th><th class=""doneCol"">Time</th></tr>"
    }
    ExportSegment .= "<tr"
    ExportSegment .= " class="""
    If (InStr(Tasks%A_Index%_2, "R"))
    {
      ReviewCounter += 1
      ExportSegment .= "review"
    }
    Else If (InStr(Tasks%A_Index%_2, "D"))
    {
      DoneCounter += 1
      ExportSegment .= " done"
    }
    Else
    {
      UnactionedCounter += 1
      ExportSegment .= " unactioned"            
        }
        If (A_Index == CurrentTask)
        {
      ExportSegment .= " current"                    
        }
        If (WarningClass==" class=""today""")
        {
      ExportSegment .= " today"                    
        }
        Else If (WarningClass==" class=""tomorrow""")
        {
      ExportSegment .= " tomorrow"                    
        }
    ExportSegment .= """"
    ExportSegment .= ">"
        . "<td>" 
          . Tasks%A_Index%_1
        . "</td>"
  
    ExportSegment .= "<td><nobr>" 
          . ExportAdded
        . "<nobr></td>"
        . "<td class=""reviewCol""><nobr>" 
          . ExportReview
        . "<nobr></td>"
        . "<td class=""doneCol""><nobr>" 
          . ExportDone
        . "</nobr></td>"
        . "<td class=""doneCol""><nobr>" 
          . ExprtTime
        . "</nobr></td>"
        
    
    ExportSegment .= "</tr>"
    If (System == "AF4" and HasClosedList and A_Index == LastTaskInClosedList and LastTaskInClosedList != TaskCount)
    {
      If (AllCounter > 0)
      {
        HeaderClass := "has"
        If (UnactionedCounter > 0)
        {
          HeaderClass .= "Unactioned"
        }
        If (DoneCounter > 0)
        {
          HeaderClass .= "Done"
        }
        If (ReviewCounter > 0)
        {
          HeaderClass .= "Review"
        }
        StringReplace, ExportHeader, ExportHeader, CONSISTCLASS, %HeaderClass%, All
        
        Export .= ExportHeader . ExportSegment
      }
      ExportSegment := ""
      AllCounter := 0
      UnactionedCounter := 0
      DoneCounter := 0
      ReviewCounter := 0
      ExportHeader := "<tr class=""CONSISTCLASS""><th colspan=""5"">Open List</th></tr>"
      . "<tr class=""CONSISTCLASS""><th>Task</th><th>Added</th><th class=""reviewCol"">On Review</th><th class=""doneCol""><nobr>Done/Re-Added</nobr></th><th class=""doneCol"">Time</th></tr>"
    }
  }


  If (ExportSegment != "")
  {
    If (AllCounter > 0)
    {
      HeaderClass := "has"
      If (UnactionedCounter > 0)
      {
        HeaderClass .= "Unactioned"
      }
      If (DoneCounter > 0)
      {
        HeaderClass .= "Done"
      }
      If (ReviewCounter > 0)
      {
        HeaderClass .= "Review"
      }
      StringReplace, ExportHeader, ExportHeader, CONSISTCLASS, %HeaderClass%, All
      Export .= ExportHeader . ExportSegment
    }
    ExportSegment := ""
    AllCounter := 0
    UnactionedCounter := 0
    DoneCounter := 0
    ReviewCounter := 0
  }
    
  Export .= "</table>"

  Export .= "<script type=""text/javascript"">"
    . "var unactionedHidden = false;"
    . "var reviewHidden = true;"
    . "var doneHidden = true;"
    . "setBodyClass();"
    . "function setBodyClass()"
    . "{"
    . "var b = document.body;"
    . "b.className = """";"
    . "b.className = unactionedHidden ? b.className + ' hideunactioned' : b.className;"
    . "b.className = reviewHidden ? b.className + ' hidereview' : b.className;"
    . "b.className = doneHidden ? b.className + ' hidedone' : b.className;"
    . "var s = document.getElementById('displaysettings');"
    . "s.style.display = 'block';"
    . "}"
    . "function toggleUnactioned()"
    . "{"
    . "unactionedHidden = unactionedHidden ? false : true;"
    . "setBodyClass();"
    . "}"
    . "function toggleDone()"
    . "{"
    . "doneHidden = doneHidden ? false : true;"
    . "setBodyClass();"
    . "}"
    . "function toggleReview()"
    . "{"
    . "reviewHidden = reviewHidden ? false : true;"
    . "setBodyClass();"
    . "}"
    . "</script>"
  Export .= "</body></html>"
  
  FileDelete, %A_ScriptDir%\Export\Tasks-%ExportTime%.html
  FileAppend, %Export%, %A_ScriptDir%\Export\Tasks-%ExportTime%.html 
  Run, %A_ScriptDir%\Export\Tasks-%ExportTime%.html 
}
