/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: text.c,v 1.2.1.4 1994/12/09 05:29:56 jason Exp $

$Log: text.c,v $
 * Revision 1.2.1.4  1994/12/09  05:29:56  jason
 * added copyright
 *
 * Revision 1.2.1.3  1994/11/16  06:30:09  jason
 * adjust for borders
 *
 * Revision 1.2.1.2  1994/09/13  03:53:06  jason
 * fixed alignment of text
 *
 * Revision 1.2.1.1  1994/03/29  05:41:32  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:04:24  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:00:51  jason
 * RCS/agl.h,v
 *

******************************************************************************/


#ifndef NOT_EXTERN
#include"agl.h"
#endif

long TextX[MAX_WINDOWS],TextY[MAX_WINDOWS];


/******************************************************************************
void	cmov2s(long sx,long sy)

******************************************************************************/
/*PROTOTYPE*/
void cmov2i(long sx,long sy)
	{
	if(OneToOne[CurrentWid])	/* bypass transforms if no effect */
		{
		TextX[CurrentWid]=sx;
		TextY[CurrentWid]=sy;
		}
	else
		cmov((float)sx,(float)sy,(float)0.0);
	}


/******************************************************************************
void	cmovs(long sx,long sy,long sz)

******************************************************************************/
/*PROTOTYPE*/
void cmovi(long sx,long sy,long sz)
	{
	cmov((float)sx,(float)sy,(float)sz);
	}


/******************************************************************************
void	cmov2s(short sx,short sy)

******************************************************************************/
/*PROTOTYPE*/
void cmov2s(short sx,short sy)
	{
	if(OneToOne[CurrentWid])	/* bypass transforms if no effect */
		{
		TextX[CurrentWid]=sx;
		TextY[CurrentWid]=sy;
		}
	else
		cmov((float)sx,(float)sy,(float)0.0);
	}


/******************************************************************************
void	cmovs(short sx,short sy,short sz)

******************************************************************************/
/*PROTOTYPE*/
void cmovs(short sx,short sy,short sz)
	{
	cmov((float)sx,(float)sy,(float)sz);
	}


/******************************************************************************
void	cmov2(float fx,float fy)

******************************************************************************/
/*PROTOTYPE*/
void cmov2(float fx,float fy)
	{
	if(OneToOne[CurrentWid])	/* bypass transforms if no effect */
		{
		TextX[CurrentWid]=fx;
		TextY[CurrentWid]=fy;
		}
	else
		cmov(fx,fy,(float)0.0);
	}


/******************************************************************************
void	cmov(float fx,float fy,float fz)

******************************************************************************/
/*PROTOTYPE*/
void cmov(float fx,float fy,float fz)
	{
	float vert[3],rvert[3],pvert[3];

	vert[0]=fx;
	vert[1]=fy;
	vert[2]=fz;

	rotate_translate_position(vert,rvert);
	project_vertex(rvert,pvert);

/*
	TextX[CurrentWid]=CurrentWidth* (pvert[0]+1.0)/2.0+0.5;
	TextY[CurrentWid]=CurrentHeight*(pvert[1]+1.0)/2.0+0.5;
*/

	TextX[CurrentWid]=ViewPort[CurrentWid][0] + ViewPort[CurrentWid][1] * (pvert[0]+1.0)/2.0;
	TextY[CurrentWid]=ViewPort[CurrentWid][2] + ViewPort[CurrentWid][3] * (pvert[1]+1.0)/2.0;
	}


/******************************************************************************
void	charstr(char *string)

******************************************************************************/
/*PROTOTYPE*/
void charstr(char *string)
	{
	short cx,cy;

	getcpos(&cx,&cy);

	cy=CurrentHeight-1-cy;

	if(Bordered[CurrentWid])
		{
		cx+=BorderWidth;
		cy+=BorderWidth+BorderHeight;
		}

	Move(DrawRPort,cx,cy);
	Text(DrawRPort,string,(ULONG)strlen(string));
	}


/******************************************************************************
void	getcpos(short *cx,short *cy)

******************************************************************************/
/*PROTOTYPE*/
void getcpos(short *cx,short *cy)
	{
	*cx=TextX[CurrentWid];
	*cy=TextY[CurrentWid];
	}
