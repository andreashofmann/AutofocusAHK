
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

	Gui, Font, Bold
	Gui, Add, Text, xm w600 Center, On Notice for Review
	Gui, Font, Norm

	NoticeCount := 0
	Loop %TaskCount%
	{
		If (Tasks%A_Index%_3 == 0 and InStr(Tasks%A_Index%_2, "N"))
		{
			NoticeCount += 1
		}
	}

	
	First := 1
	Loop %TaskCount%
	{
		If (Tasks%A_Index%_3 == 0 and InStr(Tasks%A_Index%_2, "N"))
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
	GuiControl, Disable, NextListView
	GuiControl, Disable, NoticeListView
	Gui, Show, AutoSize, Show Tasks - AutofocusAHK %Ver%
}

;Add a New Task
AddTask()
{
	global
	Gui, 3:Destroy
	Gui, 3:Add, Edit, w400 vNewTask  ; The ym option starts a new column of controls.
	Gui, 3:Add, Button,ym default gButtonAdd, Add
	Gui, 3:+LabelGuiAdd
	Gui, 3:Show, AutoSize, Add Task - AutofocusAHK %Ver%
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
	Gui, Add, Text, Y20 w400 Center vTaskControl, % Tasks%CurrentTask%_1
	Gui, Font, Norm
	GuiControlGet, TaskPos, Pos, TaskControl
	NewY := TaskPosY + TaskPosH + 20
	NewYT := NewY + 5
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
	If (CurrentMode == ForwardMode)
	{
		Title := "Forward Mode"
	}
	Else
	{
		Title := "Reverse Mode"
	}
	Gui, Show, Center Autosize, %Title% - AutofocusAHK %Ver%
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
	Gui, Add, Text, x%WorkingPosX% Y%NewY% w400 Center vTaskControl, % Tasks%CurrentTask%_1
	Gui, Font, Norm
	GuiControlGet, TaskPos, Pos, TaskControl
	NewY := TaskPosY + TaskPosH + 20
	NewYT := NewY + 5
	GuiControl, Text, ModeControl, ForwardMode
	;GuiControl, Move, TaskControl, w200 h100
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
	Gui, Show, Center Autosize, Done - AutofocusAHK %Ver% 
	GuiControl, Focus, YesButton
	Return
}


ShowReviewWindow()
{
	global
	Gui, Destroy
	Gui, Font, Bold
	Gui, Add, Text, Y20 w400 Center vTaskControl, % Tasks%ReviewTask%_1
	Gui, Font, Norm
	GuiControlGet, TaskPos, Pos, TaskControl
	NewY := TaskPosY + TaskPosH + 20
	NewYT := NewY + 5
	GuiControl, Text, ModeControl, ForwardMode
	;GuiControl, Move, TaskControl, w200 h100
	Gui, Add, Text, vQuestionLabel Y%NewYT%,Do you want to re-add this task?
	Gui, Add, Button, gButtonReviewYes vRvYesButton Y%NewY%, &Yes
	Gui, Add, Button, gButtonReviewNo vRvNoButton Y%NewY% Default, &Not now
	Gui, Add, Button, gButtonReviewNever vRvNeverButton Y%NewY%, Ne&ver
	;Gui, Add, Button, vCancelButton Y%NewY%, &Cancel
	;GuiControlGet, CancelPos, Pos, CancelButton
	;DiffX := CancelPosX + CancelPosW - TaskPosX - TaskPosW
	;CancelPosX := CancelPosX - DiffX
	;GuiControl, Move, CancelButton, x%CancelPosX% y%CancelPosY% w%CancelPosW% h%CancelPosH%
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
	GuiControlGet, QuestionPos, Pos, QuestionLabel
	QuestionPosX := QuestionPosX - DiffX
	GuiControl, Move, QuestionLabel, x%QuestionPosX% y%QuestionPosY% w%QuestionPosW% h%QuestionPosH%
	;Gui, +LabelGuiReview
	Gui, Show, Center Autosize, Review Mode - AutofocusAHK %Ver%
	GuiControl, Focus, RvNoButton
	Return
}

ShowStatusWindow()
{
	global
	Gui, 2:Destroy
	Gui, 2:+AlwaysOnTop -SysMenu +Owner -Caption Resize MinSize MaxSize
	Gui, 2:Add, Text, y10, % Tasks%CurrentTask%_1
	Gui, 2:Add, Text, y10 Right vTimeControl, 00:00:00
	Gui, 2:Add, Button,ym default gButtonStop vStopButton, Stop
	Gui, 2:Add, Button,ym gButtonHide, Hide for 30s
	Gui, 2:Show, y0 xCenter NoActivate AutoSize, Status - AutohotkeyAHK
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
			If (!ReviewComplete)
			{
				ReAddTask()
			}
			Else
			{
				MarkAsDone()
			}
			Gui, Destroy
			MsgBox, Review done!
			Break
		}
		
		If (Tasks%ReviewTask%_3 == 1)
		{
			If (!InStr(Tasks%ReviewTask%_2, "D") and InStr(Tasks%ReviewTask%_2, "R"))
			{
				ShowReviewWindow()
				Break
			}
		}
	}
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
ShowWorkWindow()
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
	Tasks%CurrentTask%_3 := 1
	UnactionedCount := UnactionedCount - 1
	SaveTasks()
	CurrentTask := 1
	SelectNextActivePage()
	SelectNextTask()
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

ButtonReAdd:
	Active := 0
	If (CurrentMode == ForwardMode)
	{
		ActionOnCurrentPass := 1
	}
	ReAddTask()
	ShowWorkWindow()
Return

ButtonNoReAdd:
	Active := 0
	If (CurrentMode == ForwardMode)
	{
		ActionOnCurrentPass := 1
	}
	MarkAsDone()
	ShowWorkWindow()
Return

ButtonAdd:
	Gui, Submit
	If (NewTask != "")
	{
		TaskCount := TaskCount + 1
		UnactionedCount := UnactionedCount + 1
		Tasks%Taskcount%_1 := NewTask
		Tasks%Taskcount%_2 := "A" . A_Now
		Tasks%Taskcount%_3 := 0
		SaveTasks()
	}
	Gui, Hide
Return

ButtonHide:
	SetTimer,ReShowStatusWindow,30000
	Gui, 2:Hide
Return

ButtonStop:
	Work()
Return

ButtonReviewYes:
Tasks%ReviewTask%_2 := Tasks%ReviewTask%_2 . " D" . A_Now
Tasks%ReviewTask%_3 := 1

TaskCount := TaskCount + 1
UnactionedCount := UnactionedCount + 1
Tasks%Taskcount%_1 := Tasks%ReviewTask%_1
Tasks%Taskcount%_2 := "A" . A_Now
Tasks%Taskcount%_3 := 0
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

	GuiControl, 2: , TimeControl, %TimeString%
Return