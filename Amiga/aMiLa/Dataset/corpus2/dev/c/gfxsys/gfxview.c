#include <simple/inc.h>
#include <simple/intuition.h>
#include <simple/utility.h>

#include "global.h"
#include "gfxwin.h"
#include "gfxreq.h"
#include "gfxerrors.h"

extern struct Library * IntuitionBase;
extern struct Library * UtilityBase;

struct GfxView * CreateGfxView (struct TagItem *TagList)
{
struct GfxView * GfxView;

if ( (GfxView=AllocMem(sizeof(struct GfxView),MEMF_CLEAR)) == NULL )
	return(NULL);

if ( (GfxView->IDCMPport = CreateMsgPort()) == NULL )
	{
	GfxView->Error = GFXERROR_INIT_MESSAGE_PORT;
	return(GfxView);
	}

if ( FindTagItem(GV_AskScreen,TagList) )
	{
	GfxView->ScreenType = GVST_CUSTOM;
	GfxView->Screen = MakeRequestedScreen();
	}
else if ( FindTagItem(GV_PubScreen,TagList) )
	{
	GfxView->ScreenType = GVST_PUBLIC;
	GfxView->Screen = LockPubScreen((char *)GetTagData(GV_PubScreen,0,TagList));
	}
else if ( FindTagItem(GV_CustomScreen,TagList) )
	{
	GfxView->ScreenType = GVST_CUSTOM;
	GfxView->Screen = OpenScreenTagList(NULL,(struct TagItem *)
		GetTagData(GV_CustomScreen,0,TagList));	
	}
else
	{
	GfxView->Error = GFXERROR_NO_SCREEN_SPECIFIED;
	return(GfxView);
	}

if ( GfxView->Screen == NULL )
	{
	GfxView->Error = GFXERROR_OPEN_SCREEN;
	return(GfxView);	
	}

GfxView->ScreenSizeX = GfxView->Screen->Width;
GfxView->ScreenSizeY = GfxView->Screen->Height;

return(GfxView);
}

void CloseGfxView (struct GfxView *GfxView)
{
while (GfxView->GfxWindows)
	{
	RemoveGfxWindow(GfxView,GfxView->GfxWindows);
	}

if (GfxView->IDCMPport)
	{
	DeleteMsgPort(GfxView->IDCMPport);
	}

if (GfxView->Screen)
	{
	if (GfxView->ScreenType == GVST_CUSTOM)
		{
		CloseScreen(GfxView->Screen);
		}
	else if (GfxView->ScreenType == GVST_PUBLIC)
		{
		UnlockPubScreen(NULL,GfxView->Screen);
		}
	}

FreeMem(GfxView,sizeof(struct GfxView));
}
