/*
 * DL1 Quantization
 * ================
 *
 * File: dl1quant.c
 * Author: Dennis Lee   E-mail: denlee@ecf.utoronto.ca
 *
 * Copyright (C) 1993-1997 Dennis Lee
 *
 * C implementation of DL1 Quantization.
 * DL1 Quantization is a 2-pass color quantizer optimized for speed.
 * The method was designed around the steps required by a 2-pass
 * quantizer and constructing a model that would require the least
 * amount of extra work.  The resulting method is extremely fast --
 * about half the speed of a memcpy.  That should make DL1 Quant the
 * fastest 2-pass color quantizer.
 *
 * This quantizer's quality is also among the best, slightly
 * better than Wan et al's marginal variance based quantizer.  For
 * more on DL1 Quant's performance and other related information,
 * see DLQUANT.TXT included in this distribution.
 *
 *
 * NOTES
 * =====
 *
 * The dithering code is based on code from the IJG's jpeg library.
 *
 * This source code may be freely copied, modified, and redistributed,
 * provided this copyright notice is attached.
 * Compiled versions of this code, modified or not, are free for
 * personal use.  Compiled versions used in distributed software
 * is also free, but a notification must be sent to the author.
 * An e-mail to denlee@ecf.utoronto.ca will do.
 *
 */


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
 * Version 2.0  13 Sep 1998
 * by Jarno van der Linden
 * jarno@kcbbs.gen.nz
 *
 * - Changed to comply with v2 quantizer interface
 * - Added SetIndexRGB
 * - Now using the mesa context attribute getting interface
 * - Added colourbase correction to index buffer
 * - Change to OutputHandler interface
 * - Added preferences system
 * - Added a somewhat experimental on-the-fly window swapping
 *   function
 *
 */


#define DL1SRC

#include <stdlib.h>
#include <string.h>
#include "dl1quant.h"

#include <intuition/intuition.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/utility.h>
#include <proto/exec.h>
#include <proto/dos.h>

#include <string.h>

#include "gl/outputhandler.h"


/********** The following are options **********/

//#define FAST        /* improves speed but uses a lot of memory */
//#define QUAL1       /* improves quality slightly (slower) */
//#define QUAL2       /* improves quality slightly (slower) */

/* define *one* of the following dither options */
#define DITHER1     /* 1-val error diffusion dither */
//#define DITHER2     /* 2-val error diffusion dither */
//#define DITHER4     /* 4-val error diffusion dither (Floyd-Steinberg) */

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

const char *outputtypes[] = { "Window", NULL };

UWORD pens[] = {(UWORD)~0};

struct dl1Context {
	AmigaMesaRTLContext mesacontext;	/* Associated amigamesa context */
	struct Window *window;				/* Window to which to render */
	ULONG mode;							/* AMRTL_RGBA or AMRTL_Index */
	struct DrawInfo *di;				/* Window drawinfo */
	struct BitMap bm;					/* WPA8 data */
	struct RastPort rp;					/* " */
	UBYTE *qbuffer;						/* Buffer to quantizer to */
	ULONG *palette;						/* LoadRGB32 palette for RGBA */
	ULONG reqnumc, reqfirstc;			/* Requested colour range */
	ULONG numc, firstc;					/* Clipped colour range */
	int rw, rh;							/* Buffer size */
	int ww, wh;							/* Window size */
	int outputtype;						/* What output type are we using? */
	char screenname[40];				/* Name of screen */
	struct Screen *screen;				/* Custom screen */
	BOOL mywindow, myscreen;			/* Did I open that? */
};


struct dl1Context context;
struct Library *mesadriverBase;

#define WINWIDTH(w)		((w)->Width - (w)->BorderLeft - (w)->BorderRight)
#define WINHEIGHT(w)	((w)->Height - (w)->BorderTop - (w)->BorderBottom)

#define ARGSKEY "ColourBase/N,NumColours/N,_LA1_Own_Window_Parameters/K,NAMED=_MX_Public_Screen/S,DEFAULT=_MX_Default_Screen/S,CUSTOM=_MX_Full_Screen/S,NAME=Screen_Name,_LA1_Full_Screen_Parameters/K,MODE=_SM_Mode,Width/N,Height/N"

struct my_prefs
{
	LONG colourbase, numcolours;
	LONG dummy1;
	LONG namedscreen, defaultscreen, customscreen;
	char *name;
	LONG dummy2;
	LONG mode;
	LONG width,height;
} prefs,defaultprefs={0,-1,0,1,0,0,"Mesa",0,0,0,0};


BOOL InitWritePixelA8(void)
{
	int depth;

	InitBitMap(&(context.bm), context.di->dri_Depth, context.rw, 1);

	for(depth=0; depth<context.di->dri_Depth; depth++)
	{
		context.bm.Planes[depth] = (PLANEPTR)AllocRaster(context.rw, 1);
		if(!context.bm.Planes[depth])
			return FALSE;
	}

	context.rp = *(context.window->RPort);
	context.rp.Layer = NULL;
	context.rp.BitMap = &(context.bm);

	return(TRUE);
}


void DelWritePixelA8(void)
{
	int depth;

	if(context.di)
	{
		for(depth=0; depth<context.di->dri_Depth; depth++)
		{
			if(context.bm.Planes[depth]) FreeRaster(context.bm.Planes[depth], context.rw, 1);
			context.bm.Planes[depth] = NULL;
		}
	}
}


void SetColourRange(void)
{
	ULONG maxnumcolours;
	ULONG firstc,numc;

	firstc = prefs.colourbase;
	numc = prefs.numcolours;

	context.reqfirstc = firstc;
	context.reqnumc = numc;

	if(!context.di)
		return;

	maxnumcolours = 1L<<context.di->dri_Depth;
	if(firstc > (maxnumcolours-2))
		firstc = maxnumcolours-2;
	if(firstc < 0)
		firstc = 0;
	if(numc > (maxnumcolours-firstc))
		numc = maxnumcolours-firstc;
	if(numc < 2)
		numc = 2;
	context.numc = numc;
	context.firstc = firstc;

	if(context.mode == AMRTL_RGBAMode)
	{
		if(context.palette) free(context.palette);
		context.palette = calloc(1+context.numc*3+1,sizeof(ULONG));
	}
}


int CreateOutput(void)
{
	int depth;

	if(context.window)
	{
		/* Use someone else's window */

		context.myscreen = FALSE;
		context.mywindow = FALSE;
	}
	else if(prefs.customscreen)
	{
		/* Setup my own screen and window */

		context.screen = OpenScreenTags(NULL,
							SA_Depth,			8,
							SA_Quiet,			TRUE,
							SA_DisplayID,		prefs.mode,
							TAG_SKIP,			prefs.width > 0 ? 0 : 1,
							SA_Width,			prefs.width,
							TAG_SKIP,			prefs.height > 0 ? 0 : 1,
							SA_Height,			prefs.height,
							SA_Pens,			(ULONG)pens,
							TAG_END);
		if(!context.screen)
			return 0;

		context.myscreen = TRUE;

		context.window = OpenWindowTags(NULL,
							WA_CustomScreen,	context.screen,
							WA_Width,			context.screen->Width,
							WA_Height,			context.screen->Height,
							WA_Activate,		TRUE,
							//WA_CloseGadget,		TRUE,
							WA_Borderless,		TRUE,
							WA_NewLookMenus,	TRUE,
							TAG_END);

		if(!context.window)
		{
			CloseScreen(context.screen);
			context.screen = NULL;
			return 0;
		}

		context.mywindow = TRUE;
	}
	else if(prefs.namedscreen || prefs.defaultscreen)
	{
		/* Setup my own window on someone else's screen */

		context.screen = LockPubScreen(prefs.namedscreen ? prefs.name : NULL);

		if(!context.screen)
			return 0;

		context.myscreen = FALSE;

		context.window = OpenWindowTags(NULL,
							WA_Title,			"Mesa Display",
							WA_PubScreen,		context.screen,
							WA_Width,			100,
							WA_Height,			100,
							WA_MinWidth,		32,
							WA_MinHeight,		32,
							WA_MaxWidth,		~0,
							WA_MaxHeight,		~0,
							WA_NoCareRefresh,	TRUE,
							WA_Activate,		TRUE,
							WA_CloseGadget,		TRUE,
							WA_DragBar,			TRUE,
							WA_SizeGadget,		TRUE,
							WA_DepthGadget,		TRUE,
							TAG_END);

		UnlockPubScreen(NULL,context.screen);

		if(!context.window)
		{
			context.screen = NULL;
			return 0;
		}

		context.mywindow = TRUE;
	}
	else
	{
		/* Panic, no window given and no instructions to set one up */

		return 0;


	}

	context.di = GetScreenDrawInfo(context.window->WScreen);

	for(depth=0; depth<context.di->dri_Depth; depth++)
		context.bm.Planes[depth] = NULL;

	return 1;
}


void DestroyOutput(void)
{
	DelWritePixelA8();

	if(context.palette) free(context.palette);
	context.palette = NULL;

	if(context.di) FreeScreenDrawInfo(context.window->WScreen, context.di);
	context.di = NULL;

	if(context.qbuffer) free(context.qbuffer);
	context.qbuffer = NULL;

	if(context.mywindow)
	{
		if(context.window) CloseWindow(context.window);
		context.window = NULL;
	}
	context.mywindow = FALSE;

	if(context.myscreen)
	{
		if(context.screen) CloseScreen(context.screen);
		context.screen = NULL;
	}
	context.myscreen = FALSE;
}


int ChangeOutput(APTR output, char *outputtype)
{
	int t;

    for(t=0; outputtypes[t] != NULL; t++)
		if(outputtype && (stricmp(outputtypes[t],outputtype) == 0))
			break;

	if(t != 0)
		return 0;

	DestroyOutput();

	context.outputtype = t;
	context.window = output;

	if(!CreateOutput())
		return 0;

	SetColourRange();

	context.rw = context.rh = 0;
	context.ww = context.wh = 0;

	return 1;
}



void ReadPrefs(char *strprefs)
{
	char *pr = NULL;
	struct RDArgs *my_rda=NULL, *rda=NULL;

	pr=malloc(strlen(strprefs)+2);
	if(pr)
	{
		strcpy(pr,strprefs);
		strcat(pr,"\n");

		if (my_rda=AllocDosObject(DOS_RDARGS,0))
		{
			my_rda->RDA_Source.CS_Buffer=pr;
			my_rda->RDA_Source.CS_Length=strlen(pr);
			rda=ReadArgs(ARGSKEY,&prefs,my_rda);
		}
	}

	if(!rda)
		prefs = defaultprefs;
	else
	{
		if(prefs.colourbase)
			prefs.colourbase = *(LONG *)(prefs.colourbase);
		else
			prefs.colourbase = defaultprefs.colourbase;

		if(prefs.numcolours)
			prefs.numcolours = *(LONG *)(prefs.numcolours);
		else
			prefs.numcolours = defaultprefs.numcolours;

		if(prefs.mode)
			prefs.mode = strtol(prefs.mode,NULL,0);
		else
			prefs.mode = defaultprefs.mode;

		if(prefs.namedscreen)
		{
			if(prefs.name)
			{
				strncpy(context.screenname,prefs.name,39);
				context.screenname[39] = '\0';
				prefs.name = context.screenname;
			}
			else
				prefs.name = defaultprefs.name;
		}
		if(prefs.width)
			prefs.width = *(LONG *)(prefs.width);
		else
			prefs.width = defaultprefs.width;

		if(prefs.height)
			prefs.height = *(LONG *)(prefs.height);
		else
			prefs.height = defaultprefs.height;
	}

	if (rda) FreeArgs(rda);
	rda = NULL;

	if(my_rda) FreeDosObject(DOS_RDARGS,my_rda);
	my_rda = NULL;

	if(pr) free(pr);
	pr = NULL;
}


__asm __saveds int InitOutputHandlerA(register __a0 AmigaMesaRTLContext mesacontext, register __a1 struct TagItem *tags)
{
	char *outputtype;
	APTR output;
	char prefs[1000]={0};

	context.mesacontext = NULL;
	context.window = NULL;
	context.screen = NULL;
	context.di = NULL;
	context.qbuffer = NULL;
	context.palette = NULL;
	context.mywindow = FALSE;
	context.myscreen = FALSE;

	mesadriverBase = (struct Library *)GetTagData(OH_DriverBase,NULL,tags);
	if(!mesadriverBase)
		return 0;

	context.mesacontext = mesacontext;

	AmigaMesaRTLGetContextAttr(AMRTL_Mode,mesacontext,&(context.mode));

	GetVar("AmigaMesaRTL/dl1.prefs",prefs,1000,0);
	ReadPrefs(GetTagData(OH_Parameters,prefs,tags));

	outputtype = (char *)GetTagData(OH_OutputType,NULL,tags);
	output = (APTR)GetTagData(OH_Output,NULL,tags);

	if(!ChangeOutput(output,outputtype))
		return 0;

	dlq_init();
	dlq_start();

	return 1;
}


__asm __saveds void DeleteOutputHandler(void)
{
	dlq_finish();

	DestroyOutput();
}


__asm __saveds int ResizeOutputHandler(void)
{
	DelWritePixelA8();
	if(context.qbuffer) free(context.qbuffer);
	context.qbuffer = NULL;

	AmigaMesaRTLGetContextAttr(AMRTL_BufferWidth,context.mesacontext,&bufwidth);
	AmigaMesaRTLGetContextAttr(AMRTL_BufferHeight,context.mesacontext,&bufheight);
#ifdef FAST
	if(dl_image) free(dl_image)

	dl_image = malloc(sizeof(short) * bufwidth*bufheight);
#endif

	context.rw = bufwidth;
	context.rh = bufheight;

	context.ww = WINWIDTH(context.window);
	context.wh = WINHEIGHT(context.window);

	context.qbuffer = (UBYTE *)calloc(context.rw * context.rh, sizeof(UBYTE));

	InitWritePixelA8();
	return 1;
}


void dl1Quantize(unsigned long *buffer, unsigned long numc, unsigned long base, unsigned char *qbuffer,unsigned long *paltable);
__asm __saveds int ProcessOutput(void)
{
	ULONG *buffer;
	register UBYTE *bufferp, *qbufferp;
	const UBYTE fc = context.firstc;
	int t;

	AmigaMesaRTLGetContextAttr(AMRTL_Buffer,context.mesacontext,&buffer);
	if(context.mode == AMRTL_RGBAMode)
	{
		dl1Quantize(buffer, context.numc, context.firstc, context.qbuffer, context.palette);
		LoadRGB32(ViewPortAddress(context.window), context.palette);

		if((WINWIDTH(context.window) != context.ww) || (WINHEIGHT(context.window) != context.wh))
			return 1;
		WritePixelArray8(context.window->RPort,
		                 context.window->BorderLeft , context.window->BorderTop,
		                 context.window->BorderLeft + context.ww-1, context.window->BorderTop + context.wh-1,
		                 context.qbuffer, &(context.rp));
	}
	else if(context.mode == AMRTL_IndexMode)
	{
		bufferp = (UBYTE *)buffer;
		qbufferp = context.qbuffer;
		/* Buffer size is a multiple of 16 */
		for(t=0; t<(bufwidth*bufheight)>>4; t++)
		{
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
			*qbufferp = *bufferp + fc; qbufferp++; bufferp++;
		}

		WritePixelArray8(context.window->RPort,
		                 context.window->BorderLeft , context.window->BorderTop,
		                 context.window->BorderLeft + context.ww-1, context.window->BorderTop + context.wh-1,
		                 context.qbuffer, &(context.rp));
	}
	return 1;
}


__asm __saveds void SetIndexRGBTable(register __d0 int index, register __a0 ULONG *rgbtable, register __d1 int numcolours)
{
	int t;
	ULONG *tablep;

	tablep = rgbtable;
	for(t=0; (t < numcolours) && ((index+t) < context.numc); t++)
	{
		SetRGB32(ViewPortAddress(context.window), context.firstc + index + t, tablep[0], tablep[1], tablep[2]);
		tablep+=3;
	}
}


__asm __saveds ULONG SetOutputHandlerAttrsA(register __a0 struct TagItem *tags)
{
	struct TagItem *tstate, *tag;
	ULONG tidata;
	ULONG ret;

	ret = 0;
	tstate = tags;
	while(tag = NextTagItem(&tstate))
	{
		tidata = tag->ti_Data;

		switch(tag->ti_Tag)
		{
			case OH_Output:
				ret |= ChangeOutput(tidata,(char *)GetTagData(OH_OutputType,NULL,tags)) ? 2 : 1;
				break;
			case OH_OutputType:
				break;
			case OH_Parameters:
				ReadPrefs((char *)tidata);	/* Only reset colour range, changing output */
				SetColourRange();			/* through preferences might bypass application. */
				ret |= 1;
				break;
			default:
				break;
		}
	}

	return ret;
}


__asm __saveds ULONG GetOutputHandlerAttr(register __d0 ULONG attr, register __a0 ULONG *data)
{
	switch(attr)
	{
		case OH_Output:
			*((struct Window **)data) = context.window;
			break;
		case OH_OutputType:
			*((char **)data) = outputtypes[context.outputtype];
			break;
		case OH_Width:
			*((ULONG *)data) = WINWIDTH(context.window);
			break;
		case OH_Height:
			*((ULONG *)data) = WINHEIGHT(context.window);

			break;
		case OH_ParameterQuery:
			*((char **)data) = ARGSKEY;
			break;
		case OH_OutputQuery:
			*((char ***)data) = outputtypes;
			break;
		case OH_RGBAOrder:
			*((ULONG *)data) = ORDER_RGBA;
			break;
		default:
			return(0);
	}

	return(1);
}


void dl1Quantize(unsigned long *buffer, unsigned long numc, unsigned long base, unsigned char *qbuffer,unsigned long *paltable)
{
	unsigned long *pp;
	unsigned char *pr,*pg,*pb;
	int t;

	reset();
	build_table(buffer, (ulong)bufwidth * (ulong)bufheight);
	reduce_table(numc);
	set_palette(0, 0);
	quantize_image(buffer, qbuffer, bufwidth, bufheight, 1, base);

	pp = paltable;
	pr = palette[0];
	pg = palette[1];
	pb = palette[2];

	*pp++ = (numc<<16)+base;

	for(t=0; t<numc; t++)
	{
		*pp++ = ((unsigned long)(*pr++)) * 0x01010101;
		*pp++ = ((unsigned long)(*pg++)) * 0x01010101;
		*pp++ = ((unsigned long)(*pb++)) * 0x01010101;
	}
	*pp = 0;
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
