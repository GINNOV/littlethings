/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: clip.c,v 1.2.1.3 1994/12/09 05:29:56 jason Exp $

$Log: clip.c,v $
 * Revision 1.2.1.3  1994/12/09  05:29:56  jason
 * added copyright
 *
 * Revision 1.2.1.2  1994/11/16  06:23:56  jason
 * separate calls to activate/deactivate clipping for specific windows
 *
 * Revision 1.2.1.1  1994/09/13  03:47:14  jason
 * debugged and tested
 *
 * Revision 1.2  1994/08/24  04:19:39  jason
 * original revision
 *

******************************************************************************/


#ifndef NOT_EXTERN
#include"agl.h"
#endif


short ClipLimits[MAX_WINDOWS][4];


/******************************************************************************
void	scrmask(Screencoord left,Screencoord right,
											Screencoord bottom,Screencoord top)

******************************************************************************/
/*PROTOTYPE*/
void scrmask(Screencoord left,Screencoord right,Screencoord bottom,Screencoord top)
	{
	ClipLimits[CurrentWid][0]=left;
	ClipLimits[CurrentWid][1]=right;
	ClipLimits[CurrentWid][2]=top;
	ClipLimits[CurrentWid][3]=bottom;

	if(!Bordered[CurrentWid] && left==0 && right==CurrentWidth-1 && bottom==0 && top==CurrentHeight-1)
		Clipped[CurrentWid]=FALSE;
	else
		Clipped[CurrentWid]=TRUE;

	activate_clipping(CurrentWid);
	}



/******************************************************************************
void	getscrmask(Screencoord *left,Screencoord *right,
										Screencoord *bottom,Screencoord *top)

******************************************************************************/
/*PROTOTYPE*/
void getscrmask(Screencoord *left,Screencoord *right,Screencoord *bottom,Screencoord *top)
	{
	*left=		ClipLimits[CurrentWid][0];
	*right=		ClipLimits[CurrentWid][1];
	*top=		ClipLimits[CurrentWid][2];
	*bottom=	ClipLimits[CurrentWid][3];
	}


/******************************************************************************
void	activate_clipping(long wid)

	activates clipping in current window
******************************************************************************/
/*PROTOTYPE*/
void activate_clipping(long wid)
	{
	struct Region *old_region;

	Screencoord left,right,bottom,top;

	long y1,y2;

	if(Clipped[wid])
		{
		getscrmask(&left,&right,&bottom,&top);

		y1=CurrentHeight-top-1;
		y2=CurrentHeight-bottom-1;

		if(Bordered[wid])
			{
			left+=BorderWidth;
			right+=BorderWidth;

			y1+=BorderWidth+BorderHeight;
			y2+=BorderWidth+BorderHeight;
			}

		if( (old_region=clip_window(GLWindow[wid],(long)left,y1,(long)right,y2)) != NULL )
			DisposeRegion(old_region);
		}
	else
		unclip_window(GLWindow[wid]);
	}


/******************************************************************************
void	deactivate_clipping(long wid)

	activates clipping in current window
******************************************************************************/
/*PROTOTYPE*/
void deactivate_clipping(long wid)
	{
	unclip_window(GLWindow[wid]);
	}


/******************************************************************************
void	unclip_window(struct Window *window)

	install NULL region
	dispose of old region, if one existed

******************************************************************************/
/*PROTOTYPE*/
void unclip_window(struct Window *window)
	{
	struct Region *old_region;

	if( (old_region=InstallClipRegion(window->WLayer,NULL)) != NULL )
		DisposeRegion(old_region);
	}


/******************************************************************************
struct Region *clip_window(struct Window *window,
									long minx,long miny,long maxx,long maxy)

	clip window to given bounds
	return old region, if one existed

******************************************************************************/
/*PROTOTYPE*/
struct Region *clip_window(struct Window *window,long minx,long miny,long maxx,long maxy)
	{
	struct Region *new_region;
	struct Rectangle rectangle;

	rectangle.MinX=minx;
	rectangle.MinY=miny;
	rectangle.MaxX=maxx;
	rectangle.MaxY=maxy;

	if( (new_region=NewRegion()) != NULL )
		{
		if( OrRectRegion(new_region,&rectangle) == FALSE )
			{
			printf("Error setting clipping region\n");

			DisposeRegion(new_region);
			new_region=NULL;
			}
		}
	else
		printf("Error creating clipping region\n");

	return(InstallClipRegion(window->WLayer,new_region));
	}
