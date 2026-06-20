/****************************************************************************/
/*									    */
/*			    3D-Rotaion Routines				    */
/*									    */
/*  CrEatOr: LarZ SamuelssoN (C)			     AD: 1993 	    */
/*									    */
/*  If everything works as planned these routines will be based on the      */
/*  introduction of an Ortho-Normal-base in the vectorobject. The base,	    */
/*  consisting of three orthogonal vectors, will then be rotated and the    */
/*  coordinates of the object's corners will be expressed as linear-        */
/*  combinations of the three base-vectors. 				    */
/*  I will also try to substitute the sine-functions with sine-tables.      */
/*  When calculating the perspective I will use logarithm- and 		    */
/*  exponential-tables of the natural logarithm.			    */
/*  If I have any strenght left after these speed-ups I will look for	    */
/*  further optimizations. 						    */
/*									    */
/*  I will do my best to comment the code (I need 'em too)		    */
/*									    */
/****************************************************************************/

/****************************************************************************/
/*									    */
/*  Version 0.01: Plain ordinary rotation... calculating every new point    */
/*		  by multiplying the rotation-matrix with the vector 	    */
/*  (SLOW)	  representing a corner in the object. 			    */
/*									    */
/****************************************************************************/

#include <X11/Xlib.h>	/* openscreen & drawing stuff			    */
#include <stdio.h>	/* the usual I/O				    */
#include <math.h>	/* sin() and cos()				    */
#include <stdlib.h>

#define	CORNERS 8	/* I will be rotating a cube which has 8 corners    */
#define DIM	3	/* Nr of coordinates needed to descibe a corner     */

typedef	float 	Vob[ CORNERS ][ DIM ];		/* my vector-object type    */

/* Draw a line relative (ox,oy) from (x,y) to (xe, ye) on rootwindow        */
void DrawLine(int x, int y, int xe, int ye, int ox, int oy);

/* Initializes the X-Crap						    */
void Init(void);

/* Makes X happy on exit						    */
void Exit(void);

/* Clear the root (I bet you never could have guessed that)		    */
void Cls(void);

/* Calculates and returns the corners with perspective			    */
Vob * Perspect(Vob * em, int depth);

/* Calculates and 'returns' the corners rotated w1,w2,w3       		    */
void Rotate(Vob * em, float matrix[][ DIM ]);

/* Draws the object on the rootwindow with the corners are scaled 	    */
void DrawOb(Vob * em, int scale, int cx, int cy, int pixel);

/* These are the variables set out to explore the unknown (X)	            */

Display 		*dpy;
XColor 			xcolour;
GC 			gc;
XGCValues 		xgcvalues;
XSetWindowAttributes 	xsetwattrs;
int			scrn, pixel;

int main (void)
{
  	int 	cx = 600;	/* Center of rotation (rootwindow coords)   */
	int 	cy = 400;

	float 	wx = 0;		/* Step-Rotation-Angles around the axises   */
	float	wy = 0.02;
	float	wz = 0;

	int 	depth = 10;	/* Perspective depth 			    */
	int	scale = 200;	/* Scaling factor (in pixels)		    */

	/* This is the object we will be dealing with, hence, a cube.	    */
	/* The numerous ones are the coordinates of the cube's corners and  */
	/* three unos sealed in brackets represent a vector pointing at the */
	/* corner of the cube. Everything is calculated relative the center */
	/* of the cube, which is located in { 0, 0, 0 }			    */

	Vob 	cube =
	{
		{  1,  1,  1 },
		{  1, -1,  1 },
		{  1, -1, -1 },
		{  1,  1, -1 },
		{ -1,  1, -1 },
		{ -1,  1,  1 },
		{ -1, -1,  1 },
		{ -1, -1, -1 },
 	};

	Vob *	pos;		/* Holds the position of the cube's corners */
				/* during the calculations		    */

	float matrix[ DIM ][ DIM ];

	/* This is the rotation-matrix for rotation around three axises	    */
	/* and I won't explain the maths needed to understand it. 	    */
	/* Further reading: (any?) University Text about Linear Algebra	    */

	matrix[0][0] =  cos(wx) * cos(wy);
  	matrix[0][1] = -sin(wz) * cos(wx) - sin(wx) * sin(wy) * cos(wz);
  	matrix[0][2] =  sin(wx) * sin(wz) - sin(wy) * cos(wx) * cos(wz);
  	matrix[1][0] =  sin(wz) * cos(wy);
  	matrix[1][1] = 	cos(wx) * cos(wz) - sin(wx) * sin(wy) * sin(wz);
  	matrix[1][2] = -sin(wx) * cos(wz) - sin(wy) * sin(wz) * cos(wx);
  	matrix[2][0] =  sin(wy);
  	matrix[2][1] =  sin(wx) * cos(wz);
  	matrix[2][2] =  cos(wx) * cos(wz);

	Init( );
	Cls( );
	pos = &cube;
	while (4711)
	{
		DrawOb( Perspect( pos, depth ), scale, cx, cy, 
			BlackPixel(dpy, scrn) );
							/* black */
		Rotate( pos, matrix );

		DrawOb( Perspect( pos, depth ), scale, cx, cy, 
			WhitePixel(dpy, scrn) );
	}						/* white */
	Exit( );
  	return 0;
}

void DrawOb(Vob * em, int scale, int cx, int cy, int pixel)
{
	Vob v;
	int i;

	/* The mathematical cube (the one we use in our calcs) 	*/
	/* has got a sidelenght of 1+1=2, which is quite small 	*/
	/* if we consider it as pixels. Therefore we have to 	*/
	/* scale the vectors by a number, i e scale determines  */
	/* the on-screen-size of the cube			*/	

	for ( i=0; i<CORNERS; i++ )
	{
		v[i][0] = scale*(*em)[i][0];
		v[i][1] = scale*(*em)[i][1];
	}
			    /* set color */

	xgcvalues.foreground = pixel;
  	XChangeGC (dpy,gc,GCForeground, &xgcvalues);
	
	/* Cube specific - depends on how the cube was defined 	*/
	/* in the array declaration. If you draw a picture of  	*/
	/* the cube with it's center in oirgo (0,0,0) and plot 	*/
	/* the corners ( {1,1,1}, {1,-1,1}, etc ) it's quite   	*/
	/* easy to see which lines should be drawn.		*/

	DrawLine(v[0][0], v[0][1], v[1][0], v[1][1], cx, cy);
	DrawLine(v[1][0], v[1][1], v[2][0], v[2][1], cx, cy);
	DrawLine(v[2][0], v[2][1], v[3][0], v[3][1], cx, cy);
	DrawLine(v[3][0], v[3][1], v[4][0], v[4][1], cx, cy);
	DrawLine(v[4][0], v[4][1], v[5][0], v[5][1], cx, cy);
	DrawLine(v[5][0], v[5][1], v[6][0], v[6][1], cx, cy);
	DrawLine(v[6][0], v[6][1], v[7][0], v[7][1], cx, cy);
	DrawLine(v[6][0], v[6][1], v[1][0], v[1][1], cx, cy);
	DrawLine(v[7][0], v[7][1], v[4][0], v[4][1], cx, cy);
	DrawLine(v[5][0], v[5][1], v[0][0], v[0][1], cx, cy);
	DrawLine(v[1][0], v[1][1], v[6][0], v[6][1], cx, cy);
	DrawLine(v[3][0], v[3][1], v[0][0], v[0][1], cx, cy);
	DrawLine(v[2][0], v[2][1], v[7][0], v[7][1], cx, cy);
}

/* This is where the perspective is calculated. I use a method where I      */
/* introduce a line on parametric form from a point on the z-axis to each   */
/* of the cube's corners. I let the screen be the (x,y)-plane and project   */
/* the corner point on to the screen ((x,y)-plane) in the direction of the  */
/* line.								    */

Vob * Perspect(Vob * em, int depth)
{
	Vob temp;
	int i;	

	for ( i=0; i<CORNERS; i++ )
	{
		temp[i][0] = (*em)[i][0]*depth/(depth-(*em)[i][2]);
		temp[i][1] = (*em)[i][1]*depth/(depth-(*em)[i][2]);
	}
	return &temp;
}

/* This is where I multiply the matrix with the corner-vectors to yield     */
/* the new corner-position. I use a temp vector to hold the values during   */
/* claculation because I cannot change the 'real' values as they appear in  */
/* every step of the calc.						    */

void Rotate(Vob * em, float matrix[][ DIM ])
{
        Vob temp;
	int i,j;

	for ( i=0; i<CORNERS; i++ )			
	{
	  	temp[i][0] = matrix[0][0]*(*em)[i][0] +
		             matrix[0][1]*(*em)[i][1] +
			     matrix[0][2]*(*em)[i][2];
	  	temp[i][1] = matrix[1][0]*(*em)[i][0] +
		             matrix[1][1]*(*em)[i][1] +
			     matrix[1][2]*(*em)[i][2];
	  	temp[i][2] = matrix[2][0]*(*em)[i][0] +
		             matrix[2][1]*(*em)[i][1] +
			     matrix[2][2]*(*em)[i][2];
	}
	for ( i=0; i<CORNERS; i++ ) 
		for ( j=0; j<DIM; j++ ) 
			(*em)[i][j] = temp[i][j];
}

/* Someone showed me how to initialize a screen and stuff in X so I can't   */
/* explain any of the following stuff... The imprortance is that they work  */
/* and the drawing routines are probably a bit different on the machines    */
/* I'll be using these routines on later...				    */

void DrawLine(int x, int y, int xe, int ye, int ox, int oy)
{
	XDrawLine(dpy, RootWindow(dpy,scrn), gc, ox+x, oy+y, ox+xe, oy+ye);
}

void Cls(void)
{
    	XClearWindow(dpy,RootWindow(dpy,scrn));
}

void Init(void)
{
	if (!(dpy = XOpenDisplay (NULL))) 
   	{
      		fprintf (stderr, "Cannot open display.\n");
      		exit(1);
    	}
  	scrn 				= DefaultScreen(dpy);
	xsetwattrs.backing_store 	= Always;
 	xsetwattrs.background_pixel 	= BlackPixel(dpy,scrn);
	pixel 				= WhitePixel(dpy,scrn);

  	XChangeWindowAttributes(dpy,RootWindow(dpy,scrn),
			 	CWBackingStore|CWBackPixel,
				&xsetwattrs);
  	if (XParseColor(dpy, DefaultColormap(dpy,scrn), "khaki2", &xcolour))
    		if (XAllocColor (dpy, DefaultColormap(dpy,scrn), &xcolour))
      			pixel = xcolour.pixel;

  	gc = XCreateGC (dpy, RootWindow(dpy,scrn),0,NULL);
}
	
void Exit(void)
{
	XFlush (dpy);
}

