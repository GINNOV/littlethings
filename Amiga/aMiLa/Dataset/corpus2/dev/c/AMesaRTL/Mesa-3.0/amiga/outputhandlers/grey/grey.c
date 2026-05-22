//#define DB kprintf
#define DB / ## /

//
// OUTPUT HANDLER FOR AMIGAMESARTL
// Szymon Ulatowski <szulat@friko6.onet.pl>
//
// supports "window" and "rportvport" output types
//

#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <intuition/intuition.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/utility.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/layers.h>
#include <dos/rdargs.h>
#include <dos/dos.h>

#include <graphics/gfxbase.h>

#include "gl/outputhandler.h"

#define ARGSKEY "Dither/S"

long dither=0;

#define MAXPENS 256

#define MAXLOOKUP (7*256)
#define RGBLOOKUP(r,g,b) (((r)<<1)+((g)<<2)+(b))

AmigaMesaRTLContext mesacontext;
struct Window *window;
ULONG mode;
struct BitMap *tmpbm;
struct RastPort tmprp;
UBYTE pens[MAXPENS];
UBYTE *qbuffer;
short havepens;
ULONG numc;
UBYTE lookup[MAXLOOKUP];
short realtab[MAXPENS];
int bufwidth,bufheight;
int fullwindow;
int newpalette;

struct RPortVPort
{
struct RastPort *RPort;
struct ViewPort *VPort;
long LeftEdge,TopEdge;
long Width,Height;
};

struct Library *mesadriverBase;
struct RPortVPort rpvp;

#define WINWIDTH(w)		((w)->Width - (w)->BorderLeft - (w)->BorderRight)
#define WINHEIGHT(w)	((w)->Height - (w)->BorderTop - (w)->BorderBottom)

void ReadPrefs(char *prefs)
{
char *pr=malloc(strlen(prefs)+2);
struct RDArgs *my_rda=0,*rda=0;
strcpy(pr,prefs);
strcat(pr,"\n");
DB("got prefs '%s'\n",prefs);
if (my_rda=AllocDosObject(DOS_RDARGS,0))
	{
	my_rda->RDA_Source.CS_Buffer=pr;
	my_rda->RDA_Source.CS_Length=strlen(pr);
	rda=ReadArgs(ARGSKEY,&dither,my_rda);
	if (rda) FreeArgs(rda);
	else dither=0;
	FreeDosObject(DOS_RDARGS,my_rda);
	}
free(pr);
}

BOOL InitWritePixelA8(void)
{
if (!rpvp.RPort) return 0;
	if (!(tmpbm=AllocBitMap(bufwidth,1,rpvp.RPort->BitMap->Depth,0,0)))
		return 0;

	tmprp = *(rpvp.RPort);
	tmprp.Layer = 0;
	tmprp.BitMap = tmpbm;

	return 1;
}

void DelWritePixelA8(void)
{
if (tmpbm) FreeBitMap(tmpbm);
tmpbm=0;
}

int findbest(int v)
{
int i;
int bestv=MAXLOOKUP,besti,d;
for (i=0;i<numc;i++)
	{
	d=abs(realtab[pens[i]]-v);
	if (d<bestv) {bestv=d; besti=i;}
	}
return pens[besti];
}

void AllocPens(int makelookup)
{
unsigned char got[MAXPENS];
unsigned long rgb[3];
int i,step,val,ready;

if ((!havepens)&&(rpvp.VPort))
	{
	numc=min(256,rpvp.VPort->ColorMap->Count);
	step=256; ready=0;
	memset(got,0,MAXPENS);
	for (;;)
		{
		for (val=0;val<=256;val+=step)
			{
			if (val==256) val=255;
			if (got[val]) continue;
			pens[ready]=ObtainBestPen(rpvp.VPort->ColorMap,
				val*0x01010101,val*0x01010101,val*0x01010101,0);
			got[val]=1;
			ready++;
			if (ready>=numc) goto finished;
			}
		step/=2;
		}
	finished:

	for (i=0;i<numc;i++)
		{
//		GetRGB32(rpvp.VPort->ColorMap,pens[i],1,rgb);
		GetRGB32(rpvp.VPort->ColorMap,i,1,rgb);
		realtab[i]=RGBLOOKUP(rgb[0]>>24,rgb[1]>>24,rgb[2]>>24);
		}
	makelookup=1;
	}

if (makelookup)
{
if (mode==AMRTL_RGBAMode)
//for (i=0;i<MAXLOOKUP;i++)	lookup[i]=pens[findbest(i)];
for (i=0;i<MAXLOOKUP;i++)	lookup[i]=findbest(i);
else
	{
	ULONG *pal;
	AmigaMesaRTLGetContextAttr(AMRTL_IndexPalette,mesacontext,&pal);
	for (i=0;i<MAXPENS;i++,pal+=3)
		lookup[i]=findbest(RGBLOOKUP(pal[0]>>24,pal[1]>>24,pal[2]>>24));
//		lookup[i]=pens[findbest(RGBLOOKUP(pal[0]>>24,pal[1]>>24,pal[2]>>24))];
	}
}
havepens=1;
}

void FreePens(void)
{
int i;
if ((havepens)&&(rpvp.VPort))
	{
	for (i=0;i<numc;i++)
		ReleasePen(rpvp.VPort->ColorMap,pens[i]);
	}
havepens=0;
}

void ChangeEnvironment(struct RPortVPort *chg)
{
if ((!chg)||(!(chg->VPort))) FreePens();

if ((!chg)||(!(chg->RPort))) DelWritePixelA8();

if (chg) rpvp=*chg; else memset(&rpvp,0,sizeof(rpvp));
}

__asm __saveds int InitOutputHandlerA(register __a0 AmigaMesaRTLContext ctx, register __a1 struct TagItem *tags)
{
	char *outputtype;
	void *output;
	char prefs[1000]={0};

	if (GfxBase->LibNode.lib_Version<39) return 0;

	mesadriverBase = (struct Library *)GetTagData(OH_DriverBase,NULL,tags);
	if(!mesadriverBase)
		return 0;

	AmigaMesaRTLGetContextAttr(AMRTL_Mode,ctx,&mode);

	GetVar("AmigaMesaRTL/grey.prefs",prefs,1000,0);
	ReadPrefs(GetTagData(OH_Parameters,prefs,tags));

	qbuffer = NULL;
	havepens=0;

	tmpbm=0;

	numc = 2;

	newpalette=0;
	rpvp.RPort=0;
	rpvp.VPort=0;
	rpvp.LeftEdge=rpvp.TopEdge=0;
	rpvp.Width=16; rpvp.Height=16;

	mesacontext = ctx;
	outputtype = (char *)GetTagData(OH_OutputType,NULL,tags);
	output = (void*)GetTagData(OH_Output,NULL,tags);
	if (outputtype)
		{
		if (output&&(!stricmp(outputtype,"window")))
			{
			window=(struct Window*)output;
			rpvp.TopEdge=window->BorderTop;
			rpvp.LeftEdge=window->BorderLeft;
			rpvp.RPort=window->RPort;
			rpvp.VPort=ViewPortAddress(window);
			numc=min(256,rpvp.VPort->ColorMap->Count);
			fullwindow=1;
			}
		else if (!stricmp(outputtype,"rportvport"))
			{
			fullwindow=0;
			ChangeEnvironment(output);
			}
		else return 0;
		}
	else return 0;

	return 1;
}

__asm __saveds void DeleteOutputHandler(void)
{
	FreePens();

	DelWritePixelA8();

	if(qbuffer) free(qbuffer);
	qbuffer = NULL;

mesadriverBase=0;
}

__asm __saveds int ResizeOutputHandler(void)
{
// if (!rpvp.RPort) return;
	DelWritePixelA8();
	if(qbuffer) free(qbuffer);
	qbuffer = NULL;

AmigaMesaRTLGetContextAttr(AMRTL_BufferWidth,
	mesacontext,&bufwidth);
AmigaMesaRTLGetContextAttr(AMRTL_BufferHeight,
	mesacontext,&bufheight);

AmigaMesaRTLGetContextAttr(AMRTL_OutputWidth,
	mesacontext,&rpvp.Width);
AmigaMesaRTLGetContextAttr(AMRTL_OutputHeight,
	mesacontext,&rpvp.Height);

	qbuffer = (UBYTE *)calloc(bufwidth * bufheight, sizeof(UBYTE));

	InitWritePixelA8();

	return 1;
}

__asm __saveds int ProcessOutput(void)
{
UBYTE *buffer,*in;
int i;
unsigned char *q;

AmigaMesaRTLGetContextAttr(AMRTL_Buffer,mesacontext,&buffer);

if ((!bufwidth)||(!bufheight)) {DisplayBeep(0); return 1;}
if (!qbuffer) return 1;

if (rpvp.VPort)
	{
	if ((!havepens)||(newpalette)) AllocPens(newpalette);

	if(mode == AMRTL_RGBAMode)
		{
if (dither)
		{
		short error=0,b;
		for (q=qbuffer,in=buffer,i=bufwidth*bufheight;i>0;i--,q++,in+=4)
			{
			b=(short)RGBLOOKUP(in[0],in[1],in[2])+error;
			*q=lookup[max(0,min((MAXLOOKUP-1),b))];
			error=(b-realtab[*q])/2;
			}
		}
else
		for (q=qbuffer,in=buffer,i=bufwidth*bufheight;i>0;i--,q++,in+=4)
			*q=lookup[RGBLOOKUP(in[0],in[1],in[2])];
		}
	else
		{
		for (q=qbuffer,in=buffer,i=bufwidth*bufheight;i>0;i--,q++,in++)
			*q=lookup[*in];
		}
	}
if (rpvp.RPort)
	{
	struct Region *re=0,*oldre;
	if (!tmpbm) InitWritePixelA8();

	if (fullwindow)
		{
		if ((rpvp.Width>WINWIDTH(window))||(rpvp.Height>WINHEIGHT(window)))
			{
			struct Rectangle rect;
DB("wpa8 needs clipping!\n");
			rect.MinX=window->BorderLeft;
			rect.MinY=window->BorderTop;
			rect.MaxX=window->BorderLeft+WINWIDTH(window)-1;
			rect.MaxX=window->BorderTop+WINHEIGHT(window)-1;
			re=NewRegion();
			OrRectRegion(re,&rect);
			oldre=InstallClipRegion(rpvp.RPort->Layer,re);
			}
		}

	WritePixelArray8(rpvp.RPort,
     rpvp.LeftEdge , rpvp.TopEdge,
     rpvp.LeftEdge + rpvp.Width-1, rpvp.TopEdge + rpvp.Height-1,
     qbuffer, &(tmprp));

	if (re)
		{
		InstallClipRegion(rpvp.RPort->Layer,oldre);
		DisposeRegion(re);
		}
	}
	return 1;
}


__asm __saveds void SetIndexRGBTable(register __d0 int index, register __a0 ULONG *rgbtable, register __d1 int numcolours)
{
newpalette=1;
}

__asm __saveds ULONG SetOutputHandlerAttrsA(register __a0 struct TagItem *tags)
{
struct TagItem *tstate, *tag;
ULONG tidata;

tstate = tags;
while(tag = NextTagItem(&tstate))
{
	tidata = tag->ti_Data;
	switch(tag->ti_Tag)
	{
		case OH_Output:
			if (!fullwindow) ChangeEnvironment((struct RPortVPort*)tidata);
			break;
/*		case OH_NumColours:
			SetColourRange(reqfirstc,tidata);
			break;
*/		default:
			break;
	}
}
return(0);
}


__asm __saveds ULONG GetOutputHandlerAttr(register __d0 ULONG attr, register __a0 ULONG *data)
{
	switch(attr)
	{
		case OH_Output:
			*((struct Window **)data) = window;
			break;
		case OH_OutputType:
			*((char **)data) = "Window";
			break;
		case OH_Width:
			if (fullwindow) *data=WINWIDTH(window);
			else	*data = rpvp.Width;
			break;
		case OH_Height:
			if (fullwindow) *data=WINHEIGHT(window);
			else	*data = rpvp.Height;
			break;
		case OH_NumColours:
			*((ULONG *)data) = numc;
			break;
		case OH_ParameterQuery:
			*((char **)data) = ARGSKEY;
			break;
		default:
			return(0);
	}
return(1);
}


/*
long __saveds __asm __UserLibInit(register __a6 long x)
{
kprintf("userlibinit %lx\n",x);
return 0;
}
*/

