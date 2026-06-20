/*
 *	File:					TASK_About.h
 *	Description:	About requester window.
 *
 *	(C) 1995 Ketil Hunn
 *
 */

#ifndef TASK_ABOUT_H
#define TASK_ABOUT_H

/*** GLOBALS *************************************************************************/
extern struct egTask	aboutTask;
extern struct Image	aboutImage;
extern struct List 	*aboutlist;


/*** PROTOTYPES **********************************************************************/
__asm __saveds ULONG OpenAboutTask(	register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message);
__asm __saveds ULONG HandleAboutTask(register __a0 struct Hook *hook,
																		register __a2 APTR	      object,
																		register __a1 APTR	      message);

__asm BYTE TextToList(register __a0 struct List *list,
											register __a1 UBYTE				*text,
											register __d0 UWORD				width);
void UpdateAboutTask(void);
#endif
