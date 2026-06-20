#include <simple/inc.h>

#include "gfxsys.h"

char __stdiowin[]="CON:0/10/640/190/GfxSys_Report";
char __stdiov37[]="";

struct Library * IntuitionBase;
struct Library * UtilityBase;
struct Library * ReqToolsBase;
struct Library * GfxBase;     

// internal protos : 
short ButtonHandler (struct GfxObject *);
short NewButtonHandler (struct GfxObject *);
short ConsoleHandler (struct GfxObject *GfxObj);

struct GfxPoint DrawList[] =
	{
	{ GPC_MOVETO, 5000, 1000 },
	{ GPC_LINETO, 9000, 9000 },
	{ GPC_LINETO, 1000, 9000 },
	{ GPC_LINETO, 5000, 1000 },
	{ GPC_DONE  ,    0,    0 }
	};

struct TagItem NewScreenTags[] =
	{
	{	SA_Width, 640	},
	{	SA_Height,400	},
	{ SA_Depth, 2 },
	{	SA_Title,	(ulong) "The Screen From Hell" },
	{	SA_DisplayID, NTSC_MONITOR_ID|HIRESLACE_KEY },
	{	SA_SysFont,	0	},
	{	SA_FullPalette, TRUE	},
	{	SA_Type,			CUSTOMSCREEN	},
	{	TAG_DONE , 0	}
	};

void main(void)
{
struct GfxView * GfxView;

IntuitionBase = OpenLibrary("intuition.library",0);
GfxBase = OpenLibrary("graphics.library",0);
ReqToolsBase = OpenLibrary("reqtools.library",0);
UtilityBase = OpenLibrary("utility.library",0);

if ( ! (GfxView = CreateGfxViewTags(GV_CustomScreen,NewScreenTags,TAG_DONE)) )
	goto Main_Done;

if ( GfxView->Error )
	{
	printf("Error: %d\n",GfxView->Error);
	CloseGfxView(GfxView);
	goto Main_Done;	
	}

AddGfxWindowTags ( GfxView,
						GW_X, 150,
						GW_Y, 10,
						GW_SizeX, 300,
						GW_SizeY, 300,
						GW_MaxSizeX, -1,
						GW_MaxSizeY, -1,
						GW_Title,"Chuk's Console",
						TAG_DONE );

AddGfxObjectTags( GfxView->GfxWindows,
									GW_SizeX, -1,
									GW_SizeY, -1,
									GO_Type,Type_Console,
									GO_ConsoleHandler,ConsoleHandler,
									TAG_DONE);

AddGfxWindowTags ( GfxView,
						GW_X, 10,
						GW_Y, 10,
						GW_SizeX, 600,
						GW_SizeY, 300,
						GW_MinSizeX, 150,
						GW_MinSizeY, 100,
						GW_MaxSizeX, -1,
						GW_MaxSizeY, -1,
						GW_Title,"Chuk's GfxWindow",
						GW_RetainAspect,1,
						TAG_DONE );

if ( GfxView->Error )
	{
	printf("Error: %d\n",GfxView->Error);
	CloseGfxView(GfxView);
	goto Main_Done;	
	}

AddGfxObjectTags( GfxView->GfxWindows,
									GO_SizeX, 100,
									GO_SizeY, 20,
									GO_Type,Type_Button,
									GO_ButtonLabel,"Add Window",
									GO_ButtonHandler,ButtonHandler,
									TAG_DONE);

AddGfxObjectTags( GfxView->GfxWindows,
									GO_X, 		10,
									GO_Y, 		25,
									GO_SizeX, 10,
									GO_SizeY, 10,
									GO_PosFlags, (PosFlag_SizeX_Right|PosFlag_SizeY_Bottom),
									GO_Type,	Type_DrawList,
									GO_DrawList, (ulong)DrawList,
									TAG_DONE);

AddGfxObjectTags( GfxView->GfxWindows,
									GO_X, 		110,
									GO_Y, 		20,
									GO_PosFlags, (PosFlag_SizeX_Right),
									GW_SizeX,  5,
									GW_SizeY,  0,
									GO_Type,Type_StrGad,
									GO_StrGadHandler,ConsoleHandler,
									TAG_DONE);
AddGfxObjectTags( GfxView->GfxWindows,
									GO_X, 		106,
									GO_Y, 		16,
									GO_PosFlags, (PosFlag_SizeX_Right),
									GW_SizeX,  1,
									GW_SizeY, 16,
									GO_Type,Type_Button,
									TAG_DONE);

if ( GfxView->Error )
	{
	printf("Error: %d\n",GfxView->Error);
	CloseGfxView(GfxView);
	goto Main_Done;	
	}

MainLoop(GfxView);

Main_Done:

CloseLibrary(IntuitionBase);
CloseLibrary(UtilityBase);
CloseLibrary(ReqToolsBase);
CloseLibrary(GfxBase);
}

const char * StdTitle = "Chuk's Sub-GfxWindow";
const char * AltTitle = "Alternate Title";

short ButtonHandler (struct GfxObject *GfxObj)
{
struct GfxView * GfxView;
struct GfxWindow * NewWindow;

GfxView = GfxObj->Parent->Parent;

NewWindow = AddGfxWindowTags ( GfxView,
						GW_X, 10,
						GW_Y, 10,
						GW_SizeX, 200,
						GW_SizeY, 40,
						GW_Title,(ulong)StdTitle,
						TAG_DONE );

if ( ! NewWindow ) return(0);

if ( AddGfxObjectTags(NewWindow,
									GO_SizeX, 100,
									GO_Type,Type_Button,
									GO_ButtonLabel,"Swap Title",
									GO_ButtonHandler,NewButtonHandler,
									TAG_DONE) ) return(1);

return(0);
}

short NewButtonHandler (struct GfxObject *GfxObj)
{
struct GfxWindow * GfxWindow;

GfxWindow = GfxObj->Parent;

if ( GfxWindow->Window->Title == (ubyte *)StdTitle )
	ModifyGfxWindowTags(GfxWindow,GW_Title,(ulong)AltTitle,TAG_DONE);
else
	ModifyGfxWindowTags(GfxWindow,GW_Title,(ulong)StdTitle,TAG_DONE);
	
return(1);
}

short ConsoleHandler (struct GfxObject *GfxObj)
{

puts ( (char *)GfxObj->HandlerData );

return(1);
}
