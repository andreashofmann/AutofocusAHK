; AutofocusAHK
;
; This file holds all functions specific to the Autofocus 1 system. 
;
; @author    Andreas Hofmann
; @license   See LICENSE.txt
; @version   0.9.5.1
; @since     0.9

AF1_IsReviewOptional()
{
  Return 1
}

AF1_IsValidTask(TaskName, TaskStats, TaskIndex)
{
  global

  If (TaskName == "Change to review mode")
  {
    HasReviewModeTask := 1

    Return 1
  }

  If (TaskName == "Change to forward mode")
  {
    If (CurrentTask > TaskIndex) CurrentTask -= CurrentTask

    Return 0
  }

  If (TaskName == "---")
  {
    Return 0
  }

  Return 1
}

AF1_PostTaskLoad()
{
  global

  If (CurrentTask == 0 or CurrentTask > TaskCount or Tasks%CurrentTask%_3 == 4)
  {
    SelectNextTask()
  }
}

AF1_PostTaskAdd()
{
}

AF1_SelectNextTask()
{
  global

  If (UnactionedCount > 0)
  {
    Start := CurrentTask

    Loop
    {
      CurrentTask := CurrentTask + 1

      If (CurrentTask > LastTaskOnPage)
      {
        If (ActionOnCurrentPass or CreatingList)
        {
          CurrentTask := FirstTaskOnPage

          If (!CreatingList)
          {
            CurrentPass := CurrentPass + 1
            ActionOnCurrentPass := 0
          }
        }
        Else
        {
          If (CurrentPass == 1)
          {
            AF1_DismissTasks()
            CurrentPass := 1
            ActionOnCurrentPass := 0
            SelectNextActivePage()
          }
          Else
          {
            CurrentPass := 1
            ActionOnCurrentPass := 0
            SelectNextActivePage()
          }
        }
      }

      If (Tasks%CurrentTask%_4 == 0 or UnactionedCount == 0) 
      {
        Break
      }
    }
  }
}

AF1_Work()
{
  global

  If (CurrentMode == ReviewMode)
  {
    ShowReviewWindow()
  }
  Else If (Active == 1)
  {
    ShowDoneWindow()
  }
  Else
  {
    If (UnactionedCount <= 0)
    {
      MsgBox No unactioned tasks!

      Return
    }

    ShowWorkWindow()
  }
}

AF1_DoMorningRoutine()
{
}

AF1_DismissTasks()
{
  global

  Message := ""
  ToBeDismissed := FirstTaskOnPage

  Loop %TasksPerPage%
  {
    If (Tasks%ToBeDismissed%_4 == 0)
    {
      Tasks%ToBeDismissed%_2 := Tasks%ToBeDismissed%_2 . " R" . A_Now
      Tasks%ToBeDismissed%_4 := 1
      UnactionedCount := UnactionedCount - 1
      Message := Message . "- " . Tasks%ToBeDismissed%_1 . "`n"
    }

    ToBeDismissed += 1

    If (ToBeDismissed > LastTaskOnPage)
    {
      Break
    }
  }

  If (Message != "")
  {
    MsgBox The following tasks are now on review:`n`n%Message%
    HasTasksOnReview := 1

    If (HasReviewModeTask == 0)
    {
      TaskCount := TaskCount + 1
      UnactionedCount := UnactionedCount + 1
      Tasks%Taskcount%_1 := "Change to review mode"
      Tasks%Taskcount%_2 := "A" . A_Now
      Tasks%Taskcount%_3 := ""
      Tasks%Taskcount%_4 := 0
      HasReviewModeTask := 1
    }
  }

  SaveTasks()
}

AF1_GetWorkWindowTitle()
{
  Title .= "Work" . GetStandardWindowTitle()

  Return Title
}

AF1_GetReviewWindowTitle()
{
  Title := "Review"
  Title .= GetStandardWindowTitle()

  Return Title
}

AF1_PreShowTaskname()
{
}

AF1_PostShowTaskname()
{
}
