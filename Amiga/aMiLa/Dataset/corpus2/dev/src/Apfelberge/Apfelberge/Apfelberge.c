;/*
sc Apfelberge.c link parm r opt math 8 nostkchk ign 306,73 idir "" to ApfelbergeFPU
;sc Apfelberge.c link parm r opt math f nostkchk ign 306,73 idir ""
;gcc -s -O2 -Qn -I. -oApfelbergeMOS Apfelberge.c
quit;*/
/* C: Stefan A. Haubenthal 3/03 */
/* BASIC: G. Paret 7/86, F. Müller 1/87 */

#include <stdlib.h>
#include <joystick.h>
#include <tgi.h>

#ifndef __AMIGADATE__
#define __AMIGADATE__ "("__DATE__")"
#endif
const char VERsion[]="$VER: Apfelberge 3.0 "__AMIGADATE__
#ifdef _M68881
" FPU"
#endif
" $";
#ifdef __CC65__
#define FLOAT int
#define ITOF(x) x
#else
#define FLOAT float
#define ITOF(x) (x)/100.
#endif

const int xm=105, ym=105;
const xc=1, yc=0, t=20, s=60;
FLOAT xl=ITOF(-15), xr=ITOF(26), yo=ITOF(47), yu=ITOF(90);

void calc(FLOAT xl, FLOAT xr, FLOAT yo, FLOAT yu)
{
const FLOAT dx=(xr-xl)/xm, dy=(yu-yo)/ym;
unsigned n, m, k, v, v1, u, u1;
FLOAT y1, x, y, x2, y2;

for (n=0; n<ym; ++n)
	{
	y1=yo+n*dy;
	for (m=0; m<=xm; ++m)
		{
		x=xl+m*dx;
		y=y1;
		k=0;
		do
			{
			x2=x*x;
			y2=y*y;
			y=2*x*y-yc;
			x=x2-y2-xc;
			} while (++k<t && x2+y2<s);
		u=m+53-n/2;
		u1=u+1;
		v=n+80;
		v1=v-3*(k-1);
		tgi_setcolor(3);
		tgi_line(u, v, u, v1);
		tgi_setcolor(2);
		tgi_line(u1, v, u1, v1);
		tgi_setcolor(1);
		tgi_line(u, v1, u1, v1);
		}
	}
}

int p;

main(int argc, char *argv[])
{
short f=1;
#ifdef __JOYSTICK__
int j;

joy_load_driver(joy_stddrv);
p=argc==1 ? joy_count()-1 : atoi(argv[1]);
#endif
tgi_load(TGI_MODE_160_200_4);
tgi_init();
do
	{
	if (f)
		{
//		tgi_clear();
		calc(xl, xr, yo, yu);
//		printf("%f %f %f %f\n", xl, xr, yo, yu);
		f=0;
		}
#ifdef __JOYSTICK__
	j=joy_read(p);
	if (JOY_BTN_UP(j))
		yo-=ITOF(10),yu-=ITOF(10),f=1;
	if (JOY_BTN_DOWN(j))
		yo+=ITOF(10),yu+=ITOF(10),f=1;
	if (JOY_BTN_LEFT(j))
		xl-=ITOF(10),xr-=ITOF(10),f=1;
	if (JOY_BTN_RIGHT(j))
		xl+=ITOF(10),xr+=ITOF(10),f=1;
	} while (!(JOY_BTN_FIRE(j)));
joy_unload();
#else
	} while (0);
#endif
tgi_unload();
}
