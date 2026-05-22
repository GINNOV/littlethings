/*
 * dl1quant.c
 *
 * Modified  27 Jun 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * Some minor additions and changes to work with AmigaMesaRTL
 *
 * Version 1.1  02 Aug 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to a quantizer plugin library
 *
 *   06 Aug 1998
 * - from now called 'dl1plus'
 *   maintained by Szymon Ulatowski <szulat@friko6.onet.pl>
 * - pen sharing
 *   11 Aug 1998
 * - optimized palette change
 *   16 Aug 1998
 * - uses v2 quantizer interface
 *   17 Aug 1998
 * - output type "RPortVPort" implemented
 *   12 Sep 1998
 * - adapted to the new amigamesartl interface
 */

//#define DB kprintf
#define DB / ## /

#define DL1SRC

#include <stdlib.h>
#include <string.h>
#include "dl1quant.h"

#include <time.h>
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

/********** The following are options **********/

//#define FAST        /* improves speed but uses a lot of memory */
//#define QUAL1       /* improves quality slightly (slower) */
//#define QUAL2       /* improves quality slightly (slower) */

/* define *one* of the following dither options */
#define DITHER1     /* 1-val error diffusion dither */
//#define DITHER2     /* 2-val error diffusion dither */
//#define DITHER4     /* 4-val error diffusion dither (Floyd-Steinberg) */

#define ERRORCONTROL

/********** End of options **********/

#define DITHER_MAX  20

LOCAL uchar palette[3][256];
LOCAL CUBE *rgb_table[6];
LOCAL ushort r_offset[256], g_offset[256], b_offset[256];
LOCAL CLOSEST_INFO c_info;
LOCAL int tot_colors, pal_index, did_init = 0;
LOCAL ulong *squares;
LOCAL FCUBE *heap = NULL;
LOCAL short *dl_image = NULL;

LOCAL int bufwidth,bufheight;
LOCAL ulong globalerror,fresherror;
LOCAL char txttmp[50];
LOCAL ulong lasttime=0;
LOCAL int newpalette=0;
LOCAL int fullwindow=0;

#define MAXPENS 256

struct dl1Context {
	AmigaMesaRTLContext mesacontext;
	struct Window *window;
	ULONG mode;
	struct BitMap *tmpbm;
	struct RastPort tmprp;
	UBYTE pens[MAXPENS];
	BYTE penstate[MAXPENS];
	UBYTE *qbuffer;
	short havepens;
	ULONG numc, firstc;
};

#define PEN_FREE		0
#define PEN_HAVE		1
#define PEN_CHANGED	2
#define PEN_MIXED		4

struct RPortVPort
{
struct RastPort *RPort;
struct ViewPort *VPort;
long LeftEdge,TopEdge;
long Width,Height;
};

#define ARGSKEY "ChangePaletteEachFrame/S,ForcePaletteChangeTime/N,ForcePaletteChangeQuality/N,PercentageOfColours/N"

struct { long eachframe,maxtime,maxquality,colours;}
	args={0,0,0,0},def_args={0,2,5,50};

struct dl1Context context;
struct Library *mesadriverBase;
struct RPortVPort rpvp;

#define WINWIDTH(w)		((w)->Width - (w)->BorderLeft - (w)->BorderRight)
#define WINHEIGHT(w)	((w)->Height - (w)->BorderTop - (w)->BorderBottom)

int numberofcolours(int n)
{
return max(2,min(n,args.colours*n/100));
}

BOOL InitWritePixelA8(void)
{
if (!rpvp.RPort) return 0;
	if (!(context.tmpbm=AllocBitMap(bufwidth,1,rpvp.RPort->BitMap->Depth,0,0)))
		return 0;

	context.tmprp = *(rpvp.RPort);
	context.tmprp.Layer = 0;
	context.tmprp.BitMap = context.tmpbm;

	return 1;
}

void DelWritePixelA8(void)
{
if (context.tmpbm) FreeBitMap(context.tmpbm);
context.tmpbm=0;
}

void FreePens(void)
{
int i;
DB("FreePens! havepens=%ld vport=%lx\n",context.havepens,rpvp.VPort);
if ((context.havepens)&&(rpvp.VPort))
	if(context.mode == AMRTL_RGBAMode)
		for (i=0;i<context.numc;i++)	ReleasePen(rpvp.VPort->ColorMap,context.pens[i]);
	else
		for (i=0;i<MAXPENS;i++)
			if (context.penstate[i]&PEN_HAVE)
				{
				ReleasePen(rpvp.VPort->ColorMap,context.pens[i]);
				context.penstate[i]&=~PEN_HAVE;
				}
context.havepens=0;
}

void ChangeEnvironment(struct RPortVPort *chg)
{
DB("change env.\n");
if ((!chg)||(!(chg->VPort))) FreePens();
else if (chg->VPort!=rpvp.VPort) newpalette=1;

if ((!chg)||(!(chg->RPort))) DelWritePixelA8();
else if (chg->RPort!=rpvp.RPort) context.numc=numberofcolours(1<<chg->RPort->BitMap->Depth);

if (chg) rpvp=*chg; else memset(&rpvp,0,sizeof(rpvp));
DB("new environment: rp=%lx vp=%lx xy=%ld,%ld wh=%ldx%ld\n",rpvp.RPort,rpvp.VPort,rpvp.LeftEdge,rpvp.TopEdge,rpvp.Width,rpvp.Height);

}

void ReadPrefs(char *prefs)
{
char *pr=malloc(strlen(prefs)+2);
struct RDArgs *my_rda=0,*rda=0;
strcpy(pr,prefs);
strcat(pr,"\n");
if (my_rda=AllocDosObject(DOS_RDARGS,0))
	{
	my_rda->RDA_Source.CS_Buffer=pr;
	my_rda->RDA_Source.CS_Length=strlen(pr);
	rda=ReadArgs(ARGSKEY,&args,my_rda);
DB("read args:%s\n",prefs);
	if (rda)
		{
		args.maxtime=args.maxtime?*(long*)args.maxtime:def_args.maxtime;
		args.maxquality=args.maxquality?*(long*)args.maxquality:def_args.maxquality;
		args.colours=args.colours?*(long*)args.colours:def_args.colours;
		FreeArgs(rda);
		}
	else args=def_args;
DB("args=%ld %ld %ld %ld\n",args.eachframe,args.maxtime,args.maxquality,args.colours);
	FreeDosObject(DOS_RDARGS,my_rda);
	}
free(pr);
}

__asm __saveds int InitOutputHandlerA(register __a0 AmigaMesaRTLContext mesacontext, register __a1 struct TagItem *tags)
{
	char *outputtype;
	void *output;
	char prefs[1000]={0};

	if (GfxBase->LibNode.lib_Version<39) return 0;

	mesadriverBase = (struct Library *)GetTagData(OH_DriverBase,NULL,tags);
	if(!mesadriverBase)
		return 0;

	AmigaMesaRTLGetContextAttr(AMRTL_Mode,mesacontext,&(context.mode));

	GetVar("AmigaMesaRTL/dl1plus.prefs",prefs,1000,0);
	ReadPrefs(GetTagData(OH_Parameters,prefs,tags));

	context.qbuffer = NULL;
	context.havepens=0;

	context.tmpbm=0;

	context.numc = 2;
	context.firstc = 0;

	memset(context.penstate,PEN_FREE,256);
	newpalette=0;
	rpvp.RPort=0;
	rpvp.VPort=0;
	rpvp.LeftEdge=rpvp.TopEdge=0;
	rpvp.Width=16; rpvp.Height=16;

	context.mesacontext = mesacontext;
	outputtype = (char *)GetTagData(OH_OutputType,NULL,tags);
	output = (void*)GetTagData(OH_Output,NULL,tags);
	outputtype = (char *)GetTagData(OH_OutputType,NULL,tags);
	if (outputtype)
		{
		if (output&&(!stricmp(outputtype,"window")))
			{
			context.window=(struct Window*)output;
			rpvp.TopEdge=context.window->BorderTop;
			rpvp.LeftEdge=context.window->BorderLeft;
			rpvp.RPort=context.window->RPort;
			rpvp.VPort=ViewPortAddress(context.window);
			context.numc=numberofcolours(1<<rpvp.RPort->BitMap->Depth);
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

	dlq_init();
	dlq_start();
	return 1;
}


__asm __saveds void DeleteOutputHandler(void)
{
DB("dl1plus: delete\n");
	dlq_finish();
	FreePens();

	DelWritePixelA8();

	if(context.qbuffer) free(context.qbuffer);
	context.qbuffer = NULL;

mesadriverBase=0;
}

__asm __saveds int ResizeOutputHandler(void)
{
// if (!rpvp.RPort) return;
	DelWritePixelA8();
	if(context.qbuffer) free(context.qbuffer);
	context.qbuffer = NULL;

AmigaMesaRTLGetContextAttr(AMRTL_BufferWidth,
	context.mesacontext,&bufwidth);
AmigaMesaRTLGetContextAttr(AMRTL_BufferHeight,
	context.mesacontext,&bufheight);

AmigaMesaRTLGetContextAttr(AMRTL_OutputWidth,
	context.mesacontext,&rpvp.Width);
AmigaMesaRTLGetContextAttr(AMRTL_OutputHeight,
	context.mesacontext,&rpvp.Height);

#ifdef FAST
	if(dl_image) free(dl_image)
	dl_image = malloc(sizeof(short) * bufwidth*bufheight);
#endif

	context.qbuffer = (UBYTE *)calloc(bufwidth * bufheight, sizeof(UBYTE));

	InitWritePixelA8();

	return 1;
}


void dl1Quantize(unsigned long *buffer, unsigned long numc, unsigned long base, unsigned char *qbuffer);

__asm __saveds int ProcessOutput(void)
{
UBYTE *buffer;
int i;
unsigned char newpens[256],*remap;
unsigned char *pr,*pg,*pb,*q;

AmigaMesaRTLGetContextAttr(AMRTL_Buffer,context.mesacontext,&buffer);

if ((!bufwidth)||(!bufheight)) {DisplayBeep(0); return 1;}
if (!context.qbuffer) return 1;

if(context.mode == AMRTL_RGBAMode)
	dl1Quantize(buffer, context.numc, 0, context.qbuffer);

//	if((WINWIDTH(context.window) == context.ww) && (WINHEIGHT(context.window) == context.wh))

if (rpvp.VPort)
{
if (newpalette)
	{
	if(context.mode == AMRTL_RGBAMode)
		{
		pr = palette[0]; pg = palette[1]; pb = palette[2];
DB("Get Pens for rgb mode\n");
		for (i=0;i<context.numc;i++,pr++,pg++,pb++)
			newpens[i]=ObtainBestPen(rpvp.VPort->ColorMap,(*pr)<<24,(*pg)<<24,(*pb)<<24,0);
		}
	else
		{
		ULONG *pal;
		AmigaMesaRTLGetContextAttr(AMRTL_IndexPalette,context.mesacontext,&pal);
DB("Get Pens for index mode\n");
		for (i=0;i<MAXPENS;i++,pal+=3)
			if (context.penstate[i]&PEN_CHANGED)
			{
			newpens[i]=ObtainBestPen(rpvp.VPort->ColorMap,pal[0],pal[1],pal[2],0);
//			DB("pen %ld = ObtainBestPen(%lx,%lx,%lx) -> %x\n",i,pal[0],pal[1],pal[2],newpens[i]);
			}
		}
	remap=newpens;
	} else remap=context.pens;

if(context.mode == AMRTL_RGBAMode)
   for (q=context.qbuffer,i=bufwidth*bufheight;i>0;i--,q++) *q=remap[*q];
else
   for (q=context.qbuffer,i=bufwidth*bufheight;i>0;i--,q++,buffer++) *q=remap[*buffer];
}

if (rpvp.RPort)
{
	struct Region *re=0,*oldre;
	if (!context.tmpbm) InitWritePixelA8();
DB("Quantize: WPA8 %ld,%ld %ldx%ld\n",rpvp.LeftEdge,rpvp.TopEdge,rpvp.Width,rpvp.Height);

	if (fullwindow)
		{
		if ((rpvp.Width>WINWIDTH(context.window))||(rpvp.Height>WINHEIGHT(context.window)))
			{
			struct Rectangle rect;
DB("wpa8 needs clipping!\n");
			rect.MinX=context.window->BorderLeft;
			rect.MinY=context.window->BorderTop;
			rect.MaxX=context.window->BorderLeft+WINWIDTH(context.window)-1;
			rect.MaxX=context.window->BorderTop+WINHEIGHT(context.window)-1;
			re=NewRegion();
			OrRectRegion(re,&rect);
			oldre=InstallClipRegion(rpvp.RPort->Layer,re);
			}
		}

	WritePixelArray8(rpvp.RPort,
     rpvp.LeftEdge , rpvp.TopEdge,
     rpvp.LeftEdge + rpvp.Width-1, rpvp.TopEdge + rpvp.Height-1,
     context.qbuffer, &(context.tmprp));

	if (re)
		{
		InstallClipRegion(rpvp.RPort->Layer,oldre);
		DisposeRegion(re);
		}

}

if (rpvp.VPort)
{
if (newpalette)
	{
	DB("After frame, clean up palette change\n");
	if (context.havepens) FreePens();
	if(context.mode == AMRTL_IndexMode)
		for (i=0;i<MAXPENS;i++)
			if (context.penstate[i]&PEN_CHANGED)
				context.penstate[i]|=PEN_HAVE;
	memcpy(context.pens,newpens,MAXPENS);
	context.havepens=1;
	newpalette=0;
	DB("After frame, clean up palette change DONE\n");
	}
}


	return 1;
}


__asm __saveds void SetIndexRGBTable(register __d0 int index, register __a0 ULONG *rgbtable, register __d1 int numcolours)
{
for(numcolours+=index; (index<numcolours)&&(index<MAXPENS); index++)
	context.penstate[index]|=PEN_CHANGED;
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
			SetColourRange(context.reqfirstc,tidata);
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
			*((struct Window **)data) = context.window;
			break;
		case OH_OutputType:
			*((char **)data) = "Window";
			break;
		case OH_Width:
			if (fullwindow) *data=WINWIDTH(context.window);
			else	*data = rpvp.Width;
			break;
		case OH_Height:
			if (fullwindow) *data=WINHEIGHT(context.window);
			else	*data = rpvp.Height;
			break;
		case OH_ColourBase:
			*((ULONG *)data) = context.firstc;
			break;
		case OH_NumColours:
			*((ULONG *)data) = context.numc;
			break;
		case OH_ParameterQuery:
			*((char **)data) = ARGSKEY;
			break;
		default:
			return(0);
	}
return(1);
}


void dl1Quantize(unsigned long *buffer, unsigned long numc, unsigned long base, unsigned char *qbuffer)
{
ulong thistime;
time(&thistime);
if (args.eachframe||(globalerror>=fresherror+args.maxquality)||(thistime>=lasttime+args.maxtime))
	{
	reset();
	build_table(buffer, (ulong)bufwidth * (ulong)bufheight);
	reduce_table(numc);
	set_palette(0, 0);
	newpalette=1;
	lasttime=thistime;
	}

quantize_image(buffer, qbuffer, bufwidth, bufheight, 1, base);

/*
if (fullwindow)
{
sprintf(txttmp,"error:%ld average:%ld fresh:%ld %c",
	globalerror,globalerror/bufwidth/bufheight,fresherror,newpalette?'*':' ');
SetWindowTitles(context.window,(UBYTE*)~0,txttmp);
}
*/

globalerror=globalerror/bufwidth/bufheight;
if (newpalette) fresherror=globalerror;
}


#if 0
/* returns 1 on success, 0 on failure */
GLOBAL int
dl1quant(uchar *inbuf, uchar *outbuf, int width, int height, int quant_to,
	 int dither, uchar userpal[3][256]) {

    if (!did_init) {
	did_init = 1;
	dlq_init();
    }
    if (dlq_start() == 0) {
	dlq_finish();
	return 0;
    }
    if (build_table(inbuf, (ulong)width * (ulong)height) == 0) {
	dlq_finish();
	return 0;
    }
    reduce_table(quant_to);
    set_palette(0, 0);
    if (quantize_image(inbuf, outbuf, width, height, dither) == 0) {
	dlq_finish();
	return 0;
    }
    dlq_finish();
    copy_pal(userpal);

    return 1;
}
#endif

LOCAL void
copy_pal(uchar userpal[3][256]) {
    int i;

    for (i = 0; i < 256; i++) {
	userpal[0][i] = palette[0][i];
	userpal[1][i] = palette[1][i];
	userpal[2][i] = palette[2][i];
    }
}

LOCAL void
dlq_init(void) {
    int i;

    for (i = 0; i < 256; i++) {
	r_offset[i] = (i & 128) << 7 | (i & 64) << 5 | (i & 32) << 3 |
		      (i & 16)  << 1 | (i & 8)  >> 1;
	g_offset[i] = (i & 128) << 6 | (i & 64) << 4 | (i & 32) << 2 |
		      (i & 16)  << 0 | (i & 8)  >> 2;
	b_offset[i] = (i & 128) << 5 | (i & 64) << 3 | (i & 32) << 1 |
		      (i & 16)  >> 1 | (i & 8)  >> 3;
    }

    for (i = (-255); i <= 255; i++)
	c_info.squares[i+255] = i*i;
    squares = c_info.squares + 255;
}

/* returns 1 on success, 0 on failure */
LOCAL int
dlq_start(void) {
    int i;

    rgb_table[0] = (CUBE *) calloc(sizeof(CUBE), 1);
    rgb_table[1] = (CUBE *) calloc(sizeof(CUBE), 8);
    rgb_table[2] = (CUBE *) calloc(sizeof(CUBE), 64);
    rgb_table[3] = (CUBE *) calloc(sizeof(CUBE), 512);
    rgb_table[4] = (CUBE *) calloc(sizeof(CUBE), 4096);
    rgb_table[5] = (CUBE *) calloc(sizeof(CUBE), 32768);

    for (i = 0; i <= 5; i++)
	if (rgb_table[i] == NULL)
	    return 0;

    pal_index = 0;

	heap = (FCUBE *) malloc(sizeof(FCUBE) * 32769);
	if(heap == NULL)
		return 0;

    return 1;
}


LOCAL void
reset(void) {
	memset(rgb_table[0], 0, 1*sizeof(CUBE));
	memset(rgb_table[1], 0, 8*sizeof(CUBE));
	memset(rgb_table[2], 0, 64*sizeof(CUBE));
	memset(rgb_table[3], 0, 512*sizeof(CUBE));
	memset(rgb_table[4], 0, 4096*sizeof(CUBE));
	memset(rgb_table[5], 0, 32768*sizeof(CUBE));

	pal_index = 0;
}



LOCAL void
dlq_finish(void) {
    if (rgb_table[0] != NULL)
	free(rgb_table[0]);
    if (rgb_table[1] != NULL)
	free(rgb_table[1]);
    if (rgb_table[2] != NULL)
	free(rgb_table[2]);
    if (rgb_table[3] != NULL)
	free(rgb_table[3]);
    if (rgb_table[4] != NULL)
	free(rgb_table[4]);
    if (rgb_table[5] != NULL)
	free(rgb_table[5]);
    if (heap != NULL)
	free(heap);
    if (dl_image != NULL)
	free(dl_image);
}

/* returns 1 on success, 0 on failure */
LOCAL int
build_table(uchar *image, ulong pixels) {
    ulong i, index, cur_count, head, tail;
    slong j;

    for (i = 0; i < pixels; i++) {
#ifdef FAST
	dl_image[i] = index = r_offset[image[0]] + g_offset[image[1]] + b_offset[image[2]];
#else
	index = r_offset[image[0]] + g_offset[image[1]] + b_offset[image[2]];
#endif
#ifdef QUAL1
	rgb_table[5][index].r += image[0];
	rgb_table[5][index].g += image[1];
	rgb_table[5][index].b += image[2];
#endif
	rgb_table[5][index].pixel_count++;
	image += 4;
    }

    tot_colors = 0;
    for (i = 0; i < 32768; i++) {
	cur_count = rgb_table[5][i].pixel_count;
	if (cur_count) {
	    heap[++tot_colors].level = 5;
	    heap[tot_colors].index = i;
	    rgb_table[5][i].pixels_in_cube = cur_count;
#ifndef QUAL1
	    rgb_table[5][i].r = cur_count * (((i & 0x4000) >> 7 |
				(i & 0x0800) >> 5 | (i & 0x0100) >> 3 |
				(i & 0x0020) >> 1 | (i & 0x0004) << 1) + 4);
	    rgb_table[5][i].g = cur_count * (((i & 0x2000) >> 6 |
				(i & 0x0400) >> 4 | (i & 0x0080) >> 2 |
				(i & 0x0010) >> 0 | (i & 0x0002) << 2) + 4);
	    rgb_table[5][i].b = cur_count * (((i & 0x1000) >> 5 |
				(i & 0x0200) >> 3 | (i & 0x0040) >> 1 |
				(i & 0x0008) << 1 | (i & 0x0001) << 3) + 4);
#endif
	    head = i;
	    for (j = 4; j >= 0; j--) {
		tail = head & 0x7;
		head >>= 3;
		rgb_table[j][head].pixels_in_cube += cur_count;
		rgb_table[j][head].children |= 1 << tail;
	    }
	}
    }

    for (i = tot_colors; i > 0; i--)
	fixheap(i);

    return 1;
}

LOCAL void
fixheap(ulong id) {
    uchar thres_level = heap[id].level;
    ulong thres_index = heap[id].index, index, half_totc = tot_colors >> 1,
	  thres_val = rgb_table[thres_level][thres_index].pixels_in_cube;

    while (id <= half_totc) {
	index = id << 1;

	if (index < tot_colors)
	    if (rgb_table[heap[index].level][heap[index].index].pixels_in_cube
	      > rgb_table[heap[index+1].level][heap[index+1].index].pixels_in_cube)
		index++;

	if (thres_val <= rgb_table[heap[index].level][heap[index].index].pixels_in_cube)
	    break;
	else {
	    heap[id] = heap[index];
	    id = index;
	}
    }
    heap[id].level = thres_level;
    heap[id].index = thres_index;
}

LOCAL void
reduce_table(int num_colors) {
    while (tot_colors > num_colors) {

	uchar tmp_level = heap[1].level, t_level = tmp_level - 1;
	ulong tmp_index = heap[1].index, t_index = tmp_index >> 3;

	if (rgb_table[t_level][t_index].pixel_count)
	    heap[1] = heap[tot_colors--];
	else {
	    heap[1].level = t_level;
	    heap[1].index = t_index;
	}
	rgb_table[t_level][t_index].pixel_count += rgb_table[tmp_level][tmp_index].pixel_count;
	rgb_table[t_level][t_index].r += rgb_table[tmp_level][tmp_index].r;
	rgb_table[t_level][t_index].g += rgb_table[tmp_level][tmp_index].g;
	rgb_table[t_level][t_index].b += rgb_table[tmp_level][tmp_index].b;
	rgb_table[t_level][t_index].children &= ~(1 << (tmp_index & 0x7));
	fixheap(1);
    }
}

LOCAL void
set_palette(int index, int level) {
    int i;

    if (rgb_table[level][index].children)
	for (i = 7; i >= 0; i--)
	    if (rgb_table[level][index].children & (1 << i))
		set_palette((index << 3) + i, level + 1);

    if (rgb_table[level][index].pixel_count) {
	ulong r_sum, g_sum, b_sum, sum;

	rgb_table[level][index].palette_index = pal_index;
	r_sum = rgb_table[level][index].r;
	g_sum = rgb_table[level][index].g;
	b_sum = rgb_table[level][index].b;
	sum = rgb_table[level][index].pixel_count;
	palette[0][pal_index] = (r_sum + (sum >> 1)) / sum;
	palette[1][pal_index] = (g_sum + (sum >> 1)) / sum;
	palette[2][pal_index] = (b_sum + (sum >> 1)) / sum;
	pal_index++;
    }
}

LOCAL void
closest_color(int index, int level) {
    int i;

    if (rgb_table[level][index].children)
	for (i = 7; i >= 0; i--)
	    if (rgb_table[level][index].children & (1 << i))
		closest_color((index << 3) + i, level + 1);

    if (rgb_table[level][index].pixel_count) {
	slong dist, r_dist, g_dist, b_dist;
	uchar pal_num = rgb_table[level][index].palette_index;

	/* Determine if this color is "closest". */
	r_dist = palette[0][pal_num] - c_info.red;
	g_dist = palette[1][pal_num] - c_info.green;
	b_dist = palette[2][pal_num] - c_info.blue;
	dist = squares[r_dist] + squares[g_dist] + squares[b_dist];
	if (dist < c_info.distance) {
	    c_info.distance = dist;
	    c_info.palette_index = pal_num;
	}
    }
}

/* returns 1 on success, 0 on failure */
LOCAL int
quantize_image(uchar *in, uchar *out, int width, int height, int dither, int base) {
    if (!dither) {
	ulong i, pixels = width * height;
	ushort level, index;
	uchar tmp_r, tmp_g, tmp_b, cube, *lookup;

	lookup = malloc(sizeof(char) * 32768);
	if (lookup == NULL)
	    return 0;

	for (i = 0; i < 32768; i++)
	    if (rgb_table[5][i].pixel_count) {
		tmp_r = (i & 0x4000) >> 7 | (i & 0x0800) >> 5 |
			(i & 0x0100) >> 3 | (i & 0x0020) >> 1 |
			(i & 0x0004) << 1;
		tmp_g = (i & 0x2000) >> 6 | (i & 0x0400) >> 4 |
			(i & 0x0080) >> 2 | (i & 0x0010) >> 0 |
			(i & 0x0002) << 2;
		tmp_b = (i & 0x1000) >> 5 | (i & 0x0200) >> 3 |
			(i & 0x0040) >> 1 | (i & 0x0008) << 1 |
			(i & 0x0001) << 3;
#ifdef QUAL2
		lookup[i] = bestcolor(tmp_r, tmp_g, tmp_b);
#else
		c_info.red   = tmp_r + 4;
		c_info.green = tmp_g + 4;
		c_info.blue  = tmp_b + 4;
		level = 0;
		index = 0;
		for (;;) {
		    cube = (tmp_r&128) >> 5 | (tmp_g&128) >> 6 | (tmp_b&128) >> 7;
		    if ((rgb_table[level][index].children & (1 << cube)) == 0) {
			c_info.distance = ~0L;
			closest_color(index, level);
			lookup[i] = c_info.palette_index;
			break;
		    }
		    level++;
		    index = (index << 3) + cube;
		    tmp_r <<= 1;
		    tmp_g <<= 1;
		    tmp_b <<= 1;
		}
#endif
	    }

	for (i = 0; i < pixels; i++) {
#ifdef FAST
	    out[i] = lookup[dl_image[i]]+base;
#else
	    out[i] = lookup[r_offset[in[0]] + g_offset[in[1]] + b_offset[in[2]]]+base;
	    in += 4;
#endif
	}

	free(lookup);
    } else {
#if defined(DITHER2) || defined(DITHER4)
	slong i, j, r_pix, g_pix, b_pix, offset, dir, two_val,
	      odd_scanline = 0, err_len = (width + 2) * 3;
	uchar *range_tbl = malloc(3 * 256), *range = range_tbl + 256;
	sshort *lookup  = malloc(sizeof(short) * 32768),
	       *erowerr = malloc(sizeof(short) * err_len),
	       *orowerr = malloc(sizeof(short) * err_len),
	       *thisrowerr, *nextrowerr;
	schar *dith_max_tbl = malloc(512), *dith_max = dith_max_tbl + 256;




	if (range_tbl == NULL || lookup == NULL ||
	    erowerr == NULL || orowerr == NULL || dith_max_tbl == NULL) {
	    if (range_tbl != NULL)
		free(range_tbl);
	    if (lookup != NULL)
		free(lookup);
	    if (erowerr != NULL)
		free(erowerr);
	    if (orowerr != NULL)
		free(orowerr);
	    if (dith_max_tbl != NULL)
		free(dith_max_tbl);
	    return 0;
	}

	for (i = 0; i < err_len; i++)
	    erowerr[i] = 0;

	for (i = 0; i < 32768; i++)
	    lookup[i] = -1;

	for (i = 0; i < 256; i++) {
	    range_tbl[i] = 0;
	    range_tbl[i + 256] = (uchar) i;
	    range_tbl[i + 512] = 255;
	}

	for (i = 0; i < 256; i++) {
	    dith_max_tbl[i] = -DITHER_MAX;
	    dith_max_tbl[i + 256] = DITHER_MAX;
	}
	for (i = -DITHER_MAX; i <= DITHER_MAX; i++)
	    dith_max_tbl[i + 256] = i;

	for (i = 0 ; i < height; i++) {
	    if (odd_scanline) {
		dir = -1;
		in  += (width - 1) * 4;
		out += (width - 1);
		thisrowerr = orowerr + 3;
		nextrowerr = erowerr + width * 3;
	    } else {
		dir = 1;
		thisrowerr = erowerr + 3;
		nextrowerr = orowerr + width * 3;
	    }
	    nextrowerr[0] = nextrowerr[1] = nextrowerr[2] = 0;
	    for (j = 0; j < width; j++) {
#ifdef DITHER2
		r_pix = range[(thisrowerr[0] >> 1) + in[0]];
		g_pix = range[(thisrowerr[1] >> 1) + in[1]];
		b_pix = range[(thisrowerr[2] >> 1) + in[2]];
#else
		r_pix = range[((thisrowerr[0] + 8) >> 4) + in[0]];
		g_pix = range[((thisrowerr[1] + 8) >> 4) + in[1]];
		b_pix = range[((thisrowerr[2] + 8) >> 4) + in[2]];
#endif
		offset = (r_pix&248) << 7 | (g_pix&248) << 2 | b_pix >> 3;
		if (lookup[offset] < 0)
		    lookup[offset] = bestcolor(r_pix, g_pix, b_pix);
		*out = lookup[offset]+base;
		r_pix = dith_max[r_pix - palette[0][lookup[offset]]];
		g_pix = dith_max[g_pix - palette[1][lookup[offset]]];
		b_pix = dith_max[b_pix - palette[2][lookup[offset]]];
#ifdef DITHER2
		nextrowerr[0  ]  = r_pix;
		thisrowerr[0+3] += r_pix;
		nextrowerr[1  ]  = g_pix;
		thisrowerr[1+3] += g_pix;
		nextrowerr[2  ]  = b_pix;
		thisrowerr[2+3] += b_pix;
#else
		two_val = r_pix * 2;
		nextrowerr[0-3]  = r_pix;
		r_pix += two_val;
		nextrowerr[0+3] += r_pix;
		r_pix += two_val;
		nextrowerr[0  ] += r_pix;
		r_pix += two_val;
		thisrowerr[0+3] += r_pix;
		two_val = g_pix * 2;
		nextrowerr[1-3]  = g_pix;
		g_pix += two_val;
		nextrowerr[1+3] += g_pix;
		g_pix += two_val;
		nextrowerr[1  ] += g_pix;
		g_pix += two_val;
		thisrowerr[1+3] += g_pix;
		two_val = b_pix * 2;
		nextrowerr[2-3]  = b_pix;
		b_pix += two_val;
		nextrowerr[2+3] += b_pix;
		b_pix += two_val;
		nextrowerr[2  ] += b_pix;
		b_pix += two_val;
		thisrowerr[2+3] += b_pix;
#endif
		thisrowerr += 3;
		nextrowerr -= 3;
		in  += dir * 4;
		out += dir;
	    }
	    if ((i % 2) == 1) {
		in  += (width + 1) * 4;
		out += (width + 1);
	    }
	    odd_scanline = !odd_scanline;
	}

	free(range_tbl);
	free(lookup);
	free(erowerr);
	free(orowerr);
	free(dith_max_tbl);
#else
	slong i, j, r_pix, g_pix, b_pix, r_err, g_err, b_err, offset;
	uchar *range_tbl = malloc(3 * 256), *range = range_tbl + 256;
	sshort *lookup = malloc(sizeof(short) * 32768);

	if (range_tbl == NULL || lookup == NULL) {
	    if (range_tbl != NULL)
		free(range_tbl);
	    if (lookup != NULL)
		free(lookup);
	    return 0;
	}

	for (i = 0; i < 32768; i++)
	    lookup[i] = -1;

	for (i = 0; i < 256; i++) {
	    range_tbl[i] = 0;
	    range_tbl[i + 256] = (uchar) i;
	    range_tbl[i + 512] = 255;
	}

#ifdef ERRORCONTROL
globalerror=0;
#endif

	for (i = 0; i < height; i++) {
	    r_err = g_err = b_err = 0;
	    for (j = width - 1; j >= 0; j--) {
		r_pix = range[(r_err >> 1) + in[0]];
		g_pix = range[(g_err >> 1) + in[1]];
		b_pix = range[(b_err >> 1) + in[2]];
		offset = (r_pix&248) << 7 | (g_pix&248) << 2 | b_pix >> 3;
		if (lookup[offset] < 0)
		    lookup[offset] = bestcolor(r_pix, g_pix, b_pix);
		*out++ = lookup[offset]+base;
		r_err = r_pix - palette[0][lookup[offset]];
		g_err = g_pix - palette[1][lookup[offset]];
		b_err = b_pix - palette[2][lookup[offset]];
#ifdef ERRORCONTROL
globalerror+=abs(r_err)+abs(g_err)+abs(b_err);
#endif
		in += 4;
	    }
	}



	free(range_tbl);
	free(lookup);
#endif
    }
    return 1;
}

LOCAL int
bestcolor(int r, int g, int b) {
    ulong i, bestcolor, curdist, mindist;
    slong rdist, gdist, bdist;

    r = (r & 248) + 4;
    g = (g & 248) + 4;
    b = (b & 248) + 4;
    mindist = 200000;
    for (i = 0; i < tot_colors; i++) {
	rdist = palette[0][i] - r;
	gdist = palette[1][i] - g;
	bdist = palette[2][i] - b;
	curdist = squares[rdist] + squares[gdist] + squares[bdist];
	if (curdist < mindist) {
	    mindist = curdist;
	    bestcolor = i;
	}
    }
    return (int)bestcolor;
}
