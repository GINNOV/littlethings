/* Author: Alain Thellier - Paris - 2010 . See ReadMe for more infos								*/
/* v3.0 Sept  2011: Draw FPS correctly on Aros too. Now works with Wazp3D using "hard overlay"				*/
/* v4.0 March 2012: Try to use W3D_InterleavedArray() on OS4 									*/
/* v5.0 Sept  2012: Use W3D_DrawElement() on OS4 ==> faster										*/
/* v6.0 Feb   2016: Use Nova on OS4															*/

#define DISPLAYW 640
#define DISPLAYH 480
#define COWSIZE 90.0

#ifdef __amigaos4__
#define __USE_INLINE__
#define __USE_BASETYPE__
#define __USE_OLD_TIMEVAL__
#endif

#ifdef __amigaos4__
#define OS4
#else
#define OS3
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
#include <proto/cybergraphics.h>

#ifdef STATWAZP3D
#include "Warp3D_protos.h"
#else
#include <proto/Warp3D.h>
#endif

#if !defined(PIXFMT_LUT8)
#include "cybergraphics.h"
#endif

/*=================================================================*/
#ifdef OS4
#include "kazmath/vec2.c"				/* TODO: enlever ça et faire soi même ses fonctions de matrices */
#include "kazmath/vec3.c"
#include "kazmath/vec4.c"
#include "kazmath/mat3.c"
#include "kazmath/mat4.c"
#include "kazmath/quaternion.c"
#include "kazmath/plane.c"
#include "kazmath/utility.c"
/*=================================================================*/
/* Supported pixel formats (V54) */
enum enPixelFormat
{
    PIXF_NONE      = 0,
    PIXF_CLUT      = 1,
    PIXF_R8G8B8    = 2,
    PIXF_B8G8R8    = 3,
    PIXF_R5G6B5PC  = 4,
    PIXF_R5G5B5PC  = 5,
    PIXF_A8R8G8B8  = 6,
    PIXF_A8B8G8R8  = 7,
    PIXF_R8G8B8A8  = 8,
    PIXF_B8G8R8A8  = 9,
    PIXF_R5G6B5    = 10,
    PIXF_R5G5B5    = 11,
    PIXF_B5G6R5PC  = 12,
    PIXF_B5G5R5PC  = 13,
    PIXF_YUV422CGX = 14,
    PIXF_YUV411    = 15,
    PIXF_YUV422PA  = 16,
    PIXF_YUV422    = 17,
    PIXF_YUV422PC  = 18,
    PIXF_YUV420P   = 19,
    PIXF_YUV410P   = 20,
    PIXF_ALPHA8    = 21
};
#include <Warp3DNova/Warp3DNova.h>
#include <proto/Warp3DNova.h>
/*==================================================================*/
typedef struct NovaPoint {
	kmVec3 position;		// The vertex's position
	kmVec3 normal;		// The vertex's normal
	kmVec2 texCoord;		// The vertex's texture coordinate
} NOVAPOINT;
/*==================================================================*/
typedef struct _VertexShaderData {
	kmMat4 mvpMatrix;		// ModelViewProjectionMatrix
	kmMat4 normalMatrix;	// NormalMatrix
	kmVec4 lightPos;		// LightSourcePosition
} VertexShaderData;
#endif
/*==================================================================*/
#include "Cow3D_Object.h"				/* 3d object*/
#ifdef OS4
UBYTE  progname[]={"CoW3D V6/OS4: type 'b' for speed up"};
#else
UBYTE  progname[]={"CoW3D V6/OS3: type 'b' for speed up"};
#endif
/*==================================================================*/
#define LIBCLOSE(libbase)	 if(libbase!=NULL)	{CloseLibrary( (struct Library  *)libbase );   libbase=NULL; }
#define LIBOPEN(libbase,name,version)  libbase	=(void*)OpenLibrary(#name,version);				if(libbase==NULL) 	return(FALSE);
#ifdef OS4
#define LIBOPEN4(interface,libbase)    interface=(void*)GetInterface((struct Library *)libbase, "main", 1, NULL);	if(interface==NULL)	return(FALSE);
#define LIBCLOSE4(interface) if(interface!=NULL)	{DropInterface((struct Interface*)interface );interface=NULL;}
#else
#define LIBOPEN4(interface,libbase)    ;
#define LIBCLOSE4(interface) ;	
#endif
/*==================================================================*/
#define LL            {if(debug) printf("Line:%ld\n",__LINE__);}
#define VAR(var)   if(debug) {printf(" " #var "=" ); printf("%ld\n",  ((ULONG)var)  );}
#define   VARS(var)   if(debug) {printf(" " #var "=<%s>;\n",var); }
#define ZZ  if(debug) printf("ZZ stepping ..\n");
#define REM(message)   if(debug) printf(#message"\n");
#define MYCLR(x) 	memset(&x,0,sizeof(x));
#define NLOOP(nbre) for(n=0;n<nbre;n++)
#define MLOOP(nbre) for(m=0;m<nbre;m++)
#define SPEED 5  /* object speed */
#define FRAMESCOUNT (360/SPEED)		/* frames count to rotate fully */
#define MAXPRIM (3*1000)			/* Wazp3D cant draw bigger primitives  so split the object in several drawing*/
#include "patches_for_Warp3D.h"
BOOL debug=FALSE;
/*==================================================================*/
typedef struct _WarpPoint{
	float x,y,z;
	float color[4];
	float u,v,w;
} WARPPOINT;
/*==================================================================*/
struct object3D{
	APTR  P;				/* original points */
	APTR  P2;				/* points rotated/transformed to screen */
	ULONG *PI;					/* points' indices that define the triangles */
	ULONG Pnb;					/* points counts(french "points nombre" */
	ULONG PInb;					/* PI counts(french "PI nombre" */
	UBYTE *picture;				/* texture data */
	W3D_Texture  *wtexture;		/* warp3d texture */
#ifdef OS4
/* for Nova */	
	W3DN_Texture *ntexture;		/* nova texture */
	W3DN_VertexBuffer *vbo;	
	ULONG Vid,Nid,UVid,Cid,PIid;
	ULONG Vattrib,Nattrib,UVattrib,Cattrib,PIattrib;
	UBYTE Vname[40];
	UBYTE Nname[40];
	UBYTE UVname[40];
	UBYTE Cname[40];
#endif	
};
/*==================================================================*/
struct GfxBase*			GfxBase				=NULL;
struct IntuitionBase*	IntuitionBase		=NULL;
struct Library*			Warp3DBase			=NULL;
struct Library*			CyberGfxBase		=NULL;
struct Library*			Warp3DNovaBase		=NULL;
/*==================================================================*/
#ifdef OS4
struct GraphicsIFace*			IGraphics		=NULL;
struct IntuitionIFace*			IIntuition		=NULL;
struct CyberGfxIFace*			ICyberGfx		=NULL;
struct Warp3DIFace*				IWarp3D			=NULL;
struct Warp3DNovaIFace*			IW3DNova		=NULL;
#endif
/*==================================================================*/
struct Cow3D{
struct Screen  *screen;
struct Window  *window;
struct BitMap  *bufferbm;
W3D_Context *wcontext;
W3D_Scissor scissor;
struct RastPort bufferrastport;
ULONG result,NumTMU,ModeID,flags,ScreenBits;
BOOL  closed;
BOOL greyreadz;
BOOL colored;
BOOL IsBlended;
BOOL showfps;
BOOL Zbuffer;
BOOL zupdate;
BOOL HideFace;
BOOL rotate;
BOOL DrawCow;
BOOL DrawCosmos;
UBYTE drawmode;
BOOL bigpoint;
BOOL UseLineTest;
BOOL UseZTest;
BOOL IsBuffered;
ULONG Zmode;
BOOL optimroty;
float ViewMatrix[16];
float RotY;
ULONG FramesCounted;
ULONG FPS;
UBYTE FpsText[200];
UBYTE zname[5];
struct object3D *CowObj;
struct object3D *CosmosObj;
struct object3D *QuadObj;
WARPPOINT  *BufferedP;			/* store all transformed points */
UBYTE Pdone[FRAMESCOUNT];
ULONG SrcFunc,DstFunc,SrcDstFunc;
ULONG TexEnvMode;
W3D_Color EnvColor;
ULONG DisplayW,DisplayH;
ULONG ScreenW,ScreenH;

BOOL FrameLimit;
ULONG Time, OldTime;

float opaqueBlack[4];
double clearDepth;

BOOL GotNova,UseNova,Use2D;
#ifdef OS4
VertexShaderData View;

kmVec3 initCamPos;			/* The initial camera position */

kmMat4 viewMatrix;			// The camera's view matrix
kmMat4 modelMatrix;			// The object's view matrix
kmMat4 projectionMatrix;	// The projection matrix 

W3DN_Context *ncontext;
W3DN_Gpu *gpu;

W3DN_TextureSampler *texSampler;
W3DN_DataBuffer *dbo;
W3DN_ErrorCode error;
BOOL UsePespective;
BOOL alwaysShowLog;
const char *shaderLog;
#endif
};
struct Cow3D C;
/*==================================================================*/
#ifdef OS4
#include "Cow3D_Nova.h"
#else
inline BOOL CheckNova(void)	{return(TRUE);}
inline BOOL DoTextureNova(void *O,APTR pixels,UWORD texw,UWORD texh,UWORD bits)	{return(TRUE);}
inline BOOL DoViewNova(void)	{return(TRUE);}
inline BOOL DrawEleNova(void* vbo,ULONG PIid,ULONG PInb,ULONG primitive,void *wtexture)	{return(TRUE);}
inline BOOL DrawObjectNova(void *O)	{return(TRUE);}
inline BOOL DrawPoiNova(void* vbo,ULONG PIid,ULONG PInb,void *wtexture)	{return(TRUE);}
inline BOOL ObjectToVboNova(void *O)	{return(TRUE);}
inline BOOL OpenDisplayNova(void)	{return(TRUE);}
inline ULONG BmToNovaPixF(ULONG BmFmt)	{return(0);}
inline ULONG SetBlendModeNova(void) {return(0);}
inline void CloseNova(void)	{return;}
inline void PixfToName(UBYTE *name, ULONG PixFmt)	{return;}
inline void QueryBmNova(ULONG BmFmt)	{return;}
inline void QueryDriverNova(ULONG query)	{return;}
inline void QueryStateNova(ULONG state)	{return;}
inline void QueryTexNova(ULONG PixFmt,ULONG EleFmt)	{return;}
inline void ReadIncludedObjectNova(void *O,float *V,ULONG *i,float size)	{return;}
inline void SetStatesNova(void *wtexture)	{return;}
inline void SwitchDisplayNova(void)	{return;}
#endif
/*==================================================================*/
void SetDefault()
{

/* all other values are set to zero */	
	MYCLR(C);

	C.DisplayW=DISPLAYW;
	C.DisplayH=DISPLAYH;
	C.colored=TRUE;
	C.showfps=TRUE;
	C.Zbuffer=TRUE;
	C.zupdate=TRUE;
	C.HideFace=TRUE;
	C.rotate=TRUE;
	C.DrawCow=TRUE;
	C.DrawCosmos=TRUE;
	C.drawmode='e';
	C.Zmode=W3D_Z_LESS;
	C.optimroty=TRUE;
	C.TexEnvMode=1;
	

	C.opaqueBlack[0] = 0.0;
	C.opaqueBlack[1] = 0.0;
	C.opaqueBlack[2] = 0.3;
	C.opaqueBlack[3] = 1.0;
	C.clearDepth = 1.0;
		
}
/*==================================================================*/
void SetTexBlendWarp3D(struct object3D *O);
ULONG SetBlendMode();
void SetMrot(float *M,float R ,UBYTE a,UBYTE b,UBYTE c,UBYTE d);
void SetMrx(float *M,float x);
void SetMry(float *M,float y);
void SetMrz(float *M,float z);
void TransformP(register float *M,WARPPOINT  *P,LONG Pnb);
void YrotateP(register float *M,WARPPOINT  *P,LONG Pnb);
void ProjectP(WARPPOINT  *P,LONG Pnb);
/*==================================================================*/
BOOL DoViewWarp3D(void)
{
ULONG frame,n;
BOOL framebuffered;		
WARPPOINT *P;
	
		framebuffered=FALSE;

		if(C.IsBuffered)
		if(C.BufferedP==NULL)
			{
			printf("Will allocate buffer %ld bytes\n",FRAMESCOUNT*C.CowObj->Pnb*sizeof(WARPPOINT));
			C.BufferedP = malloc(FRAMESCOUNT*C.CowObj->Pnb*sizeof(WARPPOINT));
			if(!C.BufferedP) printf("no memory for buffer!\n");
			NLOOP(FRAMESCOUNT) C.Pdone[n]=FALSE;
			}


		if(C.rotate)
		{
		frame=C.RotY/SPEED;

		if(C.IsBuffered)
		if(C.BufferedP!=NULL)
		if(C.Pdone[frame])		/* use a saved frame ? */
			{
			C.CowObj->P2		=&C.BufferedP[C.CowObj->Pnb*frame];	/* P2=IsBuffered points */
			framebuffered=TRUE;
			}

		if(!framebuffered)		/* then transform/rotate/project frame  */
			{
			P=C.CowObj->P;
			C.CowObj->P2		=&P[C.CowObj->Pnb];		/* use default P2 */
			memcpy(C.CowObj->P2,C.CowObj->P,C.CowObj->Pnb*sizeof(WARPPOINT));	/* copy the object's points to P2*/
			SetMry(C.ViewMatrix,C.RotY);	/* do a y rotation matrix */
			if(C.optimroty)
				YrotateP(C.ViewMatrix,C.CowObj->P2,C.CowObj->Pnb);		/* only y-rotate the object's points in P2*/
			else
				TransformP(C.ViewMatrix,C.CowObj->P2,C.CowObj->Pnb);		/* fully transform the object's points in P2*/
			ProjectP(C.CowObj->P2,C.CowObj->Pnb);/* project points to screen */
			}

		if(C.IsBuffered)
		if(C.BufferedP!=NULL)
		if(!C.Pdone[frame])		/* then save this frame */
			{
			memcpy(&C.BufferedP[C.CowObj->Pnb*frame],C.CowObj->P2,C.CowObj->Pnb*sizeof(WARPPOINT));	/* save the transformed points to buffer */
			C.Pdone[frame]=TRUE;
			}

		}
	
	return(TRUE);
}
/*==================================================================*/
void DrawEleWarp3D(WARPPOINT  *P,ULONG *PI,ULONG PInb,ULONG primitive,W3D_Texture *wtexture)
{
void *VertexPointer;
void *TexCoordPointer;
void *ColorPointer;
UWORD stride=sizeof(WARPPOINT);
UWORD off_v,off_w;

	W3D_Flush(C.wcontext);
	W3D_WaitIdle(C.wcontext);		/* dont modify points or pointers during drawing */
	VertexPointer	=(void *)&(P->x);
		
/* Warp3D V5 for Os4 ppc only implement W3D_InterleavedArray() not W3D_Vertex/TexCoord/ColorPointer() */
#ifdef OS4
	#define ARRAYFORMAT (W3D_VFORMAT_COLOR|W3D_VFORMAT_TCOORD_0)
	W3D_InterleavedArray(C.wcontext,VertexPointer,stride,ARRAYFORMAT,W3D_TEXCOORD_NORMALIZED);
#else
	TexCoordPointer	=(void *)&(P->u);
	ColorPointer	=(void *)&(P->color);
	off_v=(UWORD)( (ULONG)&(P->v) - (ULONG)&(P->u));
	off_w=(UWORD)( (ULONG)&(P->w) - (ULONG)&(P->u));
	C.result=W3D_VertexPointer(C.wcontext,VertexPointer,stride,W3D_VERTEX_F_F_F, 0);
	C.result=W3D_TexCoordPointer(C.wcontext,TexCoordPointer,stride,0, off_v, off_w,W3D_TEXCOORD_NORMALIZED);
	C.result=W3D_ColorPointer(C.wcontext,ColorPointer,stride,W3D_COLOR_FLOAT ,W3D_CMODE_RGBA,0);
#endif

	if( W3D_SUCCESS != W3D_LockHardware(C.wcontext) ) 
			{REM(cant lock!) ; return;}
	W3D_DrawElements(C.wcontext,primitive,W3D_INDEX_ULONG,PInb,PI);	/* draw with warp3d */

	W3D_UnLockHardware(C.wcontext);
	W3D_Flush(C.wcontext);
}
/*=================================================================*/
void SetP(WARPPOINT  *P,float x, float y, float z,float w,float u, float v,UBYTE r,UBYTE g,UBYTE b,UBYTE a)
{
	if(P==NULL) return;

	P->x=x; 
	P->y=y;
	P->z=z;
	P->w=w;
	P->u=u;
	P->v=v;
	P->color[0]=(float)r/255.0;
	P->color[1]=(float)g/255.0;
	P->color[2]=(float)b/255.0;
	P->color[3]=(float)a/255.0;

}
/*==================================================================*/
void PtoV(WARPPOINT  *P,W3D_Vertex *V)
{
	if(P==NULL) return;
	if(V==NULL) return;
	
	V->x=P->x;
	V->y=P->y;
	V->z=P->z;
	V->w=P->w;
	V->u=P->u*TEXSIZE;
	V->v=P->v*TEXSIZE;
	V->color.r=P->color[0];
	V->color.g=P->color[1];
	V->color.b=P->color[2];
	V->color.a=P->color[3];
}
/*==================================================================*/
void SetV(W3D_Vertex *V,float x, float y, float z,float w,float u, float v,float r,float g,float b,float a)
{
	if(V==NULL) return;

	V->x=x;
	V->y=y;
	V->z=z;
	V->w=w;
	V->u=u*TEXSIZE;
	V->v=v*TEXSIZE;
	V->color.r=r;
	V->color.g=g;
	V->color.b=b;
	V->color.a=a;
}
/*==================================================================*/
void PrintV(W3D_Vertex  *V)
{
	if(V!=NULL) printf("V: XYZ %2.2f %2.2f %2.2f   UV %2.2f  %2.2f  WT %2.2f  %2.2f \n",V->x,V->y,V->z,V->u,V->v,V->w,V->tex3d);
}
/*==================================================================*/
void DrawTriWarp3D(WARPPOINT  *P,ULONG *PI,ULONG PInb,W3D_Texture *wtexture)
{
W3D_Triangle tri;
register ULONG n;


	MYCLR(tri);
	tri.tex=wtexture;
	if( W3D_SUCCESS != W3D_LockHardware(C.wcontext) ) 
			{REM(cant lock!) ; return;}

	NLOOP(PInb/3)
	{
	PtoV( &P[PI[n*3+0]], &tri.v1 );
	PtoV( &P[PI[n*3+1]], &tri.v2 );
	PtoV( &P[PI[n*3+2]], &tri.v3 );
	W3D_DrawTriangle(C.wcontext, &tri);
	}

	W3D_UnLockHardware(C.wcontext);

}
/*==================================================================*/
void DrawPoiWarp3D(WARPPOINT  *P,ULONG *PI,ULONG PInb,W3D_Texture *wtexture)
{
W3D_Point point;
register ULONG n;

	MYCLR(point);
	if( W3D_SUCCESS != W3D_LockHardware(C.wcontext) ) return;

	point.tex=wtexture;
	point.pointsize=1.0;
	if(C.bigpoint) point.pointsize=8.0;
	NLOOP(PInb)
	{
	PtoV( &P[PI[n]], &point.v1 );
 	PatchW3D_DrawPoint(C.wcontext,&point);
	}

	W3D_UnLockHardware(C.wcontext);
}
/*==================================================================*/
void DrawLinWarp3D(WARPPOINT  *P,ULONG *PI,ULONG PInb,W3D_Texture *wtexture)
{
W3D_Vertex v[3];
W3D_Lines lines;
register ULONG n;

	MYCLR(lines);
	if( W3D_SUCCESS != W3D_LockHardware(C.wcontext) ) return;

	lines.v=v;
	lines.vertexcount=3;
	lines.tex=wtexture;
	lines.linewidth=1.0;
	if(C.bigpoint) lines.linewidth=4.0;
	NLOOP(PInb/3)
	{
	PtoV( &P[PI[n*3+0]], &v[0] );
	PtoV( &P[PI[n*3+1]], &v[1] );
	PtoV( &P[PI[n*3+2]], &v[2] );
 	PatchW3D_DrawLineLoop(C.wcontext,&lines);
	}

	W3D_UnLockHardware(C.wcontext);
}
/*==================================================================*/
void DrawObjectWarp3D(struct object3D *O)
{
ULONG n,nb,rest;

	if(C.drawmode=='t')
		{DrawTriWarp3D(O->P2,O->PI,O->PInb,O->wtexture);return;}
	if(C.drawmode=='p')
		{DrawPoiWarp3D(O->P2,O->PI,O->PInb,O->wtexture);return;}
	if(C.drawmode=='l')
		{DrawLinWarp3D(O->P2,O->PI,O->PInb,O->wtexture);return;}
	if(C.drawmode=='e')
		{
		nb  =O->PInb  /  MAXPRIM;
		rest=O->PInb % MAXPRIM;
		NLOOP(nb)
			DrawEleWarp3D(O->P2,&O->PI[MAXPRIM*n],MAXPRIM,W3D_PRIMITIVE_TRIANGLES,O->wtexture);
		DrawEleWarp3D(O->P2,&O->PI[MAXPRIM*nb],rest,W3D_PRIMITIVE_TRIANGLES,O->wtexture);
		}
}
/*==================================================================*/
void DrawObject(struct object3D *O)
{
REM(DrawObject)
	if(C.UseNova)
		DrawObjectNova(O);
	else	
		DrawObjectWarp3D(O);
}	
/*==================================================================*/
void SetQuad(struct object3D *Quad,float x,float y,float z,float large,float high,UBYTE r,UBYTE g,UBYTE b,UBYTE a)
{
WARPPOINT *P2;

	Quad->PI[0]=0; /* do the quad as 2 triangles */
	Quad->PI[1]=1;
	Quad->PI[2]=2;
	Quad->PI[3]=0;
	Quad->PI[4]=2;
	Quad->PI[5]=3;

	P2=Quad->P2;
	SetP(&P2[0],x,y+high,z,1.0/z,0.0,1.0,r,g,b,a);
	SetP(&P2[1],x+large,y+high,z,1.0/z,1.0,1.0,r,g,b,a);
	SetP(&P2[2],x+large,y,z,1.0/z,1.0,0.0,r,g,b,a);
	SetP(&P2[3],x,y,z,1.0/z,0.0,0.0,r,g,b,a);

}
/*==================================================================================*/
void MyDumpMem(UBYTE *pt,LONG nb)
{
LONG n;

NLOOP(nb/4)
	{
	printf("[%ld\t][%ld\t] %d\t%d\t%d\t%d\n",(ULONG)pt,4*n,pt[0],pt[1],pt[2],pt[3]);
	pt=&(pt[4]);
	}
}
/*==================================================================*/
void DrawPointLineTestsWarp3D(W3D_Texture *wtexture)
{
UBYTE r,g,b,a;
float x,y,z,w,u,v,u2,v2;
W3D_Line line;
W3D_Point point;

	MYCLR(point);
	MYCLR(line);
	if( W3D_SUCCESS != W3D_LockHardware(C.wcontext) ) return;

	r=255; g=0; b=0; a=255; /* use a simple red */
	u=v=0.0;
	u2=v2=0.9;
	point.tex=wtexture;


	x=400; y=20; z=0.1; w=1.0/z;
	point.pointsize=1;
	SetV(&point.v1,x,y,z,w,u,v,r,g,b,a);
	C.result=PatchW3D_DrawPoint(C.wcontext,&point);
	if(C.result!=W3D_SUCCESS)
		printf("Cant W3D_DrawPoint size=1\n");

	x=400; y=40; z=0.1; w=1.0/z;
	point.pointsize=5;
	SetV(&point.v1,x,y,z,w,u,v,r,g,b,a);
	C.result=PatchW3D_DrawPoint(C.wcontext,&point);
	if(C.result!=W3D_SUCCESS)
		printf("Cant W3D_DrawPoint size=5\n");

	r=0; g=255; b=0; a=255; /* use a simple green */
	line.tex=wtexture;
	line.st_enable=FALSE;
	line.st_pattern=0;
	line.st_factor=0;

	x=420; y=20; z=0.1; w=1.0/z;
	line.linewidth=1;
	SetV(&line.v1,x,y,z,w,u,v,r,g,b,a);
	SetV(&line.v2,x+100,y+20,z,w,u2,v2,r,g,b,a);
	C.result=PatchW3D_DrawLine(C.wcontext,&line);
	if(C.result!=W3D_SUCCESS)
		printf("Cant W3D_DrawLine width=1\n");

	x=420; y=40; z=0.1; w=1.0/z;
	line.linewidth=5;
	SetV(&line.v1,x,y,z,w,u,v,r,g,b,a);
	SetV(&line.v2,x+100,y+20,z,w,u2,v2,r,g,b,a);
	C.result=PatchW3D_DrawLine(C.wcontext,&line);
	if(C.result!=W3D_SUCCESS)
		printf("Cant W3D_DrawLine width=5\n");

	W3D_UnLockHardware(C.wcontext);
}
/*==================================================================*/
void DrawZtests(void)
{
float x,y,z;
float large,high;
ULONG n,m;
UBYTE rgba[4*7]={
0,128,128,255,
0,0,128,255,
128,0,128,255,
128,0,0,255,
128,128,0,255,
0,128,128,255,
255,128,64,255
};
float zvalues[7]={0.10,0.20,0.30,0.40,0.90,0.94,0.98};
double zspan[DISPLAYW];
UBYTE   mask[DISPLAYW];

/* 1: test writezspan */
	if(!w3dpatch)
	if( W3D_SUCCESS != W3D_LockHardware(C.wcontext) ) return;

	W3D_SetState(C.wcontext, W3D_TEXMAPPING,W3D_DISABLE);	/* color is enough to test the Zbuffer */
	W3D_SetState(C.wcontext, W3D_BLENDING,	W3D_ENABLE);	/* transparent to see the multipass effect*/

	NLOOP(C.DisplayW)
		{mask[n]=n&1; zspan[n]=0.90;}		/* mask 1 pixel,show 1 pixel...*/

	MLOOP(7)	/* for the 7 test-rectangles */
	NLOOP(50)	/* for the test-rectangle size */
		zspan[n*m]=zvalues[n];			/* fill zspan with same z values as the test-rectangles */

	PatchW3D_WriteZSpan(C.wcontext,0,40,C.DisplayW,zspan,mask); 	/* draw a zspan in the midle of the test-rectangles */

	NLOOP(C.DisplayW)
		{mask[n]=1; zspan[n]=0.50;}		/* never mask */
	NLOOP(100)
		zspan[n]=n*0.01;

	PatchW3D_WriteZSpan(C.wcontext,0,42,C.DisplayW,zspan,mask); 	/* draw a zspan in the midle of the test-rectangles */

	if(!w3dpatch)
	W3D_UnLockHardware(C.wcontext);

/* 2: test Zbuffer */
	if( W3D_SUCCESS != W3D_LockHardware(C.wcontext) ) return;

	large=50.0;
	high =40.0;
	NLOOP(7) /* draw 7 quads as various depth with various colors (z increase with n) */
	{
	x=n*large;
	y=n*2+20;
	z=zvalues[n];
	SetQuad(C.QuadObj,x,y,z,large+large/3.0,high-n*4,rgba[4*n],rgba[4*n+1],rgba[4*n+2],rgba[4*n+3]);
	DrawObject(C.QuadObj);
	}

	NLOOP(7) /* do a multi-pass : redraw  a grey transparent square with same depth (sticked to the face) */
	{
	x=n*large;
	y=20+high/2;
	z=zvalues[n];
	SetQuad(C.QuadObj,x+large/3.0,y,z,large/2,high-n*2,200,200,200,128);
	DrawObject(C.QuadObj);
	}

	W3D_UnLockHardware(C.wcontext);
}
/*=============================================================*/
void WriteLineRGBA(APTR RGBA,UWORD y)
{
	WritePixelArray(RGBA,0,0,C.DisplayW*32/8,&C.bufferrastport,0,y,C.DisplayW,1,RECTFMT_RGBA);
}
/*==================================================================*/
void DrawZvaluesWarp3D(void)
{
ULONG m,n;
UBYTE  RGBA[DISPLAYW][4];
double zspan[DISPLAYW];
UBYTE grey;
typedef const void * (*HOOKEDFUNCTION)(APTR RGBA,UWORD y);	/* doing this forbid the compiler to inline the function */
HOOKEDFUNCTION HookWriteLineRGBA;/* so calling WritePixelArray dont cause the "missing registers" bug */

	if(!w3dpatch)
	if( W3D_SUCCESS != W3D_LockHardware(C.wcontext) ) return;

	HookWriteLineRGBA=(HOOKEDFUNCTION)WriteLineRGBA;
	MLOOP(C.DisplayH)
	{
	C.result=PatchW3D_ReadZSpan(C.wcontext,0,m,C.DisplayW,zspan);

	NLOOP(C.DisplayW)
		{
		grey=zspan[n]*100.0;
		RGBA[n][0]=RGBA[n][1]=RGBA[n][2]=grey;
		if(C.result!=W3D_SUCCESS)		/* show not readed lines as red */
			{RGBA[n][0]=255; RGBA[n][1]=0; RGBA[n][2]=0;}
		RGBA[n][3]=255;
		}
	HookWriteLineRGBA(RGBA,m);    /* write a pixels line */
	}

	if(!w3dpatch)
	W3D_UnLockHardware(C.wcontext);
}
/*=================================================================*/
struct object3D *AddObject(ULONG Pnb,ULONG PInb)
{
struct object3D *O;
ULONG Osize,Psize,P2size,PIsize,size;
UBYTE *pt;

	PIsize=PInb*sizeof(ULONG);
	Osize =	sizeof(struct object3D);	
	Psize =Pnb *sizeof(WARPPOINT);
	P2size=Pnb *sizeof(WARPPOINT);

#ifdef OS4
	if(C.UseNova)
	{	
	Psize  =Pnb *sizeof(NOVAPOINT);
	P2size =0;
	}
#endif	
	
	size=Osize+PIsize+Psize+P2size; /* define all the object datas in a single malloc */
	pt=malloc(size);

	memset(pt,0,sizeof(struct object3D));
	
	O			=(struct object3D *)pt;		pt=pt+Osize;
	O->PI		=(ULONG *)pt;				pt=pt+PIsize;
	O->P		=(APTR)pt;					pt=pt+Psize;	
	O->P2		=(APTR)pt;					pt=pt+P2size;
	O->Pnb		=Pnb;
	O->PInb		=PInb;

	return(O);
}
/*=================================================================*/
void ReadIncludedObjectWarp3D(struct object3D *O,float *V,ULONG *i)
{
WARPPOINT *P    = NULL;
float x,y,z,w,u,v;
UBYTE r,g,b,a;
ULONG n,Psize;


	NLOOP(O->PInb)
		O->PI[n]=i[n];

	r=g=b=a=255;

	P=O->P;
	NLOOP(O->Pnb)
	{
	u=V[0]; v=V[1]; x=V[2]; y=V[3]; y=-y; z=V[4]; w=1.0/z;	/* beware z is negated so faces are reverted again in good order*/
	r=x*90+90; g=y*90+90; b=z*90+90;	/* just set various colors a stupid way*/
	SetP(P,x,y,z,w,u,v,r,g,b,a); 
	P++; 
	V=V+5;
	}

/* default: P2 are untransformed P */

	Psize=O->Pnb *sizeof(WARPPOINT);
	memcpy(O->P2,O->P,Psize);
}
/*=================================================================*/
void SetMrot(float *M,float R ,UBYTE a,UBYTE b,UBYTE c,UBYTE d)
{	/* define a rotation matrix */
float Pi =3.1416;
WORD n;
	if(M==NULL) return;
	M[0]=M[5]=M[10]=M[15]= 1.0;  	M[1]=M[2]=M[3]=M[4]=M[6]=M[7]=M[8]=M[9]=M[11]=M[12]=M[13]=M[14]=0.0;
	if(R==0.0) return;
	if(R>=360.0)
		{n=R/360.0;  R=R-n*360.0;}
	if(R<0.0)
		{n=1+R/360.0;R=R-n*360.0;}
	R= R / 180.0 * Pi;
	M[a]  =  (float)cos(R);
	M[b]  =  M[a];
	M[c]  =  (float)sin(R);
	M[d]  = -M[c];
}
/*=================================================================*/
void SetMrx(float *M,float x)		/* define X rotation matrix */
	{ SetMrot(M,x,5,10,6,9); }
/*=================================================================*/
void SetMry(float *M,float y)		/* define Y rotation matrix */
	{ SetMrot(M,y,10,0,8,2); }
/*=================================================================*/
void SetMrz(float *M,float z)		/* define Z rotation matrix */
	{ SetMrot(M,z,0,5,1,4); }
/*=================================================================*/
void TransformP(register float *M,WARPPOINT  *P,LONG Pnb)
{	/* transform points with a given matrix */
register float x;
register float y;
register float z;
register LONG n;

NLOOP(Pnb)
	{
	x=P->x;y=P->y;z=P->z;
	P->x= M[0]*x + M[4]*y+ M[8] *z+ M[12];
	P->y= M[1]*x + M[5]*y+ M[9] *z+ M[13];
	P->z= M[2]*x + M[6]*y+ M[10]*z+ M[14];
	P++;
	}
}
/*=================================================================*/
void YrotateP(register float *M,WARPPOINT  *P,LONG Pnb)
{	/* y rotate points with a given matrix : optimized TransformP() */
register float x;
register float z;
register float m0 =M[0];
register float m8 =M[8];
register float m2 =M[2];
register float m10=M[10];
register LONG n;

NLOOP(Pnb)
	{
	x=P->x;z=P->z;
	P->x= m0*x +  m8 *z;
	P->z= m2*x +  m10*z;
	P++;
	}
}
/*=================================================================*/
void ProjectP(WARPPOINT  *P,LONG Pnb)
{	/* project points to screen-coordinates */
register float x;
register float y;
register float z;
register float sizex;
register float sizey;
register float sizez;
register LONG n;

	sizex=C.DisplayW/2.0;
	sizey=C.DisplayH /2.0;
	sizez=0.8  /2.0;
NLOOP(Pnb)
	{
	x=P->x;y=P->y;z=P->z;
	P->x= x*sizex+sizex;
	P->y= y*sizey+sizey;
	P->z= z*sizez+sizez;
	P->w= 1.0/P->z;
	P++;
	}
}
/*=================================================================*/
BOOL LoadFile(UBYTE *buffer, UBYTE *name,ULONG bufferSize)
{	/* load a file in memory */
FILE *fp;
ULONG size=0;

	fp = fopen(name,"rb");
	if(fp == NULL)
		{printf("Cant open file ! <%s>\n",name); return(FALSE); }
	size = fread(buffer,bufferSize,1,fp);
	if(size ==0 )
		{printf("Cant read file ! <%s>\n",name); return(FALSE); }
	fclose(fp);
	return(TRUE);
}
/*=================================================================*/
BOOL DoTextureWarp3D(struct object3D *O,APTR pixels,UWORD texw,UWORD texh,UWORD bits)
{
ULONG mode;
	
	if(bits==32) mode=W3D_R8G8B8A8; else mode=W3D_R8G8B8;
	O->wtexture=W3D_AllocTexObjTags(C.wcontext,&C.result,W3D_ATO_IMAGE,(ULONG)O->picture,W3D_ATO_FORMAT,mode,W3D_ATO_WIDTH,texw,W3D_ATO_HEIGHT,texh,TAG_DONE);

	if(C.result!=W3D_SUCCESS)
		{printf("Cant create wtexture! \n");return(FALSE);}

	W3D_BindTexture(C.wcontext,0,O->wtexture);
	return(TRUE);
}
/*=================================================================*/
BOOL LoadTexture(struct object3D *O,UBYTE* name,UWORD size,UWORD bits)
{	/* load a RAW rgb bitmap in memory. Make it a Warp3D texture */
ULONG textureSize = size*size*bits/8;
BOOL ok;

VARS(name)
VAR(size)
VAR(bits)
	O->picture = (UBYTE *) malloc(textureSize);
	if(O->picture==NULL)
		{printf("Cant alloc picture! \n");return(FALSE);}
	if(LoadFile(O->picture,name,textureSize)==FALSE)
		{printf("Cant load picture! \n");return(FALSE);}
		
	if(C.UseNova)
		ok=DoTextureNova(O,O->picture,size,size,bits);
	else
		ok=DoTextureWarp3D(O,O->picture,size,size,bits);		
	return(ok);	
}
/*==========================================================================*/
void	 MyDrawText(WORD x,WORD y,UBYTE *text)
{	/* draw a text in the window */
struct RastPort *rp;

/* if use Warp3D context Yoffset */
	if(!C.UseNova) 
		y=y+C.wcontext->yoffset;

	rp=C.window->RPort;
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
/*=================================================================*/
static void DoFps(void)
{/* count the average "frame per second" */
UBYTE drawname[10];
	
	if(C.drawmode=='e') strcpy(drawname,"Elem.");
	if(C.drawmode=='t') strcpy(drawname,"Tris.");
	if(C.drawmode=='p') strcpy(drawname,"Poin.");
	if(C.drawmode=='l') strcpy(drawname,"Lin.");

	if(C.Zmode==W3D_Z_NEVER) strcpy(C.zname,"ZNEVER");
	if(C.Zmode==W3D_Z_LESS) strcpy(C.zname,"ZLESS");
	if(C.Zmode==W3D_Z_GEQUAL) strcpy(C.zname,"ZGEQUAL");
	if(C.Zmode==W3D_Z_LEQUAL) strcpy(C.zname,"ZLEQUAL");
	if(C.Zmode==W3D_Z_GREATER) strcpy(C.zname,"ZGREATER");
	if(C.Zmode==W3D_Z_NOTEQUAL) strcpy(C.zname,"ZNOTEQUAL");
	if(C.Zmode==W3D_Z_EQUAL) strcpy(C.zname,"ZEQUAL");
	if(C.Zmode==W3D_Z_ALWAYS) strcpy(C.zname,"ZALWAYS");

	if (++C.FramesCounted >= (20*FRAMESCOUNT)) 			/* ie after the object turned 20 times  */
	{
		C.Time  = clock();
		C.FPS = (20*FRAMESCOUNT*CLOCKS_PER_SEC) / (C.Time - C.OldTime) ;
		C.OldTime = C.Time; 
		C.FramesCounted = 0;
		if(C.UseZTest)
		{
		printf("context->zbuffer:\n");
		MyDumpMem(C.wcontext->zbuffer,16);
		}
	}

	sprintf(C.FpsText,"COW3D: %ld Fps(%ldtris %ldpoints)(zbuf%d/zupd%d(%s) optirot%d buffer%d) as %s(big%d)",C.FPS,C.CowObj->PInb/3,C.CowObj->Pnb,C.Zbuffer,C.zupdate,C.zname,C.optimroty,C.IsBuffered,drawname,C.bigpoint);	
	MyDrawText(3,9,C.FpsText);
	
	if(C.FramesCounted==0)
	if(C.Time!=0)
		printf("%s\n",C.FpsText);	

}
/*=================================================================*/
void SwitchDisplayWarp3D(void)
{
W3D_Double z=0.90;
ULONG n;

/* lock hardware then clear */
	W3D_Flush(C.wcontext);
	W3D_FlushFrame(C.wcontext);
	W3D_WaitIdle(C.wcontext);

	W3D_SetDrawRegion(C.wcontext,C.bufferbm,0,&C.scissor);
	WaitBlit();

/* Wait for the VBlank period is a quick-n'-dirty way of limiting the frame-rate to monitor's rate */
	NLOOP(C.FrameLimit)
		WaitBOVP(&(C.window->WScreen->ViewPort));

	BltBitMapRastPort(C.bufferbm,0,0,C.window->RPort,0,0,C.DisplayW,C.DisplayH,0xC0);	/* copy the "back buffer" to the window */

	if( W3D_SUCCESS != W3D_LockHardware(C.wcontext) ) return;
#ifdef OS4
W3D_Color color;
	color.a=color.r=color.g=color.b=0.0;
	W3D_ClearBuffers(C.wcontext,&color,&z, NULL);
#else
	W3D_ClearDrawRegion(C.wcontext,0);
	W3D_ClearZBuffer(C.wcontext, &z);
#endif
	W3D_UnLockHardware(C.wcontext);
}
/*=================================================================*/
void SwitchDisplay(void)
{
	if(C.UseNova)
		SwitchDisplayNova();
	else
		SwitchDisplayWarp3D();	
}
/*=================================================================*/
void SetEnvColor(float r,float g,float b,float a)
{
	C.EnvColor.r=r; C.EnvColor.g=g; C.EnvColor.b=b; C.EnvColor.a=a;
}	
/*==================================================================*/
void QueryStateWarp3D( ULONG state)
{
UBYTE statename[50];

	statename[0]=0;
	if(state==W3D_AUTOTEXMANAGEMENT)	strcpy(statename,"W3D_AUTOTEXMANAGEMENT");
	if(state==W3D_SYNCHRON)				strcpy(statename,"W3D_SYNCHRON");
	if(state==W3D_INDIRECT)				strcpy(statename,"W3D_INDIRECT");
	if(state==W3D_GLOBALTEXENV)			strcpy(statename,"W3D_GLOBALTEXENV");
	if(state==W3D_DOUBLEHEIGHT)			strcpy(statename,"W3D_DOUBLEHEIGHT");
	if(state==W3D_FAST)					strcpy(statename,"W3D_FAST");
	if(state==W3D_TEXMAPPING)			strcpy(statename,"W3D_TEXMAPPING");
	if(state==W3D_PERSPECTIVE)			strcpy(statename,"W3D_PERSPECTIVE");
	if(state==W3D_GOURAUD)				strcpy(statename,"W3D_GOURAUD");
	if(state==W3D_ZBUFFER)				strcpy(statename,"W3D_ZBUFFER");
	if(state==W3D_ZBUFFERUPDATE)		strcpy(statename,"W3D_ZBUFFERUPDATE");
	if(state==W3D_BLENDING)				strcpy(statename,"W3D_BLENDING");
	if(state==W3D_FOGGING)				strcpy(statename,"W3D_FOGGING");
	if(state==W3D_ANTI_POINT)			strcpy(statename,"W3D_ANTI_POINT");
	if(state==W3D_ANTI_LINE)			strcpy(statename,"W3D_ANTI_LINE");
	if(state==W3D_ANTI_POLYGON)			strcpy(statename,"W3D_ANTI_POLYGON");
	if(state==W3D_ANTI_FULLSCREEN)		strcpy(statename,"W3D_ANTI_FULLSCREEN");
	if(state==W3D_DITHERING)			strcpy(statename,"W3D_DITHERING");
	if(state==W3D_LOGICOP)				strcpy(statename,"W3D_LOGICOP");
	if(state==W3D_STENCILBUFFER)		strcpy(statename,"W3D_STENCILBUFFER");
	if(state==W3D_ALPHATEST)			strcpy(statename,"W3D_ALPHATEST");
	if(state==W3D_SPECULAR)				strcpy(statename,"W3D_SPECULAR");
	if(state==W3D_TEXMAPPING3D)			strcpy(statename,"W3D_TEXMAPPING3D");
	if(state==W3D_CHROMATEST)			strcpy(statename,"W3D_CHROMATEST");

	#ifdef OS4		
	if(state==W3D_MULTITEXTURE )		strcpy(statename,"W3D_MULTITEXTURE");
	if(state==W3D_FOG_COORD )			strcpy(statename,"FOG_COORD");
	if(state==W3D_LINE_STIPPLE )		strcpy(statename,"W3D_LINE_STIPPLE");
	if(state==W3D_POLYGON_STIPPLE )		strcpy(statename,"W3D_POLYGON_STIPPLE");
	#endif   

	if(statename[0]==0) return;
	C.result = W3D_GetState(C.wcontext,state);
	if(C.result == W3D_ENABLED) printf(" [x]"); else printf(" [ ]");
	printf(" %s\n",&statename[4]);
}
/*==================================================================*/
void WarpBmFmtToName(UBYTE *name, ULONG WarpBmFmt)
{
	strcpy(name,"W3D_FMT_UNKNOWN");
	if(WarpBmFmt==W3D_FMT_CLUT)			strcpy(name,"W3D_FMT_CLUT");
	if(WarpBmFmt==W3D_FMT_R5G5B5)		strcpy(name,"W3D_FMT_R5G5B5");
	if(WarpBmFmt==W3D_FMT_B5G5R5)		strcpy(name,"W3D_FMT_B5G5R5");
	if(WarpBmFmt==W3D_FMT_R5G5B5PC)		strcpy(name,"W3D_FMT_R5G5B5PC");
	if(WarpBmFmt==W3D_FMT_B5G5R5PC)		strcpy(name,"W3D_FMT_B5G5R5PC");
	if(WarpBmFmt==W3D_FMT_R5G6B5)		strcpy(name,"W3D_FMT_R5G6B5");
	if(WarpBmFmt==W3D_FMT_B5G6R5)		strcpy(name,"W3D_FMT_B5G6R5");
	if(WarpBmFmt==W3D_FMT_R5G6B5PC)		strcpy(name,"W3D_FMT_R5G6B5PC");
	if(WarpBmFmt==W3D_FMT_B5G6R5PC)		strcpy(name,"W3D_FMT_B5G6R5PC");
	if(WarpBmFmt==W3D_FMT_R8G8B8)		strcpy(name,"W3D_FMT_R8G8B8");
	if(WarpBmFmt==W3D_FMT_B8G8R8)		strcpy(name,"W3D_FMT_B8G8R8");
	if(WarpBmFmt==W3D_FMT_A8B8G8R8)		strcpy(name,"W3D_FMT_A8B8G8R8");
	if(WarpBmFmt==W3D_FMT_A8R8G8B8)		strcpy(name,"W3D_FMT_A8R8G8B8");
	if(WarpBmFmt==W3D_FMT_B8G8R8A8)		strcpy(name,"W3D_FMT_B8G8R8A8");
	if(WarpBmFmt==W3D_FMT_R8G8B8A8)		strcpy(name,"W3D_FMT_R8G8B8A8");
}
/*==================================================================*/
void WarpTexFmtToName(UBYTE *name, ULONG WarpTexFmt)
{
	if(WarpTexFmt==W3D_CHUNKY)		strcpy(name,"W3D_CHUNKY  ");
	if(WarpTexFmt==W3D_A1R5G5B5)	strcpy(name,"W3D_A1R5G5B5");
	if(WarpTexFmt==W3D_R5G6B5)		strcpy(name,"W3D_R5G6B5  ");
	if(WarpTexFmt==W3D_R8G8B8)		strcpy(name,"W3D_R8G8B8  ");
	if(WarpTexFmt==W3D_A4R4G4B4)	strcpy(name,"W3D_A4R4G4B4");
	if(WarpTexFmt==W3D_A8R8G8B8)	strcpy(name,"W3D_A8R8G8B8");
	if(WarpTexFmt==W3D_A8)			strcpy(name,"W3D_A8      ");
	if(WarpTexFmt==W3D_L8)			strcpy(name,"W3D_L8      ");
	if(WarpTexFmt==W3D_L8A8)		strcpy(name,"W3D_L8A8    ");
	if(WarpTexFmt==W3D_I8)			strcpy(name,"W3D_I8      ");
	if(WarpTexFmt==W3D_R8G8B8A8)	strcpy(name,"W3D_R8G8B8A8");

	if(WarpTexFmt==12)	strcpy(name,"W3D_COMPRESSED_R5G6B5");
	if(WarpTexFmt==13)	strcpy(name,"W3D_A4_COMPRESSED_R5G6B5 13");
	if(WarpTexFmt==14)	strcpy(name,"W3D_COMPRESSED_A8R5G6B5");
}
/*==================================================================*/
ULONG BmToWarpBmFmt(ULONG BmFmt)
{
ULONG WarpBmFmt=0;

	if(BmFmt==PIXFMT_LUT8)		WarpBmFmt=W3D_FMT_CLUT;
	if(BmFmt==PIXFMT_RGB15)		WarpBmFmt=W3D_FMT_R5G5B5;
	if(BmFmt==PIXFMT_BGR15)		WarpBmFmt=W3D_FMT_B5G5R5;
	if(BmFmt==PIXFMT_RGB15PC)	WarpBmFmt=W3D_FMT_R5G5B5PC;
	if(BmFmt==PIXFMT_BGR15PC)	WarpBmFmt=W3D_FMT_B5G5R5PC;
	if(BmFmt==PIXFMT_RGB16)		WarpBmFmt=W3D_FMT_R5G6B5;
	if(BmFmt==PIXFMT_BGR16)		WarpBmFmt=W3D_FMT_B5G6R5;
	if(BmFmt==PIXFMT_RGB16PC)	WarpBmFmt=W3D_FMT_R5G6B5PC;
	if(BmFmt==PIXFMT_BGR16PC)	WarpBmFmt=W3D_FMT_B5G6R5PC;
	if(BmFmt==PIXFMT_RGB24)		WarpBmFmt=W3D_FMT_R8G8B8;
	if(BmFmt==PIXFMT_BGR24)		WarpBmFmt=W3D_FMT_B8G8R8;
	if(BmFmt==PIXFMT_ARGB32)	WarpBmFmt=W3D_FMT_A8R8G8B8;
	if(BmFmt==PIXFMT_BGRA32)	WarpBmFmt=W3D_FMT_B8G8R8A8;
	if(BmFmt==PIXFMT_RGBA32)	WarpBmFmt=W3D_FMT_R8G8B8A8;
	
	return(WarpBmFmt);
}		
/*==================================================================*/
void QueryDriverWarp3D(W3D_Driver *driver, ULONG query, ULONG BmFmt)
{
UBYTE BmName[50];
UBYTE queryname[50];
BOOL ShowValue;

	if(query>162)
	if(query<170)
		return;

	if(query>177)
		return;

	queryname[0]=0;
	ShowValue=FALSE;


	WarpBmFmtToName(BmName,BmFmt);

	if(query==W3D_Q_DRAW_POINT)			strcpy(queryname,"W3D_Q_DRAW_POINT");   
	if(query==W3D_Q_DRAW_LINE)			strcpy(queryname,"W3D_Q_DRAW_LINE");   
	if(query==W3D_Q_DRAW_TRIANGLE)		strcpy(queryname,"W3D_Q_DRAW_TRIANGLE");   
	if(query==W3D_Q_DRAW_POINT_X)		strcpy(queryname,"W3D_Q_DRAW_POINT_X");   
	if(query==W3D_Q_DRAW_LINE_X)		strcpy(queryname,"W3D_Q_DRAW_LINE_X");   
	if(query==W3D_Q_DRAW_LINE_ST)		strcpy(queryname,"W3D_Q_DRAW_LINE_ST");   
	if(query==W3D_Q_DRAW_POLY_ST)		strcpy(queryname,"W3D_Q_DRAW_POLY_ST");   
	if(query==W3D_Q_DRAW_POINT_FX)		strcpy(queryname,"W3D_Q_DRAW_POINT_FX");   
	if(query==W3D_Q_DRAW_LINE_FX)		strcpy(queryname,"W3D_Q_DRAW_LINE_FX");   
	if(query==W3D_Q_TEXMAPPING)			strcpy(queryname,"W3D_Q_TEXMAPPING");   
	if(query==W3D_Q_MIPMAPPING)			strcpy(queryname,"W3D_Q_MIPMAPPING");   
	if(query==W3D_Q_BILINEARFILTER)		strcpy(queryname,"W3D_Q_BILINEARFILTER");   
	if(query==W3D_Q_MMFILTER)			strcpy(queryname,"W3D_Q_MMFILTER");   
	if(query==W3D_Q_LINEAR_REPEAT)		strcpy(queryname,"W3D_Q_LINEAR_REPEAT");   
	if(query==W3D_Q_LINEAR_CLAMP)		strcpy(queryname,"W3D_Q_LINEAR_CLAMP");   
	if(query==W3D_Q_PERSPECTIVE)		strcpy(queryname,"W3D_Q_PERSPECTIVE");   
	if(query==W3D_Q_PERSP_REPEAT)		strcpy(queryname,"W3D_Q_PERSP_REPEAT");   
	if(query==W3D_Q_PERSP_CLAMP)		strcpy(queryname,"W3D_Q_PERSP_CLAMP");   
	if(query==W3D_Q_ENV_REPLACE)		strcpy(queryname,"W3D_Q_ENV_REPLACE");   
	if(query==W3D_Q_ENV_DECAL)			strcpy(queryname,"W3D_Q_ENV_DECAL");   
	if(query==W3D_Q_ENV_MODULATE)		strcpy(queryname,"W3D_Q_ENV_MODULATE");   
	if(query==W3D_Q_ENV_BLEND)			strcpy(queryname,"W3D_Q_ENV_BLEND");   
	if(query==W3D_Q_WRAP_ASYM)			strcpy(queryname,"W3D_Q_WRAP_ASYM");   
	if(query==W3D_Q_SPECULAR)			strcpy(queryname,"W3D_Q_SPECULAR");   
	if(query==W3D_Q_BLEND_DECAL_FOG)	strcpy(queryname,"W3D_Q_BLEND_DECAL_FOG");    
	if(query==W3D_Q_TEXMAPPING3D)		strcpy(queryname,"W3D_Q_TEXMAPPING3D");   
	if(query==W3D_Q_CHROMATEST)			strcpy(queryname,"W3D_Q_CHROMATEST");   
	if(query==W3D_Q_FLATSHADING)		strcpy(queryname,"W3D_Q_FLATSHADING");   
	if(query==W3D_Q_GOURAUDSHADING)		strcpy(queryname,"W3D_Q_GOURAUDSHADING");   
	if(query==W3D_Q_ZBUFFER)			strcpy(queryname,"W3D_Q_ZBUFFER");   
	if(query==W3D_Q_ZBUFFERUPDATE)		strcpy(queryname,"W3D_Q_ZBUFFERUPDATE");   
	if(query==W3D_Q_ZCOMPAREMODES)		strcpy(queryname,"W3D_Q_ZCOMPAREMODES");   
	if(query==W3D_Q_ALPHATEST)			strcpy(queryname,"W3D_Q_ALPHATEST");   
	if(query==W3D_Q_ALPHATESTMODES)		strcpy(queryname,"W3D_Q_ALPHATESTMODES");   
	if(query==W3D_Q_BLENDING)			strcpy(queryname,"W3D_Q_BLENDING");   
	if(query==W3D_Q_SRCFACTORS)			strcpy(queryname,"W3D_Q_SRCFACTORS");   
	if(query==W3D_Q_DESTFACTORS)		strcpy(queryname,"W3D_Q_DESTFACTORS");   
	if(query==W3D_Q_ONE_ONE)			strcpy(queryname,"W3D_Q_ONE_ONE");   
	if(query==W3D_Q_FOGGING)			strcpy(queryname,"W3D_Q_FOGGING");   
	if(query==W3D_Q_LINEAR)				strcpy(queryname,"W3D_Q_LINEAR");   
	if(query==W3D_Q_EXPONENTIAL)		strcpy(queryname,"W3D_Q_EXPONENTIAL");   
	if(query==W3D_Q_S_EXPONENTIAL)		strcpy(queryname,"W3D_Q_S_EXPONENTIAL");   
	if(query==W3D_Q_INTERPOLATED)		strcpy(queryname,"W3D_Q_INTERPOLATED");   
	if(query==W3D_Q_ANTIALIASING)		strcpy(queryname,"W3D_Q_ANTIALIASING");   
	if(query==W3D_Q_ANTI_POINT)			strcpy(queryname,"W3D_Q_ANTI_POINT");   
	if(query==W3D_Q_ANTI_LINE)			strcpy(queryname,"W3D_Q_ANTI_LINE");   
	if(query==W3D_Q_ANTI_POLYGON)		strcpy(queryname,"W3D_Q_ANTI_POLYGON");   
	if(query==W3D_Q_ANTI_FULLSCREEN)	strcpy(queryname,"W3D_Q_ANTI_FULLSCREEN");   
	if(query==W3D_Q_DITHERING)			strcpy(queryname,"W3D_Q_DITHERING");   
	if(query==W3D_Q_PALETTECONV)		strcpy(queryname,"W3D_Q_PALETTECONV");   
	if(query==W3D_Q_SCISSOR)			strcpy(queryname,"W3D_Q_SCISSOR");   
	if(query==W3D_Q_MAXTEXWIDTH)		strcpy(queryname,"W3D_Q_MAXTEXWIDTH");   
	if(query==W3D_Q_MAXTEXHEIGHT)		strcpy(queryname,"W3D_Q_MAXTEXHEIGHT");   
	if(query==W3D_Q_MAXTEXWIDTH_P)		strcpy(queryname,"W3D_Q_MAXTEXWIDTH_P");   
	if(query==W3D_Q_MAXTEXHEIGHT_P)		strcpy(queryname,"W3D_Q_MAXTEXHEIGHT_P");   
	if(query==W3D_Q_RECTTEXTURES)		strcpy(queryname,"W3D_Q_RECTTEXTURES");   
	if(query==W3D_Q_LOGICOP)			strcpy(queryname,"W3D_Q_LOGICOP");   
	if(query==W3D_Q_MASKING)			strcpy(queryname,"W3D_Q_MASKING");   
	if(query==W3D_Q_STENCILBUFFER)		strcpy(queryname,"W3D_Q_STENCILBUFFER");   
	if(query==W3D_Q_STENCIL_MASK)		strcpy(queryname,"W3D_Q_STENCIL_MASK");   
	if(query==W3D_Q_STENCIL_FUNC)		strcpy(queryname,"W3D_Q_STENCIL_FUNC");   
	if(query==W3D_Q_STENCIL_SFAIL)		strcpy(queryname,"W3D_Q_STENCIL_SFAIL");   
	if(query==W3D_Q_STENCIL_DPFAIL)		strcpy(queryname,"W3D_Q_STENCIL_DPFAIL");   
	if(query==W3D_Q_STENCIL_DPPASS)		strcpy(queryname,"W3D_Q_STENCIL_DPPASS");   
	if(query==W3D_Q_STENCIL_WRMASK)		strcpy(queryname,"W3D_Q_STENCIL_WRMASK");   
	if(query==W3D_Q_DRAW_POINT_TEX)		strcpy(queryname,"W3D_Q_DRAW_POINT_TEX");   
	if(query==W3D_Q_DRAW_LINE_TEX)		strcpy(queryname,"W3D_Q_DRAW_LINE_TEX");   
	if(query==W3D_Q_CULLFACE)			strcpy(queryname,"W3D_Q_CULLFACE");   
	   
	#ifdef OS4				   
	if(query==W3D_Q_NUM_TMU)			strcpy(queryname,"W3D_Q_NUM_TMU");   
	if(query==W3D_Q_NUM_BLEND)			strcpy(queryname,"W3D_Q_NUM_BLEND");   
	if(query==W3D_Q_ENV_COMBINE)		strcpy(queryname,"W3D_Q_ENV_COMBINE");   
	if(query==W3D_Q_ENV_ADD)			strcpy(queryname,"W3D_Q_ENV_ADD");   
	if(query==W3D_Q_ENV_SUB)			strcpy(queryname,"W3D_Q_ENV_SUB");   
	if(query==W3D_Q_ENV_CROSSBAR)		strcpy(queryname,"W3D_Q_ENV_CROSSBAR");   
	if(query==W3D_Q_STIPPLE_LINE)		strcpy(queryname,"W3D_Q_STIPPLE_LINE");   
	if(query==W3D_Q_STIPPLE_POLYGON)	strcpy(queryname,"W3D_Q_STIPPLE_POLYGON");   

	if(query==W3D_Q_NUM_TMU)   
		ShowValue=TRUE;				   
	if(query==W3D_Q_NUM_BLEND)   
		ShowValue=TRUE;				   
	#endif   
	   
	if(query==W3D_Q_STENCIL_FUNC)   
		ShowValue=TRUE;				   
	if(query==W3D_Q_STENCIL_SFAIL)   
		ShowValue=TRUE;				   
	if(query==W3D_Q_STENCIL_DPFAIL)   
		ShowValue=TRUE;				   
	if(query==W3D_Q_STENCIL_DPPASS)   
		ShowValue=TRUE;				   
	if(query==W3D_Q_MAXTEXWIDTH)   
		ShowValue=TRUE;				   
	if(query==W3D_Q_MAXTEXHEIGHT)   
		ShowValue=TRUE;				   
	if(query==W3D_Q_MAXTEXWIDTH_P)   
		ShowValue=TRUE;				   
	if(query==W3D_Q_MAXTEXHEIGHT_P)   
		ShowValue=TRUE;				 

	if(queryname[0]==0) return;

	if(!ShowValue)
	{
	C.result = W3D_QueryDriver(driver,query,BmFmt);
	if(C.result != W3D_NOT_SUPPORTED) printf(" QueryDriver[x]"); else printf(" QueryDriver[ ]");
	C.result = W3D_Query(C.wcontext,query,BmFmt);
	if(C.result != W3D_NOT_SUPPORTED) printf(" Query[x]"); else printf(" Query[ ]");
	}
	else
	{
	C.result = W3D_QueryDriver(driver,query,BmFmt);
	printf(" QueryDriver[%ld]",C.result);
	C.result = W3D_Query(C.wcontext,query,BmFmt);
	printf(" Query[%ld]",C.result);
	}
	printf(" %s \n",&queryname[6]);
}
/*==================================================================*/
void QueryTexWarp3D(ULONG TexFmt,ULONG BmFmt)
{
UBYTE BmName[50];
UBYTE TexName[50];

	WarpBmFmtToName(BmName,BmFmt);
	WarpTexFmtToName(TexName,TexFmt);

	printf("  Hardware Support for TexFmt %s / BmFmt %s \t",&TexName[4],&BmName[8]);
	C.result = W3D_GetTexFmtInfo(C.wcontext, TexFmt, BmFmt);
	if(C.result & W3D_TEXFMT_FAST)
	printf("[FAST]"); else printf("[....]");
	if(C.result & W3D_TEXFMT_CLUTFAST)
	printf("[CLUTFAST]"); else printf("[........]");
	if(C.result & W3D_TEXFMT_ARGBFAST)
	printf("[ARGB]"); else printf("[....]");
	if(C.result & W3D_TEXFMT_UNSUPPORTED)
	printf("[NO]"); else printf("[..]");
	if(C.result & W3D_TEXFMT_SUPPORTED)
	printf("[SUP]"); else printf("[...]");
	printf("\n");
}
	
/*================================================================================*/
void ShowSrcDst(void)
{
#define  WINFO(var,val,doc) if(var == val) printf(" " #var "=" #val ", " #doc "\n");

	printf("Blending src%ld/dst%ld\n",C.SrcFunc,C.DstFunc);

	WINFO(C.SrcFunc,W3D_ZERO,"source + dest ")
	WINFO(C.SrcFunc,W3D_ONE,"source + dest ")
	WINFO(C.SrcFunc,W3D_SRC_COLOR,"dest only !!!!")
	WINFO(C.SrcFunc,W3D_DST_COLOR,"source only ")
	WINFO(C.SrcFunc,W3D_ONE_MINUS_SRC_COLOR,"dest only !!!!")
	WINFO(C.SrcFunc,W3D_ONE_MINUS_DST_COLOR,"source only ")
	WINFO(C.SrcFunc,W3D_SRC_ALPHA,"source + dest ")
	WINFO(C.SrcFunc,W3D_ONE_MINUS_SRC_ALPHA,"source + dest ")
	WINFO(C.SrcFunc,W3D_DST_ALPHA,"source + dest ")
	WINFO(C.SrcFunc,W3D_ONE_MINUS_DST_ALPHA,"source + dest ")
	WINFO(C.SrcFunc,W3D_SRC_ALPHA_SATURATE,"source only ")
	WINFO(C.SrcFunc,W3D_CONSTANT_COLOR," ");
	WINFO(C.SrcFunc,W3D_ONE_MINUS_CONSTANT_COLOR," ");
	WINFO(C.SrcFunc,W3D_CONSTANT_ALPHA," ");
	WINFO(C.SrcFunc,W3D_ONE_MINUS_CONSTANT_ALPHA," ");

	WINFO(C.DstFunc,W3D_ZERO,"source + dest ")
	WINFO(C.DstFunc,W3D_ONE,"source + dest ")
	WINFO(C.DstFunc,W3D_SRC_COLOR,"dest only ")
	WINFO(C.DstFunc,W3D_DST_COLOR,"source only !!!!")
	WINFO(C.DstFunc,W3D_ONE_MINUS_SRC_COLOR,"dest only ")
	WINFO(C.DstFunc,W3D_ONE_MINUS_DST_COLOR,"source only !!!!")
	WINFO(C.DstFunc,W3D_SRC_ALPHA,"source + dest ")
	WINFO(C.DstFunc,W3D_ONE_MINUS_SRC_ALPHA,"source + dest ")
	WINFO(C.DstFunc,W3D_DST_ALPHA,"source + dest ")
	WINFO(C.DstFunc,W3D_ONE_MINUS_DST_ALPHA,"source + dest ")
	WINFO(C.DstFunc,W3D_SRC_ALPHA_SATURATE,"source only !!!!")
	WINFO(C.DstFunc,W3D_CONSTANT_COLOR," ");
	WINFO(C.DstFunc,W3D_ONE_MINUS_CONSTANT_COLOR," ");
	WINFO(C.DstFunc,W3D_CONSTANT_ALPHA," ");
	WINFO(C.DstFunc,W3D_ONE_MINUS_CONSTANT_ALPHA," ");

/* check if this blend mode works ? */
	C.result=SetBlendMode();
	if(C.result!=W3D_SUCCESS)
		{
		printf("Cant SetBlendMode!(src %ld dst %ld)\n",C.SrcFunc,C.DstFunc);
		if(!C.UseNova)				
			W3D_SetBlendMode(C.wcontext,W3D_ONE,W3D_ONE);	 /* so default to a working blendmode */
		}
}
/*==================================================================*/
void CheckBlendModes(void)
{
ULONG m,n;
	

 	MLOOP(15)
	{
	C.SrcFunc=m+1; 	/* Src/DstFunc go 1 to 15 */
	if(C.SrcFunc<10) printf(" Src%ld :",C.SrcFunc); else printf(" Src%ld:",C.SrcFunc);
	NLOOP(15)
	{
	C.DstFunc=n+1;

	C.result=SetBlendMode();
	if(C.result==W3D_SUCCESS)
		{if(C.DstFunc<10) printf(" Dst%ld ",C.DstFunc); else printf(" Dst%ld",C.DstFunc);}
	else
		{if(C.DstFunc<10) printf(" ---- "); else printf(" -----");}
	}
	printf("\n");
	}
	C.SrcFunc=C.DstFunc=0;
	printf("============================================================\n");
	printf(" 1=ZERO\n");
	printf(" 2=ONE\n");
	printf(" 3=SRC_COLOR\n");
	printf(" 4=DST_COLOR\n");
	printf(" 5=ONE_MINUS_SRC_COLOR\n");
	printf(" 6=ONE_MINUS_DST_COLOR\n");
	printf(" 7=SRC_ALPHA\n");
	printf(" 8=ONE_MINUS_SRC_ALPHA\n");
	printf(" 9=DST_ALPHA\n");
	printf("10=ONE_MINUS_DST_ALPHA\n");
	printf("11=SRC_ALPHA_SATURATE\n");
	printf("12=CONSTANT_COLOR\n");
	printf("13=ONE_MINUS_CONSTANT_COLOR\n");
	printf("14=CONSTANT_ALPHA\n");
	printf("15=ONE_MINUS_CONSTANT_ALPHA\n");
	printf("============================================================\n");
	
}	
/*==================================================================*/
void CheckWarp3D(void)
{
W3D_Driver **drivers;
W3D_Driver *driver=NULL;
ULONG state,query,m,n,DriversNb;
ULONG CurrentBmFmt,BmFmt,TexFmt;
UBYTE name[50];

// Pixels formats:
// PIXFMT_	Cybergraphics	0 to 13
// PIXF_	gfx				1 to 21
// W3D_		Warp3D tex		1 to 14
// W3D_FMT_	Warp3D bm		(1<<0) to (1<<14)
// W3DN_PixelFormat Nova	0 to 7
// W3DN_ElementFormat Nova	0 to 15
	
	printf("CheckWarp3D:\n");
	printf("============================================================\n");

/* recover current bitmap's BmFmt */
	CurrentBmFmt=BmToWarpBmFmt( GetCyberMapAttr(C.bufferbm,CYBRMATTR_PIXFMT) );
	WarpBmFmtToName(name,CurrentBmFmt);
	printf("Current bitmap's format is %s (%ld)\n",name,CurrentBmFmt);
	printf("============================================================\n");

	C.flags = W3D_CheckDriver();
	if (C.flags & W3D_DRIVER_3DHW)			{printf("Hardware W3D_Driver available\n");}
	if (C.flags & W3D_DRIVER_CPU)			{printf("Software W3D_Driver available\n");}
	if (C.flags & W3D_DRIVER_UNAVAILABLE)	{printf("No W3D_Driver !!!\n");return;}

	DriversNb=0;
	drivers = W3D_GetDrivers();
	if (*drivers == NULL)
		return;

	printf("============================================================\n");
	while (drivers[0])
	{
	driver=drivers[0];
	printf("W3D_Driver <%s> soft:%d ChipID:%ld formats:%ld \n",driver->name,driver->swdriver,driver->ChipID,driver->formats);
	DriversNb++;
	drivers++;
	}
	printf("%ld Driver(s) installed\n",DriversNb);
	printf("============================================================\n");
	if(DriversNb>1) printf("WARNING: You have %ld Warp3D drivers installed !!!\n",DriversNb);

	drivers = W3D_GetDrivers();
	if (*drivers == NULL)
		return;

	printf("============================================================\n");
	while (drivers[0])
	{
	driver=drivers[0];

	printf(" W3D_Driver <%s> soft:%d ChipID:%ld formats:%ld \n",driver->name,driver->swdriver,driver->ChipID,driver->formats);


	printf("============================================================\n");
	printf("Query drawing features for all bitmaps destformat\n");
	MLOOP(15)
	{
	BmFmt=1<<m;;
	WarpBmFmtToName(name,BmFmt);
	printf("------------------------------\n");
	printf("Bm format %s (%ld)\n",name,BmFmt);
	QueryDriverWarp3D(driver,W3D_Q_DRAW_POINT,BmFmt);
	QueryDriverWarp3D(driver,W3D_Q_DRAW_LINE,BmFmt);
	QueryDriverWarp3D(driver,W3D_Q_DRAW_TRIANGLE,BmFmt);
	}

	WarpBmFmtToName(name,CurrentBmFmt);
	printf("============================================================\n");
	printf("Query all for the current bitmap's format %s (%ld)\n",name,CurrentBmFmt);
	NLOOP(177)
	{
	query=n+1;
		QueryDriverWarp3D(driver,query,CurrentBmFmt);
	}

	drivers++;
	printf("============================================================\n");
	}


/* Values for currently selected  driver */
	printf("============================================================\n");
	printf("Values for this context's  driver\n");
	printf("State default values:\n");
	NLOOP(31)
	{
	state=1<<(n+1);
		QueryStateWarp3D(state);
	}


	printf("============================================================\n");
	printf("Textures formats/bitmaps destformats: \n");
	MLOOP(14)
	{
	TexFmt=m+1;
	WarpTexFmtToName(name,TexFmt);
	printf("Texture format %s (%ld)\n",name,TexFmt);
		NLOOP(15)
		{
		BmFmt=1<<n;
		QueryTexWarp3D(TexFmt,BmFmt);
		}
	printf("============================================================\n");
	}

	MLOOP(15)
	{
	C.SrcFunc=m+1; 	/* src/dstfunc go 1 to 15 */
	if(C.SrcFunc<10) printf("BlendMode Src%ld :",C.SrcFunc); else printf("BlendMode Src%ld:",C.SrcFunc);
	NLOOP(15)
	{
	C.DstFunc=n+1;

	C.result=SetBlendMode();
	if(C.result==W3D_SUCCESS)
		{if(C.DstFunc<10) printf(" Dst%ld ",C.DstFunc); else printf(" Dst%ld",C.DstFunc);}
	else
		{if(C.DstFunc<10) printf(" ---- "); else printf(" -----");}
	}
	printf("\n");
	}
	
	C.SrcFunc=C.DstFunc=0;
	
	printf("============================================================\n");
	printf(" 1=W3D_ZERO\n");
	printf(" 2=W3D_ONE\n");
	printf(" 3=W3D_SRC_COLOR\n");
	printf(" 4=W3D_DST_COLOR\n");
	printf(" 5=W3D_ONE_MINUS_SRC_COLOR\n");
	printf(" 6=W3D_ONE_MINUS_DST_COLOR\n");
	printf(" 7=W3D_SRC_ALPHA\n");
	printf(" 8=W3D_ONE_MINUS_SRC_ALPHA\n");
	printf(" 9=W3D_DST_ALPHA\n");
	printf("10=W3D_ONE_MINUS_DST_ALPHA\n");
	printf("11=W3D_SRC_ALPHA_SATURATE\n");
	printf("12=W3D_CONSTANT_COLOR\n");
	printf("13=W3D_ONE_MINUS_CONSTANT_COLOR\n");
	printf("14=W3D_CONSTANT_ALPHA\n");
	printf("15=W3D_ONE_MINUS_CONSTANT_ALPHA\n");
	printf("============================================================\n");
}
/*=================================================================*/
void ResetTexBlendWarp3D(void)
{
#ifdef OS4
ULONG n;


	W3D_SetBlendMode(C.wcontext,W3D_ONE,W3D_ONE);
	W3D_SetState(C.wcontext,W3D_BLENDING,W3D_DISABLE);

	W3D_SetState(C.wcontext,W3D_MULTITEXTURE,W3D_ENABLE);	
	C.NumTMU = W3D_Query(C.wcontext,W3D_Q_NUM_TMU,0);

	NLOOP(C.NumTMU)
		W3D_BindTexture(C.wcontext,n,NULL);
	NLOOP(C.NumTMU)
		{
		W3D_SetTextureBlendTags(C.wcontext,
		W3D_BLEND_STAGE,n,
		W3D_ENV_MODE,W3D_OFF,
		TAG_DONE);
		}

	C.result=W3D_SetTextureBlend(C.wcontext,NULL);
	if(C.result!=W3D_SUCCESS)
		{printf("Cant ResetTexBlendWarp3D (result %ld)\n",C.result);}
#endif
	;
}
/*=================================================================*/
void SetTexBlendWarp3D(struct object3D *O)
{
#ifdef OS4
ULONG n;

	C.NumTMU = W3D_Query(C.wcontext,W3D_Q_NUM_TMU,0);

	NLOOP(C.NumTMU)
	{
	if(n==0)
		W3D_BindTexture(C.wcontext,0,O->wtexture);
	else
		W3D_BindTexture(C.wcontext,n,NULL);
	}

	NLOOP(C.NumTMU)
	{
	if(n==0)
	W3D_SetTextureBlendTags(C.wcontext,
	W3D_BLEND_STAGE, 0,
	W3D_ENV_MODE, C.TexEnvMode,
	TAG_DONE);

	if(n>0)
	W3D_SetTextureBlendTags(C.wcontext,
 	W3D_BLEND_STAGE,n,
 	W3D_COLOR_COMBINE,W3D_COMBINE_DISABLED,
 	W3D_ALPHA_COMBINE,W3D_COMBINE_DISABLED,
	TAG_DONE);
	}
	C.result=W3D_SetTextureBlend(C.wcontext,NULL);
	if(C.result!=W3D_SUCCESS)
		{printf("Cant SetTextureBlend (result %ld)\n",C.result);}
#else
	W3D_SetTexEnv(C.wcontext,O->wtexture,C.TexEnvMode,&C.EnvColor);
	W3D_BindTexture(C.wcontext,0,O->wtexture);
#endif
}
/*==================================================================*/
ULONG SetBlendModeWarp3D(void)
{
	if(C.SrcFunc==0)
	if(C.DstFunc==0)
		return(W3D_ILLEGALINPUT);

	if((C.SrcFunc==W3D_ZERO) && (C.DstFunc==W3D_ZERO))	/* skip this special value that is used in Wazp3D */
		{
		W3D_SetState(C.wcontext, W3D_TEXMAPPING,W3D_DISABLE);
		return(W3D_SUCCESS);
		}

	return(W3D_SetBlendMode(C.wcontext,C.SrcFunc,C.DstFunc));
}
/*==================================================================*/
ULONG SetBlendMode(void)
{
BOOL ok;
	
	if(C.UseNova)
		ok=SetBlendModeNova();
	else
		ok=SetBlendModeWarp3D();
	return(ok);
}
/*=================================================================*/
void SetStatesWarp3D(struct object3D *O)
{

	W3D_SetState(C.wcontext, W3D_BLENDING,		W3D_DISABLE);	/* non transparent */
	W3D_SetState(C.wcontext, W3D_GOURAUD,		W3D_DISABLE);	/* non shaded */
	W3D_SetState(C.wcontext, W3D_PERSPECTIVE,	W3D_DISABLE);	/* not needed here */

	W3D_SetState(C.wcontext, W3D_TEXMAPPING,	W3D_ENABLE);	/* use textures */
	W3D_SetState(C.wcontext, W3D_ZBUFFER,		W3D_ENABLE);
	W3D_SetState(C.wcontext, W3D_ZBUFFERUPDATE,	W3D_ENABLE);
	W3D_SetZCompareMode(C.wcontext,C.Zmode);/* use C.Zbuffer = remove hidden pixels */
	W3D_SetState(C.wcontext, W3D_SCISSOR,		W3D_ENABLE);	/* clip to C.screen size */
	W3D_SetFrontFace(C.wcontext,W3D_CCW);
	W3D_SetState(C.wcontext, W3D_CULLFACE,		W3D_ENABLE);	/* remove hidden faces */

	W3D_SetState(C.wcontext, W3D_GOURAUD,		W3D_ENABLE);	/* patch: gouraud is needed on some hardware */

	if(C.IsBlended)
		W3D_SetState(C.wcontext, W3D_BLENDING,W3D_ENABLE);

	if(!C.HideFace)
		W3D_SetState(C.wcontext,W3D_CULLFACE,		W3D_DISABLE);
	if(!C.Zbuffer)
		W3D_SetState(C.wcontext, W3D_ZBUFFER,		W3D_DISABLE);
	if(!C.zupdate)
		W3D_SetState(C.wcontext, W3D_ZBUFFERUPDATE,	W3D_DISABLE);
	if(!C.colored)
		W3D_SetState(C.wcontext, W3D_TEXMAPPING,	W3D_DISABLE);

	SetBlendModeWarp3D();
	SetTexBlendWarp3D(O);
}
/*==================================================================*/
void SetStates(struct object3D *O)
{
REM(SetStates)	
	if(C.UseNova)
		SetStatesNova(O);
	else
		SetStatesWarp3D(O);
}
/*==================================================================================*/
BOOL OpenAmigaLibraries(void)
{
	LIBOPEN(GfxBase,graphics.library,0L)
	LIBOPEN(IntuitionBase,intuition.library,0L)
	LIBOPEN(CyberGfxBase,cybergraphics.library,0L)

	LIBOPEN4(IExec,SysBase)

	LIBOPEN4(IGraphics,GfxBase)
	LIBOPEN4(IIntuition,IntuitionBase)
	LIBOPEN4(ICyberGfx,CyberGfxBase)

#ifdef STATWAZP3D
	WAZP3D_Init(SysBase);
#else
	LIBOPEN(Warp3DBase,Warp3D.library,4L);
	LIBOPEN4(IWarp3D,Warp3DBase)
#endif	
	
	return(TRUE);
}
/*==================================================================================*/
BOOL OpenNovaLibraries(void)
{
	LIBOPEN(Warp3DNovaBase,Warp3DNova.library,0L)
	LIBOPEN4(IW3DNova,Warp3DNovaBase)
	return(TRUE);
}
/*======================================================================================*/
void CloseAmigaLibraries()
{
	LIBCLOSE4(IGraphics)
	LIBCLOSE4(IIntuition)
	LIBCLOSE4(ICyberGfx)
	
	LIBCLOSE(GfxBase)
	LIBCLOSE(IntuitionBase)
	LIBCLOSE(CyberGfxBase)
	
#ifdef STATWAZP3D
	WAZP3D_Close();
#else
	if(Warp3DBase)			CloseLibrary(Warp3DBase);
	LIBCLOSE4(IWarp3D)
#endif
}
/*======================================================================================*/
void CloseNovaLibraries()
{
	LIBCLOSE4(IW3DNova)
	LIBCLOSE(Warp3DNovaBase)
}
/*==========================================================================*/
BOOL OpenDisplayWarp3D(void)
{
#ifdef STATWAZP3D
#define W3D_Q_SETTINGS 9999
	drivers = W3D_GetDrivers();
	if(*drivers == NULL)
		{printf("No Warp3D driver found !!!\n");return(FALSE);}
	W3D_QueryDriver(drivers[0],W3D_Q_SETTINGS,0);
#endif

REM(OpenDisplayWarp3D)
#ifdef OS3
	C.wcontext = W3D_CreateContextTags(&C.result,
		W3D_CC_MODEID,      C.ModeID,             // Mandatory for non-pubC.screen
		W3D_CC_BITMAP,      (ULONG)C.bufferbm,          // The bitmap we'll use
		W3D_CC_YOFFSET,     0,                  // We don't do dbuffering
		W3D_CC_DRIVERTYPE,  W3D_DRIVER_BEST,    // Let Warp3D decide
		W3D_CC_DOUBLEHEIGHT,FALSE,               // Double height C.screen

		W3D_CC_INDIRECT,    TRUE,			//all drawing operations will be queued
		W3D_CC_FAST,        TRUE,               // Fast drawing
	TAG_DONE);
#endif

#ifdef OS4
	C.wcontext = W3D_CreateContextTags(&C.result,
		W3D_CC_MODEID,      C.ModeID,             // Mandatory for non-pubC.screen
		W3D_CC_BITMAP,      (ULONG)C.bufferbm,          // The bitmap we'll use
		W3D_CC_YOFFSET,     0,                  // We don't do dbuffering
		W3D_CC_DRIVERTYPE,  W3D_DRIVER_BEST,    // Let Warp3D decide
		W3D_CC_DOUBLEHEIGHT,FALSE,               // Double height C.screen
	TAG_DONE);
#endif

	if(!C.wcontext || C.result != W3D_SUCCESS)
		{printf("Cant create Warp3D C.wcontext! (result %ld)\n",C.result);return(FALSE);}

		
	C.scissor.left=0;
	C.scissor.top=0;
	C.scissor.width=C.DisplayW;
	C.scissor.height=C.DisplayH;
		
	C.result=W3D_AllocZBuffer(C.wcontext);
	if(C.result!=W3D_SUCCESS)
	{printf("Cant create C.Zbuffer! (result %ld)\n",C.result);return(FALSE);}

	ResetTexBlendWarp3D();
	return(TRUE);	
}	
/*==========================================================================*/
BOOL OpenDisplay(void)
{	/* open a window & a rastport ("back buffer") & open warp3d & create a warp3d C.wcontext  */
ULONG Flags =WFLG_ACTIVATE | WFLG_REPORTMOUSE | WFLG_RMBTRAP | WFLG_SIMPLE_REFRESH | WFLG_GIMMEZEROZERO ;
ULONG IDCMPs=IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY | IDCMP_RAWKEY | IDCMP_MOUSEMOVE | IDCMP_MOUSEBUTTONS ;
BOOL ok;
	
	if(OpenAmigaLibraries()==FALSE)
		return(FALSE);
	C.GotNova=OpenNovaLibraries();
REM(OpenDisplay)
VAR(C.GotNova)
	if(C.GotNova==FALSE)
		C.UseNova=FALSE;
VAR(C.UseNova)
	C.screen 	=LockPubScreen("Workbench") ;
	C.ScreenW	=C.screen->Width;
	C.ScreenH	=C.screen->Height;
	C.ModeID  =GetVPModeID(&C.screen->ViewPort);
	UnlockPubScreen(NULL, C.screen);

	C.window = OpenWindowTags(NULL,
	WA_Activate,		TRUE,
	WA_InnerWidth,		C.DisplayW,
	WA_InnerHeight,		C.DisplayH,
	WA_Left,			(C.ScreenW - C.DisplayW)/2,
	WA_Top,				(C.ScreenH - C.DisplayH)/2,
	WA_Title,			(ULONG)progname,
	WA_DragBar,			TRUE,
	WA_CloseGadget,		TRUE,
	WA_GimmeZeroZero,	TRUE,
	WA_Backdrop,		FALSE,
	WA_Borderless,		FALSE,
	WA_IDCMP,			IDCMPs,
	WA_Flags,			Flags,
	WA_Flags,			Flags,
	TAG_DONE);

	if(C.window==NULL)
		{printf("Cant open window\n");return FALSE;}

	InitRastPort( &C.bufferrastport );				/* allocate an other bitmap/rastport four double buffering */
	C.ScreenBits  = GetBitMapAttr( C.window->WScreen->RastPort.BitMap, BMA_DEPTH );
	C.flags = BMF_DISPLAYABLE|BMF_MINPLANES;
	C.bufferrastport.BitMap = AllocBitMap(C.DisplayW,C.DisplayH,C.ScreenBits, C.flags, C.window->RPort->BitMap);
	if(C.bufferrastport.BitMap==NULL)
		{printf("No Bitmap\n");return FALSE;}

	C.bufferbm=C.bufferrastport.BitMap;				/* draw in this back-buffer */

		
	if(C.UseNova)
		ok=OpenDisplayNova();
	else
		ok=OpenDisplayWarp3D();

	return(ok);
}
/*=================================================================*/
void FreeObj(struct object3D *O)
{
	VAR(O->wtexture)
	if(O->wtexture)		{W3D_FreeTexObj(C.wcontext,O->wtexture);  O->wtexture=NULL;}

	VAR(O->picture)
	if(O->picture)		{free(O->picture); O->picture=NULL;}

#ifdef OS4
	if(C.UseNova)
	{	
	VAR(O->ntexture)
	if(O->ntexture) 	{C.ncontext->DestroyTexture(O->ntexture); O->ntexture=NULL;}
	
	VAR(O->vbo)
	if(O->vbo) 			{C.ncontext->DestroyVertexBufferObject(O->vbo); O->vbo=NULL;};
	}
#endif
	
	VAR(O)
	free(O);	/* free also P P2 PI that are included in Object */
}
/*=================================================================*/
void FreeData(void)
{

REM(BufferedP----------)
	if(C.BufferedP)		free(C.BufferedP);
REM(CowObj----------)
	if(C.CowObj)		FreeObj(C.CowObj);
REM(CosmosObj----------)
	if(C.CosmosObj)		FreeObj(C.CosmosObj);
REM(QuadObj----------)
	if(C.QuadObj)		FreeObj(C.QuadObj);
}
/*=================================================================*/
void CloseWarp3D(void)
{
REM(CloseWarp3D)
	W3D_Flush(C.wcontext);
	W3D_FlushFrame(C.wcontext);
	W3D_WaitIdle(C.wcontext);


	ResetTexBlendWarp3D();

	FreeData();

	W3D_FreeZBuffer(C.wcontext);
	if(C.wcontext)			W3D_DestroyContext(C.wcontext);
}
/*==========================================================================*/
void CloseDisplay(void)
{
REM(CloseDisplay)
	if(C.UseNova)
		CloseNova();
	else
		CloseWarp3D();	
	
	if(C.bufferrastport.BitMap)	FreeBitMap(C.bufferrastport.BitMap);
	if(C.window)					CloseWindow(C.window);

	CloseAmigaLibraries();
	if(C.GotNova)
		CloseNovaLibraries();

}	
/*================================================================================*/
void WindowEvents(void)
{		/* manage the window  */
struct IntuiMessage *imsg;

REM(WindowEvents)
	while( (imsg = (struct IntuiMessage *)GetMsg(C.window->UserPort)))
	{
	if(imsg == NULL) break;
	switch (imsg->Class)
		{
		case IDCMP_CLOSEWINDOW:
			C.closed=TRUE;				break;
		case IDCMP_VANILLAKEY:
			switch(imsg->Code)
			{
			case 'f':	C.showfps=!C.showfps;		break;
			case 'o':	C.optimroty=!C.optimroty;	break;

			case 'z':	C.Zbuffer=!C.Zbuffer;		break;
			case '1': 	C.Zmode=W3D_Z_NEVER; 	break;
			case '2': 	C.Zmode=W3D_Z_LESS; 	break;
			case '3': 	C.Zmode=W3D_Z_GEQUAL; 	break;
			case '4': 	C.Zmode=W3D_Z_LEQUAL; 	break;
			case '5': 	C.Zmode=W3D_Z_GREATER; 	break;
			case '6': 	C.Zmode=W3D_Z_NOTEQUAL; 	break;
			case '7': 	C.Zmode=W3D_Z_EQUAL; 	break;
			case '8': 	C.Zmode=W3D_Z_ALWAYS; 	break;
			case 'u':	C.zupdate=!C.zupdate;		break;
			case 'e':	C.drawmode='e';		break;
			case 't':	C.drawmode='t';		break;
			case 'l':	C.drawmode='l';		break;
			case 'p':	C.drawmode='p';		break;
			case '0':	C.bigpoint=!C.bigpoint;	break;
			case 'c':	C.colored=!C.colored;		break;
			case 'C':	C.DrawCow=!C.DrawCow;		break;
			case 'h':	C.HideFace=!C.HideFace;	break;
			case 'g':	C.greyreadz=!C.greyreadz;	break;
			case 'r':	C.rotate=!C.rotate;		break;
			case 'P':	C.UseLineTest=!C.UseLineTest;		break;
			case 'L':	C.UseLineTest=!C.UseLineTest;		break;
			case 'Z':	C.UseZTest=!C.UseZTest;		break;
			case 'b':	C.IsBuffered=!C.IsBuffered;	break;
			case '!':	debug=!debug;	break;
			case 'F':	C.FrameLimit++;	if(C.FrameLimit>10) C.FrameLimit=0; break;

			case 'S':
				C.SrcDstFunc--;
				if(C.SrcDstFunc>255) C.SrcDstFunc=0;
				C.SrcFunc=C.SrcDstFunc/16;
				C.DstFunc=C.SrcDstFunc-C.SrcFunc*16;
				ShowSrcDst();
				break;
			case 'D':
				C.SrcDstFunc++;
				if(C.SrcDstFunc>255) C.SrcDstFunc=0;
				C.SrcFunc=C.SrcDstFunc/16;
				C.DstFunc=C.SrcDstFunc-C.SrcFunc*16;
				ShowSrcDst();
				break;

			case 's':
				C.SrcFunc++;
				if(C.SrcFunc>15) 	C.SrcFunc=0;
				C.SrcDstFunc=C.SrcFunc*16+C.DstFunc;
				ShowSrcDst();
				break;
			case 'd':
				C.DstFunc++;
				if(C.DstFunc>15) 	C.DstFunc=0;
				C.SrcDstFunc=C.SrcFunc*16+C.DstFunc;
				ShowSrcDst();
				break;

			case 'm':
			case 'M':
				C.TexEnvMode++;	if(C.TexEnvMode>W3D_BLEND)	C.TexEnvMode=W3D_REPLACE;
				printf("Texenvmode %ld\n",C.TexEnvMode);
				WINFO(C.TexEnvMode,W3D_REPLACE,"unlit texturing ")
				WINFO(C.TexEnvMode,W3D_DECAL,"same as W3D_REPLACE use alpha to blend texture with primitive =lit-texturing")
				WINFO(C.TexEnvMode,W3D_MODULATE,"lit-texturing by modulation ")
				WINFO(C.TexEnvMode,W3D_BLEND,"blend with environment color ")
				break;

			case 'w':
			w3dpatch=!w3dpatch;
				if(w3dpatch)	printf("Warp3D is  patched\n");
				else			printf("Warp3D not patched\n");
				break;

			case 27:	C.closed=TRUE;		break;
			default:break;
			}
			break;
		default:
			break;
		}
	if(imsg)
		{ReplyMsg((struct Message *)imsg);imsg = NULL;}
	}
}
/*=================================================================*/
int main(int argc, char *argv[])
{
char *param=NULL;
ULONG size=0;
ULONG n;

	printf("Cow3D6: build " __DATE__ " at " __TIME__ "\n");
	SetDefault();

	if(argc==2)
		{
		param=argv[1];
		size=strlen(param);
		}

	NLOOP(size)
		{
		if(param[n]=='n')
			C.UseNova=TRUE;
		if(param[n]=='w')
			C.UseNova=FALSE;	
		}
	VAR(C.UseNova)
			
	if(!OpenDisplay())
		goto panic;

	if(C.UseNova)
		CheckNova();
	else
		CheckWarp3D();

	C.SrcFunc=W3D_ONE;
	C.DstFunc=W3D_ONE;
	C.SrcDstFunc=C.SrcFunc*16+C.DstFunc;


	C.CosmosObj=AddObject(pointsCountQuad,trianglesCountQuad*3);	/* simple quad as 2 tris */
	if(C.UseNova)
		ReadIncludedObjectNova(C.CosmosObj,pointsQuad,indicesQuad,1.0);	/* read data in Cow3D_Object.h */
	else
		ReadIncludedObjectWarp3D(C.CosmosObj,pointsQuad,indicesQuad);
	LoadTexture(C.CosmosObj,"Cosmos_256X256X32.RAW",256,32);		/* texture data as R8 G8 B8 A8*/
	if(C.UseNova) ObjectToVboNova(C.CosmosObj);	

	C.CowObj =AddObject(pointsCount,trianglesCount*3);				/* the cow object */
	if(C.UseNova)
		ReadIncludedObjectNova(C.CowObj,points,indices,COWSIZE);			/* read data in Cow3D_Object.h */
	else
		ReadIncludedObjectWarp3D(C.CowObj,points,indices);
	LoadTexture(C.CowObj,TEXNAME,TEXSIZE,32);						/* texture data as R8 G8 B8 A8*/
	if(C.UseNova) ObjectToVboNova(C.CowObj);	



	while(!C.closed)
	{
	REM(====== New frame =====)

		if(C.UseNova)
			DoViewNova();
		else
			DoViewWarp3D();		

		C.Use2D=FALSE;
		C.IsBlended=FALSE;
		SetEnvColor(0.0,0.0,1.0,1.0);
		SetStates(C.CowObj);
		if(C.DrawCow)
			DrawObject(C.CowObj);		/* draw it */

		C.Use2D=TRUE;
		C.DrawCosmos=TRUE;
		if(C.SrcFunc==W3D_ONE)
		if(C.DstFunc==W3D_ZERO)
			C.DrawCosmos=FALSE;			/* avoid to hide the cow */

		C.IsBlended=TRUE;
		SetEnvColor(0.0,1.0,0.0,1.0);
		SetStates(C.CosmosObj);
		if(C.DrawCosmos)
			DrawObject(C.CosmosObj);	/* draw it */

		if(!C.UseNova)
		{	
			if(C.UseLineTest)
				DrawPointLineTestsWarp3D(C.CowObj->wtexture);
			
			if(C.UseZTest)
				DrawZtests();

			if(C.greyreadz)
				DrawZvaluesWarp3D();

			W3D_Flush(C.wcontext);
		}

		SwitchDisplay();				/* copy to window */

		WindowEvents();					/* is window closed ? */
		if(C.showfps) DoFps(); 			/* count the average "frames per second" */
		if(C.rotate)
			C.RotY=C.RotY+SPEED;			/* rotate */
		if(C.RotY>=360.0)
				C.RotY=0.0;				/* rotate */
	}
	


panic:
	REM(ending...)

	CloseDisplay();
	return 0;
}
/*==================================================================*/








			
			

				











