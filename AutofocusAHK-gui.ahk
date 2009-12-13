; AutofocusAHK
;
; Functions that create/modify the graphical user inferface
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.2.2
; @since     0.9


; Show Next Tasks
ShowNextTasks()
{
	global
	If (UnactionedCount <= 0)
	{
		MsgBox No unactioned tasks!
		Return
	}
	PreviousTask := CurrentTask
	CreatingList := 1
	
	Message := ""
	Count := 10
	If (UnactionedCount < 10)
	{
		Count := UnactionedCount
	}
	Gui, Destroy
	Gui +LastFound
	Gui, Font, Bold
	Gui, Add, Text, xm w600 Center, Next Tasks
	Gui, Font, Norm
	Gui, Add, ListView, NoSortHdr Count%Count% -ReadOnly -WantF2 xm r%Count% w600 vNextListView, Description|Added
	Loop %Count%
	{
		GetCurrentMetadata()
		LV_Add("", Tasks%CurrentTask%_1, CurrentAdded)
		SelectNextTask()
	}
	CurrentTask := PreviousTask
	CreatingList := 0
	LV_ModifyCol(2,"Auto")
	SendMessage, 4125, 1, 0, SysListView321
	Width := ErrorLevel
	LV_ModifyCol(1, Width)
	LV_ModifyCol(2,"AutoHdr")
	SendMessage, 4125, 1, 0, SysListView321
	LV_ModifyCol(2, Width)
	LV_ModifyCol(1, ErrorLevel)
 	GuiControl, Disable, NextListView

  If(System == "AF3" or System == "AF2")
  {
  	Gui, Font, Bold
  	Gui, Add, Text, xm w600 Center, On Notice for Review
  	Gui, Font, Norm
  
  	NoticeCount := 0
  	Loop %TaskCount%
  	{
  		If (Tasks%A_Index%_4 == 0 and InStr(Tasks%A_Index%_2, "N"))
  		{
  			NoticeCount += 1
  		}
  	}
  
  	
  	First := 1
  	Loop %TaskCount%
  	{
  		If (Tasks%A_Index%_4 == 0 and InStr(Tasks%A_Index%_2, "N"))
  		{
  			If (First)
  			{
  				First := 0
  				Gui, Add, ListView, NoSortHdr Count%NoticeCount% -ReadOnly -WantF2 xm r%NoticeCount% w600 vNoticeListView, Description|Added
  			}
  			GetTaskMetadata(A_Index)
  			LV_Add("", Tasks%A_Index%_1, TaskAdded)
  		}
  	}
  	If (First == 1)
  	{
  		Gui, Add, Text, xm,There are currently no tasks on notice.
  	}
  
  	LV_ModifyCol(2, Width)
  	LV_ModifyCol(1, ErrorLevel)
  	GuiControl, Disable, NoticeListView
  }
	Gui, Show, AutoSize, Show Tasks - %System% - AutofocusAHK %Ver%
}

;Add a New Task
AddTask()
{
	global
	Gui, 3:Destroy
	Gui, 3:Add, Edit, w400 vNewTask  ; The ym option starts a new column of controls.
	Gui, 3:Add, Button,ym vAddNotesButton gButtonAddNotes, &Notes
	Gui, 3:Add, Button,ym default gButtonAdd vAddTaskButton, &Add
	Gui, 3:Add, Edit,xm Hidden T8 R10 default vAddNotesBox
	Gui, 3:+LabelGuiAdd
	Gui, 3:Show, AutoSize, Add Task - %System% - AutofocusAHK %Ver%
}

ToggleStartup()
{
	If (StartWithWindows)
	{
		Message := "Autostart is currently enabled."
	}
	Else 
	{
		Message := "Autostart is currently disabled."
	}
	Message := Message . "`n`nDo you want AutofocusAHK to start with Windows in the future?"

	MsgBox, 4, AutofocusAHK %Ver%, %Message%
	IfMsgBox Yes
	{
		FileCreateShortcut, "%A_ScriptFullPath%", %A_Startup%\AutofocusAHK.lnk, %A_ScriptDir% 
		StartWithWindows := 1
		IniWrite, 1, %A_ScriptDir%\AutofocusAHK.ini, General, StartWithWindows
	}
	IfMsgBox No
	{
		FileDelete, %A_Startup%\AutofocusAHK.lnk
		StartWithWindows := 0
		IniWrite, 0, %A_ScriptDir%\AutofocusAHK.ini, General, StartWithWindows
	}
}


ShowWorkWindow()
{
	global
	Gui, Destroy
	Gui, Font, Bold
	Gui, Add, Text, Y20 w500 Center vTaskControl, % Tasks%CurrentTask%_1
	Gui, Font, Norm
	GuiControlGet, TaskPos, Pos, TaskControl
	NewY := TaskPosY + TaskPosH + 20
	NewYT := NewY + 5
	Gui, Add, Button, gButtonShowNotes vShowNotesButton x%TaskPosX% Y%NewY%, &Show Notes
	GuiControl, Text, ModeControl, ForwardMode
	;GuiControl, Move, TaskControl, w200 h100
	Gui, Add, Text, vQuestionLabel Y%NewYT%,Does this task feel ready to be done? 
	Gui, Add, Button, gButtonReady vYesButton Y%NewY%, &Yes
	Gui, Add, Button, gButtonNotReady vNoButton Y%NewY% Default, &No
	;Gui, Add, Button, vCancelButton Y%NewY%, &Cancel
	;GuiControlGet, CancelPos, Pos, CancelButton
	;DiffX := CancelPosX + CancelPosW - TaskPosX - TaskPosW
	;CancelPosX := CancelPosX - DiffX
	;GuiControl, Move, CancelButton, x%CancelPosX% y%CancelPosY% w%CancelPosW% h%CancelPosH%
	GuiControlGet, NoPos, Pos, NoButton
	DiffX := NoPosX + NoPosW - TaskPosX - TaskPosW
	NoPosX := NoPosX - DiffX
	GuiControl, Move, NoButton, x%NoPosX% y%NoPosY% w%NoPosW% h%NoPosH%
	GuiControlGet, YesPos, Pos, YesButton
	YesPosX := YesPosX - DiffX
	GuiControl, Move, YesButton, x%YesPosX% y%YesPosY% w%YesPosW% h%YesPosH%
	GuiControlGet, QuestionPos, Pos, QuestionLabel
	QuestionPosX := QuestionPosX - DiffX
	GuiControl, Move, QuestionLabel, x%QuestionPosX% y%QuestionPosY% w%QuestionPosW% h%QuestionPosH%
	Title := %System%_GetWorkWindowTitle()
	If(Tasks%CurrentTask%_3 == "")
	{
        GuiControl Disable, ShowNotesButton
    }
    StringReplace, ShowNotesBoxContent, Tasks%CurrentTask%_3,\t,%A_Tab%, All
    StringReplace, ShowNotesBoxContent, ShowNotesBoxContent,\n,`n, All
	Gui, Add, Edit,xm Hidden ReadOnly T8 R10 default vShowNotesBox, %ShowNotesBoxContent%
	Gui, Show, Center Autosize, %Title%
	GuiControl, Focus, NoButton
	Return
}

ShowDoneWindow()
{
	global
	SetTimer,UpdateTime,Off
	Gui, 2:Destroy
	Gui, Destroy
	Gui, Add, Text, vWorkingOn, You were working on
	GuiControlGet, WorkingPos, Pos, WorkingOn
	NewY := WorkingPosY + WorkingPosH + 20
	Gui, Font, Bold
	Gui, Add, Text, x%WorkingPosX% Y%NewY% w500 Center vTaskControl, % Tasks%CurrentTask%_1
	Gui, Font, Norm
	GuiControlGet, TaskPos, Pos, TaskControl
	Gui, Add, Edit,X%TaskPosX% Y%TaskPosY% W%TaskPosW% Hidden vRephraseBox, % Tasks%CurrentTask%_1
    
	NewY := TaskPosY + TaskPosH + 20
	NewYT := NewY + 5
	GuiControl, Text, ModeControl, ForwardMode
	;GuiControl, Move, TaskControl, w200 h100
	Gui, Add, Button, gButtonRephrase vRephraseButton x%TaskPosX% Y%NewY%, &Rephrase
	GuiControlGet, RephrasePos, Pos, RephraseButton
	NewX := RephrasePosX + RephrasePosX + RephrasePosW
	Gui, Add, Button, gButtonShowNotes vShowNotesButton X%NewX% Y%NewY%, &Edit Notes
	Gui, Add, Text, vQuestionLabel Y%NewYT%,Do you want to re-add this task?
	Gui, Add, Button, gButtonReAdd vYesButton Y%NewY%, &Yes
	Gui, Add, Button, gButtonNoReAdd vNoButton Y%NewY% Default, &No
	;Gui, Add, Button, vCancelButton Y%NewY%, &Cancel
	;GuiControlGet, CancelPos, Pos, CancelButton
	;DiffX := CancelPosX + CancelPosW - TaskPosX - TaskPosW
	;CancelPosX := CancelPosX - DiffX
	;GuiControl, Move, CancelButton, x%CancelPosX% y%CancelPosY% w%CancelPosW% h%CancelPosH%
	
    GuiControlGet, NoPos, Pos, NoButton
	DiffX := NoPosX + NoPosW - TaskPosX - TaskPosW
	NoPosX := NoPosX - DiffX
	GuiControl, Move, NoButton, x%NoPosX% y%NoPosY% w%NoPosW% h%NoPosH%
	GuiControlGet, YesPos, Pos, YesButton
	YesPosX := YesPosX - DiffX
	GuiControl, Move, YesButton, x%YesPosX% y%YesPosY% w%YesPosW% h%YesPosH%
	GuiControlGet, QuestionPos, Pos, QuestionLabel
	QuestionPosX := QuestionPosX - DiffX
	GuiControl, Move, QuestionLabel, x%QuestionPosX% y%QuestionPosY% w%QuestionPosW% h%QuestionPosH%
	
    Gui, +LabelGuiDone
    StringReplace, ShowNotesBoxContent, Tasks%CurrentTask%_3,\t,%A_Tab% , All
    StringReplace, ShowNotesBoxContent, ShowNotesBoxContent,\n,`n, All
	Gui, Add, Edit,xm Hidden T8 R10 default vShowNotesBox, %ShowNotesBoxContent%
	Gui, Show, Center Autosize, Done - AutofocusAHK %Ver% 
	GuiControl, Focus, YesButton
	Return
}


ShowReviewWindow()
{
	global
	Gui, Destroy
	Gui, Add, Text, vReviewing, The following task is on review:
	GuiControlGet, ReviewingPos, Pos, Reviewing
	NewY :=ReviewingPosY + ReviewingPosH + 20
	Gui, Font, Bold
	Gui, Add, Text, x%ReviewingPosX% Y%NewY% w500 Center vTaskControl, % Tasks%ReviewTask%_1
	Gui, Font, Norm
	GuiControlGet, TaskPos, Pos, TaskControl
	Gui, Add, Edit,X%TaskPosX% Y%TaskPosY% W%TaskPosW% Hidden vRephraseBox, % Tasks%ReviewTask%_1
	NewY := TaskPosY + TaskPosH + 20
	NewYT := NewY + 5

	Gui, Add, Button, gButtonRephrase vRephraseButton x%TaskPosX% Y%NewY%, &Rephrase
	GuiControlGet, RephrasePos, Pos, RephraseButton
	NewX := RephrasePosX + RephrasePosX + RephrasePosW
	Gui, Add, Button, gButtonShowNotes vShowNotesButton X%NewX% Y%NewY%, &Edit Notes
	Gui, Add, Text, vQuestionLabel Y%NewYT%,Do you want to re-add this task?

    If (%System%_IsReviewOptional)
    {
      Gui, Add, Button, gButtonReviewYes vRvYesButton Y%NewY%, &Yes
      Gui, Add, Button, gButtonReviewNo vRvNoButton Y%NewY% , &Not now
      Gui, Add, Button, gButtonReviewNever vRvNeverButton Y%NewY% Default, Ne&ver
      GuiControlGet, NeverPos, Pos, RvNeverButton
      DiffX := NeverPosX + NeverPosW - TaskPosX - TaskPosW
      NeverPosX := NeverPosX - DiffX
      GuiControl, Move, RvNeverButton, x%NeverPosX% y%NeverPosY% w%NeverPosW% h%NeverPosH%
      GuiControlGet, YesPos, Pos, RvYesButton
      YesPosX := YesPosX - DiffX
      GuiControl, Move, RvYesButton, x%YesPosX% y%YesPosY% w%YesPosW% h%YesPosH%
      GuiControlGet, NoPos, Pos, RvNoButton
      NoPosX := NoPosX - DiffX
      GuiControl, Move, RvNoButton, x%NoPosX% y%NoPosY% w%NoPosW% h%NoPosH%
    }
    Else
    {
      Gui, Add, Button, gButtonReviewYes vRvYesButton Y%NewY%, &Yes
      Gui, Add, Button, gButtonReviewNever vRvNeverButton Y%NewY% Default, &No
      GuiControlGet, NeverPos, Pos, RvNeverButton
      DiffX := NeverPosX + NeverPosW - TaskPosX - TaskPosW
      NeverPosX := NeverPosX - DiffX
      GuiControl, Move, RvNeverButton, x%NeverPosX% y%NeverPosY% w%NeverPosW% h%NeverPosH%
      GuiControlGet, YesPos, Pos, RvYesButton
      YesPosX := YesPosX - DiffX
      GuiControl, Move, RvYesButton, x%YesPosX% y%YesPosY% w%YesPosW% h%YesPosH%
    }

	GuiControlGet, QuestionPos, Pos, QuestionLabel
	QuestionPosX := QuestionPosX - DiffX
    GuiControl, Move, QuestionLabel, x%QuestionPosX% y%QuestionPosY% w%QuestionPosW% h%QuestionPosH%

    StringReplace, ShowNotesBoxContent, Tasks%ReviewTask%_3,\t,%A_Tab%, All
    StringReplace, ShowNotesBoxContent, ShowNotesBoxContent,\n,`n, All
	Gui, Add, Edit,xm Hidden T8 R10 default vShowNotesBox, %ShowNotesBoxContent%


	Title := %System%_GetReviewWindowTitle()
	Gui, Show, Center Autosize, %Title%
	GuiControl, Focus, RvNeverButton
	Return
}

ShowStatusWindow()
{
	global
	Gui, 2:Destroy
	Gui, 2:+AlwaysOnTop -SysMenu +Owner -Caption Resize MinSize MaxSize
	Gui, 2:Add, Text, y10, % Tasks%CurrentTask%_1
	Gui, 2:Add, Text, y10 Right vTimeControl, 00:00:00
	Gui, 2:Add, Button,ym default gButtonStop vStopButton, &Stop
	Gui, 2:Add, Button,ym gButtonHide, &Hide for 30s
	Gui, 2:Show, y0 xCenter AutoSize, Status - AutohotkeyAHK
	GuiControl, Focus, StopButton

}

SelectNextReviewTask()
{
	global
	Loop
	{
		ReviewTask := ReviewTask + 1
		If (ReviewTask > TaskCount)
		{
			CurrentMode := PreviousMode
			If (HasReviewModeTask)
			{
              If (!ReviewComplete)
    		  {
    		    ReAddTask()
    		  }
    		  Else
    		  {
    		    MarkAsDone()
    		  }
    		}
			Gui, Destroy
			SaveTasks()
			Break
		}
		
		If (Tasks%ReviewTask%_4 == 1)
		{
			If (!InStr(Tasks%ReviewTask%_2, "D") and InStr(Tasks%ReviewTask%_2, "R"))
			{
				Break
			}
		}
	}
	Work()
}

GuiClose:
GuiEscape:
Gui, Hide
Return

GuiDoneClose:
GuiDoneEscape:
	Gui, Destroy
	ShowStatusWindow()
	SetTimer,UpdateTime,1000
Return

GuiAddClose:
GuiAddEscape:
	Gui, 3:Destroy
Return


ButtonNotReady:
SelectNextTask()
Gui, Destroy
Work()
Return

ButtonReady:
Gui, Hide
If (Tasks%CurrentTask%_1 == "Change to review mode")
{
	Active := 0
	PreviousMode := CurrentMode
	CurrentMode := ReviewMode
	DoReview()
}
Else If (Tasks%CurrentTask%_1 == "Change to forward mode")
{
	Active := 0
	CurrentMode := ForwardMode
	CurrentPass := 1
	ActionOnCurrentPass := 0
	Tasks%CurrentTask%_2 := Tasks%CurrentTask%_2 . " D" . A_Now
	Tasks%CurrentTask%_4 := 1
	UnactionedCount := UnactionedCount - 1
	SaveTasks()
	CurrentTask := 1
	SelectNextActivePage()
	SelectNextTask()
	Gui, Destroy
  Work()
}
Else
{
	Active := 1
	TimePassed := 0
	ShowStatusWindow()
	SetTimer,UpdateTime,1000
}
Return

ButtonShowNotes:
    GuiControl, Disable, ShowNotesButton
    GuiControl, Show, ShowNotesBox
    GuiControl, Move, ShowNotesBox, w%TaskPosW%
    GuiControl, Focus, ShowNotesBox
	Gui, Show, AutoSize
Return

ButtonRephrase:
    GuiControl, Disable, RephraseButton
    GuiControl, Hide, TaskControl
    GuiControl, Show, RephraseBox
    GuiControl, Focus, RephraseBox
    Send ^a

Return


ButtonReAdd:
	Active := 0
  ActionOnCurrentPass := 1
	ReAddTask()
 	Gui, Destroy
  Work()
Return

ButtonNoReAdd:
	Active := 0
	If (CurrentMode == ForwardMode)
	{
		ActionOnCurrentPass := 1
	}
	MarkAsDone()
	Gui, Destroy
  Work()
Return

ButtonAdd:
	Gui, Submit
	If (NewTask != "")
	{
		TaskCount := TaskCount + 1
		If (UnactionedCount == 0)
		{
            CurrentTask := TaskCount
        }
		UnactionedCount := UnactionedCount + 1
		Tasks%Taskcount%_1 := NewTask
		Tasks%Taskcount%_2 := "A" . A_Now
	    StringReplace, AddNotesBox, AddNotesBox,%A_Tab%,\t, All
	    StringReplace, AddNotesBox, AddNotesBox,`n,\n, All
        Tasks%Taskcount%_3 := AddNotesBox
    	Tasks%Taskcount%_4 := 0
    	%System%_PostTaskAdd()
		SaveTasks()

	}
	Gui, Hide
Return

ButtonAddNotes:
    GuiControl, Disable, AddNotesButton
    GuiControlGet, AddTaskFieldPos, Pos, NewTask
    GuiControlGet, AddTaskButtonPos, Pos, AddTaskButton
    NewW := AddTaskButtonPosX + AddTaskButtonPosW - AddTaskFieldPosX
    GuiControl, Show, AddNotesBox
    GuiControl, Move, AddNotesBox, w%NewW%
    GuiControl, Focus, AddNotesBox
	Gui, 3:Show, AutoSize
Return

ButtonHide:
	SetTimer,ReShowStatusWindow,30000
	Gui, 2:Hide
Return

ButtonStop:
	Gui, Destroy
  Work()
Return

ButtonReviewYes:
Tasks%ReviewTask%_2 := Tasks%ReviewTask%_2 . " D" . A_Now
Tasks%ReviewTask%_4 := 1

TaskCount := TaskCount + 1
UnactionedCount := UnactionedCount + 1
GuiControlGet,RephraseBoxContent,,RephraseBox
If (RephraseBoxContent)
{
      Tasks%Taskcount%_1 := RephraseBoxContent
  }
  Else
  {
      Tasks%Taskcount%_1 := Tasks%ReviewTask%_1
  }
Tasks%Taskcount%_2 := "A" . A_Now
GuiControlGet,ShowNotesBoxContent,,ShowNotesBox
If (ShowNotesBoxContent)
{
      Tasks%Taskcount%_3 := ShowNotesBoxContent
}
Else
{
      Tasks%Taskcount%_3 := Tasks%ReviewTask%_3
  }

Tasks%Taskcount%_4 := 0
SaveTasks()
SelectNextReviewTask()
Return

ButtonReviewNo:
ReviewComplete := 0
SelectNextReviewTask()
Return

ButtonReviewNever:
Tasks%ReviewTask%_2 := Tasks%ReviewTask%_2 . " D" . A_Now
Tasks%ReviewTask%_3 := 1
SelectNextReviewTask()
Return

ReShowStatusWindow:
	SetTimer,ReShowStatusWindow,Off
	Gui, 2:Show, y0 xCenter NoActivate AutoSize, Status - AutohotkeyAHK
Return

UpdateTime:
	TimePassed := TimePassed + 1
  TimeString := SecondsToFormattedTime(TimePassed)
	GuiControl, 2: , TimeControl, %TimeString%
Return

SecondsToFormattedTime(TimePassed)
{
	TimeTemp := TimePassed
	If (TimePassed < 60)
	{
		Hours := 0
		Minutes := 0
		Seconds := TimePassed
	}
	Else If (TimePassed < 3600)
	{
		Hours := 0
		Minutes := 0
		Loop
		{
			TimeTemp := TimeTemp - 60
			Minutes := Minutes + 1
			If (TimeTemp <60)
			{
				break
			}
		}
		Seconds := TimeTemp
	}
	Else
	{
		Hours := 0
		Loop
		{
			TimeTemp := TimeTemp - 3600
			Hours := Hours + 1
			If (TimeTemp < 3600)
			{
				break
			}
		}
		Minutes := 0
		Loop
		{
			If (TimeTemp <60)
			{
				break
			}
			TimeTemp := TimeTemp - 60
			Minutes := Minutes + 1
		}
		Seconds := TimeTemp
	}
	TimeString := ""
	
	If (Hours > 0)
	{
		;If (Hours < 10)
		;{
		;	TimeString := TimeString . "0"
		;}
		TimeString := TimeString . Hours . ":"
		If (Minutes < 10)
		{
			TimeString := TimeString . "0"		
		}
	}
	TimeString := TimeString . Minutes . ":"
	If (Seconds< 10)
	{
		TimeString := TimeString . "0"
	}
	TimeString := TimeString . Seconds
  
  Return TimeString
}

ShowPreferences()
{
	global
	Gui, Destroy
	Gui, Font, Bold
	Gui, Add, Text, w250, Used time management system
	Gui, Font, Norm
	RadioChecked := System == "AF1"
  Gui, Add, Radio, vRadioSystem checked%RadioChecked% gSystemAF1, Autofocus Version 1 (AF1/AF)
	RadioChecked := System == "AF2"
  Gui, Add, Radio, checked%RadioChecked% gSystemAF2, Autofocus Version 2 (AF2)
	RadioChecked := System == "AF3"
  Gui, Add, Radio,  checked%RadioChecked% gSystemAF3, Autofocus Version 3 (AF3/RAF)                   
	RadioChecked := System == "AF4" || System == ""
  Gui, Add, Radio,  checked%RadioChecked% gSystemAF4, Autofocus Version 4 (AF4)                   
	Gui, Font, Bold
	Gui, Add, Text, ym w250, Autostart
	Gui, Font, Norm
  Gui, Add, Checkbox, vAutostartCheck checked%StartWithWindows%  gAutostartCheckbox, Start AutofocusAHK with Windows                    
	Gui, Font, Bold
	Gui, Add, Text, w250, Backups
	Gui, Font, Norm
  Gui, Add, Checkbox, vBackupCheck checked%DoBackups%  gBackupCheckbox, Create daily backups of task list
  Gui, Add, Text, vBackupLabel, Number of Backups to keep:                   
	GuiControlGet, BackupLabelPos, Pos, BackupLabel
	NewX := BackupLabelPosX + BackupLabelPosW + 10
	Gui, Add, Edit, vBackupEdit w30 gBackupEditBox,%BackupsToKeep%
	GuiControlGet, BackupEditPos, Pos, BackupEdit,
	NewY := BackupLabelPosY - (BackupEditPosH - BackupLabelPosH)/2
	GuiControl, Move, BackupEdit, x%NewX% y%NewY% 
	Gui, Show, Center Autosize, Preferences - AutofocusAHK %Ver%
	Return
}

SystemAF1:
		System := "AF1"
		IniWrite, %System%, %A_ScriptDir%\AutofocusAHK.ini, General, System
    LoadTasks()
Return

SystemAF2:
		System := "AF2"
		IniWrite, %System%, %A_ScriptDir%\AutofocusAHK.ini, General, System
    LoadTasks()
Return

SystemAF3:
		System := "AF3"
		IniWrite, %System%, %A_ScriptDir%\AutofocusAHK.ini, General, System
		LoadTasks()
Return

SystemAF4:
		System := "AF4"
		IniWrite, %System%, %A_ScriptDir%\AutofocusAHK.ini, General, System
		LoadTasks()
Return

AutostartCheckbox:
  If(StartWithWindows == 0)
  {
		FileCreateShortcut, "%A_ScriptFullPath%", %A_Startup%\AutofocusAHK.lnk, %A_ScriptDir% 
		StartWithWindows := 1
		IniWrite, 1, %A_ScriptDir%\AutofocusAHK.ini, General, StartWithWindows
	} 
  Else
  {
		FileDelete, %A_Startup%\AutofocusAHK.lnk
		StartWithWindows := 0
		IniWrite, 0, %A_ScriptDir%\AutofocusAHK.ini, General, StartWithWindows
  }
Return

BackupCheckbox:
  If(DoBackups == 0)
  {
		FileCreateShortcut, "%A_ScriptFullPath%", %A_Startup%\AutofocusAHK.lnk, %A_ScriptDir% 
		DoBackups := 1
		IniWrite, 1, %A_ScriptDir%\AutofocusAHK.ini, General, DoBackups
	} 
  Else
  {
		FileDelete, %A_Startup%\AutofocusAHK.lnk
		DoBackups := 0
		IniWrite, 0, %A_ScriptDir%\AutofocusAHK.ini, General, DoBackups
  }
Return

BackupEditBox:
    GuiControlGet, PreBackupsToKeep,,BackupEdit
    If PreBackupsToKeep is digit
    {
        Gui, Font
        GuiControl, Font, BackupEdit
		BackupsToKeep := PreBackupsToKeep
		IniWrite, %BackupsToKeep%, %A_ScriptDir%\AutofocusAHK.ini, General, BackupsToKeep
    }
    Else
    {
        Gui, Font, cRed
        GuiControl, Font, BackupEdit
        Gui, Font
    }
Return 