#include "sys_main.h"
#include "shared.h"
#include "rend_main.h"
#include "main.h"
#include "scr_api.h"
#include "mathlib.h"
#include "rend_surfcache.h"

short	scan[MAX_HEIGHT*2];

extern MLeaf_t	*PModelLeaf;
/*-----------------------------------------------------------------------*/
void AddSolidSpans(int y,int ey)
{
short *scp;
Span_t *ysp,*fsp,*nsp,*gsp;

	scp=&scan[y];
	ysp=&YSpans[y];
	fsp=nsp=FreeSpans;

	while(y<ey)
	{
		int sx,ex;

		ex=scp[MAX_HEIGHT];
		sx=*scp;

		if(ex>sx)
		{
			Span_t *sp,*psp;

			psp=ysp;
			sp=psp->Next;

			while(sp)
			{
				int sex,ssx;

				sex=sp->Ex;
				if(sx<sex)
				{
					ssx=sp->Sx;
					if(sx<ssx)
					{
						gsp=nsp;
						nsp=nsp->NextSurf;

						psp->Next=gsp;
						gsp->Next=sp;
						gsp->Y=y;
						gsp->Sx=sx;
						if(ex>ssx)
							gsp->Ex=ssx;
						else
						{
							gsp->Ex=ex;
							goto skipspan;
						}
					}
					if(ex<=sex)
						goto skipspan;

					sx=sex;
				}

				psp=sp;
				sp=sp->Next;
			}

			gsp=nsp;
			nsp=nsp->NextSurf;

			psp->Next=gsp;
			gsp->Next=NULL;
			gsp->Y=y;
			gsp->Sx=sx;
			gsp->Ex=ex;

skipspan:
		}
		scp++;
		ysp++;
		y++;
	}

	if(nsp!=fsp)
	{
		SurfSpan_t *ssp;

		gsp->NextSurf=NULL;
		ssp=FreeSurfSpans;
		ssp->Face=PFace;
		ssp->Parm.MipDist=PMipDist;
		ssp->Thing=PThing;
		ssp->FirstSpan=fsp;
		FreeSurfSpans=ssp+1;
		FreeSpans=nsp;
	}
}

/*-----------------------------------------------------------------------*/
void AddTransparentSpans(int y,int ey)
{
short *scp;
Span_t *ysp,*fsp,*nsp,*gsp;

	scp=&scan[y];
	ysp=&YSpans[y];
	fsp=nsp=FreeSpans;

	while(y<ey)
	{
		int sx,ex;

		ex=scp[MAX_HEIGHT];
		sx=*scp;

		if(ex>sx)
		{
			Span_t *sp,*psp;

			psp=ysp;
			sp=psp->Next;

			while(sp)
			{
				int sex,ssx;

				sex=sp->Ex;
				if(sx<sex)
				{
					ssx=sp->Sx;
					if(sx<ssx)
					{
						gsp=nsp;
						nsp=nsp->NextSurf;

						gsp->Y=y;
						gsp->Sx=sx;
						if(ex>ssx)
							gsp->Ex=ssx;
						else
						{
							gsp->Ex=ex;
							goto skipspan;
						}
					}
					if(ex<=sex)
						goto skipspan;

					sx=sex;
				}

				psp=sp;
				sp=sp->Next;
			}

			gsp=nsp;
			nsp=nsp->NextSurf;

			gsp->Y=y;
			gsp->Sx=sx;
			gsp->Ex=ex;

skipspan:
		}
		scp++;
		ysp++;
		y++;
	}

	if(nsp!=fsp)
	{
		SurfSpan_t *ssp;

		gsp->NextSurf=NULL;
		ssp=FreeSurfSpans;
		ssp->Face=PFace;
		ssp->Parm.MipDist=PMipDist;
		ssp->Thing=PThing;
		ssp->FirstSpan=fsp;
		FreeSurfSpans=ssp+1;
		FreeSpans=nsp;
	}
}

/*-----------------------------------------------------------------------*/
void ClipPoint(float f,Point3D_t *p,Point3D *p1,Point3D_t *p2)
{
float x,y,z,fx,fy,iz;
ubyte	cc;

	x=p2->Pos[0];
	x=((p1->Pos[0]-x)*f)+x;
	y=p2->Pos[1];
	y=((p1->Pos[1]-y)*f)+y;
	z=p2->Pos[2];
	z=((p1->Pos[2]-z)*f)+z;

	p->Pos[0]=x;
	p->Pos[1]=y;
	p->Pos[2]=z;

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

}

/*-----------------------------------------------------------------------*/
int ClipFace(int cc)
{
float scalex,scaley;
Point3D_t	*po=NULL,*fp,*tp;
Point3D_t	tmp;

	scalex=ClipScaleX;
	scaley=ClipScaleY;

	fp=FreePoints;
	tp=&tmp;
	tp->Next=NULL;

	if(cc&CC_OFF_LEFT)
	{
		Point3D_t *p1,*p2,*first;

		po=(Point3D_t *)&PPoints;
		p1=PPoints;
		first=p1;
		PPoints=NULL;

		do
		{
			int c;

			c=p1->CCodes;

			if(c&CC_OFF_LEFT)
			{
				tp->Next=p1;
				tp=p1;
			}
			else
			{
				po->Next=p1;
				po=p1;
			}

			p2=p1->Next;	//second point

			if((c^p2->CCodes)&CC_OFF_LEFT)
			{
				float f;

				f=-(p2->Pos[2]+p2->Pos[0]*scalex)/((p1->Pos[0]-p2->Pos[0])*scalex+p1->Pos[2]-p2->Pos[2]);
				ClipPoint(f,fp,p1,p2);

				po->Next=fp;
				po=fp;

				fp=fp->Next;
			}

			p1=p2;
		} while(first!=p2);

		if(!PPoints) goto Out;

		po->Next=PPoints;		//enclose cycle
	}

	if(cc&CC_OFF_RIGHT)
	{
		Point3D_t *p1,*p2,*first;

		po=(Point3D_t *)&PPoints;
		p1=po->Next;		//a2
		first=p1;
		po->Next=NULL;		//a6

		do
		{
			int c;

			c=p1->CCodes;

			if(c&CC_OFF_RIGHT)
			{
				tp->Next=p1;
				tp=p1;
			}
			else
			{
				po->Next=p1;
				po=p1;
			}

			p2=p1->Next;	//second point

			if((c^p2->CCodes)&CC_OFF_RIGHT)
			{
				float f;

				f=(p2->Pos[2]-p2->Pos[0]*scalex)/((p1->Pos[0]-p2->Pos[0])*scalex-p1->Pos[2]+p2->Pos[2]);
				ClipPoint(f,fp,p1,p2);

				po->Next=fp;
				po=fp;

				fp=fp->Next;
			}
			p1=p2;
		} while(first!=p2);

		if(!PPoints) goto Out;

		po->Next=PPoints;		//enclose cycle
	}

	if(cc&CC_OFF_TOP)
	{
		Point3D_t *p1,*p2,*first;

		po=(Point3D_t *)&PPoints;
		p1=po->Next;		//a2
		first=p1;
		po->Next=NULL;		//a6

		do
		{
			int c;

			c=p1->CCodes;

			if(c&CC_OFF_TOP)
			{
				tp->Next=p1;
				tp=p1;
			}
			else
			{
				po->Next=p1;
				po=p1;
			}

			p2=p1->Next;	//second point

			if((c^p2->CCodes)&CC_OFF_TOP)
			{
				float f;

				f=(p2->Pos[2]-p2->Pos[1]*scaley)/((p1->Pos[1]-p2->Pos[1])*scaley-p1->Pos[2]+p2->Pos[2]);
				ClipPoint(f,fp,p1,p2);

				po->Next=fp;
				po=fp;

				fp=fp->Next;
			}
			p1=p2;
		} while(first!=p2);

		if(!PPoints) goto Out;

		po->Next=PPoints;		//enclose cycle
	}

	if(cc&CC_OFF_BOT)
	{
		Point3D_t *p1,*p2,*first;

		po=(Point3D_t *)&PPoints;
		p1=po->Next;		//a2
		first=p1;
		po->Next=NULL;		//a6

		do
		{
			int c;

			c=p1->CCodes;

			if(c&CC_OFF_BOT)
			{
				tp->Next=p1;
				tp=p1;
			}
			else
			{
				po->Next=p1;
				po=p1;
			}

			p2=p1->Next;	//second point

			if((c^p2->CCodes)&CC_OFF_BOT)
			{
				float f;

				f=-(p2->Pos[2]+p2->Pos[1]*scaley)/((p1->Pos[1]-p2->Pos[1])*scaley+p1->Pos[2]-p2->Pos[2]);
				ClipPoint(f,fp,p1,p2);

				po->Next=fp;
				po=fp;

				fp=fp->Next;
			}
			p1=p2;
		} while(first!=p2);

		if(!PPoints) goto Out;

		po->Next=PPoints;		//enclose cycle
	}

Out:
	PLastPoint=po;


	if(tmp.Next)
	{
		tp->Next=fp;
		fp=tmp.Next;
	}

	FreePoints=fp;

	return (PPoints!=NULL);
}

/*-----------------------------------------------------------------------*/
void ScanFace(int and,int or)
{
Point3D_t *po;
int ifix;
float fix,mf;


	if(!and)
	{
		ifix=65535;
		fix=65536.0;
		mf=65535.0;

		if(or) ClipFace(or);

		if((po=PPoints)!=NULL)
		{
			Point3D_t *np;
			int top,bottom;

			np=po->Next;
			top=po->Sy;
			bottom=po->Sy;

			while(po!=np)
			{
				int y;

				y=np->Sy;

				if(y<top) top=y;
				if(y>bottom) bottom=y;

				np=np->Next;
			}

			top=(top+ifix)>>16;
			bottom=(bottom+ifix)>>16;

			if(top<bottom)
			{
				short *scp;
				Point3D_t *old;
				int y1,y2,off;

				po=PPoints;
				scp=scan;

				while(TRUE)
				{
					int ty1,fy1;

					old=po;
					po=po->Next;
					np=po;

					y1=np->Sy;
					y2=old->Sy;

					if(y1>y2)
					{
						Point3D_t *pt;
						int it;
						//right edge
						it=y1;
						y1=y2;
						y2=it;
						pt=old;
						old=np;
						np=pt;
						off=MAX_HEIGHT;
					}
					else
						//left edge
						off=0;

					ty1=y1+ifix;
					fy1=ty1>>16;

					y2=((y2+ifix)>>16)-fy1;

					if(y2>0)
					{
						float fdx;
						int dx,ex,sh;

						fdx=(old->Fx-np->Fx)/(old->Fy-np->Fy);
						ty1=(ty1&~0xffff)-y1;
						dx=(int)(fdx*fix);
						ex=(int)((np->Fx+fdx*ty1)+mf);

						scp=&scan[off+fy1];
						sh=16;

						do
						{
							*scp=(ex>>sh);
							ex+=dx;
							scp++;
						} while(--y2);

					}
					if(PPoints==po) break;
				}
				if(PThing && PThing->Flags&TFL_TRANSPARENT)
					AddTransparentSpans(top,bottom);
				else
					AddSolidSpans(top,bottom);
			}
		}
	}
}

/*-----------------------------------------------------------------------*/
void DrawSubFace(Point3D_t *po)
{
Point3D_t *fp,*lp;
float *mat;
int and,or;

	and=0xff;
	or=0;
	PPoints=po;
	mat=ViewMatrix[0];
	fp=po;

	do
	{
		int cc;

		cc=TransPoint(po,po->Pos,mat);

		and&=cc;
		or|=cc;
		lp=po;
		po=po->Next;

	} while(fp!=po);

	PLastPoint=lp;

	ScanFace(and,or);

	if(PPoints)
	{
		PLastPoint->Next=FreePoints;
		FreePoints=PPoints;
	}
}


/*-----------------------------------------------------------------------*/
void DrawFaceSw()
{
Face_t *fac;
MSurfEdge_t *se;
int n,and,or;
float *mat,dist;
Point3D_t *po;

	PPoints=NULL;
	DrawnFaces++;

	fac=PFace;
	n=fac->NumEdges;
	se=fac->FirstEdge;

	mat=Matrix;
	dist=(float)(1<<30);

	or=0;
	and=0xff;

	PPoints=po=FreePoints;

	DrawnEdges+=n;

	while(TRUE)
	{
		float *ve,d,x,y,z;
		int cc;

		ve=se->Edge->Vert[se->Type];

		x=ve[0]-mat[9];
		y=ve[1]-mat[10];
		z=ve[2]-mat[11];
		d=x*x+y*y+z*z;
		if(dist>d) dist=d;

		cc=TransPoint(po,ve,mat);
		or|=cc;
		and&=cc;

		se++;
		n--;

		if(n==0) break;

		po=po->Next;
	}

	PMipDist=dist;
	PLastPoint=po;
	FreePoints=po->Next;
	po->Next=PPoints;

	ScanFace(and,or);

	if(PPoints)
	{
		PLastPoint->Next=FreePoints;
		FreePoints=PPoints;
	}
}

/*-----------------------------------------------------------------------*/
