; AutofocusAHK
;
; Functions that create/modify the graphical user inferface
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5
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
  Gui, Default
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

  Gui, Show, AutoSize, Show Tasks - %System% - %ApplicationName% %Ver%
}

ShowAddTaskWindow()
{
  global

  NewTaskDescription := ""
  OldClipboard := ClipBoardAll
  Clipboard =
  Send ^c
  ClipWait, 0.2

  If (!ErrorLevel)
  {
    NewTaskDescription := Clipboard
    StringReplace, NewTaskDescription, NewTaskDescription,%A_Tab%, %A_Space%, All
    StringReplace, NewTaskDescription, NewTaskDescription,`n, %A_Space%, All
  }

  NewUrl := CheckForBrowserUrl()
  ClipBoard := OldClipboard
  OldClipboard =
  Gui, 3:Destroy
  Gui, 3:Add, Edit, w400 vNewTask r1, %NewTaskDescription%  ; The ym option starts a new column of controls.
  Gui, 3:Add, Button,ym vAddNotesButton gButtonAddNotes, &More ...
  Gui, 3:Add, Button,ym default gButtonAdd vAddTaskButton, &Add
  GuiControlGet, AddTaskFieldPos, 3:Pos, NewTask
  GuiControlGet, AddTaskButtonPos, 3:Pos, AddTaskButton
  NewW := AddTaskButtonPosX + AddTaskButtonPosW - AddTaskFieldPosX
  Gui, 3:Add, Tab2, xm w%NewW% vAddTabs, Notes|Tickler
  Gui, 3:Add, Edit, T8 R10 vAddNotesBox

  If (NewUrl)
  {
    Gui, 3:Add, Checkbox,  vAddUrlCheckbox, &Use this URL:
    Gui, 3:Add, Edit, r1 vAddUrlBox, %NewUrl%  
  }
  Else
  {
    Gui, 3:Add, Text,   vAddUrlLabel, URL:
    Gui, 3:Add, Edit, r1 vAddUrlBox
    GuiControl, 3:Hide, AddTabs
  }

  GuiControlGet, AddNotesBoxPos, 3:Pos, AddNotesBox
  NewW := NewW - AddNotesBoxPosX
  GuiControl, 3:Move, AddNotesBox, w%NewW%
  GuiControl, 3:Move, AddUrlBox, w%NewW%
  Gui, 3:Tab, Tickler
  FormatTime, startdate,,yyyyMMdd
  Gui, 3:Add, MonthCal, 16 -Multi Range%startdate% 6 gCalendarTicklerAdd vAddTicklerCalendar
  Gui, 3:Add, Text, w%NewW% vAddTicklerLabel, The task will be added to the list immediately.
  Gui, 3:+LabelGuiAdd
  Gui, 3:Show, AutoSize, Add Task - %System% - %ApplicationName% %Ver%
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

  Message := Message . "`n`nDo you want " . ApplicationName . " to start with Windows in the future?"
  MsgBox, 4, %ApplicationName% %Ver%, %Message%

  IfMsgBox Yes
  {
    FileCreateShortcut, "%A_ScriptFullPath%", %A_Startup%\%ApplicationName%.lnk, %A_ScriptDir% 
    StartWithWindows := 1
    IniWrite, 1, %A_ScriptDir%\%ApplicationName%.ini, General, StartWithWindows
  }

  IfMsgBox No
  {
    FileDelete, %A_Startup%\%ApplicationName%.lnk
    StartWithWindows := 0
    IniWrite, 0, %A_ScriptDir%\%ApplicationName%.ini, General, StartWithWindows
  }
}

ShowWorkWindow()
{
  global

  Gui, Destroy
  Gui, Font, Bold
  %System%_PreShowTaskname()
  Gui, Add, Text, Y20 w500 Center vTaskControl, % Tasks%CurrentTask%_1
  %System%_PostShowTaskname()
  Gui, Font, Norm
  GuiControlGet, TaskPos, Pos, TaskControl
  NewY := TaskPosY + TaskPosH + 20
  NewYT := NewY + 5
  Gui, Add, Button, gButtonShowNotes vShowNotesButton x%TaskPosX% Y%NewY%, &More ...
  GuiControlGet, MoreButtonPos, Pos, ShowNotesButton
  DoneButtonX := MoreButtonPosX * 2 + MoreButtonPosW 
  Gui, Add, Button, gButtonMarkDone vShowMarkDone x%DoneButtonX% Y%NewY%, Already &Done
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

  If(Tasks%CurrentTask%_3 == "" and Tasks%CurrentTask%_URL == "")
  {
        GuiControl Disable, ShowNotesButton
  }

  Gui, Add, Text, xm Hidden vShowNotesBoxLabel, Notes:
  StringReplace, ShowNotesBoxContent, Tasks%CurrentTask%_3,\t,%A_Tab%, All
  StringReplace, ShowNotesBoxContent, ShowNotesBoxContent,\n,`n, All
  Gui, Add, Edit,xm Hidden ReadOnly T8 R10 default vShowNotesBox, %ShowNotesBoxContent%
  Gui, Add, Text, xm Hidden vShowUrlBoxLabel, URL:
  Gui, Add, Edit,xm Hidden ReadOnly T8 default vShowUrlBox, % Tasks%CurrentTask%_URL
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
  Gui, Add, Button, gButtonShowNotes vShowNotesButton X%NewX% Y%NewY%, &More ...
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
  Gui, Add, Text, xm Hidden vShowUrlBoxLabel, URL:
  Gui, Add, Edit,xm Hidden default vShowUrlBox, % Tasks%CurrentTask%_URL
  Gui, Show, Center Autosize, Done - %ApplicationName% %Ver% 
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
  Gui, Add, Button, gButtonShowNotes vShowNotesButton X%NewX% Y%NewY%, &More ...
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
  Gui, 2:Add, Button,ym gButtonShowStatusNotes vStatusNotesButton, &More ...
  Gui, 2:Add, Button,ym gButtonHide vHideButton, &Hide for 30s
  Gui, 2:Add, Button,ym gButtonInstantReAdd vIntantReAddButton, &Re-Add
  Gui, 2:Add, Button,ym default gButtonStop vStopButton, &Stop
  Gui, 2:Show, y0 xCenter AutoSize, Status - AutohotkeyAHK
  GuiControl, 2:Focus, StopButton
}

~Shift::
  {
    GuiControl, 2:Text, HideButton, Hide
    HidePermanently := 1
  }
Return

~Shift Up::
  {
    GuiControl, 2:Text, HideButton, &Hide for 30s
    HidePermanently := 0
  }
Return

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

GuiNotesClose:
GuiNotesEscape:
  GuiControl, 2:Enable, StatusNotesButton
  GuiControlGet,ShowNotesBoxContent,,ShowStatusNotesBox

  If (ShowNotesBoxContent)
  {
        Tasks%CurrentTask%_3 := ShowNotesBoxContent
  }

  GuiControlGet,ShowUrlBoxContent,,ShowStatusUrlBox

  If (ShowUrlBoxContent)
  {
        Tasks%CurrentTask%_URL := ShowUrlBoxContent
  }

  Gui, 4:Destroy  
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
    If (Tasks%CurrentTask%_URL != "")
    {
      Run, % Tasks%CurrentTask%_URL
    }
    Active := 1
    TimePassed := 0
    ShowStatusWindow()
    SetTimer,UpdateTime,1000
  }
Return

ButtonShowNotes:
  GuiControl, Disable, ShowNotesButton
  GuiControl, Show, ShowUrlBoxLabel
  GuiControl, Show, ShowUrlBox
  GuiControl, Move, ShowUrlBox, w%TaskPosW%
  GuiControl, Show, ShowNotesBoxLabel
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
    If (NewUrl and AddUrlCheckbox)
    {
      Tasks%Taskcount%_URL := AddUrlBox
      NewUrl =
    }

    AddTask(NewTask, AddNotesBox, AddUrlBox, AddTicklerCalendar)
  }

  Gui, Hide
Return

ButtonAddNotes:
  GuiControl, 3:Disable, AddNotesButton
  GuiControl, 3:Show, AddTabs
  GuiControl, 3:Focus, AddNotesBox
  Gui, 3:Show, AutoSize
Return

ButtonHide:
  If (HidePermanently != 1)
  {
    SetTimer,ReShowStatusWindow,30000
  }

  Gui, 2:Hide
Return

ButtonShowStatusNotes:
  GuiControl, Disable, StatusNotesButton
  Gui, 4:Destroy
  Gui, 4:Font, Bold
  Gui, 4:Add, Text,  w500 Center vTaskNotesControl, % Tasks%CurrentTask%_1
  Gui, 4:Font, Norm
  StringReplace, ShowNotesBoxContent, Tasks%CurrentTask%_3,\t,%A_Tab%, All
  StringReplace, ShowNotesBoxContent, ShowNotesBoxContent,\n,`n, All
  Gui, 4:+LabelGuiNotes
  Gui, 4:Add, Text, xm w500, Notes:
  Gui, 4:Add, Edit,xm w500 T8 R10 default vShowStatusNotesBox, %ShowNotesBoxContent%
  Gui, 4:Add, Text, xm, URL:
  Gui, 4:Add, Edit,xm w500 default vShowStatusUrlBox, % Tasks%CurrentTask%_URL
  Gui, 4:Show, Center Autosize, Task Info - %ApplicationName% %Ver%
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

  If (ShowUrlBoxContent)
  {
    Tasks%Taskcount%_URL := ShowUrlBoxContent ;Tasks%CurrentTask%_3
  }
  Else
  {
    Tasks%Taskcount%_URL := Tasks%CurrentTask%_URL
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
        Break
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
        Break
      }
    }

    Minutes := 0

    Loop
    {
      If (TimeTemp <60)
      {
        Break
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
    ;  TimeString := TimeString . "0"
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
  RadioChecked := System == "DWM" || System == ""
  Gui, Add, Radio,  checked%RadioChecked% gSystemDWM, Day/Week/Month (DWM)                   
  Gui, Font, Bold
  Gui, Add, Text, ym w250, Autostart
  Gui, Font, Norm
  Gui, Add, Checkbox, vAutostartCheck checked%StartWithWindows%  gAutostartCheckbox, Start %ApplicationName% with Windows                    
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
  Gui, Show, Center Autosize, Preferences - %ApplicationName% %Ver%

  Return
}

SystemAF1:
  System := "AF1"
  IniWrite, %System%, %A_ScriptDir%\%ApplicationName%.ini, General, System
  LoadTasks()
Return

SystemAF2:
  System := "AF2"
  IniWrite, %System%, %A_ScriptDir%\%ApplicationName%.ini, General, System
  LoadTasks()
Return

SystemAF3:
  System := "AF3"
  IniWrite, %System%, %A_ScriptDir%\%ApplicationName%.ini, General, System
  LoadTasks()
Return

SystemAF4:
  System := "AF4"
  IniWrite, %System%, %A_ScriptDir%\%ApplicationName%.ini, General, System
  LoadTasks()
Return

SystemDWM:
  System := "DWM"
  IniWrite, %System%, %A_ScriptDir%\%ApplicationName%.ini, General, System
  LoadTasks()
Return

AutostartCheckbox:
  If(StartWithWindows == 0)
  {
    FileCreateShortcut, "%A_ScriptFullPath%", %A_Startup%\%ApplicationName%.lnk, %A_ScriptDir% 
    StartWithWindows := 1
    IniWrite, 1, %A_ScriptDir%\%ApplicationName%.ini, General, StartWithWindows
  } 
  Else
  {
    FileDelete, %A_Startup%\%ApplicationName%.lnk
    StartWithWindows := 0
    IniWrite, 0, %A_ScriptDir%\%ApplicationName%.ini, General, StartWithWindows
  }
Return

BackupCheckbox:
  If(DoBackups == 0)
  {
    FileCreateShortcut, "%A_ScriptFullPath%", %A_Startup%\%ApplicationName%.lnk, %A_ScriptDir% 
    DoBackups := 1
    IniWrite, 1, %A_ScriptDir%\%ApplicationName%.ini, General, DoBackups
  } 
  Else
  {
    FileDelete, %A_Startup%\%ApplicationName%.lnk
    DoBackups := 0
    IniWrite, 0, %A_ScriptDir%\%ApplicationName%.ini, General, DoBackups
  }
Return

BackupEditBox:
  GuiControlGet, PreBackupsToKeep,,BackupEdit
  If PreBackupsToKeep is digit
  {
    Gui, Font
    GuiControl, Font, BackupEdit
    BackupsToKeep := PreBackupsToKeep
    IniWrite, %BackupsToKeep%, %A_ScriptDir%\%ApplicationName%.ini, General, BackupsToKeep
  }
  Else
  {
    Gui, Font, cRed
    GuiControl, Font, BackupEdit
    Gui, Font
  }
Return 

ShowSearchWindow()
{
  global

  NewUrl := CheckForBrowserUrl()
  Gui, 5:Destroy
  Gui, 5:Add, Edit, gEditSearch w500 vSearchString  ; The ym option starts a new column of controls.
  Gui, 5:+LabelGuiSearch
  Gui, 5:Add, ListView, gListSearch Count%UnactionedCount% ReadOnly AltSubmit -Multi -WantF2 -Hdr xm r6 w500 vSearchResults, Task|Number
  Gui, 5:Add, Text, w500 center, Double-click result to jump to task
  Gui, 5:Show, AutoSize, Find - %System% - %ApplicationName% %Ver%
  GroupAdd, AutofocusAHK, Find - %System% - %ApplicationName% %Ver%
  Gui, 5:Default

  Loop, %Taskcount%
  {
    If (Tasks%A_Index%_4 == 0)
    {
      LV_Add("", Tasks%A_Index%_1, A_Index)
      LV_ModifyCol(2, 0)
      LV_ModifyCol(1, 468)
      
    }
  }

  LV_Modify(1, "Focus Select Vis")
}

EditSearch:
  GuiControlGet, Blub, , SearchString
  Gui, 5:Default
  LV_Delete()

  Loop, %Taskcount%
  {
    If (Tasks%A_Index%_4 == 0 and (InStr(Tasks%A_Index%_1, Blub) or InStr(Tasks%A_Index%_3, Blub) or InStr(Tasks%A_Index%_URL, Blub)))
    {
      LV_Add("", Tasks%A_Index%_1, A_Index)
      LV_ModifyCol(2, 0)
      LV_ModifyCol(1, 468)
    }
  }

  LV_Modify(1, "Focus Select Vis")
Return

ListSearch:
  If (A_GuiEvent == "DoubleClick")
  {
    ResultRow := LV_GetNext(0, "Focused")

    If(ResultRow)
    {
      LV_GetText(JumpTask, ResultRow, 2)
      Gui, 5:Destroy
      CurrentTask := JumpTask
      Work()
    }
  }
  Else If (A_GuiEvent == "Normal" or A_GuiEvent == "F" )
  {
    SetTimer, RefocusSearch, 50 
  }
Return

RefocusSearch:
  SetTimer, RefocusSearch, off 
  GuiControl, Focus, SearchString
  Send {End}
Return

GuiSearchClose:
GuiSearchEscape:
  Gui, 5:Destroy
Return


#IfWinActive, ahk_group AutofocusAHK
  Down::
    Gui, 5:Default
    ResultRow := LV_GetNext(0, "Focused")
    LV_Modify(ResultRow + 1, "Focus Select Vis")
  Return
  
  Up::
    Gui, 5:Default
    ResultRow := LV_GetNext(0, "Focused")

    If (ResultRow != 1)
    {
      LV_Modify(ResultRow - 1, "Focus Select Vis")
    }
  Return
  
  Enter::
    Gui, 5:Default
    ResultRow := LV_GetNext(0, "Focused")

    If(ResultRow)
    {
      LV_GetText(JumpTask, ResultRow, 2)
      Gui, 5:Destroy
      CurrentTask := JumpTask
      Work()
    }
  Return
#IfWinActive

ButtonMarkDone:
  MarkAsDone()
  SelectNextTask()
  Gui, Destroy
  Work()
Return

ButtonInstantReAdd:
  Active := 0
  ActionOnCurrentPass := 1
  ReAddTask()
  Gui, Destroy
  Work()
Return

CalendarTicklerAdd:
  FormatTime, cal, %AddTicklerCalendar%, yyyy-MM-dd
  FormatTime, today, ,yyyy-MM-dd

  If (cal != today)
  {
     GuiControl, Text, AddTicklerLabel, The task will be added to the list on %cal%.
  }
  Else
  {
    GuiControl, Text, AddTicklerLabel, The task will be added to the list immediately.
  }
Return
