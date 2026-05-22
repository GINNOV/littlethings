#include <simple/inc.h>
#include <simple/utility.h>
#include <crb/conman.h>

#include "global.h"
#include "gfxutil.h"
#include "drawlist.h"
#include "refresh.h"
#include "gfxerrors.h"

extern struct Library * IntuitionBase;
extern struct Library * UtilityBase;

//internal protos:
void RemoveGfxObject(struct GfxWindow *GfxWindow,
										 struct GfxObject *GfxObject);

struct GfxObject * AddGfxObject(struct GfxWindow *GfxWindow,
																struct TagItem *TagList)
{
struct GfxObject * GfxObject;

if ( (GfxObject = AllocMem(sizeof(struct GfxObject),MEMF_CLEAR)) == NULL )
	{
	GfxWindow->Parent->Error = GFXERROR_ALLOC;
	return(NULL);
	}

GfxObject->Parent = GfxWindow;
GfxObject->Next = GfxWindow->GfxObjects;
GfxWindow->GfxObjects = GfxObject;

GfxObject->X = GetTagData(GO_X,0,TagList);
GfxObject->Y = GetTagData(GO_Y,0,TagList);
GfxObject->SizeX = GetTagData(GO_SizeX,50,TagList);
GfxObject->SizeY = GetTagData(GO_SizeY,20,TagList);
GfxObject->PosFlags = GetTagData(GO_PosFlags,0,TagList);
GfxObject->UserData = GetTagData(GO_UserData,0,TagList);

switch ( GfxObject->Type = GetTagData(GO_Type,0,TagList) )
	{
	case Type_DrawList:
		GfxObject->TypeData = GetTagData(GO_DrawList,0,TagList);
		InitDrawList((struct GfxPoint *)(GfxObject->TypeData));
		break;
	case Type_Button:
		GfxObject->Handler 	= GetTagData(GO_ObjectHandler,0,TagList);
		if ( FindTagItem(GO_ButtonLabel,TagList) )
			{
			if ( (GfxObject->TypeData = (ulong)AllocMem(STRINGLEN,MEMF_ANY)) == NULL)
				{
				RemoveGfxObject(GfxWindow,GfxObject);
				GfxWindow->Parent->Error = GFXERROR_ALLOC;
				return(NULL);
				}
			strcpy(	(char *)GfxObject->TypeData,
							(char *)GetTagData(GO_ButtonLabel,0,TagList) );
			}
		break;
	case Type_StrGad:
	case Type_Console:
		GfxObject->HandlerData = (ulong)AllocMem(STRINGLEN,MEMF_ANY);
		GfxObject->Handler = GetTagData(GO_ObjectHandler,0,TagList);
		GfxObject->TypeData = (ulong) InitCon(GfxWindow->Window,
															CON_BufLen,STRINGLEN,TAG_DONE);
		if ( !(GfxObject->TypeData) || !(GfxObject->HandlerData) ) 
			{
			RemoveGfxObject(GfxWindow,GfxObject);
			GfxWindow->Parent->Error = GFXERROR_OPEN_CONSOLE;
			return(NULL);
			}
		break;
	default:
		break;
	}

RefreshGfxObject(GfxObject);

return(GfxObject);
}

void RemoveGfxObject(struct GfxWindow *GfxWindow,
										 struct GfxObject *GfxObject)
{
struct GfxObject * Pred;

if ( GfxWindow->GfxObjects == GfxObject )
	{
	GfxWindow->GfxObjects = GfxObject->Next;
	}
else
	{
	Pred = GfxWindow->GfxObjects;
	while (Pred)
		{
		if ( Pred->Next == GfxObject )
			{
			Pred->Next = GfxObject->Next;
			break;
			}
		Pred = Pred->Next;
		}
	}

switch (GfxObject->Type)
	{
	case Type_DrawList:
		break;
	case Type_Button:
		if ( GfxObject->TypeData ) FreeMem((void *)GfxObject->TypeData,STRINGLEN);
		break;
	case Type_StrGad:
	case Type_Console:
		if ( GfxObject->HandlerData ) FreeMem((void *)GfxObject->HandlerData,STRINGLEN);
		if ( GfxObject->TypeData ) CloseCon((struct ConInfo *)GfxObject->TypeData);
		break;
	}

FreeMem(GfxObject,sizeof(struct GfxObject));
}

void ModifyGfxObject(struct GfxObject *GfxObject,struct TagItem *TagList)
{

GfxObject->X = GetTagData(GO_X,GfxObject->X,TagList);
GfxObject->Y = GetTagData(GO_Y,GfxObject->Y,TagList);
GfxObject->SizeX = GetTagData(GO_SizeX,GfxObject->SizeX,TagList);
GfxObject->SizeY = GetTagData(GO_SizeY,GfxObject->SizeY,TagList);
GfxObject->PosFlags = GetTagData(GO_PosFlags,GfxObject->PosFlags,TagList);
GfxObject->UserData = GetTagData(GO_UserData,GfxObject->UserData,TagList);

switch ( GfxObject->Type )
	{
	case Type_DrawList:
		if ( FindTagItem(GO_DrawList,TagList) )
			{
			GfxObject->TypeData = GetTagData(GO_DrawList,0,TagList);
			InitDrawList((struct GfxPoint *)(GfxObject->TypeData));
			}
		break;
	case Type_Button:
		GfxObject->Handler = GetTagData(GO_ObjectHandler,(ulong)GfxObject->Handler,TagList);
		strcpy(	(char *)GfxObject->TypeData,
						(char *)GetTagData(GO_ButtonLabel,GfxObject->TypeData,TagList) );
		break;
	case Type_StrGad:
	case Type_Console:
		GfxObject->Handler = GetTagData(GO_ObjectHandler,(ulong)GfxObject->Handler,TagList);
		// GfxObject->HandlerData is the input string
		break;
	default:
		break;
	}

RefreshGfxObject(GfxObject);

return;
}
