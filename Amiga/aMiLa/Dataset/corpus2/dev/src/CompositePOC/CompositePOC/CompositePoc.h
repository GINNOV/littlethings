/*==================================================================*/
/* CompositePOC.c: Composite Proof Of Concept - July 2012 											*/
/* Author: Alain Thellier - Paris - France . See ReadMe for more infos										*/
/* v1.0 July  2011: Demonstrate how to use the OS function CompositeTags() to make a game					*/
/* CompositeTags() is an OS4 function that add blitter-like hardware accelerated functions					*/
/*==================================================================*/
#ifdef __amigaos4__
#define __USE_INLINE__
#define __USE_BASETYPE__
#define __USE_OLD_TIMEVAL__
#endif

#include <stdio.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>
#include <strings.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/Picasso96API.h>
#include <proto/cybergraphics.h>
#include <proto/datatypes.h>
#include <proto/timer.h>

#include <graphics/composite.h>
#include <libraries/Picasso96.h>
#include <cybergraphx/cybergraphics.h>
#include <datatypes/pictureclass.h>

/*==================================================================*/
BOOL debug=FALSE;
/*==================================================================*/
#define ZZ printf("ZZ stepping ..\n");
#define REM(message)  if(debug) {printf(#message"\n");}
#define    VAR(var)   if(debug) {printf(" " #var "=" ); printf("%ld\n",  ((ULONG)var)  );}
#define   VARP(var)   if(debug) {if(var!=0) {printf(" " #var "=" ); printf("%ld\n",  ((ULONG)var)  );} else {printf(" " #var "=NULL\n");}}
#define   VARF(var)   if(debug) {pfloat(" " #var "="   , &var,1);}

#define SFUNCTION(message)   if(debug) printf(#message"\n");
#define MYCLR(x) 	memset(&x,0,sizeof(x));
#define NLOOP(nbre) for(n=0;n<nbre;n++)
#define MLOOP(nbre) for(m=0;m<nbre;m++)
#define XLOOP(nbre) for(x=0;x<nbre;x++)
#define YLOOP(nbre) for(y=0;y<nbre;y++)
/*================================================================*/
struct XYSTW_Vertex3D { 
float x, y; 
float s, t, w; 
}; 
/*================================================================*/
struct texture3D {
UWORD high,large;
struct BitMap  *bm;
void *pt;
};
/*================================================================*/
struct sprite3D {
struct XYSTW_Vertex3D Rect[4]; 
struct texture3D *T;
float  large,high;
float  u,v,SizeU,SizeV;
ULONG  CompMode;
}; 
/*================================================================*/
struct map3D {
struct texture3D TilesTex;
struct XYSTW_Vertex3D *GridP;
struct sprite3D *Tiles;
UBYTE *TilesMap;
ULONG  MapSizeX,MapSizeY;
ULONG  TilesSizeX,TilesSizeY;
float  MapPosX,MapPosY;
LONG MinX,MaxX,MinY,MaxY;
LONG   TilePosX,TilePosY;
LONG   MarginTilesX,MarginTilesY,VisibleTilesX,VisibleTilesY;
LONG  MouseTilePosX,MouseTilePosY;
ULONG  GridSize,GridNb;
ULONG  TileSize,TilesNb;
}; 
/*==================================================================*/
struct engine3D{
struct Screen  *screen;
struct Window  *window	;
struct BitMap  *bm;
struct RastPort bufferrastport;
UWORD large,high;
struct map3D LevelMap;
struct map3D TextMap;
ULONG  StartTime;
ULONG  MilliTime;
ULONG  LastMilliTime;
ULONG  TimePerFrame;
ULONG  Time;
ULONG  FramesDone;
ULONG  Fps;
UBYTE  FpsText[200];
BOOL   Closed;
float  RotZ,RotZ2,CenterX,CenterY;
float  AxisX,AxisY;
float  MovingX,MovingY;
UBYTE  TileNum;
float  Zoom;
ULONG MouseX,MouseY;
float EditX,EditY;
BOOL Push,Drag,Edit,GameStarted;
ULONG MouseButtons,VanillaKey;
ULONG Player,Score,Lifes;
UBYTE  ProgName[256];
} Engine;
/*==================================================================*/
struct sprite3D ship,shadow,halo,cloud;
struct texture3D shiptex,shadowtex,halotex,cloudtex;
/*==================================================================*/
struct IntuitionBase*	IntuitionBase		=NULL;
struct GfxBase*		GfxBase			=NULL;
struct Library*		CyberGfxBase		=NULL;
struct Library*		UtilityBase			=NULL;
struct Library*		GadToolsBase		=NULL;
struct Library* 		P96Base 			=NULL;
struct Library*		DataTypesBase		=NULL;

struct Device *		TimerBase			=NULL;
struct timerequest tr;
/*==================================================================*/
struct GraphicsIFace*			IGraphics			=NULL;
struct IntuitionIFace*			IIntuition			=NULL;
struct GadToolsIFace*			IGadTools			=NULL;
struct CyberGfxIFace*			ICyberGfx			=NULL;
struct UtilityIFace*			IUtility			=NULL;
struct P96IFace* 				IP96 				=NULL;
struct DataTypesIFace*			IDataTypes			=NULL;

struct TimerIFace*			ITimer			=NULL;
/*==================================================================================*/
void FreeTexturePOC(struct texture3D *T);
void COMP3D_DrawTriangles(struct XYSTW_Vertex3D *P,ULONG Vnb,ULONG CompMode,void *texbm);
/*==================================================================================*/
BOOL OpenAmigaLibraries(void)
{
#define LIBOPEN(libbase,name,version)  libbase	=(void*)OpenLibrary(#name,version);				if(libbase==NULL) 	return(FALSE);
#define LIBOPEN4(interface,libbase)    interface=(void*)GetInterface((struct Library *)libbase, "main", 1, NULL);	if(interface==NULL)	return(FALSE);



	LIBOPEN(DOSBase,dos.library,36L)
	LIBOPEN(GfxBase,graphics.library,0L)
	LIBOPEN(IntuitionBase,intuition.library,0L)
	LIBOPEN(UtilityBase,utility.library,36L)
	LIBOPEN(GadToolsBase,gadtools.library,37L)
	LIBOPEN(CyberGfxBase,cybergraphics.library,0L)
	LIBOPEN(P96Base,Picasso96API.library,0L)
	LIBOPEN(DataTypesBase,datatypes.library,39L)

	LIBOPEN4(IExec,SysBase)

	LIBOPEN4(IDOS,DOSBase)
	LIBOPEN4(IGraphics,GfxBase)
	LIBOPEN4(IIntuition,IntuitionBase)
	LIBOPEN4(IUtility,UtilityBase)
	LIBOPEN4(IGadTools,GadToolsBase)
	LIBOPEN4(ICyberGfx,CyberGfxBase)
	LIBOPEN4(IP96,P96Base)
	LIBOPEN4(IDataTypes,DataTypesBase)

	if (OpenDevice(TIMERNAME, UNIT_MICROHZ, (struct IORequest *)&tr, 0L) != 0)
		return(FALSE);
	TimerBase = (struct Device  *) tr.tr_node.io_Device;
	LIBOPEN4(ITimer,TimerBase);
	if (ITimer==NULL)		return(FALSE);

	return(TRUE);
}
/*======================================================================================*/
void CloseAmigaLibraries()
{
#define LIBCLOSE(libbase)	 if(libbase!=NULL)	{CloseLibrary( (struct Library  *)libbase );   libbase=NULL; }
#define LIBCLOSE4(interface) if(interface!=NULL)	{DropInterface((struct Interface*)interface );interface=NULL;}

	LIBCLOSE4(IDOS)
	LIBCLOSE4(IGraphics)
	LIBCLOSE4(IIntuition)
	LIBCLOSE4(IGadTools)
	LIBCLOSE4(ICyberGfx)
	LIBCLOSE4(ITimer)
	LIBCLOSE4(IP96)
	LIBCLOSE4(IDataTypes)


	LIBCLOSE(DOSBase)
	LIBCLOSE(GfxBase)
	LIBCLOSE(IntuitionBase)
	LIBCLOSE(GadToolsBase)
	LIBCLOSE(UtilityBase)
	LIBCLOSE(CyberGfxBase)
	LIBCLOSE(P96Base)
	LIBCLOSE(DataTypesBase)

	CloseDevice((struct IORequest *)&tr);
}
/*=================================================================*/
void SetP(struct XYSTW_Vertex3D  *P,float x, float y,float u, float v)
{
	P->x=x; P->y=y;P->s=u; P->t=v;P->w=1.0;
}
/*=================================================================*/
void PrintP(struct XYSTW_Vertex3D  *P)
{
	 if(debug) 
		printf("P XY %4.2f %4.2f STW %4.2f %4.2f %4.2f  \n",P->x,P->y,P->s,P->t,P->w); 
}
/*==================================================================*/
void SetSpritePOC(struct sprite3D *S,float large,float high,struct texture3D *T,float u, float v,float SizeU,float SizeV,ULONG CompMode)
{
float s1=0.0;
float s2=0.4;
REM(SetSpritePOC)


	S->T=T;
	S->large=large;
	S->high=high;
	S->u=u+s1;
	S->v=v+s1;
	S->SizeU=SizeU-s2;
	S->SizeV=SizeV-s2;
	S->CompMode=CompMode;
}
/*=================================================================*/
void MoveP(struct XYSTW_Vertex3D  *P,ULONG Pnb,float R, float AxisX,float AxisY, float xpos,float ypos,float scale)
{
register float x;
register float y;
register float tmp;
register float CosR;
register float SinR;
register LONG n;
float Pi =3.1416;

	if(R==0.0)
	{
		NLOOP(Pnb)
		{
		x=P->x;		/* to registers  */
		y=P->y;

		x= scale*x;		/* scaling */
		y= scale*y;

		x= x + xpos;	/* go to this x y position */
		y= y + ypos;

		P->x= x;		/* to memory  */
		P->y= y;

		P++;
		}
	return;
	}

/* rotated quad */
	R= R / 180.0 * Pi;
	CosR=  (float)cos(R);
	SinR=  (float)sin(R);

	NLOOP(Pnb)
	{
	x=P->x;			/* to registers  */
	y=P->y;

	x= scale*x;			/* scaling */
	y= scale*y;

	x= x + xpos;		/* go to this x y position */
	y= y + ypos;

	x= x - AxisX;		/* centering to x y axis */
	y= y - AxisY;

	tmp= (x *CosR - y*SinR);	/* R rotating on z axis */
	y    = (y *CosR + x*SinR);
	x    =tmp;

	x= x + AxisX;
	y= y + AxisY;		/* back to x y axis position */

	P->x = x;			/* to memory  */
	P->y = y;
	P++;
	}
}
/*=================================================================*/
void MoveSpritePOC(struct sprite3D *S,float R, float xpos,float ypos,float scale)
{
struct XYSTW_Vertex3D *P=S->Rect;


	SetP(&P[0],0,0,S->u,S->v);
	SetP(&P[1],0,0+S->high,S->u,S->v+S->SizeV);
	SetP(&P[2],0+S->large,0+S->high,S->u+S->SizeU,S->v+S->SizeV);
	SetP(&P[3],0+S->large,0,S->u+S->SizeU,S->v);

	MoveP(P,4,R,Engine.AxisX,Engine.AxisY,xpos,ypos,scale);	 /* a rect got 4 points and the axis in the middle */ 
}
/*=================================================================*/
void SetAxisPOC(float AxisX,float AxisY)
{
	Engine.AxisX=AxisX;
	Engine.AxisY=AxisY;
}
/*================================================================*/
void DrawSpritePOC(struct sprite3D *S)
{
struct XYSTW_Vertex3D *RECT=S->Rect;
struct XYSTW_Vertex3D TRI[2*3];
#define COPYV(a,b)   { (a)->x=(b)->x; (a)->y=(b)->y; (a)->s=(b)->s; (a)->t=(b)->t; (a)->w=(b)->w;  }
ULONG n;

	COPYV( &TRI[0] , &RECT[0] );
	COPYV( &TRI[1] , &RECT[1] );
	COPYV( &TRI[2] , &RECT[2] );
	COPYV( &TRI[3] , &RECT[0] );
	COPYV( &TRI[4] , &RECT[2] );
	COPYV( &TRI[5] , &RECT[3] );

	if(Engine.Zoom!=1.0)
	NLOOP(6)
		{
		TRI[n].x= TRI[n].x * Engine.Zoom;
		TRI[n].y= TRI[n].y * Engine.Zoom;
		}

	COMP3D_DrawTriangles(TRI,6,S->CompMode,S->T->bm);
}
/*=================================================================*/
BOOL LoadFile(UBYTE *name,UBYTE *buffer, ULONG size)
{						/* load a file in memory */
FILE *fp;

	fp = fopen(name,"rb");
	if(fp == NULL)
		{printf("Cant open file ! <%s>\n",name); return(FALSE); }
	size = fread(buffer,size,1,fp);
	if(size ==0 )
		{printf("Cant read file ! <%s>\n",name); return(FALSE); }
	fclose(fp);
	return(TRUE);
}
/*=================================================================*/
BOOL SaveFile(UBYTE *filename,UBYTE *pt,LONG size)
{
FILE *fp;

	fp=fopen(filename,"wb");
	if(fp == NULL)
		{printf("Cant open file ! <%s>\n",filename); return(FALSE); }
	size=fwrite(pt,size,1,fp);
	if(size ==0 )
		{printf("Cant write file ! <%s>\n",filename); return(FALSE); }
	fclose(fp);
	return(TRUE);
}
/*=================================================================*/
void LoadTextureRAW(struct texture3D *T,UBYTE* filename,UWORD large,UWORD high)
{						/* load a RAW rgb bitmap in memory. Make it a Composite texture */
	if(T->pt==NULL)
		printf("Not allocated picture! \n");
	if(LoadFile(filename,T->pt,large*high*32/8)==FALSE)
		return;
}
/*==========================================================================*/
void	 MyDrawText(WORD x,WORD y,UBYTE *text)
{						/* draw a text in the window */
struct RastPort *rp;

	rp=Engine.window->RPort;
	SetAPen(rp, 0) ;
	RectFill(rp,x-3,y-9,x+8*strlen(text)+3,y+2);

	SetAPen(rp, 2);
	Move(rp,x-2,y-2);
	Text(rp,(void*)text, strlen(text));

	SetAPen(rp, 2);
	Move(rp,x,y);
	Text(rp,(void*)text, strlen(text));

	SetAPen(rp, 1);
	Move(rp,x-1,y-1);
	Text(rp,(void*)text, strlen(text));

	SetAPen(rp, 1);
}
/*==================================================================================*/
void OSGetTime(void)
{
struct timeval tv;
#define FPS 25
ULONG Frequence1=FPS;
ULONG Frequence2=1000000/Frequence1;

REM(OSGetTime)
	GetSysTime((void *)&tv);
	if(Engine.StartTime==0)	Engine.StartTime=tv.tv_secs;
	Engine.Time= (tv.tv_secs-Engine.StartTime) * Frequence1 + tv.tv_micro/Frequence2;

}
/*==================================================================================*/
ULONG OSMilliTimer(void)
{
struct timeval tv;
ULONG	MilliFrequence1=1000;
ULONG	MilliFrequence2=1000000/MilliFrequence1;
ULONG MilliTime;

REM(OSMilliTimer)
	GetSysTime((void *)&tv);
	if(Engine.StartTime==0)	Engine.StartTime=tv.tv_secs;
	MilliTime  = (tv.tv_secs-Engine.StartTime) *  MilliFrequence1 + tv.tv_micro/MilliFrequence2;
	return(MilliTime);
}
/*=================================================================*/
void DoTiming(void)
{					
ULONG MilliTime;

	sprintf(Engine.FpsText,"%s: %d Fps (%d %d) Pos(%2.2f %2.2f)  rot %2.2f ",Engine.ProgName,Engine.Fps,Engine.Time,Engine.FramesDone,Engine.LevelMap.MapPosX,Engine.LevelMap.MapPosY,Engine.RotZ);

	OSGetTime();
	MilliTime=OSMilliTimer();
	Engine.TimePerFrame= MilliTime - Engine.LastMilliTime;
	Engine.LastMilliTime=MilliTime;
	if(Engine.TimePerFrame!=0)
		Engine.Fps=(((ULONG)1000)/Engine.TimePerFrame);
	if(debug)	MyDrawText(3,Engine.high-10,Engine.FpsText);
}
/*=================================================================*/
void SwitchDisplayPOC(void)
{
	WaitBlit();
	BltBitMapRastPort(Engine.bufferrastport.BitMap,0,0,Engine.window->RPort,0,0,Engine.large,Engine.high,0xC0);	/* copy the "back buffer" to the window */
	Engine.FramesDone++;
	p96RectFill(&Engine.bufferrastport,0,0,Engine.large,Engine.high,0);
}
/*=================================================================*/
BOOL StartPOC(UBYTE *name,UWORD large,UWORD high,float Zoom)
{						/* open a window & a rastport ("back buffer") */
UWORD screenlarge,screenhigh;
ULONG ModeID,ScreenBits;
ULONG Flags =WFLG_ACTIVATE | WFLG_REPORTMOUSE | WFLG_RMBTRAP | WFLG_SIMPLE_REFRESH | WFLG_GIMMEZEROZERO ;
ULONG IDCMPs=IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY | IDCMP_RAWKEY | IDCMP_MOUSEMOVE | IDCMP_MOUSEBUTTONS ;

	strcpy(Engine.ProgName,name);
	Engine.large		=large;
	Engine.high			=high;
	Engine.screen		=NULL;
	Engine.window		=NULL;
	Engine.bm			=NULL;
	Engine.StartTime		=0;
	Engine.MilliTime		=0;
	Engine.Time			=0;
	Engine.FramesDone	=0;
	Engine.Fps			=0;
	Engine.Closed		=FALSE;
	Engine.FpsText[0]		=0;
	Engine.LevelMap.TilesMap	=NULL;
	Engine.TextMap.TilesMap	=NULL;
	Engine.Lifes		=3;
	Engine.GameStarted	=FALSE;
	Engine.Player		=1;
	Engine.Score		=10500;

	Engine.RotZ			=0.0;
	Engine.RotZ2		=0.0;

	Engine.AxisX		=large/2;
	Engine.AxisY		=high /2;

	Engine.Zoom			=Zoom;

	Engine.CenterX		=Engine.large/(Engine.Zoom*2.0);
	Engine.CenterY		=Engine.high /(Engine.Zoom*2.0);


	OpenAmigaLibraries();

	Engine.screen 	=LockPubScreen("Workbench") ;
	screenlarge	=Engine.screen->Width;
 	screenhigh	=Engine.screen->Height;
	ModeID = GetVPModeID(&Engine.screen->ViewPort);
	UnlockPubScreen(NULL, Engine.screen);

	Engine.window = OpenWindowTags(NULL,
	WA_Activate,	TRUE,
	WA_InnerWidth,	Engine.large,
	WA_InnerHeight,	Engine.high,
	WA_Left,		(screenlarge - Engine.large)/2,
	WA_Top,		(screenhigh  -  Engine.high)/2,
	WA_Title,		(ULONG)Engine.ProgName,
	WA_DragBar,		TRUE,
	WA_CloseGadget,	TRUE,
	WA_GimmeZeroZero,	TRUE,
	WA_Backdrop,	FALSE,
	WA_Borderless,	FALSE,
	WA_IDCMP,		IDCMPs,
	WA_Flags,		Flags,
	TAG_DONE);

	if (Engine.window==NULL)
		{printf("Cant open window\n");return FALSE;}

	InitRastPort( &Engine.bufferrastport );				/* allocate an other bitmap/rastport four double buffering */
	ScreenBits  = GetBitMapAttr( Engine.window->WScreen->RastPort.BitMap, BMA_DEPTH );
	Flags = BMF_DISPLAYABLE|BMF_MINPLANES;
	Engine.bufferrastport.BitMap = AllocBitMap(Engine.large,Engine.high,ScreenBits, Flags, Engine.window->RPort->BitMap);
	if(Engine.bufferrastport.BitMap==NULL)
		{printf("No Bitmap\n");return FALSE;}

	Engine.bm=Engine.bufferrastport.BitMap;				/* draw in this back-buffer */

	return(TRUE);
}
/*=================================================================*/
void ClosePOC(void)
{
	if(Engine.bufferrastport.BitMap)			FreeBitMap(Engine.bufferrastport.BitMap);
	if(Engine.window)						CloseWindow(Engine.window);
	if(Engine.LevelMap.TilesMap)			free(Engine.LevelMap.TilesMap);
	if(Engine.TextMap.TilesMap)				free(Engine.TextMap.TilesMap);
	if(Engine.LevelMap.GridP)				free(Engine.LevelMap.GridP);
	if(Engine.TextMap.GridP)				free(Engine.TextMap.GridP);
	FreeTexturePOC(&Engine.LevelMap.TilesTex);
	FreeTexturePOC(&Engine.TextMap.TilesTex);
}
/*=================================================================*/
UBYTE GetTilePOC(struct map3D *Map,LONG x,LONG y)
{
UBYTE TileNum=0;

	if(Map==NULL) return;
	if(Map->TilesMap)
	if(0<=x) 
	if(0<=y)
	if(x<Map->MapSizeX)
	if(y<Map->MapSizeY) 
		TileNum= Map->TilesMap[x+y*Map->MapSizeX];

	if(TileNum>=Map->TilesNb)
		TileNum=0;
	return(TileNum);
}
/*=================================================================*/
void SetTilePOC(struct map3D *Map,LONG x,LONG y,UBYTE TileNum)
{

	if(Map==NULL) return;
	if(TileNum<Map->TilesNb)
	if(Map->TilesMap)
	if(0<=x) 
	if(0<=y)
	if(x<Map->MapSizeX)
	if(y<Map->MapSizeY) 
		Map->TilesMap[x+y*Map->MapSizeX]=TileNum;
}
/*=================================================================*/
void TextToMapPOC(struct map3D *Map,LONG x,LONG y,UBYTE *name)
{
ULONG n,size;

	if(name==NULL) return;
	if(Map==NULL) return;

	size=strlen(name);
	NLOOP(size)
		SetTilePOC(Map,x+n,y,name[n]);
}
/*================================================================================*/
void WindowEventsPOC(void)
{							/* manage the window  */
struct IntuiMessage *imsg;
ULONG x,y;
#define et  &&

	DoTiming();
	Engine.VanillaKey=0;
	Engine.MouseButtons=0;
	while( (imsg = (struct IntuiMessage *)GetMsg(Engine.window->UserPort)))
	{
	if (imsg == NULL) break;

	x=imsg->MouseX;
	y=imsg->MouseY;
	x=x-Engine.window->BorderLeft;
	y=y-Engine.window->BorderTop;

	if ((0<=x) et (x<Engine.large) et (0<=y) et (y<Engine.high))
	{
		Engine.MouseX=x;
		Engine.MouseY=y;

		Engine.EditX=(float)x/(float)Engine.large;
		Engine.EditY=(float)y/(float)Engine.high;
		Engine.EditX=Engine.EditX*2.0-1.0;
		Engine.EditY=Engine.EditY*2.0-1.0;
	}

	switch (imsg->Class)
		{
			case IDCMP_CLOSEWINDOW:
			Engine.Closed=TRUE;				break;

			case IDCMP_MOUSEBUTTONS:
			Engine.MouseButtons=imsg->Code;
			if (imsg->Code == SELECTDOWN) 
				Engine.Drag=TRUE;
			if (imsg->Code == SELECTUP)
				Engine.Drag=FALSE;
			if (imsg->Code == MENUDOWN) 
				{
				Engine.Push=TRUE;
				Engine.TileNum++;
				}
			if (imsg->Code == MENUUP)
				Engine.Push=FALSE;				
			break;

			case IDCMP_VANILLAKEY:
			Engine.VanillaKey=imsg->Code;

			default:
			break;
		}
	if(imsg)
		{ReplyMsg((struct Message *)imsg);imsg = NULL;}
	}

}
/*==================================================================================*/
ULONG LibMilliTimer(void)
{
struct timeval tv;
ULONG	MilliFrequence1=1000;
ULONG	MilliFrequence2=1000000/MilliFrequence1;
ULONG MilliTime;

	GetSysTime((void *)&tv);
	if(Engine.StartTime==0)	Engine.StartTime=tv.tv_secs;
	MilliTime  = (tv.tv_secs-Engine.StartTime) *  MilliFrequence1 + tv.tv_micro/MilliFrequence2;
	return(MilliTime);
}
/*==================================================================*/
void fillBmTexture(struct texture3D *T)
{
UBYTE *ARGB;				/* bm memory  */
LONG lock;					/* to directly write to bm */
ULONG size,n;
UBYTE *RGBA;
UBYTE *RGB;
struct RenderInfo renderInfo;

	SFUNCTION( fillBmTexture);


	lock=p96LockBitMap(T->bm, (UBYTE*)&renderInfo, sizeof(renderInfo));
	ARGB=renderInfo.Memory;


	size=T->large*T->high;

	NLOOP(size)
		{
		ARGB[0]=255;		
		ARGB[1]=n;	
		ARGB[2]=n-size;	
		ARGB[3]=n;	
		ARGB+=4;
		RGB+=3;
		}

	p96UnlockBitMap(T->bm,lock);

}
/*==================================================================================*/
void LoadTexturePOC(struct texture3D *T,UBYTE* filename)
{
struct BitMapHeader *bitMapHeader = NULL;
struct RenderInfo renderInfo;
Object* dto ;
ULONG srcBytesPerRow,lock;
	
	dto= NewDTObject(filename, DTA_SourceType,DTST_FILE, DTA_GroupID, GID_PICTURE,PDTA_DestMode, PMODE_V43,PDTA_Remap, FALSE,TAG_DONE);

	if(!dto)
		REM(ERROR: Could not open texture file)
	
	if(GetDTAttrs(dto,PDTA_BitMapHeader,&bitMapHeader,TAG_DONE) != 1)
	{
		DisposeDTObject(dto);
		REM(Could not obtain the picture objects bitmap header)
	}

	T->large	=bitMapHeader->bmh_Width;
	T->high	=bitMapHeader->bmh_Height;
	T->bm	=p96AllocBitMap(T->large, T->high, 32, BMF_DISPLAYABLE,NULL, RGBFB_A8R8G8B8);
	T->pt	=NULL;

	if(!T->bm)
	{
		DisposeDTObject(dto);
		REM(ERROR: Could not allocate a bitmap)
	}
	
	// Extract the bitmap data from the picture object
	// NOTE: For some reason the picture datatype kills the alpha channel unless
	// we extract the pixel data using PDTM_READPIXELARRAY

	lock = p96LockBitMap(T->bm,(UBYTE*)&renderInfo, sizeof(renderInfo));
	srcBytesPerRow = p96GetBitMapAttr(T->bm, P96BMA_BYTESPERROW);
	
	IDoMethod(dto, 
		PDTM_READPIXELARRAY,
		renderInfo.Memory,
		PBPAFMT_ARGB,
		srcBytesPerRow,
		0,
		0,
		T->large,
		T->high);

	p96UnlockBitMap(T->bm, lock);
	DisposeDTObject(dto);



}
/*==================================================================*/
void UpdateBmTexture(struct texture3D *T)
{
UBYTE *ARGB;				/* bm memory  */
LONG lock;					/* to directly write to bm */
ULONG size,n;
UBYTE *RGBA;
UBYTE *RGB;
struct RenderInfo renderInfo;

	SFUNCTION(UpdateBmTexture);
	if(T->bm==NULL) return;

	lock=p96LockBitMap(T->bm, (UBYTE*)&renderInfo, sizeof(renderInfo));
	ARGB=renderInfo.Memory;

	RGBA=RGB=T->pt;
	size=T->large*T->high;

	NLOOP(size)
		{
		ARGB[0]=255;		
		ARGB[1]=RGB[0];	
		ARGB[2]=RGB[1];	
		ARGB[3]=RGB[2];	
		ARGB+=4;
		RGB+=3;
		}

	p96UnlockBitMap(T->bm,lock);

}

/*==================================================================*/
BOOL AllocTexture(struct texture3D *T,UWORD large,UWORD high)
{

	T->pt=malloc(large*high*4);

	if(T->pt==NULL)
		return(FALSE);
	T->large=large;
	T->high=high;
	T->bm = p96AllocBitMap(large,high,32,BMF_DISPLAYABLE,NULL,RGBFB_A8R8G8B8);
	if(T->bm==NULL)
		{
		free(T->pt);
		return(FALSE);
		}
	UpdateBmTexture(T);
	return(TRUE);
}
/*==================================================================*/
void FreeTexturePOC(struct texture3D *T)
{

	if(T->bm)
	{
      	p96FreeBitMap(T->bm);
      	T->bm = NULL;
    	}
	if(T->pt)
	{
		free(T->pt);
      	T->pt = NULL;
    	}
}
/*==================================================================*/
void LumiToAlphaPOC(struct texture3D *ST)
{
UBYTE *Image8;				/* bm memory  */
LONG lock;					/* to directly write to bm */
ULONG x,y;
UBYTE *ARGB;
struct RenderInfo renderInfo;
ULONG xoffset;

	if(ST->bm==NULL) return;

	SFUNCTION(LumiToAlphaPOC);
	lock=p96LockBitMap(ST->bm, (UBYTE*)&renderInfo, sizeof(renderInfo));
	Image8=renderInfo.Memory;
	ARGB=Image8;
	xoffset= p96GetBitMapAttr(ST->bm, P96BMA_BYTESPERROW) - (ST->large*32/8);
	YLOOP(ST->high)
	{
	XLOOP(ST->large)
		{
		ARGB[0]=(ARGB[1]+ARGB[2]+ARGB[3])/3;  /* store color average level in alpha */
		ARGB+=4;
		}
	ARGB+=xoffset;
	}

	p96UnlockBitMap(ST->bm,lock);
}
/*==================================================================*/
void BlackToAlphaPOC(struct texture3D *ST)
{
UBYTE *Image8;				/* bm memory  */
LONG lock;					/* to directly write to bm */
ULONG x,y;
UBYTE *ARGB;
struct RenderInfo renderInfo;
ULONG xoffset;

	if(ST->bm==NULL) return;

	SFUNCTION(BlackToAlphaPOCPOC);
	lock=p96LockBitMap(ST->bm, (UBYTE*)&renderInfo, sizeof(renderInfo));
	Image8=renderInfo.Memory;
	ARGB=Image8;
	xoffset= p96GetBitMapAttr(ST->bm, P96BMA_BYTESPERROW) - (ST->large*32/8);
	YLOOP(ST->high)
	{
	XLOOP(ST->large)
		{
		ARGB[0]=255;
		if( (ARGB[1]+ARGB[2]+ARGB[3]) == 0)			/* if black */
			ARGB[0]=0;						/* then transp alpha */
		ARGB+=4;
		}
	ARGB+=xoffset;
	}

	p96UnlockBitMap(ST->bm,lock);
}
/*==================================================================*/
void TranspAlphaPOC(struct texture3D *ST,float alpha)
{
UBYTE *Image8;				/* bm memory  */
LONG lock;					/* to directly write to bm */
ULONG x,y;
UBYTE *ARGB;
struct RenderInfo renderInfo;
ULONG xoffset;
float A;

	if(ST->bm==NULL) return;
	if(alpha>=1.0) return;
	if(alpha <0.0) return;

	SFUNCTION(TranspAlphaPOC);
	lock=p96LockBitMap(ST->bm, (UBYTE*)&renderInfo, sizeof(renderInfo));
	Image8=renderInfo.Memory;
	ARGB=Image8;
	xoffset= p96GetBitMapAttr(ST->bm, P96BMA_BYTESPERROW) - (ST->large*32/8);
	YLOOP(ST->high)
	{
	XLOOP(ST->large)
		{
		A=ARGB[0];
		ARGB[0]=(A*alpha);
		ARGB+=4;
		}
	ARGB+=xoffset;
	}

	p96UnlockBitMap(ST->bm,lock);
}
/*==================================================================*/
void COMP3D_DrawTriangles(struct XYSTW_Vertex3D *P,ULONG Pnb,ULONG CompMode,void *texbm)
{
ULONG TRInb=Pnb/3;
ULONG error,flags,n,x,y,high,large;
struct BitMap  *bm=Engine.window->WScreen->RastPort.BitMap;

REM(COMP3D_DrawTriangles)
	x=0;
	y=0;
	high =Engine.high;
	large=Engine.large;

	flags=COMPFLAG_HardwareOnly | COMPFLAG_SrcFilter|COMPFLAG_IgnoreDestAlpha;
	bm=Engine.bm;

	error = CompositeTags(CompMode, 
		texbm,bm,
		COMPTAG_VertexArray, P, 
		COMPTAG_VertexFormat,COMPVF_STW0_Present,
	    	COMPTAG_NumTriangles,TRInb,
		COMPTAG_DestX,x,
		COMPTAG_DestY,y,
		COMPTAG_DestWidth ,large,
		COMPTAG_DestHeight,high,
		COMPTAG_Flags, flags ,
		TAG_DONE);

	NLOOP(Pnb)
		PrintP(&P[n]);

	if(error != COMPERR_Success)
			printf("CompositeTags error %d\n",error);
}
/*=================================================================*/
void ClearMapPOC(struct map3D *Map)
{
ULONG x,y;

	if(Map->TilesMap)
	YLOOP(Map->MapSizeY) 
	XLOOP(Map->MapSizeX)
		SetTilePOC(Map,x,y,0);

}
/*=================================================================*/
void InitMapPOC(struct map3D *Map,UBYTE *filename,ULONG TileSize,ULONG MapSizeX,ULONG MapSizeY,ULONG CompMode)
{
ULONG x,y;
UBYTE TileNum=0;

	LoadTexturePOC(&Map->TilesTex,filename);

	Map->TileSize		=TileSize;
	Map->MapSizeX	=MapSizeX;
	Map->MapSizeY	=MapSizeY;

	Map->TilesSizeX		=(Map->TilesTex.large/ Map->TileSize  );
	Map->TilesSizeY		=(Map->TilesTex.high / Map->TileSize  );
	Map->TilesNb			=(Map->TilesSizeX    * Map->TilesSizeY);

	Map->VisibleTilesX=Engine.large / (((float)Map->TileSize)*Engine.Zoom);
	Map->VisibleTilesY=Engine.high/ (((float)Map->TileSize)*Engine.Zoom);

	if(Engine.large<Engine.high)
		Map->GridSize=(3*Map->VisibleTilesY)/2;
	else
		Map->GridSize=(3*Map->VisibleTilesX)/2;

	Map->MarginTilesX= (Map->GridSize - Map->VisibleTilesX) /2 ;
	Map->MarginTilesY= (Map->GridSize - Map->VisibleTilesY) /2 ;

	Map->MinX= 0 - Map->MarginTilesX;
	Map->MaxX=Map->MapSizeX - Map->MarginTilesX - Map->VisibleTilesX;
	Map->MinY= 0 - Map->MarginTilesY;
	Map->MaxY=Map->MapSizeY - Map->MarginTilesY - Map->VisibleTilesY;

	Map->TilePosX		=0;
	Map->TilePosY		=0;
	Map->MapPosX		=Map->MinX;
	Map->MapPosY		=Map->MinY;

	Map->GridNb	=((Map->GridSize+1)*(Map->GridSize+1));

	Map->Tiles=malloc(sizeof(struct sprite3D)*Map->TilesNb);

	YLOOP(Map->TilesSizeY) 
	XLOOP(Map->TilesSizeX)
		SetSpritePOC(&Map->Tiles[Map->TilesSizeX*y+x],TileSize,TileSize,&Map->TilesTex,TileSize*x,TileSize*y,TileSize,TileSize,CompMode);

	Map->TilesMap 	=malloc(sizeof(UBYTE)*MapSizeY*MapSizeX);
	Map->GridP		=malloc(sizeof(struct XYSTW_Vertex3D)*Map->GridNb);

	ClearMapPOC(Map);
}
/*=================================================================*/
void DefaultMapPOC(struct map3D *Map)
{
ULONG x,y;
UBYTE TileNum=0;

	if(Map->TilesMap)
	YLOOP(Map->TilesSizeY) 
	XLOOP(Map->TilesSizeX)
	{
	TileNum=(x+y*Map->TilesSizeX);	
	SetTilePOC(Map,x,y,TileNum);
	}

}
/*=================================================================*/
void LoadMapPOC(UBYTE *filename,struct map3D *Map)
{
	if(Map==NULL) return;
	LoadFile(filename,Map->TilesMap,sizeof(UBYTE)*Map->MapSizeY*Map->MapSizeX);
}
/*=================================================================*/
void SaveMapPOC(UBYTE *filename,struct map3D *Map)
{
	if(Map==NULL) return;
	SaveFile(filename,Map->TilesMap,sizeof(UBYTE)*Map->MapSizeY*Map->MapSizeX);
}
/*=================================================================*/
void MapPositionPOC(struct map3D *Map,float  x,float y)
{
	if(Map==NULL) return;
	Map->MapPosX=x;
	Map->MapPosY=y;
}
/*=================================================================*/
void MapMovePOC(struct map3D *Map,float  x,float y)
{
	if(Map==NULL) return;
	Map->MapPosX+=x;
	Map->MapPosY+=y;
}
/*=================================================================*/
void DrawMapPOC(struct map3D *Map)
{
struct sprite3D *S;
struct XYSTW_Vertex3D *P;
ULONG x,y;
UBYTE TileNum;
float GridCenter;
float OffsetX,OffsetY;


REM(DrawMapPoc)
	if(Map==NULL) return;

	YLOOP((Map->GridSize+1))
	XLOOP((Map->GridSize+1))
	{

		P=&Map->GridP[(Map->GridSize+1)*y+x];
		P->x=x*Map->TileSize;		
		P->y=y*Map->TileSize;	
	}

	if(Map->MapPosX<Map->MinX)
		Map->MapPosX=Map->MinX;
	if(Map->MapPosY<Map->MinY)
		Map->MapPosY=Map->MinY;

	if(Map->MapPosX>Map->MaxX)
		Map->MapPosX=Map->MaxX;
	if(Map->MapPosY>Map->MaxY)
		Map->MapPosY=Map->MaxY;

	Map->TilePosX=Map->MapPosX;
	Map->TilePosY=Map->MapPosY;

	GridCenter=(Map->GridSize*Map->TileSize)/2;

	OffsetX=-((Map->MapPosX-Map->TilePosX)*Map->TileSize);
	OffsetY=-((Map->MapPosY-Map->TilePosY)*Map->TileSize);

	OffsetX=OffsetX+Engine.CenterX-GridCenter;
	OffsetY=OffsetY+Engine.CenterY-GridCenter;

	if(Map == &Engine.LevelMap)
		MoveP(Map->GridP,Map->GridNb,Engine.RotZ,Engine.CenterX,Engine.CenterY,OffsetX,OffsetY,1.0);
	else
		MoveP(Map->GridP,Map->GridNb,0.0,Engine.CenterX,Engine.CenterY,OffsetX,OffsetY,1.0);

	Map->MouseTilePosX=Map->TilePosX+ (Engine.MouseX-Engine.Zoom*OffsetX) / (Engine.Zoom*Map->TileSize);
	Map->MouseTilePosY=Map->TilePosY+ (Engine.MouseY-Engine.Zoom*OffsetY) / (Engine.Zoom*Map->TileSize);


	YLOOP(Map->GridSize)
	XLOOP(Map->GridSize)
	{
		TileNum=GetTilePOC(Map,Map->TilePosX+x,Map->TilePosY+y);

		if(Map == &Engine.LevelMap)
		if(Engine.Edit)
		if((Map->TilePosX+x)==Map->MouseTilePosX)
		if((Map->TilePosY+y)==Map->MouseTilePosY)
			TileNum=Engine.TileNum;

		if(TileNum!=0)
		{
		S=&Map->Tiles[TileNum];
		P=&Map->GridP[(Map->GridSize+1)*y+x];

		SetP(&S->Rect[0],P[0].x,P[0].y,S->u,S->v);
		SetP(&S->Rect[1],P[0+1].x,P[0+1].y,S->u+S->SizeU,S->v);
		SetP(&S->Rect[2],P[Map->GridSize+1+1].x,P[Map->GridSize+1+1].y,S->u+S->SizeU,S->v+S->SizeV);
		SetP(&S->Rect[3],P[Map->GridSize+1].x,P[Map->GridSize+1].y,S->u,S->v+S->SizeV);
		DrawSpritePOC(S);
		}
	}

	if(Map != &Engine.LevelMap)
		return;

	YLOOP(Map->GridSize)
	XLOOP(Map->GridSize)
	{
		TileNum=GetTilePOC(Map,Map->TilePosX+x,Map->TilePosY+y);
		P=&Map->GridP[(Map->GridSize+1)*y+x];

		MoveSpritePOC(&cloud,Engine.RotZ,P[0].x,P[0].y,1.0);
		if(TileNum>0)
		if((TileNum % 30)==0)
			DrawSpritePOC(&cloud);
	}

	S=&Map->Tiles[Engine.TileNum];
	MoveSpritePOC(S,0.0,20.0,20.0,2.0);
	if(Engine.Edit)	
		DrawSpritePOC(S);
}
/*================================================================================*/
