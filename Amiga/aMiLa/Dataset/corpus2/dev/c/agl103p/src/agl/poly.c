/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: poly.c,v 1.2.1.5 1994/12/09 05:29:56 jason Exp $

$Log: poly.c,v $
 * Revision 1.2.1.5  1994/12/09  05:29:56  jason
 * uses global screen settings instead of structure
 *
 * Revision 1.2.1.4  1994/11/16  06:25:54  jason
 * adjust for borders
 *
 * Revision 1.2.1.3  1994/09/13  03:51:13  jason
 * PolyDraw() test
 *
 * Revision 1.2.1.2  1994/04/06  02:41:16  jason
 * Back to rectangular clear
 *
 * Revision 1.2.1.1  1994/03/29  05:41:32  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:04:19  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:00:51  jason
 * RCS/agl.h,v
 *

******************************************************************************/


#ifndef NOT_EXTERN
#include"agl.h"
#endif

#define POLYLINE		FALSE	/* use PolyDraw() instead of Move(), Draw() */
#define MAX_LINE_VERTS	512		/* max # of lines vertices (2 times max lines) */

short LineBuffer[MAX_LINE_VERTS];


/******************************************************************************
void	recti(long x1,long y1,long x2,long y2)

******************************************************************************/
/*PROTOTYPE*/
void recti(long x1,long y1,long x2,long y2)
	{
	bgnline();
	rectvert((float)x1,(float)y1,(float)x2,(float)y2,TRUE);
	endline();
	}


/******************************************************************************
void	rectfi(long x1,long y1,long x2,long y2)

******************************************************************************/
/*PROTOTYPE*/
void rectfi(long x1,long y1,long x2,long y2)
	{
	if(OneToOne[CurrentWid])	/* bypass transforms if no effect */
		{
		y1=CurrentHeight-y1-1;
		y2=CurrentHeight-y2-1;

		RectFill(DrawRPort,x1,y2,x2,y1);
		return;
		}

	bgnpolygon();
	rectvert((float)x1,(float)y1,(float)x2,(float)y2,FALSE);
	endpolygon();
	}


/******************************************************************************
void	rects(short x1,short y1,short x2,short y2)

******************************************************************************/
/*PROTOTYPE*/
void rects(short x1,short y1,short x2,short y2)
	{
	bgnline();
	rectvert((float)x1,(float)y1,(float)x2,(float)y2,TRUE);
	endline();
	}


/******************************************************************************
void	rectfs(short x1,short y1,short x2,short y2)

******************************************************************************/
/*PROTOTYPE*/
void rectfs(short x1,short y1,short x2,short y2)
	{
	bgnpolygon();
	rectvert((float)x1,(float)y1,(float)x2,(float)y2,FALSE);
	endpolygon();
	}


/******************************************************************************
void	rect(float x1,float y1,float x2,float y2)

******************************************************************************/
/*PROTOTYPE*/
void rect(float x1,float y1,float x2,float y2)
	{
	bgnline();
	rectvert(x1,y1,x2,y2,TRUE);
	endline();
	}


/******************************************************************************
void	rectf(float x1,float y1,float x2,float y2)

******************************************************************************/
/*PROTOTYPE*/
void rectf(float x1,float y1,float x2,float y2)
	{
	bgnpolygon();
	rectvert(x1,y1,x2,y2,FALSE);
	endpolygon();
	}


/******************************************************************************
void	rectvert(float x1,float y1,float x2,float y2,long line)

******************************************************************************/
/*PROTOTYPE*/
void rectvert(float x1,float y1,float x2,float y2,long line)
	{
	static float vert[4][2];
	short n;

	vert[0][0]=x1;
	vert[0][1]=y1;
	vert[1][0]=x2;
	vert[1][1]=y1;
	vert[2][0]=x2;
	vert[2][1]=y2;
	vert[3][0]=x1;
	vert[3][1]=y2;

	for(n=0;n<4;n++)
		v2f(vert[n]);

	if(line)
		v2f(vert[0]);
	}


/*******************************************************************************
void	bgnpoint(void)

*******************************************************************************/
/*PROTOTYPE*/
void bgnpoint(void)
	{
	if(DrawType)
		GL_error("bgnpoint(): bad command order");

	DrawType=GL_POINT;
	}


/*******************************************************************************
void	endpoint(void)

*******************************************************************************/
/*PROTOTYPE*/
void endpoint(void)
	{
	if(DrawType!=GL_POINT)
		GL_error("endpoint(): bad command order");

	DrawType=FALSE;
	}


/*******************************************************************************
void	bgnline(void)

*******************************************************************************/
/*PROTOTYPE*/
void bgnline(void)
	{
	if(DrawType)
		GL_error("bgnline(): bad command order");

	DrawType=GL_LINE;
	BgnLine=TRUE;
	Verts=0;
	}


/*******************************************************************************
void	endline(void)

*******************************************************************************/
/*PROTOTYPE*/
void endline(void)
	{
	if(DrawType!=GL_LINE)
		GL_error("endline(): bad command order");

#if POLYLINE

	else
		PolyDraw(DrawRPort,Verts/2,LineBuffer);

#endif

	DrawType=FALSE;
	}


/*******************************************************************************
void	bgnpolygon(void)

*******************************************************************************/
/*PROTOTYPE*/
void bgnpolygon(void)
	{
	if(DrawType)
		GL_error("bgnpolygon(): bad command order");

	DrawType=GL_POLYGON;
	Verts=0;
	}


/*******************************************************************************
void	endpolygon(void)

*******************************************************************************/
/*PROTOTYPE*/
void endpolygon(void)
	{
	if(DrawType!=GL_POLYGON)
		GL_error("endpolygon(): bad command order");

	AreaEnd(DrawRPort);

	DrawType=FALSE;
	}


/*******************************************************************************
void	render_vertex(short vert[2])

*******************************************************************************/
/*PROTOTYPE*/
void render_vertex(short vert[2])
	{
	long x,y;

	x=vert[0];
	y=CurrentHeight-vert[1]-1;

	if(Bordered[CurrentWid])
		{
		x+=BorderWidth;
		y+=BorderWidth+BorderHeight;
		}

	switch(DrawType)
		{
		case FALSE:
			GL_error("v??(): bad command order");
			break;

		case GL_POINT:
			WritePixel(DrawRPort,x,y);
			break;

		case GL_LINE:
#if POLYLINE
			if(Verts==MAX_LINE_VERTS)
				GL_error("Exceeded max points in polyline");
			else
				{
				LineBuffer[Verts++]=x;
				LineBuffer[Verts++]=y;
				}
#else
			if(BgnLine)
				{
				BgnLine=FALSE;
				Move(DrawRPort,x,y);
				}
			else
				Draw(DrawRPort,x,y);
#endif
			break;

		case GL_POLYGON:
			if(Verts==MAX_POLY_VERTS)
				GL_error("Exceeded max points in polygon");
			else
				{
				if(Verts)
					AreaDraw(DrawRPort,x,y);
				else
					AreaMove(DrawRPort,x,y);

				Verts++;
				}
			break;
		}
	}


/******************************************************************************
void	mapcolor(long m,long r,long g,long b)

	maintain 256 shade standard
******************************************************************************/
/*PROTOTYPE*/
void mapcolor(long m,long r,long g,long b)
	{
	char string[100];

	if(m<0 || m>15)
		{
		sprintf(string,"mapcolor(): bad index %d",m);
		GL_error(string);
		return;
		}

	r=(r+7)/16;
	g=(g+7)/16;
	b=(b+7)/16;

	ColorMap[m]= (((r<<4)+g)<<4)+b;
	SetRGB4(GLView,m,r,g,b);
	}


/******************************************************************************
void	getmcolor(long m,long *r,long *g,long *b)

******************************************************************************/
/*PROTOTYPE*/
void getmcolor(long m,long *r,long *g,long *b)
	{
	*r=ColorMap[m];

	*b= *r&15;
	*r= *r>>4;
	*g= *r&15;
	*r= *r>>4;

	*r *=16;
	*g *=16;
	*b *=16;
	}


/*******************************************************************************
void	color(long c)

*******************************************************************************/
/*PROTOTYPE*/
void color(long c)
	{
	CurrentColor=c;
	SetAPen(DrawRPort,c);
	}


/*******************************************************************************
long	getcolor(void)

*******************************************************************************/
/*PROTOTYPE*/
long getcolor(void)
	{
	return CurrentColor;
	}


/*******************************************************************************
void	clear(void)

*******************************************************************************/
/*PROTOTYPE*/
void clear(void)
	{
	long bit,value;
	long m,line,screenwidth,offset,lineoff;
	size_t linewidth;
	PLANEPTR planes,planem;

	/* only activate one of the following three methods */


#if FALSE

	/* clear window */
	RectFill(DrawRPort,0,0,CurrentWidth-1,CurrentHeight-1);

#endif


#if TRUE

	/* clear whole screen (clipped to window) */
	SetRast(DrawRPort,CurrentColor);

#endif


#if FALSE
	size=ScreenWidth*ScreenHeight/8;

	/* individually clear each full plane */
	for(m=0;m<ScreenDeep;m++)
		memset(DrawRPort->BitMap->Planes[m],2<<m,size);

#endif


#if FALSE

	screenwidth=ScreenWidth/8+1;
	offset=screenwidth*(ScreenHeight-CurrentPosY-CurrentHeight-1)+CurrentPosX/8;
	linewidth=(CurrentWidth+7)/8+1;
	bit=1;

	if(offset)
		{
		offset--;
		linewidth++;
		}

	/* individually clear area in each plane */
	for(m=0;m<ScreenDeep;m++)
		{
		if(CurrentColor&bit)
			value=255;
		else
			value=0;

		lineoff=offset;
		planem= (DrawRPort->BitMap->Planes[m]);

		for(line=0;line<CurrentHeight;line++)
			{
			memset(&(planem[lineoff]),value,linewidth);

			lineoff+=screenwidth;
			}

		bit<<=1;
		}

/*
		BltClear((DrawRPort->BitMap->Planes[m])+offset,size,0);
*/

#endif
	}
