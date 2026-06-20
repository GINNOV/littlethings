#include <stdio.h>

#ifdef SGI
#include "gl.h"
#include "device.h"
#include "hershey.h"
#else
#include "vogl.h"
#include "vodevice.h"
#endif

/*
 *	An array of points for a polygon
 */
static Coord	parray[][3] = {
	{-8.0, -8.0, 0.0},
	{-5.0, -8.0, 0.0},
	{-5.0, -5.0, 0.0},
	{-8.0, -5.0, 0.0}
};

/*
 * drawpoly
 *
 *	draw some polygons
 */
void drawpoly(void)
{
	float	vec[3];
	short	val;

	color(YELLOW);

	/*
	 * Draw a polygon using poly, parray is our array of
	 * points and 4 is the number of points in it.
	 */
	poly(4L, parray);

	color(GREEN);

	/*
	 * Draw a 5 sided figure by using bgnpolygon, v3d, and endpolygon
	 */
	polymode(PYM_LINE);
	bgnpolygon();
		vec[0] = 0.0;
		vec[1] = 0.0;
		vec[2] = 0.0;
		v3f(vec);
		vec[0] = 3.0;
		vec[1] = 0.0;
		vec[2] = 0.0;
		v3f(vec);
		vec[0] = 3.0;
		vec[1] = 4.0;
		vec[2] = 0.0;
		v3f(vec);
		vec[0] = -1.0;
		vec[1] = 5.0;
		vec[2] = 0.0;
		v3f(vec);
		vec[0] = -2.0;
		vec[1] = 2.0;
		vec[2] = 0.0;
		v3f(vec);
	endpolygon();

	color(MAGENTA);

	/*
	 * draw a sector representing a 1/4 circle
	 */
	arc(1.5, -7.0, 3.0, 0, 900);

	move2(1.5, -7.0);
	draw2(1.5, -4.0);

	move2(1.5, -7.0);
	draw2(4.5, -7.0);

	qread(&val);
}

/*
 * drawpolyf
 *
 *	draw some filled polygons
 */
void drawcircle(void)
{
	color(YELLOW);
	circ(1.5,-7.0,2.0);
	// swapbuffers();
}

/*
 * Using polygons, hatching, and filling.
 */
int main(void)
{
	int	i;


	winopen("poly");

	unqdevice(INPUTCHANGE);
	qdevice(KEYBD);		/* enable keyboard */

	// doublebuffer();

	color(BLACK);		/* clear to black */
	clear();

	/*
	 * world coordinates are now in the range -10 to 10
	 * in x, y, and z. Note that positive z is towards us.
	 */
	ortho(-10.0, 10.0, -10.0, 10.0, 10.0, -10.0);

	color(YELLOW);

	drawcircle();
		
	for(i=16;i<40;i++)
	{
		rot((float)(i/2), 'x');
		rot((float)(i/2)+6.0, 'z');
		rot((float)(i/5), 'y');
	}
	
	gexit();
}
