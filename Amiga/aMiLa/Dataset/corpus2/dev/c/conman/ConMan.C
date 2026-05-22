#include <simple/inc.h>
#include <simple/utility.h>
#include <simple/intuition.h>

#include "raw2vanilla.h"

extern struct Library * GfxBase;
extern struct Library * UtilityBase;

#define DEFNUMLINES			256
#define DEFBUFLEN				256
#define DEFAPEN					1
#define DEFBPEN					0
#define DEFDRMD					JAM1
#define DEFCURSORCOLOR	3

struct ConInfo
	{
	struct RastPort * RP;
	ulong Flags;
	ubyte APen,BPen,DrMd;
	ubyte TxHeight,TxUp;
	ubyte CursorColor,CursorStatus;
	ubyte Pad;
	uword MinX,MinY,MaxX,MaxY;

	uword NumLines;
	uword BufLen;
	char ** Buffer;
	uword * StrLens;

	uword CurLines;
	uword CurRefLine; //for up-arrow referencing

	uword CurCharPos;
	};

//Flags:
#define CIF_LINECURSOR (1<<0)

//Tags:															<read from>
#define CON_APen				(TAG_USER+1) //RP
#define CON_BPen				(TAG_USER+2) //RP
#define CON_DrMd				(TAG_USER+3) //RP
#define CON_TxHeight		(TAG_USER+4) //RP
#define CON_TxUp				(TAG_USER+5) //RP
#define CON_CursorColor	(TAG_USER+6)
#define CON_CursorType	(TAG_USER+7)
#define CON_MinX				(TAG_USER+8) //Win
#define CON_MinY				(TAG_USER+9) //Win
#define CON_MaxX				(TAG_USER+10)//Win
#define CON_MaxY				(TAG_USER+11)//Win

//for InitCon only
#define CON_NumLines		(TAG_USER+20)
#define CON_BufLen			(TAG_USER+21)

//for ModifyCon only
#define CON_ReadWin			(TAG_USER+30)
#define CON_ReadRP			(TAG_USER+31)


void __regargs CloseCon (struct ConInfo * ConInfo)
{
register int i;

if ( ConInfo->StrLens ) FreeMem(ConInfo->StrLens,(ConInfo->NumLines)*sizeof(uword));

if ( ConInfo->Buffer )
	{
	for (i=0;i<(ConInfo->NumLines);i++)
		{
		if ( ConInfo->Buffer[i] ) FreeMem(ConInfo->Buffer[i],(ConInfo->BufLen));
		}
	FreeMem(ConInfo->Buffer,(ConInfo->NumLines)*sizeof(char *));
	}

FreeMem(ConInfo,sizeof(struct ConInfo));
}

void __regargs RedrawConBottom(struct ConInfo * ConInfo,short DoCursor)
{
register struct RastPort * RP;
register short X,Y;
short StrLen;

RP = ConInfo->RP;

SetDrMd(RP,ConInfo->DrMd);
SetAPen(RP,ConInfo->APen);
SetBPen(RP,ConInfo->BPen);

Y = ConInfo->MinY + (ConInfo->CurLines)*(ConInfo->TxHeight) + 1;
if ( Y >= (ConInfo->MaxY) ) Y = ConInfo->MaxY - 1;

EraseRect(RP , ConInfo->MinX , Y - ConInfo->TxHeight ,
	ConInfo->MaxX , Y );

Move(RP,ConInfo->MinX,Y - ConInfo->TxUp);

StrLen = ConInfo->StrLens[0];
while ( TextLength(RP,ConInfo->Buffer[0],StrLen) > (ConInfo->MaxX - ConInfo->MinX) && StrLen )
	StrLen--;
 
Text(RP,ConInfo->Buffer[0],StrLen);

if ( DoCursor )
	{
	short XSize;

	X = TextLength(RP,ConInfo->Buffer[0],ConInfo->CurCharPos) + ConInfo->MinX;
	SetAPen (RP,ConInfo->CursorColor);

	if ( ConInfo->Flags & CIF_LINECURSOR )
		{
		XSize = 2;
		}
	else
		{	
		SetDrMd(RP,COMPLEMENT);
		if ( ConInfo->Buffer[0][ConInfo->CurCharPos] == 0 )
			XSize = TextLength(RP,"X",1);
		else
			XSize = TextLength(RP,&(ConInfo->Buffer[0][ConInfo->CurCharPos]),1);

		if ( XSize < 2 )
			XSize = 2;
		}

	RectFill(RP,X,Y-ConInfo->TxHeight,X+XSize,Y);
	}
}

void __regargs AdvanceCon(struct ConInfo * ConInfo)
{
register short i;
char * NewBottom;

RedrawConBottom(ConInfo,0);

if ( (ConInfo->MinY + (ConInfo->CurLines)*(ConInfo->TxHeight) + 1) > (ConInfo->MaxY) )
	{
	ScrollRaster (ConInfo->RP,0,ConInfo->TxHeight,
		ConInfo->MinX,ConInfo->MinY,ConInfo->MaxX,ConInfo->MaxY);
	}

NewBottom = ConInfo->Buffer[(ConInfo->NumLines - 1)];
for (i=(ConInfo->NumLines - 1);i>0;i--)
	{
	ConInfo->Buffer[i] = ConInfo->Buffer[i-1];
	}
ConInfo->Buffer[0] = NewBottom;
ConInfo->Buffer[0][0] = 0;

for (i=(ConInfo->NumLines - 1);i>0;i--)
	{
	ConInfo->StrLens[i] = ConInfo->StrLens[i-1];
	}
ConInfo->StrLens[0] = 0;

if ( ConInfo->CurLines < ConInfo->NumLines ) ConInfo->CurLines++;
ConInfo->CurCharPos = 0;

RedrawConBottom(ConInfo,ConInfo->CursorStatus);

ConInfo->CurRefLine = 0;
}

void __regargs RedrawCon (struct ConInfo * ConInfo)
{
register struct RastPort * RP;
register short Y,i,StrLen;
short MinY;
char * Str;

RP = ConInfo->RP;

SetDrMd(RP,ConInfo->DrMd);
SetAPen(RP,ConInfo->APen);
SetBPen(RP,ConInfo->BPen);

EraseRect(RP,ConInfo->MinX,ConInfo->MinY,ConInfo->MaxX,ConInfo->MaxY);

Y = ConInfo->MinY + (ConInfo->CurLines)*(ConInfo->TxHeight) + 1;
if ( Y >= (ConInfo->MaxY) ) Y = ConInfo->MaxY - 1;
i = 0;
MinY = ConInfo->MinY + ConInfo->TxHeight;

while ( Y > MinY && ConInfo->Buffer[i] )
	{
	Str = ConInfo->Buffer[i];
	Move(RP,ConInfo->MinX,Y - ConInfo->TxUp);

	// ** Do Str wrapping

	StrLen = ConInfo->StrLens[i];
	while ( TextLength(RP,Str,StrLen) > (ConInfo->MaxX - ConInfo->MinX) && StrLen )
		StrLen--;
 	Text (RP,Str,StrLen);

	Y -= ConInfo->TxHeight;
	i++;
	}

RedrawConBottom(ConInfo,ConInfo->CursorStatus);
}

__regargs struct ConInfo * InitConA (struct Window * Win,struct TagItem * TagList)
{
register struct ConInfo * ConInfo;
struct RastPort * RP;
short i;

if ( (ConInfo = AllocMem(sizeof(struct ConInfo),MEMF_CLEAR)) == NULL )
	return(NULL);

ConInfo->NumLines = GetTagData(CON_NumLines,DEFNUMLINES,TagList);
ConInfo->BufLen   = GetTagData(CON_BufLen  ,DEFBUFLEN  ,TagList);

if ( (ConInfo->StrLens = AllocMem((ConInfo->NumLines)*sizeof(uword),MEMF_CLEAR)) == NULL )
	{
	CloseCon(ConInfo);
	return(NULL);
	}
if ( (ConInfo->Buffer = AllocMem((ConInfo->NumLines)*sizeof(char *),MEMF_ANY)) == NULL )
	{
	CloseCon(ConInfo);
	return(NULL);
	}

for (i=0;i<(ConInfo->NumLines);i++)
	{
	if ( (ConInfo->Buffer[i] = AllocMem((ConInfo->BufLen),MEMF_ANY)) == NULL )
		{
		CloseCon(ConInfo);
		return(NULL);
		}
	ConInfo->Buffer[i][0] = 0;
	}

RP = Win->RPort;

ConInfo->RP 			= RP;
ConInfo->APen 		= GetTagData(CON_APen,DEFAPEN,TagList);
ConInfo->BPen 		= GetTagData(CON_BPen,DEFBPEN,TagList);
ConInfo->DrMd 		= GetTagData(CON_DrMd,DEFDRMD,TagList);
ConInfo->TxHeight = GetTagData(CON_TxHeight,(RP->TxHeight + 2),TagList);
ConInfo->TxUp 		= GetTagData(CON_TxHeight,(ConInfo->TxHeight - RP->TxBaseline),TagList);
ConInfo->CursorColor = GetTagData(CON_CursorColor,DEFCURSORCOLOR,TagList);
ConInfo->MinX 		= GetTagData(CON_MinX,(Win->BorderLeft + 1),TagList);
ConInfo->MinY 		= GetTagData(CON_MinY,(Win->BorderTop + 1),TagList);
ConInfo->MaxX 		= GetTagData(CON_MaxX,((Win->Width)-(Win->BorderRight)-2) , TagList);
ConInfo->MaxY 		= GetTagData(CON_MaxY,((Win->Height)-(Win->BorderBottom)-2) , TagList);

//bools
if ( GetTagData(CON_CursorType,0,TagList) ) ConInfo->Flags |= CIF_LINECURSOR;

ConInfo->CurLines = 1;

return(ConInfo);
}

__stdargs struct ConInfo * InitCon (struct Window * Win,ulong FirstTag, ...)
{
return ( InitConA(Win, (struct TagItem *) &FirstTag) );
}

__regargs void ModifyConA (struct ConInfo * ConInfo,struct TagItem * TagList)
{
struct Window * Win;

ConInfo->CursorColor = GetTagData(CON_CursorColor,ConInfo->CursorColor,TagList);

if ( FindTagItem(CON_ReadRP,TagList) )
	{
	struct RastPort *RP;
	RP = ConInfo->RP;
	ConInfo->APen 		= GetTagData(CON_APen, RP->FgPen, TagList);
	ConInfo->BPen 		= GetTagData(CON_BPen, RP->BgPen, TagList);
	ConInfo->DrMd 		= GetTagData(CON_DrMd, RP->DrawMode, TagList);
	ConInfo->TxHeight = GetTagData(CON_TxHeight,(RP->TxHeight + 2),TagList);
	ConInfo->TxUp 		= GetTagData(CON_TxHeight,(ConInfo->TxHeight - RP->TxBaseline),TagList);
	}
else
	{
	ConInfo->APen 			 = GetTagData(CON_APen ,ConInfo->APen ,TagList);
	ConInfo->BPen 			 = GetTagData(CON_BPen ,ConInfo->BPen ,TagList);
	ConInfo->DrMd 			 = GetTagData(CON_DrMd ,ConInfo->DrMd ,TagList);
	ConInfo->TxHeight 	 = GetTagData(CON_TxHeight,ConInfo->TxHeight,TagList);
	ConInfo->TxUp		  	 = GetTagData(CON_TxHeight,ConInfo->TxUp,TagList);
	}
	
if ( Win = (struct Window *) GetTagData(CON_ReadWin,0,TagList) )
	{
	ConInfo->MinX 		= (Win->BorderLeft) + 1;
	ConInfo->MinY 		= (Win->BorderTop)  + 1;
	ConInfo->MaxX 		= (Win->Width)  - (Win->BorderRight)  - 1;
	ConInfo->MaxY 		= (Win->Height) - (Win->BorderBottom) - 1;
	}
else
	{
	ConInfo->MinX 		= GetTagData(CON_MinX,ConInfo->MinX,TagList);
	ConInfo->MinY 		= GetTagData(CON_MinY,ConInfo->MinY,TagList);
	ConInfo->MaxX 		= GetTagData(CON_MaxX,ConInfo->MaxX,TagList);
	ConInfo->MaxY 		= GetTagData(CON_MaxY,ConInfo->MaxY,TagList);
	}

}

__stdargs void ModifyCon (struct ConInfo * ConInfo,ulong FirstTag, ...)
{
ModifyConA(ConInfo, (struct TagItem *) &FirstTag );
}

__regargs void HandleCon  (struct ConInfo * ConInfo,uword RawKey,uword Qualifier)
{
uword IsShifted;

if ( (Qualifier & IEQUALIFIER_LSHIFT) || (Qualifier & IEQUALIFIER_RSHIFT) )
	IsShifted = 1;
else
	IsShifted = 0;

switch( RawKey )
	{
	case 68:
		AdvanceCon(ConInfo);
		break;
	case 76: //up arrow
		ConInfo->CurCharPos = 0;
		ConInfo->CurRefLine ++;
		if ( (ConInfo->CurRefLine) >= (ConInfo->CurLines) )
			 ConInfo->CurRefLine = ConInfo->CurLines - 1;
		strcpy( ConInfo->Buffer[0] , ConInfo->Buffer[(ConInfo->CurRefLine)] );
		ConInfo->StrLens[0] = ConInfo->StrLens[(ConInfo->CurRefLine)];
		RedrawConBottom(ConInfo,1);
		break;
	case 77: //down arrow
		ConInfo->CurCharPos = 0;
		ConInfo->CurRefLine --;
		if ( (ConInfo->CurRefLine) <= 0 )
			{
			ConInfo->CurRefLine  = 0;
			ConInfo->Buffer[0][0]= 0;
			ConInfo->StrLens[0]  = 0;
			}
		else
			{
			strcpy( ConInfo->Buffer[0] , ConInfo->Buffer[(ConInfo->CurRefLine)] );
			ConInfo->StrLens[0] = ConInfo->StrLens[(ConInfo->CurRefLine)];
			}
		RedrawConBottom(ConInfo,1);
		break;

	case 78: //right arrow
		if ( IsShifted ) ConInfo->CurCharPos = ConInfo->StrLens[0];
		else
			{
			ConInfo->CurCharPos ++;		
			if ( ConInfo->CurCharPos > (ConInfo->StrLens[0]) )
				ConInfo->CurCharPos = ConInfo->StrLens[0];
			}
		RedrawConBottom(ConInfo,1);
		break;
	case 79: //left arrow
		if ( IsShifted ) ConInfo->CurCharPos = 0;
		else
			{
			ConInfo->CurCharPos --;
			if ( ConInfo->CurCharPos < 0 ) 
				ConInfo->CurCharPos = 0;
			}
		RedrawConBottom(ConInfo,1);
		break;
	case 70: //delete
		if ( IsShifted )
			{
			ConInfo->StrLens[0] = ConInfo->CurCharPos;
			ConInfo->Buffer[0][ConInfo->CurCharPos] = 0;
			RedrawConBottom(ConInfo,1);
			}
		else if ( ConInfo->CurCharPos < ConInfo->StrLens[0] )
			{
			memmove(&(ConInfo->Buffer[0][ConInfo->CurCharPos]),
							&(ConInfo->Buffer[0][ConInfo->CurCharPos + 1]),
							ConInfo->StrLens[0] - (ConInfo->CurCharPos + 1));
			ConInfo->StrLens[0] --;				
			RedrawConBottom(ConInfo,1);
			}
		break;
	case 65: //backspace
		if ( IsShifted )
			{
			memmove(&(ConInfo->Buffer[0][0]),
							&(ConInfo->Buffer[0][ConInfo->CurCharPos]),
							ConInfo->StrLens[0] - (ConInfo->CurCharPos));
			ConInfo->StrLens[0] -= (ConInfo->CurCharPos);
			ConInfo->Buffer[0][ConInfo->StrLens[0]] = 0;
			ConInfo->CurCharPos = 0;
			RedrawConBottom(ConInfo,1);
			}
		else if ( ConInfo->CurCharPos > 0 )
			{
			ConInfo->CurCharPos--;
			memmove(&(ConInfo->Buffer[0][ConInfo->CurCharPos]),
							&(ConInfo->Buffer[0][ConInfo->CurCharPos + 1]),
							ConInfo->StrLens[0] - (ConInfo->CurCharPos + 1));
			ConInfo->StrLens[0] --;				
			RedrawConBottom(ConInfo,1);
			}
		break;

	default:
		{
		ubyte GotChar;

		if ( ConInfo->StrLens[0] >= ConInfo->BufLen ) break;	

		if ( GotChar = Raw2Vanilla(RawKey,IsShifted) )
			{
			memmove(&(ConInfo->Buffer[0][ConInfo->CurCharPos + 1]),
							&(ConInfo->Buffer[0][ConInfo->CurCharPos]),	
							ConInfo->StrLens[0] - ConInfo->CurCharPos);

			ConInfo->Buffer[0][ConInfo->CurCharPos] = GotChar;
			ConInfo->CurCharPos ++;
			ConInfo->StrLens[0] ++;
			ConInfo->Buffer[0][ConInfo->StrLens[0]] = 0;

			RedrawConBottom(ConInfo,1);
			}
		break;
		}
	}
}

void __regargs GetCon (struct ConInfo * ConInfo,char *into)
{
strcpy(into,ConInfo->Buffer[0]);
}

void __regargs AddCon (struct ConInfo * ConInfo,char *from)
{
strcpy(ConInfo->Buffer[0],from);
ConInfo->StrLens[0]=strlen(from);
AdvanceCon(ConInfo);
RedrawCon(ConInfo);
}

void __regargs ClearConCursor (struct ConInfo * ConInfo)
{
ConInfo->CursorStatus = 0;
RedrawConBottom(ConInfo,0);
}

void __regargs ShowConCursor (struct ConInfo * ConInfo)
{
ConInfo->CursorStatus = 1;
RedrawConBottom(ConInfo,1);
}
