; AutofocusAHK
;
; Functions that read from or write to the file system
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9
; @since     0.9

; Load tasks from file Tasks.txt
LoadTasks()
{
	global
	TaskCount := 0
	UnactionedCount := 0
	Loop, read, %A_ScriptDir%\Tasks.txt
	{
		Loop, parse, A_LoopReadLine, %A_Tab%
		{
      NewTask_%A_Index% := A_LoopField
		}
	  IsValidTask := %System%_IsValidTask(NewTask_1, NewTask_2)

    if (IsValidTask)
    {
  		TaskCount := TaskCount + 1
  	  Tasks%TaskCount%_1 := NewTask_1
  	  Tasks%TaskCount%_2 := NewTask_2
	  
  
  		If (InStr(Tasks%TaskCount%_2, "D") or InStr(Tasks%TaskCount%_2, "R"))
  		{
  			Tasks%TaskCount%_3 := 1
  			If (!InStr(Tasks%TaskCount%_2, "D") and InStr(Tasks%TaskCount%_2, "R"))
  			{
  				HasTasksOnReview := 1
  			}
  		}
  		Else
  		{
  			Tasks%TaskCount%_3 := 0
  			UnactionedCount := UnactionedCount +1
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
		Content := Content . Tasks%A_Index%_1 . A_Tab . Tasks%A_Index%_2 . "`n"
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
	IniRead, System, %A_ScriptDir%\AutofocusAHK.ini, General, System
	If (System == "ERROR")
	{
	  FirstStart := 1
		System := "AF4"
		IniWrite, %System%, %A_ScriptDir%\AutofocusAHK.ini, General, System
	}
	IniRead, StartWithWindows, %A_ScriptDir%\AutofocusAHK.ini, General, StartWithWindows
	If (StartWithWindows == "ERROR")
	{
		StartWithWindows := 0
		ToggleStartup()
	}
	IniRead, DoBackups, %A_ScriptDir%\AutofocusAHK.ini, General, DoBackups
	If (DoBackups == "ERROR")
	{
		DoBackups := 1
		IniWrite, %DoBackups%, %A_ScriptDir%\AutofocusAHK.ini, General, DoBackups
	}
	IniRead, BackupsToKeep, %A_ScriptDir%\AutofocusAHK.ini, General, BackupsToKeep
	If (BackupsToKeep == "ERROR")
	{
		BackupsToKeep := 10
		IniWrite, %BackupsToKeep%, %A_ScriptDir%\AutofocusAHK.ini, General, BackupsToKeep
	}
	IniRead, LastRoutine, %A_ScriptDir%\AutofocusAHK.ini, ReviewMode, LastRoutine
	If (LastRoutine == "ERROR")
	{
		LastRoutine := Now
		IniWrite, %LastRoutine%, %A_ScriptDir%\AutofocusAHK.ini, ReviewMode, LastRoutine
	}
	IniRead, StartRoutineAt, %A_ScriptDir%\AutofocusAHK.ini, ReviewMode, StartRoutineAt
	If (StartRoutineAt == "ERROR")
	{
		StartRoutineAt := 6
		IniWrite, %StartRoutineAt%, %A_ScriptDir%\AutofocusAHK.ini, ReviewMode, StartRoutineAt
	}
	IniRead, TasksPerPage, %A_ScriptDir%\AutofocusAHK.ini, ForwardMode, TasksPerPage
	If (TasksPerPage == "ERROR")
	{
		TasksPerPage := 20
		IniWrite, %TasksPerPage%, %A_ScriptDir%\AutofocusAHK.ini, ForwardMode, TasksPerPage
	}
	IniRead, HKAddTask, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKAddTask
	If (HKAddTask == "ERROR")
	{
		HKAddTask := "CapsLock & a"
		IniWrite, %HKAddTask%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKAddTask
	}
	Hotkey, %HKAddTask%, TriggerAddTask
	IniRead, HKWork, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKWork
	If (HKWork == "ERROR")
	{
		HKWork := "CapsLock & d"
		IniWrite, %HKWork%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKWork
	}
	Hotkey, %HKWork%, TriggerWork
	IniRead, HKShowNextTasks, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKShowNextTasks
	If (HKShowNextTasks == "ERROR")
	{
		HKShowNextTasks := "CapsLock & s"
		IniWrite, %HKShowNextTasks%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKShowNextTasks
	}
	Hotkey, %HKShowNextTasks%, TriggerShowNextTasks
	IniRead, HKToggleAutostart, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKToggleAutostart
	If (HKToggleAutostart != "ERROR")
	{
		IniDelete, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKToggleAutostart
	}
	IniRead, HKExport, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKExport
	If (HKExport == "ERROR")
	{
		HKExport := "CapsLock & e"
		IniWrite, %HKExport%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKExport
	}
	Hotkey, %HKExport%, TriggerExport
	IniRead, HKPreferences, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKPreferences
	If (HKPreferences == "ERROR")
	{
		HKPreferences := "CapsLock & p"
		IniWrite, %HKPreferences%, %A_ScriptDir%\AutofocusAHK.ini, HotKeys, HKPreferences
	}
	Hotkey, %HKPreferences%, TriggerPreferences

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
	FormatTime, ExportTime, , yyyy-MM-dd
	Export := ""
	Export := "<!doctype html>" 
		. "<html><head><title>Export " . ExportTime . " - AutofocusAHK</title>"
		. "<style type=""text/css"">"
		. "body {background-color: #FFF;font-family: Corbel, ""Lucida Grande"", ""Lucida Sans Unicode"", ""Lucida Sans"", ""DejaVu Sans"", ""Bitstream Vera Sans"", ""Liberation Sans"", Verdana, ""Verdana Ref"", sans-serif;} "
		. "table {width:90%; margin:0 auto;border-collapse: collapse;border-spacing: 0;} "
		. "th,td {border:1px solid #666;} "
		. ".done {background:#CDFF7F;} "
		. ".review {background:#F5FF7F;} "
		. ".datefield {whitespace:nowrap;} "
		. "th {text-align:center;background:#DDD; font-weight:bold;} "
		. "th,td {padding:0.3em;} "
		. "h1 {font-size:16px; color:#666; padding:0; margin:0.5em auto; width:90%;}"
		. "h2 {font-size:24px; color:#666; padding:0; margin:0.5em auto; width:90%;}"
		. "</style>"
		. "</head><body>"
		. "<h1>AutofocusAHK</h1>"
		. "<h2>Export " . ExportTime . "</h2><table cellspacing=""0"">"
		
  If (System == "AF1" or System == "AF3")
  {
    Export .= "<tr><th colspan=""4"">Page 1</th></tr>"
  }
  If (System == "AF4")
  {
    Export .= "<tr><th colspan=""4"">"
    If (HasClosedList)
    {
      Export .= "Closed List"
    }
    Else
    {
      Export .= "Open List"    
    }
          Export .= "</th></tr>"
  }
		Export .= "<tr><th>Task</th><th>Added</th><th>On&nbsp;Review</th><th><nobr>Done/Re-Added</nobr></th></tr>"
		ExportPage := 1
	Loop, %TaskCount%
	{
		If ((System == "AF1" or System == "AF3") and ExportPage < ceil(A_Index/TasksPerPage))
		{
			ExportPage := ExportPage + 1
			Export .= "<tr><th colspan=""4"">Page " . ExportPage . "</th></tr>"
			. "<tr><th>Task</th><th>Added</th><th>On Review</th><th><nobr>Done/Re-Added</nobr></th></tr>"
		}
		Export .= "<tr"
		If (Tasks%A_Index%_3 == 1)
		{
			Export .= " class="""
			If (InStr(Tasks%A_Index%_2, "R"))
			{
				Export .= "review"
			}
			Else If (InStr(Tasks%A_Index%_2, "D"))
			{
				Export .= " done"
			}
			Export .= """"
		}
		Export .= ">"
				. "<td>" 
					. Tasks%A_Index%_1
				. "</td>"
		ExportAdded := ""
		ExportReview := ""
		ExportDone := ""
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

		}
		Export .= "<td><nobr>" 
					. ExportAdded
				. "<nobr></td>"
				. "<td><nobr>" 
					. ExportReview
				. "<nobr></td>"
				. "<td><nobr>" 
					. ExportDone
				. "</nobr></td>"
		
		Export .= "</tr>"
		If (System == "AF4" and HasClosedList and A_Index == LastTaskInClosedList and LastTaskInClosedList != TaskCount)
		{
			Export .= "<tr><th colspan=""4"">Open List</th></tr>"
			. "<tr><th>Task</th><th>Added</th><th>On Review</th><th><nobr>Done/Re-Added</nobr></th></tr>"
		}
  }
	
	Export .= "</table></body></html>"
	
	FileDelete, %A_ScriptDir%\Export\Tasks-%ExportTime%.html
	FileAppend, %Export%, %A_ScriptDir%\Export\Tasks-%ExportTime%.html 
	Run, %A_ScriptDir%\Export\Tasks-%ExportTime%.html 
}
