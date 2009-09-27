; AutofocusAHK
;
; Triggers for actions, which will be connected with user defined hotkeys
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9
; @since     0.9

; Trigger for adding a new task
TriggerAddTask:
	If (WinActive("Add Task - AutofocusAHK"))
	{
		; If "Add Task" window is active, close it
		WinClose
	}
	Else
	{
		; Show "Add Task" window
		AddTask()
	}
Return

; Trigger for showing the next tasks
TriggerShowNextTasks:
	; Show "Show Tasks" window
	ShowNextTasks()
Return


; Trigger to start/stop working
TriggerWork:
	If (WinActive("Reverse Mode - AutofocusAHK") or WinActive("Forward Mode - AutofocusAHK") or WinActive("Done - AutofocusAHK") or WinActive("Forward Mode - AutofocusAHK") or WinActive("Review Mode - AutofocusAHK"))
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

; Trigger to toggle autostart
TriggerToggleAutostart:
	;Show autostart selection
	ToggleStartup()
Return


TriggerExport:
	Export()
Return
