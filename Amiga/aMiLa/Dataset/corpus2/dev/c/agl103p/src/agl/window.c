/******************************************************************************

Copyright © 1994 Jason Weber
All Rights Reserved

$Id: window.c,v 1.2.1.6 1994/12/09 05:29:56 jason Exp $

$Log: window.c,v $
 * Revision 1.2.1.6  1994/12/09  05:29:56  jason
 * fixed bitmap crashes
 *
 * Revision 1.2.1.5  1994/11/18  07:49:22  jason
 * added foreground() check
 *
 * Revision 1.2.1.4  1994/11/16  06:31:09  jason
 * added border support
 * fixed double-buffering
 *
 * Revision 1.2.1.3  1994/09/13  03:53:54  jason
 * use true double-buffering for single window
 * added prefsize
 * added minsize(), maxsize()
 * fixed border corrections
 *
 * Revision 1.2.1.2  1994/04/06  02:42:55  jason
 * winset() calls reset_matrix_pointers()
 *
 * Revision 1.2.1.1  1994/03/29  05:41:32  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:04:26  jason
 * Added RCS Header
 *
 * Revision 1.2.1.1  2002/03/26  22:00:51  jason
 * RCS/agl.h,v
 *

******************************************************************************/


#define NOT_EXTERN
#include"agl.h"

#define COOL_BORDERS	TRUE

#define BORDERSIZEX	4		/* displace lower left for border */
#define BORDERSIZEY	11

#define BORDERSIZE_TITLEY	12

short NextWindow_Initialized=FALSE;
short NextBordered=TRUE;
short NextSizeable=TRUE;
short Gfx_Initialized=FALSE;
short NumberWindows=0;

short Foregrounded=FALSE;

struct Library *ConsoleDevice,*DiskfontBase,*LayersBase;


/*******************************************************************************
void	gversion(char *string)

*******************************************************************************/
/*PROTOTYPE*/
void gversion(char *string)
	{
	sprintf(string,"GLAMECS-1.0");
	}


/*******************************************************************************
long	getgdesc(long inquiry)

*******************************************************************************/
/*PROTOTYPE*/
long getgdesc(long inquiry)
	{
	long value=0;

	switch(inquiry)
		{
		case GD_XPMAX:
			value=ScreenWidth;
			break;
		case GD_YPMAX:
			value=ScreenHeight;
			break;
		case GD_BITS_NORM_SNG_CMODE:
			value=ScreenDeep;
			break;
		case GD_BITS_NORM_DBL_CMODE:
			value=ScreenDeep;
			break;
		case GD_NVERTEX_POLY:
			value=MAX_POLY_VERTS;
			break;
	 	}

	return value;
	}


/******************************************************************************
void	foreground(void)

******************************************************************************/
/*PROTOTYPE*/
void foreground(void)
	{
	Foregrounded=TRUE;
	}


/******************************************************************************
void	cmode(void)

******************************************************************************/
/*PROTOTYPE*/
void cmode(void)
	{
	RGBmodeOn[CurrentWid]=FALSE;
	}


/******************************************************************************
void	RGBmode(void)

******************************************************************************/
/*PROTOTYPE*/
void RGBmode(void)
	{
	RGBmodeOn[CurrentWid]=TRUE;
	}


/******************************************************************************
void	doublebuffer(void)

******************************************************************************/
/*PROTOTYPE*/
void doublebuffer(void)
	{
	DoubleBuffered[CurrentWid]=TRUE;
	}


/******************************************************************************
void	singlebuffer(void)

******************************************************************************/
/*PROTOTYPE*/
void singlebuffer(void)
	{
	DoubleBuffered[CurrentWid]=FALSE;
	}


/******************************************************************************
long	getdisplaymode(void)

	0 = RGB single
	1 = single
	2 = double
	5 = RGB double
******************************************************************************/
/*PROTOTYPE*/
long getdisplaymode(void)
	{
	return 1+DoubleBuffered[CurrentWid];
	}


/******************************************************************************
void	clone_new_bitmap(void)

	if true double-buffing (single window), copy visible bitmap to drawbuffer
	intended to update window borders and screen background in backbuffer
******************************************************************************/
/*PROTOTYPE*/
void clone_new_bitmap(void)
	{
	struct BitMap *old_bitmap;

	if(NumberWindows==1 && DoubleBufferSet[CurrentWid])
		{

#if FALSE
		BltBitMap(
					&BackBitMap[CurrentWid],0,0,
					GLScreen->RastPort.BitMap,0,0,
											(long)ScreenWidth,(long)ScreenHeight,0xC0,0xFF,NULL);

		old_bitmap=GLWindow[CurrentWid]->RPort->BitMap;
		memcpy(GLWindow[CurrentWid]->RPort,&BackRPort[CurrentWid],sizeof(struct RastPort));

		GLWindow[CurrentWid]->RPort->BitMap=old_bitmap;
#endif

#if FALSE
		BltBitMap(
					GLScreen->RastPort.BitMap,0,0,
					&BackBitMap[CurrentWid],0,0,
										(long)ScreenWidth,(long)ScreenHeight,0xC0,0xFF,NULL);

		old_bitmap=BackRPort[CurrentWid].BitMap;
		memcpy(&BackRPort[CurrentWid],GLWindow[CurrentWid]->RPort,sizeof(struct RastPort));
		BackRPort[CurrentWid].BitMap=old_bitmap;
#endif

#if TRUE
		BltBitMap(
					VisibleRPort->BitMap,0,0,
					DrawRPort->BitMap,0,0,
										(long)ScreenWidth,(long)ScreenHeight,0xC0,0xFF,NULL);

/*
		old_bitmap=DrawRPort->BitMap;
		memcpy(DrawRPort,VisibleRPort,sizeof(struct RastPort));
		DrawRPort->BitMap=old_bitmap;
*/
#endif
		}
	}


/*******************************************************************************
void	gconfig(void)

*******************************************************************************/
/*PROTOTYPE*/
void gconfig(void)
	{
	long d,dd,abort=FALSE;

	if(DoubleBuffered[CurrentWid] && !DoubleBufferSet[CurrentWid])
		{
		memcpy(&BackRPort[CurrentWid],GLWindow[CurrentWid]->RPort,sizeof(struct RastPort));

		InitBitMap(&BackBitMap[CurrentWid],(long)ScreenDeep,(long)ScreenWidth,(long)ScreenHeight);
		for(d=0;d<ScreenDeep && !abort;d++)
			{
			if((BackBitMap[CurrentWid].Planes[d]=(PLANEPTR)AllocRaster((ULONG)ScreenWidth,
																	(ULONG)ScreenHeight))==NULL)
				abort=TRUE;
			}

		if(abort)
			{
			GL_error("Could not allocate backbuffer");

			for(dd=0;dd<d-1;dd++)
				FreeRaster(BackBitMap[CurrentWid].Planes[dd],
														(ULONG)ScreenWidth,(ULONG)ScreenHeight);
			}
		else
			{
/* 			clone_new_bitmap(); */

			BltBitMap(
						GLScreen->RastPort.BitMap,0,0,
						&BackBitMap[CurrentWid],0,0,
											(long)ScreenWidth,(long)ScreenHeight,0xC0,0xFF,NULL);

/* 			memcpy(&BackRPort[CurrentWid],GLWindow[CurrentWid]->RPort,sizeof(struct RastPort)); */

			BackRPort[CurrentWid].BitMap= &BackBitMap[CurrentWid];
			DoubleBufferSet[CurrentWid]=TRUE;
			}
		}

	if(!DoubleBuffered[CurrentWid] && DoubleBufferSet[CurrentWid])
		{
		for(d=0;d<ScreenDeep;d++)
			FreeRaster(BackBitMap[CurrentWid].Planes[d],(ULONG)ScreenWidth,(ULONG)ScreenHeight);

		DoubleBufferSet[CurrentWid]=FALSE;
		}

	RGBmodeSet[CurrentWid]=RGBmodeOn[CurrentWid];

	set_rasterport();
	}


/*******************************************************************************
void	swapbuffers(void)

*******************************************************************************/
/*PROTOTYPE*/
void swapbuffers(void)
	{
	struct BitMap *swap;

	long x,y;

	if(DoubleBuffered[CurrentWid])
		{
		if(NumberWindows==1)
			{
			/* make sure any window movements/sizing taken care of */
			update_queue(-1);

			/* update to make visible */
			MakeScreen(GLScreen);
			RethinkDisplay();

			/* swap bitmaps */
			swap=VisibleRPort->BitMap;
			VisibleRPort->BitMap=DrawRPort->BitMap;

			if(DrawRPort->BitMap==swap)
				GL_error("swapbuffers() software error, bitmaps are the same");

			DrawRPort->BitMap=swap;

			GLScreen->RastPort.BitMap=swap;
			GLScreen->ViewPort.RasInfo->BitMap=swap;

/* 			GLWindow[CurrentWid]->RPort->BitMap=VisibleRPort->BitMap; */

			if(RedoBorder[CurrentWid])
				{
				drawborder(CurrentWid,0);
				RedoBorder[CurrentWid]=FALSE;
				}
			}
		else
			{
			deactivate_clipping(CurrentWid);
/*
			OwnBlitter();
			WaitBlit();
			BltBitMap(DrawRPort->BitMap,0,0,VisibleRPort->BitMap,0,0,CurrentWidth,CurrentHeight,
																					0xC0,0xFF,NULL);
			DisownBlitter();
*/
			if(COOL_BORDERS && Bordered[CurrentWid])
				{
				x=BorderWidth;
				y=BorderWidth+BorderHeight;
				}
			else
				{
				x=0;
				y=0;
				}

			ClipBlit(DrawRPort,x,y,VisibleRPort,x,y,CurrentWidth,CurrentHeight,0xC0);

			activate_clipping(CurrentWid);
			}
		}
	else
		GL_error("swapbuffers() called in single buffer mode");
	}


/*******************************************************************************
void	set_rasterport(void)

*******************************************************************************/
/*PROTOTYPE*/
void set_rasterport(void)
	{
	VisibleRPort=GLWindow[CurrentWid]->RPort;

	if(DoubleBuffered[CurrentWid])
		DrawRPort= &BackRPort[CurrentWid];
	else
		DrawRPort=VisibleRPort;
	}


/*******************************************************************************
void	winpush(void)

*******************************************************************************/
/*PROTOTYPE*/
void winpush(void)
	{
	WindowToBack(GLWindow[CurrentWid]);
	}


/*******************************************************************************
void	winpop(void)

*******************************************************************************/
/*PROTOTYPE*/
void winpop(void)
	{
	WindowToFront(GLWindow[CurrentWid]);
	}


/*******************************************************************************
long	winget(void)

*******************************************************************************/
/*PROTOTYPE*/
long winget(void)
	{
	return CurrentWid;
	}


/*******************************************************************************
void	winset(long wid)

*******************************************************************************/
/*PROTOTYPE*/
void winset(long wid)
	{
	static char string[100];

	if(GLWindow[wid]==NULL)
		{
		if(wid)
			{
			sprintf(string,"winset(%d): window not open",wid);
			GL_error(string);
			}

		CurrentWid=0;
		}
	else
		{
		CurrentWid=wid;

		set_rasterport();
		get_dimensions(CurrentWid,FALSE,&CurrentPosX,&CurrentPosY,&CurrentWidth,&CurrentHeight);

		reset_matrix_pointers();
		}
	}


/******************************************************************************
short	get_dimensions(long wid,long whole,long *x,long *y,long *lenx,long *leny)

	if whole==TRUE, get whole window dimensions including border

	returns FALSE if window is not opened
******************************************************************************/
/*PROTOTYPE*/
short get_dimensions(long wid,long whole,long *x,long *y,long *lenx,long *leny)
	{
	if(GLWindow[wid]==NULL)
		return FALSE;

	if(COOL_BORDERS || !Bordered[wid])
		{
		*lenx=GLWindow[wid]->Width;
		*leny=GLWindow[wid]->Height;
		}
	else
		{
		*lenx=GLWindow[wid]->GZZWidth;
		*leny=GLWindow[wid]->GZZHeight;
		}

	*x=GLWindow[wid]->LeftEdge+GLWindow[wid]->BorderLeft;
	*y=GLWindow[wid]->TopEdge+GLWindow[wid]->BorderTop;

	*y=ScreenHeight-(*y)- *leny;

#if COOL_BORDERS

	if(Bordered[wid] && !whole)
		{
		*x+=BorderWidth;
		*y+=BorderWidth;

		*lenx-=2*BorderWidth;
		*leny-=2*BorderWidth+BorderHeight;
		}

#endif

	return TRUE;
	}


/*******************************************************************************
void	sleep(long seconds)

*******************************************************************************/
/*PROTOTYPE*/
void sleep(long seconds)
	{
	Delay(60*seconds);
	}


/******************************************************************************
void	minsize(long x,long y)

******************************************************************************/
/*PROTOTYPE*/
void minsize(long x,long y)
	{
	NextWindow.MinWidth=x;
	NextWindow.MinHeight=y;
	}


/******************************************************************************
void	maxsize(long x,long y)

******************************************************************************/
/*PROTOTYPE*/
void maxsize(long x,long y)
	{
	NextWindow.MaxWidth=x;
	NextWindow.MaxHeight=y;
	}


/*******************************************************************************
void	prefposition(long x1,long x2,long y1,long y2)

*******************************************************************************/
/*PROTOTYPE*/
void prefposition(long x1,long x2,long y1,long y2)
	{
	if(!NextWindow_Initialized)
		initialize_nextwindow();

	NextWindow.LeftEdge=x1;
	NextWindow.Width=	x2-x1+1;

	NextWindow.TopEdge=	ScreenHeight-1-y2;
	NextWindow.Height=	y2-y1+1;

	if(NextWindow.Flags&WINDOWSIZING)
		NextWindow.Flags^=WINDOWSIZING;

/*
	printf("X %3d   %3d  Y %3d   %3d\n",x1,x2,y1,y2);
	printf("L %3d W %3d  T %3d H %3d\n\n",NextWindow.LeftEdge,NextWindow.Width,
															NextWindow.TopEdge,NextWindow.Height);
*/
	NextSizeable=FALSE;
	}


/******************************************************************************
void	prefsize(long x,long y)

******************************************************************************/
/*PROTOTYPE*/
void prefsize(long x,long y)
	{
	if(!NextWindow_Initialized)
		initialize_nextwindow();

#if COOL_BORDERS

	prefposition(BorderWidth,BorderWidth+x-1,BorderWidth,BorderWidth+BorderHeight+y-1);

#else

	prefposition(BORDERSIZEX,BORDERSIZEX+x-1,1,1+y-1);

	NextWindow.Flags|=WINDOWSIZING;

#endif

	NextSizeable=TRUE;
	}


/*******************************************************************************
void	noborder(void)

*******************************************************************************/
/*PROTOTYPE*/
void noborder(void)
	{
	if(!NextWindow_Initialized)
		initialize_nextwindow();

	NextBordered=FALSE;

#if !COOL_BORDERS

	NextWindow.Flags|=BORDERLESS;

#endif
	}


/******************************************************************************
void	winposition(long x1,long x2,long y1,long y2)

******************************************************************************/
/*PROTOTYPE*/
void winposition(long x1,long x2,long y1,long y2)
	{
	long posx,posy,lenx,leny;
	long sizex,sizey;

/* 	printf("\nwinposition(%d,%d,%d,%d)\n",x1,x2,y1,y2); */

	get_dimensions(CurrentWid,FALSE,&posx,&posy,&lenx,&leny);
	posy=ScreenHeight-posy-leny;

/* 	printf(" %d,%d %d,%d\n",posx,posy,lenx,leny); */

	sizex=abs(x2-x1)+1-lenx;
	sizey=abs(y2-y1)+1-leny;

	lenx+=sizex;
	leny+=sizey;

	y1=ScreenHeight-y1-leny;
	y2=ScreenHeight-y2-leny;

	if(x1>x2)
		x1=x2;
	if(y1<y2)
		y1=y2;

	x1-=posx;
	y1-=posy;

/* 	printf(" %d,%d+%d,%d %d,%d+%d,%d\n",posx,posy,x1,y1,lenx,leny,sizex,sizey); */

	/* in two passes to prevent possible crossing of screen borders */
	do_move_and_resize(CurrentWid,x1<0,x1,0,sizex,0);
	do_move_and_resize(CurrentWid,y1<0,0,y1,0,sizey);

	winset(CurrentWid);

	get_dimensions(CurrentWid,FALSE,&posx,&posy,&lenx,&leny);
/* 	printf(" %d,%d %d,%d ->",posx,posy,lenx,leny); */

	posy=ScreenHeight-posy-leny;

/* 	printf("%d\n",posy); */
	}


/******************************************************************************
void	winmove(long orgx,long orgy)

******************************************************************************/
/*PROTOTYPE*/
void winmove(long orgx,long orgy)
	{
	long dx,dy;

	dx=orgx-CurrentPosX;
	dy=orgy-CurrentPosY;

	do_move_and_resize(CurrentWid,FALSE,dx,-dy,0,0);

	winset(CurrentWid);

/* 	MoveWindow(GLWindow[CurrentWid],dx,-dy); */
	}


/******************************************************************************
void	wintitle(char *name)

******************************************************************************/
/*PROTOTYPE*/
void wintitle(char *name)
	{
	strcpy(TitleList[CurrentWid],name);

	drawborder(CurrentWid,0);

	if(NumberWindows==1 && DoubleBufferSet[CurrentWid])
		RedoBorder[CurrentWid]=TRUE;
	}


/******************************************************************************
void	getsize(long *x,long *y)

******************************************************************************/
/*PROTOTYPE*/
void getsize(long *x,long *y)
	{
	*x=CurrentWidth;
	*y=CurrentHeight;
	}


/******************************************************************************
void	getorigin(long *x,long *y)

******************************************************************************/
/*PROTOTYPE*/
void getorigin(long *x,long *y)
	{
	*x=CurrentPosX;
	*y=CurrentPosY;
	}


/*******************************************************************************
long	winopen(char *title)

*******************************************************************************/
/*PROTOTYPE*/
long winopen(char *title)
	{
	long wid=1;

	if(!Foregrounded)
		{
		GL_error("AGL cannot background process: foreground() assumed");

		Foregrounded=TRUE;
		}

	if(!NextWindow_Initialized)
		initialize_nextwindow();

	while(wid<MAX_WINDOWS && GLWindow[wid])
		wid++;

	if(wid==MAX_WINDOWS)
		{
		GL_error("Too many windows");
		return -1;
		}

	if(!Gfx_Initialized)
		gfxinit();

	DefaultWindow.Screen=GLScreen;
	NextWindow.Screen=GLScreen;

	Sizeable[wid]=NextSizeable;
	Bordered[wid]=NextBordered;
	NextSizeable=TRUE;
	NextBordered=TRUE;

	Maximization[wid][0]=BorderWidth;
	Maximization[wid][1]=BorderWidth;
	Maximization[wid][2]=ScreenWidth-2*BorderWidth;
	Maximization[wid][3]=ScreenHeight-2*BorderWidth-BorderHeight;
	
#if COOL_BORDERS

	NextWindow.Flags|=BORDERLESS;

#endif

	if(Bordered[wid])
		{
#if COOL_BORDERS

		NextWindow.LeftEdge-=BorderWidth;
		NextWindow.TopEdge-=BorderWidth+BorderHeight;

		NextWindow.Width+=BorderWidth*2;
		NextWindow.Height+=BorderHeight+BorderWidth*2;

#else

		NextWindow.Flags|= ACTIVATE | WINDOWDRAG | WINDOWCLOSE | GIMMEZEROZERO;

		NextWindow.LeftEdge-=BORDERSIZEX;
		NextWindow.TopEdge-=BORDERSIZEY;

		NextWindow.Height+=BORDERSIZE_TITLEY;
		NextWindow.Width+=BORDERSIZEX*2;

		NextWindow.Title=TitleList[wid];

#endif

		strcpy(TitleList[wid],title);
		}

	GLWindow[wid]=(struct Window *)OpenWindow(&NextWindow);
	if(GLWindow[wid]==NULL)
	 	{
	 	printf("Window won't open: \"%s\"\n",title);
	 	CloseScreen(GLScreen);
	 	CloseLibrary((void *)IntuitionBase);
	 	CloseLibrary((void *)GfxBase);
	 	exit(400);
	 	}

	winset(wid);

	InitArea(&AInfo[wid],AreaBuffer[wid],MAX_POLY_VERTS);
	DrawRPort->AreaInfo= &AInfo[wid];
	TempBuffer[wid]=(PLANEPTR)AllocRaster((ULONG)ScreenWidth,(ULONG)ScreenHeight);
	if(TempBuffer[wid]==NULL)
		{
		GL_error("Error alocating Poly Space");
		return -1;
		}

	DrawRPort->TmpRas=(struct TmpRas *)
				InitTmpRas(&TempRaster[wid],TempBuffer[wid],RASSIZE(ScreenWidth,ScreenHeight));

	SetDrMd(DrawRPort,JAM1);

	Dimensions[wid]=2;

	ortho2(-0.5,CurrentWidth-0.5,-0.5,CurrentHeight-0.5);

	if(Bordered[wid])
		drawborder(wid,0);

	viewport(0,CurrentWidth-1,0,CurrentHeight-1);

	initialize_nextwindow();

	NumberWindows++;

	return wid;
	}


/******************************************************************************
void	gexit(void)

	set as trap to occur on completion of execution

	closes all opened windows
	should result in complete release of all of AGL's resources
******************************************************************************/
/*PROTOTYPE*/
void gexit(void)
	{
	long m;

	printf("KILL AGL\n");

	for(m=1;m<MAX_WINDOWS;m++)
		if(GLWindow[m])
			winclose(m);
	}


/*******************************************************************************
void	winclose(long wid)

*******************************************************************************/
/*PROTOTYPE*/
void winclose(long wid)
	{
	char string[100];
	long temp_wid;
	short m,on;

	NumberWindows--;

	if(GLWindow[wid]==NULL)
		{
		sprintf(string,"cannot close unopened window %d",wid);
		GL_error(string);
		}
	else
		{
		/* remove backbuffer */
		temp_wid=CurrentWid;

		winset(wid);
		singlebuffer();
		gconfig();

		if(GLWindow[temp_wid])
			winset(temp_wid);

		FreeRaster(TempBuffer[wid],(ULONG)ScreenWidth,(ULONG)ScreenHeight);

		CloseWindow(GLWindow[wid]);
		GLWindow[wid]=NULL;
		}

	on=0;
	for(m=1;m<MAX_WINDOWS;m++)
		if(GLWindow[m])
			on=1;

	if(!on)
		{
#if MICE
		free_mousesprite();
		stop_gameport();
#endif

		if(FontPtr)
			CloseFont(FontPtr);
	 	CloseLibrary((void *)DiskfontBase);

		CloseScreen(GLScreen);
	 	CloseLibrary((void *)IntuitionBase);
	 	CloseLibrary((void *)GfxBase);
		}
	}


/*******************************************************************************
void	initialize_nextwindow(void)

*******************************************************************************/
/*PROTOTYPE*/
void initialize_nextwindow(void)
	{
	static short first=1;
	short m;

	if(first)
		{
		BorderWidth=4;
		BorderHeight=11;

		for(m=0;m<MAX_WINDOWS;m++)
			{
			GLWindow[m]=NULL;
			Bordered[m]=FALSE;
			RedoBorder[m]=FALSE;
			DoubleBuffered[m]=FALSE;
			DoubleBufferSet[m]=FALSE;
			Clipped[m]=FALSE;
			}

		first=FALSE;
		}

	memcpy(&NextWindow,&DefaultWindow,sizeof(struct NewWindow));

	NextWindow_Initialized=TRUE;
	}


/******************************************************************************
long	AGLconfig(short screenx,short screeny,short bitplanes)

	this the only AGL specific command

	it configures the screen for all windows to use

	returns TRUE if sucessful, ie. no GL command had been previously issued

******************************************************************************/
/*PROTOTYPE*/
long AGLconfig(short screenx,short screeny,short bitplanes)
	{
	if(Gfx_Initialized)
		{
		GL_error("AGLconfig(): must be called before all GL commands\n");
		return FALSE;
		}
	else
		{
		ScreenDef.ViewModes=NULL;

		if(screeny>225)
			{
/* 			printf("HiRes Lace\n"); */

			if(screenx>720)
				screenx=720;

			if(screeny>450)
				screeny=450;

			if(bitplanes>4)
				bitplanes=4;

			ScreenDef.ViewModes|=HIRES;
			ScreenDef.ViewModes|=LACE;
			}
		else
			{
/* 			printf("LoRes\n"); */

			if(screenx>360)
				screenx=360;

			if(screeny>225)
				screeny=225;

			if(bitplanes>5)
				bitplanes=5;
			}

		ScreenDef.Width=screenx;
		ScreenDef.Height=screeny;
		ScreenDef.Depth=bitplanes;

		ScreenWidth=ScreenDef.Width;
		ScreenHeight=ScreenDef.Height;
		ScreenDeep=ScreenDef.Depth;

		return TRUE;
		}
	}


/*******************************************************************************
void	gfxinit(void)

	startup AGL and initialize all it's resources

*******************************************************************************/
/*PROTOTYPE*/
void gfxinit(void)
	{
	long colors;

	colors=pow(2.0,(float)ScreenDeep);

	GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",0L);
	if(GfxBase==NULL)
	 	{
		GL_error("Error opening GraFiX Library\n");

	 	exit(1);
	 	}

	IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",0L);
	if(IntuitionBase==NULL)
	 	{
		GL_error("Error opening Intuition Library\n");

	 	CloseLibrary((void *)GfxBase);
	 	exit(2);
	 	}

	LayersBase=OpenLibrary("layers.library",0L);
	if(LayersBase==NULL)
	 	{
		GL_error("Error opening Intuition Library\n");

	 	CloseLibrary((void *)IntuitionBase);
	 	CloseLibrary((void *)GfxBase);
	 	exit(3);
	 	}

	GLScreen=(struct Screen *)OpenScreen(&ScreenDef);
	if(GLScreen==NULL)
	 	{
		GL_error("Error opening Screen\n");

	 	CloseLibrary((void *)LayersBase);
	 	CloseLibrary((void *)IntuitionBase);
	 	CloseLibrary((void *)GfxBase);
	 	exit(4);
	 	}

	if(!(OpenDevice("console.device",-1L,(struct IORequest *)&IOStandardRequest,0L)))
		ConsoleDevice=(struct Library *)IOStandardRequest.io_Device;
	else
		{
		GL_error("Error Opening Console\n");

	 	CloseScreen(GLScreen);
	 	CloseLibrary((void *)LayersBase);
	 	CloseLibrary((void *)IntuitionBase);
	 	CloseLibrary((void *)GfxBase);
	 	exit(5);
		}

	DiskfontBase=OpenLibrary("diskfont.library",0L);
	if(DiskfontBase==NULL)
		GL_error("Error opening Diskfont Library\n");

	FontPtr=OpenDiskFont(&StdFont);
	if(FontPtr==NULL)
		GL_error("Error Opening Font\n");

/* 	SetRast(&GLScreen->RastPort,BLUEGREEN); */

	ScreenWidth=GLScreen->Width;
	ScreenHeight=GLScreen->Height;

	GLView= &GLScreen->ViewPort;
	LoadRGB4(GLView,ColorMap,colors);
	DrawType=FALSE;
	CurrentColor=0;
	init_matrices();
	initialize_RGB();

#if MICE
	start_gameport();
	create_mousesprite();
#endif

	qinit();

	Gfx_Initialized=TRUE;

	/* set an exit trap */
	if(atexit(gexit))
		GL_error("Error setting exit trap\n");
	}


/*******************************************************************************
void	GL_error(char *message)

*******************************************************************************/
/*PROTOTYPE*/
void GL_error(char *message)
	{
	printf("Amiga GL Error: %s\n",message);
	}
