#ifdef _AMIGA
#include<exec/types.h>
#include<intuition/intuitionbase.h>
#include<functions.h>
#endif

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>
#include<gl.h>
#include<device.h>

#define MINDIST 4.0

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

short CubeEdge[24]=
    {
    1,2,3,0,
    4,5,1,0,
    4,7,6,5,
    6,7,3,2,
    6,2,1,5,
    4,0,3,7,
    };

int main(int argc,char **argv,char **envp)
	{
	long screenx,screeny;
	long wx,wy;
	long lastx,lasty;
	long wid;

	short left=FALSE,middle=FALSE;
	short quit=FALSE;
	short dbuffer=TRUE;
	short hires=FALSE;
	short breakout;
    short signal,data;
	short c,m;
	short i,j;

	float distance=MINDIST;
	float theta=0.0,phi=0.0,delta_theta=0.0,delta_phi=0.0;

	/* decipher argument: s for single buffer, h for hires (Amiga only) */
    if(argc>1)
        {
        for(m=0;m<strlen(argv[1]);m++)
            switch(c=argv[1][m])
                {
                case 's':
                    dbuffer=FALSE;
                    break;
                case 'h':
                    hires=TRUE;
                    break;
                }
        }

#if _AMIGA

    /* optionally use hi-res, (lo-res is default) */
    if(hires)
        AGLconfig(640,400,4);
    else
        AGLconfig(350,225,4);

#endif

	/* get screen size */
    screenx=getgdesc(GD_XPMAX);
    screeny=getgdesc(GD_YPMAX);

	/* run process in foreground */
    foreground();

	/* set window size and open */
	prefsize(screenx/2,screeny/2);
	wid=winopen("box");

	/* release non-sizable constraint */
	winconstraints();

	/* optionally activate double buffering */
	if(dbuffer)
		doublebuffer();
	gconfig();

	/* don't draw backfacing polygons */
	backface(TRUE);

	/* que some events */
	qdevice(WINQUIT);
    qdevice(ESCKEY);
    qdevice(LEFTMOUSE);
    qdevice(RIGHTMOUSE);

	/* tie position event to middle mouse button */
	tie(RIGHTMOUSE,MOUSEX,MOUSEY);

	/* event loop */
    while(!quit)
        {
		breakout=FALSE;

		/* while events still on que */
        while(qtest() && !breakout)
            {
            signal=qread(&data);

            switch(signal)
                {
                case WINQUIT:
                case ESCKEY:
					quit=TRUE;
                    break;

				case LEFTMOUSE:
					if(data)
						{
						left=TRUE;
						qdevice(MOUSEY);
						lasty=getvaluator(MOUSEY);
						}
					else
						{
						left=FALSE;
						unqdevice(MOUSEY);
						}
					break;

				case RIGHTMOUSE:
					if(data)
						{
						middle=TRUE;
						qdevice(MOUSEX);
						qdevice(MOUSEY);
						lastx=getvaluator(MOUSEX);
						lasty=getvaluator(MOUSEY);
						}
					else
						{
						middle=FALSE;
						delta_theta=getvaluator(MOUSEX)-lastx;
						delta_phi=getvaluator(MOUSEY)-lasty;
						unqdevice(MOUSEX);
						unqdevice(MOUSEY);
						}
					break;

				case MOUSEX:
					if(middle)
						{
						delta_theta=data-lastx;
						lastx=data;
						}
					break;

				case MOUSEY:
					if(middle)
						{
						delta_phi=data-lasty;
						lasty=data;
						breakout=TRUE;
						}
					else if(left)
						{
						distance+=data-lasty;
						lasty=data;

						if(distance<MINDIST)
							distance=MINDIST;
						breakout=TRUE;
						}
					break;
				}
			}

		theta+=delta_theta;
		phi+=delta_phi;

		if(middle)
			{
			delta_theta=0.0;
			delta_phi=0.0;
			}

		pushmatrix();

		/* tranlate and rotate cube into position */
		translate(0.0,0.0,distance);
		rot(-phi,'x');
		rot(theta,'y');

		/* get window size and reset view */
		getsize(&wx,&wy);
		viewport(0,wx-1,0,wy-1);
		perspective(600,wx/(float)wy,0.1,10.0);

		/* background */
		color(CYAN);
		clear();

		/* six faces */
		for(j=0;j<6;j++)
			{
			color(j);

			bgnpolygon();

			for(i=0;i<4;i++)
				v3s(CubeVert[CubeEdge[j*4+i]]);

			endpolygon();
			}

		popmatrix();

		if(dbuffer)
			swapbuffers();
		}

	winclose(wid);
	return 0;
	}
