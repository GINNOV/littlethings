#include <simple/inc.h>
#include <crb/conman.h>

#include "global.h"
#include "drawlist.h"

extern struct Library * GfxBase;
extern struct Library * IntuitionBase;

short GfxClip (struct GfxWindow *GfxWindow,uword * X,uword * Y)
{
short ret=0;

if ( *X > GfxWindow->SizeX )
	{
	*X = GfxWindow->SizeX;
	ret=1;
	}
if ( *Y > GfxWindow->SizeY )
	{
	*Y = GfxWindow->SizeY;
	ret=1;
	}
return(ret);
}

void DrawBevelBox(struct GfxObject *GfxObject,char *Label)
{
struct RastPort * RP;
uword X,Y,MaxX,MaxY,oMaxX,oMaxY;
short TLpen,BRpen,TXpen;
short DidClip;

TLpen = 2;
TXpen = BRpen = 1;

X = GfxObject->CurX;
Y = GfxObject->CurY;

RP = GfxObject->Parent->Window->RPort;

oMaxX = MaxX = X + GfxObject->CurSizeX;
oMaxY = MaxY = Y + GfxObject->CurSizeY;

DidClip = GfxClip(GfxObject->Parent,&MaxX,&MaxY);

X += GfxObject->Parent->OffX;
Y += GfxObject->Parent->OffY;
MaxX += GfxObject->Parent->OffX;
MaxY += GfxObject->Parent->OffY;
oMaxX += GfxObject->Parent->OffX;
oMaxY += GfxObject->Parent->OffY;

if ( DidClip )
	{
	SetAPen(RP,TLpen);
	Move(RP,X,Y);
	Draw(RP,X,MaxY);
	Draw(RP,X+1,MaxY-1);
	Draw(RP,X+1,Y);
	Draw(RP,MaxX,Y);
	SetAPen(RP,BRpen);

	if ( MaxX == oMaxX )
		{
		Move(RP,MaxX,Y);
		Draw(RP,MaxX,MaxY);
		Draw(RP,MaxX-1,MaxY);
		Draw(RP,MaxX-1,Y+1);
		}
	if ( MaxY == oMaxY )
		{
		Move(RP,X,MaxY);
		Draw(RP,MaxX,MaxY);
		}
	}
else
	{
	SetAPen(RP,TLpen);
	Move(RP,X,Y);
	Draw(RP,X,MaxY);
	Draw(RP,X+1,MaxY-1);
	Draw(RP,X+1,Y);
	Draw(RP,MaxX,Y);
	SetAPen(RP,BRpen);
	Draw(RP,MaxX,MaxY);
	Draw(RP,X,MaxY);
	Move(RP,MaxX-1,Y+1);
	Draw(RP,MaxX-1,MaxY);

	if ( GfxObject->TypeData )
		{
		X += GfxObject->SizeX / 2;
		X -= TextLength(RP,(char *)(GfxObject->TypeData),
			strlen((char *)GfxObject->TypeData)) / 2;
		Y += GfxObject->SizeY / 2;
		Y += RP->TxHeight / 2;
		Move(RP,X,Y);

		SetAPen(RP,TXpen);
		Text(RP,(char *)(GfxObject->TypeData),
			strlen((char *)GfxObject->TypeData));
		}
	}

}

void RefreshGfxObject(struct GfxObject *GfxObject)
{
uword X,Y;

if ( GfxObject->PosFlags & PosFlag_X_Factor )
	GfxObject->CurX = (GfxObject->X * GfxObject->Parent->SizeX) / GFX_VIRTBOX_SIZE;
else
	GfxObject->CurX = GfxObject->X;
if ( GfxObject->PosFlags & PosFlag_Y_Factor )
	GfxObject->CurY = (GfxObject->Y * GfxObject->Parent->SizeY) / GFX_VIRTBOX_SIZE;
else
	GfxObject->CurY = GfxObject->Y;
if ( GfxObject->PosFlags & PosFlag_X_Right )
	GfxObject->CurX = (GfxObject->Parent->SizeX - GfxObject->CurX);
if ( GfxObject->PosFlags & PosFlag_Y_Bottom )
	GfxObject->CurY = (GfxObject->Parent->SizeY - GfxObject->CurY);

if ( GfxObject->PosFlags & PosFlag_SizeX_Factor )
	GfxObject->CurSizeX = (GfxObject->SizeX * GfxObject->Parent->SizeX) / GFX_VIRTBOX_SIZE;
else
	GfxObject->CurSizeX = GfxObject->SizeX;
if ( GfxObject->PosFlags & PosFlag_SizeY_Factor )
	GfxObject->CurSizeY = (GfxObject->SizeY * GfxObject->Parent->SizeY) / GFX_VIRTBOX_SIZE;
else
	GfxObject->CurSizeY = GfxObject->SizeY;
if ( GfxObject->PosFlags & PosFlag_SizeX_Right )
	GfxObject->CurSizeX = (GfxObject->Parent->SizeX 
													- GfxObject->CurX - GfxObject->CurSizeX);
if ( GfxObject->PosFlags & PosFlag_SizeY_Bottom )
	GfxObject->CurSizeY = (GfxObject->Parent->SizeY
													- GfxObject->CurY - GfxObject->CurSizeY);

X = GfxObject->CurX;
Y = GfxObject->CurY;
if ( GfxClip(GfxObject->Parent,&X,&Y) ) return;

if ( GfxObject->CurSizeX == -1 )
	GfxObject->CurSizeX = GfxObject->Parent->SizeX - GfxObject->CurX - 1;
if ( GfxObject->CurSizeY == -1 )
	GfxObject->CurSizeY = GfxObject->Parent->SizeY - GfxObject->CurY - 1;


switch (GfxObject->Type)
	{
	case Type_DrawList:
		RenderDrawList(GfxObject);
		break;
	case Type_Button:
		DrawBevelBox(GfxObject,(char *)GfxObject->TypeData);
		break;
	case Type_StrGad:
		GfxObject->CurSizeY = (GfxObject->Parent->Window->RPort->TxHeight + 2);
	case Type_Console:
		ModifyCon((struct ConInfo *)GfxObject->TypeData,
			CON_MinX , (GfxObject->CurX)+(GfxObject->Parent->OffX),
			CON_MinY , (GfxObject->CurY)+(GfxObject->Parent->OffY),
			CON_MaxX , (GfxObject->CurX)+(GfxObject->Parent->OffX)+(GfxObject->CurSizeX),
			CON_MaxY , (GfxObject->CurY)+(GfxObject->Parent->OffY)+(GfxObject->CurSizeY),
			TAG_DONE);
		RedrawCon ((struct ConInfo *)GfxObject->TypeData);
		break;
	}
}

void RefreshGfxWindow(struct GfxWindow * GfxWindow)
{
struct GfxObject * GfxObject;

GfxWindow->SizeX = GfxWindow->Window->Width - GfxWindow->Window->BorderLeft
											- GfxWindow->Window->BorderRight - 1;
GfxWindow->SizeY = GfxWindow->Window->Height - GfxWindow->Window->BorderTop
											- GfxWindow->Window->BorderBottom - 1;

if ( GfxWindow->Flags & GWF_FAKEOUTLAYERS )
	{
	BeginRefresh(GfxWindow->Window);
	EndRefresh(GfxWindow->Window,TRUE);
	}

if ( GfxWindow->Flags & GWF_USELAYERS ) 
	{
	BeginRefresh(GfxWindow->Window);
	}
else
	{
	EraseRect(GfxWindow->Window->RPort,GfxWindow->OffX,GfxWindow->OffY,
							GfxWindow->OffX+GfxWindow->SizeX,GfxWindow->OffY+GfxWindow->SizeY);
	}

GfxObject = GfxWindow->GfxObjects;
while (GfxObject)
	{
	RefreshGfxObject(GfxObject);
	GfxObject = GfxObject->Next;
	}

if ( GfxWindow->Flags & GWF_USELAYERS ) 
	{
	EndRefresh(GfxWindow->Window,TRUE);
	}

GfxWindow->Flags &= ( GWF_FAKEOUTLAYERS ^ 0xFFFFFFFF);
GfxWindow->Flags &= ( GWF_USELAYERS ^ 0xFFFFFFFF);
}

void RetainAspect(struct GfxWindow *GfxWindow)
{
uword NewSizeX,NewSizeY,OldSizeX,OldSizeY,MaxX,MaxY,ShiftedNewSizeX,BorderX,BorderY;
uword NewX,NewY;

BorderX = (GfxWindow->Window->BorderLeft)+(GfxWindow->Window->BorderRight) + 1;
BorderY =	(GfxWindow->Window->BorderTop) +(GfxWindow->Window->BorderBottom) + 1;
NewSizeX = GfxWindow->Window->Width - BorderX;
NewSizeY = GfxWindow->Window->Height - BorderY;
OldSizeX = GfxWindow->SizeX;
OldSizeY = GfxWindow->SizeY;
MaxX = GfxWindow->Parent->ScreenSizeX;
MaxY = GfxWindow->Parent->ScreenSizeY;
NewX = GfxWindow->Window->LeftEdge;
NewY = GfxWindow->Window->TopEdge;

ShiftedNewSizeX = (NewSizeY * OldSizeX) / OldSizeY;

if ( (ShiftedNewSizeX + BorderX) < MaxX )
	{
	if ( (ShiftedNewSizeX + BorderX + NewX) > MaxX ) NewX = 0;

	ChangeWindowBox(GfxWindow->Window,NewX,NewY,
		ShiftedNewSizeX+BorderX,NewSizeY+BorderY);
	}
else
	{
	NewSizeY = ( NewSizeX * OldSizeY ) / OldSizeX;

	if ( (NewSizeY + BorderY + NewY) > MaxY ) NewY = 0;

	ChangeWindowBox(GfxWindow->Window,NewX,NewY,
		NewSizeX+BorderX,NewSizeY+BorderY);
	}

RefreshGfxWindow(GfxWindow);
GfxWindow->Flags |= GWF_JUSTDIDRETAINASPECT;
}
