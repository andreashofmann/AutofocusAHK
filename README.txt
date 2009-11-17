AutofocusAHK 
------------
A simple tool based on Mark Forster's Autofocus Time Management System. Written
in AutohHotkey.

History
-------
2009-09-04 - Released version 0.9   - support for switching between AF1-4, AF4 support still lacks review
2009-09-04 - Released version 0.8.5 - improved gui for review mode, show next tasks and tasks on notice
2009-08-28 - Released version 0.8   - HTML export
2009-08-27 - Released version 0.7   - new user interface for adding and doing, status window with timer
2009-08-25 - Released version 0.6   - forward mode
2009-08-22 - Released version 0.5   - hotkeys now configurable via ini file
2009-08-22 - Released version 0.4   - autostart
2009-08-22 - Released version 0.3   - automatic daily backup, keep certain number of backups
2009-08-22 - Released version 0.2   - morning routine, basic review mode
2009-08-21 - Released version 0.1   - basic reverse mode, no forward or review mode
2009-08-20 - Started development

Installation
------------
1. Unzip
2. Start "AutofocusAHK.exe"

Compile from Source
-------------------
1. Download and install Autohotkey from http://www.autohotkey.com
2. Download AutofocusAHK source from GitHub
3. Right-click on "AutofocusAHK.ahk" and select "Compile Script" from the
   context menu.

Usage
-----
This application uses CapsLock as a hotkey. If you need CapsLock for some 
reason, you must change the hotkeys in the configuration file.

CapsLock + a	Add a task
CapsLock + s	Show the next tasks and tasks on notice for review
CapsLock + d	Start/Stop Working
CapsLock + e	Export list to HTML
CapsLock + p	Show preferences

Configuration
-------------
Edit AutofocusAHK.ini (created on first start) to change how the application behaves.

Sample ini file:

[General]
DoBackups=1
BackupsToKeep=10
[ReviewMode]
LastRoutine=20090822
StartRoutineAt=6
[HotKeys]
HKAddTask=CapsLock & a
HKWork=CapsLock & d
HKShowNextTasks=CapsLock & s
HKShowCurrentTask=CapsLock & c
HKShowOnNotice=CapsLock & n
HKToggleAutostart=CapsLock & s

DoBackups        1: Do daily automatic backups (saved in sub folder "Backups"), 0: don't do backups
BackupsToKeep    Number of backups that should be kept. Default value is 10.

LastRoutine      Date when the last morning routine was executed. Updated autmatically.
StartRoutineAt   Time (hour) when the morning routine takes place. Value from 0 to 23.

HotKeys          Change the hotkeys for the different actions. Follows AutoHotkey rules, see
                 http://www.autohotkey.com/docs/Hotkeys.htm
				 
				 Examples: 
				 #q              Hold Win and press q
				 ^!{Tab}         Hold Ctrl+Alt and press Tab
				 #^+t            Hold Win+Ctrl+Shift and press t
 				 CapsLock & a    Hold CapsLock and press a