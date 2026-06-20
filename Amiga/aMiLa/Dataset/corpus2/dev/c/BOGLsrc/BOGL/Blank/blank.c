/* -------------------------------------------------------------------------- *\
   BLANK.C
   Copyright © 1998 by Jarno van der Linden
   jarno@kcbbs.gen.nz

   AMRTL output handler for BOGL Garshneblanker

   This program is Freeware, and all usual Freeware rules apply.

   22 Nov 1998: Project started
\* -------------------------------------------------------------------------- */

/* -------------------------------- Includes -------------------------------- */
#include <exec/types.h>
#include <exec/semaphores.h>

#include <gl/outputhandler.h>

#include <pragmas/outputhandler_pragmas.h>

#include <proto/exec.h>
#include <proto/utility.h>

#include <string.h>

#include "blank.h"

/* ------------------------------ Definitions ------------------------------- */

/* --------------------------------- Macros --------------------------------- */

/* -------------------------------- Typedefs -------------------------------- */

/* ------------------------------ Proto Types ------------------------------- */

/* -------------------------------- Structs --------------------------------- */

/* -------------------------------- Globals --------------------------------- */
volatile char oldoh[256];
struct Library	*outputhandlerBase,
				*UtilityBase;
struct SignalSemaphore sem, sem2;
volatile APTR output;
volatile ULONG framecount;

/* ---------------------------------- Code ---------------------------------- */

__asm __saveds int __UserLibInit(register __a6 struct blankBase *libbase)
{
	if(UtilityBase = OpenLibrary("utility.library",36L))
	{
		outputhandlerBase = NULL;
		InitSemaphore(&sem);
		InitSemaphore(&sem2);
		framecount = 0;
		output = NULL;

		return 0;
	}
	CloseLibrary(UtilityBase);
	UtilityBase = NULL;

	return 1;
}


__asm __saveds void __UserLibCleanup(register __a6 struct blankBase *libbase)
{
	if(UtilityBase) CloseLibrary(UtilityBase);
	UtilityBase = NULL;
}


__asm __saveds int BlankInitOutputHandlerA(register __a0 AmigaMesaRTLContext mesacontext, register __a1 struct TagItem *tags)
{
	struct TagItem *filteredtags;
	Tag filters[] = { OH_Output, OH_OutputType, TAG_END };
	int ret;

	ret = 0;

	if(outputhandlerBase)
		return(0);

	filteredtags = CloneTagItems(tags);
	FilterTagItems(filteredtags, filters, TAGFILTER_NOT);

	ObtainSemaphore(&sem);
	outputhandlerBase = OpenLibrary((char *)oldoh,0);
	if(outputhandlerBase)
		ret = InitOutputHandler(mesacontext,	OH_Output,		output,
												OH_OutputType,	"Window",
												TAG_MORE,		filteredtags );
	ReleaseSemaphore(&sem);

	FreeTagItems(filteredtags);

	return ret;
}


__asm __saveds void BlankDeleteOutputHandler(void)
{
	DeleteOutputHandler();

	if(outputhandlerBase)
		CloseLibrary(outputhandlerBase);
	outputhandlerBase = NULL;

	ObtainSemaphore(&sem2);
	framecount = 0;
	ReleaseSemaphore(&sem2);

	ObtainSemaphore(&sem);
	output = NULL;
	ReleaseSemaphore(&sem);
}


__asm __saveds int BlankResizeOutputHandler(void)
{
	return ResizeOutputHandler();
}


__asm __saveds int BlankProcessOutput(void)
{
	int ret;

	ret = ProcessOutput();

	ObtainSemaphore(&sem2);
	framecount++;
	ReleaseSemaphore(&sem2);

	return ret;
}


__asm __saveds void BlankSetIndexRGBTable(register __d0 int index, register __a0 ULONG *rgbtable, register __d1 int numcolours)
{
	SetIndexRGBTable(index,rgbtable,numcolours);
}


__asm __saveds ULONG BlankSetOutputHandlerAttrsA(register __a0 struct TagItem *tags)
{
	struct TagItem *tstate, *tag;
	ULONG tidata;
	ULONG ret;

	ret = 0;
	tstate = tags;

	while(tag = NextTagItem(&tstate))
	{
		tidata = tag->ti_Data;

		switch(tag->ti_Tag)
		{
			case BLANK_OldOH:
				ObtainSemaphore(&sem);
				if(tidata)
				{
					strcpy((char *)oldoh,"outputhandlers/");
					strcat((char *)oldoh,tidata);
				}
				ReleaseSemaphore(&sem);

				ret |= 1;
				break;
			case OH_Output:
				{
					char *ot;

					ot = (char *)GetTagData(OH_OutputType, NULL, tags);
					if((ot) && (stricmp(ot,"Window") == 0))
					{
						ObtainSemaphore(&sem);
						output = (APTR)tidata;
						ReleaseSemaphore(&sem);
					}

					ret |= 1;
				}
				break;
			case OH_OutputType:
				ret |= 1;
				break;
			default:
				break;
		}
	}

	if(ret)
		return ret;

	return SetOutputHandlerAttrs(tags);
}


__asm __saveds ULONG BlankGetOutputHandlerAttr(register __d0 ULONG attr, register __a0 ULONG *data)
{
	switch(attr)
	{
		case BLANK_Done:
			*(BOOL *)data = output ? FALSE : TRUE;
			return 1;
			break;
		case BLANK_FrameCount:
			ObtainSemaphore(&sem2);
			*(ULONG *)data = framecount;
			ReleaseSemaphore(&sem2);
			return 1;
			break;
	}

	return GetOutputHandlerAttr(attr,data);
}
