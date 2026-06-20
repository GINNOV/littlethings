/* ---------------------------  I N C L U D E S  -------------------------- */

#include "global.h"
#include "JoyStick.h"
#include <stdio.h>
#include <stdlib.h>

/* ----------------------------  D E F I N E S  --------------------------- */

#define SUCCESS 0
/* BIT FLAGS FOR THE BLOCKTYPE */
#define NORTH 1
#define EAST  2
#define SOUTH 4
#define WEST  8
#define DOOR  16

#define N 0
#define E 1
#define S 2
#define W 3
#define DRN 4
#define DRE 5
#define DRS 6
#define DRW 7

/* -----------------------------  G L O B A L  ---------------------------- */

struct Library  *IntuitionBase;
struct Library  *GfxBase;
struct RastPort *RASTPORT = NULL;
struct Screen   *MySCR;
struct Window   *MyWIN;
struct BitMap	*MyBMP;

struct NewScreen NewScreen; /* Structures needed for Workbench V1.3 compatibility */
struct NewWindow NewWindow;

word JoyStick1 = NULL;

unsigned byte *WallGfx[NbrWallBMPs];

unsigned byte *fBUFFER;

/* ----------------  I N T E R N A L   S T R U C T U R E S  --------------- */

static char *ErrorMesg[12] =
{
	"No Errors Occurred",
	"Could not open >intuition.library V37<",
	"Could not open >graphics.library V37<",
	"Could not open a custom screen.",
	"Could not open a window!",
	"Could not allocate joystick port!",
	"Could not open file 'walls.bmp'",
	"File 'walls.bmp' is corrupted",
	"Could not allocate temporary bitmaps for WritePixelArray8",
	"Could not allocate memory for wall bitmaps",
	"Could not allocate memory for the bitmap structure",
	"Could not allocate memory for the planes",
};

static char *version = "$VER: WOLF3D V0.4 (8 Apr 94) Copyright ©1994 Terence Russell. All rights reserved.";


/* ------------------  I N T E R N A L   R O U T I N E S  ----------------- */

word StartUp( void );
void CleanUp( void );
void ERROR_ALERT( word );

/* ------------------  E X T E R N A L   R O U T I N E S  ------------------ */

extern void WOLF3D( void );
