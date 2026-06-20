/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: que.c,v 1.2.1.5 1994/12/09 05:29:56 jason Exp $

$Log: que.c,v $
 * Revision 1.2.1.5  1994/12/09  05:29:56  jason
 * border buttons with feedback
 *
 * Revision 1.2.1.4  1994/11/16  06:28:44  jason
 * border support
 *
 * Revision 1.2.1.3  1994/09/13  03:52:07  jason
 * replaced micropause() with delay()
 *
 * Revision 1.2.1.2  1994/04/06  02:42:15  jason
 * Now only updates que when it's empty
 *
 * Revision 1.2.1.1  1994/03/29  05:41:32  jason
 * Added RCS Header

******************************************************************************/


#ifndef NOT_EXTERN
#include"agl.h"
#endif

#include"keymap.h"


#define QDEBUG			FALSE

#define MAXKEYINPUT		128

#define BORDER_TITLE	0
#define BORDER_LEFT		1
#define BORDER_RIGHT	2
#define BORDER_TOP		4
#define BORDER_BOTTOM	8
#define BORDER_MENU		16
#define BORDER_MINIMIZE	32
#define BORDER_MAXIMIZE	64


struct InputEvent InEvent={0,IECLASS_RAWKEY,0,0,0};

short LastOrigin[MAX_WINDOWS][2];
short Tie[MAX_DEVICE][2];
short Queued[MAX_DEVICE];
short ButtonState[MAX_DEVICE];
short QRead,QWrite;
short Mousex,Mousey,LastMousex=0,LastMousey=0;
short Mouse2x=0,Mouse2y=0;

long Queue[QUEUE_SIZE][2];



/******************************************************************************
void	qinit(void)

******************************************************************************/
/*PROTOTYPE*/
void qinit(void)
	{
	short m;

	GLFocus=0;

	QRead=0;
	QWrite=0;

	for(m=0;m<MAX_WINDOWS;m++)
		{
		LastOrigin[m][0]= -1;
		LastOrigin[m][1]= -1;
		}

	for(m=0;m<MAX_DEVICE;m++)
		{
		Queued[m]=FALSE;
		Tie[m][0]=0;
		Tie[m][1]=0;
		}

	clear_buttons(TRUE);

	Queued[REDRAW]=TRUE;
	Queued[INPUTCHANGE]=TRUE;
	}


/******************************************************************************
void	tie(long dev,long valuator1,long valuator2)

******************************************************************************/
/*PROTOTYPE*/
void tie(long dev,long valuator1,long valuator2)
	{
	Tie[dev][0]=valuator1;
	Tie[dev][1]=valuator2;
	}


/******************************************************************************
void	qdevice(long dev)

******************************************************************************/
/*PROTOTYPE*/
void qdevice(long dev)
	{
	Queued[dev]=TRUE;
	}


/******************************************************************************
void	unqdevice(long dev)

******************************************************************************/
/*PROTOTYPE*/
void unqdevice(long dev)
	{
	Queued[dev]=FALSE;
	}


/******************************************************************************
long	isqueued(long dev)

******************************************************************************/
/*PROTOTYPE*/
long isqueued(long dev)
	{
	return Queued[dev];
	}


/******************************************************************************
void	qenter(long dev,short val)

******************************************************************************/
/*PROTOTYPE*/
void qenter(long dev,short val)
	{
	Queue[QWrite][0]=dev;
	Queue[QWrite][1]=val;
	QWrite++;

	if(QWrite==QRead)
		{
		GL_error("Queue filled: event overrun");
		QRead++;
		if(QRead==QUEUE_SIZE)
			QRead=0;
		}

	if(QWrite==QUEUE_SIZE)
		QWrite=0;
	}


/******************************************************************************
long	qtest(void)

	checks if there is event in the queue
	doesn't wait, returns immediately

******************************************************************************/
/*PROTOTYPE*/
long qtest(void)
	{
	if(QRead==QWrite)
		update_queue(-1);

	if(QRead==QWrite)
		return 0;
	else
		return Queue[QRead][0];
	}


/*******************************************************************************
void	delay(void)

*******************************************************************************/
/*PROTOTYPE*/
void delay(void)
	{
	Delay(5);
	}


/******************************************************************************
long	qread(short *data)

	reads queue
	will wait for an event

******************************************************************************/
/*PROTOTYPE*/
long qread(short *data)
	{
	long device;

	while(QRead==QWrite)
		{
		update_queue(-1);
		delay();
		}

	device=Queue[QRead][0];
	*data=Queue[QRead][1];

	QRead++;

	if(QRead==QUEUE_SIZE)
		QRead=0;

	return device;
	}


/******************************************************************************
void	qreset(void)

******************************************************************************/
/*PROTOTYPE*/
void qreset(void)
	{
	QRead=QWrite;
	}


/******************************************************************************
long	getvaluator(long val)

******************************************************************************/
/*PROTOTYPE*/
long getvaluator(long val)
	{
	long result=0;

	switch(val)
		{
		case MOUSEX:
			result=GLScreen->MouseX;
			break;
		case MOUSEY:
			result=GLScreen->Height-1-GLScreen->MouseY;
			break;
		}

	return result;
	}


/******************************************************************************
long	getbutton(long num)

******************************************************************************/
/*PROTOTYPE*/
long getbutton(long num)
	{
	update_queue(-1);

	return (long)ButtonState[num];
	}


/******************************************************************************
void clear_buttons(long init)

	resets state of mouse buttons

	unless init, issues que entry for switch off

******************************************************************************/
/*PROTOTYPE*/
void clear_buttons(long init)
	{
	long m;

/* 	printf("clear buttons\n"); */

	for(m=0;m<MAX_DEVICE;m++)
		{
		if(ButtonState[m] && Queued[m] && !init)
			qenter_tie(m,(short)FALSE);

		ButtonState[m]=FALSE;
		}
	}


/*******************************************************************************
void	update_queue(short waitid)

	a manual MOUSEX,MOUSEY move check is much better than having Intuition
		flood the system with reports

	if waitid>=0, wait for event in wid specified by waitid

*******************************************************************************/
/*PROTOTYPE*/	 
void update_queue(short waitid)
	{
	struct IntuiMessage *message,*mess1,*mess2;
	struct MsgPort *userport;

	ULONG class;
	USHORT code;
	UWORD qualifier;

	char string[MAXKEYINPUT];

	long wid,old_wid;
	long border_touch=NULL;	/* wid of window whose border is being touched */
	long device;
	long originx,originy;
	long sizex,sizey;

	short inside;
	short border;
	short data;
	short ascii;
	short c;
	short length;
	short mx,my;
	short waited=FALSE;

	Mousex=getvaluator(MOUSEX);
	Mousey=getvaluator(MOUSEY);

#if MICE
	while(gameport_event(&device,&data,&mx,&my))	/* mx,my = delta mouse position */
		{
/*
		if(device && Queued[device])
			qenter_tie(device,data);
*/
			
		if(mx || my)
			{
			Mouse2x+=mx;
			Mouse2y+=my;

			if(Mouse2x<0)
				Mouse2x=0;
			if(Mouse2x>GLScreen->Width-1)
				Mouse2x=GLScreen->Width-1;

			if(Mouse2y<0)
				Mouse2y=0;
			if(Mouse2y>GLScreen->Height-1)
				Mouse2y=GLScreen->Height-1;

/*
			if(Queued[BPADX])
				qenter(BPADX,Mouse2x);

			if(Queued[BPADY])
				qenter(BPADY,Mouse2y);
*/

			move_mousesprite((long)Mouse2x,(long)Mouse2y);
			}
		}
#endif

	if( (Queued[MOUSEX]||Queued[MOUSEY]) && (Mousex!=LastMousex||Mousey!=LastMousey)
														&& is_inside(GLFocus,Mousex,Mousey,FALSE) )
		{
		if(Queued[MOUSEX])
			qenter(MOUSEX,Mousex);
		if(Queued[MOUSEY])
			qenter(MOUSEY,Mousey);
		}

	LastMousex=Mousex;
	LastMousey=Mousey;

	do	{
		for(wid=1;wid<MAX_WINDOWS;wid++)
			{
			if(GLWindow[wid])
				{
				/* check if window has moved (no Intuition event for this) */
				get_dimensions(wid,TRUE,&originx,&originy,&sizex,&sizey);
				originy=ScreenHeight-originy-sizey;

				if(originx!=LastOrigin[wid][0] || originy!=LastOrigin[wid][1])
					{
					if(QDEBUG)
						printf("MOVEWINDOW (pseudo-event)\n");

					LastOrigin[wid][0]=originx;
					LastOrigin[wid][1]=originy;

					if(wid==waitid)
						waited=TRUE;
					}

				userport=GLWindow[wid]->UserPort;
				inside=is_inside(wid,Mousex,Mousey,TRUE);
				if(inside)
					{
					border=!is_inside(wid,Mousex,Mousey,FALSE);

					/* not considered inside if on border */
					inside=!border;
					}
				else
					border=FALSE;

				while(message=(struct IntuiMessage *)GetMsg(userport))
					{
					device=0;
					data=0;

					class=message->Class;
					code=message->Code;
					qualifier=message->Qualifier;
					mx=message->MouseX;
					my=message->MouseY;

/*	Note: ignoring button info from refresh and newsize to prevent
 *	false-positive leftmouse after a resize
 */

					if( class!=NEWSIZE && class!=REFRESHWINDOW &&
													class!=ACTIVEWINDOW && class!=INACTIVEWINDOW )
						{
						ButtonState[LEFTMOUSE]= (qualifier&IEQUALIFIER_LEFTBUTTON)!=0;
						ButtonState[MIDDLEMOUSE]= (qualifier&IEQUALIFIER_MIDBUTTON)!=0;
						ButtonState[RIGHTMOUSE]= (qualifier&IEQUALIFIER_RBUTTON)!=0;
						}
				
					if(QDEBUG)
						printf("Msg on %d: %d,%d mb=%d%d%d code=%d ",wid,mx,my,ButtonState[LEFTMOUSE],
												ButtonState[MIDDLEMOUSE],ButtonState[RIGHTMOUSE],code);

					ReplyMsg((struct Message *)message);

					switch(class)
						{
						case CLOSEWINDOW:
							if(QDEBUG)
								printf("CLOSEWINDOW\n");
							device=WINQUIT;
							data=TRUE;
							break;

						case NEWSIZE:
							if(QDEBUG)
								printf("NEWSIZE\n");

#if FALSE
							/* window resize indicates an otherwise unseen left mouse release */
							ButtonState[LEFTMOUSE]=FALSE;

#endif
							if(wid==waitid)
								waited=TRUE;
							break;

						case REFRESHWINDOW:
							if(QDEBUG)
								printf("REFRESHWINDOW\n");

							/* optimally refresh occurs between these, but not convenient in GL */
							BeginRefresh(GLWindow[wid]);
							EndRefresh(GLWindow[wid],TRUE);

							device=REDRAW;
							data=wid;

							drawborder(wid,0);
							break;

						case ACTIVEWINDOW:
							if(QDEBUG)
								printf("ACTIVEWINDOW\n");

							if(GLFocus!=0)
								qenter_tie(INPUTCHANGE,(short)0);

							old_wid=GLFocus;
							GLFocus=wid;
							device=INPUTCHANGE;
							data=wid;

							drawborder(old_wid,0);
							drawborder(wid,0);

							RedoBorder[wid]=TRUE;
							RedoBorder[old_wid]=TRUE;
							break;

						case INACTIVEWINDOW:
							if(QDEBUG)
								printf("INACTIVEWINDOW\n");

							if(GLFocus==wid)
								{
								old_wid=GLFocus;
								GLFocus=0;
								device=INPUTCHANGE;
								data=0;
								clear_buttons(FALSE);

								drawborder(old_wid,0);
								RedoBorder[old_wid]=TRUE;
								}

							break;

						case MOUSEMOVE:
							if(QDEBUG)
								printf("MOUSEMOVE\n");

							if(inside)
								{
								if(Queued[MOUSEX])
									qenter(MOUSEX,Mousex);
								if(Queued[MOUSEY])
									qenter(MOUSEY,Mousey);
								}
							break;

						case MOUSEBUTTONS:
							if(QDEBUG)
								printf("MOUSEBUTTONS\n");

							switch(code)
								{
								case SELECTDOWN:
									device=LEFTMOUSE;
									data=TRUE;

									if(border)
										border_touch=wid;
									break;

								case SELECTUP:
									device=LEFTMOUSE;
									data=FALSE;
									break;

								case MIDDLEDOWN:
									device=MIDDLEMOUSE;
									data=TRUE;

									if(border)
										border_touch= -wid;
									break;

								case MIDDLEUP:
									device=MIDDLEMOUSE;
									data=FALSE;
									break;

								case MENUDOWN:
									device=RIGHTMOUSE;
									data=TRUE;
									break;

								case MENUUP:
									device=RIGHTMOUSE;
									data=FALSE;
									break;
								}

/*
							if(!inside)
								device=NULL;
*/
							break;

						case RAWKEY:
							if(QDEBUG)
								printf("RAWKEY\n");

							if(inside)
								{
								if(!(code&IECODE_UP_PREFIX))
									{
									InEvent.ie_Code=code;
									InEvent.ie_Qualifier=qualifier;
									length=RawKeyConvert(&InEvent,string,MAXKEYINPUT,NULL);

									if(length>0)
										{
										string[length]=0;

										if(QDEBUG)
											for(c=0;string[c];c++)
												printf("     %2x %3d '%c'\n",
																		string[c],string[c],string[c]);

										if(Queued[KEYBD] && length==1)
											{
											ascii=string[0];
											device=KEYBD;
											data=ascii;
											}
										}
									}
								}
							quekeys(code,inside);

#if FALSE
							/* prevent running */
							mess1=(struct IntuiMessage *) userport->mp_MsgList.lh_Head;
							while(mess2=(struct IntuiMessage *)mess1->ExecMessage.mn_Node.ln_Succ)
								{
								if(mess2->ExecMessage.mn_Node.ln_Succ==NULL)
									break;
								if(mess1->Class!=RAWKEY)
									break;
								if(!(mess1->Qualifier & IEQUALIFIER_REPEAT))
									break;
								if(mess2->Class != RAWKEY)
									break;
								if(!(mess2->Qualifier & IEQUALIFIER_REPEAT))
									break;

								/* Message removed */
								mess1=(struct IntuiMessage *)GetMsg(userport);
								ReplyMsg((struct Message *)mess1);

								mess1=(struct IntuiMessage *) userport->mp_MsgList.lh_Head;
								}
#endif
							break;
						}

					if(device && Queued[device])
						qenter_tie(device,data);
					}
				}
			}
		} while(waitid>=0 && !waited);

	if(border_touch && waitid<0)
		{
		if(border_touch<0)
			{
			border_touch= -border_touch;
			data=TRUE;
			}
		else
			data=FALSE;

		border_action(border_touch,Mousex,Mousey,data);
		}
	}


/******************************************************************************
void	qenter_tie(long device,short data)

******************************************************************************/
/*PROTOTYPE*/
void qenter_tie(long device,short data)
	{
	short n;

	qenter(device,data);

	for(n=0;n<2;n++)
		{
		if(Tie[device][n]==MOUSEX)
			qenter(MOUSEX,Mousex);
		if(Tie[device][n]==MOUSEY)
			qenter(MOUSEY,Mousey);
		}
	}


/******************************************************************************
void	quekeys(USHORT code,short inside)

******************************************************************************/
/*PROTOTYPE*/
void quekeys(USHORT code,short inside)
	{
	long device;
	short data=TRUE;

	if( code & IECODE_UP_PREFIX )
		{
		data=FALSE;
		code-=IECODE_UP_PREFIX;
		}

	if(code<KEYMAPLENGTH)
		{
 		device=KeyRemap[code];

		if(data != ButtonState[device])
			{
			if(QDEBUG)
				printf("Code %2X %3d -> device=%d\n",code,data,device);

			ButtonState[device]=data;

			if(Queued[device] && inside)
				qenter_tie(device,data);
			}
		}
	}


/******************************************************************************
short 	is_inside(long wid,short x,short y,short border)

	if border==TRUE, will also report inside if on border

******************************************************************************/
/*PROTOTYPE*/
short is_inside(long wid,short x,short y,short border)
	{
	long posx,posy,lenx,leny;
	short inside;

	get_dimensions(wid,border,&posx,&posy,&lenx,&leny);

	x-=posx;
	y-=posy;

	inside=	x>=0 && x<lenx && y>=0 && y<leny;

/* 	printf("border=%d pos=%d,%d len=%d,%d %d,%d inside=%d\n",border,posx,posy,lenx,leny,x,y,inside); */

	return inside;
	}


/******************************************************************************
short	border_edge(long wid,short x,short y)

	returns which edge/corner is touched as sum of the following
		BORDER_LEFT
		BORDER_RIGHT
		BORDER_TOP
		BORDER_BOTTOM
		BORDER_MENU
		BORDER_MINIMIZE
		BORDER_MAXIMIZE

	note that all combinations of flags are not possible

	assuming you know x,y is on the border, return of 0 indicates title bar
******************************************************************************/
/*PROTOTYPE*/
short border_edge(long wid,short x,short y)
	{
	long posx,posy,lenx,leny;

	short result=0;

	get_dimensions(wid,TRUE,&posx,&posy,&lenx,&leny);

	x-=posx;
	y-=posy;

	if(x< BorderWidth+BorderHeight)
		result+=BORDER_LEFT;

	if(x> lenx - (BorderWidth+BorderHeight) )
		result+=BORDER_RIGHT;

	if(y< BorderWidth+BorderHeight)
		result+=BORDER_BOTTOM;

	if(y>= leny - (BorderWidth+BorderHeight) )
		result+=BORDER_TOP;

	if( x>= BorderWidth && x< lenx-BorderWidth && y>= BorderWidth && y< leny-BorderWidth )
		{
		/* not on outer edge */

		if( y <= leny-BorderWidth-BorderHeight )
			result=0;
		else
			{
			/* title bar */

			if( x< BorderWidth+BorderHeight )
				result=BORDER_MENU;
			else if( x>= lenx-BorderWidth-BorderHeight )
				result=BORDER_MAXIMIZE;
			else if( x>= lenx-BorderWidth-2*BorderHeight )
				result=BORDER_MINIMIZE;
			else
				result=0;
			}
		}

	return result;
	}


/******************************************************************************
void 	border_action(long wid,short ox,short oy,short middle)

******************************************************************************/
/*PROTOTYPE*/
void border_action(long wid,short ox,short oy,short middle)
	{
	long old_wid;
	long dx,dy;
	long x,y;
	long movex,movey;
	long sizex,sizey;
	long posx,posy,lenx,leny;
	long edge=BORDER_TITLE;

	short first=TRUE;
	short movefirst;

	get_dimensions(wid,TRUE,&posx,&posy,&lenx,&leny);
	posy=ScreenHeight-posy-leny;

	edge=border_edge(wid,ox,oy);

	if( (middle || !Sizeable[wid]) && edge!=BORDER_MENU)
		edge=BORDER_TITLE;

	if(edge==BORDER_MENU)
		{
		drawborder(wid,1);

		while( (!middle && getbutton(LEFTMOUSE)) || (middle && getbutton(MIDDLEMOUSE)) )
			/* NOP */ ;

		drawborder(wid,0);

		qenter(WINQUIT,TRUE);
		}
	else if(edge==BORDER_MINIMIZE)
		{
		drawborder(wid,3);

		while( (!middle && getbutton(LEFTMOUSE)) || (middle && getbutton(MIDDLEMOUSE)) )
			/* NOP */ ;

		drawborder(wid,0);
		}
	else if(edge==BORDER_MAXIMIZE)
		{
		drawborder(wid,4);

		while( (!middle && getbutton(LEFTMOUSE)) || (middle && getbutton(MIDDLEMOUSE)) )
			/* NOP */ ;

		get_dimensions(wid,FALSE,&posx,&posy,&lenx,&leny);

		x=Maximization[wid][0];
		y=Maximization[wid][1];
		dx=x+Maximization[wid][2]-1;
		dy=y+Maximization[wid][3]-1;

/*
		printf("\n%d,%d %d,%d,%d,%d %d,%d\n",ScreenWidth,ScreenHeight,
																BorderWidth,BorderHeight,x,y,dx,dy);
*/
		old_wid=winget();
		winset(wid);

		winposition(x,dx,y,dy);

		Maximization[wid][0]=posx;
		Maximization[wid][1]=posy;
		Maximization[wid][2]=lenx;
		Maximization[wid][3]=leny;

		winset(old_wid);
		}
	else
		{
		if(!middle && edge==0)
			drawborder(wid,2);

		while( (!middle && getbutton(LEFTMOUSE)) || (middle && getbutton(MIDDLEMOUSE)) )
			{
			x=getvaluator(MOUSEX);
			y=getvaluator(MOUSEY);

			dx=x-ox;
			dy=y-oy;

			if(dx || dy)
				{
				if(first)
					{
					first=FALSE;

					GLScreen->RastPort.BitMap=VisibleRPort->BitMap;
					GLScreen->ViewPort.RasInfo->BitMap=VisibleRPort->BitMap;

					MakeScreen(GLScreen);
					RethinkDisplay();
					}

				sizex=0;
				sizey=0;

				movefirst=TRUE;

				if(edge==0)
					{
					movex=dx;
					movey= -dy;
					}
				else
					{
					movex=0;
					movey=0;
					}

				if(edge&BORDER_TOP)
					{
					movey= -dy;
					sizey=dy;

					movefirst= (movey<0);
					}

				if(edge&BORDER_BOTTOM)
					sizey= -dy;

				if(edge&BORDER_LEFT)
					{
					movex=dx;
					sizex= -dx;

					movefirst= (movex<0);
					}

				if(edge&BORDER_RIGHT)
					sizex=dx;

				if(movex< -posx)
					{
					movex= -posx;
					if(sizex)
						sizex= -movex;
					}

				if(movey< -posy)
					{
					movey= -posy;
					if(sizey)
						sizey= -movey;
					}

				move_and_resize(wid,movefirst,movex,movey,sizex,sizey);

				if(!middle && edge==0)
					drawborder(wid,2);

				posx+=movex;
				posy+=movey;

				lenx+=sizex;
				leny+=sizey;
				}

			ox=x;
			oy=y;
			}

		drawborder(wid,0);

		clone_new_bitmap();
		}
	}


/******************************************************************************
void	do_move_and_resize(long wid,long movefirst,long movex,long movey,
														long sizex,long sizey)

	does proper setup for double buffering
	calls move_and_resize()

******************************************************************************/
/*PROTOTYPE*/
void do_move_and_resize(long wid,long movefirst,long movex,long movey,long sizex,long sizey)
	{
/* 	printf("do(%d,%d, %d,%d, %d,%d)\n",wid,movefirst,movex,movey,sizex,sizey); */

	GLScreen->RastPort.BitMap=VisibleRPort->BitMap;
	GLScreen->ViewPort.RasInfo->BitMap=VisibleRPort->BitMap;

	MakeScreen(GLScreen);
	RethinkDisplay();

	move_and_resize(wid,movefirst,movex,movey,sizex,sizey);

	clone_new_bitmap();
	}


/******************************************************************************
void	move_and_resize(long wid,long movefirst,long movex,long movey,
														long sizex,long sizey)

******************************************************************************/
/*PROTOTYPE*/
void move_and_resize(long wid,long movefirst,long movex,long movey,long sizex,long sizey)
	{
	long posx,posy,lenx,leny;
	long limit;

	get_dimensions(wid,TRUE,&posx,&posy,&lenx,&leny);
	posy=ScreenHeight-posy-leny;

/*
	printf("\n wid=%d movefirst=%d pos=%d,%d+%d,%d size=%d,%d+%d,%d\n",wid,movefirst,posx,posy,
																movex,movey,lenx,leny,sizex,sizey);
*/

	if(lenx+sizex<MIN_WINX)
		sizex=MIN_WINX-lenx;

	if(leny+sizey<MIN_WINY)
		sizey=MIN_WINY-leny;

	limit=ScreenWidth-posx-lenx-sizex;
	if(movex>limit && limit>=0)
		movex=limit;

	limit=ScreenHeight-posy-leny-sizey;
	if(movey>limit && limit>=0)
		movey=limit;

	if(movex< -posx)
		movex= -posx;

	if(movey< -posy)
		movey= -posy;

	limit=ScreenWidth-posx-lenx-movex;
	if(sizex>limit && limit>=0)
		sizex=limit;

	limit=ScreenHeight-posy-leny-movey;
	if(sizey>limit && limit>=0)
		sizey=limit;

/*
	printf("                   pos=%d,%d+%d,%d size=%d,%d+%d,%d\n",posx,posy,movex,movey,
																			lenx,leny,sizex,sizey);
*/

	if( movefirst && (movex || movey) )
		{
		MoveWindow(GLWindow[wid],movex,movey);
		update_queue(wid);
		}

	if(sizex || sizey)
		{
		SizeWindow(GLWindow[wid],sizex,sizey);
		update_queue(wid);

		clear_void(wid,sizex,sizey);
		}

	if( !movefirst && (movex || movey) )
		{
		MoveWindow(GLWindow[wid],movex,movey);
		update_queue(wid);
		}
	}


/******************************************************************************
void	clear_void(long wid,short x,short y)

	clears space left by expanding window
******************************************************************************/
/*PROTOTYPE*/
void clear_void(long wid,short x,short y)
	{
	struct RastPort *rp;

	long posx,posy,lenx,leny;

	rp=GLWindow[wid]->RPort;

	get_dimensions(wid,TRUE,&posx,&posy,&lenx,&leny);

	SetAPen(rp,0);

	deactivate_clipping(wid);

	if(x>0)
		RectFill(rp,lenx-BorderWidth-x,BorderWidth+BorderHeight,lenx-BorderWidth,leny-BorderWidth);

	if(y>0)
		RectFill(rp,BorderWidth,leny-BorderWidth-y,lenx-BorderWidth,leny-BorderWidth);

	activate_clipping(wid);
	}
