#include <exec/exec.h>
#include <dos/dos.h>
#include <intuition/intuition.h>
#include <graphics/gfx.h>
#include <hardware/custom.h>
#include <hardware/dmabits.h>

#ifdef __MAXON__
#include <pragma/exec_lib.h>
#include <pragma/dos_lib.h>
#include <pragma/graphics_lib.h>
#include <pragma/intuition_lib.h>
#else
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#endif

#include <stdio.h>
#include <string.h>

#include "hardware.h"
#include "cop.h"
#include "map.h"


#define ARG_TEMPLATE "SPEED/S,NTSC/S,HOW/S,FMODE/N/K"
#define ARG_SPEED 0
#define ARG_NTSC  1
#define ARG_HOW   2
#define ARG_FMODE 3
#define NUM_ARGS  4

#define MAPNAME		"maps/race.raw"
#define BLOCKSNAME	"blocks/raceblocks.raw"

#define SCREENWIDTH  320
#define SCREENHEIGHT 256
#define EXTRAHEIGHT 32
#define SCREENBYTESPERROW (SCREENWIDTH / 8)

#define BITMAPWIDTH SCREENWIDTH
#define BITMAPBYTESPERROW (BITMAPWIDTH / 8)
#define BITMAPHEIGHT (SCREENHEIGHT + EXTRAHEIGHT)

#define BLOCKSWIDTH 320
#define BLOCKSHEIGHT 200
#define BLOCKSDEPTH 4
#define BLOCKSCOLORS (1L << BLOCKSDEPTH)
#define BLOCKWIDTH 16
#define BLOCKHEIGHT 16
#define BLOCKSBYTESPERROW (BLOCKSWIDTH / 8)
#define BLOCKSPERROW (BLOCKSWIDTH / BLOCKWIDTH)

#define NUMSTEPS BLOCKHEIGHT

#define BITMAPBLOCKSPERROW (BITMAPWIDTH / BLOCKWIDTH)
#define BITMAPBLOCKSPERCOL (BITMAPHEIGHT / BLOCKHEIGHT)

#define VISIBLEBLOCKSX (SCREENWIDTH / BLOCKWIDTH)
#define VISIBLEBLOCKSY (SCREENHEIGHT / BLOCKHEIGHT)

#define BITMAPPLANELINES (BITMAPHEIGHT * BLOCKSDEPTH)
#define BLOCKPLANELINES  (BLOCKHEIGHT * BLOCKSDEPTH)

#define DIWSTART 0x2981
#define DIWSTOP  0x29C1

#define PALSIZE (BLOCKSCOLORS * 2)
#define BLOCKSFILESIZE (BLOCKSWIDTH * BLOCKSHEIGHT * BLOCKSPLANES / 8 + PALSIZE)

// calculate how many times (steps) y-scrolling needs to
// blit two blocks instead of one block to make sure a
// complete row is blitted after 16 pixels of y-scrolling
//
// x * 2 + (16 - x) = BITMAPBLOCKSPERROW
// 2x + 16 - x = BITMAPBLOCKSPERROW
// x = BITMAPBLOCKSPERROW - 16

#define TWOBLOCKS (BITMAPBLOCKSPERROW - NUMSTEPS)
#define TWOBLOCKSTEP (NUMSTEPS - TWOBLOCKS)

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Screen *scr;
struct RastPort *ScreenRastPort;
struct BitMap *BlocksBitmap,*ScreenBitmap;
struct RawMap *Map;
UBYTE	 *frontbuffer,*blocksbuffer;

WORD	mapposy,videoposy;
WORD	bitmapheight;

LONG	mapwidth,mapheight;
UBYTE *mapdata;

UWORD	colors[BLOCKSCOLORS];

LONG	Args[NUM_ARGS];

BOOL	option_ntsc,option_how,option_speed;
WORD	option_fetchmode,bplmodulo;

BPTR	MyHandle;
char	s[256];

struct FetchInfo
{
	WORD	ddfstart;
	WORD	ddfstop;
	WORD	modulooffset;
} fetchinfo [] =
{
	{0x38,0xD0,0},	/* normal         */
	{0x38,0xC8,0}, /* BPL32          */
	{0x38,0xC8,0}, /* BPAGEM         */
	{0x38,0xB8,0}	/* BPL32 + BPAGEM */
};

/********************* MACROS ***********************/

#define ROUND2BLOCKHEIGHT(x) ((x) & ~(BLOCKHEIGHT - 1))

/************* SETUP/CLEANUP ROUTINES ***************/

static void Cleanup (char *msg)
{
	WORD rc;
	
	if (msg)
	{
		printf("Error: %s\n",msg);
		rc = RETURN_WARN;
	} else {
		rc = RETURN_OK;
	}

	if (scr) CloseScreen(scr);

	if (ScreenBitmap)
	{
		WaitBlit();
		FreeBitMap(ScreenBitmap);
	}

	if (BlocksBitmap)
	{
		WaitBlit();
		FreeBitMap(BlocksBitmap);
	}

	if (Map) FreeVec(Map);
	if (MyHandle) Close(MyHandle);

	if (GfxBase) CloseLibrary((struct Library *)GfxBase);
	if (IntuitionBase) CloseLibrary((struct Library *)IntuitionBase);

	exit(rc);
}

static void OpenLibs(void)
{
	if (!(IntuitionBase = (struct IntuitionBase *)OpenLibrary("intuition.library",39)))
	{
		Cleanup("Can't open intuition.library V39!");
	}
	
	if (!(GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",39)))
	{
		Cleanup("Can't open graphics.library V39!");
	}
}

static void GetArguments(void)
{
	struct RDArgs *MyArgs;

	if (!(MyArgs = ReadArgs(ARG_TEMPLATE,Args,0)))
	{
		Fault(IoErr(),0,s,255);
		Cleanup(s);
	}

	if (Args[ARG_SPEED]) option_speed = TRUE;
	if (Args[ARG_NTSC]) option_ntsc = TRUE;
	if (Args[ARG_HOW])
	{
		option_how = TRUE;
		option_speed = FALSE;
	}
	if (Args[ARG_FMODE])
	{
		option_fetchmode = *(LONG *)Args[ARG_FMODE];
	}

	FreeArgs(MyArgs);
	
	if (option_fetchmode < 0 || option_fetchmode > 3)
	{
		Cleanup("Invalid fetch mode. Must be 0 .. 3!");
	}

}

static void OpenMap(void)
{
	LONG l;

	if (!(MyHandle = Open(MAPNAME,MODE_OLDFILE)))
	{
		Fault(IoErr(),0,s,255);
		Cleanup(s);
	}
	
	Seek(MyHandle,0,OFFSET_END);
	l = Seek(MyHandle,0,OFFSET_BEGINNING);

	if (!(Map = AllocVec(l,MEMF_PUBLIC)))
	{
		Cleanup("Out of memory!");
	}
	
	if (Read(MyHandle,Map,l) != l)
	{
		Fault(IoErr(),0,s,255);
		Cleanup(s);
	}
	
	Close(MyHandle);MyHandle = 0;
	
	mapdata = Map->data;
	mapwidth = Map->mapwidth;
	mapheight = Map->mapheight;
}

static void OpenBlocks(void)
{
	LONG l;

	if (!(BlocksBitmap = AllocBitMap(BLOCKSWIDTH,
											   BLOCKSHEIGHT,
											   BLOCKSDEPTH,
											   BMF_STANDARD | BMF_INTERLEAVED,
											   0)))
	{
		Cleanup("Can't alloc blocks bitmap!");
	}
	
	if (!(MyHandle = Open(BLOCKSNAME,MODE_OLDFILE)))
	{
		Fault(IoErr(),0,s,255);
		Cleanup(s);
	}
	
	if (Read(MyHandle,colors,PALSIZE) != PALSIZE)
	{
		Fault(IoErr(),0,s,255);
		Cleanup(s);
	}
	
	l = BLOCKSWIDTH * BLOCKSHEIGHT * BLOCKSDEPTH / 8;
	
	if (Read(MyHandle,BlocksBitmap->Planes[0],l) != l)
	{
		Fault(IoErr(),0,s,255);
		Cleanup(s);
	}
	
	Close(MyHandle);MyHandle = 0;
	
	blocksbuffer = BlocksBitmap->Planes[0];
}

static void OpenDisplay(void)
{	
	struct DimensionInfo diminfo;
	DisplayInfoHandle		dih;
	ULONG						modeid;
	LONG						l;
	
	bitmapheight = BITMAPHEIGHT + 3;

	if (!(ScreenBitmap = AllocBitMap(BITMAPWIDTH,bitmapheight,BLOCKSDEPTH,BMF_STANDARD | BMF_INTERLEAVED | BMF_CLEAR,0)))
	{
		Cleanup("Can't alloc screen bitmap!");
	}
	frontbuffer = ScreenBitmap->Planes[0];
	
	if (!(TypeOfMem(ScreenBitmap->Planes[0]) & MEMF_CHIP))
	{
		Cleanup("Screen bitmap is not in CHIP RAM!?? If you have a gfx card try disabling \"planes to fast\" or similiar options in your RTG system!");
	}

	l = GetBitMapAttr(ScreenBitmap,BMA_FLAGS);
	
	if (!(GetBitMapAttr(ScreenBitmap,BMA_FLAGS) & BMF_INTERLEAVED))
	{
		Cleanup("Screen bitmap is not in interleaved format!??");
	}

	if (option_how)
	{
		modeid = INVALID_ID;

		if ((dih = FindDisplayInfo(VGAPRODUCT_KEY)))
		{
			if (GetDisplayInfoData(dih,(APTR)&diminfo,sizeof(diminfo),DTAG_DIMS,0))
			{
				if (diminfo.MaxDepth >= BLOCKSDEPTH) modeid = VGAPRODUCT_KEY;
			}
		}
		if (modeid == INVALID_ID)
		{
			if (option_ntsc)
			{
				modeid = NTSC_MONITOR_ID | HIRESLACE_KEY;
			} else {
				modeid = PAL_MONITOR_ID | HIRESLACE_KEY;
			}
		}	
	} else {
		if (option_ntsc)
		{
			modeid = NTSC_MONITOR_ID;
		} else {
			modeid = PAL_MONITOR_ID;
		}
	}

	if (!(scr = OpenScreenTags(0,SA_Width,BITMAPWIDTH,
										  SA_Height,bitmapheight,
										  SA_Depth,BLOCKSDEPTH,
										  SA_DisplayID,modeid,
										  SA_BitMap,ScreenBitmap,
										  option_how ? SA_Overscan : TAG_IGNORE,OSCAN_TEXT,
										  option_how ? SA_AutoScroll : TAG_IGNORE,TRUE,
										  SA_Quiet,TRUE,
										  TAG_DONE)))
	{
		Cleanup("Can't open screen!");
	}

	if (scr->RastPort.BitMap->Planes[0] != ScreenBitmap->Planes[0])
	{
		Cleanup("Screen was not created with the custom bitmap I supplied!??");
	}
	
	ScreenRastPort = &scr->RastPort;
	
	LoadRGB4(&scr->ViewPort,colors,BLOCKSCOLORS);
}

static void InitCopperlist(void)
{
	WORD	*wp,*wp2;
	ULONG	plane,plane2;
	LONG	l;

	WaitVBL();

	custom->dmacon = 0x7FFF;
	custom->beamcon0 = option_ntsc ? 0 : DISPLAYPAL;

	CopFETCHMODE[1] = option_fetchmode;
	
	// bitplane control registers

	CopBPLCON0[1] = ((BLOCKSDEPTH * BPL0_BPU0_F) & BPL0_BPUMASK) +
						 ((BLOCKSDEPTH / 8) * BPL0_BPU3_F) +
						 BPL0_COLOR_F +
						 (option_speed ? 0 : BPL0_USEBPLCON3_F);

	CopBPLCON1[1] = 0;

	CopBPLCON3[1] = BPLCON3_BRDNBLNK;

	// bitplane modulos

	l = BITMAPBYTESPERROW * BLOCKSDEPTH -
		 SCREENBYTESPERROW - fetchinfo[option_fetchmode].modulooffset;

	CopBPLMODA[1] = l;
	CopBPLMODB[1] = l;

	CopVIDEOSPLITRESETMODULO[1] = l;
	CopVIDEOSPLITRESETMODULO[3] = l;
	
	bplmodulo = l;

	// display window start/stop
	
	CopDIWSTART[1] = DIWSTART;
	CopDIWSTOP[1] = DIWSTOP;
	
	// display data fetch start/stop
	
	CopDDFSTART[1] = fetchinfo[option_fetchmode].ddfstart;
	CopDDFSTOP[1]  = fetchinfo[option_fetchmode].ddfstop;
	
	// plane pointers

	wp = CopPLANE1H;
	wp2 = CopPLANE2_1H;		//only hiwords here

	for(l = 0;l < BLOCKSDEPTH;l++)
	{
		plane = (ULONG)ScreenBitmap->Planes[l];
		
		wp[1] = plane >> 16;
		wp[3] = plane & 0xFFFF;

		wp2[1] = plane >> 16;

		wp += 4;wp2 += 2;
	}

	// Setup modulo trick
 
	plane = (ULONG)ScreenBitmap->Planes[0];

	plane2 = plane +
				(BITMAPHEIGHT - 1) * BITMAPBYTESPERROW * BLOCKSDEPTH +
				SCREENBYTESPERROW;

	l = (plane - plane2) & 0xFFFF;
	
	CopVIDEOSPLITMODULO[1] = l;
	CopVIDEOSPLITMODULO[3] = l;

	/**/

	custom->intena = 0x7FFF;
	
	custom->dmacon = DMAF_SETCLR | DMAF_BLITTER | DMAF_COPPER | DMAF_RASTER | DMAF_MASTER;

	custom->cop2lc = (ULONG)CopperList;	
};

/******************* SCROLLING **********************/

static void DrawBlock(LONG x,LONG y,LONG mapx,LONG mapy)
{
	UBYTE block;

	// x = in pixels
	// y = in "planelines" (1 realline = BLOCKSDEPTH planelines)

	x = (x / 8) & 0xFFFE;
	y = y * BITMAPBYTESPERROW;
	
	block = mapdata[mapy * mapwidth + mapx];

	mapx = (block % BLOCKSPERROW) * (BLOCKWIDTH / 8);
	mapy = (block / BLOCKSPERROW) * (BLOCKPLANELINES * BLOCKSBYTESPERROW);
	
	if (option_how) OwnBlitter();

	HardWaitBlit();
	
	custom->bltcon0 = 0x9F0;	// use A and D. Op: D = A
	custom->bltcon1 = 0;
	custom->bltafwm = 0xFFFF;
	custom->bltalwm = 0xFFFF;
	custom->bltamod = BLOCKSBYTESPERROW - (BLOCKWIDTH / 8);
	custom->bltdmod = BITMAPBYTESPERROW - (BLOCKWIDTH / 8);
	custom->bltapt  = blocksbuffer + mapy + mapx;
	custom->bltdpt	 = frontbuffer + y + x;
	
	custom->bltsize = BLOCKPLANELINES * 64 + (BLOCKWIDTH / 16);

	if (option_how) DisownBlitter();
}

static void FillScreen(void)
{
	WORD a,b,x,y;
	
	for (b = 0;b < BITMAPBLOCKSPERCOL;b++)
	{
		for (a = 0;a < BITMAPBLOCKSPERROW;a++)
		{
			x = a * BLOCKWIDTH;
			y = b * BLOCKPLANELINES;

			DrawBlock(x,y,a,b);
		}
	}
}

static void ScrollUp(void)
{
	WORD mapx,mapy,x,y;

	if (mapposy < 1) return;

	mapposy--;
	videoposy = mapposy % BITMAPHEIGHT;

	mapx = mapposy & (NUMSTEPS - 1);
	mapy = mapposy / BLOCKHEIGHT;
	
	y = ROUND2BLOCKHEIGHT(videoposy) * BLOCKSDEPTH;

   if (mapx < TWOBLOCKSTEP)
   {
   	// blit only one block
   	
   	x = mapx * BLOCKWIDTH;
   	
   	DrawBlock(x,y,mapx,mapy);
   	
   } else {
   	// blit two blocks
   	
   	mapx = TWOBLOCKSTEP + (mapx - TWOBLOCKSTEP) * 2;
   	x = mapx * BLOCKWIDTH;
   	
   	DrawBlock(x,y,mapx,mapy);
   	DrawBlock(x + BLOCKWIDTH,y,mapx + 1,mapy);
   	
   }
}

static void ScrollDown(void)
{
	WORD mapx,mapy,x,y;

	if (mapposy >= (mapheight * BLOCKHEIGHT - SCREENHEIGHT - BLOCKHEIGHT)) return;
	
	mapx = mapposy & (NUMSTEPS - 1);
	mapy = BITMAPBLOCKSPERCOL + mapposy / BLOCKHEIGHT;
	
	y = ROUND2BLOCKHEIGHT(videoposy) * BLOCKSDEPTH;

   if (mapx < TWOBLOCKSTEP)
   {
   	// blit only one block
   	
   	x = mapx * BLOCKWIDTH;
   	
   	DrawBlock(x,y,mapx,mapy);
   	
   } else {
   	// blit two blocks
   	
   	mapx = TWOBLOCKSTEP + (mapx - TWOBLOCKSTEP) * 2;
   	x = mapx * BLOCKWIDTH;
   	
   	DrawBlock(x,y,mapx,mapy);
   	DrawBlock(x + BLOCKWIDTH,y,mapx + 1,mapy);
   }

	mapposy++;
	videoposy = mapposy % BITMAPHEIGHT;
	
}

static void CheckJoyScroll(void)
{
	WORD i,count;
	
	if (JoyFire()) count = 8; else count = 1;

	if (JoyUp())
	{
		for(i = 0;i < count;i++)
		{
			ScrollUp();
		}
	}
	
	if (JoyDown())
	{
		for(i = 0;i < count;i++)
		{
			ScrollDown();
		}
	}
}

static void UpdateCopperlist(void)
{
	ULONG pl;
	LONG	planeadd;
	WORD	i,yoffset;
	WORD	*wp;

	yoffset = (videoposy + BLOCKHEIGHT) % BITMAPHEIGHT;
	planeadd = ((LONG)yoffset) * BITMAPBYTESPERROW * BLOCKSDEPTH;
	
	// set top plane pointers

	wp = CopPLANE1H;

	for(i = 0;i < BLOCKSDEPTH;i++)
	{
		pl = ((ULONG)ScreenBitmap->Planes[i]) + planeadd;
		
		wp[1] = (WORD)(pl >> 16);
		wp[3] = (WORD)(pl & 0xFFFF);
		
		wp += 4;
	}

	yoffset = BITMAPHEIGHT - yoffset;

	yoffset += (DIWSTART >> 8);
	
	/* CopVIDEOSPLIT must wait for line (yoffset -1 )
	   CopVIDEOSPLIT2 must wait for line (yoffset)    */

	if (yoffset <= 255)
	{
		CopVIDEOSPLIT[0] = 0x0001;
		CopVIDEOSPLIT[2] = (yoffset - 1) * 256 + 0x1;

		CopVIDEOSPLIT2[0] = 0x0001;
		CopVIDEOSPLIT2[2] = yoffset * 256 + 0x1;
	} else if (yoffset == 256)
	{
		CopVIDEOSPLIT[0] = 0x0001;
		CopVIDEOSPLIT[2] = 255 * 256 + 0x1;
		
		CopVIDEOSPLIT2[0] = 0xFFDF;
		CopVIDEOSPLIT2[2] = (256 - 256) * 256 + 0x1;
	} else {
		CopVIDEOSPLIT[0] = 0xFFDF;
		CopVIDEOSPLIT[2] = (yoffset - 256 - 1) * 256 + 0x1;
		
		CopVIDEOSPLIT2[0] = 0x001;
		CopVIDEOSPLIT2[2] = (yoffset - 256) * 256 + 0x1;
	}
}

static void MainLoop(void)
{
	if (!option_how)
	{
		// activate copperlist
		
		HardWaitBlit();
		WaitVBL();
		custom->copjmp2 = 0;
	}
	
	while (!LMBDown())
	{
		if (!option_how)
		{
			WaitVBeam(1);
			UpdateCopperlist();
			WaitVBeam(200);
		} else {
			Delay(1);
		}
		
		if (option_speed) *(WORD *)0xdff180 = 0xFF0;

		CheckJoyScroll();

		if (option_speed) *(WORD *)0xdff180 = 0xF00;
	}
}

/********************* MAIN *************************/

void main(void)
{
	OpenLibs();
	GetArguments();
	OpenMap();
	OpenBlocks();
	OpenDisplay();

	if (!option_how)
	{
		Delay(2*50);
		KillSystem();
		InitCopperlist();
	}
	FillScreen();
	
	MainLoop();
	
	if (!option_how)
	{
		ActivateSystem();
	}

	Cleanup(0);
	
}

