#include <simple/inc.h>
#include <crb/conman.h>

#include "global.h"
#include "gfxactive.h"

short DoObjHandler(struct GfxWindow *GfxWin,uword mX,uword mY)
{
struct GfxObject * GO;

GO = GfxWin->GfxObjects;

mX -= GfxWin->OffX;
mY -= GfxWin->OffY;

while (GO)
	{
	if ( mX > GO->CurX )
		{
		if ( mY > GO->CurY )
			{
			if ( mX < (GO->CurX + GO->CurSizeX) )
				{
				if ( mY < (GO->CurY + GO->CurSizeY) )
					{
					if ( GO->Type == Type_StrGad || GO->Type == Type_Console )
						{
						DeActivateObject(GfxWin->ActiveObject);
						ActivateObject(GO);
						}
					if ( GO->Type == Type_Button && GO->Handler )
						{
						return( GO->Handler(GO) );
						}
					}
				}
			}
		}

	GO = GO->Next;
	}

return(1);
}

short DoKeyHandler(struct GfxWindow *GfxWin,uword MsgQual,uword MsgCode)
{
struct KeyHandler *KH;
struct GfxObject * GO;

KH = GfxWin->KeyHandlers;

while(KH)
	{
	if ( KH->RawKey == MsgCode )
		{
		if ( KH->Qualifier == MsgQual || !(KH->Qualifier) )	
			{
			if ( KH->Handler )
				{
				return ( KH->Handler(GfxWin,KH) );
				}
			}
		}
	KH = KH->Next;
	}

if ( (GO = GfxWin->ActiveObject) )
	{
	if ( GO->Type == Type_Console )
		{

		if ( MsgCode == 68 ) //return
			{
			GetCon((struct ConInfo *)GO->TypeData,(char *)GO->HandlerData);
			HandleCon((struct ConInfo *)GO->TypeData,68,0);
			
			if ( GO->Handler ) return( GO->Handler(GO) );
			else return(1);
			}
		else 
			{
			HandleCon((struct ConInfo *)GO->TypeData,MsgCode,MsgQual);
			return(1);
			}

		}
	else if ( GO->Type == Type_StrGad )
		{

		if ( MsgCode == 68 ) //return
			{
			GetCon((struct ConInfo *)GO->TypeData,(char *)GO->HandlerData);
			HandleCon((struct ConInfo *)GO->TypeData,68,0);
			HandleCon((struct ConInfo *)GO->TypeData,76,0); //up arrow

			DeActivateObject(GO);
			ActivateNextObject(GO);

			if ( GO->Handler ) return( GO->Handler(GO) );
			else return(1);
			}
		else 
			{
			HandleCon((struct ConInfo *)GO->TypeData,MsgCode,MsgQual);
			return(1);
			}

		}

	}

return(1);
}
