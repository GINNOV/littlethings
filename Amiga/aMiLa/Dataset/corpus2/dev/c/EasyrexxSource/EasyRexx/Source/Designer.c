/*
 *	File:					Designer.c
 *	Description:	Main program
 *	Version:			3.1
 *	Author:				Ketil Hunn
 *	Mail:					Ketil.Hunn@hiMolde.no
 *
 *	Copyright ©		1994,1995 Ketil Hunn.
 *
 */

#ifndef DESIGNER_C
#define DESIGNER_C

/*** INCLUDES ************************************************************************/
#include "System.h"
#include "TASK_Main.h"
#include "TASK_Assign.h"
#include "TASK_About.h"
#include "Asl.h"
#include "TASK_Code.h"
#include "Designer_AREXX.h"
#include "ProjectIO.h"
#include "GUI_Environment.h"
#include "myinclude:Exists.h"

/*** GLOBALS *************************************************************************/
static const char version[]=VERSTAG;

/*** FUNCTIONS ***********************************************************************/
void main(int argc, char **argv)
{
	if(OpenResources())
	{
		NameFromLock(GetProgramDir(), startdir, MAXCHARS-1);
		GetTooltypes(argc, argv);

		if(OpenGUIEnvironment(&mainTask, &assignTask, &codeTask, &aboutTask, NULL))
		{
			if(commandlist=InitList())
			{
				ULONG signal;

				if(EasyRexxBase)
					macro=AllocARexxMacro(TAG_DONE);

				/* Exchange 'Unnamed' with the localized string */
				if(0==Stricmp(FilePart(project), "Unnamed"))
				{
					*PathPart(project)='\0';
					AddPart(project, egGetString(MSG_UNNAMED), MAXCHARS-1);
				}

				AllocMainMenu();
				if(Exists(project))
				{
					ReadIFF(commandlist, project, FALSE);
					GetFirstCommand();
					GetFirstArgument();
				}

				OpenMainTask(NULL, NULL, NULL);
				if(assignTask.status)
					OpenAssignTask(NULL, NULL, NULL);
				if(codeTask.status)
					OpenCodeTask(NULL, NULL, NULL);
				if(aboutTask.status)
					OpenAboutTask(NULL, NULL, NULL);

				while(egTaskActive(&mainTask) | !ER_SAFETOQUIT(context))
				{
					signal=egWait(eg, ER_SIGNAL(context));

					ER_SETSIGNALS(context, signal);
					if(signal & ER_SIGNAL(context))
						myHandleARexx(context);
				}
				RemoveNode((struct Node *)commandbuffer);
				RemoveNode((struct Node *)argumentbuffer);
				FreeMenus(mainMenu);
				if(EasyRexxBase)
					FreeARexxMacro(macro);
				FreeList(commandlist);
			}
		}
		CloseGUIEnvironment();
	}
	CloseResources();
}

#endif
