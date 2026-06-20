/*
 *	File:					SetMouse.c
 *	Description:	Position the mouse at any coordinates
 *
 *	(C) 1994,1995, Ketil Hunn
 *
 */

/*** PRIVATE INCLUDES ****************************************************************/
#include <exec/types.h>
#include <exec/memory.h>
#include <exec/libraries.h>
#include <devices/input.h>
#include <devices/inputevent.h>
#include <intuition/screens.h>

#include <dos/dos.h>
#include <dos/dostags.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>


/*** DEFINES *************************************************************************/
#define TEMPLATE "XPOS=NUMBER/A/N,YPOS=NUMBER/A/N,LEFTBUTTON/S,MIDDLEBUTTON/S,RIGHTBUTTON/S,DOUBLECLICK/S"
#define XPOS 					0
#define YPOS 					1
#define LEFTBUTTON 		2
#define MIDDLEBUTTON	3
#define RIGHTBUTTON 	4
#define DOUBLECLICK 	5

#define	ARGUMENTS			6

/*** GLOBALS *************************************************************************/
char const *version="\0$VER: SetMouse 2.0 (07.12.95)\©1995 Ketil Hunn";

extern struct Library *SysBase;
struct IntuitionBase *IntuitionBase;

/*** FUNCTIONS ***********************************************************************/
void SetMouse(struct Screen *screen, WORD x, WORD y, UWORD button)
{
	struct IOStdReq				*InputIO;
	struct MsgPort				*InputMP;
	struct InputEvent			*FakeEvent;
	struct IEPointerPixel	*NeoPix;

	if(InputMP=CreateMsgPort())
	{
		if(FakeEvent=AllocVec(sizeof(struct InputEvent), MEMF_PUBLIC))
		{
			if(NeoPix=AllocVec(sizeof(struct IEPointerPixel), MEMF_PUBLIC))
			{
				if(InputIO=CreateIORequest(InputMP, sizeof(struct IOStdReq)))
				{
					if(!OpenDevice("input.device", NULL, (struct IORequest *)InputIO, NULL))
					{
						NeoPix->iepp_Screen					=(struct Screen *)screen;
						NeoPix->iepp_Position.X			=x;
						NeoPix->iepp_Position.Y			=y;

						FakeEvent->ie_EventAddress	=(APTR)NeoPix;
						FakeEvent->ie_NextEvent			=NULL;
						FakeEvent->ie_Class					=IECLASS_NEWPOINTERPOS;
						FakeEvent->ie_SubClass			=IESUBCLASS_PIXEL;
						FakeEvent->ie_Code					=0;
						FakeEvent->ie_Qualifier 		=NULL;

						InputIO->io_Data						=(APTR)FakeEvent;
						InputIO->io_Length					=sizeof(struct InputEvent);
						InputIO->io_Command					=IND_WRITEEVENT;
						DoIO((struct IORequest *)InputIO);

						if(button!=IECODE_NOBUTTON)
						{
							/* BUTTON DOWN */
							FakeEvent->ie_EventAddress	=NULL;
							FakeEvent->ie_Class					=IECLASS_RAWMOUSE;
							FakeEvent->ie_Code					=button;
							DoIO((struct IORequest *)InputIO);

							/* BUTTON UP */
							FakeEvent->ie_Code					=button|IECODE_UP_PREFIX;
							DoIO((struct IORequest *)InputIO);
						}
						CloseDevice((struct IORequest *)InputIO);
					}
					DeleteIORequest(InputIO);
				}
				FreeVec(NeoPix);
			}
			FreeVec(FakeEvent);
		}
		DeleteMsgPort(InputMP);
	}
}

void __main(void)
{
	if(SysBase->lib_Version>35)
	{
		struct RDArgs	*args;
		register LONG	arg[ARGUMENTS]={0L, 0L, 0L, 0L, 0L, 0L};

		if(args=ReadArgs(TEMPLATE, arg, NULL))
		{
			struct Screen *screen;

			if(IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library", 36L))
			{
				if(screen=(struct Screen *)LockPubScreen(NULL))
				{
					register WORD 	x=(WORD)*((LONG *)arg[XPOS]),
													y=(WORD)*((LONG *)arg[YPOS]);
					register UWORD	button=0;
					register UBYTE	clicks=1;

					if(arg[LEFTBUTTON])
						button=IECODE_LBUTTON;
					if(arg[MIDDLEBUTTON])
						button|=IECODE_MBUTTON;
					if(arg[RIGHTBUTTON])
						button|=IECODE_RBUTTON;
					if(button==0)
						button=IECODE_NOBUTTON;

					if(arg[DOUBLECLICK])
						clicks=2;

					while(clicks--)
						SetMouse(screen,	(x==-1 ? screen->Width/2	: x),
															(y==-1 ? screen->Height/2	: y),
															button);

					UnlockPubScreen(NULL, screen);
				}
				CloseLibrary((struct Library *)IntuitionBase);
			}
			FreeArgs(args);
		}
	}
}
