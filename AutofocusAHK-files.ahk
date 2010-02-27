; AutofocusAHK
;
; Functions that read from or write to the file system
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5.2
; @since     0.9

; Load tasks from file Tasks.txt
LoadTasks()
{
  global

  WriteToLog("Function", "Begin LoadTasks()", 1)

  TaskCount := 0
  UnactionedCount := 0
  RessourceTasksWriteAccess += 1

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

    If (IsValidTask and !InStr(NewTask_2, "U"))
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
      Else If (TicklePos := InStr(Tasks%TaskCount%_2, "S"))
      {
        Tasks%TaskCount%_4 := 1
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
      %System%_PostTaskAdd()
    }
  }

  RessourceTasksWriteAccess -= 1
  %System%_PostTaskLoad()
  
  WriteToLog("Function", "End LoadTasks()", -1)
}

; Save tasks to file Tasks.txt
SaveTasks()
{
  global

  WriteToLog("Function", "Begin SaveTasks()", 1)

  If (RessourceTasksWriteAccess == 0)
  {
    WriteToLog("Ressource", "Tasks can be saved")
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
  Else
  {
    WriteToLog("Ressource", "Tasks can not be saved")
  }

  WriteToLog("Function", "End SaveTasks()", -1)
}

; Load configuration from AutofocusAHK.ini
LoadConfig()
{
  global

  FirstStart := 0
  IfNotExist, %A_ScriptDir%\%ApplicationName%.ini
  {
    FirstStart := 1
  }
  FormatTime, Now, , yyyyMMdd
  FormatTime, Hour, , H
  
  System := LoadSetting("System", "General", "AF4")

  If (System == "AF5")
  {
    System := "DWM"
    SaveSetting("System", System, "General")
  }

  IniRead, HKToggleAutostart, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKToggleAutostart
  If (HKToggleAutostart != "ERROR")
  {
    IniDelete, %A_ScriptDir%\%ApplicationName%.ini, HotKeys, HKToggleAutostart
  }

  StartWithWindows := LoadSetting("StartWithWindows", "General", 0)
  DoBackups := LoadSetting("DoBackups", "General", 1)
  BackupsToKeep := LoadSetting("BackupsToKeep", "General", 10)
  LastRoutine := LoadSetting("LastRoutine", "ReviewMode", Now)
  StartRoutineAt := LoadSetting("StartRoutineAt", "ReviewMode", 6)
  TasksPerPage := LoadSetting("TasksPerPage", "ForwardMode", 20)
  CurrentTask := LoadSetting("CurrentTask", "General", 0)
  ActionOnCurrentPass := LoadSetting("ActionOnCurrentPass", "General", 0)
  CurrentPass := LoadSetting("CurrentPass", "General", 1)
  ExpirationNew := LoadSetting("ExpirationNew", "DWM", 28)
  ExpirationReAdd := LoadSetting("ExpirationReAdd", "DWM", 7)
  HideOnLostFocus := LoadSetting("HideOnLostFocus", "GUI", 1)
  GuiAlwaysOnTop := LoadSetting("AlwaysOnTop", "GUI", 1)
  GuiHideTaskbarButton := LoadSetting("HideTaskbarButton", "GUI", 1)

  SetHotkeys := ""

  HKAddTask := LoadSetting("HKAddTask", "Hotkeys", "CapsLock & a")
  Hotkey, %HKAddTask%, TriggerAddTask
  SetHotkeys .= HKAddTask
  
  HKWork := LoadSetting("HKWork", "Hotkeys", "CapsLock & d")
  Hotkey, %HKWork%, TriggerWork
  SetHotkeys .= HKWork

  HKShowNextTasks := LoadSetting("HKShowNextTasks", "Hotkeys", "CapsLock & s")
  Hotkey, %HKShowNextTasks%, TriggerShowNextTasks
  SetHotkeys .= HKShowNextTasks

  HKExport := LoadSetting("HKExport", "Hotkeys", "CapsLock & e")
  Hotkey, %HKExport%, TriggerExport
  SetHotkeys .= HKExport

  HKPreferences := LoadSetting("HKPreferences", "Hotkeys", "CapsLock & p")
  Hotkey, %HKPreferences%, TriggerPreferences
  SetHotkeys .= HKPreferences

  HKReload := LoadSetting("HKReload", "Hotkeys", "CapsLock & r")
  Hotkey, %HKReload%, TriggerReload
  SetHotkeys .= HKReload

  HKSearch := LoadSetting("HKSearch", "Hotkeys", "CapsLock & f")
  Hotkey, %HKSearch%, TriggerSearch
  SetHotkeys .= HKSearch

  HKQuit := LoadSetting("HKQuit", "Hotkeys", "CapsLock & q")
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

LoadSetting(Setting, Section = "System", Default = "")
{
  Global ApplicationName

  WriteToLog("Function", "Begin LoadSetting(" . Setting . ", " . Section . ", " . Default . ")", 1)
  IniRead, Result, %A_ScriptDir%\%ApplicationName%.ini, %Section%, %Setting%

  If (Result == "ERROR")
  {
    Result := Default
    SaveSetting(Setting, Result, Section)
  }

  WriteToLog("Function", "End LoadSetting(" . Setting . ", " . Section . ", " . Default . "), Return: " . Result, -1)

  Return Result
}

SaveSetting(Setting, Value, Section = "System")
{
  Global ApplicationName

  WriteToLog("Function", "Begin SaveSetting(". Setting . ", " . Value . ", " . Section . ")", 1)
  IniWrite, %Value%, %A_ScriptDir%\%ApplicationName%.ini, %Section%, %Setting%
  WriteToLog("Function", "End SaveSetting(". Setting . ", " . Value . ", " . Section . ")", -1)
}
BackupTasks()
{
  global DoBackups, BackupsToKeep

  WriteToLog("Function", "Begin BackupTasks()", 1)

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
        If (A_LoopField == "")
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

  WriteToLog("Function", "End BackupTasks()", -1)
}

Export()
{
  global

  WriteToLog("Function", "Begin Export()", 1)

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

  If (System == "AF1" or System == "AF3")
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
    If (!InStr(Tasks%A_Index%_2, "S"))
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

      FormatTime, Today, , yyyyMMdd 
      Expires := SubStr(Tasks%A_Index%_2, InStr(Tasks%A_Index%_2, "E")+1,8)
      
      If ((System == "DWM" and Expires >= Today) or System != "DWM")
      {
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
      }
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
  WriteToLog("Function", "End Export()", -1)
}

WriteToLog(Type, Message, Increment = 0)
{
  global LogFile, LogIndent, SettingDebugLoggingEnabled

  If (SettingDebugLoggingEnabled)
  {
    If (Increment < 0)
    {
      LogIndent += Increment
    }

    FormatTime, LogLine, , yyyy-MM-dd HH:mm:ss
    
    Loop, %LogIndent%
    {
      LogLine .= "  "
    }

    LogLine .= " [" . Type . "] " . Message

    FileAppend, %LogLine%`n, %LogFile%

    If (Increment > 0)
    {
      LogIndent += Increment
    }
  }
}

InitializeLog()
{
  global LogFile, LogIndent, SettingDebugLoggingEnabled

  SettingDebugLoggingEnabled := LoadSetting("LoggingEnabled", "Debug", 0)

  If (SettingDebugLoggingEnabled and !FileExist(A_ScriptDir . "\Logs"))
  {
    FileCreateDir, %A_ScriptDir%\Logs
  }

  LogFile := A_ScriptDir . "\Logs\" . A_Now . ".txt"
  LogIndent := 0
}