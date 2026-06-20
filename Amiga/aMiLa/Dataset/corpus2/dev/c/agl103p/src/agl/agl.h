/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: agl.h,v 1.2.1.3 1994/12/09 05:27:24 jason Exp $

$Log: agl.h,v $
 * Revision 1.2.1.3  1994/12/09  05:27:24  jason
 * added globals for screen size
 *
 * Revision 1.2.1.2  1994/11/16  06:19:41  jason
 * lots more globals
 *
 * Revision 1.2.1.1  1994/03/29  05:31:04  jason
 * Added RCS Header
 *

******************************************************************************/


#include<exec/types.h>
#include<exec/memory.h>
#include<devices/gameport.h>
#include<intuition/intuitionbase.h>
#include<graphics/gfxmacros.h>

#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<math.h>

#ifdef __SASC
/* #include<functions.h> */
#endif

#ifdef AZTEC_C
#include<functions.h>
#endif

#ifdef LATTICE
#include<lattice_amiga.h>
#define SEEK_CUR 1
#endif

#include<gl.h>
#include<device.h>

#define	PIE	3,14159265
#define DEG .01745329	/* PIE/180.0 */

#define SCREENX		700     /* 720 */
#define SCREENY		450     /* 450 */
#define SCREENDEPTH	4       /* 4 */

/* 4Sight User's Guide says the default minumum size is 80x40 */
#define MIN_WINX	80
#define MIN_WINY	40

#define MICE		FALSE	/* TRUE = second mouse active */

#define MAX_WINDOWS 10
#define MAX_DEVICE	600		/* theoretically 20000 */
#define QUEUE_SIZE	101		/* according to GL manual */

#define	GL_POINT	1
#define	GL_LINE		2
#define	GL_POLYGON	3

#define	MAX_POLY_VERTS		255

/* extra colors (not official GL) */
#define DARKGREY    8
#define PINK        9 
#define LIGHTGREEN  10
#define OLIVE       11
#define LAVENDER    12
#define PURPLE      13
#define BLUEGREEN   14
#define LIGHTGREY   15

#define CBLACK          0x000
#define CRED            0xF00
#define CGREEN          0x0F0
#define CYELLOW         0xFF0
#define CBLUE           0x00F
#define CMAGENTA        0xF0F
#define CCYAN           0x0FF
#define CWHITE          0xFFF
#define CDARKGREY       0x555
#define CPINK           0xC77
#define CLIGHTGREEN     0x7C7
#define COLIVE          0x883
#define CLAVENDER       0x77C
#define CPURPLE         0x838
#define CBLUEGREEN      0x388
#define CLIGHTGREY      0xAAA

#ifdef NOT_EXTERN
#define extern
#endif

extern USHORT ColorMap[16]
#ifdef NOT_EXTERN
	={
	CBLACK,
	CRED,
	CGREEN,
	CYELLOW,
	CBLUE,
	CMAGENTA,
	CCYAN,
	CWHITE,
	CDARKGREY,
	CPINK,
	CLIGHTGREEN,
	COLIVE,
	CLAVENDER,
	CPURPLE,
	CBLUEGREEN,
	CLIGHTGREY,
	}
#endif
;

extern struct Device *ConsoleDev;

extern struct IOStdReq IOStandardRequest;
extern struct GfxBase *GfxBase;
extern struct IntuitionBase *IntuitionBase;
extern struct IntuiMessage *Message;

extern struct ViewPort *GLView;
extern struct Window *GLWindow[MAX_WINDOWS];
extern struct Screen *GLScreen;

extern struct TextAttr StdFont
#ifdef NOT_EXTERN
	={
	"JXEN.font",
	7,
	FS_NORMAL,
	0
	}
#endif
;

extern struct NewScreen ScreenDef
#ifdef NOT_EXTERN
	={
	0,0,
	SCREENX,SCREENY,SCREENDEPTH,
	BLACK,WHITE,
	HIRES | LACE,
	CUSTOMSCREEN,
	&StdFont,
	"Amiga GL v1.03  by Jason Weber",
	NULL,
	NULL,
	}
#endif
;

extern struct NewWindow NextWindow;
extern struct NewWindow DefaultWindow
#ifdef NOT_EXTERN
	={
	100,100,
	SCREENX-200,SCREENY-200,
	(UBYTE)(-1),(UBYTE)(-1),
/* 	NEWSIZE | CLOSEWINDOW | REFRESHWINDOW | ACTIVEWINDOW | INACTIVEWINDOW | MOUSEBUTTONS | RAWKEY, */
	NEWSIZE | REFRESHWINDOW | ACTIVEWINDOW | INACTIVEWINDOW | MOUSEBUTTONS | RAWKEY,
	SIMPLE_REFRESH | RMBTRAP,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	MIN_WINX,MIN_WINY,
	SCREENX-1,SCREENY-1,
	CUSTOMSCREEN,
	}
#endif
;


#ifdef NOT_EXTERN
	extern short ScreenWidth=SCREENX;
	extern short ScreenHeight=SCREENY;
	extern short ScreenDeep=SCREENDEPTH;
#else
	extern short ScreenWidth;
	extern short ScreenHeight;
	extern short ScreenDeep;
#endif


extern unsigned short AreaBuffer[MAX_WINDOWS][MAX_POLY_VERTS*5/2];
extern PLANEPTR TempBuffer[MAX_WINDOWS];
extern struct TmpRas TempRaster[MAX_WINDOWS];
extern struct AreaInfo AInfo[MAX_WINDOWS];

extern struct BitMap BackBitMap[MAX_WINDOWS];
extern struct RastPort *VisibleRPort,*DrawRPort,BackRPort[MAX_WINDOWS];
extern struct TextFont *FontPtr;

extern char TitleList[MAX_WINDOWS][100];

extern long CurrentPosX,CurrentPosY;
extern long CurrentHeight,CurrentWidth;
extern long CurrentColor;
extern long Verts;
extern long GLFocus;
extern long CurrentWid;

extern short ViewPort[MAX_WINDOWS][4];
extern short Clipped[MAX_WINDOWS];
extern short Bordered[MAX_WINDOWS];
extern short DoubleBuffered[MAX_WINDOWS];
extern short DoubleBufferSet[MAX_WINDOWS];
extern short Sizeable[MAX_WINDOWS];
extern short RGBmodeOn[MAX_WINDOWS];
extern short RGBmodeSet[MAX_WINDOWS];
extern short OneToOne[MAX_WINDOWS];
extern short Dimensions[MAX_WINDOWS];
extern short RedoBorder[MAX_WINDOWS];
extern short Maximization[MAX_WINDOWS][4];

extern short DrawType;
extern short BgnLine;
extern short BorderWidth,BorderHeight;

#undef extern

#include"prototypes.h"
