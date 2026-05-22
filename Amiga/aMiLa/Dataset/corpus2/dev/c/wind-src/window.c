/*
	window.c
	WindowDemo - COOL !

	Manx Aztec C V5.0
	Tuesday, October 8, 1991

	Coded by Sentinel
	# CRO 042 691 567
*/

/***************************************************************************/

#include <ctype.h>
#include <exec/types.h>
#include <exec/memory.h>

#include <graphics/gfxbase.h>
#include <graphics/gfx.h>

#include <intuition/intuitionbase.h>
#include <intuition/intuition.h>

/***************************************************************************/

#define WIN_WIDTH	640
#define WIN_HEIGHT	256

#define MIN_WIDTH	175
#define MIN_HEIGHT	52

#define MAX_WIDTH	640
#define MAX_HEIGHT_PAL	256
#define MAX_HEIGHT_NTSC	200

/***************************************************************************/

void adios(char *message);
void about(void);
long asker(void);

/***************************************************************************/

struct GfxBase		*GfxBase;
struct IntuitionBase	*IntuitionBase;

struct Window		*window;
struct RastPort		*rastport;
struct IntuiMessage	*intuimessage;

/***************************************************************************/
struct TextAttr T8 = { (UBYTE *)"topaz.font", 8, 0, 0 };

static char winstring[] = "1991 By SENTINEL";
struct IntuiText wintext = { 3, 0, JAM1, 0, 0, &T8, (UBYTE *)&winstring, 0 };

/***************************************************************************/

static char WindowTitle[] = "WindowDemo";
struct NewWindow newwindow = {	0, 0, WIN_WIDTH, WIN_HEIGHT, 0, 1,
				CLOSEWINDOW|MENUPICK,
				WINDOWCLOSE|WINDOWSIZING|WINDOWDRAG
				|WINDOWDEPTH|ACTIVATE|NOCAREREFRESH,
				(struct Gadget *)NULL,
				(struct Image *)NULL,
				(UBYTE *)WindowTitle,
				(struct Screen *)NULL,
				(struct BitMap *)NULL,
				MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH,
				MAX_HEIGHT_PAL, WBENCHSCREEN };

/***************************************************************************/

struct IntuiText intuitext1 = { 0, 1, JAM1, 8, 1, &T8, (UBYTE *)"About", 0 };
struct IntuiText intuitext2 = { 0, 1, JAM1, 0, 1, &T8, (UBYTE *)"-------", 0 };
struct IntuiText intuitext3 = { 0, 1, JAM1, 8, 1, &T8, (UBYTE *)"Quit", 0 };

struct MenuItem menuitem1 = { 	NULL,
				2, 0, 56, 10,
				ITEMTEXT|ITEMENABLED|HIGHCOMP, 0L,
				(APTR)&intuitext1,
				(APTR)0, (BYTE)0, (struct MenuItem *)0,
				(USHORT)0 };

struct MenuItem menuitem2 = { 	(struct MenuItem *)&menuitem1,
				2, 10, 56, 10,
				ITEMTEXT|HIGHCOMP, 0L,
				(APTR)&intuitext2,
				(APTR)0, (BYTE)0, (struct MenuItem *)0,
				(USHORT)0 };

struct MenuItem menuitem3 = { 	(struct MenuItem *)&menuitem2,
				2, 19, 55, 10,
				ITEMTEXT|ITEMENABLED|HIGHBOX, 0L,
				(APTR)&intuitext3,
				(APTR)0, (BYTE)0, (struct MenuItem *)0,
				(USHORT)0 };

struct Menu menu = {		NULL,
				0, 0,
				62, 10,
				MENUENABLED,
				(BYTE *) "Options",
				&menuitem3,
				0, 0, 0, 0 };

/***************************************************************************/

UWORD pointer_data[] ={	0, 0, 256, 256, 256, 256, 896, 0, 3168, 0, 12312, 0,
			256, 49414, 256, 49414, 12312, 0, 3168, 0, 896, 0,
			256, 256, 256, 256, 256, 256, 0, 0 };

UWORD *chip_data;

/***************************************************************************/

ULONG class;
USHORT code;
BOOL quit=FALSE;
short count;

/***************************************************************************/

void main(void)
{

GfxBase = (struct GfxBase *) OpenLibrary("graphics.library", 0L);
if (!GfxBase) adios("ERROR: Couldn't open graphics.library !");

IntuitionBase = (struct IntuitionBase *) OpenLibrary("intuition.library", 0L);
if (!IntuitionBase) adios("ERROR: Couldn't open intuition.library !");

chip_data = (UWORD *) AllocMem(sizeof(pointer_data), MEMF_CHIP);
if (!chip_data) adios("ERROR: Couldn't allocate memory for chip_data");

for (count = 0; count <32; count++)
	*(chip_data+count) = pointer_data[count];

if (GfxBase -> DisplayFlags == 1)
	newwindow.MaxHeight = newwindow.Height = MAX_HEIGHT_NTSC;

window = (struct Window *) OpenWindow(&newwindow);
if (!window) adios("ERROR: Not enough memory for main-window.");

rastport=window->RPort;
PrintIText(rastport, &wintext, 25, 25);

SetPointer(window, (short *) chip_data, 14, 16, -7, -6);
SetMenuStrip(window, &menu);

while (!quit) {
	intuimessage = (struct IntuiMessage *) GetMsg(window->UserPort);

	if (intuimessage == NULL)
		continue;

	class = intuimessage->Class;
	code = intuimessage->Code;

	switch (class) {
		case CLOSEWINDOW :
			quit = (BOOL) asker();
			break;

		case MENUPICK :
			if (MENUNUM(code)==0)
				switch(ITEMNUM(code)) {
					case 2:	about();
						break;

					case 0:	quit=(BOOL) asker();
				}
		}

	ReplyMsg(intuimessage);
	}

ClearMenuStrip(window, &menu);
ClearPointer(window);

adios(NULL);
}

/***************************************************************************/

void adios(char *message)
{
	if(message)		puts(message);
	if(chip_data)		FreeMem(chip_data, sizeof(pointer_data));
	if(window)		CloseWindow(window);
	if(IntuitionBase)	CloseLibrary(IntuitionBase);
	if(GfxBase)		CloseLibrary(GfxBase);
	if(message)		exit(1);
}

/***************************************************************************/

void about(void)
{

	static char title[] = "About WindowDemo";
	static char text1[] = " WindowDemo Version 1.0b";
	static char text2[] = "   (c)1991 By Sentinel";
	static char text3[] = "Call me: CRO #042 691 567";

	struct Window		*wd;
	struct RastPort		*rp;
	struct IntuiMessage	*im;

	static struct IntuiText it3 = { 1, 0, JAM1, 5, 24, &T8,
		(UBYTE *)text3, (struct IntuiText *)NULL };

	static struct IntuiText it2 = { 2, 0, JAM1, 5, 12, &T8,
		(UBYTE *)text2, (struct IntuiText *)&it3 };

	static struct IntuiText it1 = { 3, 0, JAM1, 5, 0, &T8,
		(UBYTE *)text1, (struct IntuiText *)&it2 };

	static short coords[] = { 1, 1, 238, 1, 238, 50, 1, 50, 1, 1 };
	static struct Border brdr = { 0, 0, 3, 0, JAM1, 5, &coords[0], NULL };

	struct NewWindow nw = {	15, 15, 251, 65, 0, 1,
				CLOSEWINDOW|MOUSEBUTTONS,
				WINDOWCLOSE|WINDOWDRAG|ACTIVATE|RMBTRAP,
				(struct Gadget *)NULL,
				(struct Image *)NULL,
				(UBYTE *)title,
				(struct Screen *)NULL,
				(struct BitMap *)NULL,
				0, 0, 0, 0, WBENCHSCREEN };


	wd = (struct Window *) OpenWindow (&nw);
	if (wd) {
		rp=wd->RPort;
		PrintIText(rp, &it1, 20, 20);
		DrawBorder(rp, &brdr, 6, 11);

		while (im->Class != CLOSEWINDOW && im->Class != MOUSEBUTTONS)
			im = (struct IntuiMessage *) GetMsg(wd->UserPort);
		ReplyMsg(im);
		CloseWindow(wd);
		}
	else
		adios("ERROR: Not enough memory for about-window");
}

/***************************************************************************/

long asker(void)
{

	static struct IntuiText BodyText = {0, 1, JAM1, 20, 4, &T8,
		(UBYTE *)"Are you sure ?", NULL};

	static struct IntuiText PosText = {0, 1, JAM1, 6, 4, &T8,
		(UBYTE *)"Yes", NULL};

	static struct IntuiText NegText = {0, 1, JAM1, 7, 4, &T8,
		(UBYTE *)"No", NULL};


	return(AutoRequest (window, &BodyText, &PosText, &NegText,
		0, 0, 170, 50));
}
