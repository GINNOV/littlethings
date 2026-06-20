/*
 * Vogle driver for the Amiga
 *
 * Written By: Dr. Charles E. Campbell, Jr.
 * Version   : 1.00
 * Date      : September 28, 1993
 *
 */
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <stdlib.h>
#include <ctype.h>

#include <functions.h>
#include <exec/types.h>
#include <intuition/intuition.h>
#include <libraries/dos.h>
#include <graphics/rastport.h>
#include <graphics/gfxmacros.h>
#include <graphics/text.h>
#include <exec/memory.h>
#include <devices/inputevent.h>
#include <clib/exec_protos.h>
#include <clib/intuition_protos.h>
#include <clib/console_protos.h>

#include "vogl.h"

#define INTUITION_REV	((unsigned long) 33L)
#define GRAPICS_REV		((unsigned long) 33L)

/* --------------------------------------------------------------------------
 * Definitions Section:
 */
#define SNGLBUFMODE	0	/* default scrbufmode value					*/
#define DBLBUFMODE	1	/* scrbufmode value							*/
#define RAWKEYBUF	128	/* initial size of rawkey buffer conversion	*/
#define KEYBUF		256	/* max size of keybuffer to be read			*/

#define FONTSEP		';'
#define MAXVRTX		200
#define MAXSTRING	1024

#ifdef SASC
#define USESVMODE
#endif

#ifdef AZTEC_C
# define MEMTYPE	(MEMF_CHIP|MEMF_CLEAR)
#else
# define MEMTYPE	(MEMF_CLEAR)
#endif

/* head_link: handles the generation of head-linked lists.  Note that 
 *   each structure is assumed to have the member "nxt".
 *   The new member becomes "head" - ie. oldest is last in the linked list,
 *   the newest is first.
 */
#define head_link(structure,head,fail_msg) {         \
	structure *newstr;                               \
	newstr= (structure *) malloc(sizeof(structure)); \
	if(!newstr) printf("***out of memory*** <%s>\n",fail_msg);   \
	newstr->nxt= head;                               \
	head    = newstr;                                \
	}

/* stralloc: allocates new memory for and copies a string into the new mem */
#define stralloc(ptr,string,fail_msg) {                             \
	ptr= (char *) calloc((size_t) strlen(string) + 1,sizeof(char)); \
	if(!ptr) printf("***out of memory*** <%s>\n",fail_msg);                  \
	strcpy(ptr,string);                                             \
	}

/* --------------------------------------------------------------------------
 * Typedefs:
 */
typedef struct FontList_str FontList;

/* --------------------------------------------------------------------------
 * Data Structures:
 */
struct FontList_str {
	char            *fontspec;
	struct TextFont *textfont;
	FontList        *nxt;
	};

/* --------------------------------------------------------------------------
 * Extern Data:
 */
#ifdef AZTEC_C
extern int Enable_Abort;
#else
void __regargs __checkabort (void);
#endif

/* --------------------------------------------------------------------------
 * Local Data:
 */
WORD                 *voglareaBuffer= NULL;
struct BitMap        *voglback      = NULL;
struct BitMap        *voglfront     = NULL;
struct DiskFontBase  *DiskfontBase  = NULL;
struct GfxBase       *GfxBase       = NULL;
struct IntuiText     *voglitext     = NULL;
struct IntuitionBase *IntuitionBase = NULL;
struct IOStdReq      *vogl_cd_ioreq = NULL;
struct Library       *ConsoleDevice = NULL;
struct RastPort      *voglrastport  = NULL;
struct Screen        *voglscreen    = NULL;
struct TextAttr      *vogltextattr  = NULL;
struct TmpRas        *vogltmpras    = NULL;
struct Window        *voglwindow    = NULL;

static char               useborder       = 0;
static char               scrbufmode      = SNGLBUFMODE;
static char              *rawkeybuf       = NULL;
static int                grfxmode        = 0;
static int                currcolor       = 0;
static UBYTE             *voglstring      = NULL;
static UWORD              scrdepth        = 4;
static UWORD              scrwidth        = 0;
static UWORD              scrheight       = 0;
static UWORD              voglscrbordleft = 0;
static UWORD              voglscrbordright= 0;
static UWORD              voglscrbordtop  = 0;
static UWORD              voglscrbordbttm = 0;
static USHORT             screenviewmode  = HIRES|LACE;
static LONG               qtyrawkeybuf    = 0L;
static FontList          *fontlisthd      = NULL;
static struct InputEvent *voglievent      = NULL;
static PLANEPTR          voglplaneptr     = NULL;

/* voglkeybuf
 *   |uuuddddddduuuuu|    u=unused  d=data
 *      ^       ^
 *   ikeybgn    ikeyend   (always point to unused)
 */
static char     voglkeybuf[KEYBUF];
static unsigned ikeyend= 0;			/* points just-past chars in voglkeybuf		*/
static unsigned ikeybgn= KEYBUF-1;	/* points just-before chars in voglkeybuf	*/


/* --------------------------------------------------------------------------
 * Local Prototypes:
 */
void AMIGA_config(char *);                             /* amiga.c         */
int AMIGA_init(void);                                  /* amiga.c         */
static struct BitMap *makeBitMap(void);                /* amiga.c         */
void freeBitMap(struct BitMap *);                      /* amiga.c         */
int AMIGA_exit(void);                                  /* amiga.c         */
void AMIGA_draw( int, int);                            /* amiga.c         */
int AMIGA_getkey(void);                                /* amiga.c         */
int AMIGA_checkkey(void);                              /* amiga.c         */
int AMIGA_locator( int *, int *);                      /* amiga.c         */
void AMIGA_clear(void);                                /* amiga.c         */
void AMIGA_color(int);                                 /* amiga.c         */
void AMIGA_mapcolor( int, int, int, int);              /* amiga.c         */
int AMIGA_font(char *);                                /* amiga.c         */
void AMIGA_char(char);                                 /* amiga.c         */
void AMIGA_string(char *);                             /* amiga.c         */
void AMIGA_fill( int, int[], int[]);                   /* amiga.c         */
int AMIGA_backbuffer(void);                            /* amiga.c         */
int AMIGA_swapbuffer(void);                            /* amiga.c         */
void AMIGA_frontbuffer(void);                          /* amiga.c         */
void _AMIGA_devcpy(void);                              /* amiga.c         */


/* --------------------------------------------------------------------------
 * Device Entry
 *	fontname;height[;{BEIPU}]
 *   B == bold
 *   E == extended
 *   I == italic
 *   P == plain (default)
 *   U == underlined
 */
static DevEntry amigadev = {
	"AMIGA",			/* name of device								*/
	"topaz;9;P",		/* name of small "hardware" font				*/
	"topaz;11;P",		/* name of large "hardware" font				*/
	AMIGA_backbuffer,	/* initializes double buffering					*/
	AMIGA_char,			/* prints a "hardware" character				*/
	AMIGA_checkkey,		/* check if keyboard key hit, return it			*/
	AMIGA_clear,		/* clears viewport to background				*/
	AMIGA_color,		/* change current color index					*/
	AMIGA_draw,			/* draws line from current to (x,y)				*/
	AMIGA_exit,			/* cleans up and allows vogle to exit			*/
	AMIGA_fill,			/* does filled polygons							*/
	AMIGA_font,			/* sets up a hardware font						*/
	AMIGA_frontbuffer,	/* switches drawing into front buffer			*/
	AMIGA_getkey,		/* gets a char of input							*/
	AMIGA_init,			/* enables graphics								*/
	AMIGA_locator,		/* finds mouse position in vogle device coords	*/
	AMIGA_mapcolor,		/* changes color at index to given rgb value	*/
	AMIGA_string,		/* prints a string of hardware text				*/
	AMIGA_swapbuffer};	/* swaps front and back buffers					*/

/* ==========================================================================
 * Source Code:
 */

/* AMIGA_config: This function modifies what AMIGA_init does.  It allows the
 * user to control the type of screen and bitmaps used.  Note that one may
 * use extra half-brite mode, too.  I put in ham mode since I expect to
 * attempt to do some shading someday.
 *
 * The AMIGA_init sets up a gimmezerozero window using a custom Screen and
 * BitMap.
 *
 * The config string may include:
 *      b : use border&title on window
 *		d : double buffer mode
 *		e : extra halfbrite mode
 *		h : ham graphics mode
 *      s : single buffer mode
 *		1-5 : 1,2,3, 4, 5 bit planes (2,4,8,16,64 colors, respectively)
 *
 * Screen height will be max and interlaced.
 * Screen width  will be 640 for 1-4 bit planes and 320 otherwise
 */
void AMIGA_config(char *config)
{
Enable_Abort=0;

for(; *config; ++config) switch(*config) {

case 'b':	/* use border on window */
	useborder= 1;
	break;

case 'd':	/* double buffer mode	*/
	scrbufmode= DBLBUFMODE;
	break;

case 'e':	/* extra halfbrite mode	*/
	screenviewmode= LACE|EXTRA_HALFBRITE;
	scrdepth     = 6;
	break;

case 'h':	/* ham mode				*/
	screenviewmode= LACE|HAM;
	scrdepth     = 6;
	break;

case 's':	/* single buffer mode */
	scrbufmode= SNGLBUFMODE;
	break;

case '1':	/* one bit plane		*/
	screenviewmode= LACE|HIRES;
	scrdepth     = 1;
	break;

case '2':	/* two bit planes		*/
	screenviewmode= LACE|HIRES;
	scrdepth     = 2;
	break;

case '3':	/* three bit planes		*/
	screenviewmode= LACE|HIRES;
	scrdepth     = 3;
	break;

case '4':	/* four bit planes		*/
	screenviewmode= LACE|HIRES;
	scrdepth     = 4;
	break;

case '5':
	screenviewmode= LACE;
	scrdepth     = 5;
	break;

default:
	screenviewmode= LACE|HIRES;
	scrdepth     = 4;
	printf("***warning*** AMIGA_config: bad config<%s> string\n",config);
	break;
	}
}

/* -------------------------------------------------------------------------- */

/* AMIGA_init: initialises drawing canvas to occupy current window
 *  a routine which enables graphics on the device, sets the default
 *  colour map, and sets vdevice.maxS{x,y} and vdevice.minS{x,y} to the
 *  window size in pixels.
 */
int AMIGA_init(void)
{
int               gx,gy;			/* getprefposandsize x,y	*/
int               gxs,gys;			/* getprefposandsize xs,ys	*/
struct Screen    *wbscreen=NULL;
struct NewScreen *newscreen=NULL;
struct NewWindow *newwindow=NULL;

Enable_Abort=0;

/* don't let user initialize twice (or more!) */
if(IntuitionBase) {
	printf("***warning*** AMIGA_init: attempt to initialize twice!\n");
	return 0;
	}

/* allocate some memory needed for the ConsoleDevice */
vogl_cd_ioreq= (struct IOStdReq *)
  AllocMem(sizeof(struct IOStdReq),MEMTYPE);
if(!vogl_cd_ioreq) {
	AMIGA_exit();
	printf("***warning*** unable to allocate a IOStdReq\n");
	goto initproblem;
	}

/* open Intuition */
IntuitionBase= (struct IntuitionBase *)
  OpenLibrary((UBYTE *) "intuition.library",INTUITION_REV);
if(IntuitionBase == NULL) {
	AMIGA_exit();
	printf("***warning*** unable to open Intuition Library\n");
	goto initproblem;
	}

/* open Graphics */
GfxBase= (struct GfxBase *)
  OpenLibrary((UBYTE *) "graphics.library",INTUITION_REV);
if(GfxBase == NULL) {
	AMIGA_exit();
	printf("***warning*** unable to open Graphics Library\n");
	goto initproblem;
	}

/* open DiskFont */
DiskfontBase= (struct DiskFontBase *)
  OpenLibrary((UBYTE *) "diskfont.library",0L);
if(DiskfontBase == NULL) {
	AMIGA_exit();
	printf("***warning*** unable to open DiskFont library\n");
	goto initproblem;
	}

/* open ConsoleDevice */
if(OpenDevice((UBYTE *) "console.device",-1L,(struct IORequest *) vogl_cd_ioreq,0L) != 0) {
	AMIGA_exit();
	printf("***warning*** unable to open DiskFont library\n");
	goto initproblem;
	}
ConsoleDevice= (struct Library *) vogl_cd_ioreq->io_Device;

/* determine screen width and height from screenviewmode */

#ifdef USESVMODE

/* this code uses screenviewmode by itself, setting up standard
 * height and width
 */
scrwidth= 640;
if( (screenviewmode & HAM)   ||
   !(screenviewmode & HIRES) ||
    (screenviewmode & EXTRA_HALFBRITE)) scrwidth= 320;
scrheight= 200;
if(screenviewmode & LACE) scrheight= 400;

#else

/* lock WorkBench screen and query it for its dimensions */
wbscreen= LockPubScreen((UBYTE *) "Workbench");
if(wbscreen) {
	scrheight= wbscreen->Height;
	scrwidth = wbscreen->Width;

	
	if     ( (wbscreen->ViewPort.Modes & LACE)  && !(screenviewmode & LACE))  scrheight/= 2;
	else if(!(wbscreen->ViewPort.Modes & LACE)  &&  (screenviewmode & LACE))  scrheight*= 2;
	if     ( (wbscreen->ViewPort.Modes & HIRES) && !(screenviewmode & HIRES)) scrwidth /= 2;
	else if(!(wbscreen->ViewPort.Modes & HIRES) &&  (screenviewmode & HIRES)) scrwidth *= 2;

	voglscrbordtop  = wbscreen->WBorTop + wbscreen->Font->ta_YSize + 1;
	UnlockPubScreen(NULL,wbscreen);
	}
else voglscrbordtop= 0;
#endif

/* allocate a NewScreen in CHIP memory */
newscreen= AllocMem(sizeof(struct NewScreen),MEMTYPE);
if(!newscreen) {
	AMIGA_exit();
	printf("***warning*** unable to allocate a NewScreen\n");
	goto initproblem;
	}

/* set up both front and back BitMaps.  Note that Vogl signals
 * use of double buffering after this function is called
 * (the doublebuffer() function calls AMIGA_backbuffer
 * which begins backbuffering)
 */
voglfront= makeBitMap();
if(!voglfront) {
	AMIGA_exit();
	printf("***warning*** unable to allocate front BitMap\n");
	goto initproblem;
	}

voglback= makeBitMap();
if(!voglback) {
	AMIGA_exit();
	printf("***warning*** unable to allocate back BitMap\n");
	goto initproblem;
	}

/* initialize NewScreen */
newscreen->LeftEdge    = 0;
newscreen->TopEdge     = 0;
newscreen->Width       = scrwidth;
newscreen->Height      = scrheight;
newscreen->Depth       = scrdepth;
newscreen->DetailPen   = 1;
newscreen->BlockPen    = 0;
newscreen->ViewModes   = screenviewmode;
newscreen->Type        = CUSTOMSCREEN|CUSTOMBITMAP|SCREENQUIET;
newscreen->Font        = (struct TextAttr *) NULL;
newscreen->DefaultTitle= (UBYTE *) NULL;
newscreen->CustomBitMap= voglfront;

voglscreen             = OpenScreen(newscreen);
FreeMem(newscreen,sizeof(struct NewScreen));
if(!voglscreen) {
	AMIGA_exit();
	printf("***warning*** unable to open a Screen\n");
	goto initproblem;
	}

/* allocate and initialize a window */
newwindow= AllocMem((LONG) sizeof(struct NewWindow),MEMTYPE);
if(!newwindow) {
	AMIGA_exit();
	printf("***warning*** unable to allocate a NewWindow\n");
	goto initproblem;
	}

/* get user-specified initial window position and size
 *  The user specifies these parameters with
 *
 *  prefposition(long x,long y)
 *  prefsize(long xs,long ys)
 *
 * *prior* to calling winopen() or ginit().
 * Vogl initializes gx, gy, gxs, gys to -1
 */
getprefposandsize(&gx,&gy,&gxs,&gys);
if(gx  < 0 || scrwidth  < gx)  gx = 0;
if(gy  < 0 || scrheight < gy)  gy = 0;
if(gxs < 0 || scrwidth  < gxs) gxs= scrwidth;
if(gys < 0 || scrheight < gys) gys= scrheight;

/* the amiga driver's standard window */
newwindow->LeftEdge   = (SHORT) gx;
newwindow->TopEdge    = (SHORT) gy;
newwindow->Width      = (SHORT) gxs;
newwindow->Height     = (SHORT) gys;
newwindow->DetailPen  = (UBYTE) -1;
newwindow->BlockPen   = (UBYTE) -1;
newwindow->IDCMPFlags = (ULONG) IDCMP_MOUSEBUTTONS | IDCMP_RAWKEY;
newwindow->Flags      = REPORTMOUSE | ACTIVATE | RMBTRAP;
newwindow->FirstGadget= (struct Gadget *) NULL;
newwindow->CheckMark  = (struct Image *) NULL;
newwindow->Title      = (UBYTE *) NULL;
newwindow->Screen     = voglscreen;
newwindow->BitMap     = voglfront;
newwindow->MinWidth   =  0;
newwindow->MinHeight  =  0;
newwindow->MaxHeight  = ~0;
newwindow->MaxWidth   = ~0;
newwindow->Type       = CUSTOMSCREEN;

/* configuration modifications */
if(!useborder) newwindow->Flags|= BORDERLESS;
else {
	int Yfont;
	if(vdevice.wintitle && vdevice.wintitle[0]) {
		newwindow->Title= (UBYTE *) vdevice.wintitle;
		}
	Yfont             = voglscreen->Font? voglscreen->Font->ta_YSize : 0;
	voglscrbordtop    = voglscreen->WBorTop + Yfont + 1;
	voglscrbordbttm   = voglscreen->WBorBottom;
	voglscrbordleft   = voglscreen->WBorLeft;
	voglscrbordright  = voglscreen->WBorRight;
	}

/* open the window */
voglwindow= OpenWindow(newwindow);
FreeMem(newwindow,sizeof(struct NewWindow));
if(!voglwindow) {
	AMIGA_exit();
	printf("***warning*** unable to allocate a NewWindow\n");
	goto initproblem;
	}

/* set voglrastport up */
voglrastport               = &voglscreen->RastPort;
voglscreen->RastPort.BitMap= voglscreen->ViewPort.RasInfo->BitMap=
  (scrbufmode == DBLBUFMODE)? voglback : voglfront;

/* initialize areaBuffer (5 bytes, not words, per vertex) */
voglareaBuffer= (WORD *) AllocMem((LONG) 5*MAXVRTX,MEMTYPE);
if(!voglareaBuffer) {
	AMIGA_exit();
	printf("***warning*** unable to initialize areaBuffer for %d vertices\n",MAXVRTX);
	goto initproblem;
	}

voglrastport->AreaInfo= (struct AreaInfo *)
  AllocMem((LONG) sizeof(struct AreaInfo),MEMTYPE);
if(!voglrastport->AreaInfo) {
	AMIGA_exit();
	printf("***warning*** unable to initialize areaInfo\n");
	goto initproblem;
	}
InitArea(voglrastport->AreaInfo,voglareaBuffer,MAXVRTX);

/* initialize a TmpRas */
vogltmpras= (struct TmpRas *)
  AllocMem((LONG) sizeof(struct TmpRas),MEMTYPE);
if(!vogltmpras) {
	AMIGA_exit();
	printf("***warning*** unable to allocate a TmpRas\n");
	goto initproblem;
	}

voglplaneptr= (PLANEPTR) AllocRaster(scrwidth,scrheight);
if(voglplaneptr) {
	voglrastport->TmpRas= (struct TmpRas *)
	  InitTmpRas(vogltmpras,voglplaneptr,RASSIZE(scrwidth,scrheight));
	}
else {
	AMIGA_exit();
	printf("***warning*** unable to allocate a %dx%d raster for TmpRas\n",
	  scrwidth,scrheight);
	goto initproblem;
	}


/* don't outline area fills with the OPen (outline color pen) */
BNDRYOFF(voglrastport);

/* set up strings and fonts */
voglitext   = (struct IntuiText *) AllocMem((LONG) sizeof(struct IntuiText),MEMTYPE);
voglstring  = (UBYTE *)            AllocMem((LONG) MAXSTRING*sizeof(UBYTE),MEMTYPE);
vogltextattr= (struct TextAttr *)  AllocMem((LONG) sizeof(struct TextAttr),MEMTYPE);

/* optionally set up double buffering via AMIGA_backbuffer() */
if(scrbufmode == DBLBUFMODE) AMIGA_backbuffer();

/* initial rawkey buffer allocation */
if(!rawkeybuf) {
	qtyrawkeybuf= RAWKEYBUF;
	rawkeybuf   = (char *) AllocMem(qtyrawkeybuf,MEMTYPE);

	if(!rawkeybuf) {	/* terminate on no buffer */
		AMIGA_exit();
		printf("***warning*** unable to allocate a %ld byte buffer for rawkeys\n",
		  qtyrawkeybuf);
		goto initproblem;
		}
	}

/* allocate an InputEvent */
voglievent= (struct InputEvent *) AllocMem(sizeof(struct InputEvent),MEMTYPE);
if(!voglievent) {
	AMIGA_exit();
	printf("***warning*** unable to allocate an InputEvent\n");
	goto initproblem;
	}

/* initialize vogl screensize variables*/
vdevice.sizeSx= scrwidth  - 1;		/* x: upper right corner	*/
vdevice.sizeSy= scrheight - 1;		/* y: upper right corner	*/
vdevice.depth = scrdepth;			/* z: qty bitplanes			*/
vdevice.sizeX = vdevice.sizeY= (scrheight < scrwidth)? scrheight : scrwidth;

/* initialize the colormap */
AMIGA_mapcolor(0, 0, 0, 0);			/* black					*/
AMIGA_mapcolor(1,15, 0, 0);			/* red						*/
if(scrdepth >= 2) {
	AMIGA_mapcolor(2, 0,15, 0);		/* green					*/
	AMIGA_mapcolor(3,15,15, 0);		/* yellow					*/
	if(scrdepth >= 3) {
		int icolor;
		AMIGA_mapcolor(4, 0, 0,15);	/* blue						*/
		AMIGA_mapcolor(5,15, 0,15);	/* magenta					*/
		AMIGA_mapcolor(6, 0,15,15);	/* cyan						*/
		AMIGA_mapcolor(7,15,15,15);	/* white					*/

		/* make the rest, if any, black */
		for(icolor= 8; icolor < (1<<scrdepth); ++icolor)
		  AMIGA_mapcolor(icolor,0,0,0);
		}
	}

return 1;

initproblem:
return 0;
}

/* -------------------------------------------------------------------------- */

/* makeBitMap: this function sets up one bitmap.  Double buffering, of
 * course, requires two bitmaps.
 */
static struct BitMap *makeBitMap(void)
{
int            idepth;
struct BitMap *bitmap=NULL;

/* allocate BitMap itself */
bitmap= AllocMem((LONG) sizeof(struct BitMap),MEMTYPE);

if(bitmap) {
	InitBitMap(bitmap,(LONG) scrdepth,(LONG) scrwidth,(LONG) scrheight);

	for(idepth= 0; idepth < scrdepth; ++idepth) {
		bitmap->Planes[idepth]= (PLANEPTR) AllocRaster(scrwidth,scrheight);
		if(!bitmap->Planes[idepth]) {	/* unable to get enough memory */
			for(--idepth; idepth >= 0; --idepth)
			  FreeRaster(bitmap->Planes[idepth],scrwidth,scrheight);
			FreeMem(bitmap,(LONG) sizeof(struct BitMap));
			break;
			}
		BltClear(bitmap->Planes[idepth],(scrwidth>>3)*scrheight,1);
		}
	}

return bitmap;
}

/* -------------------------------------------------------------------------- */

/* freeBitMap: this function frees up memory used by a BitMap */
void freeBitMap(struct BitMap *bitmap)
{
int idepth;

for(idepth= scrdepth-1; idepth >= 0; --idepth) {
	FreeRaster(bitmap->Planes[idepth],scrwidth,scrheight);
	}
FreeMem(bitmap,(LONG) sizeof(struct BitMap));
}

/* -------------------------------------------------------------------------- */

/* AMIGA_exit: cleans up before returning the window to normal
 *  Note: I've designed this driver so that it can be re-opened.
 */
int AMIGA_exit(void)
{
FontList *prvfontlist;

/* clear back screen */
if(voglscreen) SetRast(&(voglscreen->RastPort),(unsigned long) 0);

/* close open Fonts and clean up memory use */
while(fontlisthd) {
	CloseFont(fontlisthd->textfont);
	free((char *) fontlisthd->fontspec);
	fontlisthd->textfont= NULL;
	fontlisthd->fontspec= NULL;
	prvfontlist         = fontlisthd;
	fontlisthd          = fontlisthd->nxt;
	free((char *) prvfontlist);
	}
fontlisthd= NULL;

/* free up rawkey buffer */
if(voglievent) FreeMem(voglievent,sizeof(struct InputEvent));
if(rawkeybuf)  FreeMem(rawkeybuf,qtyrawkeybuf);

if(vogltextattr->ta_Name) {
	int slen;
	slen= strlen((char *) vogltextattr->ta_Name);
	if(slen & 1) ++slen;
	FreeMem(vogltextattr->ta_Name,slen*sizeof(char));
	vogltextattr->ta_Name= NULL;
	}
if(vogltextattr) FreeMem(vogltextattr,sizeof(struct TextAttr));
if(voglstring)   FreeMem(voglstring,MAXSTRING*sizeof(UBYTE));
if(voglitext)    FreeMem(voglitext,sizeof(struct IntuiText));
vogltextattr= NULL;
voglstring  = NULL;
voglitext   = NULL;

if(voglplaneptr) {
	FreeRaster(voglplaneptr,scrwidth,scrheight);
	voglplaneptr= NULL;
	}

if(vogltmpras) {
	FreeMem(vogltmpras,sizeof(struct TmpRas));
	}
voglrastport->TmpRas= vogltmpras= NULL;

if(voglrastport->AreaInfo) {
	FreeMem(voglrastport->AreaInfo,sizeof(struct AreaInfo));
	}
voglrastport->AreaInfo= NULL;

if(voglareaBuffer) {
	FreeMem(voglareaBuffer,5*MAXVRTX);
	}
voglareaBuffer= NULL;

if(voglwindow) {
	CloseWindow(voglwindow);
	}
voglwindow= NULL;

if(voglscreen) {
	CloseScreen(voglscreen);
	}
voglscreen= NULL;

/* free up BitMaps */
if(voglback)  freeBitMap(voglback);
if(voglfront) freeBitMap(voglfront);
voglfront= voglback= NULL;

/* close down Libraries */
if(ConsoleDevice) {
	CloseDevice((struct IORequest *) vogl_cd_ioreq);
	}
ConsoleDevice= NULL;
if(DiskfontBase) {
	CloseLibrary((struct Library *) DiskfontBase);
	}
DiskfontBase= NULL;
if(GfxBase) {
	CloseLibrary((struct Library *) GfxBase);
	}
GfxBase= NULL;
if(IntuitionBase) {
	CloseLibrary((struct Library *) IntuitionBase);
	}
IntuitionBase= NULL;

/* free up memory for Console Device */
if(vogl_cd_ioreq) {
	FreeMem(vogl_cd_ioreq,sizeof(struct IOStdReq));
	}
vogl_cd_ioreq= NULL;

return 0;
}

/* -------------------------------------------------------------------------- */

/* AMIGA_draw: draws a line from the current graphics position to (x, y) */
void AMIGA_draw(
  int x,
  int y)
{
Move(voglrastport,vdevice.cpVx,vdevice.sizeSy - vdevice.cpVy);
Draw(voglrastport,x,vdevice.sizeSy - y);
}

/* -------------------------------------------------------------------------- */

/* AMIGA_getkey: grab a character from the keyboard
 *  (empties voglkeybuf)
 */
int AMIGA_getkey(void)
{
int   key;
int   mb,wx,wy;		/* to make AMIGA_locator happy */
int   newikeybgn;
ULONG signals;

newikeybgn= ikeybgn + 1;
if(newikeybgn >= KEYBUF) newikeybgn= 0;

if(newikeybgn != ikeyend) {
	/* update ikeybgn index and get key from voglkeybuf */
	ikeybgn= newikeybgn;
	key    = voglkeybuf[ikeybgn];
	}

else {

	/* block until a key is hit */
	do {
		signals= Wait(1L << voglwindow->UserPort->mp_SigBit);
		if(signals & (1L << voglwindow->UserPort->mp_SigBit)) {
			mb= AMIGA_locator(&wx,&wy);
			}
		} while(newikeybgn == ikeyend);

	/* update ikeybgn index and get key from voglkeybuf */
	ikeybgn= newikeybgn;
	key    = voglkeybuf[ikeybgn];
	}

return key;
}

/* -------------------------------------------------------------------------- */

/* AMIGA_checkkey: Check if a keyboard key has been hit. If so return it
 *  Otherwise, return 0.  Note: this function does actually read the
 *  key (ie. remove it from the buffer) if one has been hit.  That's
 *  the way the qread/qtest functions like it.
 */
int AMIGA_checkkey(void)
{
int key;
int mb,wx,wy;		/* to make AMIGA_locator happy */
int newikeybgn;


/* fill up rawkeybuf with any pending key hits */
mb = AMIGA_locator(&wx,&wy);

newikeybgn= ikeybgn + 1;
if(newikeybgn >= KEYBUF) newikeybgn= 0;
if(newikeybgn != ikeyend) {
	ikeybgn= newikeybgn;
	key    = voglkeybuf[ikeybgn];
	}
else key= 0;

return key;
}

/* -------------------------------------------------------------------------- */

/* AMIGA_handlekey: this function handles RAWKEYs  (fills up voglkeybuf)
 *     voglkeybuf                                      voglkeybuf
 *   |uuuddddddduuuuu|    u=unused  d=data            |ddddduuuuuuudd|
 *      ^       ^                                           ^     ^
 *   ikeybgn    ikeyend   (always point to unused)     ikeyend    ikeybgn
 */
static void AMIGA_handlekey(struct IntuiMessage *Imsg)
{
int      dbl=0;
LONG     numchars;
unsigned newikeyend;

/* convert rawkey message into a vanilla key */
do {
	voglievent->ie_Class           = IECLASS_RAWKEY;
	voglievent->ie_Code            = Imsg->Code;
	voglievent->ie_Qualifier       = Imsg->Qualifier;
	voglievent->ie_position.ie_addr= *((APTR*) Imsg->IAddress);

	numchars= RawKeyConvert(voglievent,(STRPTR) rawkeybuf,qtyrawkeybuf-1,NULL);
	dbl    = numchars == -1 && !rawkeybuf[0];

	if(dbl) {	/* double size of rawkeybuf to enable conversion */
		FreeMem(rawkeybuf,qtyrawkeybuf);
		qtyrawkeybuf<<= 1;
		rawkeybuf     = AllocMem(qtyrawkeybuf,MEMTYPE);
		if(!rawkeybuf) {	/* unable to double rawkey buffer! */
			qtyrawkeybuf= 0;
			AMIGA_exit();
			}
		}
	} while(dbl);

/* numchars contains the number of characters placed within the rawkeybuf.
 * Key up events and key sequences which do not generate any data for the
 * program (deadkeys, already intercepted sequences, etc) will return zero.
 *
 * Special keys (HELP, cursor keys, FKeys, etc) return multiple characters
 * that have to be parsed below.
 *
 * There are a number of qualifiers available, most of which are currently
 * being ignored by this vogl-amiga driver.  However, for reference purposes:
 *
 * (Imsg->Code & 0x80)? key-up : key-down
 * 
 *  Imsg->Qualifier can be "anded" with
 * 
 *    IEQUALIFIER_CAPSLOCK       IEQUALIFIER_LSHIFT         IEQUALIFIER_RBUTTON       
 *    IEQUALIFIER_CONTROL        IEQUALIFIER_MIDBUTTON      IEQUALIFIER_RCOMMAND      
 *    IEQUALIFIER_INTERRUPT      IEQUALIFIER_MULTIBROADCAST IEQUALIFIER_RELATIVEMOUSE 
 *    IEQUALIFIER_LALT           IEQUALIFIER_NUMERICPAD     IEQUALIFIER_REPEAT        
 *    IEQUALIFIER_LCOMMAND       IEQUALIFIER_RALT           IEQUALIFIER_RSHIFT        
 *    IEQUALIFIER_LEFTBUTTON     
 */

/* key is pressed down */
if(!(Imsg->Code & 0x80)) {

	/* handlekey only accepts alphameric (assumed to be caps), numeric, and unshifted
	 * punctuation.  Report sequences (function keys, help, cursor keys, etc) are
	 * ignored!
	 */
	newikeyend= ikeyend + 1;
	if(newikeyend >= KEYBUF) newikeyend= 0;
	
	if(newikeyend != ikeybgn && rawkeybuf[0] != 0x9b) {	/* 0x9b is a report sequence */
		if     (islower(rawkeybuf[0]))   rawkeybuf[0]= toupper(rawkeybuf[0]);	/* lower -> upper	*/
		else if(rawkeybuf[0] == '\177')  rawkeybuf[0]= '\020';					/* DEL key mapping	*/
		voglkeybuf[ikeyend]= rawkeybuf[0];
		ikeyend            = newikeyend;
		}
	}
}

/* --------------------------------------------------------------------- */

/* AMIGA_locator:
 *	return the window location of the cursor,
 *  plus which mouse button, if any, has been pressed.
 *
 * Bit   0     1      2    is 1 when button is pressed down
 *     |left|middle|right| is 0 when button is released
 */
int AMIGA_locator(
  int *wx,
  int *wy)
{
int                  mb  = 0;
struct Message      *Mmsg= NULL;
struct IntuiMessage *Imsg= NULL;

/* get current mouse position */
*wx= voglwindow->MouseX;
*wy= vdevice.sizeSy - voglwindow->MouseY;

while(Mmsg= GetMsg(voglwindow->UserPort)) {
	Imsg= (struct IntuiMessage *) Mmsg;

	switch(Imsg->Class) {

	case IDCMP_MOUSEBUTTONS:

		switch(Imsg->Code) {

		case SELECTDOWN:	/* left   mouse pressed		*/
			mb|= 01;
			break;

		case SELECTUP:		/* left   mouse released	*/
			mb&= ~01;
			break;

		case MIDDLEDOWN:	/* middle mouse pressed		*/
			mb|= 02;
			break;

		case MIDDLEUP:		/* middle mouse released	*/
			mb&= ~02;
			break;

		case MENUDOWN:		/* right  mouse pressed		*/
			mb|= 04;
			break;

		case MENUUP:		/* right  mouse released	*/
			mb&= ~04;
			break;

		default:
			break;
			}
		break;

	case IDCMP_RAWKEY:		/* a key was hit/released	*/
		AMIGA_handlekey(Imsg);
		break;

	default:				/* unsupported Intuimessage	*/
		break;
		}

	ReplyMsg(Mmsg);
	}

return mb;
}

/* -------------------------------------------------------------------------- */

/* AMIGA_clear: Clear the screen to current color */
void AMIGA_clear(void)
{
SetRast(voglrastport,(unsigned long) currcolor);
}

/* -------------------------------------------------------------------------- */

/* AMIGA_color: set the current drawing color index */
void AMIGA_color(int icolor)
{
currcolor= icolor;				/* used by string/char rendering */
SetAPen(voglrastport,icolor);
}

/* -------------------------------------------------------------------------- */

/* AMIGA_mapcolor: change index icolor in the color map to the appropriate
 *  r, g, b, value.
 */
void AMIGA_mapcolor(
  int icolor,
  int r,
  int g,
  int b)
{
if(icolor >= (1<<scrdepth)) {
	return;
	}

SetRGB4(&voglscreen->ViewPort,
  (long)          icolor,
  (unsigned long) r,
  (unsigned long) g,
  (unsigned long) b);
}

/* -------------------------------------------------------------------------- */

/* AMIGA_font: Set up a hardware font. Return 1 on success 0 otherwise
 *  I have come up with a little convention for the fontspec:
 *	fontname;height[;{BEIPU}]
 *   B == bold
 *   E == extended
 *   I == italic
 *   P == plain (default)
 *   U == underlined
 *
 *  Returns: 0=failure-to-open
 *           1=successful font open
 */
int AMIGA_font(char *fontspec)
{
char             type='P';		/* font spec type			*/
char            *fsh;			/* ptr to font spec height	*/
char            *fst;			/* ptr to font spec type	*/
int              h;				/* height					*/
int              slen;			/* length of fontname		*/
FontList        *fontlist    = NULL;
struct TextFont *vogltextfont= NULL;
static FontList *oldfontlist = NULL;

/* check over FontList for fontspec */
for(fontlist= fontlisthd; fontlist; fontlist= fontlist->nxt) {

	if(!strcmp(fontlist->fontspec,fontspec)) {
	
		if(fontlist == oldfontlist) {	/* font unchanged! */
			return;
			}

		vdevice.hheight= fontlist->textfont->tf_YSize;
		vdevice.hwidth = fontlist->textfont->tf_XSize;
	
		/* set the font */
		SetFont(voglrastport,fontlist->textfont);
		oldfontlist= fontlist;
		return 1;
		}
	}

/* get font-separator pointers */
fsh                   = strchr(fontspec,FONTSEP);	/* nominal font height		*/
fst                   = strchr(fsh+1,FONTSEP);		/* type of font				*/
vogltextattr->ta_Style= (UBYTE) 0;					/* default style == plain	*/
vogltextattr->ta_Flags= (UBYTE) 0;					/* default style == plain	*/

if(fsh) {
	sscanf(fsh+1,"%hu",&vogltextattr->ta_YSize);
	*fsh= '\0';

	if(fst) {
		for(++fst; *fst; ++fst) switch(*fst) {

		case 'B':	/* bold */
		case 'b':
			vogltextattr->ta_Style|= FSF_BOLD;
			break;

		case 'E':	/* extended (extra wide) */
		case 'e':
			vogltextattr->ta_Style|= FSF_EXTENDED;
			break;

		case 'I':	/* italic */
		case 'i':
			vogltextattr->ta_Style|= FSF_ITALIC;
			break;

		case 'P':	/* plain */
		case 'p':
			break;

		case 'U':	/* underlined */
		case 'u':
			vogltextattr->ta_Style|= FSF_UNDERLINED;
			break;

		default:	/* ignored */
			break;
			}
		}
	}
else vogltextattr->ta_YSize= 11L;			/* default height == 11 pts	*/

/* free up old ta_Name */
if(vogltextattr->ta_Name) {
	slen= strlen((char *) vogltextattr->ta_Name);
	if(slen & 1) ++slen;
	FreeMem(vogltextattr->ta_Name,slen*sizeof(char));
	vogltextattr->ta_Name= NULL;
	}
slen= strlen(fontspec) + 6;
if(slen & 1) ++slen;
vogltextattr->ta_Name= (STRPTR) AllocMem((LONG) slen*sizeof(char),MEMTYPE);
sprintf((char *) vogltextattr->ta_Name,"%s.font",fontspec);

if(fsh) *fsh= FONTSEP;							/* restore *fsh			*/


/* attempt to open requested font */
vogltextfont= OpenDiskFont(vogltextattr);		/* open the font		*/
if(vogltextfont) {
	SetFont(voglrastport,vogltextfont);			/* set the font			*/

	/* set up FontList */
	head_link(FontList,fontlisthd,"FontList");
	stralloc(fontlisthd->fontspec,fontspec,"fontspec");
	fontlisthd->textfont= vogltextfont;
	oldfontlist         = fontlisthd;
	vdevice.hheight     = fontlisthd->textfont->tf_YSize;
	vdevice.hwidth      = fontlisthd->textfont->tf_XSize;
	}
else {	/* failure to open requested font */
	vdevice.hheight= 0;
	vdevice.hwidth = 0;
	return 0;
	}

return 1;
}

/* -------------------------------------------------------------------------- */

/* AMIGA_char: outputs one char */
void AMIGA_char(char c)
{
char s[2];

s[0]= c;
s[1]= '\0';
AMIGA_string(s);
}

/* -------------------------------------------------------------------------- */

/* AMIGA_string: Display a string at the current drawing position */
void AMIGA_string(char *s)
{
/* set up the IntuiText */
voglitext->FrontPen = (UBYTE) currcolor;	/* set text's foreground color		*/
voglitext->BackPen  = (UBYTE) 0;			/* background color ignored			*/
voglitext->DrawMode = JAM1;					/* just use fgd color				*/

voglitext->LeftEdge = vdevice.cpVx;			/* set x position					*/
/* set y position			*/
voglitext->TopEdge  = vdevice.sizeSy - vdevice.cpVy - vdevice.hheight;

voglitext->ITextFont= NULL;					/* use default font					*/
strcpy((char *) voglstring,s);				/* copy user's string to voglstring	*/
voglitext->IText    = voglstring;			/* print out voglstring				*/
voglitext->NextText = NULL;					/* no next text						*/

PrintIText(voglrastport,voglitext,0L,0L);	/* use printIText to render			*/
}

/* -------------------------------------------------------------------------- */

/* AMIGA_fill: fill a polygon */
void AMIGA_fill(
  int  n,
  int *x,
  int *y)
{
int ifill;
int result;

if(AreaMove(voglrastport,(long) x[0],(long) vdevice.sizeSy - y[0]) < 0) {
	printf("***warning*** unable to fill polygon with %d vertices\n",n);
	return;
	}

for(ifill= 1; ifill < n; ++ifill) {
	if(AreaDraw(voglrastport,(long) x[ifill],(long) vdevice.sizeSy - y[ifill]) < 0) {
		printf("***warning*** unable to fill polygon with %d vertices\n",n);
		return;
		}
	}

AreaEnd(voglrastport);

vdevice.cpVx = x[n - 1];
vdevice.cpVy = y[n - 1];
}

/* -------------------------------------------------------------------------- */

/* AMIGA_backbuffer: draw in back buffer, display front
 *  Returns 0=success
 *         -1=failure
 */
int AMIGA_backbuffer(void)
{
if(scrbufmode == SNGLBUFMODE) {	/* begin double buffer mode */
	scrbufmode                 = DBLBUFMODE;
	voglscreen->RastPort.BitMap= voglscreen->ViewPort.RasInfo->BitMap= voglback;
	voglscreen->RastPort.Flags = DBUFFER;
	}

if(voglback && voglscreen->RastPort.BitMap != voglback) {
	MakeScreen(voglscreen);	/* make screen's new copper list			*/
	RethinkDisplay();		/* combine copper lists into single View	*/
	voglscreen->RastPort.BitMap= voglscreen->ViewPort.RasInfo->BitMap= voglback;
	voglwindow->RPort->BitMap  = voglback;
	}

return 0;
}

/* -------------------------------------------------------------------------- */

/* AMIGA_swapbuffer: swap the front and back buffers */
int AMIGA_swapbuffer(void)
{
struct BitMap *voglswap;

if(!voglback || scrbufmode != DBLBUFMODE) {
	return 0;
	}

/* display back buffer */
MakeScreen(voglscreen);	/* make screen's new copper list			*/
RethinkDisplay();		/* combine copper lists into single View	*/

/* swap front and back BitMap buffers */
voglswap                   = voglfront;
voglfront                  = voglback;
voglback                   = voglswap;
voglscreen->RastPort.BitMap= voglscreen->ViewPort.RasInfo->BitMap= voglback;
voglwindow->RPort->BitMap  = voglback;

return 0;
}

/* -------------------------------------------------------------------------- */

/* AMIGA_frontbuffer: draw in the front buffer */
void AMIGA_frontbuffer(void)
{
voglscreen->RastPort.BitMap= voglscreen->ViewPort.RasInfo->BitMap= voglfront;
voglwindow->RPort->BitMap  = voglfront;
}

/* --------------------------------------------------------------------------
 * _AMIGA_devcpy
 *
 *	copy the amiga device into vdevice.dev.
 */
void _AMIGA_devcpy(void)
{
vdevice.dev= amigadev;
}

/* ==========================================================================
 * Source Code:
 *  The test code here exercises the amiga driver by itself and is not
 *  expected to be the "usual" way of using it.  The usual way is via
 *  standard vogl methods.
 */

/* --------------------------------------------------------------------- */

/* DT_title: this function sets up the window's title */
void DT_title(char *buf)
{
static char titlebuf[RAWKEYBUF];

strcpy(titlebuf,buf);
vdevice.wintitle= titlebuf;
}

/* --------------------------------------------------------------------- */

#ifdef SASC
void __regargs __checkabort (void)
{
/* empty */
}
#endif

/* --------------------------------------------------------------------- */
