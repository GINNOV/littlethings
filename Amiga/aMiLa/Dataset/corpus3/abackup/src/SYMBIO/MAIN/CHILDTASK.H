/*
* This file is part of ABackup.
* Copyright (C) 1999 Denis Gounelle
* 
* ABackup is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* ABackup is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with ABackup.  If not, see <http://www.gnu.org/licenses/>.
*
*/
/*  _______________________________________________________________________

    ABackup 5.0
    childtask.h

    Copyright © 1992-1995
    by Denis Gounelle & Reza Elghazi,
    All Rights Reserved.
    _______________________________________________________________________

    Version : 38.0
    Created : 20-Nov-93
    Modified: 10-May-94
    _______________________________________________________________________
*/

#ifndef ABACKUP_CHILDTASK_H
#define ABACKUP_CHILDTASK_H

#define MINWBUFSIZE	KBYTES(12)  // minimal size of child task buffer
#define MEMORYTOLEAVE	KBYTES(256) // memory to leave for others, see OpenArc()

struct InternalCmd
{
  struct Message  ic_Message;	// message to send to child/parent
  UWORD 	  ic_Command;	// command number
  UWORD 	  ic_Flags;	// special flags
  struct ArcUnit *ic_Unit;	// unit on which command is to apply
  BYTE		 *ic_Data;	// data pointer for ICMDN_WRITE
  LONG		  ic_Arg;	// argument/result
};

/* commands classes */

#define ICMDC_SYNC	0x8000		// synchronous command
#define ICMDC_ASYNC	0x4000		// asynchronous command
#define ICMDC_DEMAND	0x2000		// demand from child task
#define ICMDC_PRIOR	0x1000		// prioritary command

#define ICMDC_MASK	0xF000

/* commands numbers */

#define ICMDN_OPEN	0x000		// opens the device
#define ICMDN_CLOSE	0x001		// closes the device
#define ICMDN_DOIO	0x002		// sends device command
#define ICMDN_SYNC	0x003		// waits end of queued writes and flush last cyl
#define ICMDN_DIE	0x004		// terminates the child task
#define ICMDN_WRITE	0x005		// writes
#define ICMDN_CANCEL	0x007		// cancels all queued writes
#define ICMDN_RESTART	0x008		// next floppy inserted
#define ICMDN_ASKDISK	0x009		// asks next floppy
#define ICMDN_BADCYL	0x00A		// reports bad cylinder
#define ICMDN_ERROR	0x00B		// fatal error
#define ICMDN_WAIT	0x00C		// waits end of queued writes

#define ICMDN_MASK	0x00F

/* values for ic_Command */

#define ICMD_OPEN	(ICMDC_SYNC|ICMDN_OPEN)
#define ICMD_CLOSE	(ICMDC_SYNC|ICMDN_CLOSE)
#define ICMD_SYNC	(ICMDC_SYNC|ICMDN_SYNC)
#define ICMD_WAIT	(ICMDC_SYNC|ICMDN_WAIT)
#define ICMD_DOIO	(ICMDC_SYNC|ICMDC_PRIOR|ICMDN_DOIO)
#define ICMD_SWRITE	(ICMDC_SYNC|ICMDC_PRIOR|ICMDN_WRITE)
#define ICMD_CANCEL	(ICMDC_SYNC|ICMDC_PRIOR|ICMDN_CANCEL)
#define ICMD_RESTART	(ICMDC_SYNC|ICMDC_PRIOR|ICMDN_RESTART)

#define ICMD_DIE	(ICMDC_ASYNC|ICMDN_DIE)
#define ICMD_AWRITE	(ICMDC_ASYNC|ICMDC_PRIOR|ICMDN_WRITE)

#define ICMD_ASKDISK	(ICMDC_DEMAND|ICMDN_ASKDISK)
#define ICMD_BADCYL	(ICMDC_DEMAND|ICMDN_BADCYL)
#define ICMD_ERROR	(ICMDC_DEMAND|ICMDN_ERROR)

/* values for ic_Flags */

#define ICMDF_FREEMSG	0x0001		// FreeVec() message after use

#endif	// ABACKUP_CHILDTASK_H
