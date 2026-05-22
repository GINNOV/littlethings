#include <libraries/Picasso96.h>
#include <utility/tagitem.h>
#include <intuition/intuition.h>
#include <graphics/text.h>
#include <proto/picasso96.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/diskfont.h>
#include <proto/exec.h>

#include <stdio.h>
#include <string.h>

struct Screen *Scr=NULL;

struct ScreenBuffer *Buf1=NULL;
struct ScreenBuffer *Buf2=NULL;

struct Library *P96Base=NULL;

void RemoveSys(STRPTR);

int main()
{
ULONG DisplayID;
LONG width,height;

	P96Base=OpenLibrary((UBYTE *)"Picasso96API.library",2);
	if(P96Base==NULL)
	{
		RemoveSys("No library..");
	}

	DisplayID=p96BestModeIDTags(P96BIDTAG_NominalWidth, 320,
								P96BIDTAG_NominalHeight, 240,
								P96BIDTAG_Depth, 24,
								P96BIDTAG_FormatsForbidden, (RGBFF_R5G5B5|RGBFF_R5G5B5PC|RGBFF_B5G5R5PC|RGBFF_CLUT),
								TAG_DONE );

	if(DisplayID == INVALID_ID)
	{
		RemoveSys("No screenmode");
	}

	width=p96GetModeIDAttr(DisplayID, P96IDA_WIDTH);
	height=p96GetModeIDAttr(DisplayID, P96IDA_HEIGHT);
	Scr=p96OpenScreenTags( P96SA_Width, 	width,
							P96SA_Height,	height,
							P96SA_Depth,	p96GetModeIDAttr(DisplayID, P96IDA_DEPTH),
							P96SA_Type,		CUSTOMSCREEN,
							P96SA_DisplayID,DisplayID,
							P96SA_ShowTitle,FALSE,
							P96SA_RGBFormat,p96GetModeIDAttr(DisplayID,P96IDA_RGBFORMAT),
							TAG_DONE);
	if(Scr==NULL)
	{
		RemoveSys("No screen");
	}

	Buf1=AllocScreenBuffer(Scr, NULL,SB_SCREEN_BITMAP);
	if(Buf1==NULL)
	{
		RemoveSys("No Buf_1");
	}

	Buf2=AllocScreenBuffer(Scr, NULL,SB_COPY_BITMAP);
	if(Buf2==NULL)
	{
		RemoveSys("No Buf_2");
	}

	RemoveSys("All OK");
}

void RemoveSys(STRPTR Err)
{
	puts(Err);

	if(Buf1)
	{
		FreeScreenBuffer(Scr,Buf1);
		Buf1=NULL;
	}

	if(Buf2)
	{
		FreeScreenBuffer(Scr,Buf2);
		Buf2=NULL;
	}

	if(Scr)
	{
		p96CloseScreen(Scr);
		Scr=NULL;
	}

	if(P96Base)
	{
		CloseLibrary(P96Base);
		P96Base=NULL;
	}
}
