#include <simple/inc.h>
#include <simple/utility.h>

#include "global.h"
#include "gfxutil.h"
#include "gfxerrors.h"
#include "gfxobj.h"

extern struct Library * IntuitionBase;
extern struct Library * UtilityBase;

// internal protos:
void RemoveGfxWindow (struct GfxView * GfxView,struct GfxWindow *GfxWindow);

// consts:
const char *DefaultTitle = "GfxWindow";
const char *DefaultScreenTitle = "GfxWindow Screen";
const uword DefaultZoomRect[4] = { 0,0,80,60 };

struct GfxWindow * AddGfxWindow 
	(struct GfxView * GfxView,struct TagItem *TagList)
{
ulong ScreenTag;
register struct GfxWindow * GfxWindow;
uword BorderX,BorderY;
long SizeX,SizeY;
long MinSizeX,MinSizeY;
long MaxSizeX,MaxSizeY;
long X,Y;

if ( (GfxWindow = AllocMem(sizeof(struct GfxWindow),MEMF_CLEAR)) == NULL)
	{
	GfxView->Error = GFXERROR_ALLOC;
	return(NULL);
	}

GfxWindow->Parent = GfxView;
GfxWindow->Next = GfxView->GfxWindows;
GfxView->GfxWindows = GfxWindow;

GfxWindow->KeyHandlers = (struct KeyHandler *) 
	GetTagData(GW_KeyHandlers,0,TagList);

		 if ( GfxView->ScreenType == GVST_PUBLIC )
	ScreenTag = WA_PubScreen;
else if ( GfxView->ScreenType == GVST_CUSTOM )
	ScreenTag = WA_CustomScreen;
else
	ScreenTag = TAG_IGNORE;

BorderX = GfxView->Screen->WBorLeft + GfxView->Screen->WBorRight;
BorderY = GfxView->Screen->WBorTop + GfxView->Screen->WBorBottom +
	GfxView->Screen->RastPort.TxHeight + 1;

X = GetTagData(GW_X,0,TagList);
Y = GetTagData(GW_Y,0,TagList);
SizeX = (long)GetTagData(GW_SizeX,320,TagList);
SizeY = (long)GetTagData(GW_SizeY,200,TagList);
if ( SizeX == - 1 )
	{ SizeX = GfxView->ScreenSizeX - X; }
if ( SizeY == - 1 )
	{ SizeY = GfxView->ScreenSizeY - Y; }
MinSizeX = (long)GetTagData(GW_MinSizeX,320,TagList);
MinSizeY = (long)GetTagData(GW_MinSizeY,200,TagList);
if ( MinSizeX == - 1 ) MinSizeX = GfxView->ScreenSizeX;
else MinSizeX += BorderX;
if ( MinSizeY == - 1 ) MinSizeY = GfxView->ScreenSizeY;
else MinSizeY += BorderY;
MaxSizeX = (long)GetTagData(GW_MaxSizeX,320,TagList);
MaxSizeY = (long)GetTagData(GW_MaxSizeY,200,TagList);
if ( MaxSizeX == - 1 ) MaxSizeX = GfxView->ScreenSizeX;
else MaxSizeX += BorderX;
if ( MaxSizeY == - 1 ) MaxSizeY = GfxView->ScreenSizeY;
else MaxSizeY += BorderY;

GfxWindow->Window = OpenWindowTags(NULL,
										WA_Left,				X,
										WA_Top, 				Y,
										WA_MinWidth, 		MinSizeX,
										WA_MinHeight,		MinSizeY,
										WA_InnerWidth, 	SizeX,
										WA_InnerHeight,	SizeY,
										WA_MaxWidth, 		MaxSizeX,
										WA_MaxHeight,		MaxSizeY,
										WA_Zoom,				GetTagData(GW_Zoom,(ulong)&DefaultZoomRect,TagList),
										WA_IDCMP, 			0,
										WA_Flags, 			WFLG_DRAGBAR|WFLG_DEPTHGADGET|WFLG_CLOSEGADGET|
																		WFLG_SIZEGADGET|WFLG_SIMPLE_REFRESH ,
										WA_Title,			 	GetTagData(GW_Title,(ulong)DefaultTitle,TagList),
										WA_ScreenTitle,	GetTagData(GW_ScreenTitle,(ulong)DefaultScreenTitle,TagList),
										ScreenTag,			GfxView->Screen,
										TAG_DONE);

if ( ! GfxWindow->Window )
	{
	RemoveGfxWindow(GfxView,GfxWindow);
	GfxView->Error = GFXERROR_OPEN_WINDOW;
	return(NULL);
	}

GfxWindow->Window->UserPort = GfxView->IDCMPport;
ModifyIDCMP(GfxWindow->Window,	IDCMP_REFRESHWINDOW |
																IDCMP_RAWKEY |
																IDCMP_MOUSEBUTTONS |
																IDCMP_CLOSEWINDOW |
																IDCMP_CHANGEWINDOW );

GfxWindow->Window->UserData = (APTR) GfxWindow;

GfxWindow->OffX = (GfxWindow->Window->BorderLeft);
GfxWindow->OffY = (GfxWindow->Window->BorderTop);

GfxWindow->SizeX = GfxWindow->Window->Width - GfxWindow->Window->BorderLeft
											- GfxWindow->Window->BorderRight ;
GfxWindow->SizeY = GfxWindow->Window->Height - GfxWindow->Window->BorderTop
											- GfxWindow->Window->BorderBottom ;

GfxWindow->CloseHandler = GetTagData(GW_CloseHandler,0,TagList);

if ( FindTagItem(GW_RetainAspect,TagList) ) GfxWindow->Flags |= GWF_RETAINASPECT;

return(GfxWindow);
}

void RemoveGfxWindow (struct GfxView *GfxView,struct GfxWindow *GfxWindow)
{
struct GfxWindow * Pred;

if ( GfxWindow->CloseHandler )
	{
	GfxWindow->CloseHandler(GfxWindow);
	}

if ( GfxView->GfxWindows == GfxWindow )
	{
	GfxView->GfxWindows = GfxWindow->Next;
	}
else
	{
	Pred = GfxView->GfxWindows;
	while (Pred)
		{
		if ( Pred->Next == GfxWindow )
			{
			Pred->Next = GfxWindow->Next;
			break;
			}
		Pred = Pred->Next;
		}
	}

while ( GfxWindow->GfxObjects )
	{
	RemoveGfxObject(GfxWindow,GfxWindow->GfxObjects);
	}

if (GfxWindow->Window)
	{
	CloseSharedWindow(GfxWindow->Window);
	}

FreeMem(GfxWindow,sizeof(struct GfxWindow));
}

void ModifyGfxWindow
	(struct GfxWindow * GfxWindow,struct TagItem *TagList)
{
short BorderX,BorderY;

/*
WA_Zoom,GetTagData(GW_Zoom,(ulong)&DefaultZoomRect,TagList),
*/

BorderX = (GfxWindow->Window->BorderLeft)+(GfxWindow->Window->BorderRight);
BorderY =	(GfxWindow->Window->BorderTop) +(GfxWindow->Window->BorderBottom);

GfxWindow->KeyHandlers = (struct KeyHandler *) 
	GetTagData(GW_KeyHandlers,0,TagList);

ChangeWindowBox(GfxWindow->Window,
								GetTagData(GW_X,GfxWindow->Window->LeftEdge,TagList),
								GetTagData(GW_Y,GfxWindow->Window->TopEdge,TagList),
								GetTagData(GW_SizeX,(GfxWindow->Window->Width)-BorderX,
										TagList) + BorderX,
								GetTagData(GW_SizeY,(GfxWindow->Window->Height)-BorderY,
										TagList) + BorderY );

WindowLimits(GfxWindow->Window,
							(long)GetTagData(GW_MinSizeX,-BorderX,TagList)+BorderX,
							(long)GetTagData(GW_MinSizeY,-BorderY,TagList)+BorderY,
							(long)GetTagData(GW_MaxSizeX,-BorderX,TagList)+BorderX,
							(long)GetTagData(GW_MaxSizeY,-BorderY,TagList)+BorderY);

if ( FindTagItem(GW_Title,TagList) )
	SetWindowTitles(GfxWindow->Window,(ubyte *)GetTagData(GW_Title,0,TagList),(ubyte *)-1);
if ( FindTagItem(GW_ScreenTitle,TagList) )
	SetWindowTitles(GfxWindow->Window,(ubyte *)-1,(ubyte *)GetTagData(GW_ScreenTitle,0,TagList));

GfxWindow->OffX = (GfxWindow->Window->BorderLeft);
GfxWindow->OffY = (GfxWindow->Window->BorderTop);
GfxWindow->SizeX = GfxWindow->Window->Width  - BorderX;
GfxWindow->SizeY = GfxWindow->Window->Height - BorderY;

if ( FindTagItem(GW_RetainAspect,TagList) ) GfxWindow->Flags |= GWF_RETAINASPECT;

}
