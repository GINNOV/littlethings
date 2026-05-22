
/*********************************************************************
* This file contains functions to operate on the doors and objects lists.
*********************************************************************/

#include "defines.h"

/*********************************************************************
* void PointInWall(float x,float y)
*********************************************************************/
void PointInWall(float x,float y)
{
float x1,x2,y1,y2;
short i;

	inside=0;
	x1 = x-0.7+100;
	x2 = x+0.7+100;
	y1 = y-0.62+100;
	y2 = y+0.62+100;

	for (i=0;i<numedges;i++)
		if (subpoints[i][0]>x1 && subpoints[i][0]<x2 &&
			subpoints[i][2]>y1 && subpoints[i][2]<y2)
			inside=i;

}

/*********************************************************************
* Called when " " is pressed from main program.
* Call pointinwall to see which door edge you are in front of.
* 	If yourangle=dir_of_edge, then you are facing door
*		else return;
* Go through doors list to find that edge.
* If door is open, return.
* If door is secretdoor
*   Set active bit.
*********************************************************************/
void ActivateDoor()
{
short edge=0;
BYTE yourdir,done=0;
ListRec *tmp1=doors,*tmp;

	PointInWall(transX,transY);
	edge=inside;
	yourdir=Direction(angle);
	if (edge==0) return;

	for (;tmp1;)
	{
		if (tmp1->edge==edge) tmp=tmp1;
        tmp1 = (tmp1->next) ? tmp1->next : 0;
	}
	if (!tmp) return;

	if (tmp->type==STAYOPENDOOR || tmp->type==AUTOCLOSEDOOR)
	{
		if ((tmp->direction==NORTH || tmp->direction==SOUTH) &&
			(yourdir==EAST || yourdir==WEST)) return; else
		if ((tmp->direction==EAST || tmp->direction==WEST) &&
			(yourdir==NORTH || yourdir==SOUTH)) return;
	} else
	if (tmp->type==SECRETDOOR)
		if (tmp->direction!=yourdir) return;

	if (tmp->open) return;
	tmp->active=1;
}

/*********************************************************************
* Called before each frame is generated.
* Goes down doors list.
* For each door with "active" bit set,
*  	If door is secret
*		Move door coords & midpoint 0.02 in direction of door's direction.
*		increment state
*		if state==100 (secret door is open all the way)
* 			Delete the door from doors list
*********************************************************************/
void MoveDoors()
{
ListRec *tmp=doors;
short e,pt1,pt2,bad,state;
float incx=0.0, incy=0.0,x1,y1,x2,y2;

	for (;tmp;)
	{
		if (tmp->active)
		{
			bad=0;
			e = tmp->edge;
			pt1 = edges[e][0]-1;
			pt2 = edges[e][1]-1;
			state = tmp->state;
			if (tmp->type==SECRETDOOR)
			{
				if (state==100)
				{
					doors=DeleteNode(tmp,doors);
					PlotMap();
					return;
				}
				incy=0;
				incx=0;
				if (tmp->direction==NORTH) incy= 0.015; else
				if (tmp->direction==SOUTH) incy=-0.015; else
				if (tmp->direction==EAST)  incx= 0.015; else
				if (tmp->direction==WEST)  incx=-0.015;
				points[pt1][0] += incx;
				points[pt1][2] += incy;
				points[pt2][0] += incx;
				points[pt2][2] += incy;
				subpoints[e][0] += incx;
				subpoints[e][2] += incy;
				tmp->state++;
			} else
			if (tmp->type==STAYOPENDOOR || tmp->type==AUTOCLOSEDOOR)
			{
				if (state<26) /* open door */
				{
					incy=0;
					incx=0;
					if (tmp->direction==NORTH) incx= 0.06; else
					if (tmp->direction==SOUTH) incx=-0.06; else
					if (tmp->direction==EAST)  incy= 0.06; else
					if (tmp->direction==WEST)  incy=-0.06;
					points[pt1][0] += incx;
					points[pt1][2] += incy;
					points[pt2][0] += incx;
					points[pt2][2] += incy;
				}
				if (state==20)
				{
					subpoints[e][0] += incx*25;
					subpoints[e][2] += incy*25;
				}
				if (state==150 || state>199-25)
				{
					x1 = points[pt1][0];
					y1 = points[pt1][2];
					x2 = points[pt2][0];
					y2 = points[pt2][2];
					if (fabs(x1-x2)<0.0001)
					{
						if (fabs(transX-x1)<0.5) bad=1;
						if (tmp->direction==EAST) y1=y2-1;
						if (tmp->direction==WEST) y1=y2+1;
						if ((y1<transY && y2>transY) || (y1>transY && y2<transY)) bad=bad&1; else bad=0;
					} else
					{
						if (fabs(transY-y1)<0.5) bad=1;
						if (tmp->direction==NORTH) x1=x2+1;
						if (tmp->direction==SOUTH) x1=x2-1;
						if ((x1<transX && x2>transX) || (x1>transX && x2<transX)) bad=bad&1; else bad=0;
					}
				}
				if (state>149 && bad==0)
				{
					incy=0;
					incx=0;
					if (tmp->direction==NORTH) incx=-0.06; else
					if (tmp->direction==SOUTH) incx= 0.06; else
					if (tmp->direction==EAST)  incy=-0.06; else
					if (tmp->direction==WEST)  incy= 0.06;
					points[pt1][0] += incx;
					points[pt1][2] += incy;
					points[pt2][0] += incx;
					points[pt2][2] += incy;
				}
				if (state==155)
				{
					subpoints[e][0] += incx*25;
					subpoints[e][2] += incy*25;
				}
				if (state==26) tmp->open=1;
				if (state==26 && tmp->type==STAYOPENDOOR)
				{
					tmp->active=0;
					PlotMap();
					return;
				} else
				if (state>199-25)
				{
					tmp->active=0;
					tmp->state=0;
					tmp->key=0;
					tmp->open=0;
					PlotMap();
					return;
				}
				if (bad==0) tmp->state++;
			}
		}
        tmp = (tmp->next) ? tmp->next : 0;
	}
}

/*********************************************************************
* Called when LMB clicked. To see if you activated a button.
* Call pointinwall to see which door edge you are in front of.
* 	If yourangle=dir_of_edge, then you are facing door
*		else return;
* Go through buttons list to find that button.
* If no button found at that location, return.
* Else, do button stuff.
*********************************************************************/
void ActivateButton()
{
short edge=0;
BYTE yourdir,done=0;
ListRec *tmp1=buttons,*tmp;

	PointInWall(transX,transY);
	edge=inside;
	yourdir=Direction(angle);
	if (edge==0) return;

	for (;tmp1;)
	{
		if (tmp1->edge==edge) tmp=tmp1;
        tmp1 = (tmp1->next) ? tmp1->next : 0;
	}
	if (!tmp) return;

	if (tmp->type!=BUTTON_BOOL || tmp->direction!=yourdir) return;

	tmp->state=!tmp->state;
	if (tmp->open==IN) edges[tmp->edge][2]=tmp->wall2; else
	if (tmp->open==OUT) edges[tmp->edge][2]=tmp->wall1;
}

