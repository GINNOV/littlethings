/*
**	Support code for easy implementation of the AmigaGuide help system
**	in an application. These routines are fully reentrant and 
**  self-contained.  All routines are safe to call even if AmigaGuide
**  is not running.
**
**	Copyright (C) 1995 Petter Nilsen of Ultima Thule Software,
**						All Rights Reserved.
**
*/

#include <libraries/amigaguide.h>
#include <exec/memory.h>
#include <dos/dos.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/amigaguide.h>

struct GuideContext
{
	AMIGAGUIDECONTEXT 	guidecontext;
	ULONG 				guidesignal;
	struct Library		*guidebase;
	struct ExecBase		*SysBase;
};

#define GUIDECONTEXT
typedef struct GuideContext *GuideContext;

#include "simpleguide.h"


/****** simpleguide/AmigaGuideOpen ******************************************
*
*   NAME	
*       AmigaGuideOpen -- Open async AmigaGuide prosess ready for input
*
*   SYNOPSIS
*       guide = AmigaGuideOpen(nag)
*       D0                     A0
*
*       GuideContext AmigaGuideOpen(struct NewAmigaGuide *);
*
*   FUNCTION
*       This function will start AmigaGuide async and wait until the help 
*       system has been successfully started. 
*       The amigaguide.library V34+ will also be opened.
*
*   INPUTS
*       nag - a pointer to an initialized NewAmigaGuide structure. 
*             Unused fields in this structure must be set to 0.
*
*   RESULT
*       guide - A pointer to a GuideContext, or NULL on failure.
*
*   EXAMPLE
*
*       enum {
*           HELP_MAIN,
*           HELP_MACROKEYS,
*       };
*
*       GuideContext guide = NULL;
*
*       struct NewAmigaGuide nag = {NULL};
*
*       STRPTR context[] = 
*       { 	
*           "Main",
*           "Macro_Keys",		[Note that AmigaGuide won't allow spaces]
*           NULL				[in a node name!]
*		};
*
*       nag.nag_BaseName = "THOR Help";
*       nag.nag_Name = "THOR.guide";			[Set the document name]
*       nag.nag_Screen = Scr;           		[screen pointer]
*       nag.nag_Context = context;				[context table]
*       nag.nag_Node = HELP_MAIN;				[node to align on first]
*
*       guide = AmigaGuideOpen(&nag);
*
*       [....]
*
*       [We need some help here]
*
*       if(guide)
*       {
*           [Set up what node we want help on]
*
*           SetGuideContext(guide, HELP_MACROKEYS);
*
*           [Start the show]
*
*           SendGuideContext(guide);
*
*           [Optional: Set the node pointer back to the first node]
*	
*           SetGuideContext(guide, HELP_MAIN);
*       }
*
*
*   NOTES
*       The AmigaGuide help system must be closed with the AmigaGuideClose()
*       function.
*       Safe to call with a NULL pointer.
*
*   BUGS
*
*   SEE ALSO
*       AmigaGuideClose, HandleAmigaGuide
*
******************************************************************************
*
*/

__asm GuideContext AmigaGuideOpen(register __a0 struct NewAmigaGuide *nag)
{
	struct Library *AmigaGuideBase;
    struct AmigaGuideMsg *agm;
	GuideContext		guide;
	BOOL				OPEN;
	BOOL				ACTIVE;
	struct ExecBase *SysBase = *(struct ExecBase **)4L;
	UBYTE ag_lib[20];

	/* We are really serious about having no global data.. :-) */

	ag_lib[0] = 'a';
	ag_lib[1] = 'm';
	ag_lib[2] = 'i';
	ag_lib[3] = 'g';
	ag_lib[4] = 'a';
	ag_lib[5] = 'g';
	ag_lib[6] = 'u';
	ag_lib[7] = 'i';
	ag_lib[8] = 'd';
	ag_lib[9] = 'e';
	ag_lib[10] = '.';
	ag_lib[11] = 'l';
	ag_lib[12] = 'i';
	ag_lib[13] = 'b';
	ag_lib[14] = 'r';
	ag_lib[15] = 'a';
	ag_lib[16] = 'r';
	ag_lib[17] = 'y';
	ag_lib[18] = '\0';


	if(!nag) 
		return(NULL);

	OPEN = FALSE;
	ACTIVE = FALSE;

	if(guide = (GuideContext)AllocVec(sizeof(struct GuideContext), MEMF_CLEAR))
	{
		if(AmigaGuideBase = OpenLibrary(ag_lib, 34L))
		{
			guide->guidebase = AmigaGuideBase;
			guide->SysBase = SysBase;

			if(guide->guidecontext = OpenAmigaGuideAsync(nag, NULL))
			{
				if(guide->guidesignal = AmigaGuideSignal(guide->guidecontext))
				{
					OPEN = TRUE;

					Wait(guide->guidesignal);

					while(!ACTIVE)
					{
					    while(agm = GetAmigaGuideMsg(guide->guidecontext))
					    {
							/* Ok startup of the guide file */
							if(agm->agm_Type == ActiveToolID)
    							ACTIVE = TRUE;

							/* Opening the guide file failed for some reason, continue as usual */
							if(agm->agm_Type == ToolStatusID && agm->agm_Pri_Ret)
								ACTIVE = TRUE;

							ReplyAmigaGuideMsg(agm);
						}
				    }
				}
			}
		}
		if(!OPEN)
		{
			if(guide) 
			{
				AmigaGuideClose(guide);
				guide = NULL;
			}
		}
	}
	return(guide);
}

/****** simpleguide/AmigaGuideClose ******************************************
*
*   NAME	
*       AmigaGuideClose -- Close async AmigaGuide prosess already opened with
*                          AmigaGuideOpen().
*
*   SYNOPSIS
*       AmigaGuideClose(guide)
*                       A0
*
*       void AmigaGuideClose(GuideContext);
*
*   FUNCTION
*       This function will close the AmigaGuide async prosess already opened
*       with AmigaGuideOpen() and free the structure passed in. If AmigaGuide
*       have a window open, this window will be closed. This function should
*       used if you close the screen or your application is finished running.
*
*   INPUTS
*       guide - a pointer to an initialized GuideContext structure optained with
*               a call to AmigaGuideOpen().
*
*   RESULT
*
*   EXAMPLE
*
*   NOTES
*       Safe to call with a NULL pointer.
*
*   BUGS
*
*   SEE ALSO
*       AmigaGuideOpen, HandleAmigaGuide
*
******************************************************************************
*
*/
 __asm void AmigaGuideClose(register __a0 GuideContext guide)
{
	struct Library *AmigaGuideBase;
	struct ExecBase *SysBase;

	if(guide)
	{
		AmigaGuideBase = guide->guidebase;
		SysBase = guide->SysBase;

		if(guide->guidecontext)
			CloseAmigaGuide(guide->guidecontext);

		if(guide->guidebase)
			CloseLibrary(guide->guidebase);

		FreeVec(guide);
	}
}

/****** simpleguide/HandleAmigaGuide ******************************************
*
*   NAME	
*       HandleAmigaGuide - will simple reply to all outstanding messages 
*                          from the AmigaGuide prosess started with
*                          AmigaGuideOpen().
*
*
*   SYNOPSIS
*       HandleAmigaGuide(guide)
*                        A0
*
*       void HandleAmigaGuide(GuideContext);
*
*   FUNCTION
*       This function will simple reply to all outstanding messages from the
*       AmigaGuide prosess given with the GuideContext argument.
*
*   INPUTS
*       guide - a pointer to an initialized GuideContext structure optained with
*               a call to AmigaGuideOpen().
*
*   RESULT
*
*   EXAMPLE
*
*   NOTES
*       Safe to call with a NULL pointer.
*
*   BUGS
*
*   SEE ALSO
*       AmigaGuideOpen, AmigaGuideClose
*
******************************************************************************
*
*/
 __asm void HandleAmigaGuide(register __a0 GuideContext guide)
{
	struct Library	*AmigaGuideBase;
    struct AmigaGuideMsg *agm;

	if(guide)
	{
		AmigaGuideBase = guide->guidebase;

	    while(agm = GetAmigaGuideMsg(guide->guidecontext))
			ReplyAmigaGuideMsg(agm);
	}
}

/****** simpleguide.c/GetAmigaGuideSignal ******************************************
*
*   NAME	
*       GetAmigaGuideSignal - will return a signal to be used in event-loops
*
*
*   SYNOPSIS
*       signal = GetAmigaGuideSignal(guide)
*       D0                           A0
*
*       ULONG GetAmigaGuideSignal(GuideContext);
*
*   FUNCTION
*       This function will simply return a signal to be used in event loops.
*
*   INPUTS
*       guide - a pointer to an initialized GuideContext structure optained with
*               a call to AmigaGuideOpen().
*
*   RESULT
*       signal - A signal previously optained in the GuideContext structure
*            after calling AmigaGuideOpen().  Will return 0 if the pointer
*            passed in is NULL.
*
*   EXAMPLE
*
*   NOTES
*       Safe to call with a NULL pointer, and will return 0L if this is the
*       case. 
*
*   BUGS
*
*   SEE ALSO
*       AmigaGuideOpen, AmigaGuideClose
*
******************************************************************************
*
*/
__asm ULONG GetAmigaGuideSignal(register __a0 GuideContext guide)
{
	if(guide)
		return(guide->guidesignal);
	else
		return(0L);
}

/****** simpleguide/GetAmigaGuideBase ******************************************
*
*   NAME	
*       GetAmigaGuideBase - will return a pointer to AmigaGuideBase
*
*   SYNOPSIS
*       base = GetAmigaGuideBase(guide)
*       D0                       A0
*
*       struct Library * GetAmigaGuideBase(GuideContext);
*
*   FUNCTION
*       This function will return a pointer to AmigaGuideBase and must be called
*       first if you intent to call any functions in amigaguide.library directly.
*
*   INPUTS
*       guide - a pointer to an initialized GuideContext structure optained with
*               a call to AmigaGuideOpen().
*
*   RESULT
*       base - A AmigaGuideBase pointer previously optained in the GuideContext 
*          structure after calling AmigaGuideOpen().  Will return NULL if the 
*          pointer passed in is NULL.
*
*   EXAMPLE
*
*       struct Library *AmigaGuideBase;
*
*       if(AmigaGuideBase = GetAmigaGuideBase(guidecontext))
*       {
*           [safely call amigaguide.library functions directly here]
*       }
*
*   NOTES
*       Safe to call with a NULL pointer, and will return NULL if this is the
*       case. 
*
*   BUGS
*
*   SEE ALSO
*       AmigaGuideOpen, AmigaGuideClose
*
******************************************************************************
*
*/
__asm struct Library *GetAmigaGuideBase(register __a0 GuideContext guide)
{
	if(guide)
		return(guide->guidebase);
	else
		return(NULL);
}

/****** simpleguide/SetGuideContext ******************************************
*
*   NAME	
*       SetGuideContext -- Set the context ID for an AmigaGuide system.
*
*   SYNOPSIS
*       success = SetGuideContext(guide, node)
*       D0                        A0     D0
*
*       BOOL SetGuideContext(GuideContext, ULONG);
*
*	FUNCTION
*       This function, and the SendGuideContext() function, are used to
*       provide a simple way to display a node based on a numeric value,
*       instead of having to build up a slightly more complex command
*       string.
*
*   INPUTS
*       guide - a pointer to an initialized GuideContext structure optained with
*          a call to AmigaGuideOpen().
*
*       node  - Index value of the desired node to display.
*
*   RESULT
*       success - Returns TRUE if a valid context ID and GuideContext pointer was 
*          passed, otherwise returns FALSE.
*
*   EXAMPLE
*
*   NOTES
*       Safe to call with a NULL pointer, and will return FALSE if this is the
*       case. 
*
*   BUGS
*
*   SEE ALSO
*       SetAmigaGuideContext, SendGuideContext
*
******************************************************************************
*
*/
__asm BOOL SetGuideContext(register __a0 GuideContext guide, register __d0 ULONG index)
{
	struct Library	*AmigaGuideBase;

	if(guide)
	{
		AmigaGuideBase = guide->guidebase;
		return((BOOL)SetAmigaGuideContext(guide->guidecontext, index, NULL));
	}
	return(FALSE);
}

/****** simpleguide/SendGuideContext ******************************************
*
*   NAME	
*       SendGuideContext - Align an AmigaGuide system on the context ID.
*
*   SYNOPSIS
*       success = SendGuideContext(guide)
*       D0                         A0
*
*       BOOL SendGuideContext(GuideContext);
*
*	FUNCTION
*       This function is used to send a message to an AmigaGuide system to
*       align it on the current context ID.
*
*   INPUTS
*       guide - a pointer to an initialized GuideContext structure optained with
*          a call to AmigaGuideOpen().
*
*   RESULT
*       success - Returns TRUE if a valid GuideContext pointer was passed and the
*          message was sent, otherwise returns FALSE.
*
*   EXAMPLE
*
*   NOTES
*       Safe to call with a NULL pointer, and will return FALSE if this is the
*       case. 
*
*   BUGS
*
*   SEE ALSO
*       SendAmigaGuideContext, SetGuideContext
*
******************************************************************************
*
*/
__asm BOOL SendGuideContext(register __a0 GuideContext guide)
{
	struct Library	*AmigaGuideBase;

	if(guide)
	{
		AmigaGuideBase = guide->guidebase;
		return((BOOL)SendAmigaGuideContext(guide->guidecontext, NULL));
	}
	return(FALSE);
}

