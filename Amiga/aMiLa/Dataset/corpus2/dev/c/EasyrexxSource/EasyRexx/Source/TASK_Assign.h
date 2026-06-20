/*
 *	File:					TASK_Assign.h
 *	Description:	Assign window which displays credits and information
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef TASK_ASSIGN_H
#define TASK_ASSIGN_H

/*** INCLUDES ************************************************************************/
#include "Designer_AREXX.h"

/*** GLOBALS *************************************************************************/
extern struct egTask	assignTask;

extern struct egGadget	*macrostring[MAXMACROS];

/*** PROTOTYPES **********************************************************************/
__asm ULONG OpenAssignTask(	register __a0 struct Hook *hook,
													register __a2 APTR	      object,
													register __a1 APTR	      message);
__asm __saveds ULONG HandleAssignTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message);
void UpdateAssignTask(void);
void EnterMacroName(BYTE id, UBYTE *name);

#endif
