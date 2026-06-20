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

#define MAPNAME		"maps/scroller.raw"
#define BLOCKSNAME	"blocks/demoblocks.raw"

#define SCREENWIDTH  320
#define SCREENHEIGHT 256
#define EXTRAWIDTH  64
#define EXTRAHEIGHT 32
#define SCREENBYTESPERROW (SCREENWIDTH / 8)

#define BITMAPWIDTH (SCREENWIDTH + EXTRAWIDTH)
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

#define NUMSTEPS_X BLOCKWIDTH
#define NUMSTEPS_Y BLOCKHEIGHT

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

#define DIRECTION_IGNORE 0
#define DIRECTION_LEFT   1
#define DIRECTION_RIGHT  2

// calculate how many times (steps) y-scrolling needs to
// blit two blocks instead of one block to make sure a
// complete row is blitted after 16 pixels of y-scrolling
//
// x * 2 + (16 - x) = BITMAPBLOCKSPERROW
// 2x + 16 - x = BITMAPBLOCKSPERROW
// x = BITMAPBLOCKSPERROW - 16

#define TWOBLOCKS (BITMAPBLOCKSPERROW - NUMSTEPS_Y)
#define TWOBLOCKSTEP TWOBLOCKS

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Screen *scr;
struct RastPort *ScreenRastPort;
struct BitMap *BlocksBitmap,*ScreenBitmap;
struct RawMap *Map;
UBYTE	 *frontbuffer,*blocksbuffer;

WORD	mapposx,mapposy,videoposx,videoposy,block_videoposy;
WORD	mapblockx,mapblocky,stepx,stepy;
WORD	bitmapheight,bitplanemodulo;

WORD	*savewordpointer;
WORD	saveword;
BYTE	previous_xdirection;

LONG	mapwidth,mapheight;
UBYTE *mapdata;

UWORD	colors[BLOCKSCOLORS];

LONG	Args[NUM_ARGS];

BOOL	option_ntsc,option_how,option_speed;
WORD	option_fetchmode;

BPTR	MyHandle;
char	s[256];

#if EXTRAWIDTH == 32

	// bitmap width aligned to 32 Pixels
	#define MAX_FETCHMODE 2
	#define MAX_FETCHMODE_S "2"

#elif EXTRAWIDTH == 64

	// bitmap width aligned to 64 Pixels
	#define MAX_FETCHMODE 3
	#define MAX_FETCHMODE_S "3"

#else

	// bad extrawidth
	#error "EXTRAWIDTH must be either 32 or 64"

#endif

struct FetchInfo
{
	WORD	ddfstart;
	WORD	ddfstop;
	WORD	modulooffset;
	WORD	bitmapoffset;
	WORD	scrollpixels;
} fetchinfo [] =
{
	{0x30,0xD0,2,0,16},	/* normal         */
	{0x28,0xC8,4,16,32},	/* BPL32          */
	{0x28,0xC8,4,16,32},	/* BPAGEM         */
	{0x18,0xB8,8,48,64}	/* BPL32 + BPAGEM */
};

/********************* MACROS ***********************/

#define ROUND2BLOCKWIDTH(x)  ((x) & ~(BLOCKWIDTH - 1))
#define ROUND2BLOCKHEIGHT(x) ((x) & ~(BLOCKHEIGHT - 1))

#define ADJUSTDESTCOORDS(x,y) 		\
	if (x >= BITMAPWIDTH)				\
	{											\
		x -= BITMAPWIDTH;					\
		y++;									\
		if (y >= BITMAPPLANELINES)		\
		{										\
			y -= BITMAPPLANELINES;		\
		}										\
	}

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
	
	if (option_fetchmode < 0 || option_fetchmode > MAX_FETCHMODE)
	{
		Cleanup("Invalid fetch mode. Must be 0 .. " MAX_FETCHMODE_S "!");
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
	frontbuffer += (fetchinfo[option_fetchmode].bitmapoffset / 8);

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
	WORD	*wp;
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

	bitplanemodulo = l;

	// display window start/stop
	
	CopDIWSTART[1] = DIWSTART;
	CopDIWSTOP[1] = DIWSTOP;
	
	// display data fetch start/stop
	
	CopDDFSTART[1] = fetchinfo[option_fetchmode].ddfstart;
	CopDDFSTOP[1]  = fetchinfo[option_fetchmode].ddfstop;
	
	// plane pointers

	wp = CopPLANE1H;

	for(l = 0;l < BLOCKSDEPTH;l++)
	{
		plane = (ULONG)ScreenBitmap->Planes[l];
		
		wp[1] = plane >> 16;
		wp[3] = plane & 0xFFFF;

		wp += 4;
	}

	// Setup modulo trick

	plane = (ULONG)ScreenBitmap->Planes[0];

	plane2 = plane +
				(BITMAPHEIGHT - 1) * BITMAPBYTESPERROW * BLOCKSDEPTH +
				SCREENBYTESPERROW +
				fetchinfo[option_fetchmode].modulooffset;

	l = (plane - plane2) & 0xFFFF;

	CopVIDEOSPLITMODULO[1] = l;
	CopVIDEOSPLITMODULO[3] = l;
	
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
	
	block = mapdata[mapy * mapwidth + mapx];

	mapx = (block % BLOCKSPERROW) * (BLOCKWIDTH / 8);
	mapy = (block / BLOCKSPERROW) * (BLOCKPLANELINES * BLOCKSBYTESPERROW);
	
	if (option_how) OwnBlitter();

	if (y + BLOCKPLANELINES <= BITMAPPLANELINES)
	{
		// blit does not cross bitmap's bottom boundary
		
		HardWaitBlit();
		
		custom->bltcon0 = 0x9F0;	// use A and D. Op: D = A
		custom->bltcon1 = 0;
		custom->bltafwm = 0xFFFF;
		custom->bltalwm = 0xFFFF;
		custom->bltamod = BLOCKSBYTESPERROW - (BLOCKWIDTH / 8);
		custom->bltdmod = BITMAPBYTESPERROW - (BLOCKWIDTH / 8);
		custom->bltapt  = blocksbuffer + mapy + mapx;
		custom->bltdpt	 = frontbuffer + y * BITMAPBYTESPERROW + x;
		
		custom->bltsize = BLOCKPLANELINES * 64 + (BLOCKWIDTH / 16);
	} else {
		// blit does cross bitmap's bottom boundary
		// --> need to split blit = do two blit operations
		
		HardWaitBlit();
		
		custom->bltcon0 = 0x9F0;	// use A and D. Op: D = A
		custom->bltcon1 = 0;
		custom->bltafwm = 0xFFFF;
		custom->bltalwm = 0xFFFF;
		custom->bltamod = BLOCKSBYTESPERROW - (BLOCKWIDTH / 8);
		custom->bltdmod = BITMAPBYTESPERROW - (BLOCKWIDTH / 8);
		custom->bltapt  = blocksbuffer + mapy + mapx;
		custom->bltdpt	 = frontbuffer + y * BITMAPBYTESPERROW + x;
		
		y = BITMAPPLANELINES - y;
		custom->bltsize = y * 64 + (BLOCKWIDTH / 16);
		
		HardWaitBlit();

		custom->bltdpt  = frontbuffer + x;
		custom->bltsize = (BLOCKPLANELINES - y)  * 64 + (BLOCKWIDTH / 16);

	}

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
	mapblocky = mapposy / BLOCKHEIGHT;
	stepy = mapposy & (NUMSTEPS_Y - 1);
	
	videoposy -= BLOCKSDEPTH;
	if (videoposy < 0) videoposy += BITMAPPLANELINES;
	if (stepy == (NUMSTEPS_Y - 1))
	{
		block_videoposy -= BLOCKPLANELINES;
		if (block_videoposy < 0) block_videoposy += BITMAPPLANELINES;
	}
	
	if (stepy == (NUMSTEPS_Y - 1))
	{
		// a complete row is filled up
		// : the next fill up row will be BLOCKHEIGHT (16)
		// pixels at the top, so we have to adjust
		// the fillup column (for x scrolling), but
		// only if the fillup column (x) contains some
		// fill up blocks
		
		if (stepx)
		{
			// step 1: blit the 1st block in the fillup
			//         col (x). There can only be 0 or
			//         (2 or more) fill up blocks in the
			//         actual implementation, so we do
			//         not need to check previous_xdirection
			//         for this blit
			
			mapx = mapblockx + BITMAPBLOCKSPERROW;
			mapy = mapblocky + 1;
			
			x = ROUND2BLOCKWIDTH(videoposx);
			y = (block_videoposy + 1 + BLOCKPLANELINES) % BITMAPPLANELINES;
			
			DrawBlock(x,y,mapx,mapy);
			
			// step 2: remove the (former) bottommost fill up
			// block
			
			if (previous_xdirection == DIRECTION_RIGHT)
			{
				*savewordpointer = saveword;
			}
			
			mapy = stepx + 2;

			// we blit a 'left' block

			y = (block_videoposy + (mapy * BLOCKPLANELINES)) % BITMAPPLANELINES;
			
			savewordpointer = (WORD *)(frontbuffer + (y * BITMAPBYTESPERROW) + (x / 8));
			saveword = *savewordpointer;

			mapx -= BITMAPBLOCKSPERROW;
			mapy += mapblocky;

			DrawBlock(x,y,mapx,mapy);
			
			previous_xdirection = DIRECTION_LEFT;

		} /* if (stepx) */
		
	} /* if (stepy == NUMSTEPS_Y - 1) */


	mapx = stepy;
	mapy = mapblocky;
	
	y = block_videoposy;

   if (mapx >= TWOBLOCKSTEP)
   {
   	// blit only one block
   	
   	mapx += TWOBLOCKSTEP;

   	x = mapx * BLOCKWIDTH + ROUND2BLOCKWIDTH(videoposx);

		ADJUSTDESTCOORDS(x,y)

   	mapx += mapblockx;

   	DrawBlock(x,y,mapx,mapy);
   	
   } else {
   	// blit two blocks
   	
   	mapx *= 2;

   	x = mapx * BLOCKWIDTH + ROUND2BLOCKWIDTH(videoposx);

		ADJUSTDESTCOORDS(x,y)
 
		mapx += mapblockx;

   	DrawBlock(x,y,mapx,mapy);
   	
   	x += BLOCKWIDTH;

		ADJUSTDESTCOORDS(x,y)

   	DrawBlock(x,y,mapx + 1,mapy);
   	
   }
}

static void ScrollDown(void)
{
	WORD mapx,mapy,x,y,y2;

	if (mapposy >= (mapheight * BLOCKHEIGHT - SCREENHEIGHT - BLOCKHEIGHT)) return;
	
	mapx = stepy;
	mapy = mapblocky + BITMAPBLOCKSPERCOL;
	
	y = block_videoposy;

   if (mapx >= TWOBLOCKSTEP)
   {
   	// blit only one block
   	
   	mapx += TWOBLOCKSTEP;

   	x = mapx * BLOCKWIDTH + ROUND2BLOCKWIDTH(videoposx);

		ADJUSTDESTCOORDS(x,y)

   	mapx += mapblockx;

   	DrawBlock(x,y,mapx,mapy);
   	
   } else {
   	// blit two blocks
   	
   	mapx *= 2;

   	x = mapx * BLOCKWIDTH + ROUND2BLOCKWIDTH(videoposx);

		ADJUSTDESTCOORDS(x,y)

   	mapx += mapblockx;
   	
   	DrawBlock(x,y,mapx,mapy);
   	
   	x += BLOCKWIDTH;

		ADJUSTDESTCOORDS(x,y)

   	DrawBlock(x,y,mapx + 1,mapy);
   }

	mapposy++;
	mapblocky = mapposy / BLOCKHEIGHT;
	stepy = mapposy & (NUMSTEPS_Y - 1);
	
	videoposy += BLOCKSDEPTH;
	if (videoposy >= BITMAPPLANELINES) videoposy -= BITMAPPLANELINES;
	
	if (!stepy)
	{
		block_videoposy += BLOCKPLANELINES;
		if (block_videoposy >= BITMAPPLANELINES) block_videoposy -= BITMAPPLANELINES;
	}

	if (stepy == 0)
	{
		// a complete row is filled up
		// : the next fill up row will be BLOCKHEIGHT (16)
		// pixels at the bottom, so we have to adjust
		// the fillup column (for x scrolling), but
		// only if the fillup column (x) contains some
		// fill up blocks
		
		if (stepx)
		{
			// step 1: blit the 1st block in the fillup
			//         row (y) because this block must
			//         not be part of the fillup col (x)
			//         instead it is for exclusive use
			//         by the fillup row
			
			mapx = mapblockx;
			mapy = mapblocky;
			
			x = ROUND2BLOCKWIDTH(videoposx);
			y = block_videoposy;
			
			DrawBlock(x,y,mapx,mapy);
			
			// step 2: blit the (new) bottommost fill up
			// block
			
			if (previous_xdirection == DIRECTION_LEFT)
			{
				*savewordpointer = saveword;
			}
			
			mapy = stepx + 1;

			// we blit a 'right' block, therefore + 1

			y = (block_videoposy + 1 + (mapy * BLOCKPLANELINES)) % BITMAPPLANELINES;
			y2 = (y + BLOCKPLANELINES - 1) % BITMAPPLANELINES;
			
			savewordpointer = (WORD *)(frontbuffer + (y2 * BITMAPBYTESPERROW) + (x / 8));
			saveword = *savewordpointer;

			mapx += BITMAPBLOCKSPERROW;
			mapy += mapblocky;

			DrawBlock(x,y,mapx,mapy);
			
			previous_xdirection = DIRECTION_RIGHT;
		} /* if (stepx) */
		
	} /* if (stepy == 0) */
	

}

static void ScrollLeft(void)
{
	WORD mapx,mapy,x,y;
	
	if (mapposx < 1) return;
	
	mapposx--;
	mapblockx = mapposx / BLOCKWIDTH;
	stepx = mapposx & (NUMSTEPS_X - 1);

	videoposx--;
	if (videoposx < 0)
	{
		videoposx = BITMAPWIDTH - 1;

		videoposy--;
		if (videoposy < 0) videoposy = BITMAPPLANELINES - 1;

		block_videoposy--;
		if (block_videoposy < 0) block_videoposy = BITMAPPLANELINES - 1;
	}
	
	//

	if (stepx == (NUMSTEPS_X - 1))
	{
		// a complete column is filled up
		// : the next fill up column will be BLOCKWIDTH (16)
		// pixels at the left, so we have to adjust
		// the fillup row (for y scrolling)
		
		// step 1: blit the block which came in at
		//         the left side and which might or
		//         might not be a fill up block
		
		mapx = mapblockx;
		mapy = mapblocky;
		if (stepy)
		{
			// there is a fill up block
			// so block which comes in left is
			// a fillup block
			
			mapy += BITMAPBLOCKSPERCOL;
		}

		x = ROUND2BLOCKWIDTH(videoposx);
		y = block_videoposy;
		
		DrawBlock(x,y,mapx,mapy);
		
		// step 2: remove the (former) rightmost fillup-block
		
		mapx = stepy;
		if (mapx)
		{
			// there is a fill up block;
			
			if (mapx >= TWOBLOCKSTEP)
			{
				mapx += TWOBLOCKSTEP;
			} else {
				mapx *= 2;
			}
						
			x = ROUND2BLOCKWIDTH(videoposx) + (mapx * BLOCKWIDTH);
			y = block_videoposy;
			
			ADJUSTDESTCOORDS(x,y)

			mapx += mapblockx;
			mapy -= BITMAPBLOCKSPERCOL;
			DrawBlock(x,y,mapx,mapy);
		}

	}


	mapx = mapblockx;
	mapy = stepx + 1;

	x = ROUND2BLOCKWIDTH(videoposx);
	
	if (previous_xdirection == DIRECTION_RIGHT)
	{
		HardWaitBlit();
		*savewordpointer = saveword;
	}

	if (mapy == 1)
	{
		// blit two blocks

		mapy += mapblocky;
		
		y = (block_videoposy + (1 * BLOCKPLANELINES)) % BITMAPPLANELINES;

		savewordpointer = (WORD *)(frontbuffer + (y * BITMAPBYTESPERROW) + (x / 8));
		saveword = *savewordpointer;
		
		DrawBlock(x,y,mapx,mapy);
		
		y = (y + BLOCKPLANELINES) % BITMAPPLANELINES;

		DrawBlock(x,y,mapx,mapy + 1);

	} else {
		// blit one block

		mapy ++;
		
		y = (block_videoposy + (mapy * BLOCKPLANELINES)) % BITMAPPLANELINES;
		
		mapy += mapblocky;

		savewordpointer = (WORD *)(frontbuffer + (y * BITMAPBYTESPERROW) + (x / 8));
		saveword = *savewordpointer;

		DrawBlock(x,y,mapx,mapy);
	}
	
	if (stepx)
	{
		previous_xdirection = DIRECTION_LEFT;
	} else {
		previous_xdirection = DIRECTION_IGNORE;
	}
}

static void ScrollRight(void)
{
	WORD mapx,mapy,x,y,y2;
	
	if (mapposx >= (mapwidth * BLOCKWIDTH - SCREENWIDTH - BLOCKWIDTH)) return;

	mapx = mapblockx + BITMAPBLOCKSPERROW;
	mapy = stepx + 1;

	x = ROUND2BLOCKWIDTH(videoposx);
	
	if (previous_xdirection == DIRECTION_LEFT)
	{
		HardWaitBlit();
		*savewordpointer = saveword;
	}

	if (mapy == 1)
	{
		// blit two blocks

		mapy += mapblocky;
		
		y = (block_videoposy + 1 + (1 * BLOCKPLANELINES)) % BITMAPPLANELINES;
		
		DrawBlock(x,y,mapx,mapy);
		
		y = (y + BLOCKPLANELINES) % BITMAPPLANELINES;
		y2 = (y + BLOCKPLANELINES - 1) % BITMAPPLANELINES;
		
		savewordpointer = (WORD *)(frontbuffer + (y2 * BITMAPBYTESPERROW) + (x / 8));
		saveword = *savewordpointer;

		DrawBlock(x,y,mapx,mapy + 1);

	} else {
		// blit one block

		mapy ++;
		
		y = (block_videoposy + 1 + (mapy * BLOCKPLANELINES)) % BITMAPPLANELINES;
		y2 = (y + BLOCKPLANELINES - 1) % BITMAPPLANELINES;
		
		mapy += mapblocky;

		savewordpointer = (WORD *)(frontbuffer + (y2 * BITMAPBYTESPERROW) + (x / 8));
		saveword = *savewordpointer;

		DrawBlock(x,y,mapx,mapy);
	}
	
	//
	
	mapposx++;
	mapblockx = mapposx / BLOCKWIDTH;
	stepx = mapposx & (NUMSTEPS_X - 1);

	videoposx++;
	if (videoposx == BITMAPWIDTH)
	{
		videoposx = 0;

		videoposy++;
		if (videoposy == BITMAPPLANELINES) videoposy = 0;

		block_videoposy++;
		if (block_videoposy == BITMAPPLANELINES) block_videoposy = 0;
	}
	
	if (stepx == 0)
	{
		// a complete column is filled up
		// : the next fill up column will be BLOCKWIDTH (16)
		// pixels at the right, so we have to adjust
		// the fillup row (for y scrolling)
		
		// step 1: blit the block which came in at
		//         the right side and which is never
		//         a fill up block
		
		mapx = mapblockx + BITMAPBLOCKSPERROW - 1;
		mapy = mapblocky;
		
		x = ROUND2BLOCKWIDTH(videoposx) + (BITMAPBLOCKSPERROW - 1) * BLOCKWIDTH;
		y = block_videoposy;
		
		ADJUSTDESTCOORDS(x,y)
		
		DrawBlock(x,y,mapx,mapy);
		
		// step 2: blit the (new) rightmost fillup-block
		
		mapx = stepy;
		if (mapx)
		{
			// there is a fill up block;
			
			if (mapx >= TWOBLOCKSTEP)
			{
				mapx += (TWOBLOCKSTEP - 1);
			} else {
				mapx = mapx * 2 - 1;
			}
						
			x = ROUND2BLOCKWIDTH(videoposx) + (mapx * BLOCKWIDTH);
			y = block_videoposy;
			
			ADJUSTDESTCOORDS(x,y)

			mapx += mapblockx;

			DrawBlock(x,y,mapx,mapy + BITMAPBLOCKSPERCOL);
		}
	}

	if (stepx)
	{
		previous_xdirection = DIRECTION_RIGHT;
	} else {
		previous_xdirection = DIRECTION_IGNORE;
	}
}

static void CheckJoyScroll(void)
{
	WORD i,count;
	
	if (JoyFire()) count = 4; else count = 1;

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

	if (JoyLeft())
	{
		for(i = 0;i < count;i++)
		{
			ScrollLeft();
		}
	}
	
	if (JoyRight())
	{
		for(i = 0;i < count;i++)
		{
			ScrollRight();
		}
	}

}

static void BlitVideoSplitLine(void)
{
	WORD x,y,bytes;

	y = videoposy % BLOCKSDEPTH;
	x = videoposx;
	
	bytes = y * BITMAPBYTESPERROW + (x / 8);

	if (bytes >= 2)
	{
		HardWaitBlit();
		
		custom->bltcon0 = 0x9F0;
		custom->bltcon1 = 0;
		custom->bltafwm = 0xFFFF;
		custom->bltalwm = 0xFFFF;
		custom->bltamod = 0;
		custom->bltdmod = 0;
		custom->bltapt  = frontbuffer;
		custom->bltdpt  = frontbuffer + BITMAPPLANELINES * BITMAPBYTESPERROW;

		custom->bltsize = (bytes / 2) * 64 + 1;
	}
}

static void UpdateCopperlist(void)
{
	ULONG pl;
	LONG	planeadd,planeaddx;
	WORD	i,xpos,scroll,yoffset;
	WORD	*wp;

	i = fetchinfo[option_fetchmode].scrollpixels;

	xpos = videoposx + i - 1;

	planeaddx = (xpos / i) * (i / 8);
	i = (i - 1) - (xpos & (i - 1));
	
	scroll = (i & 15) * 0x11;
	if (i & 16) scroll |= (0x400 + 0x4000);
	if (i & 32) scroll |= (0x800 + 0x8000);
	
	// set scroll register in BPLCON1
	
	CopBPLCON1[1] = scroll;

	// set top plane pointers

	// yoffset is in planelines!!! not reallines!

	yoffset = (videoposy + BLOCKHEIGHT * BLOCKSDEPTH) % BITMAPPLANELINES;
	planeadd = ((LONG)yoffset) * BITMAPBYTESPERROW;
	
	wp = CopPLANE1H;

	for(i = 0;i < BLOCKSDEPTH;i++)
	{
		pl = ((ULONG)ScreenBitmap->Planes[i]) + planeadd + planeaddx;
		
		wp[1] = (WORD)(pl >> 16);
		wp[3] = (WORD)(pl & 0xFFFF);
		
		wp += 4;
	}

	// set video split wait

	yoffset = yoffset / BLOCKSDEPTH;	// convert planelines to splitlines

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

	/* Set video split plane pointers (to top of bitmap):
 
 		We only set the hiwords. The lowords are automatically
 		correct thanks to the modulo-trick in the copperlist
 		which is setup in UpdateCopperlist().
	*/
	
	pl = (ULONG)ScreenBitmap->Planes[0] +
		  planeaddx +
	     (videoposy % BLOCKSDEPTH) * BITMAPBYTESPERROW;

	// set high words

	wp = CopPLANE2_1H;
	
	for(i = 0;i < BLOCKSDEPTH;i++)
	{
		wp[1] = (WORD)(pl >> 16);

		pl += BITMAPBYTESPERROW * BLOCKSDEPTH;
		wp += 2;
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
		BlitVideoSplitLine();

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

