/*
 *	File:					HandleFlags.c
 *	Description:	A set of functions that handles the input in Main window
 *
 *	(C) 1995, Ketil Hunn
 *
 */

#ifndef	HANDLEFLAGS_C
#define	HANDLEFLAGS_C

/*** INCLUDES ************************************************************************/
#include "System.h"
#include "HandleFlags.h"
#include "TASK_Main.h"

/*** FUNCTIONS ***********************************************************************/
UBYTE *StripFlags(UBYTE *string)
{
	register UBYTE argument[256], *c=argument;

#ifdef MYDEBUG_H
	DebugOut("StripFlags");
#endif

	strcpy(argument, string);
	while(*c!='\0')
	{
		if(*c=='/')
		{
			*c='\0';
			break;
		}
		else
			++c;		
	}
	return argument;
}

void PutFlags(struct Node *node)
{
	UBYTE argument[MAXCHARS];

#ifdef MYDEBUG_H
	DebugOut("PutFlags");
#endif

	strcpy(argument, StripFlags(node->ln_Name));

	if(ISBITSET(node->ln_Pri, ALWAYS))
		strcat(argument, "/A");
	if(ISBITSET(node->ln_Pri, KEYWORD))
		strcat(argument, "/K");
	if(ISBITSET(node->ln_Pri, NUMBER))
		strcat(argument, "/N");
	if(ISBITSET(node->ln_Pri, SWITCH))
		strcat(argument, "/S");
	if(ISBITSET(node->ln_Pri, TOGGLE))
		strcat(argument, "/T");
	if(ISBITSET(node->ln_Pri, MULTIPLE))
		strcat(argument, "/M");
	if(ISBITSET(node->ln_Pri, FINAL))
		strcat(argument, "/F");

	DetachList(arguments, mainTask.window);
	RenameNode(node, argument);
	AttachList(arguments, mainTask.window, argumentlist);
	UpdateMainTask(TRUE);
}


#endif
