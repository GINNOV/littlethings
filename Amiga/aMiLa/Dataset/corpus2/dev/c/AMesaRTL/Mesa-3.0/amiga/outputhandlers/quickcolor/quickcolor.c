//#define DB kprintf
#define DB / ## /

#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <intuition/intuition.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/utility.h>
#include <proto/exec.h>
#include <proto/layers.h>

#include <proto/dos.h>
#include <dos/rdargs.h>
#include <dos/dos.h>

#include <graphics/gfxbase.h>

#include "gl/outputhandler.h"

#define ARGSKEY "NoDither/S,_LA1_Own_Window_Parameters/K,NAMED=_MX_Public_Screen/S,DEFAULT=_MX_Default_Screen/S,CUSTOM=_MX_Full_Screen/S,NAME=Screen_Name,_LA1_Full_Screen_Parameters/K,_SM_Mode,Width/N,Height/N"

char screenname[40];

struct prefs
{
long nodither;
long dummy;
long namedscreen,defaultscreen,customscreen;
char *name;
long dummy2;
long mode,width,height;
} prefs,defaultprefs={0,0,1,0,0,"Mesa"};

char *outputtypes[]={"Window","RPortVPort",0};

#define MAXPENS 256

#define INRBITS	5
#define INGBITS	5
#define INBBITS	4

#define BITMASK(n) ((1<<n)-1)

#define SHIFTR (INRBITS+INGBITS+INBBITS-8)
#define SHIFTG (INGBITS+INBBITS-8)
#define SHIFTB (INBBITS-8)

#if SHIFTR>0
#define MAKESHR(x) (x<<SHIFTR)
#else
#define MAKESHR(x) (x>>(-(SHIFTR)))
#endif

#if SHIFTG>0
#define MAKESHG(x) (x<<SHIFTG)
#else
#define MAKESHG(x) (x>>(-(SHIFTG)))
#endif

#if SHIFTB>0
#define MAKESHB(x) (x<<SHIFTB)
#else
#define MAKESHB(x) (x>>(-(SHIFTB)))
#endif

#define INRMASK (BITMASK(INRBITS)<<(INBBITS+INGBITS))
#define INGMASK (BITMASK(INGBITS)<<(INBBITS))
#define INBMASK BITMASK(INBBITS)

#define RGBLOOKUP(r,g,b) ( (MAKESHR(r)&INRMASK) + (MAKESHG(g)&INGMASK) + (MAKESHB(b)&INBMASK) )

#define MAXLOOKUP (1<<(INRBITS+INGBITS+INBBITS))

#define OUTRBITS	3
#define OUTGBITS	3
#define OUTBBITS	2

#define MAXOUTR	(1<<OUTRBITS)
#define MAXOUTG	(1<<OUTGBITS)
#define MAXOUTB	(1<<OUTBBITS)

#define OUTINDEX(r,g,b) ((((r<<OUTGBITS)+g)<<OUTBBITS)+b)

#define MAKE32(v,bits) (((((v<<bits)+v)<<bits)+v)<<(32-3*bits))
#define MAKE8(v,bits) (MAKE32(v,bits)>>24)

AmigaMesaRTLContext mesacontext;
struct Window *window;
struct Screen *screen;
ULONG mode;
struct BitMap *tmpbm;
struct RastPort tmprp;
UBYTE pens[MAXPENS];
UBYTE penstate[MAXPENS];
#define PEN_FREE		0
#define PEN_HAVE		1
#define PEN_CHANGED	2
UBYTE *qbuffer;
short havepens;
ULONG numc;
UBYTE lookup[MAXLOOKUP];
UBYTE realpal[3*MAXPENS];
int bufwidth,bufheight;
int fullwindow;
int newpalette;
UBYTE clamp[3*256];
short mywindow;
short myscreen;

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

void ReadPrefs(char *p)
{
char *pr=malloc(strlen(p)+2);
struct RDArgs *my_rda=0,*rda=0;
prefs=defaultprefs;
strcpy(pr,p);
strcat(pr,"\n");
if (my_rda=AllocDosObject(DOS_RDARGS,0))
	{
	my_rda->RDA_Source.CS_Buffer=pr;
	my_rda->RDA_Source.CS_Length=strlen(pr);
	rda=ReadArgs(ARGSKEY,&prefs,my_rda);
	if (rda)
		{
		prefs.mode = strtol(prefs.mode,NULL,0);

		if (prefs.namedscreen)
			{
			if (prefs.name)
				{
				strncpy(screenname,prefs.name,39);
				screenname[39]=0;
				prefs.name=screenname;
				}
			else prefs.name=defaultprefs.name;
			}
		prefs.width=prefs.width?*(long*)prefs.width:0;
		prefs.height=prefs.height?*(long*)prefs.height:0;
DB("prefs.width=%ld\n",prefs.width);
DB("prefs.height=%ld\n",prefs.height);
		FreeArgs(rda);
		}
	else prefs=defaultprefs;
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

int findbest(UBYTE r,UBYTE g,UBYTE b)
{
int i;
int bestv=3*256,besti,d;
UBYTE *rgb;
if (prefs.customscreen)
for (i=0,rgb=realpal;i<numc;i++,rgb+=3)
	{
	d=abs((int)rgb[0]-(int)r)+abs((int)rgb[1]-(int)g)+abs((int)rgb[2]-(int)b);
	if (d<bestv) {bestv=d; besti=i;}
	}
else
for (i=0;i<numc;i++)
	{
	rgb=realpal+3*pens[i];
	d=abs((int)rgb[0]-(int)r)+abs((int)rgb[1]-(int)g)+abs((int)rgb[2]-(int)b);
	if (d<bestv) {bestv=d; besti=i;}
	}
return besti;
}

void AllocPens(int makelookup)
{
unsigned char got[MAXPENS];
int i,r,g,b,rs,gs,bs,ready,n=0;
ULONG rgb[3];
UBYTE *pal;

if ((mode==AMRTL_IndexMode)&&(prefs.customscreen))
	return;

if ((!havepens)&&(rpvp.VPort))
	{
	numc=min(256,rpvp.VPort->ColorMap->Count);
DB("alloc pens(%ld)\n",numc);

	rs=256;gs=256;bs=256;
	ready=0;
	memset(got,0,MAXPENS);
	for (;;)
		{
		for (r=0;r<=256;r+=rs)
		for (g=0;g<=256;g+=gs)
		for (b=0;b<=256;b+=bs)
		{
		if (r==256) r--;
		if (g==256) g--;
		if (b==256) b--;
		i=((((r>>(8-OUTRBITS))<<OUTGBITS)+(g>>(8-OUTGBITS)))<<OUTBBITS)+(b>>(8-OUTBBITS));
		if (got[i]) continue;
DB("%lx%lx%lx ",r,g,b);
		if (prefs.customscreen)
			SetRGB32(rpvp.VPort,n++,r<<24,g<<24,b<<24);
		else
			pens[ready]=ObtainBestPen(rpvp.VPort->ColorMap,
				r<<24,g<<24,b<<24,0);
		got[i]=1;
		ready++;
		if (ready>=numc) goto finished;
		}
		if ((rs>>=1)<(1<<(8-OUTRBITS))) rs<<=1;
		if ((gs>>=1)<(1<<(8-OUTGBITS))) gs<<=1;
		if ((bs>>=1)<(1<<(8-OUTBBITS))) bs<<=1;
		}
	finished:
DB("allocated\n");

	for (i=0,pal=realpal;i<numc;i++,pal+=3)
		{
		GetRGB32(rpvp.VPort->ColorMap,i,1,rgb);
		pal[0]=rgb[0]>>24;
		pal[1]=rgb[1]>>24;
		pal[2]=rgb[2]>>24;
//		DB("realpal[%ld]=%lx,%lx,%lx\n",i,rgb[0],rgb[1],rgb[2]);
		}

	makelookup=1;
	}

if (makelookup)
	if (mode==AMRTL_RGBAMode)
	{
	for (r=1<<(7-INRBITS);r<256;r+=(1<<(8-INRBITS)))
	for (g=1<<(7-INGBITS);g<256;g+=(1<<(8-INGBITS)))
	for (b=1<<(7-INBBITS);b<256;b+=(1<<(8-INBBITS)))
		{
		i=RGBLOOKUP(r,g,b);
		if (prefs.customscreen)
			lookup[i]=findbest(r,g,b);
		else
			lookup[i]=pens[findbest(r,g,b)];
		i++;
		}
	}

havepens=1;
}

void FreePens(void)
{
int i;

if (prefs.customscreen) return;

if ((havepens)&&(rpvp.VPort))
	if (mode==AMRTL_RGBAMode)
	{
	for (i=0;i<numc;i++)
		ReleasePen(rpvp.VPort->ColorMap,pens[i]);
	}
	else
	{
	for (i=0;i<MAXPENS;i++)
		if (penstate[i]&PEN_HAVE)
			{
			ReleasePen(rpvp.VPort->ColorMap,pens[i]);
			penstate[i]&=~PEN_HAVE;
			}
	}
havepens=0;
}

void ChangeEnvironment(struct RPortVPort *chg)
{
if ((!chg)||(!(chg->VPort))) FreePens();

if ((!chg)||(!(chg->RPort))) DelWritePixelA8();

if (chg) rpvp=*chg; else memset(&rpvp,0,sizeof(rpvp));
}

void CreateMyWindow()
{
if (prefs.customscreen)
	{
	long sizetags[5],*tag=sizetags;
	if (prefs.width>0) {*(tag++)=SA_Width; *(tag++)=prefs.width;}
	if (prefs.height>0) {*(tag++)=SA_Height; *(tag++)=prefs.height;}
	*(tag++)=TAG_DONE;

	screen=OpenScreenTags(0,
		SA_Depth,8,
		SA_Quiet,1,
		SA_DisplayID,prefs.mode,
		TAG_MORE,sizetags);

	if (!screen) return;

	if (window = OpenWindowTags(NULL,
		WA_CustomScreen,		screen,
		WA_Width,				screen->Width,
		WA_Height,				screen->Height,
		WA_Activate,			TRUE,
		WA_CloseGadget,		TRUE,
		WA_Borderless,			TRUE,
		TAG_END))
		{
		window->BorderTop=0;
		SetRast(window->RPort,0);
		}
	myscreen=1;
	}
else
	{
	screen = LockPubScreen(prefs.namedscreen?prefs.name:0);
	window = OpenWindowTags(NULL,
		WA_Title,				"Mesa Display",
		WA_PubScreen,			screen,
		WA_Width,				100,
		WA_Height,				100,
		WA_MinWidth,			32,
		WA_MinHeight,			32,
		WA_MaxWidth,			~0,
		WA_MaxHeight,			~0,
		WA_NoCareRefresh,		TRUE,
		WA_Activate,			TRUE,
		WA_CloseGadget,			TRUE,
		WA_DragBar,				TRUE,
		WA_SizeGadget,			TRUE,
		WA_DepthGadget,			TRUE,
		TAG_END);
	UnlockPubScreen(NULL,screen);
	}
mywindow=1;
}

void DestroyMyWindow(void)
{
if (mywindow&&window) CloseWindow(window);
if (myscreen&&screen) CloseScreen(screen);
mywindow=0;
myscreen=0;
window=0;
screen=0;
}

__asm __saveds int InitOutputHandlerA(register __a0 AmigaMesaRTLContext ctx, register __a1 struct TagItem *tags)
{
	char *outputtype;
	void *output;
	int i;
	char pr[1000]={0};

	if (GfxBase->LibNode.lib_Version<39) return 0;

	mesadriverBase = (struct Library *)GetTagData(OH_DriverBase,NULL,tags);
	if(!mesadriverBase)
		return 0;

	AmigaMesaRTLGetContextAttr(AMRTL_Mode,ctx,&mode);

	GetVar("AmigaMesaRTL/quickcolor.prefs",pr,1000,0);
	ReadPrefs(GetTagData(OH_Parameters,pr,tags));

	qbuffer = NULL;
	havepens=0;
	mywindow=0;
	tmpbm=0;

	numc = 2;

	newpalette=0;
	memset(penstate,PEN_FREE,256);

	rpvp.RPort=0;
	rpvp.VPort=0;
	rpvp.LeftEdge=rpvp.TopEdge=0;
	rpvp.Width=16; rpvp.Height=16;

	mesacontext = ctx;
	outputtype = (char *)GetTagData(OH_OutputType,NULL,tags);
	output = (void*)GetTagData(OH_Output,NULL,tags);
	if (outputtype)
		{
		if (!stricmp(outputtype,"window"))
			{
			if (output)
				{
				window=(struct Window*)output;
				prefs.customscreen=0;
				}
			else CreateMyWindow();
			if (!window) return 0;
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

	for (i=0;i<256;i++) clamp[256+i]=i;
	memset(clamp,0,256);
	memset(clamp+512,255,256);

	return 1;
}

__asm __saveds void DeleteOutputHandler(void)
{
	FreePens();

	DelWritePixelA8();

	if(qbuffer) free(qbuffer);
	qbuffer = NULL;
	if (fullwindow) DestroyMyWindow();
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
unsigned char newpens[256],*remap;

AmigaMesaRTLGetContextAttr(AMRTL_Buffer,mesacontext,&buffer);

if ((!bufwidth)||(!bufheight)) {DisplayBeep(0); return 1;}
if (!qbuffer) return 1;

if (rpvp.VPort)
	{
	if(mode == AMRTL_RGBAMode)
	{
	if ((!havepens)||(newpalette)) AllocPens(newpalette);
	if (prefs.nodither)
		{
		for (q=qbuffer,in=buffer,i=bufwidth*bufheight;i>0;i--,q++,in+=4)
			*q=lookup[RGBLOOKUP(in[0],in[1],in[2])];
		}
	else
		{
		short r,g,b,re=0,ge=0,be=0;
		UBYTE *rgb;
		for (q=qbuffer,in=buffer,i=bufwidth*bufheight;i>0;i--,q++,in+=4)
			{
			r=clamp[256+re+in[0]];
			g=clamp[256+ge+in[1]];
			b=clamp[256+be+in[2]];
			*q=lookup[RGBLOOKUP(r,g,b)];
			rgb=realpal+3*(*q);
			re=(r-(short)rgb[0])/2;
			ge=(g-(short)rgb[1])/2;
			be=(b-(short)rgb[2])/2;
			}
		}
	}
	else
		{
	if (newpalette)
		{
		ULONG *pal;
		AmigaMesaRTLGetContextAttr(AMRTL_IndexPalette,mesacontext,&pal);
DB("Get Pens for index mode\n");

		for (i=0;i<MAXPENS;i++,pal+=3)
			if (penstate[i]&PEN_CHANGED)
			{
			newpens[i]=ObtainBestPen(rpvp.VPort->ColorMap,pal[0],pal[1],pal[2],0);
//			DB("pen %ld = ObtainBestPen(%lx,%lx,%lx) -> %x\n",i,pal[0],pal[1],pal[2],newpens[i]);
			}
		remap=newpens;
		} else remap=pens;

	if (prefs.customscreen)
		memcpy(qbuffer,buffer,bufwidth*bufheight);
	else
	for (q=qbuffer,in=buffer,i=bufwidth*bufheight;i>0;i--,q++,in++)
		*q=remap[*in];
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

if ((rpvp.VPort)&&(newpalette)&&(mode==AMRTL_IndexMode))
	{
	DB("After frame, clean up palette change\n");
	if (havepens) FreePens();
		for (i=0;i<MAXPENS;i++)
			if (penstate[i]&PEN_CHANGED)
				penstate[i]|=PEN_HAVE;
	memcpy(pens,newpens,MAXPENS);
	havepens=1;
	newpalette=0;
	DB("After frame, clean up palette change DONE\n");
	}

	return 1;
}


__asm __saveds void SetIndexRGBTable(register __d0 int index, register __a0 ULONG *rgbtable, register __d1 int numcolours)
{
if (prefs.customscreen)
	{
	for(numcolours+=index; (index<numcolours)&&(index<MAXPENS); index++,rgbtable+=3)
		SetRGB32(rpvp.VPort,index,rgbtable[0],rgbtable[1],rgbtable[2]);
	}
else
	{
	for(numcolours+=index; (index<numcolours)&&(index<MAXPENS); index++)
		penstate[index]|=PEN_CHANGED;
	newpalette=1;
	}
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
		default:
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
		case OH_OutputQuery:
			*((char ***)data) = outputtypes;
			break;
		default:
			return(0);
	}
return(1);
}


