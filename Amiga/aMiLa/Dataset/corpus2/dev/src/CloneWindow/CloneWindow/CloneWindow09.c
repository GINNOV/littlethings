/*==============================================================================================*/
/* CloneWindow.c: Clone a Window to another one - July 2012 									*/
/* Author: Alain Thellier - Paris - France . See ReadMe for more infos							*/
/* Use the OS function CompositeTags() to clone a window										*/
/* v7.0 Nov 2012: now dest window is resizable 													*/
/* v8.0 Nov 2012: now redirect input to source window											*/
/* v9.0 Jun 2017: test maximum size so remove the 1800 pixels limit								*/
/* CompositeTags() is an OS4 function that add blitter-like hardware accelerated functions		*/
/*==============================================================================================*/
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
#include <proto/timer.h>

#include <graphics/composite.h>
#include <libraries/Picasso96.h>

/*==================================================================*/
BOOL debug=FALSE;
/*==================================================================*/
#define LLL  printf("Line:%ld\n",__LINE__);
#define REM(message)  if(debug) {printf(#message"\n");}
#define    VAR(var)   if(debug) {printf(" " #var "=" ); printf("%ld\n",  ((ULONG)var)  );}
#define   VARP(var)   if(debug) {if(var!=0) {printf(" " #var "=" ); printf("%ld\n",  ((ULONG)var)  );} else {printf(" " #var "=NULL\n");}}
#define   VARF(var)    if(debug) {printf(" " #var "=" ); printf("%2.2f\n",  (var)  );}
#define FUNC(message)   if(debug) printf(#message"\n");

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
struct rect3D {
float  x,y,large,high;
};
/*================================================================*/
struct sprite3D {
struct XYSTW_Vertex3D Quad[4]; 
struct texture3D *T;
float  x,y,large,high;
float  u,v,SizeU,SizeV;
ULONG  CompMode;
}; 
/*==================================================================*/
struct clonewindow3D{
struct Screen  *srcscreen;
struct Screen  *dstscreen;
struct Window  *srcwindow;
struct Window  *dstwindow;
struct IntuiMessage msg;
UWORD large,high;
ULONG  FramesDone;
UBYTE  WinTitle[256];
BOOL   Closed,CopyInput;
float  RotZ;
UBYTE  ProgName[256];
struct texture3D srcT;
struct texture3D dstT;
struct rect3D srcR;
struct rect3D dstR;
struct sprite3D S;
ULONG skipframes;
ULONG Wnum;
float xsize,ysize;
float xmin,ymin;
BOOL TooBig;	
} CW;
/*==================================================================*/
struct IntuitionBase*	IntuitionBase		=NULL;
struct GfxBase*		GfxBase			=NULL;
struct Library*		UtilityBase			=NULL;
struct Library*		GadToolsBase		=NULL;
struct Library* 		P96Base 			=NULL;
/*==================================================================*/
struct GraphicsIFace*			IGraphics			=NULL;
struct IntuitionIFace*			IIntuition			=NULL;
struct GadToolsIFace*			IGadTools			=NULL;
struct UtilityIFace*			IUtility			=NULL;
struct P96IFace* 				IP96 				=NULL;
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
	LIBOPEN(P96Base,Picasso96API.library,0L)

	LIBOPEN4(IExec,SysBase)

	LIBOPEN4(IDOS,DOSBase)
	LIBOPEN4(IGraphics,GfxBase)
	LIBOPEN4(IIntuition,IntuitionBase)
	LIBOPEN4(IUtility,UtilityBase)
	LIBOPEN4(IGadTools,GadToolsBase)
	LIBOPEN4(IP96,P96Base)

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
	LIBCLOSE4(IP96)


	LIBCLOSE(DOSBase)
	LIBCLOSE(GfxBase)
	LIBCLOSE(IntuitionBase)
	LIBCLOSE(GadToolsBase)
	LIBCLOSE(UtilityBase)
	LIBCLOSE(P96Base)

}
/*=================================================================*/
void SetP(struct XYSTW_Vertex3D  *P,float x, float y,float u, float v)
{
	P->x=x; P->y=y;P->s=u; P->t=v;P->w=1.0;
}
/*==================================================================*/
void SetSpriteCW(struct sprite3D *S,float large,float high,struct texture3D *T,float u, float v,float SizeU,float SizeV,ULONG CompMode)
{
struct XYSTW_Vertex3D *P=S->Quad;

FUNC(SetSpriteCW)
	S->T=T;
	S->large=large;
	S->high=high;
	S->u=u;
	S->v=v;
	S->SizeU=SizeU;
	S->SizeV=SizeV;
	S->CompMode=CompMode;

	SetP(&P[0],-0.5,-0.5,S->u,S->v);
	SetP(&P[1],-0.5,+0.5,S->u,S->v+S->SizeV);
	SetP(&P[2],+0.5,+0.5,S->u+S->SizeU,S->v+S->SizeV);
	SetP(&P[3],+0.5,-0.5,S->u+S->SizeU,S->v);
}
/*=================================================================*/
void TransformQuadCW(struct XYSTW_Vertex3D *P,float posx,float posy,float large,float high,float R)
{
register float x;
register float y;
register float tmp;
register float CosR;
register float SinR;
register LONG n;
float xmin,ymin,xmax,ymax;
struct XYSTW_Vertex3D *P2=P;

FUNC(TransformQuadCW)
	xmin=ymin=xmax=ymax=0.0;
	R= R / 360.0;
	R=R-((LONG)R);
	R=R*(2* 3.1416);
	CosR=  (float)cos(R);
	SinR=  (float)sin(R);

/* Rotate a normalized quad */
	NLOOP(4)
		{
		x=P->x;			/* to registers  */
		y=P->y;

		tmp	= (x *CosR - y*SinR);	/* R rotating on z axis */
		y	= (y *CosR + x*SinR);
		x	=  tmp;

		if(x<xmin) xmin=x;
		if(y<ymin) ymin=y;
		if(x>xmax) xmax=x;
		if(y>ymax) ymax=y;

		P->x = x;			/* to memory  */
		P->y = y;
		P++;
		}

/* scale quad to current size & move it to current position */
	CW.xsize=large/(xmax-xmin);
	CW.ysize=high/(ymax-ymin);
	CW.xmin=xmin;
	CW.ymin=ymin;
	NLOOP(4)
		{
		P2->x = posx+CW.xsize*(P2->x-xmin);	
		P2->y = posy+CW.ysize*(P2->y-ymin);	
		P2++;
		}
}
/*==========================================================================*/
void COMP3D_DrawTriangles(struct XYSTW_Vertex3D *P,ULONG Pnb,ULONG CompMode,struct BitMap  *srcbm)
{
ULONG TRInb=Pnb/3;
ULONG error,flags,n,x,y,high,large;
struct BitMap  *dstbm;

FUNC(COMP3D_DrawTriangles)
	x	=CW.dstR.x;
	y	=CW.dstR.y;
	large =CW.dstR.large;
	high  =CW.dstR.high;
	dstbm =CW.dstT.bm;
	srcbm =CW.srcT.bm;

	flags=COMPFLAG_HardwareOnly | COMPFLAG_SrcFilter|COMPFLAG_IgnoreDestAlpha;
	flags=COMPFLAG_HardwareOnly | COMPFLAG_SrcFilter;
	error = CompositeTags(CompMode, 
		srcbm,dstbm,
		COMPTAG_VertexArray, P, 
		COMPTAG_VertexFormat,COMPVF_STW0_Present,
	    	COMPTAG_NumTriangles,TRInb,
		COMPTAG_DestX,x,
		COMPTAG_DestY,y,
		COMPTAG_DestWidth ,large,
		COMPTAG_DestHeight,high,
		COMPTAG_Flags, flags ,
		TAG_DONE);
	
	if(error != COMPERR_Success)
			printf("CompositeTags error %d\n",error);

	CW.TooBig=(error != COMPERR_Success);
	if(CW.TooBig)
		{
		printf("Screen(%ldX%ld) or Window(%ldX%ld) is too big for OS4/CompositeTags() \n",CW.dstR.large,CW.dstR.high,CW.srcR.large,CW.srcR.high);
		CW.Closed=TRUE;
		}
	
FUNC(COMP3D_DrawTrianglesOK)
}
/*==========================================================================*/
void DrawSpriteCW(struct sprite3D *S)
{
#define COPYV(a,b)   { (a)->x=(b)->x; (a)->y=(b)->y; (a)->s=(b)->s; (a)->t=(b)->t; (a)->w=(b)->w;  }
struct XYSTW_Vertex3D *QUAD;
struct XYSTW_Vertex3D TRI[2*3];
ULONG n;

FUNC(DrawSpriteCW)
	QUAD=S->Quad;

	COPYV( &TRI[0] , &QUAD[0] );
	COPYV( &TRI[1] , &QUAD[1] );
	COPYV( &TRI[2] , &QUAD[2] );
	COPYV( &TRI[3] , &QUAD[0] );
	COPYV( &TRI[4] , &QUAD[2] );
	COPYV( &TRI[5] , &QUAD[3] );

	COMP3D_DrawTriangles(TRI,6,S->CompMode,S->T->bm);
}
/*=================================================================*/
void* FindSrcWindow()
{
struct Window  *win;
ULONG Wnum;

FUNC(FindSrcWindow)
VAR(Wnum)
	win=CW.srcscreen->FirstWindow;
	Wnum=0;
	while(win)
	{
		if (Wnum==CW.Wnum)
			{
			REM(win found)
			return(win);
			}
		Wnum++;
		win=win->NextWindow;
	}
	return(NULL);
}
/*=================================================================*/
BOOL StartCW(UBYTE *name,UWORD large,UWORD high,float RotZ,ULONG skipframes,BOOL CopyInput)
{						/* open a window & a rastport ("back buffer") */
UWORD ScreenLarge,ScreenHigh;
ULONG ModeID,ScreenBits,modeid;
ULONG Flags =WFLG_ACTIVATE | WFLG_REPORTMOUSE | WFLG_RMBTRAP | WFLG_SIMPLE_REFRESH | WFLG_GIMMEZEROZERO | WFLG_DEPTHGADGET | WFLG_SIZEGADGET;
ULONG IDCMP_ALL=IDCMP_SIZEVERIFY | IDCMP_NEWSIZE | IDCMP_REFRESHWINDOW | IDCMP_MOUSEBUTTONS | IDCMP_MOUSEMOVE | IDCMP_GADGETDOWN | IDCMP_GADGETUP | IDCMP_REQSET | IDCMP_MENUPICK | IDCMP_CLOSEWINDOW | IDCMP_RAWKEY | IDCMP_REQVERIFY | IDCMP_REQCLEAR | IDCMP_MENUVERIFY | IDCMP_NEWPREFS | IDCMP_DISKINSERTED | IDCMP_DISKREMOVED | IDCMP_WBENCHMESSAGE | IDCMP_ACTIVEWINDOW | IDCMP_INACTIVEWINDOW | IDCMP_DELTAMOVE | IDCMP_VANILLAKEY | IDCMP_INTUITICKS | IDCMP_IDCMPUPDATE | IDCMP_MENUHELP | IDCMP_CHANGEWINDOW | IDCMP_GADGETHELP;
ULONG IDCMPs=IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY | IDCMP_RAWKEY | IDCMP_MOUSEMOVE | IDCMP_MOUSEBUTTONS |IDCMP_REFRESHWINDOW | IDCMP_SIZEVERIFY | IDCMP_NEWSIZE | IDCMP_GADGETDOWN | IDCMP_GADGETUP ;

FUNC(StartCW)
	MYCLR(CW)
	strcpy(CW.ProgName,name);
	CW.large			=large;
	CW.high			=high;
	CW.srcscreen		=NULL;
	CW.srcwindow	=NULL;
	CW.dstscreen		=NULL;
	CW.dstwindow	=NULL;
	CW.FramesDone	=0;
	CW.Closed		=FALSE;
	CW.WinTitle[0]		=0;
	CW.RotZ			=RotZ;
	CW.skipframes	=skipframes;
	CW.Wnum		=0;
	CW.CopyInput	=CopyInput;
	

	if(OpenAmigaLibraries()==FALSE)
		{printf("ERROR: Cant open a library \n");return FALSE;}

	if(IntuitionBase)
		CW.srcwindow=IntuitionBase->ActiveWindow;	/* default: use active window */
	if(CW.srcwindow==NULL)
		CW.srcwindow=FindSrcWindow();
	CW.srcscreen=CW.srcwindow->WScreen;

	printf("Source window is '%s' \n",CW.srcwindow->Title);

	CW.dstscreen 	=LockPubScreen("Workbench") ;
	ScreenLarge	=CW.dstscreen->Width;
 	ScreenHigh	=CW.dstscreen->Height;
	UnlockPubScreen(NULL, CW.dstscreen);

	CW.dstwindow = 		OpenWindowTags(NULL,
	WA_Activate,			TRUE,
	WA_InnerWidth,		CW.large,
	WA_InnerHeight,		CW.high,
	WA_MinWidth,		32,
 	WA_MinHeight,		32,
 	WA_MaxWidth,		ScreenLarge,
 	WA_MaxHeight,		ScreenHigh,
	WA_Left,				(ScreenLarge -  CW.large)/2,
	WA_Top,				(ScreenHigh  -  CW.high )/2,
	WA_Title,				(ULONG)CW.ProgName,
	WA_DragBar,			TRUE,
	WA_CloseGadget,		TRUE,
	WA_GimmeZeroZero,	TRUE,
	WA_SizeGadget, 		TRUE,
	WA_Backdrop,		FALSE,
	WA_Borderless,		FALSE,
	WA_IDCMP,			IDCMPs,
	WA_Flags,			Flags,
	TAG_DONE);


	if (CW.dstwindow==NULL)
		{printf("ERROR: Cant open dest window\n");return FALSE;}

/* Texture1 is source window */
	CW.srcT.bm=CW.srcwindow->RPort->BitMap;
	CW.srcT.large=CW.srcscreen->Width; 
	CW.srcT.high =CW.srcscreen->Height; 
	CW.srcT.pt=NULL;

/* Texture2 is dest window */
	CW.dstT.bm=CW.dstwindow->RPort->BitMap;
	CW.dstT.large=CW.dstscreen->Width; 
	CW.dstT.high =CW.dstscreen->Height; 
	CW.dstT.pt=NULL;

	return(TRUE);
}
/*=================================================================*/
void CloseCW(void)
{
	if(CW.dstwindow)			CloseWindow(CW.dstwindow);
}
/*=================================================================*/
void NewDisplayCW(void)
{
struct rect3D *R;
struct Window  *win;
UBYTE winname[20+1];
ULONG n;

FUNC(NewDisplayCW)
	if(CW.srcwindow==CW.dstwindow)
		return;

/* source window to source rectangle */
	win=CW.srcwindow;
	R=&CW.srcR;

	R->x		=win->LeftEdge	+ win->BorderLeft ;
	R->y		=win->TopEdge	+ win->BorderTop  ;
	R->large	=win->Width		- win->BorderLeft - win->BorderRight ;
	R->high	=win->Height 	- win->BorderTop  - win->BorderBottom;

/* define sprite as the source rectangle */ 
	SetSpriteCW(&CW.S,R->large,R->high,&CW.srcT,R->x,R->y,R->large,R->high,COMPOSITE_Src);

/* dest window to dest rectangle */
	win=CW.dstwindow;
	R=&CW.dstR;

	R->x		=win->LeftEdge	+ win->BorderLeft ;
	R->y		=win->TopEdge	+ win->BorderTop  ;
	R->large	=win->Width		- win->BorderLeft - win->BorderRight ;
	R->high	=win->Height 	- win->BorderTop  - win->BorderBottom;

/* transform sprite to fit in dest rectangle */ 
	TransformQuadCW(CW.S.Quad,R->x,R->y,R->large,R->high,CW.RotZ);

/* if window background is visible clean it */ 
	WaitBlit();
	if(CW.RotZ!=0.0)
	if(CW.RotZ!=90.0)
	if(CW.RotZ!=180.0)
	if(CW.RotZ!=360.0)
		p96RectFill(CW.dstwindow->RPort,0,0,CW.dstT.large,CW.dstT.high,0);

/* draw  */ 
	WaitBlit();	 
	DrawSpriteCW(&CW.S);

/* get src window title */ 
	if(CW.srcwindow->Title==NULL)
	{
		strcpy(winname,"Screen");
	}
	else
	{
	if(strlen(CW.srcwindow->Title)>20)
	{
	NLOOP(20)
		winname[n]=CW.srcwindow->Title[n];
	winname[20]=0;
	}
	else
	{
	strcpy(winname,CW.srcwindow->Title);
	}
	}
/* display infos as dst window title */ 	
	sprintf(CW.WinTitle,"%s Win%ld:'%s'%ld at %ld %ld (%ld X %ld) R:%2.0f° Skip:1/%ld",CW.ProgName,CW.Wnum,winname,CW.CopyInput,(LONG)CW.srcR.x,(LONG)CW.srcR.y,(LONG)CW.srcR.large,(LONG)CW.srcR.high,CW.RotZ,CW.skipframes);
	SetWindowTitles(CW.dstwindow, CW.WinTitle, NULL);

	CW.FramesDone++;
}
/*==================================================================*/
void WindowEventsCW(void)
{	/* manage the window  */
struct IntuiMessage *imsg;
struct IntuiMessage *imsg2;
float x,y,tmp;
float R,CosR,SinR;


	while( (imsg = (struct IntuiMessage *)GetMsg(CW.dstwindow->UserPort)))
	{
	if (imsg == NULL) break;


	switch (imsg->Class)
	{
	case IDCMP_CLOSEWINDOW:
	CW.Closed=TRUE;
	break;

	case IDCMP_VANILLAKEY:
	if(imsg->Code=='!')
	{ CW.CopyInput=!CW.CopyInput; }

	if(imsg->Code=='R')
	{ CW.RotZ=CW.RotZ+15.0; if(CW.RotZ>360.0) CW.RotZ=  0.0; }
	if(imsg->Code=='r')
	{ CW.RotZ=CW.RotZ-15.0;	if(CW.RotZ<  0.0) CW.RotZ=360.0; }
	if(imsg->Code=='F')
	{ CW.skipframes++; if(CW.skipframes>100) CW.skipframes=0; }
	if(imsg->Code=='f')
	{ CW.skipframes--; if(CW.skipframes<0) CW.skipframes=100; }
	if(imsg->Code=='W')
	{
	CW.Wnum++;
	CW.srcwindow=FindSrcWindow();
	if(CW.srcwindow==NULL)
	{
	CW.Wnum=0;
	CW.srcwindow=FindSrcWindow();
	}
	}
	if(imsg->Code=='w')
	{
	CW.Wnum--;
	CW.srcwindow=FindSrcWindow();
	if(CW.srcwindow==NULL)
	{
	CW.Wnum=0;
	CW.srcwindow=FindSrcWindow();
	}
	}
	break;

	default:
	break;
	}
	if(imsg)
	{


	if(CW.CopyInput)		/* copy the msg for src window */ 
	{
REM(copyinput=================)
/* get mouse pos in dst window */
VAR(imsg->MouseX)
VAR(imsg->MouseY)
	x= imsg->MouseX	- CW.dstwindow->BorderLeft ;
	y= imsg->MouseY	- CW.dstwindow->BorderTop  ;
VARF(x) VARF(y)
/* normalise to -0.5 +0.5 */
CW.xmin=CW.ymin=0.0;
	x= x/CW.xsize  +CW.xmin - 0.5;
	y= y/CW.ysize  +CW.ymin - 0.5;
VARF(x) VARF(y)
/* rotate mouse as src window */
	R=360.0-CW.RotZ;	/* invert rotation */
	R=R / 360.0*(2* 3.1416);
	CosR=  (float)cos(R);
	SinR=  (float)sin(R);
	tmp	= (x *CosR - y*SinR);	/* R rotating on z axis */
	y	= (y *CosR + x*SinR);
	x	=  tmp;
VARF(x) VARF(y)
/* resize mouse pos for src window */
	x=(x+0.5)*CW.srcR.large + CW.srcwindow->BorderLeft ;
	y=(y+0.5)*CW.srcR.high  + CW.srcwindow->BorderTop  ;
VARF(x) VARF(y)
	WritePixel(CW.srcwindow->RPort,(WORD)x,(WORD)y);

/* transfer imsg to src window */ 
	imsg->IDCMPWindow=CW.srcwindow;
	imsg->MouseX 	=x;
	imsg->MouseY 	=y; 

	if(imsg->Class!=IDCMP_CLOSEWINDOW)	/* so will not close src window */
		PutMsg(CW.srcwindow->UserPort,(struct Message *)imsg);
	}
	else
	{
		ReplyMsg((struct Message *)imsg);
	}

	imsg = NULL;
	}
	}

}
/*==================================================================*/
int main(int argc, char *argv[])
{
ULONG w=640;
ULONG h=480;
ULONG rot=0;
ULONG fra=10;
ULONG inp=0;
ULONG cop=0;

	printf("Now click the window you want to clone within 10 secondes...\n");
	Delay(10*25);

	if (argc >= 3)
		{
		sscanf(argv[1],"%d",&w);
		sscanf(argv[2],"%d",&h);
		}

	if (argc >= 4)
		sscanf(argv[3],"%d",&rot);
	if (argc >= 5)
		sscanf(argv[4],"%d",&fra);
	if (argc >= 6)
		sscanf(argv[5],"%d",&inp);
	if (argc >= 7)
		sscanf(argv[6],"%d",&cop);

	if(!StartCW("CloneWindow - A.Thellier",w,h,(float)rot,fra,cop))
		goto panic;

	CW.CopyInput=inp;
	while(!CW.Closed)					/* Is window Closed ? */
	{
		Delay(CW.skipframes);
		WindowEventsCW();				
		NewDisplayCW();
	}

panic:
	CloseCW();
	return 0;
}
/*=================================================================*/

