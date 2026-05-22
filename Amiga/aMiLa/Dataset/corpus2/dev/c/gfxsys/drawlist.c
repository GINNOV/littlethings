#include <simple/inc.h>

#include "global.h"
#include "refresh.h"

extern struct Library * GfxBase;

void Arc ( struct RastPort * RP,
	uword CenterX,uword CenterY,
	uword RadiusX,uword RadiusY,
	uword StartX ,uword StopX )
{
/*
		Do Arc
*/
}

void RenderDrawList(struct GfxObject * GfxObject)
{
struct RastPort * RP;
char * Str;
register uword X,Y,OffX,OffY,SizeX,SizeY,VBSize;
register struct GfxPoint * DrawList;
uword ArcCenterX,ArcCenterY,ArcRadiusX,ArcRadiusY;

ArcCenterX = GfxObject->CurX + GfxObject->CurSizeX;
ArcCenterY = GfxObject->CurY + GfxObject->CurSizeY;
if ( GfxClip(GfxObject->Parent,&ArcCenterX,&ArcCenterY) ) return;

VBSize = GFX_VIRTBOX_SIZE;

OffX = GfxObject->Parent->OffX + GfxObject->CurX;
OffY = GfxObject->Parent->OffY + GfxObject->CurY;
SizeX = GfxObject->CurSizeX;
SizeY = GfxObject->CurSizeY;

RP = GfxObject->Parent->Window->RPort;

DrawList = (struct GfxPoint *)GfxObject->TypeData;

SetDrMd(RP,JAM1);
SetAPen(RP,1);

while ( DrawList->Command != GPC_DONE )
	{
	X = DrawList->X * SizeX / VBSize;
	Y = DrawList->Y * SizeY / VBSize;
	switch ( DrawList->Command )
		{
		case GPC_DONE:
			break;
		case GPC_MOVETO:
			Move(RP,OffX+X,OffY+Y);
			break;
		case GPC_LINETO:
			Draw(RP,OffX+X,OffY+Y);
			break;
		case GPC_FLOODFILL:
			Flood(RP,1,OffX+X,OffY+Y);
			break;
		case GPC_SETCOLOR:
			SetAPen(RP,DrawList->X);
			SetBPen(RP,DrawList->Y);
			break;
		case GPC_TEXT:
			Str = (char *) ( (ulong)DrawList->X << 16 | (ulong)DrawList->Y );
			Text(RP,Str,strlen(Str));
			break;
		case GPC_ARCCOMPILED1:
			ArcCenterX = X;
			ArcCenterY = Y;
			break;
		case GPC_ARCCOMPILED2:
			ArcRadiusX = X;
			ArcRadiusY = Y;
			break;
		case GPC_ARCCOMPILED3:
			Arc(RP,ArcCenterX,ArcCenterY,ArcRadiusX,ArcRadiusY,X,Y);
			break;
		}
	DrawList++;
	};
}

void InitDrawList(struct GfxPoint *DrawList)
{
/*
		convert 3-point arcs to compiled arcs of form
		Y =  ( b - a * (x-x0)^2 ) ^ .5 + y0
*/
}
