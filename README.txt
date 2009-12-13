AutofocusAHK 
------------

  A simple todo list tool based on Mark Forster's Autofocus Time Management 
  System - see http://www.markforster.net/autofocus-index/ for an overview. 
  Written in AutoHotkey.

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
  CapsLock + r  Reload the tasks list from Tasks.txt
  CapsLock + q  Quit the application

Configuration
-------------

  Edit AutofocusAHK.ini (created on first start) to change how the application
  behaves. Some of these settings can also be changed in the preferences window.
  
  Sample ini file: [General]
                   System=AF4
                   StartWithWindows=0
                   DoBackups=1
                   BackupsToKeep=10
                   [ReviewMode]
                   LastRoutine=20091120
                   StartRoutineAt=6
                   [ForwardMode]
                   TasksPerPage=15
                   [HotKeys]
                   HKAddTask=CapsLock & a
                   HKWork=CapsLock & d
                   HKShowNextTasks=CapsLock & s
                   HKExport=CapsLock & e
                   HKPreferences=CapsLock & p

  System           Which time management system will be used? Valid values
                   are "AF1", "AF2", "AF3", and "AF4". As of version 0.9.1,
                   AF4 will be the default system.
 
  DoBackups        1: Do daily automatic backups (in sub folder "Backups"), 
                   0: don't do backups

  BackupsToKeep    Number of backups that should be kept. Default value is 10.
  
  LastRoutine      Date when the last morning routine was executed. Updated 
                   autmatically. If you want to execute the routine for a second
                   time, set this value to a earlier date and restart the 
                   application.
                   
  StartRoutineAt   Time (hour) when the morning routine takes place. 
                   Value from 0 to 23.

  TasksPerPage     Number of tasks on one "page". This plays a major role with
                   systems that use pages as units (AF1 and AF3), but also has
                   other effects (for example, in AF4 the list will be closed 
                   the first time when there are more tasks than this number).
  
  HotKeys          Change the hotkeys. Follows AutoHotkey rules, 
                   see http://www.autohotkey.com/docs/Hotkeys.htm
  				 
          				 Examples: 
          				 #q              Hold Win and press q
          				 ^!{Tab}         Hold Ctrl+Alt and press Tab
          				 #^+t            Hold Win+Ctrl+Shift and press t
           				 CapsLock & a    Hold CapsLock and press a
   				 
