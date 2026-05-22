/* Dithering example using Warp3D - Alain Thellier & Kas1e - 2008 */

/* #define DODEBUG 1 */

#ifdef DODEBUG
#define REM(message) printf(#message"\n");
#else
#define REM(message) ;
#endif

#include <stdlib.h>
#include <stdio.h>
#include <strings.h>

#include <proto/exec.h>
#include <proto/intuition.h>
#include <proto/dos.h>
#include <proto/Warp3D.h>
#include <proto/graphics.h>
/*==================================================================================*/
struct Library *Warp3DBase;
W3D_Context *context = NULL;
struct Screen  *screen;
struct Window  *window;
struct RastPort bufferrastport;
ULONG OpenErr, CError;
ULONG ModeID,flags,ScreenBits;	
W3D_Texture *tex2 ;
W3D_Texture *tex1 ;
void *bitmap1=NULL;
void *bitmap2=NULL;
ULONG error;
W3D_Scissor scissor = {0,0,512,256};
WORD large=512;
WORD high=256;
WORD texlarge=256;
WORD texhigh =256;
/*==================================================================================*/
#include "FloydSteinbergForWarp3dv7.h"
/*==================================================================================*/
SwitchDisplay(void)
{
	W3D_FlushFrame(context);
	W3D_WaitIdle(context);
	BltBitMapRastPort(bufferrastport.BitMap,0,0,window->RPort,0,0,large,high,0xC0);		
	W3D_SetScissor(context, &scissor);
	W3D_SetDrawRegion(context, bufferrastport.BitMap, 0,&scissor);
}
/*==================================================================================*/
BOOL create_warp3d_context(void)
{
int x,y;

REM( Warp3D init......)
	Warp3DBase = OpenLibrary("Warp3D.library", 2L);
	if (!Warp3DBase) {
	printf("Error opening Warp3D library\n");
	return FALSE;
	};


	screen 	= LockPubScreen("Workbench") ;	
	x=screen->Width;
	y=screen->Height;	

	window = OpenWindowTags(NULL,	
	WA_Activate,	TRUE,	
	WA_Width,		large, 
	WA_Height,		high, 	
	WA_Left,		x/2-large/2,	
	WA_Top,		y/2-high/2,	
	WA_Title,		(ULONG)"Left:24 bits original. Right:16 bits Floyd Steinberg dithered.",
	WA_DragBar,		TRUE,
	WA_Backdrop,	FALSE,	
	WA_GimmeZeroZero,	TRUE,
	WA_Borderless,	FALSE,	
	TAG_DONE);	

	if (window==NULL)	
	{printf("Unable to open window\n");return FALSE;	}	

	InitRastPort( &bufferrastport );	
	ScreenBits  = GetBitMapAttr( window->WScreen->RastPort.BitMap, BMA_DEPTH );	
	flags = BMF_DISPLAYABLE|BMF_MINPLANES;	
	bufferrastport.BitMap = AllocBitMap(large,high,ScreenBits, flags, window->RPort->BitMap);	
	if(bufferrastport.BitMap==NULL)	
	{printf("No Bitmap\n");return FALSE;	}	

	context = W3D_CreateContextTags(&CError,	
		W3D_CC_BITMAP,(ULONG)bufferrastport.BitMap,	
		W3D_CC_YOFFSET,0,	
		W3D_CC_DRIVERTYPE,W3D_DRIVER_BEST,	
/*		W3D_CC_INDIRECT,TRUE,	*/
		W3D_CC_DOUBLEHEIGHT,FALSE, //DoubleHeightON,	
		W3D_CC_FAST,TRUE,	
	TAG_DONE);	

	if(CError==W3D_SUCCESS){printf("create Warp3D context success!\n");};
	if(CError==W3D_ILLEGALINPUT){printf("Illigal input!\n");};
	if(CError==W3D_NOMEMORY){printf("no memory\n");};
	if(CError==W3D_NODRIVER){printf("no driver\n");};
	if(CError==W3D_UNSUPPORTEDFMT){printf("usupportedfmt\n");};
	if(CError==W3D_ILLEGALBITMAP){printf("illegal bitmap\n");};

	W3D_ClearDrawRegion(context,0);
	return TRUE;
}
/*==================================================================================*/
void drawrect(W3D_Context *context,W3D_Texture *tex,float x,float y,float w, float h,float a)	
{
W3D_Vertex v[4];
W3D_Triangles tris;
float u1=0;
float v1=0;
float u2=texlarge;
float v2=texhigh;

	v[0].x=x;		v[0].y=y;		v[0].z=0.0;		v[0].u=u1;		v[0].v=v1;	v[0].w=1.0;
	v[0].color.r=a;	v[0].color.g=a;	v[0].color.b=a;	v[0].color.a=1.0;

	v[1].x=x+w;		v[1].y=y;		v[1].z=0.0;		v[1].u=u2;		v[1].v=v1;	v[1].w=1.0;
	v[1].color.r=a;	v[1].color.g=a;	v[1].color.b=a;	v[1].color.a=1.0;
		
	v[2].x=x;		v[2].y=y+h;		v[2].z=0.0;		v[2].u=u1;		v[2].v=v2;  v[2].w=1.0;
	v[2].color.r=a;	v[2].color.g=a;	v[2].color.b=a;	v[2].color.a=1.0;

	v[3].x=x+w;		v[3].y=y+h;		v[3].z=0.0;		v[3].u=u2;  	v[3].v=v2; 	v[3].w=1.0;
	v[3].color.r=a;	v[3].color.g=a;	v[3].color.b=a;	v[3].color.a=1.0;

	tris.tex		= tex;	
	tris.vertexcount	= 4;
	tris.v		= v;

	W3D_LockHardware(context);
	W3D_DrawTriStrip(context,&tris);
	W3D_UnLockHardware(context);
}
/*==================================================================================*/
main()
{
FILE *fp;

REM( main )
	if(FALSE==create_warp3d_context())
		goto panic;

REM( load tex )
	bitmap1=malloc(texlarge*texhigh*24/8);
	bitmap2=malloc(texlarge*texhigh*16/8);

	if((fp = fopen("PROGDIR:Limodorum_256X256X24.RAW","rb")) == NULL)
	{ printf("can't open picture\n");goto panic;}
	fread(bitmap1,texlarge*texhigh*24/8,1,fp);
	fclose(fp);

REM( tex 24 bits loaded)
	tex1 = W3D_AllocTexObjTags(context, &error,
		W3D_ATO_IMAGE,	bitmap1,		// The bitmap data
		W3D_ATO_FORMAT,	W3D_R8G8B8, 
		W3D_ATO_WIDTH,	texlarge,	
		W3D_ATO_HEIGHT,	texhigh,	
	TAG_DONE);

REM( draw 24 original to left side )
	drawrect(context,tex1,0,0,texlarge,texhigh,1.0);

REM( trying to dither data )
	FloydSteinbergTexture(bitmap1,bitmap2,texlarge,texhigh,W3D_R8G8B8,W3D_A1R5G5B5);
	tex2 = W3D_AllocTexObjTags(context, &error,
		W3D_ATO_IMAGE,	  bitmap2,			// The bitmap data
		W3D_ATO_FORMAT,	 W3D_A1R5G5B5,	
		W3D_ATO_WIDTH,	 texlarge,			 
		W3D_ATO_HEIGHT,	 texhigh,			 
	TAG_DONE);

REM( draw dithering data as second texture in right side )
	drawrect(context,tex2,256,0,texlarge,texhigh,1.0); 


 	SwitchDisplay();
	Delay(500);

panic:
REM( Closing down...)
	if (tex1)		W3D_FreeTexObj(context, tex1);
	if (tex2)		W3D_FreeTexObj(context, tex2);
	if (bitmap1)	free(bitmap1);
	if (bitmap2)	free(bitmap2);
	if (context)	W3D_DestroyContext(context);
	if (bufferrastport.BitMap)	FreeBitMap(bufferrastport.BitMap);	
	if (window)		CloseWindow(window);
	if (Warp3DBase)	CloseLibrary(Warp3DBase);

	exit(0);
}
