/* Author: Alain Thellier - Paris - 2010 . See ReadMe for more infos */

#include <stdio.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>
#include <strings.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/intuition.h>
#include <proto/Warp3D.h>
#include <proto/cybergraphics.h>
#include <cybergraphics/cybergraphics.h>
/*==================================================================*/
#include "StarShipW3D.h"				/* 3d object*/
UBYTE  progname[]={"StarShipW3D"};
#define LARGE 640					/* window size */
#define HIGH  480
#define NLOOP(nbre) for(n=0;n<nbre;n++)
#define MLOOP(nbre) for(m=0;m<nbre;m++)
#define SPEED 5					/* object speed */
#define FRAMESCOUNT (360*2/SPEED)		/* frames to be counted to estimate fps */
#define MAXPRIM (3*1000)			/* Wazp3D cant draw bigger primitives  so split the object in several drawing*/
/*==================================================================*/
struct point3D{
	float x,y,z,u,v,w;
	UBYTE RGBA[4];
};
/*==================================================================*/
struct object3D{
	struct point3D  *P;		/* original points */
	struct point3D  *P2;		/* points rotated/transformed to screen */
	ULONG Pnb;				/* points counts(french "points nombre" */
	ULONG *indices;			/* indices that define the triangles */
	ULONG Inb;				/* indices counts(french "indices nombre" */
};
/*==================================================================*/
struct Screen  *screen		=NULL;
struct Window  *window		=NULL;
struct BitMap  *bm		=NULL;
struct Library *Warp3DBase	=NULL;
struct Library *CyberGfxBase	=NULL;
W3D_Context *context		=NULL;
W3D_Texture *tex1			=NULL;
UBYTE *picture1			=NULL;
W3D_Scissor scissor = {0,0,LARGE,HIGH};
struct RastPort bufferrastport;
ULONG result,ModeID,flags,ScreenBits;
BOOL  closed=FALSE;
BOOL tridraw=FALSE;
BOOL colored=TRUE;
BOOL showfps=TRUE;
BOOL zbuffer=TRUE;
BOOL zupdate=TRUE;
BOOL hideface=TRUE;
BOOL rotate=TRUE;
ULONG zmode=W3D_Z_LESS;
BOOL optimroty=FALSE;
float ViewMatrix[16];
struct object3D Obj;
float RotY=0.0;
ULONG FramesCounted=0;
ULONG FPS=0;
UBYTE FpsText[200];
UBYTE zname[5];
/*==================================================================*/
void DrawWarp3D(struct point3D  *P,ULONG *indices,ULONG Inb,ULONG primitive,W3D_Texture *tex)
{
void *VertexPointer;
void *TexCoordPointer;
void *ColorPointer;
UWORD stride=sizeof(struct point3D);
UWORD off_v,off_w;

	W3D_WaitIdle(context);		/* dont modify points or pointers during drawing */
/* set arrays pointers */
	VertexPointer=	(void *)&(P->x);
	TexCoordPointer=(void *)&(P->u);
	ColorPointer=	(void *)&(P->RGBA);
	off_v=(UWORD)( (ULONG)&(P->v) - (ULONG)&(P->u));
	off_w=(UWORD)( (ULONG)&(P->w) - (ULONG)&(P->u));
	result=W3D_VertexPointer(context,VertexPointer,stride,W3D_VERTEX_F_F_F, 0);
	result=W3D_TexCoordPointer(context,TexCoordPointer,stride,0, off_v, off_w,W3D_TEXCOORD_NORMALIZED);
	result=W3D_ColorPointer(context,ColorPointer,stride,W3D_COLOR_UBYTE ,W3D_CMODE_RGBA,0);
/* lock hardware then draw */
	result=W3D_LockHardware(context);
	if(result==W3D_SUCCESS)
		{
		W3D_BindTexture(context,0,tex);
		W3D_DrawElements(context,primitive,W3D_INDEX_ULONG,Inb,indices);	/* draw with warp3d */
		W3D_Flush(context);
		W3D_WaitIdle(context);
		W3D_UnLockHardware(context);
		}
}
/*==================================================================*/
void PtoV(struct point3D  *P,W3D_Vertex *v)
{
	v->x=P->x; v->y=P->y; v->z=P->z; v->w=P->w; 
	v->u=P->u*TEXSIZE; v->v=P->v*TEXSIZE;
	v->color.r=(float)P->RGBA[0]/255.0;
	v->color.g=(float)P->RGBA[1]/255.0;
	v->color.b=(float)P->RGBA[2]/255.0;
	v->color.a=(float)P->RGBA[3]/255.0;  
}
/*==================================================================*/
void TriDrawWarp3D(struct point3D  *P,ULONG *indices,ULONG Inb,W3D_Texture *tex)
{
W3D_Triangle tri;

struct point3D  *PN;
ULONG n;

	result=W3D_LockHardware(context);
	if(result==W3D_SUCCESS)
	{
	NLOOP(Inb/3)
	{
	tri.tex=tex;
	PtoV( &P[indices[n*3+0]], &tri.v1 );
	PtoV( &P[indices[n*3+1]], &tri.v2 );
	PtoV( &P[indices[n*3+2]], &tri.v3 );
 	W3D_DrawTriangle(context, &tri);
	}
	W3D_UnLockHardware(context);
	}
}
/*==================================================================*/
void DrawObjectWarp3D(struct object3D *O,W3D_Texture *tex)
{
ULONG n,nb,rest;

	if(tridraw)
		{TriDrawWarp3D(O->P2,O->indices,O->Inb,tex);return;}
	nb=O->Inb/MAXPRIM;
	rest=O->Inb - nb*MAXPRIM;
	NLOOP(nb)
		DrawWarp3D(O->P2,&O->indices[MAXPRIM*n],MAXPRIM,W3D_PRIMITIVE_TRIANGLES,tex);
	DrawWarp3D(O->P2,&O->indices[MAXPRIM*nb],rest,W3D_PRIMITIVE_TRIANGLES,tex);
}
/*=================================================================*/
void SetP(struct point3D  *P,float x, float y, float z,float w,float u, float v,UBYTE r,UBYTE g,UBYTE b,UBYTE a)
{
	if(P==NULL) return;
	P->x=x; P->y=y; P->z=z;	P->w=w; P->u=u; P->v=v;
	P->RGBA[0]=r;P->RGBA[1]=g;P->RGBA[2]=b;P->RGBA[3]=a;
}
/*==================================================================*/
void DrawOneQuad(float x,float y,float z,float large,float high,UBYTE r,UBYTE g,UBYTE b,UBYTE a)
{
struct point3D P[4];
ULONG indices[6]={0,1,2,0,2,3}; /* do the quad as 2 triangles */

	SetP(&P[0],x,y+high,z,1.0/z,0.0,1.0,r,g,b,a);
	SetP(&P[1],x+large,y+high,z,1.0/z,1.0,1.0,r,g,b,a);
	SetP(&P[2],x+large,y,z,1.0/z,1.0,0.0,r,g,b,a);
	SetP(&P[3],x,y,z,1.0/z,0.0,0.0,r,g,b,a);
	DrawWarp3D(P,indices,6,W3D_PRIMITIVE_TRIANGLES,NULL);
}
/*==================================================================*/
void DrawZtests(void)
{
float x,y,z;
float large,high;
ULONG n;
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

	W3D_SetState(context, W3D_TEXMAPPING,W3D_DISABLE);	/* color is enough to test the zbuffer */
	W3D_SetState(context, W3D_BLENDING,	W3D_ENABLE);	/* transparent to see the multipass effect*/

	large=50.0;
	high =25.0;
	NLOOP(7) /* draw 7 quads as various depth with various colors (z increase with n) */
	{
	x=n*large;
	y=n*2+20;
	z=zvalues[n];
	DrawOneQuad(x,y,z,large+large/3.0,high-n*4,rgba[4*n],rgba[4*n+1],rgba[4*n+2],rgba[4*n+3]);
	}

	NLOOP(7) /* do a multi-pass : redraw  a grey transparent square with same depth (sticked to the face) */
	{
	x=n*large;
	y=20+high/2;
	z=zvalues[n];
	DrawOneQuad(x+large/3.0,y,z,large/2,high-n*2,200,200,200,128);
	}

}
/*=================================================================*/
void LoadObject(struct object3D *O)
{
struct point3D  *P;
float *V;
ULONG n,size;
float x,y,z,w,u,v;
UBYTE r,g,b,a;

	O->Pnb=pointsCount;
	O->Inb=trianglesCount*3;

	size=O->Inb*sizeof(ULONG) + O->Pnb*sizeof(struct point3D)+ O->Pnb*sizeof(struct point3D); /* define all the object datas in a single malloc */
	O->indices 	=(ULONG *) malloc(size);
	O->P 		=(struct point3D *)&O->indices[O->Inb];
	O->P2		=(struct point3D *)&O->P[O->Pnb];

	NLOOP(O->Inb)
		O->indices[n]=indices[n];
	P=O->P;
	V=points;
	r=g=b=a=255;
	NLOOP(O->Pnb)
		{
		u=V[0]; v=V[1]; x=V[2]; y=V[3]; y=-y; z=V[4]; w=1.0/z;	/* beware z is negated so faces are reverted again in good order*/
		r=x*90+90; g=y*90+90; b=z*90+90;	/* just set various colors a stupid way*/
		SetP(P,x,y,z,w,u,v,r,g,b,a); P++; V=V+5;
		}
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
	M[b]  =  (float)cos(R);
	M[c]  =  (float)sin(R);
	M[d]  = -(float)sin(R);
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
void TransformP(register float *M,struct point3D  *P,LONG Pnb)
{						/* transform points with a given matrix */
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
void YrotateP(register float *M,struct point3D  *P,LONG Pnb)
{						/* y rotate points with a given matrix : optimized TransformP() */
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
void ProjectP(struct point3D  *P,LONG Pnb)
{						/* project points to screen-coordinates */
register float x;
register float y;
register float z;
register float sizex=LARGE/2.0;
register float sizey=HIGH /2.0;
register float sizez=0.8  /2.0;
register LONG n;

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
{						/* load a file in memory */
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
BOOL LoadTextureWarp3D(UBYTE* name,UWORD size,UWORD bits)
{						/* load a RAW rgb bitmap in memory. Make it a Warp3D texture */
ULONG textureSize = size*size*bits/8;
ULONG mode;

	picture1 = (UBYTE *) malloc(textureSize);
	if(picture1==NULL)
		return(FALSE);
	if(LoadFile(picture1,name,textureSize)==FALSE)
		return(FALSE);
	if (bits==32) mode=W3D_A8R8G8B8; else mode=W3D_R8G8B8;
	tex1=W3D_AllocTexObjTags(context,&result,W3D_ATO_IMAGE,(ULONG)picture1,W3D_ATO_FORMAT,mode,W3D_ATO_WIDTH,size,W3D_ATO_HEIGHT,size,TAG_DONE);

	if(result!=W3D_SUCCESS)
		{printf("Cant create tex! (error %ld)\n",result);return(FALSE);}
	if(tex1==NULL)
		{printf("Cant create tex! (tex==NULL)\n");return(FALSE);}

	W3D_SetTexEnv(context,tex1,W3D_REPLACE,NULL);
	if(tex1==NULL)
		return(FALSE);
	return(TRUE);
}
/*==========================================================================*/
void	 DrawText(WORD x,WORD y,UBYTE *text)
{						/* draw a text in the window */
struct RastPort *rp;
UBYTE  BlueRGBA[]={ 60, 20,200,255};
UBYTE WhiteRGBA[]={255,255,255,255};

	if(strlen(text)==0) return;

	rp=window->RPort;
	SetDrMd(rp,JAM1);
	SetAPen(rp,255) ; 						
	SetRGB32(&screen->ViewPort,255,BlueRGBA[0]<<24,BlueRGBA[1]<<24,BlueRGBA[2]<<24);
	RectFill(rp,x-3,y-9,x+6*strlen(text)+3,y+2);		/* draw a rectangle */
	SetRGB32(&screen->ViewPort,255,WhiteRGBA[0]<<24,WhiteRGBA[1]<<24,WhiteRGBA[2]<<24);
	Move(rp,x-1,y-1);	Text(rp,text, strlen(text));		/* draw the text */
	SetAPen(rp,1) ; 				
}
/*=================================================================*/
static void DoFPS(void)
{					/* count the average "frame per second" */
static clock_t last=0;
clock_t now;

	if(zmode==W3D_Z_NEVER) strcpy(zname,"Z_NEVER");
	if(zmode==W3D_Z_LESS) strcpy(zname,"Z_LESS");
	if(zmode==W3D_Z_GEQUAL) strcpy(zname,"Z_GEQUAL");
	if(zmode==W3D_Z_LEQUAL) strcpy(zname,"Z_LEQUAL");
	if(zmode==W3D_Z_GREATER) strcpy(zname,"Z_GREATER");
	if(zmode==W3D_Z_NOTEQUAL) strcpy(zname,"Z_NOTEQUAL");
	if(zmode==W3D_Z_EQUAL) strcpy(zname,"Z_EQUAL");
	if(zmode==W3D_Z_ALWAYS) strcpy(zname,"Z_ALWAYS");
	sprintf(FpsText,"%s: %d Fps (Object: %d triangles %d points)(zbuffer%d/zupdate%d(%s) optimizedYrot%d))",progname,FPS,Obj.Inb/3,Obj.Pnb,zbuffer,zupdate,zname,optimroty);

	if (++FramesCounted >= FRAMESCOUNT) 			/* ie after the object turned two times  */
	{
      now  = clock();
      FPS = (FRAMESCOUNT*CLOCKS_PER_SEC) / (now-last) ;
      last = now; FramesCounted = 0;
	printf("%s\n",FpsText);
	}

	DrawText(3,9,FpsText);
}
/*=================================================================*/
SwitchDisplayWarp3D(void)
{					
W3D_Double Zclear=0.90;

/* lock hardware then clear */
	W3D_FlushFrame(context);
	W3D_WaitIdle(context);
	W3D_SetDrawRegion(context,bm,0,&scissor);
	WaitBlit(); 
	BltBitMapRastPort(bufferrastport.BitMap,0,0,window->RPort,0,0,LARGE,HIGH,0xC0);	/* copy the "back buffer" to the window */

	result=W3D_LockHardware(context);
	if(result==W3D_SUCCESS)
	{
	W3D_ClearDrawRegion(context,0);
	W3D_ClearZBuffer(context, &Zclear);
	W3D_UnLockHardware(context);
	}
}
/*==================================================================*/	
void State( ULONG state)	
{	
UBYTE statename[50];

	statename[0]=0;
	if(state==W3D_AUTOTEXMANAGEMENT)	strcpy(statename,"W3D_AUTOTEXMANAGEMENT");
	if(state==W3D_SYNCHRON)			strcpy(statename,"W3D_SYNCHRON");
	if(state==W3D_INDIRECT)			strcpy(statename,"W3D_INDIRECT");
	if(state==W3D_GLOBALTEXENV)		strcpy(statename,"W3D_GLOBALTEXENV");
	if(state==W3D_DOUBLEHEIGHT)		strcpy(statename,"W3D_DOUBLEHEIGHT");
	if(state==W3D_FAST)				strcpy(statename,"W3D_FAST");
	if(state==W3D_TEXMAPPING)			strcpy(statename,"W3D_TEXMAPPING");
	if(state==W3D_PERSPECTIVE)			strcpy(statename,"W3D_PERSPECTIVE");
	if(state==W3D_GOURAUD)			strcpy(statename,"W3D_GOURAUD");
	if(state==W3D_ZBUFFER)			strcpy(statename,"W3D_ZBUFFER");
	if(state==W3D_ZBUFFERUPDATE)		strcpy(statename,"W3D_ZBUFFERUPDATE");
	if(state==W3D_BLENDING)			strcpy(statename,"W3D_BLENDING");
	if(state==W3D_FOGGING)			strcpy(statename,"W3D_FOGGING");
	if(state==W3D_ANTI_POINT)			strcpy(statename,"W3D_ANTI_POINT");
	if(state==W3D_ANTI_LINE)			strcpy(statename,"W3D_ANTI_LINE");
	if(state==W3D_ANTI_POLYGON)		strcpy(statename,"W3D_ANTI_POLYGON");
	if(state==W3D_ANTI_FULLSCREEN)		strcpy(statename,"W3D_ANTI_FULLSCREEN");
	if(state==W3D_DITHERING)			strcpy(statename,"W3D_DITHERING");
	if(state==W3D_LOGICOP)			strcpy(statename,"W3D_LOGICOP");
	if(state==W3D_STENCILBUFFER)		strcpy(statename,"W3D_STENCILBUFFER");
	if(state==W3D_ALPHATEST)			strcpy(statename,"W3D_ALPHATEST");
	if(state==W3D_SPECULAR)			strcpy(statename,"W3D_SPECULAR");
	if(state==W3D_TEXMAPPING3D)		strcpy(statename,"W3D_TEXMAPPING3D");
	if(state==W3D_CHROMATEST)			strcpy(statename,"W3D_CHROMATEST");
 
	if(statename[0]==0) return;
	result = W3D_GetState(context,state);	
	if (result == W3D_ENABLED) printf(" [x]"); else printf(" [ ]");	
	printf(" %s\n",&statename[4]);	
}
/*==================================================================*/	
void QueryDriver(W3D_Driver *driver, ULONG query, ULONG destfmt)	
{	
UBYTE destname[50];
UBYTE queryname[50];

	if(destfmt==W3D_FMT_CLUT)	strcpy(destname,"W3D_FMT_CLUT");   	   
	if(destfmt==W3D_FMT_R5G5B5)	strcpy(destname,"W3D_FMT_R5G5B5");   	   
	if(destfmt==W3D_FMT_B5G5R5)	strcpy(destname,"W3D_FMT_B5G5R5");  	   
	if(destfmt==W3D_FMT_R5G5B5PC)	strcpy(destname,"W3D_FMT_R5G5B5PC");  	   
	if(destfmt==W3D_FMT_B5G5R5PC)	strcpy(destname,"W3D_FMT_B5G5R5PC");   	   
	if(destfmt==W3D_FMT_R5G6B5)	strcpy(destname,"W3D_FMT_R5G6B5");   	   
	if(destfmt==W3D_FMT_B5G6R5)	strcpy(destname,"W3D_FMT_B5G6R5");   	   
	if(destfmt==W3D_FMT_R5G6B5PC)	strcpy(destname,"W3D_FMT_R5G6B5PC");   	   
	if(destfmt==W3D_FMT_B5G6R5PC)	strcpy(destname,"W3D_FMT_B5G6R5PC");  	   
	if(destfmt==W3D_FMT_R8G8B8)	strcpy(destname,"W3D_FMT_R8G8B8");   	   
	if(destfmt==W3D_FMT_B8G8R8)	strcpy(destname,"W3D_FMT_B8G8R8");   	   
	if(destfmt==W3D_FMT_A8R8G8B8)	strcpy(destname,"W3D_FMT_A8R8G8B8");   	   
	if(destfmt==W3D_FMT_B8G8R8A8)	strcpy(destname,"W3D_FMT_B8G8R8A8");   	   
	if(destfmt==W3D_FMT_R8G8B8A8)	strcpy(destname,"W3D_FMT_R8G8B8A8"); 
 
	queryname[0]=0;
	if(query==W3D_Q_DRAW_POINT)		strcpy(queryname,"W3D_Q_DRAW_POINT");   
	if(query==W3D_Q_DRAW_LINE)		strcpy(queryname,"W3D_Q_DRAW_LINE");   
	if(query==W3D_Q_DRAW_TRIANGLE)	strcpy(queryname,"W3D_Q_DRAW_TRIANGLE");   
	if(query==W3D_Q_DRAW_POINT_X)		strcpy(queryname,"W3D_Q_DRAW_POINT_X");   
	if(query==W3D_Q_DRAW_LINE_X)		strcpy(queryname,"W3D_Q_DRAW_LINE_X");   
	if(query==W3D_Q_DRAW_LINE_ST)		strcpy(queryname,"W3D_Q_DRAW_LINE_ST");   
	if(query==W3D_Q_DRAW_POLY_ST)		strcpy(queryname,"W3D_Q_DRAW_POLY_ST");   
	if(query==W3D_Q_TEXMAPPING)		strcpy(queryname,"W3D_Q_TEXMAPPING");   
	if(query==W3D_Q_MIPMAPPING)		strcpy(queryname,"W3D_Q_MIPMAPPING");   
	if(query==W3D_Q_BILINEARFILTER)	strcpy(queryname,"W3D_Q_BILINEARFILTER");   
	if(query==W3D_Q_MMFILTER)		strcpy(queryname,"W3D_Q_MMFILTER");   
	if(query==W3D_Q_LINEAR_REPEAT)	strcpy(queryname,"W3D_Q_LINEAR_REPEAT");   
	if(query==W3D_Q_LINEAR_CLAMP)		strcpy(queryname,"W3D_Q_LINEAR_CLAMP");   
	if(query==W3D_Q_PERSPECTIVE)		strcpy(queryname,"W3D_Q_PERSPECTIVE");   
	if(query==W3D_Q_PERSP_REPEAT)		strcpy(queryname,"W3D_Q_PERSP_REPEAT");   
	if(query==W3D_Q_PERSP_CLAMP)		strcpy(queryname,"W3D_Q_PERSP_CLAMP");   
	if(query==W3D_Q_ENV_REPLACE)		strcpy(queryname,"W3D_Q_ENV_REPLACE");   
	if(query==W3D_Q_ENV_DECAL)		strcpy(queryname,"W3D_Q_ENV_DECAL");   
	if(query==W3D_Q_ENV_MODULATE)		strcpy(queryname,"W3D_Q_ENV_MODULATE");   
	if(query==W3D_Q_ENV_BLEND)		strcpy(queryname,"W3D_Q_ENV_BLEND");   
	if(query==W3D_Q_FLATSHADING)		strcpy(queryname,"W3D_Q_FLATSHADING");   
	if(query==W3D_Q_GOURAUDSHADING)	strcpy(queryname,"W3D_Q_GOURAUDSHADING");   
	if(query==W3D_Q_ZBUFFER)		strcpy(queryname,"W3D_Q_ZBUFFER");   
	if(query==W3D_Q_ZBUFFERUPDATE)	strcpy(queryname,"W3D_Q_ZBUFFERUPDATE");   
	if(query==W3D_Q_ZCOMPAREMODES)	strcpy(queryname,"W3D_Q_ZCOMPAREMODES");   
	if(query==W3D_Q_ALPHATEST)		strcpy(queryname,"W3D_Q_ALPHATEST");   
	if(query==W3D_Q_ALPHATESTMODES)	strcpy(queryname,"W3D_Q_ALPHATESTMODES");   
	if(query==W3D_Q_BLENDING)		strcpy(queryname,"W3D_Q_BLENDING");   
	if(query==W3D_Q_SRCFACTORS)		strcpy(queryname,"W3D_Q_SRCFACTORS");   
	if(query==W3D_Q_DESTFACTORS)		strcpy(queryname,"W3D_Q_DESTFACTORS");   
	if(query==W3D_Q_FOGGING)		strcpy(queryname,"W3D_Q_FOGGING");   
	if(query==W3D_Q_LINEAR)			strcpy(queryname,"W3D_Q_LINEAR");   
	if(query==W3D_Q_EXPONENTIAL)		strcpy(queryname,"W3D_Q_EXPONENTIAL");   
	if(query==W3D_Q_S_EXPONENTIAL)	strcpy(queryname,"W3D_Q_S_EXPONENTIAL");   
	if(query==W3D_Q_ANTIALIASING)		strcpy(queryname,"W3D_Q_ANTIALIASING");   
	if(query==W3D_Q_ANTI_POINT)		strcpy(queryname,"W3D_Q_ANTI_POINT");   
	if(query==W3D_Q_ANTI_LINE)		strcpy(queryname,"W3D_Q_ANTI_LINE");   
	if(query==W3D_Q_ANTI_POLYGON)		strcpy(queryname,"W3D_Q_ANTI_POLYGON");   
	if(query==W3D_Q_ANTI_FULLSCREEN)	strcpy(queryname,"W3D_Q_ANTI_FULLSCREEN");   
	if(query==W3D_Q_DITHERING)		strcpy(queryname,"W3D_Q_DITHERING");   
	if(query==W3D_Q_SCISSOR)		strcpy(queryname,"W3D_Q_SCISSOR");   
	if(query==W3D_Q_RECTTEXTURES)		strcpy(queryname,"W3D_Q_RECTTEXTURES");   
	if(query==W3D_Q_LOGICOP)		strcpy(queryname,"W3D_Q_LOGICOP");   
	if(query==W3D_Q_MASKING)		strcpy(queryname,"W3D_Q_MASKING");   
	if(query==W3D_Q_STENCILBUFFER)	strcpy(queryname,"W3D_Q_STENCILBUFFER");   
	if(query==W3D_Q_STENCIL_MASK)		strcpy(queryname,"W3D_Q_STENCIL_MASK");   
	if(query==W3D_Q_STENCIL_FUNC)		strcpy(queryname,"W3D_Q_STENCIL_FUNC");   
	if(query==W3D_Q_STENCIL_SFAIL)	strcpy(queryname,"W3D_Q_STENCIL_SFAIL");   
	if(query==W3D_Q_STENCIL_DPFAIL)	strcpy(queryname,"W3D_Q_STENCIL_DPFAIL");   
	if(query==W3D_Q_STENCIL_DPPASS)	strcpy(queryname,"W3D_Q_STENCIL_DPPASS");   
	if(query==W3D_Q_STENCIL_WRMASK)	strcpy(queryname,"W3D_Q_STENCIL_WRMASK");   
	if(query==W3D_Q_PALETTECONV)		strcpy(queryname,"W3D_Q_PALETTECONV");   
	if(query==W3D_Q_DRAW_POINT_FX)	strcpy(queryname,"W3D_Q_DRAW_POINT_FX");   
	if(query==W3D_Q_DRAW_POINT_TEX)	strcpy(queryname,"W3D_Q_DRAW_POINT_TEX");   
	if(query==W3D_Q_DRAW_LINE_FX)		strcpy(queryname,"W3D_Q_DRAW_LINE_FX");   
	if(query==W3D_Q_DRAW_LINE_TEX)	strcpy(queryname,"W3D_Q_DRAW_LINE_TEX");   
	if(query==W3D_Q_SPECULAR)		strcpy(queryname,"W3D_Q_SPECULAR");   
	if(query==W3D_Q_CULLFACE)		strcpy(queryname,"W3D_Q_CULLFACE");
 
	if(queryname[0]==0) return;
	result = W3D_QueryDriver(driver,query,destfmt);	
	if (result != W3D_NOT_SUPPORTED) printf(" QueryDriver[x]"); else printf(" QueryDriver[ ]");	
	result = W3D_Query(context,query,destfmt);	
	if (result != W3D_NOT_SUPPORTED) printf(" Query[x]"); else printf(" Query[ ]");
	printf(" %s for destformat %s \n",&queryname[6],&destname[8]);	
}	
/*==================================================================*/	
void QueryTex(ULONG texfmt,ULONG destfmt)	
{
UBYTE destname[50];
UBYTE texname[50];

	if(destfmt==W3D_FMT_CLUT)	strcpy(destname,"W3D_FMT_CLUT    ");   	   
	if(destfmt==W3D_FMT_R5G5B5)	strcpy(destname,"W3D_FMT_R5G5B5  ");   	   
	if(destfmt==W3D_FMT_B5G5R5)	strcpy(destname,"W3D_FMT_B5G5R5  ");  	   
	if(destfmt==W3D_FMT_R5G5B5PC)	strcpy(destname,"W3D_FMT_R5G5B5PC");  	   
	if(destfmt==W3D_FMT_B5G5R5PC)	strcpy(destname,"W3D_FMT_B5G5R5PC");   	   
	if(destfmt==W3D_FMT_R5G6B5)	strcpy(destname,"W3D_FMT_R5G6B5  ");   	   
	if(destfmt==W3D_FMT_B5G6R5)	strcpy(destname,"W3D_FMT_B5G6R5  ");   	   
	if(destfmt==W3D_FMT_R5G6B5PC)	strcpy(destname,"W3D_FMT_R5G6B5PC");   	   
	if(destfmt==W3D_FMT_B5G6R5PC)	strcpy(destname,"W3D_FMT_B5G6R5PC");  	   
	if(destfmt==W3D_FMT_R8G8B8)	strcpy(destname,"W3D_FMT_R8G8B8  ");   	   
	if(destfmt==W3D_FMT_B8G8R8)	strcpy(destname,"W3D_FMT_B8G8R8  ");   	   
	if(destfmt==W3D_FMT_A8R8G8B8)	strcpy(destname,"W3D_FMT_A8R8G8B8");   	   
	if(destfmt==W3D_FMT_B8G8R8A8)	strcpy(destname,"W3D_FMT_B8G8R8A8");   	   
	if(destfmt==W3D_FMT_R8G8B8A8)	strcpy(destname,"W3D_FMT_R8G8B8A8"); 

	if(texfmt==W3D_CHUNKY)		strcpy(texname,"W3D_CHUNKY  ");	   
	if(texfmt==W3D_A1R5G5B5)	strcpy(texname,"W3D_A1R5G5B5");	   
	if(texfmt==W3D_R5G6B5)		strcpy(texname,"W3D_R5G6B5  ");	   
	if(texfmt==W3D_R8G8B8)		strcpy(texname,"W3D_R8G8B8  ");	   
	if(texfmt==W3D_A4R4G4B4)	strcpy(texname,"W3D_A4R4G4B4");	   
	if(texfmt==W3D_A8R8G8B8)	strcpy(texname,"W3D_A8R8G8B8");	   
	if(texfmt==W3D_A8)		strcpy(texname,"W3D_A8      ");	   
	if(texfmt==W3D_L8)		strcpy(texname,"W3D_L8      ");	   
	if(texfmt==W3D_L8A8)		strcpy(texname,"W3D_L8A8    ");	   
	if(texfmt==W3D_I8)		strcpy(texname,"W3D_I8      ");	   
	if(texfmt==W3D_R8G8B8A8)	strcpy(texname,"W3D_R8G8B8A8");	

	printf("  Hardware Support for texfmt %s desfmt %s \t",&texname[4],&destname[8]);	
	result = W3D_GetTexFmtInfo(context, texfmt, destfmt);	
	if (result & W3D_TEXFMT_FAST)	
	printf("[FAST]"); else printf("[....]");	
	if (result & W3D_TEXFMT_CLUTFAST)	
	printf("[CLUTFAST]"); else printf("[........]");	
	if (result & W3D_TEXFMT_ARGBFAST)	
	printf("[ARGB]"); else printf("[....]");	
	if (result & W3D_TEXFMT_UNSUPPORTED)	
	printf("[NO]"); else printf("[..]");	
	if (result & W3D_TEXFMT_SUPPORTED)	
	printf("[SUP]"); else printf("[...]");	
	printf("\n");	
}	
/*==================================================================*/	
BOOL DoContextCheckWarp3D(void)
{
W3D_Driver **drivers;	
W3D_Driver *driver;
ULONG texfmt,destfmt,state,query,w,h,wp,hp,m,n;

	printf("CheckWarp3D:\n");
	printf("==============================\n");

	flags = W3D_CheckDriver();	
	if (flags & W3D_DRIVER_3DHW)		{printf("Hardware W3D_Driver available\n");}
	if (flags & W3D_DRIVER_CPU)		{printf("Software W3D_Driver available\n");}	
	if (flags & W3D_DRIVER_UNAVAILABLE) {printf("No W3D_Driver !!!\n");goto panic;}

	drivers = W3D_GetDrivers();

	if (*drivers == NULL) 
	{	
	printf("Panic: No W3D_Driver(s) found !!!\n");	
	return;	
	}	
	printf("==============================\n");
	while (drivers[0]) 
	{
	driver=drivers[0];
	printf("========= W3D_Driver <%s> soft:%ld ChipID:%ld formats:%ld =======\n",driver->name,driver->swdriver,driver->ChipID,driver->formats);

	MLOOP(15)
	{
	destfmt=1<<m;
	printf("------------------------------\n");
	printf("destformat:%d\n",destfmt);
	QueryDriver(driver,W3D_Q_DRAW_POINT,destfmt);	
	QueryDriver(driver,W3D_Q_DRAW_LINE,destfmt);		
	QueryDriver(driver,W3D_Q_DRAW_TRIANGLE,destfmt);	
	w =W3D_QueryDriver(driver,W3D_Q_MAXTEXWIDTH   ,destfmt);	
	h =W3D_QueryDriver(driver,W3D_Q_MAXTEXHEIGHT  ,destfmt);	
	wp=W3D_QueryDriver(driver,W3D_Q_MAXTEXWIDTH_P ,destfmt);	
	hp=W3D_QueryDriver(driver,W3D_Q_MAXTEXHEIGHT_P,destfmt);	
	printf("Max texture size %ld X %ld (perspective %ld X %ld )\n",w,h,wp,hp);
	}

	drivers++;
	}

/* recover current bitmap's destfmt */
	destfmt=GetCyberMapAttr(bm,CYBRMATTR_PIXFMT);
	if(destfmt==PIXFMT_LUT8)	destfmt=W3D_FMT_CLUT; 		 	   
	if(destfmt==PIXFMT_RGB15)	destfmt=W3D_FMT_R5G5B5; 		   
	if(destfmt==PIXFMT_BGR15)	destfmt=W3D_FMT_B5G5R5; 	 	   
	if(destfmt==PIXFMT_RGB15PC)	destfmt=W3D_FMT_R5G5B5PC; 	   
	if(destfmt==PIXFMT_BGR15PC)	destfmt=W3D_FMT_B5G5R5PC; 		   
	if(destfmt==PIXFMT_RGB16)	destfmt=W3D_FMT_R5G6B5; 	 	   
	if(destfmt==PIXFMT_BGR16)	destfmt=W3D_FMT_B5G6R5; 	  	   
	if(destfmt==PIXFMT_RGB16PC)	destfmt=W3D_FMT_R5G6B5PC; 	  	   
	if(destfmt==PIXFMT_BGR16PC)	destfmt=W3D_FMT_B5G6R5PC; 	 	   
	if(destfmt==PIXFMT_RGB24)	destfmt=W3D_FMT_R8G8B8; 	  	   
	if(destfmt==PIXFMT_BGR24)	destfmt=W3D_FMT_B8G8R8; 	  	   
	if(destfmt==PIXFMT_ARGB32)	destfmt=W3D_FMT_A8R8G8B8; 	   
	if(destfmt==PIXFMT_BGRA32)	destfmt=W3D_FMT_B8G8R8A8; 		   
	if(destfmt==PIXFMT_RGBA32)	destfmt=W3D_FMT_R8G8B8A8; 	 
	printf("==============================\n");	
	printf("Current bitmap's destformat is %d\n",destfmt);

	printf("==============================\n");	
	printf("Query for the current bitmap's destformat:\n");
	NLOOP(162)
	{
	query=n+1;
	if(query!=W3D_Q_MAXTEXWIDTH)
	if(query!=W3D_Q_MAXTEXHEIGHT)
	if(query!=W3D_Q_MAXTEXWIDTH_P)
	if(query!=W3D_Q_MAXTEXHEIGHT_P) 
		QueryDriver(driver,query,destfmt);
	}	


	context = W3D_CreateContextTags(&result,
		W3D_CC_MODEID,      ModeID,             // Mandatory for non-pubscreen
		W3D_CC_BITMAP,      (ULONG)bm,          // The bitmap we'll use
		W3D_CC_YOFFSET,     0,                  // We don't do dbuffering
		W3D_CC_DRIVERTYPE,  W3D_DRIVER_BEST,    // Let Warp3D decide
		W3D_CC_DOUBLEHEIGHT,FALSE,               // Double height screen
		W3D_CC_FAST,        TRUE,               // Fast drawing
	TAG_DONE);

	if (!context || result != W3D_SUCCESS)
		{printf("Cant create context! (error %ld)\n",result);return(FALSE);}

	printf("==============================\n");	
	printf("State default values:\n");
	NLOOP(27)
	{
	state=1<<(n+1);
		State(state);		
	}


	printf("==============================\n");
	printf("Textures formats/bitmaps destformats: \n");
	MLOOP(11)
	{
	texfmt=m+1;
		NLOOP(15)
		{
		destfmt=1<<n;
		QueryTex(texfmt,destfmt);	
		}
	printf("==============================\n");

	}
	return(TRUE);
panic:
	return(FALSE);
}	
/*=================================================================*/
BOOL StartWarp3D(void)
{						/* open a window & a ratsport ("back buffer") & open warp3d & create a warp3d context  */
UWORD screenlarge,screenhigh,ok;
ULONG Flags =WFLG_ACTIVATE | WFLG_REPORTMOUSE | WFLG_RMBTRAP | WFLG_SIMPLE_REFRESH | WFLG_GIMMEZEROZERO ;
ULONG IDCMPs=IDCMP_CLOSEWINDOW | IDCMP_VANILLAKEY | IDCMP_RAWKEY | IDCMP_MOUSEMOVE | IDCMP_MOUSEBUTTONS ;

	CyberGfxBase = OpenLibrary("cybergraphics.library", 0L);
	if (CyberGfxBase==NULL)
		{printf("Cant open LIBS:cybergraphics.library\n");	return FALSE;};

	Warp3DBase = OpenLibrary("Warp3D.library", 4L);
	if (!Warp3DBase)
		{printf("Cant open LIBS:Warp3D.library\n");	return FALSE;};

	screen 	= LockPubScreen("Workbench") ;
	screenlarge	=screen->Width; 	screenhigh	=screen->Height;
	ModeID = GetVPModeID(&screen->ViewPort); 
	UnlockPubScreen(NULL, screen);

	window = OpenWindowTags(NULL,
	WA_Activate,	TRUE,
	WA_Width,		LARGE,
	WA_Height,		HIGH,
	WA_Left,		(screenlarge - LARGE)/2,
	WA_Top,		(screenhigh  -  HIGH)/2,
	WA_Title,		(ULONG)progname,
	WA_DragBar,		TRUE,
	WA_CloseGadget,	TRUE,
	WA_GimmeZeroZero,	TRUE,
	WA_Backdrop,	FALSE,
	WA_Borderless,	FALSE,
	WA_IDCMP,		IDCMPs,
	WA_Flags,		Flags,
	TAG_DONE);

	if (window==NULL)
		{printf("Cant open window\n");return FALSE;}

	InitRastPort( &bufferrastport );				/* allocate an other bitmap/rastport four double buffering */
	ScreenBits  = GetBitMapAttr( window->WScreen->RastPort.BitMap, BMA_DEPTH );
	flags = BMF_DISPLAYABLE|BMF_MINPLANES;
	bufferrastport.BitMap = AllocBitMap(LARGE,HIGH,ScreenBits, flags, window->RPort->BitMap);
	if(bufferrastport.BitMap==NULL)
		{printf("No Bitmap\n");return FALSE;}

	bm=bufferrastport.BitMap;				/* draw in this back-buffer */

	if(DoContextCheckWarp3D()==FALSE)
		{printf("Cant Check Warp3D\n",result);return(FALSE);}

	result=W3D_AllocZBuffer(context);
	if(result!=W3D_SUCCESS)
		{printf("Cant create zbuffer! (error %ld)\n",result);return(FALSE);}
	return(TRUE);
}
/*=================================================================*/
void CloseWarp3D(void)
{
	if (tex1)				W3D_FreeTexObj(context, tex1);
	if (picture1)			free(picture1);
	if (context)			W3D_DestroyContext(context);
	if (bufferrastport.BitMap)	FreeBitMap(bufferrastport.BitMap);
	if (window)				CloseWindow(window);
	if (Warp3DBase)			CloseLibrary(Warp3DBase);
	if (Obj.indices)			free(Obj.indices);
}
/*================================================================================*/
void WindowEvents(void)
{							/* manage the window  */
struct IntuiMessage *imsg;

	while( imsg = (struct IntuiMessage *)GetMsg(window->UserPort))
	{
	if (imsg == NULL) break;
	switch (imsg->Class)
		{
		case IDCMP_CLOSEWINDOW:
			closed=TRUE;				break;
		case IDCMP_VANILLAKEY:
			switch(imsg->Code)
			{
			case 'f':	showfps=!showfps;		break;
			case 'o':	optimroty=!optimroty;	break;

			case 'z':	zbuffer=!zbuffer;		break;
			case '1': 	zmode=W3D_Z_NEVER; 	break;
			case '2': 	zmode=W3D_Z_LESS; 	break;
			case '3': 	zmode=W3D_Z_GEQUAL; 	break;
			case '4': 	zmode=W3D_Z_LEQUAL; 	break;
			case '5': 	zmode=W3D_Z_GREATER; 	break;
			case '6': 	zmode=W3D_Z_NOTEQUAL; 	break;
			case '7': 	zmode=W3D_Z_EQUAL; 	break;
			case '8': 	zmode=W3D_Z_ALWAYS; 	break;
			case 'u':	zupdate=!zupdate;		break;
			case 't':	tridraw=!tridraw;		break;
			case 'c':	colored=!colored;		break;
			case 'h':	hideface=!hideface;	break;
			case 'r':	rotate=!rotate;		break;
			case 27:	closed=TRUE;		break;
			default:					break;
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
void SetStatesWarp3D(void)
{
	W3D_SetState(context, W3D_BLENDING,		W3D_DISABLE);	/* non transparent */
	W3D_SetState(context, W3D_GOURAUD,		W3D_DISABLE);	/* non shaded */
	W3D_SetState(context, W3D_PERSPECTIVE,	W3D_DISABLE);	/* not needed here */

	W3D_SetState(context, W3D_TEXMAPPING,	W3D_ENABLE);	/* use textures */
	W3D_SetState(context, W3D_ZBUFFER,		W3D_ENABLE);
	W3D_SetState(context, W3D_ZBUFFERUPDATE,	W3D_ENABLE);
	W3D_SetZCompareMode(context,zmode);					/* use zbuffer = remove hidden pixels */
	W3D_SetState(context, W3D_SCISSOR,		W3D_ENABLE);	/* clip to screen size */
	W3D_SetFrontFace(context,W3D_CCW);
	W3D_SetState(context, W3D_CULLFACE,		W3D_ENABLE);	/* remove hidden faces */

	W3D_SetState(context, W3D_GOURAUD,		W3D_ENABLE);	/* patch: gouraud is needed on some hardware */

	if(!hideface)
		W3D_SetState(context,W3D_CULLFACE,		W3D_DISABLE);
	if(!zbuffer)
		W3D_SetState(context, W3D_ZBUFFER,		W3D_DISABLE);
	if(!zupdate)
		W3D_SetState(context, W3D_ZBUFFERUPDATE,	W3D_DISABLE);
	if(!colored)
		W3D_SetState(context, W3D_TEXMAPPING,	W3D_DISABLE);	
}
/*=================================================================*/
int main(int argc, char *argv[])
{
	FpsText[0]=zname[0]=0;
	if(!StartWarp3D())
		goto panic;

	if(!LoadTextureWarp3D(TEXNAME,TEXSIZE,24))		/* texture datas as R8 G8 B8 */
		goto panic;
	LoadObject(&Obj);

	while(!closed)
	{
		SetStatesWarp3D();
		if(rotate)
		{
		memcpy(Obj.P2,Obj.P,Obj.Pnb*sizeof(struct point3D));	/* copy the object's points to P2*/
		SetMry(ViewMatrix,RotY);					/* do a y rotation matrix */
		if(optimroty)
			YrotateP(ViewMatrix,Obj.P2,Obj.Pnb);		/* only y-rotate the object's points in P2*/
		else
			TransformP(ViewMatrix,Obj.P2,Obj.Pnb);		/* fully transform the object's points in P2*/
		ProjectP(Obj.P2,Obj.Pnb);					/* project points to screen */
		}
		DrawObjectWarp3D(&Obj,tex1);					/* draw with warp3d */
		DrawZtests();
		SwitchDisplayWarp3D();						/* copy to window */
		WindowEvents();							/* is window closed ? */
		if(showfps) DoFPS(); 						/* count the average "frames per second" */
		RotY=RotY+SPEED;							/* rotate */
	}
panic:
	CloseWarp3D();
	return 0;
}
/*=================================================================*/
