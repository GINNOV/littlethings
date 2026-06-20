#include <simple/inc.h>
#include <simple/intuition.h>

#include "global.h"
#include "gfxwin.h"
#include "gfxview.h"
#include "refresh.h"
#include "dohandlers.h"
#include "gfxactive.h"

extern struct Library * IntuitionBase;

short MainLoop (struct GfxView *GfxView)
{
struct GfxWindow *GfxWin;
struct Window * Win;
struct IntuiMessage * Msg;
ulong MsgClass;
uword MsgCode;
uword MsgQual;
uword mX,mY;

if ( ! GfxView->GfxWindows )
	{
	CloseGfxView(GfxView);
	return(1);
 	}

ActivateWindows(GfxView);

while (1)
	{
	WaitPort(GfxView->IDCMPport);
	while ( Msg = (struct IntuiMessage *) GetMsg(GfxView->IDCMPport) )
		{
		MsgClass = Msg->Class;
		MsgCode  = Msg->Code;
		MsgQual  = (Msg->Qualifier) & 0x00FF;
		mX = Msg->MouseX; 
		mY = Msg->MouseY;
		Win = Msg->IDCMPWindow;
	  ReplyMsg((struct Message *)Msg);

		GfxWin = (struct GfxWindow *) Win->UserData;

		switch(MsgClass)
			{
			case IDCMP_CLOSEWINDOW:
				{
				RemoveGfxWindow(GfxView,GfxWin);
				if ( ! (GfxView->GfxWindows) )
					{
					CloseGfxView(GfxView);
					return(1);
					}

				break;
				}

			case IDCMP_CHANGEWINDOW:
				if ( GfxWin->Flags & GWF_JUSTDIDRETAINASPECT )
					{
					GfxWin->Flags &= ( GWF_JUSTDIDRETAINASPECT ^ 0xFFFFFFFF );
					GfxWin->Flags |= GWF_FAKEOUTLAYERS;
					RefreshGfxWindow(GfxWin);
					GfxWin->Flags |= GWF_IGNORENEXTREFRESHWINDOW;
					}
				else
					{
					if ( GfxWin->Flags & GWF_IGNORENEXTCHANGEWINDOW )
						{
						GfxWin->Flags &= ( GWF_IGNORENEXTCHANGEWINDOW ^ 0xFFFFFFFF );
						}
					else
						{				
						if ( GfxWin->Flags & GWF_RETAINASPECT )	
							{
							RetainAspect(GfxWin);
							GfxWin->Flags |= GWF_IGNORENEXTREFRESHWINDOW;
							}
						else
							{
							GfxWin->Flags |= GWF_FAKEOUTLAYERS;
							RefreshGfxWindow(GfxWin);
							GfxWin->Flags |= GWF_IGNORENEXTREFRESHWINDOW;
							}
						}
					}
				break;
			case IDCMP_REFRESHWINDOW:
				if ( GfxWin->Flags & GWF_IGNORENEXTREFRESHWINDOW )
					{
					GfxWin->Flags &= ( GWF_IGNORENEXTREFRESHWINDOW ^ 0xFFFFFFFF );
					BeginRefresh(GfxWin->Window);
					EndRefresh(GfxWin->Window,TRUE);
					}
				else
					{
					GfxWin->Flags = GfxWin->Flags & GWF_USERMASK;
					GfxWin->Flags |= GWF_USELAYERS;
					RefreshGfxWindow(GfxWin);
					}
				break;


			case IDCMP_RAWKEY:
				if ( ! DoKeyHandler(GfxWin,MsgQual,MsgCode) )
					{
					CloseGfxView(GfxView);
					return(0);
					}
				break;
			case IDCMP_MOUSEBUTTONS:
				if ( MsgCode == SELECTUP )
					{
					if ( ! DoObjHandler(GfxWin,mX,mY) )
						{
						CloseGfxView(GfxView);
						return(0);
						}
					}
				break;
			default:
				CloseGfxView(GfxView);
				return(0);
				break;
			}
		}
	}
}
