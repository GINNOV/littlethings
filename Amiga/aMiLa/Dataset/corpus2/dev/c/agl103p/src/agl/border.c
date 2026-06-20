/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: border.c,v 1.2.1.2 1994/12/09 05:29:56 jason Exp $

$Log: border.c,v $
 * Revision 1.2.1.2  1994/12/09  05:29:56  jason
 * border buttons with feedback
 *
 * Revision 1.2.1.1  1994/11/16  07:08:31  jason
 * forced update
 *
 * Revision 1.2  1994/11/16  06:21:14  jason
 * complete Motif style borders
 *
 * Revision 1.1  1994/10/28  04:14:08  jason
 * Initial revision
 *

******************************************************************************/


#ifndef NOT_EXTERN
#include"agl.h"
#endif


/******************************************************************************
void	drawborder(long id,long button)

	if id<0, draw all window borders

	button:
		0 = none
		1 = menu button pressed
		2 = title pressed
		3 = minimize pressed
		4 = maximize pressed

******************************************************************************/
/*PROTOTYPE*/
void drawborder(long id,long button)
	{
	long x,y,lenx,leny;
	long w,h;
	long ledge;
	long wid,old_wid;
	long m;
	long a,b,c;
	long midcolor;
	long darkcolor=DARKGREY;
	long start,end;

	old_wid=CurrentWid;

	if(id<0)
		{
		start=0;
		end=MAX_WINDOWS;
		}
	else
		{
		start=id;
		end=id+1;
		}

	for(wid=start;wid<end;wid++)
		if(GLWindow[wid] && Bordered[wid])
			{
			winset(wid);

			if(GLFocus==wid)
				midcolor=LAVENDER;
			else
				midcolor=LIGHTGREY;

			w=BorderWidth;
			h=BorderHeight;

			ledge= BorderWidth>5? 2: 1;

			get_dimensions(wid,TRUE,&x,&y,&lenx,&leny);

			deactivate_clipping(wid);

			/* clear title bar */
			agl_box(wid,midcolor,midcolor,		w,w,lenx-w-1,w+h-1,TRUE,FALSE);

#if TRUE
			/* title text */
			agl_text(wid,BLACK,					w+h+2,w+h-3,TitleList[wid]);

			/* title box */
			agl_box(wid,WHITE,darkcolor,		w+h,w,lenx-w-2*h-1,w+h-2,FALSE,button==2);

			/* re-cover min/max area */
			agl_box(wid,midcolor,midcolor,		lenx-w-2*h,w+1,lenx-w-1,w+h-2,TRUE,FALSE);

			/* options button box */
			agl_box(wid,WHITE,darkcolor,		w,w,w+h-1,w+h-2,FALSE,button==1);

			/* minimize button box */
			agl_box(wid,WHITE,darkcolor,		lenx-w-2*h,w,lenx-w-h-1,w+h-2,FALSE,button==3);

			/* maximize button box */
			agl_box(wid,WHITE,darkcolor,		lenx-w-h,w,lenx-w-2,w+h-2,FALSE,button==4);

#else
			agl_box(wid,WHITE,darkcolor,		w,w,lenx-w-1,w+h-1,FALSE,FALSE);

			/* title text */
			agl_text(wid,BLACK,					w+h+2,w+h-3,TitleList[wid]);

			/* re-cover min/max area */
			agl_box(wid,midcolor,midcolor,		lenx-w-2*h-1,w+1,lenx-w-1,w+h-1,TRUE,FALSE);

			/* options button divider */
			a=w+h-1;
			b=w+1;
			c=w+h-2;
			line3d(wid,darkcolor,WHITE,			a,b,c,TRUE,FALSE);

			/* maximize button divider */
			a=lenx-w-h-1;
			line3d(wid,darkcolor,WHITE,			a,b,c,TRUE,FALSE);

			/* minimize button divider */
			a=lenx-w-2*h-1;
			line3d(wid,darkcolor,WHITE,			a,b,c,TRUE,FALSE);
#endif

			/* options logo */
			a=w+h/2+1;
			b=w+h/2;
			agl_box(wid,midcolor,BLACK,			a-2,b-1,a+2,b+1,FALSE,FALSE);
			a--;
			b--;
			agl_box(wid,BLACK,BLACK,			a-2,b-1,a+2,b+1,FALSE,FALSE);

			/* maximize logo */
			a=lenx-w-h/2-1;
			b++;
			agl_box(wid,midcolor,BLACK,			a-2,b-2,a+2,b+2,FALSE,FALSE);
			a--;
			b--;
			agl_box(wid,BLACK,BLACK,			a-2,b-2,a+2,b+2,FALSE,FALSE);

			/* minimize logo */
			a=lenx-w-h*3/2;
			b++;
			agl_box(wid,midcolor,BLACK,			a-1,b-1,a+1,b+1,FALSE,FALSE);
			a--;
			b--;
			agl_box(wid,BLACK,BLACK,			a-1,b-1,a+1,b+1,FALSE,FALSE);

			/* edges */
			for(m=0;m<ledge;m++)
				{
				agl_box(wid,WHITE,darkcolor,	m,m,lenx-1-m,leny-1-m,FALSE,FALSE);
				agl_box(wid,darkcolor,WHITE,	w-1-m,w-1-m,lenx-w+m,leny-w+m,FALSE,FALSE);
				}

			for(m=0;m<w-2*ledge;m++)
				agl_box(wid,midcolor,midcolor,	ledge+m,ledge+m,lenx-1-ledge-m,leny-1-ledge-m,
																						FALSE,FALSE);


			/* sizing dimples */
			if(Sizeable[wid])
				{
				/* left */
				a=1;
				b=w-ledge-1;
				line3d(wid,darkcolor,WHITE,		a,w+h-1,		b,FALSE);
				line3d(wid,darkcolor,WHITE,		a,leny-w-h-1,	b,FALSE);

				/* right */
				a=lenx-w+1;
				b=lenx-2;
				line3d(wid,darkcolor,WHITE,		a,w+h-1,		b,FALSE);
				line3d(wid,darkcolor,WHITE,		a,leny-w-h-1,	b,FALSE);

				/* top */
				a=1;
				b=w-ledge-1;
				line3d(wid,darkcolor,WHITE,		w+h-1,a,		b,TRUE);
				line3d(wid,darkcolor,WHITE,		lenx-w-h-1,a,	b,TRUE);

				/* bottom */
				a=leny-w+1;
				b=leny-2;
				line3d(wid,darkcolor,WHITE,		w+h-1,a,		b,TRUE);
				line3d(wid,darkcolor,WHITE,		lenx-w-h-1,a,	b,TRUE);
				}

			/* black title outline */
			agl_box(wid,BLACK,BLACK,			w-1,w-1,lenx-w-1,w+h-1,FALSE,FALSE);


			activate_clipping(wid);

			}

	winset(old_wid);
	}


/******************************************************************************
void	line3d(long wid,long c1,long c2,long x1,long y1,long xy2,long vertical)

	horizontal or vertical line with 3D effect
	from x1,y1 to x1,xy2 or xy2,y1

	c1 is the top/left color
	c2 is the bottom/right color

******************************************************************************/
/*PROTOTYPE*/
void line3d(long wid,long c1,long c2,long x1,long y1,long xy2,long vertical)
	{
	struct RastPort *rp;

	rp=GLWindow[wid]->RPort;

	/* top/left */
	SetAPen(rp,c1);

	Move(rp,x1,y1);
	if(vertical)
		{
		Draw(rp,x1,xy2);
		x1++;
		}
	else
		{
		Draw(rp,xy2,y1);
		y1++;
		}

	/* bottom/right */
	SetAPen(rp,c2);

	Move(rp,x1,y1);
	if(vertical)
		Draw(rp,x1,xy2);
	else
		Draw(rp,xy2,y1);
	}


/******************************************************************************
void	agl_box(long wid,long c1,long c2,long x1,long y1,long x2,long y2,
														long fill,long inverse)

	for unfilled, c2 specifies different color for right and bottom

	inverse will reverse colors

******************************************************************************/
/*PROTOTYPE*/
void agl_box(long wid,long c1,long c2,long x1,long y1,long x2,long y2,long fill,long inverse)
	{
	struct RastPort *rp;

	rp=GLWindow[wid]->RPort;

	if(inverse)
		SetAPen(rp,c2);
	else
		SetAPen(rp,c1);

	if(fill)
		RectFill(rp,x1,y1,x2,y2);
	else
		{
		Move(rp,x2,y1);
		Draw(rp,x1,y1);
		Draw(rp,x1,y2);

		if(c1!=c2)
			{
			if(inverse)
				SetAPen(rp,c1);
			else
				SetAPen(rp,c2);
			}

		Draw(rp,x2,y2);
		Draw(rp,x2,y1);
		}
	}


/******************************************************************************
void	agl_test(long wid,long c,long x,long y,char *string)

******************************************************************************/
/*PROTOTYPE*/
void agl_text(long wid,long c,long x,long y,char *string)
	{
	struct RastPort *rp;

	rp=GLWindow[wid]->RPort;

	SetAPen(rp,c);

	Move(rp,x,y);
	Text(rp,string,(ULONG)strlen(string));
	}
