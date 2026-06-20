#include<exec/types.h>
#include<intuition/intuitionbase.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>

#ifdef __SASC
#include<functions.h>
#endif

#ifdef AZTEC_C
#include<functions.h>
#endif

#ifdef LATTICE
#include<lattice_amiga.h>
#define SEEK_CUR 1
#endif

#include<gl.h>
#include<device.h>

#define PIE	3.14159265
#define DEG	(PIE/180.0)

#define MOVETEST	FALSE
#define REDRAWTEST	FALSE

#include"prototypes.h"

short CubeVert[8][3]=
	{
	-1,-1,-1,
	-1,-1, 1,
	-1, 1, 1,
	-1, 1,-1,
	 1,-1,-1,
	 1,-1, 1,
	 1, 1, 1,
	 1, 1,-1,
	};

short CubeEdge[16]=
	{
	1,2,3,0,
	3,7,6,2,
	6,5,4,7,
	4,0,1,5,
	};

long Focus,Wid[10],MaxX,MaxY;

short EventDebug=FALSE;
short DoubleBuffer=TRUE;
short Window0=FALSE;
short Window1=FALSE;
short Window2=FALSE;


/******************************************************************************
int	main(int argc,char **argv)

******************************************************************************/
/*PROTOTYPE*/
int main(int argc,char **argv)
	{
	long mx,my;
	long frame=0;

	short quit=0;
	short signal;
	short data;
	short hires=FALSE;
	short c,m;

	printf("gltest: little test program for Amiga GL by Jason Weber\n");
	printf("\nArguments: s=singlebuffer  h=hires  1,2=toggle which windows to run  e=print events\n");
	printf("\nTo kill, hit ESC or button in upper left of window\n\n");

	if(argc>1)
		{
		for(m=0;m<strlen(argv[1]);m++)
			switch(c=argv[1][m])
				{
				case 'e':
					EventDebug=TRUE;
					break;
				case 's':
					DoubleBuffer=FALSE;
					break;
				case 'h':
					hires=TRUE;
					break;
				case '1':
					Window0^=TRUE;
					break;
				case '2':
					Window1^=TRUE;
					break;
#if TRUE
				case '3':
					Window2^=TRUE;
					break;
#endif
				}
		}

	/* force at least 1 window open */
	if(!Window1 && !Window2)
		Window0=TRUE;

#if _AMIGA

	/* optionally use lores, (hires is default) */
	if(!hires)
		AGLconfig(350,225,4);

#endif

	MaxX=getgdesc(GD_XPMAX);
	MaxY=getgdesc(GD_YPMAX);
	Focus=0;

	foreground();

	if(Window0)
		window0(frame,TRUE);

	if(Window1)
		window1(frame,TRUE);

	if(Window2)
		window2(frame,TRUE);

	mapcolor(8,112,112,112);

	qdevice(WINQUIT);
	qdevice(ESCKEY);
	qdevice(KEYBD);
	qdevice(F5KEY);
	qdevice(TWOKEY);
	qdevice(SEVENKEY);
	qdevice(LEFTMOUSE);
	qdevice(MIDDLEMOUSE);
	qdevice(RIGHTMOUSE);

	tie(MIDDLEMOUSE,MOUSEX,MOUSEY);
	tie(SEVENKEY,MOUSEY,0);

	while(!quit)
		{
		while(qtest())
			{
			signal=qread(&data);

			switch(signal)
				{
				case REDRAW:
					if(EventDebug)
						printf("REDRAW      %d\n",data);

#if REDRAWTEST
					if(Window2 && data==Wid[2])
						window2(frame,FALSE);
#endif

					break;

				case INPUTCHANGE:
					if(EventDebug)
						printf("INPUTCHANGE %d\n",data);
					Focus=data;
					break;

				case KEYBD:
					if(EventDebug)
						printf("KEYBD       %3d '%c'\n",data,data);
					break;

				case F5KEY:
					if(EventDebug)
						printf("F5KEY       %3d\n",data);
					break;

				case TWOKEY:
					if(EventDebug)
						printf("TWOKEY      %3d\n",data);
					break;

				case SEVENKEY:
					if(EventDebug)
						printf("SEVENKEY    %3d\n",data);
					break;

				case MOUSEX:
					if(EventDebug)
						printf("MOUSEX      %d\n",data);
					break;

				case MOUSEY:
					if(EventDebug)
						printf("MOUSEY      %d\n",data);
					break;

				case LEFTMOUSE:
					if(EventDebug)
						printf("LEFTMOUSE   %d\n",data);
					break;

				case MIDDLEMOUSE:
					if(EventDebug)
						printf("MIDDLEMOUSE %d\n",data);
					break;

				case RIGHTMOUSE:
					if(EventDebug)
						printf("RIGHTMOUSE  %d\n",data);
					break;

				case WINQUIT:
					if(EventDebug)
						printf("WINQUIT     %d\n",data);

				case ESCKEY:
					quit=1;
					break;

				default:
					printf("Undefined queue: signal=%d data=%d\n",signal,data);
					break;
				}
			}

		if(Window0)
			window0(frame,FALSE);

		if(Window1)
			window1(frame,FALSE);

#if !REDRAWTEST

		if(Window2)
			window2(frame,FALSE);

#endif

		frame++;
		}

	if(Window0)
		winclose(Wid[0]);
	if(Window1)
		winclose(Wid[1]);
	if(Window2)
		winclose(Wid[2]);

	return 0;
	}


/******************************************************************************
void	drawcube(short fill)

******************************************************************************/
/*PROTOTYPE*/
void drawcube(short fill)
	{
	static char string[2];
	short i,j;

	if(fill)
		{
		for(j=0;j<4;j++)
			{
			bgnpolygon();

			for(i=0;i<4;i++)
				v3s(CubeVert[CubeEdge[j*4+i]]);

			endpolygon();
			}
		}
	else
		{
		bgnline();

		for(i=0;i<16;i++)
			v3s(CubeVert[CubeEdge[i]]);

		endline();
		}
	}


/******************************************************************************
void	window0(long frame,long init)

	Spinning Cube

******************************************************************************/
/*PROTOTYPE*/
void window0(long frame,long init)
	{
	char string[100];
	long x,y,size;
	long mx,my;
	long wx,wy;
	float angle;

	if(init)
		{
		x=MaxX/8;
		y=MaxY/10;
		size=MaxY/4;

/* 		noborder(); */
/* 		prefposition(x,x+size*3/2,y,y+size); */
		prefsize(size*3/2,size);

		Wid[0]=winopen("Spin Cube");
		if(DoubleBuffer)
			doublebuffer();
		gconfig();
		}
	else
		{
		winset(Wid[0]);

#if MOVETEST

		while(getbutton(MIDDLEMOUSE))
			{
			mx=getvaluator(MOUSEX);
			my=getvaluator(MOUSEY);

			winmove(mx-20,my-20);
			}


		mx=getvaluator(MOUSEX)-20;
		my=getvaluator(MOUSEY)-20;

		if(getbutton(RIGHTMOUSE))
			winposition(mx,mx+20+frame%20,my,my+20+(frame+15)%30);

#endif


		angle=frame*2.0;

		if(frame%50 == 0)
			{
			sprintf(string,"Spin Cube %d",frame);
			wintitle(string);
			}

		getsize(&wx,&wy);
		viewport(0,wx-1,0,wy-1);
		perspective(600,wx/(float)wy,0.1,10.0);

		pushmatrix();

		translate(0.0,0.0,5.0);
		rot(angle,'x');
		rot(angle,'z');

		color(BLUE);
		clear();

		color(YELLOW);
		drawcube(FALSE);

		popmatrix();
		if(DoubleBuffer)
			swapbuffers();
		}
	}


/******************************************************************************
void	window1(long frame,long init)

	Moving Scene

******************************************************************************/
/*PROTOTYPE*/
void window1(long frame,long init)
	{
	static float stator1[4][2]=
		{
		-1.0,	-1.0,
		1.0,	-1.0,
		1.0,	1.0,
		-1.0,	1.0,
		};
	static float stator2[8][2];
	static float rotor[5][2]=
		{
		0.0,	-0.8,
		0.4,	-0.4,
		-0.4,	0.4,
		0.0,	0.8,
		};
	static float craft[5][2]=
		{
		-0.3,	-1.0,
		-0.5,	0.0,
		0.0,	1.0,
		0.5,	0.0,
		0.3,	-1.0,
		};

	char string[100];

	long wx,wy,mx,my,v;
	long x,y,size;

	float angle;


	if(init)
		{
		noborder();

		x=MaxX/2;
		y=MaxY/3;
		size=MaxX/3;

		prefposition(x,x+size,y,y+size);
		Wid[1]=winopen("Scene");

		if(DoubleBuffer)
			doublebuffer();
		gconfig();

		for(v=0;v<8;v++)
			{
			angle=v*45*DEG;
			stator2[v][0]=0.8*sin(angle);
			stator2[v][1]=0.8*cos(angle);
			}
		}
	else
		{
		winset(Wid[1]);
		ortho2(-10.0,10.0,-10.0,10.0);

		angle=frame*3.0;

		color(8);
		clear();

		pushmatrix();
		pushmatrix();

		translate(0.0,8.5,0.0);

		color(WHITE);

		cmovs((short)-8,(short)0,(short)0);
		if(getbutton(LEFTMOUSE))
			charstr("Left");

		cmov2s((short)-2,(short)0);
		if(getbutton(MIDDLEMOUSE))
			charstr("Middle");

		cmov(4.0,0.0,0.0);
		if(getbutton(RIGHTMOUSE))
			charstr("Right");

		translate(0.0,-1.5,0.0);

		cmovs((short)-8,(short)0,(short)0);
		if(getbutton(TWOKEY))
			charstr("Two");

		cmov2s((short)-2,(short)0);
		if(getbutton(SEVENKEY))
			charstr("Seven");

		cmov2s((short)4,(short)0);
		if(getbutton(F5KEY))
			charstr("F5");

		translate(0.0,-1.5,0.0);

		getorigin(&wx,&wy);
		mx=getvaluator(MOUSEX);
		my=getvaluator(MOUSEY);
		sprintf(string,"%3d,%3d %3d,%3d",mx,my,mx-wx,my-wy);
		cmov2(-8.0,0.0);
		charstr(string);

		translate(0.0,-1.5,0.0);
		sprintf(string,"Focus %d",Focus);
		cmov2(0.0,0.0);
		charstr(string);

		popmatrix();

		pushmatrix();

		translate(-5.0,3.0,0.0);
		scale(1.5,1.5,1.5);

		color(11);
		bgnpolygon();
		for(v=0;v<4;v++)
			v2f(stator1[v]);
		endpolygon();

		color(15);
		bgnpolygon();
		for(v=0;v<8;v++)
			v2f(stator2[v]);
		endpolygon();

		color(GREEN);
		rot(-4.0*angle,'z');
		bgnpolygon();
		for(v=0;v<4;v++)
			v2f(rotor[v]);
		endpolygon();

		popmatrix();

		translate(2.0,-3.0,0.0);
		rot(angle,'z');
		translate(5.0,0.0,0.0);

		color(RED);
		bgnpolygon();
		for(v=0;v<5;v++)
			v2f(craft[v]);
		endpolygon();

		pushmatrix();

		scale(1.0+0.5*sin(frame/2.0),0.75+0.25*cos(frame/2.0),0.0);
		color(GREEN);
		bgnpolygon();
		for(v=0;v<5;v+=2)
			v2f(craft[v]);
		endpolygon();

		popmatrix();

		color(BLUE);
		cmov2(0.0,0.0);
		charstr("  Scout");

		popmatrix();

		if(DoubleBuffer)
			swapbuffers();
		}
	}



/******************************************************************************
void	window2(long frame,long init)

	Shaded Plane

******************************************************************************/
/*PROTOTYPE*/
void window2(long frame,long init)
	{
	static float backcolor[3]={0.0,1.0,1.0};
	static float forecolor[3]={1.0,1.0,0.0};

	float specific_color[3];

	char string[100];

	long x,y,size;
	long wx,wy;

	float angle;
	float scale;

	if(init)
		{
		x=MaxX/10;
		y=MaxY/2;
		size=MaxY/3;

		prefposition(x,x+size*3/2,y,y+size);
/* 		prefsize(size*3/2,size); */
		Wid[2]=winopen("Filled Box");

		if(DoubleBuffer)
			doublebuffer();

		RGBmode();

		gconfig();
		}
	else
		{
		winset(Wid[2]);

		angle=frame*2.0;

		getsize(&wx,&wy);
		viewport(0,wx-1,0,wy-1);
		perspective(600,wx/(float)wy,0.1,10.0);

		pushmatrix();

		translate(0.0,0.0,5.0);
		rot(angle,'x');
		rot(angle,'z');

		scale=0.5+0.5*sin(angle*DEG);
		for(x=0;x<3;x++)
			specific_color[x]=scale*backcolor[x];
		c3f(specific_color);
		clear();

		scale=0.5+0.5*cos(angle*DEG);
		for(x=0;x<3;x++)
			specific_color[x]=scale*forecolor[x];
		c3f(specific_color);
		drawcube(TRUE);

		popmatrix();
		if(DoubleBuffer)
			swapbuffers();
		}
	}
