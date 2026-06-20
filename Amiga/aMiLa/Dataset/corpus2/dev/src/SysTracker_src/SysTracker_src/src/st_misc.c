/***************************************************************************/
/* st_misc.c - Misc routines.                                              */
/*                                                                         */
/* Copyright © 1999-2000 Andrew Bell. All rights reserved.                 */
/***************************************************************************/

#include "SysTracker_rev.h"
#include "st_include.h"
#include "st_protos.h"

/***************************************************************************/

GPROTO ULONG R_GetTasksStackSize( void )
{
  /*********************************************************************
   *
   * R_GetTasksStackSize()
   *
   * Get the task's current stack size.
   *
   *********************************************************************
   *
   */

  register struct Task *Tsk = FindTask(NULL);
  return (ULONG) Tsk->tc_SPUpper - (ULONG) Tsk->tc_SPLower;
}

GPROTO BOOL R_DateStampToStr( struct DateStamp *DS, UBYTE *Buf )
{
  /*********************************************************************
   *
   * R_DateStampToStr()
   *
   * Construct a date string using a standard dos.library DateStamp
   * structure. Example output: Friday 15-Oct-99 18:00:00
   *
   * Notes
   * -----
   * Buf should point to a buffer at least 128 bytes long!
   *
   *********************************************************************
   *
   */

  UBYTE DayPart[LEN_DATSTRING];
  UBYTE DatePart[LEN_DATSTRING];
  UBYTE TimePart[LEN_DATSTRING];

  struct DateTime MyDT =
  {
    { 0, 0, 0 },
    FORMAT_DOS,
    0,
    NULL, NULL, NULL
  };

  MyDT.dat_StrDay = DayPart;
  MyDT.dat_StrDate = DatePart;
  MyDT.dat_StrTime = TimePart;
  DayPart[0] = 0; DatePart[0] = 0; TimePart[0] = 0;
  MyDT.dat_Stamp.ds_Days   = DS->ds_Days;
  MyDT.dat_Stamp.ds_Minute = DS->ds_Minute;
  MyDT.dat_Stamp.ds_Tick   = DS->ds_Tick;

  if (DateToStr((struct DateTime *) &MyDT))
  {
    sprintf(Buf, "%s %s %s",
      (UBYTE *) &DayPart, (UBYTE *) &DatePart, (UBYTE *) &TimePart);
    return TRUE;
  }

  return FALSE;
}

GPROTO BOOL R_IsTaskPtrValid( struct Task *TaskPtr )
{
  /*********************************************************************
   *
   * R_IsTaskPtrValid()
   *
   * Determine if a Task/Process pointer is still valid. This routine
   * should be called under a Forbid()/Premit() pair.
   *
   * Warning
   * -------
   *
   * This routine is a bit hacky , because it accesses the private
   * exec lists in execbase.
   *
   * Notes
   * -----
   *
   * SysTracker will only ever call this routine when the 
   * cfg_BeSystemLegal BOOL is FALSE.
   *
   *********************************************************************
   *
   */

  register struct Task *TaskNode = NULL;
  register BOOL Found = FALSE;

  Disable();

  for (TaskNode = (struct Task *) SysBase->TaskReady.lh_Head;
       TaskNode->tc_Node.ln_Succ;
       TaskNode = (struct Task *) TaskNode->tc_Node.ln_Succ)
  {
    if (TaskPtr == TaskNode) Found = TRUE;
  }

  if (!Found)
    for (TaskNode = (struct Task *) SysBase->TaskWait.lh_Head;
         TaskNode->tc_Node.ln_Succ;
         TaskNode = (struct Task *) TaskNode->tc_Node.ln_Succ)
    {
      if (TaskPtr == TaskNode) Found = TRUE;
    }

  Enable();
  return Found;
}

