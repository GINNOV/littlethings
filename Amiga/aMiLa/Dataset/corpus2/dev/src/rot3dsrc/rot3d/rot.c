
/************************************************************************
* Rot.c -- main program file.
*
* Amiga demo of texture-mapped walls.
*   - 2 16 color palettes
* 	- variable light-sourcing
*   - adjustable view size
*   - doors, secret doors
*   - lores/hires auto switching
*   - Walls created from pieces of other walls.
*
* Compiles under Aztec & SAS (with small mods to makefile).
* 1993 by: Jason Freund, Gabe Dalbec, Chris Hames.
*
************************************************************************/

#ifdef	__SASC
#include "includes.h"
#define	MYFAR	__far
/*
#define float double
*/
#else
#define	MYFAR
#endif
#include "walls.h"
/*#include "objdat.h"*/
#include "defines.h"

short halfres=0;
short moveok=1;
UBYTE *heighttolight;
extern UBYTE heighttolight0[];
extern UBYTE heighttolight1[];
extern UBYTE heighttolight2[];
extern UBYTE heighttolight3[];
extern UBYTE heighttolight4[];
extern UBYTE heighttolight5[];
extern UBYTE heighttolight6[];
extern unsigned long lighttable_base[];
unsigned long *lighttable;
extern void makelightcolor(void);
extern UWORD wallparts[];

/* You must be running Kickstart 2.0+ to define timing */
#define TIMING
#ifdef TIMING
#include <devices/timer.h>
#define StartTTimer()	ReadEClock(&TimerStuff->ttime1)
#define EndTTimer()	{ ReadEClock(&TimerStuff->ttime2); printf("%f frames/sec\n",(float)Frames/((TimerStuff->ttime2.ev_lo-TimerStuff->ttime1.ev_lo)/(float)TimerStuff->EFreq)); }
#define StartTimer()	ReadEClock(&TimerStuff->time1)
#define EndTimer(a)	{ ReadEClock(&TimerStuff->time2); printf("%s took %f seconds\n",a,(TimerStuff->time2.ev_lo-TimerStuff->time1.ev_lo)/(float)TimerStuff->EFreq); }
struct Library *TimerBase=NULL;
struct MyTimerStuff
  {
  struct timerequest tio;
  struct EClockVal ttime1;
  struct EClockVal ttime2;
  struct EClockVal time1;
  struct EClockVal time2;
  ULONG EFreq;
  };
struct MyTimerStuff *TimerStuff=NULL;
#else
#define StartTTimer()	;
#define EndTTimer()	;
#define StartTimer()	;
#define EndTimer(a)	;
#endif

short screenx,screeny;
struct IntuitionBase *IntuitionBase=NULL;
struct GfxBase       *GfxBase=NULL;
struct Screen        *Screen;
struct Screen        *mapscreen;
struct Window        *mapwindow;
struct RastPort      *maprp;
struct Window        *FirstWindow;
struct RastPort      *rp;
struct View          *view;
struct RasInfo       dualri;
struct BitMap        bm1,fastbm,mapbm;
struct IntuiMessage  *message;
ULONG *rowlookLR;
ULONG *rowlookHR;
ULONG *rowlook;
unsigned char lines[352/8];
short brushno=0;
char filename[100];
float angle;
float cy;
float sy;
float points[MAXPOINTS][3];
float subpoints[MAXPOINTS][3];
float rotpoints[MAXPOINTS][3];
struct UCopList *uCopList = NULL;
ULONG Frames=0;
UBYTE lightcolor[353];
short numpoints=0;
UBYTE edges[MAXEDGES][3];
short numedges=0;
UBYTE poly[MAXPOLY][4];
short numpoly=0;
float transX=0,transY=0;
short wallwidth = WALLWIDTH;
BOOL speed=1;
short bitmapno=0;
int numlines;
short delx;
int x2,y2;
short torch=3;
short dely;
short numbuttons=0;
short e;
short x;
short y;
short interchange,s1,s2;
short Sx,Sy,Dx,Dy,m1,m2;
short intowall=0,outofwall=0;
short changepalette,lastpalette=0;
extern Brush *Items[4][NUMITEMS+1];
extern Brush *Misc[NUMMISC+1];
/*extern void BlitMe(short x, short y, Brush *b);*/
typedef struct
{
	UWORD height;
	short bitmap;
	short offset;
	short junk;
} mapline;
mapline map[353];

struct ExtNewScreen SuperScreen =
{
   0, 0,                /* LeftEdge, TopEdge   */
   352, 199,            /* Width, Height       */
   DEPTH,               /* Depth               */
   0, 1,                /* DetailPen, BlockPen */
   0,		        /* ViewModes           */
   CUSTOMSCREEN |       /* Type                */
   SCREENQUIET | CUSTOMBITMAP | NS_EXTENDED,
   NULL,                /* Font                */
   NULL,
   NULL,                /* Gadgets             */
   NULL,                /* CustomBitMap        */
   NULL,				/* Extend */
};

struct NewWindow FirstNewWindow =
{
   0, 0,             /* LeftEdge, TopEdge   */
   353, 199,            /* Width, Height       */
   0, 1,                /* DetailPen, BlockPen */
   MENUPICK | ACTIVEWINDOW | MOUSEBUTTONS |
   VANILLAKEY | MOUSEMOVE ,/* IDCMP flags  */
   BACKDROP |BORDERLESS | NOCAREREFRESH |
   ACTIVATE | RMBTRAP | REPORTMOUSE ,       /* general flags   */
   NULL,                /* First Gadget        */
   NULL,                /* CheckMark           */
   NULL,
   NULL,                /* Screen              */
   NULL,                /* BitMap              */
   100, 50,             /* Min Width, Height   */
   640, 400,            /* Max Width, Height   */
   CUSTOMSCREEN,        /* Type                */
};

/**************************************************************************
* Maps not currently used.
**************************************************************************/
struct NewScreen MapNewScreen =
{
   0, 0,                /* LeftEdge, TopEdge   */
   320, 80,            /* Width, Height       */
   5,               /* Depth               */
   0, 1,                /* DetailPen, BlockPen */
   0,        /* ViewModes           */
   CUSTOMSCREEN |       /* Type                */
   SCREENQUIET | CUSTOMBITMAP,
   NULL,                /* Font                */
   NULL,
   NULL,                /* Gadgets             */
   NULL,                /* CustomBitMap        */
};

struct NewWindow MapNewWindow =
{
   0, 0,             /* LeftEdge, TopEdge   */
   320, 80,            /* Width, Height       */
   0, 1,                /* DetailPen, BlockPen */
   0,/* IDCMP flags  */
   BACKDROP |BORDERLESS | NOCAREREFRESH |
   RMBTRAP,       /* general flags   */
   NULL,                /* First Gadget        */
   NULL,                /* CheckMark           */
   NULL,
   NULL,                /* Screen              */
   NULL,                /* BitMap              */
   100, 50,             /* Min Width, Height   */
   640, 400,            /* Max Width, Height   */
   CUSTOMSCREEN,        /* Type                */
};


/**************************************************************************
* rot.c routine definitions
**************************************************************************/
void LoadCopper(void);
void SetUpMap(void);
void PlotYou(void);
void PlotMap(void);
void PlotRotMap(void);
void SubDivide(void);
void MakeTables(void);
void ToggleRes(void);
void DrawScene(void);
void Close_All(void);
void Open_All(BOOL reopen,short oldx, short oldy);
void ReadScene(void);
void Line(float sx,float sy,float dx,float dy);

/**************************************************************************
* Assembly routine definitions
**************************************************************************/

/*
Sets an are of memory to zero. mem be word aligned or 68020+.
size must be a multiple of 4 */
extern void cpuclear(void *mem,long size);
extern void cpuclear2(void *mem,long size);
extern void fasttochip(struct BitMap *bm);
extern void fasttochip2(struct BitMap *bm);
extern void Fill(void);
void MegaMap(short Sx, short delx, short x, short y);

/**************************************************************************
* BlitFill.  val is whether or not screen starts with top or bottom palette
* This routine fills the fifth bitplane with 1s and 0s alternately after
* every vertical line (see blitline, below).
*
* This routine is now used, but will probably later be done during the
* copy-out phase with the cpu because 1) the cpu is probably faster since
* the loop is already set up 2) Doing it in the copy-out phase will
* get rid of the flickering caused by doing 4 planes all at once, and then
* the fifth plane afterwards.
*
* Not used
**************************************************************************/
void BlitFill(BOOL val)
{
	UWORD blitsize;
	UWORD height=rp->BitMap->Rows;
	UWORD width=SBYTESPERROW;
	void *mem=rp->BitMap->Planes[4]+width*height-2;
	UWORD con1val=(val) ? 0x000e : 0x000a;
	struct Custom *custom = (void *)0x00dff000;
	blitsize=height*64+width/2;
	OwnBlitter();
	WaitBlit();
	custom->bltcon0 = 0x09f0;
	custom->bltcon1 = con1val;
	custom->bltdmod = 0;
	custom->bltamod = 0;
	custom->bltdpt = (APTR)mem;
	custom->bltapt = (APTR)mem;
	custom->bltsize = blitsize;
	DisownBlitter();
}

UBYTE *htab[] =
{
	&heighttolight0[0],
	&heighttolight1[0],
	&heighttolight2[0],
	&heighttolight3[0],
	&heighttolight4[0],
	&heighttolight5[0],
	&heighttolight6[0],
};


short ie,currented,myedge,nexted;
short nextanim[] = {1,2,3,4,5,6,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
short animwalls1[25] = { 1,3,7,9,10,13,15,16,20,34,55,56,57,60};
short animwalls2[5] = { 5 ,50};
short delay=0;
/*************************************************************************
* Increments edge number for all animating walls in animwalls[].
*************************************************************************/
void AnimWalls()
{
/* Drip Anim */
	nexted = edges[1][2]+1;
	if (nexted>6) nexted=1;
	for (ie=0;ie<14;ie++) edges[animwalls1[ie]][2]=nexted;

/* OTB Anim */
	nexted = edges[5][2]+1;
	if (nexted>12) nexted=7;
	for (ie=0;ie<2;ie++) edges[animwalls2[ie]][2]=nexted;
}

/*************************************************************************
* Change brightness.  range 0==darkest, 1==brightest
* dir == +1 or -1 from current or if
* absolute is set, then torch <- absolute
*************************************************************************/
void Brightness(short dir,short absolute)
{
	torch+=dir;
	if (absolute) torch=absolute;
	if (torch<0) torch=0; else
	if (torch>6) torch=6;
	heighttolight=htab[torch];
}

/**************************************************************************
* BlitLine.  x is the pixel column to draw the line at.
* Draws a 1-pixel-width vertical line of "1"s into the fifth bitplane
* where the palette changes.  This way, BlitFill can fill the entire fifth
* bitplane with 1s and 0s alternating after every vertical line.
*
* This routine is currently not used, because I think move/draw is faster
* on the 3000.  But a 500 version might want this routine.
*
* Not used
**************************************************************************/
void BlitLine(short x)
{
	struct Custom *custom = (void *)0x00dff000;
	OwnBlitter();
	WaitBlit();
	custom->bltcon0 = 0x0bfa || (x&15)<<16;
	custom->bltcon1 = 0x049;
	custom->bltdmod = SBYTESPERROW;
	custom->bltcmod = SBYTESPERROW;
	custom->bltamod = 0xfed4;
	custom->bltdpt  = (APTR)((UBYTE *)rp->BitMap->Planes[4]+(x/16)*2);
	custom->bltcpt  = (APTR)((UBYTE *)rp->BitMap->Planes[4]+(x/16)*2);
	custom->bltapt  = (APTR)0xffffff6a;
	custom->bltadat = 0x8000;
	custom->bltbdat = 0xffff;
	custom->bltsize = 1302;
	DisownBlitter();
}

/**************************************************************************
* Toggles resolution between hires and lores.
**************************************************************************/
void ToggleRes()
{
  	halfres^=1;

  	if(halfres)
  	{
    	fastbm.BytesPerRow=SCREENX>>4;
	    fastbm.Rows=SCREENY/2;
	    rowlook=&rowlookLR[0];
	} else
	{
	    fastbm.BytesPerRow=SCREENX>>3;
	    fastbm.Rows=SCREENY;
	    rowlook=&rowlookHR[0];
	}
}

/**************************************************************************
* Takes in start and end coords of line segement.  clips it to the screen.
* Then calls megamap (see megamap.c) to use breshenhams to check to see
* if each point on the line is higher than what was in Map.height, before.
* if the point is higher, it overwrites map[i].height and sets the other
* fields in map, too.
**************************************************************************/
void Line(float sx,float sy,float dx,float dy)
{
short i,temp;
float m;
float deltx;
	sx*=ASPECT; dx*=ASPECT;

	deltx=dx-sx;
	if (deltx==0)
	{
		deltx=0.0000001;
		m=1e100;
	} else m=(dy-sy)/deltx;
	if (m==0) m=0.00000001;

 	intowall=outofwall=0;
	if (sx<-1) {
		intowall=-(sx+1)*WALLWIDTH/deltx;
		sx=-1;
		sy=m*(sx-dx)+dy;

	}
	if (sx>1) {
		sx=1;
		sy=m*(sx-dx)+dy;
	}
	if (dx<-1) {
		dx=-1;
		dy=m*(dx-sx)+sy;
	}
	if (dx>1) {
		outofwall = (dx-1)*WALLWIDTH/deltx;
		dx=1;
		dy=m*(dx-sx)+sy;
	}

	if (sx>1 || sx<-1 || dx>1 || dx<-1) return;

/*  Sx...Dy are pixel values of the line segment */

    if (halfres)
    {
		Sx = (sx+1)*(SCREENX>>2);
		Dx = (dx+1)*(SCREENX>>2);
		Sy = (1-sy)*(SCREENY<<4);
		Dy = (1-dy)*(SCREENY<<4);
		intowall>>=1;
		outofwall>>=1;
    } else
    {
		Sx = (sx+1)*(SCREENX>>1);
		Dx = (dx+1)*(SCREENX>>1);
		Sy = (1-sy)*(SCREENY<<5);
		Dy = (1-dy)*(SCREENY<<5);
    }

	if (Sx==Dx && Sy==Dy) return;

/*  if (Sy>map[Sx].height && Dy>map[Dx].height) return; */
/*  used in megamap.c for breshenhams line algortihm */
	delx = Dx - Sx;
	dely = Dy - Sy;
	e = ABS(dely>>1)-delx;
	s2 = (dely<0) ? -1 : 1;

	MegaMap(Sx, delx, Sx, Sy);
}


/**************************************************************************
* Translates and rotates all the points in the dungeon each frame.
**************************************************************************/
void TransRot()
{
register int i;
register float *rp,*p;
register float p1,p2;

	for (i=0;i<numpoints;i++)
	{
		rp=rotpoints[i];
		p=points[i];
		p1=p[0]-transX;
		p2=p[2]-transY;
		rp[0] = p1*cy - p2*sy;
		rp[1] = p[1];
		rp[2] = p1*sy + p2*cy;
	}
}

/**************************************************************************
* This routine 1) rotates and translates the points in the dungeon
* 2) Calls "line" which checks to see if each line is at least partially
* and adds it to the Map if it is.
**************************************************************************/
void DrawScene()
{
short i,j,current,xmin,xmax;
float z1,z2,x1,x2,y1,y2,t;
short pt1,pt2;

    Frames++;
	clearmapheight();
	TransRot();

	for (i=0;i<numedges;i++) {
		pt1=edges[i][0]-1;
		pt2=edges[i][1]-1;

		bitmapno=edges[i][2];
		x1= rotpoints[pt1][0];
		y1= rotpoints[pt1][1];
		z1= rotpoints[pt1][2];
		x2= rotpoints[pt2][0];
		y2= rotpoints[pt2][1];
		z2= rotpoints[pt2][2];
		if (z1>0 || z2>0)
		{
			if (z1<0) {
				t=-z1/(z1-z2);
				z1=0.00000001;
				x1=x1+(x1-x2)*t;
				y1=y1+(y1-y2)*t;
			}
			if (z2<0) {
				t=-z1/(z1-z2);
				z2=0.00000001;
				x2=x1+(x1-x2)*t;
				y2=y1+(y1-y2)*t;
			}

			if (x1/z1 < x2/z2)
				Line((float)(x1/z1),(float)(y1/z1),(float)(x2/z2),(float)(y2/z2));
			else
				Line((float)(x2/z2),(float)(y2/z2),(float)(x1/z1),(float)(y1/z1));
		}
	}

	if (!speed) PlotYou();
	cpuclear(lines,SBYTESPERROW);
	makelightcolor();

}

/**************************************************************************
* Reads "dungeon" file into points and edges arrays.
**************************************************************************/
void ReadScene()
{
char line[256];
short mode=0,i;
int num;
int t1,t2,t3,t4,t5,t6,t7;
BYTE b4,b5,b6,b7;
FILE *fp;

	fp=fopen(filename,"r");
	if (!fp) { printf("Could not open file %s.\n",filename); return; }
	for (;;)
	{
		if (!fgets(line,50,fp)) {
			printf("error in infile format!\n");
			exit(1);
		}
		line[strlen(line)-1] = '\0';
		if (strlen(line)<2) continue;
		if (!strcmp(line,"END")) break;
		if (!strncmp(line,"POINTS",6)) {
			mode=1;
			continue;
		}
		if (!strncmp(line,"EDGES",5)) {
			mode=2;
			continue;
		}
		if (!strncmp(line,"BUTTONS",5)) {
			mode=3;
			continue;
		}
		switch (mode) {
			case 0: printf("error in infile format!\n");
					exit(1);
					break;
			case 1: /*sscanf(line,"%d %f %f %f",&num,&points[numpoints][0],
						&points[numpoints][1],&points[numpoints][2]); */
					num = atoi(strtok(line," "));
					points[numpoints][0]= 1.5 * atof((char *)strtok(NULL," "));
					points[numpoints][1]= 0.6 * atof((char *)strtok(NULL," "));
					points[numpoints][2]= 1.5 * atof((char *)strtok(NULL," "));
					numpoints++;
					break;
			/* num<edge#> t1<pt1> t2<pt2> t3<wall#> t4<doortype> t5<key> t6<dir> */
			case 2: sscanf(line,"%d %d %d %d %d %d %d",&num,&t1,&t2,&t3,&t4,&t5,&t6);
					edges[numedges][0]=t1;
					edges[numedges][1]=t2;
					edges[numedges][2]=t3;
					b4=t4; b5=t5, b6=t6;
					if (b4>0) InsertDoor(numedges,b4,b5,b6);
					numedges++;
					break;
			/* <edge#> <dir> <start_state> <press_out_wall#> <press_in_wall#> <y> */
			case 3: sscanf(line,"%d %d %d %d %d %d",&num, &t1, &t2, &t3, &t4, &t5);
					InsertButton(num,t1,t2,t3,t4,t5);
					numbuttons++;
					break;
			default: printf("error in infile format!\n");
					exit(1);
					break;
		}
	}
	printf("%d points, %d edges\n",numpoints,numedges);
}

/**************************************************************************
* allocs some chip mem for the bitmap.
**************************************************************************/
void SetUpBitMap(struct BitMap *bm,short x,short y,short depth,short bytesperrow)
{
short i;

	InitBitMap(bm,depth,x,y);
    bm->BytesPerRow=bytesperrow;
	bm->Planes[0] = AllocRaster(x,y*depth);
	if(bm->Planes[0] == NULL)
	{
		printf("Error with buffer AllocRaster Plane\n");
		Close_All();
		exit(1);
	}
	for(i=1; i<depth; i++)
		bm->Planes[i]=bm->Planes[0]+bm->BytesPerRow*bm->Rows*i;
}


struct TagItem mytags[3];

¹/**************************************************************************
* Opens screens, libs, inits stuff, etc.
**************************************************************************/
void Open_All(BOOL reopen, short oldx, short oldy)
{
short i;
PLANEPTR tempptr;

	if (!reopen)
	{
		mytags[0].ti_Tag=SA_DisplayID;
		mytags[0].ti_Data=SCREENMODE;
		mytags[1].ti_Tag=SA_Overscan;
		mytags[1].ti_Data=SCREENOVR;
		mytags[2].ti_Tag=TAG_DONE;
		mytags[2].ti_Data=TAG_DONE;
	    bm1.Planes[0]=0;
	    fastbm.Planes[0]=0;

 	   	if (!(IntuitionBase = (struct IntuitionBase *)
	    	OpenLibrary("intuition.library", 0L)))
	      	{
	      		printf("Intuition Library not found!\n");
	      		Close_All();
	      		exit(FALSE);
	      	}
	   	if (!(GfxBase = (struct GfxBase *)
	       	OpenLibrary("graphics.library", 0L)))
	      	{
	      		printf("Graphics Library not found!\n");
	      		Close_All();
	      		exit(FALSE);
	      	}
		#ifdef	TIMING
	  	if(!(TimerStuff=(struct MyTimerStuff *)AllocMem(sizeof(struct MyTimerStuff),MEMF_CLEAR|MEMF_PUBLIC)))
	    {
	    	printf("No mem for timings\n");
	    	Close_All();
	    	exit(FALSE);
	    }
	  	if(OpenDevice(TIMERNAME,UNIT_ECLOCK,(struct IORequest *)&TimerStuff->tio,0L))
	    {
	    	printf("No timer\n");
	    	Close_All();
	    	exit(FALSE);
	    } else
	    {
	    	TimerBase=(struct Library *)TimerStuff->tio.tr_node.io_Device;
	    	TimerStuff->EFreq=ReadEClock(&TimerStuff->time1);
	    }
		#endif
	}

	if (reopen)
	{
	   if (FirstWindow) CloseWindow(FirstWindow);
	   if (Screen) {
			/*FreeVPortCopLists(&Screen->ViewPort);*/
			CloseScreen(Screen);
	   }
	   if (bm1.Planes[0]) FreeRaster(bm1.Planes[0],oldx,oldy*DEPTH);
	   if (fastbm.Planes[0]) FreeMem(fastbm.Planes[0],(oldx>>3)*4*(oldy));
	}

    SetUpBitMap(&bm1,SCREENX,SCREENY,DEPTH,SBYTESPERROW);
	SuperScreen.CustomBitMap=&bm1;
	SuperScreen.Width=SCREENX;
	SuperScreen.Height=SCREENY-1;
	SuperScreen.Extension = mytags;

   	if (!(Screen = (struct Screen *)
    	OpenScreen((struct NewScreen *)&SuperScreen)))
      	{
  	    	printf("Screen1 has no page!\n");
      		Close_All();
      		exit(FALSE);
      	}

   	FirstNewWindow.Screen = Screen;
   	FirstNewWindow.Width=SCREENX;
   	FirstNewWindow.Height=SCREENY-1;
   	if (!(FirstWindow = (struct Window *)
       	OpenWindow(&FirstNewWindow)))
      	{
      		printf("Window1 will not open!\n");
      		Close_All();
      		exit(FALSE);
      	}

   	rp=FirstWindow->RPort;
/* 	SetWrMsk(rp,16); */
	SetAPen(rp,16);
	SetDrMd(rp,JAM1);

	for (i=0; i<(1<<DEPTH); i++)
	{
		SetRGB4(&Screen->ViewPort,i,(palette[i]&0xf00)>>8,
		(palette[i]&0x0f0)>>4,(palette[i]&0x00f));
	}
	SetRGB4(&Screen->ViewPort,0,0,0,4);
	SetRGB4(&Screen->ViewPort,16,0,0,4);
	fastbm.Rows=SCREENY;
	fastbm.BytesPerRow=SCREENX>>3;
	fastbm.Planes[0]=AllocMem((SCREENX>>3)*4*(SCREENY),0);
	if (!fastbm.Planes[0]) {
		printf("Could not get fast ram for screen buffer!\n");
		Close_All();
		exit(1);
	}

	ShowTitle(Screen,0);
	if(reopen) MakeTables();

}

void CleanItUp()
{
}

/**************************************************************************
* Close all stuff.
**************************************************************************/
void Close_All()
  {
#ifdef TIMING
  if(TimerStuff) {
    if(TimerBase) CloseDevice((struct IORequest *)&TimerStuff->tio);
    FreeMem(TimerStuff,sizeof(struct MyTimerStuff));
    }
#endif
   if (FirstWindow)     CloseWindow(FirstWindow);
   if (Screen) {
		FreeVPortCopLists(&Screen->ViewPort);
		CloseScreen(Screen);
   }
/* if (mapwindow)		CloseWindow(mapwindow); */
/* if (mapscreen)		CloseScreen(mapscreen); */
   if (bm1.Planes[0]) FreeRaster(bm1.Planes[0],SCREENX,SCREENY*DEPTH);
/* if (mapbm.Planes[0])	FreeRaster(mapbm.Planes[0],mapbm.BytesPerRow<<3,mapbm.Rows*mapbm.Depth); */
   if (fastbm.Planes[0]) FreeMem(fastbm.Planes[0],(SCREENX>>3)*4*(SCREENY));
   if (GfxBase)         CloseLibrary((struct Library *)GfxBase);
   if (IntuitionBase)   CloseLibrary((struct Library *)IntuitionBase);
}


/**************************************************************************
* This routine sets up a lookup table to speed up the main inner loop of
* the drawing program, used in megadraw.c
**************************************************************************/
void MakeTables()
{
short i,j,sy;
short locscreeny;
long size;

	SetAPen(rp,4);
	Move(rp,(screenx-21*8)/2,35);
	Text(rp,"Calculating Tables...",21);

	locscreeny=SCREENY;
	size=locscreeny*locscreeny*2*4;
	rowlook=&rowlookHR[0];

	for (i=0; i<locscreeny; i++)
		for (sy=-locscreeny*3/2; sy<locscreeny/2; sy++)
			rowlook[i+256*(sy+locscreeny*3/2)]=
				((i-sy)*WALLHEIGHT/(locscreeny-2*sy))*WALLWIDTH;
	locscreeny=SCREENY/2;
	rowlook=&rowlookLR[0];

	for (i=0; i<locscreeny; i++)
		for (sy=-locscreeny*3/2; sy<locscreeny/2; sy++)
			rowlook[i+256*(sy+locscreeny*3/2)]=
				((i-sy)*WALLHEIGHT/(locscreeny-2*sy))*WALLWIDTH;

	if(halfres) rowlook=&rowlookLR[0]; else rowlook=&rowlookHR[0];

	Move(rp,(screenx-21*8)/2,35);
	SetDrMd(rp,JAM2);
	Text(rp,"Done.                ",21);
	SetDrMd(rp,JAM1);
}


/**************************************************************************
* This routine loads the copper instructions to make the background
* change colors, and reflect the screen.
* In the future, the reflection must either be done by the blitter (on the
* 500) or by the CPU during copy-out on the 3000+.  When that is done,
* comment out the lines, indicated below.
* Now the reflection is done in the copy-out phase by the cpu.  Unccomment
* out the part below to have it done by the copper.
**************************************************************************/
void LoadCopper()
{
	struct Custom *custom = (void *)0x00dff000;
	uCopList= (struct UCopList *)AllocMem(sizeof(struct UCopList),MEMF_PUBLIC|MEMF_CLEAR);
	CINIT(uCopList,128);
	CWAIT(uCopList,SCREENY/4,0);
	CMOVE(uCopList,(custom->color[0]),(WORD)0x003);
	CMOVE(uCopList,(custom->color[16]),(WORD)0x003);
	CWAIT(uCopList,SCREENY*3/8,0);
	CMOVE(uCopList,(custom->color[0]),(WORD)0x002);
	CMOVE(uCopList,(custom->color[16]),(WORD)0x002);
	CWAIT(uCopList,SCREENY*7/16,0);
	CMOVE(uCopList,(custom->color[0]),(WORD)0x001);
	CMOVE(uCopList,(custom->color[16]),(WORD)0x001);
	CWAIT(uCopList,SCREENY*15/32,0);
	CMOVE(uCopList,(custom->color[0]),(WORD)0x000);
	CMOVE(uCopList,(custom->color[16]),(WORD)0x000);
	CWAIT(uCopList,SCREENY-SCREENY*15/32,0);
	CMOVE(uCopList,(custom->color[0]),(WORD)0x010);
	CMOVE(uCopList,(custom->color[16]),(WORD)0x010);
	CWAIT(uCopList,SCREENY-SCREENY*7/16,0);
	CMOVE(uCopList,(custom->color[0]),(WORD)0x020);
	CMOVE(uCopList,(custom->color[16]),(WORD)0x020);
	CWAIT(uCopList,SCREENY-SCREENY*3/8,0);
	CMOVE(uCopList,(custom->color[0]),(WORD)0x030);
	CMOVE(uCopList,(custom->color[16]),(WORD)0x030);
	CWAIT(uCopList,SCREENY-SCREENY/4,0);
	CMOVE(uCopList,(custom->color[0]),(WORD)0x040);
	CMOVE(uCopList,(custom->color[16]),(WORD)0x040);

	CEND(uCopList);
	Forbid();
	if (Screen->ViewPort.UCopIns==NULL) Screen->ViewPort.UCopIns=uCopList;
	else printf("Error setting up Copper List\n");
	Permit();
	MakeScreen(Screen);
	RethinkDisplay();
}


/**************************************************************************
* Init routine.  Opens Mapscreen and stuff.
**************************************************************************/
void SetUpMap()
{
	short i,j;

    SetUpBitMap(&mapbm,320,80,2,320>>3);
	MapNewScreen.CustomBitMap=&mapbm;

	if (!(mapscreen = (struct Screen *)OpenScreen(&MapNewScreen)))
	{
		printf("MapScreen has no page!\n");
		Close_All();
		exit(FALSE);
	}

	MapNewWindow.Screen = mapscreen;

	if (!(mapwindow = (struct Window *)OpenWindow(&MapNewWindow)))
	{
		printf("MapWindow will not open!\n");
		Close_All();
		exit(FALSE);
	}

	maprp=mapwindow->RPort;
	ShowTitle(mapscreen,0);
	MoveScreen(mapscreen,0,150);
	PlotMap();
}

/**************************************************************************
* I guess this draws the top view of the map for PlotYou.
**************************************************************************/
void PlotMap()
{
	short i,pt1,pt2,sx,sy,dx,dy;
	SetAPen(maprp,1);
	for	(i=0;i<numedges;i++) {
		pt1=edges[i][0]-1;
		pt2=edges[i][1]-1;
		sx=points[pt1][0]*35/6+80;
		sy=40-points[pt1][2]*30/6;
		dx=points[pt2][0]*35/6+80;
		dy=40-points[pt2][2]*30/6;
		Move(maprp,sx,sy);
		Draw(maprp,dx,dy);
	}
}

/**************************************************************************
* This routine is not currently used.  If you put it back in, it will draw
* the top view of the dungeon, but you will always be in the center, and
* the rest of the dungeon will rotate and move around you.
**************************************************************************/
void PlotRotMap()
{
	short i,pt1,pt2,sx,soy,dx,dy;
	float Dx,Sx,Dz,Sz;

	SetAPen(maprp,0);
	RectFill(maprp,160,0,319,79);
	SetAPen(maprp,1);

	for	(i=0;i<numedges;i++) {
		pt1=edges[i][0]-1;
		pt2=edges[i][1]-1;
		Sx=points[pt1][0];
		Sz=points[pt1][2];
		Dx=points[pt2][0];
		Dz=points[pt2][2];
		sx=(Sx*cy-Sz*sy)*30/6+240;
		soy=40-(Sx*sy+Sz*cy)*25/6;
		dx=(Dx*cy-Dz*sy)*30/6+240;
		dy=40-(Dx*sy+Dz*cy)*25/6;
		Move(maprp,sx,soy);
		Draw(maprp,dx,dy);
	}
}

/**************************************************************************
* This routine just plots the overhead view of the dungeon.  It draws a box
* around you, with a white line inside of it pointing in the direction that
* you are facing.  The "s" key will disable this from being drawn during the
* game to speed things up.  This routine only draws to the "mapscreen".
**************************************************************************/
void PlotYou()
{
	static short savex,savey,savex1,savey1;
	short x,y,x1,y1;
	x=transX*35/6+80;
	y=40-transY*30/6;

	y1=y-cos(angle*FIX)*BOX;
	x1=x+sin(angle*FIX)*BOX;

	SetAPen(maprp,0);
	Move(maprp,savex,savey);
	Draw(maprp,savex1,savey1);

	Move(maprp,(long)(savex+BOX),(long)(savey-BOX));
	Draw(maprp,(long)(savex+BOX),(long)(savey+BOX));
	Draw(maprp,(long)(savex-BOX),(long)(savey+BOX));
	Draw(maprp,(long)(savex-BOX),(long)(savey-BOX));
	Draw(maprp,(long)(savex+BOX),(long)(savey-BOX));

	SetAPen(maprp,2);
	Move(maprp,x,y);
	Draw(maprp,x1,y1);
	SetAPen(maprp,3);

	Move(maprp,(long)(x+BOX),(long)(y-BOX));
	Draw(maprp,(long)(x+BOX),(long)(y+BOX));
	Draw(maprp,(long)(x-BOX),(long)(y+BOX));
	Draw(maprp,(long)(x-BOX),(long)(y-BOX));
	Draw(maprp,(long)(x+BOX),(long)(y-BOX));

	savex=x; savey=y;
	savex1=x1; savey1=y1;
}

/**************************************************************************
* This routine checks to see if any of the points in the dungeon are inside
* a small box around your current location.  If any are, then it returns
* a value that says that you can't move in the current direction, because
* it would put you inside a wall.
* Returns edge number of the point in the box.  If that edge<numedges,
* then that point is a midpoint.
**************************************************************************/
short PointInBox(float x,float y)
{
float x1,x2,y1,y2;
register short i;
register float *sptemp;

	x1 = x-0.62+100;
	x2 = x+0.62+100;
	y1 = y-0.62+100;
	y2 = y+0.62+100;

	for (i=0;i<numpoints+numedges;i++) {
		sptemp=subpoints[i];
		if (sptemp[0]>x1 && sptemp[0]<x2 &&
			sptemp[2]>y1 && sptemp[2]<y2) {
			return i;
		}
	}
	return 0;
}

short inside=0;
/**************************************************************************
* Subdivides each edge to find midpoint and stores the midpoint in the
* points array.  Midpoints block you from walking through the centers
* of walls.
**************************************************************************/
void SubDivide()
{
short i,j;
short pt1,pt2;
	for (i=0;i<numedges;i++)
	{
		pt1=edges[i][0]-1;
		pt2=edges[i][1]-1;

		subpoints[i][0]=(points[pt1][0]+points[pt2][0])/2+100;
		subpoints[i][2]=(points[pt1][2]+points[pt2][2])/2+100;
	}
	for (i=0;i<numpoints;i++)
	{
		subpoints[i+numedges][0]=points[i][0]+100;
		subpoints[i+numedges][1]=points[i][1]+100;
		subpoints[i+numedges][2]=points[i][2]+100;
	}
}

float oldtransX=0;
float oldtransY=0;
short a,b,testitem=-1;
char c;
float distance, distance1, oldangle, deltaangle;
short resmode=0;

/**************************************************************************
* Returns the direction something is facing from a given angle.
**************************************************************************/
BYTE Direction(float angle)
{
	if (angle>314 || angle<45) return NORTH;
	if (angle>44 && angle<135) return EAST;
	if (angle>134 && angle<225) return SOUTH;
	if (angle>224 && angle<315) return WEST;
}

/**************************************************************************
* Makes 8 light tables (one for each possible shifted position) Used
* to remove a shift instruction from the innermost megadraw i-loop.
**************************************************************************/
void MakeLightTable() {
	short i,j;

	/* This makes the lighttable have shifted values to save 1 instruction
	in megadraw */

	lighttable=(ULONG *)malloc(16*16*4*8);
	if(!lighttable) {
		printf("could not alloc lighttable\n");
  		exit(1);
	}
	for(i=0;i<8;i++)
		for(j=0;j<16*16;j++)
			lighttable[i*16*16+j]=lighttable_base[j]<<i;
}


/**************************************************************************
* choose screenx, screeny
**************************************************************************/
void ChooseSize(BOOL first)
{
short i,j,tempx=256,tempy=128;
ULONG class;
USHORT code;
struct IntuiMessage  *message1;
short oldx,oldy;
char  text[256];

	oldx=screenx;oldy=screeny;

	SetAPen(rp,0);
	RectFill(rp,0,0,screenx,screeny);
	SetAPen(rp,14);
	RectFill(rp,0,0,tempx,tempy);
	SetAPen(rp,2);
	Move(rp,(screenx-18*8)/2,20);
	Text(rp,"Select Screen Size",18);
	Move(rp,(screenx-20*8)/2,30);
	Text(rp,"Using Numeric Keypad",20);
	Move(rp,(screenx-20*8)/2,40);
	Text(rp,"Press Space to begin",20);
	sprintf(text,"Now: %d by %d",tempx,tempy);
	Move(rp,(screenx-strlen(text)*8)/2,50);
	Text(rp,text,strlen(text));

	FOREVER
	{
		if ((message1 = (struct IntuiMessage *)GetMsg(FirstWindow->UserPort)) == NULL)
		{
			Wait(1L << FirstWindow->UserPort->mp_SigBit);
			continue;
		}
		class = message1->Class;
		code = message1->Code;
		ReplyMsg((struct Message *)message1);
		if (class & VANILLAKEY)
		{
			if (code==' ') break;
			else if (code=='8') tempy-=32;
			else if (code=='2') tempy+=32;
			else if (code=='4') tempx-=32;
			else if (code=='6') tempx+=32;
			else if (code=='5') { tempx=256; tempy=128; }
			else if (code=='7') { tempx-=32; tempy-=32; }
			else if (code=='9') { tempx+=32; tempy-=32; }
			else if (code=='1') { tempx-=32; tempy+=32; }
			else if (code=='3') { tempx+=32; tempy+=32; }
			if (tempx<64) tempx=64;
			if (tempy<64) tempy=64;
			if (tempx>352) tempx=352;
			if (tempy>224) tempy=224;

			SetAPen(rp,0);
			RectFill(rp,0,0,screenx,screeny);
			SetAPen(rp,14);
			RectFill(rp,0,0,tempx,tempy);
			SetAPen(rp,2);
			Move(rp,(screenx-18*8)/2,20);
			Text(rp,"Select Screen Size",18);
			Move(rp,(screenx-20*8)/2,30);
			Text(rp,"Using Numeric Keypad",20);
			Move(rp,(screenx-20*8)/2,40);
			Text(rp,"Press Space to begin",20);
			sprintf(text,"Now: %d by %d",tempx,tempy);
			Move(rp,(screenx-strlen(text)*8)/2,50);
			Text(rp,text,strlen(text));
		}
	}
	screenx=tempx;
	screeny=tempy;
	x2=SCREENX/2; y2=SCREENY/2;
	Open_All(1,oldx,oldy);
}

main(int argc,char **argv)
{
short i,j,xauto=0,yauto=0,zauto=0;
float xplus,yplus,zplus;
ULONG class;
USHORT code;
int oldx,oldy;
int rot=0;
float addx, addy;
struct IntuiMessage  *message;
APTR tempbmp;
struct ViewPort *vp;
short offangle=0;
float forward=0;

    rowlookHR = (ULONG *)malloc (256 * 512 * sizeof(ULONG));
    rowlookLR = (ULONG *)malloc (256 * 512 * sizeof(ULONG));
    if (rowlookHR==0 || rowlookLR==0) {
    	printf("not enough memory for internal arrays.\n");
    	exit(1);
    }
    loadwalls();
	screenx=352;
	screeny=224;
	x2=SCREENX/2; y2=SCREENY/2;
	Open_All(0,0,0);
	ChooseSize(1);
	if (argc!=2) strcpy(filename,"dungeon"); else strcpy(filename,argv[1]);
	ReadScene();
	SubDivide();
	MakeLightTable();
	vp=&Screen->ViewPort;
	Brightness(0,3);
/*	LoadItems();*/

	LoadCopper();
	forward= ((SCREENY/2 - y2)/5);
	forward/=30;
	offangle = (x2 - SCREENX/2)/6;
	angle += offangle;
	if (angle<0)   angle+=360; else
	if (angle>360) angle=angle-360;
	cy=cos(angle*FIX);
	sy=sin(angle*FIX);
	transY+=cy*forward;
	transX+=sy*forward;
	cpuclear((void *)fastbm.Planes[0],fastbm.BytesPerRow*4*fastbm.Rows);
	DrawScene();
	Fill();
	if(halfres) fasttochip2(&bm1); else  fasttochip(&bm1);
	SetAPen(rp,1);
	Move(rp,(screenx-18*8)/2,10);
	Text(rp,"Rotation Demo V3.0",18);
	Move(rp,(screenx-8*8)/2,20);
	Text(rp,"(c) 1993",8);
	Move(rp,(screenx-12*8)/2,40);
	Text(rp,"Jason Freund",12);
	Move(rp,(screenx-11*8)/2,50);
	Text(rp,"Gabe Dalbec",11);
	SetAPen(rp,4);
	Move(rp,(screenx-18*8)/2,11);
	Text(rp,"Rotation Demo V3.0",18);
	Move(rp,(screenx-8*8)/2,21);
	Text(rp,"(c) 1993",8);
	Move(rp,(screenx-12*8)/2,41);
	Text(rp,"Jason Freund",12);
	Move(rp,(screenx-11*8)/2,51);
	Text(rp,"Gabe Dalbec",11);

	if(screeny>64) {
		SetAPen(rp,1);
		Move(rp,(screenx-11*8)/2,60);
		Text(rp,"Chris Hames",11);
		Move(rp,(screenx-18*8)/2,70);
		Text(rp,"Click LMB to Start",18);

		SetAPen(rp,4);
		Move(rp,(screenx-11*8)/2,61);
		Text(rp,"Chris Hames",11);
		Move(rp,(screenx-18*8)/2,71);
		Text(rp,"Click LMB to Start",18);
	}

/*	GetInput(&a,&b,&c);*/
    StartTTimer(); /* Start Total Timer */

	FOREVER
	{
		if ((message = (struct IntuiMessage *)GetMsg(FirstWindow->UserPort)) == NULL)
		{
			MoveDoors();
			angle+=yauto;
			if (moveok)
			{
				forward= ((SCREENY/2 - y2)/5);
				forward/=30;
				offangle = (x2 - SCREENX/2)/6;
				angle += offangle;
				if (angle<0)   angle+=360; else
				if (angle>360) angle=angle-360;
				cy=cos(angle*FIX);
				sy=sin(angle*FIX);
				transY+=cy*forward;
				transX+=sy*forward;
				if (PointInBox(transX,transY))
					if (!PointInBox(oldtransX,transY))
						transX=oldtransX; else
						if (!PointInBox(transX,oldtransY)) transY=oldtransY; else
						{
							transX=oldtransX;
							transY=oldtransY;
						}
			}
/* auto */  if (resmode==0)
			{
				distance = fabs(transX-oldtransX);
				distance *= distance;
				distance1 = fabs(transY-oldtransY);
				distance1 *= distance1;
				distance += distance1;
				deltaangle = fabs(offangle);
				if (halfres==0 && (deltaangle>6 || distance>0.075)) ToggleRes(); else
				if (halfres && (deltaangle<7 || distance<0.075001)) ToggleRes();
			} else
/* hires */	if (resmode==1 && halfres) ToggleRes(); else
/* lores */ if (resmode==2 && halfres==0) ToggleRes();
			AnimWalls();
			cpuclear((void *)fastbm.Planes[0],fastbm.BytesPerRow*4*fastbm.Rows);
			DrawScene();
			Fill();
			/* WaitBOVP(vp); */
			if(halfres) fasttochip2(&bm1); else  fasttochip(&bm1);
/*			if (testitem>-1) BlitMe(134,30, Items[0][testitem]);*/
			oldtransX=transX;
			oldtransY=transY;
			oldangle = angle;
			continue;
		}
		class = message->Class;
		code = message->Code;
		x2=message->MouseX;
		y2=message->MouseY;
		if (y2<0) y2=0;
		if (x2<0) x2=0;
		if (x2>SCREENX) x2=SCREENX;
		if (y2>SCREENY) y2=SCREENY;
		ReplyMsg((struct Message *)message);

		if (class & VANILLAKEY)
		{
			oldtransX=transX;
			oldtransY=transY;
			if (code=='q') break;
			else if (code=='r') { transY=0; transX=0; angle=0;}
			else if (code=='5') {
				transY-=cos(angle*FIX)*.2;
				transX-=sin(angle*FIX)*.2;
			}
			else if (code=='8') {
				transY+=cos(angle*FIX)*.2;
				transX+=sin(angle*FIX)*.2;
			}
			else if (code=='4') {
				transX-=cos(angle*FIX)*.1;
				transY+=sin(angle*FIX)*.1;
			}
			else if (code=='6') {
				transX+=cos(angle*FIX)*.1;
				transY-=sin(angle*FIX)*.1;
			}
			else if (code=='7') angle-=ROTATE;
			else if (code=='9') angle+=ROTATE;
			else if (code=='y') yauto++;
			else if (code=='Y') yauto--;
			else if (code=='r') PlotMap();
			else if (code=='s') speed=!speed;
			else if (code==' ') ActivateDoor();
			else if (code=='l') resmode=2;
			else if (code=='a') resmode=0;
			else if (code=='h') resmode=1;
			else if (code==',') Brightness(-1,0);
			else if (code=='.') Brightness(1,0);
			xplus=0; yplus=0; zplus=0;

			if (PointInBox(transX,transY))
				if (!PointInBox(oldtransX,transY))
					transX=oldtransX; else
					if (!PointInBox(transX,oldtransY)) transY=oldtransY; else
					{
						transX=oldtransX;
						transY=oldtransY;
					}

		}
		else if (class & MOUSEBUTTONS)
		{
			if (code == SELECTDOWN) {}
			if (code == SELECTUP) {}
			if (code == MENUDOWN)
				moveok=!moveok;
			if (code == MENUUP) {}
		}

	}

    EndTTimer(); /* Stop Total Timer - Show fps */
    printf("screenx %d screeny %d\n",screenx,screeny);
    printf("pixels %d / sec %lf = %lf\n",(Frames*screenx*screeny),(float)(((TimerStuff->ttime2.ev_lo-TimerStuff->ttime1.ev_lo)/(float)TimerStuff->EFreq)),
		(Frames*screenx*screeny)/(float)(((TimerStuff->ttime2.ev_lo-TimerStuff->ttime1.ev_lo)/(float)TimerStuff->EFreq)));
	Close_All();
	exit(TRUE);
}

