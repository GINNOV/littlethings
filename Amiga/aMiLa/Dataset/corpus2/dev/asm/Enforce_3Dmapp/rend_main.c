#include "rend_main.h"
#include "shared.h"
#include "gfx_main.h"
#include "sys_main.h"
#include "rend_surfcache.h"
#include "rend_hw.h"
#include "game.h"
#include "mathlib.h"
#include "scr_api.h"

#include <math.h>


/*----------------------------------------------------------------------*/
/* 				Buffers																	*/
/*----------------------------------------------------------------------*/
ushort 		*OutputRows[MAX_HEIGHT];
int			OutputWidth;
ushort		*OutputPtr;

Span_t 		Spans[MAX_SPANS];
Span_t 		*FreeSpans;
Span_t 		YSpans[MAX_HEIGHT];

Point3D_t 	Points[MAX_POINTS];
Point3D_t 	*FreePoints;

SurfSpan_t	SurfSpans[MAX_SURFSPANS];
SurfSpan_t	*FreeSurfSpans;
SurfSpan_t	*LastSurfSpan;


/*----------------------------------------------------------------------*/
/* 				Statistics																*/
/*----------------------------------------------------------------------*/
int DrawnModels;
int DrawnFaces;
int DrawnEdges;
int DrawnSpans;

/*----------------------------------------------------------------------*/
/* 				Global variables														*/
/*----------------------------------------------------------------------*/

int			PBspKey;
Face_t		*PFace;
MTexInfo_t	*PTexInfo;
MNode_t		*PTopNode;
Point3D_t	*PPoints;
Point3D_t	*PLastPoint;
MMipTex_t	*PMipTex;
MLeaf_t		*PModelLeaf;
int			PMipLevel;
Thing_t		*PThing;
Vector		PTmpBBox[2];
float			Pu,Pv;
float			PMagic[9];
Vector		POffset;
uint			PPolyType;
int			PLight;
float			PMipDist;
MLeaf_t		*PModelLeaf;
BitMap_t		PBitMap;
BitMap_t		PRawBitMap;
int			PMagnify;
ushort		*PColorMap;
ushort		*PTransMap;
uint			DLight;

Vector		MainMatrix[4];
Vector		ViewMatrix[4];
Vector		MViewMatrix[4];
Plane_t		ViewFrustrum[4];
int			ViewAngles[3];

int			ClipX,ClipY;
float			ProjScaleX,ProjScaleY;
float			xcenter,ycenter,xcenter2,ycenter2;
float			ClipScaleX,ClipScaleY;
int			ClampX,ClampY;
float			MipDists[4];
float			*Matrix;
uint			FrameCount,VisFrame;
Map_t			*CurrentMap;
Thing_t		*CurrentThing;
uint			TLight;

Point3D_t	TPoints[1024];
float FloatSinCos[1280];


Vector 	SkyVector[3]={{0,1,0},{-1,0,0},{0,0,40}};

/*-----------------------------------------------------------------------*/
void TransformFace()
{
Vector	tmp[3];
float		*vec,*mat=PMagic;
float		ut,vt,xc,yc,scale;
float		x,y,z;
float		*pmatrix;

	pmatrix=Matrix;

	if(!(PPolyType&FF_SKY))
	{
		TransVector(tmp[1],PFace->M,pmatrix);
		TransVector(tmp[2],PFace->N,pmatrix);
		TransPointRaw(tmp[0],PFace->P,pmatrix);
	}
	else
	{
		TransVector(tmp[1],SkyVector[0],pmatrix);
		TransVector(tmp[2],SkyVector[1],pmatrix);
		TransVector(tmp[0],SkyVector[2],pmatrix);
	}

	vec=(float *)tmp;

	ut=Pu-PTexInfo->Soff;
	vt=Pv-PTexInfo->Toff;

	x=vec[3]*ut+vec[6]*vt+vec[0];
	y=vec[4]*ut+vec[7]*vt+vec[1];
	z=vec[5]*ut+vec[8]*vt+vec[2];

	mat[0]=vec[7]*x-vec[6]*y;
	mat[1]=vec[8]*y-vec[7]*z;
	mat[2]=vec[8]*x-vec[6]*z;
	mat[3]=vec[3]*y-vec[4]*x;
	mat[4]=vec[4]*z-vec[5]*y;
	mat[5]=vec[3]*z-vec[5]*x;
	mat[6]=vec[6]*vec[4]-vec[7]*vec[3];
	mat[7]=vec[7]*vec[5]-vec[8]*vec[4];
	mat[8]=vec[6]*vec[5]-vec[8]*vec[3];

	xc=xcenter;
	yc=ycenter;

	scale=1.0/(1<<PMipLevel);
	scale*=(PMagnify+1);

	mat[0]=(mat[0]-(mat[2]*yc+mat[1]*xc))*scale;
	mat[1]*=scale;
	mat[2]*=scale;
	mat[3]=(mat[3]-(mat[5]*yc+mat[4]*xc))*scale;
	mat[4]*=scale;
	mat[5]*=scale;
	mat[6]=mat[6]-(mat[8]*yc+mat[7]*xc);
}

/*-----------------------------------------------------------------------*/
void TransVector(Vector v1,Vector v2,float *mat)
{
	v1[0]=v2[0]*mat[3]+v2[1]*mat[4]+v2[2]*mat[5];
	v1[1]=v2[0]*mat[6]+v2[1]*mat[7]+v2[2]*mat[8];
	v1[2]=v2[0]*mat[0]+v2[1]*mat[1]+v2[2]*mat[2];
}

/*-----------------------------------------------------------------------*/
void TransPointRaw(Vector v1,Vector v2,float *mat)
{
float x,y,z;

	x=v2[0]-mat[9];
	y=v2[1]-mat[10];
	z=v2[2]-mat[11];

	v1[0]=x*mat[3]+y*mat[4]+z*mat[5];
	v1[1]=x*mat[6]+y*mat[7]+z*mat[8];
	v1[2]=x*mat[0]+y*mat[1]+z*mat[2];
}

/*-----------------------------------------------------------------------*/
ubyte TransPoint(Point3D *p,Vector vec,float *mat)
{
float x,y,z,fx,fy,iz;
ubyte	cc;

	x=vec[0]-mat[9];
	y=vec[1]-mat[10];
	z=vec[2]-mat[11];

	p->Pos[0]=x*mat[3]+y*mat[4]+z*mat[5];
	p->Pos[1]=x*mat[6]+y*mat[7]+z*mat[8];
	p->Pos[2]=x*mat[0]+y*mat[1]+z*mat[2];

	x=p->Pos[0];
	y=p->Pos[1];
	z=p->Pos[2];

	cc=CC_BEHIND;

	if(z>0.1)
	{
		iz=65536.0/z;

		fx=x*iz+xcenter2;
		fy=-y*iz+ycenter2;

		p->Fx=fx;
		p->Sx=(int)fx;

		p->Fy=fy;
		p->Sy=(int)fy;

		cc=0;
	}

	if(z>16)
	{
		int x,y;

		x=p->Sx;
		y=p->Sy;

		if(x<0)
			cc=CC_OFF_LEFT;
		else
			if(x>ClipX)
				cc=CC_OFF_RIGHT;

		if(y<0)
			cc|=CC_OFF_TOP;
		else
			if(y>ClipY)
				cc|=CC_OFF_BOT;
	}
	else
	{
		x*=ClipScaleX;
		y*=ClipScaleY;

		iz=-z;

		if(x<iz)
			cc|=CC_OFF_LEFT;

		if(x>z)
			cc|=CC_OFF_RIGHT;

		if(y>z)
			cc|=CC_OFF_TOP;

		if(y<iz)
			cc|=CC_OFF_BOT;
	}

	p->CCodes=cc;

	return cc;
}

/*-----------------------------------------------------------------------*/
int BBoxInsidePlane(float *bbox,Plane_t *pl)
{
float x,y,z;

	if(pl->Norm[0]<0)
		x=bbox[0];
	else
		x=bbox[3];

	if(pl->Norm[1]<0)
		y=bbox[1];
	else
		y=bbox[4];

	if(pl->Norm[2]<0)
		z=bbox[2];
	else
		z=bbox[5];

	return ((pl->Norm[0]*x+pl->Norm[1]*y+pl->Norm[2]*z)<pl->Dist)?0:1;
}

/*-----------------------------------------------------------------------*/
int BBoxOnPlane(float *bbox,Plane_t *pl)
{
float d1,d2,*p;
int t;

	t=pl->Type;

	if(t<0)
	{
		p=(float *)((char *)bbox+(t&0xff));
		d2=p[0];
		d1=p[3];
	}
	else
	{
		float x1,y1,z1,x2,y2,z2;

		if(pl->Norm[0]<0)
		{
			x1=bbox[0];
			x2=bbox[3];
		}
		else
		{
			x1=bbox[3];
			x2=bbox[0];
		}

		if(pl->Norm[1]<0)
		{
			y1=bbox[1];
			y2=bbox[4];
		}
		else
		{
			y1=bbox[4];
			y2=bbox[1];
		}

		if(pl->Norm[2]<0)
		{
			z1=bbox[2];
			z2=bbox[5];
		}
		else
		{
			z1=bbox[5];
			z2=bbox[2];
		}

		d1=pl->Norm[0]*x1+pl->Norm[1]*y1+pl->Norm[2]*z1;
		d2=pl->Norm[0]*x2+pl->Norm[1]*y2+pl->Norm[2]*z2;
	}

	if(d1<pl->Dist)
		t=0;
	else
		t=1;

	if(d2<pl->Dist)
		t|=2;

	return t;
}

/*-----------------------------------------------------------------------*/
void InitSpans()
{
WORD		i;
Span_t	*nl=NULL;
Span_t	*sp;

//InitSurfSpans
	FreeSurfSpans=SurfSpans;

//InitSpans
	i=WindowHeight;
	sp=YSpans;

	while (--i>=0)
		sp++->Next=nl;
}

/*-----------------------------------------------------------------------*/
void InitEngine(int flags,int depth)
{
Span_t 	*sp;
Point3D	*po;
int n;
float inc,ang;
float *sc;



	FreeSpans=sp=Spans;

	for(n=0;n<(MAX_SPANS-1);n++)
	{
		sp->NextSurf=(sp+1);
		sp++;
	}
	sp->NextSurf=NULL;

	FreePoints=po=Points;

	for(n=0;n<(MAX_POINTS-1);n++)
	{
		po->Next=(po+1);
		po++;
	}
	po->Next=NULL;

	LastSurfSpan=&SurfSpans[MAX_SURFSPANS-1];

	Lights[0].Intensity=255;

	ang=0;
	inc=(3.14159265*2)/1024;
	sc=FloatSinCos;

	for(n=0;n<1280;n++)
	{
		*sc++=sin(ang);
		ang+=inc;
	}

}

