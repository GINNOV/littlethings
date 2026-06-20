/*
 *	File:					TASK_Code.h
 *	Description:	Code generator window.
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef TASK_CODE_H
#define TASK_CODE_H

/*** DEFINES *************************************************************************/
#define	HANDLE_IDS					0
#define	HANDLE_FUNCS				1

/*** GLOBALS *************************************************************************/
extern struct egTask	codeTask;

struct CodeData
{
	BYTE	arexxhandler,
				templates,
				main,
				handle;
	UBYTE author[MAXCHARS],
				copyright[MAXCHARS],
				version[MAXCHARS],
				portname[MAXCHARS];
};

extern struct CodeData code;
extern UBYTE generatefile[MAXCHARS];

/*** PROTOTYPES **********************************************************************/
__asm __saveds ULONG OpenCodeTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message);
__asm __saveds ULONG HandleCodeTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message);
void UpdateCodeTask(void);

#endif
