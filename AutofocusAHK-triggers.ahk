; AutofocusAHK
;
; Triggers for actions, which will be connected with user defined hotkeys
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5.4
; @since     0.9

; Trigger for adding a new task
TriggerAddTask:
  If (WinActive("Add Task - " . ApplicationName))
  {
    ; If "Add Task" window is active, close it
    WinClose
  }
  Else
  {
    ; Show "Add Task" window
    ShowAddTaskWindow()
  }
Return

; Trigger for showing the next tasks
TriggerShowNextTasks:
  ; Show "Show Tasks" window
  ShowNextTasks()
Return


; Trigger to start/stop working
TriggerWork:
  If (WinActive("Reverse Mode - " . ApplicationName) or WinActive("Forward Mode - " . ApplicationName) or WinActive("Done - " . ApplicationName) or WinActive("Forward Mode - " . ApplicationName) or WinActive("Review Mode - " . ApplicationName))
  {
    ; If work window is active, close it
    WinClose
  }
  Else
  {
    ; Show work window
    Work()
  }
Return

TriggerPreferences:
  ; Show autostart selection
  ShowPreferences()
Return


TriggerExport:
  Export()
Return

TriggerQuit:
  MsgBox, 4, %ApplicationName% %Ver%, Do you want to exit %ApplicationName%?
  IfMsgBox Yes
  {
    ExitApp
  }
Return


TriggerReload:
  MsgBox, 4, %ApplicationName% %Ver%, Do you want to reload %ApplicationName%?
  IfMsgBox Yes
  {
    Reload
  }
Return

TriggerSearch:
  ShowSearchWindow()
Return