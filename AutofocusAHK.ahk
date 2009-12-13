; AutofocusAHK
;
; This is the main file of the script. It sets the environment and
; includes the other files. 
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.2.2
; @since     0.1

;; ENVIRONMENT

; Make sure the script stays in memory
#Persistent

; The script will check every 5 minutes if the conditions for the morning routine are met.
SetTimer,MorningRoutine,300000

; Set up the system
Initialize()

; End of auto-execute section
Return

;; INCLUDE FILES

#include AutofocusAHK-system.ahk

#include AutofocusAHK-tray.ahk

#include AutofocusAHK-triggers.ahk

#include AutofocusAHK-files.ahk

#include AutofocusAHK-gui.ahk

#include AutofocusAHK-af1.ahk
#include AutofocusAHK-af2.ahk
#include AutofocusAHK-af3.ahk
#include AutofocusAHK-af4.ahk

















