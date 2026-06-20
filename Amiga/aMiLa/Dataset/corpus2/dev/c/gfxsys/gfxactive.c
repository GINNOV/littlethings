#include <simple/inc.h>

#include <crb/conman.h>

#include "global.h"

void DeActivateObject(struct GfxObject * GO)
{

if ( ! GO ) return;

GO->Parent->ActiveObject = NULL;

if ( GO->Type == Type_Console || GO->Type == Type_StrGad )
	{
	ClearConCursor((struct ConInfo *)GO->TypeData);
	}
}

void ActivateObject(struct GfxObject * GO)
{

if ( ! GO ) return;

GO->Parent->ActiveObject = GO;

if ( GO->Type == Type_Console || GO->Type == Type_StrGad )
	{
	ShowConCursor((struct ConInfo *)GO->TypeData);
	}
}

void ActivateNextObject(struct GfxObject * GO)
{
struct GfxObject * StartGO;

StartGO = GO;

GO = StartGO->Next;

while ( GO != StartGO )
	{
	if ( GO == NULL ) GO = StartGO->Parent->GfxObjects;
 	else
		{
		if ( GO->Type == Type_Console || GO->Type == Type_StrGad )
			{
			ActivateObject(GO);
			return;
			}
		GO = GO->Next;	
		}
	}

}

void ActivateWindows(struct GfxView * GfxView)
{
struct GfxWindow * GW;

GW = GfxView->GfxWindows;

while(GW)
	{
	if ( GW->GfxObjects )	ActivateNextObject(GW->GfxObjects);

	GW = GW->Next;
	}
}
