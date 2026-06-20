
/*********

Defines

*********/

#define GFX_VIRTBOX_SIZE (long)(10000)

// GfxPoint->Commands:
#define GPC_DONE				0
#define GPC_MOVETO			1
#define GPC_LINETO			2
#define GPC_FLOODFILL		3
#define GPC_SETCOLOR		4	//X is the FG color, Y is the BG color	
#define GPC_TEXT				5 //X & Y combined to a ulong contain a pointer to a str

#define GPC_ARCTO				6
#define GPC_ARCXTRA 		7 //ArcTo needs more variables, this always follows it
#define GPC_ARCCOMPILED1	6 //centerX & Y
#define GPC_ARCCOMPILED2	7 //radiusX & Y
#define GPC_ARCCOMPILED3	8 //StartX & StopX

//GfxObject->Type
#define Type_DrawList	1
#define Type_Button		2
#define Type_Console	3
#define Type_StrGad		4

//GfxObject->PosFlag
#define PosFlag_X_Right				(1<<0)
#define PosFlag_Y_Bottom			(1<<1)
#define PosFlag_X_Factor  		(1<<2)
#define PosFlag_Y_Factor  		(1<<3)
#define PosFlag_SizeX_Factor	(1<<4)
#define PosFlag_SizeY_Factor	(1<<5)
#define PosFlag_SizeX_Right  	(1<<6) 
	//the size is a coordinate postion from the right side
#define PosFlag_SizeY_Bottom	(1<<7)

// GfxView->ScreenType
#define GVST_CUSTOM 1
#define GVST_PUBLIC 2

//GfxWindow->Flags
#define GWF_USELAYERS								(1<<0)
#define GWF_FAKEOUTLAYERS						(1<<1)
#define GWF_IGNORENEXTCHANGEWINDOW	(1<<2)
#define GWF_IGNORENEXTREFRESHWINDOW (1<<3)
#define GWF_JUSTDIDRETAINASPECT			(1<<4)
#define GWF_SYSTEMMASK		0x000000FF //first 8 bits are system flags

#define GWF_RETAINASPECT	(1<<8)
#define GWF_USERMASK			0xFFFFFF00 

/*********

structs

*********/

struct GfxPoint
	{
	ubyte Command;
	uword X,Y; //virtual coords
	};

struct GfxWindow
	{
	struct GfxWindow *Next;
	struct GfxView *Parent;

	struct KeyHandler * KeyHandlers;
	
	struct GfxObject * GfxObjects;
	uword SizeX,SizeY; //current size

	struct Window * Window;
	uword OffX,OffY; //offset GfxObject coords by this before drawing to Window

	ulong Flags;

	short (*CloseHandler) (struct GfxWindow *);

	struct GfxObject * ActiveObject;
	};

struct GfxObject
	{
	struct GfxObject *Next;
	struct GfxWindow *Parent;

	uword Type;
	uword PosFlags;
	uword X,Y;
	uword SizeX,SizeY;
	
	uword CurX,CurY;
	uword CurSizeX,CurSizeY;

	short (*Handler) (struct GfxObject *); //return 0 for error
	ulong HandlerData; //data for the handler to look at
	ulong UserData;
	ulong TypeData; //read-only data
	};

struct KeyHandler
	{
	struct KeyHandler *Next;
	uword RawKey;
	uword Qualifier; //0 for any
	short (*Handler) (struct GfxWindow *,struct KeyHandler *); //ret 0 for err
	ulong HandlerData;	
	};

struct GfxView
	{
	struct GfxWindow * GfxWindows;
	struct MsgPort * IDCMPport;

	struct Screen * Screen;
	uword ScreenType;	uword Pad;
	uword ScreenSizeX,ScreenSizeY;

	ulong Error;
		//if this is not 0 it is an error code
		//it must be checked after every call

	//menus
	};

/*******

TAGS

*******/

//for AddGfxWindow:
#define GW_KeyHandlers	(TAG_USER+1)
#define GW_X						(TAG_USER+2)
#define GW_Y						(TAG_USER+3)
#define GW_SizeX				(TAG_USER+4)
#define GW_SizeY				(TAG_USER+5)
#define GW_Zoom					(TAG_USER+6)
#define GW_Title				(TAG_USER+7)
#define GW_ScreenTitle	(TAG_USER+8)
#define GW_MinSizeX			(TAG_USER+9)
#define GW_MinSizeY			(TAG_USER+10)
#define GW_MaxSizeX			(TAG_USER+11)
#define GW_MaxSizeY			(TAG_USER+12)
#define GW_CloseHandler (TAG_USER+13)
#define GW_RetainAspect (TAG_USER+14)

// for CreateGfxView:
// select one of these 3 to indicate which type of screen:
#define GV_CustomScreen (TAG_USER+1)
#define GV_PubScreen 		(TAG_USER+2)
#define GV_AskScreen 		(TAG_USER+3)

//for AddGfxObject:
#define GO_Type						(TAG_USER+1)
#define GO_X							(TAG_USER+2)
#define GO_Y							(TAG_USER+3)
#define GO_SizeX					(TAG_USER+4)
#define GO_SizeY					(TAG_USER+5)
#define GO_PosFlags				(TAG_USER+6)
#define GO_UserData				(TAG_USER+7)
	
#define GO_ObjectHandler	(TAG_USER+8)
#define GO_ButtonHandler	(TAG_USER+8)
#define GO_ConsoleHandler	(TAG_USER+8)
#define GO_StrGadHandler	(TAG_USER+8)

#define GO_TypeData				(TAG_USER+9)
#define GO_DrawList				(TAG_USER+9)
#define GO_ButtonLabel    (TAG_USER+9)
