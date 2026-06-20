/****************************************************************************/
/*									    */
/*			    3D-Rotaion Routines				    */
/*									    */
/*  CrEatOr: LarZ SamuelssoN (C)			     AD: 1993 	    */
/*									    */
/*  Version 0.02: Now I'm using an ON-base in the rotaion sequence and I    */
/*		  calculate the corners of the object as linear 	    */
/*  (FASTER)	  combinations of the base. This saves a lot of muls.	    */
/*		  Unfortunately, the increase in rotationspeed can hardly   */
/*		  be noticed as the drawing routines are MEGA-slow and 	    */
/*		  limits the speed of output.				    */
/*		  Maybe someone can write 'em in asm for me :)		    */
/*		  I also added a routine that draws filled-vector gfx.	    */
/*		  ( I sure hope you ppl out there got color support )	    */
/*									    */
/****************************************************************************/

#include <X11/Xlib.h>	/* Graphics Stuff				    */
#include <X11/X.h>	/* Graphics defines				    */
#include <stdio.h>	/* standard					    */
#include <math.h>	/* math						    */
#include <stdlib.h>	/* exit()					    */
#include <string.h>	/* Yes, I'm actually gonna type an errormessage     */

#define	CORNERS 8	/* I will be rotating a cube which has 8 corners    */
#define DIM	3	/* Nr of coordinates needed to descibe a corner     */
#define PTS	4	/* Nr of points to contain a surface		    */

typedef float   Base[ DIM ];			/* my base-vector   type    */
typedef	float	Vob[ CORNERS ][ DIM ];		/* my vector-object type    */

/* Draw a line relative (ox,oy) from (x,y) to (xe, ye) on rootwindow        */
void DrawLine(int x, int y, int xe, int ye, int ox, int oy);

/* Draw a solid polygon relative (ox,oy) cointained by (x1, y1) - (x4, y4)  */
void DrawSolid(int x1, int y1, int x2, int y2,
	       int x3, int y3, int x4, int y4, int ox, int oy);

/* Set color								    */
void SetCol(char * str);

/* Initializes the X-Crap						    */
void Init(void);

/* Makes X happy on exit						    */
void Exit(void);

/* Clear the root (I bet you never could have guessed that)		    */
void Cls(void);

/* Calculates and returns the corners with perspective			    */
Vob * Perspect(Vob * em, int depth);

/* Calculates and 'returns' the corners rotated w1,w2,w3 using the three    */
/* base-vectors e1,e2,e3 						    */
void Rotate(Vob * em, float matrix[][ DIM ], Base * e1, Base * e2, Base * e3);

/* Draws the object (lines) on the rootwindow with the corners scaled	    */
void DrawLOb(Vob * em, int s, int x, int y, int col);

/* Draws the object (solid) on the rootwindow with the corners scaled	    */
void DrawSOb(Vob * em, Base e1, Base e2, Base e3, int s, int x, int y, int p);

/* These are the variables set out to explore the unknown (X)	            */

Display 		*dpy;
XPoint			mypoints[ PTS ];
XColor 			xcolour;
GC 			gc;
XGCValues 		xgcvalues;
XSetWindowAttributes 	xsetwattrs;
int			scrn, pixel;

int main (int argc, char * argv[])
{
  	int 	cx = 600;	/* Center of rotation (rootwindow coords)   */
	int 	cy = 400;

	float 	wx = 0.015;	/* Step-Rotation-Angles around the axises   */
	float	wy = 0.010;
	float	wz = 0.005;

	int 	depth = 5;	/* Perspective depth 			    */
	int	scale = 200;	/* Scaling factor (in pixels)		    */

	/* This is our three base vectors (if we were to rotate a 4-dim     */
	/* cube we would need four base vectors). As you can see these are  */
	/* unit vectors in the 3-dim euclidian space, though you could use  */
	/* any other three vectors that aren't linearly dependent, but I    */
	/* wouldn't recommend that as the coordinates for the cube relative */
	/* those would be harder to find.				    */ 

	Base e1 = { 1, 0, 0 };
	Base e2 = { 0, 1, 0 };
	Base e3 = { 0, 0, 1 };

	/* This is the object we will be dealing with, hence, a cube.	    */
	/* The numerous ones are the coordinates of the cube's corners, but */
	/* this time these will only be used as the initial position of the */
	/* object. Actually we wouldn't have to use this at all, but it     */
	/* makes life easier when we want to see which linear combination   */
	/* of the base vectors each of the cube's corner represent.	    */

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

	/* Following here is the main() - function. I added some nice 	    */
	/* command line options to make life easier.... 		    */
	/* The important part here is calling the different functions B)    */ 

	Init( );
	Cls( );

	pos = &cube;
	if ( argc == 1 || argc >= 3 )	
	{
		printf("Use with options:   -s (solid cube)\n");
		printf("		    -w (wireframe)\n");
		exit(1);
	}

	if ( !strcmp( argv[1], "-s" ) )
		while (4711)
		{
			Cls( );  
		
			Rotate( pos, matrix, &e1, &e2, &e3 );	

			DrawSOb( Perspect( pos, depth ), e1, e2, e3, 
				 scale, cx, cy, depth ); 
		}

	if ( !strcmp( argv[1], "-w" ) )
		while (4711)
		{ 
			DrawLOb( Perspect( pos, depth ), scale, cx, cy, 
			 	 BlackPixel(dpy, scrn) ); 
				
			Rotate( pos, matrix, &e1, &e2, &e3 );

			DrawLOb( Perspect( pos, depth ), scale, cx, cy, 
				 WhitePixel(dpy, scrn) ); 
		} 				

	Exit( );
  	return 0;
}

void DrawLOb(Vob * em, int s, int x, int y, int col)
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
		v[i][0] = s*(*em)[i][0];
		v[i][1] = s*(*em)[i][1];
	}
			    /* set color */

	xgcvalues.foreground = col;
  	XChangeGC (dpy,gc,GCForeground, &xgcvalues);
	
	/* Cube specific - depends on how the cube was defined 	*/
	/* in the array declaration. If you draw a picture of  	*/
	/* the cube with it's center in oirgo (0,0,0) and plot 	*/
	/* the corners ( {1,1,1}, {1,-1,1}, etc ) it's quite   	*/
	/* easy to see which lines should be drawn.		*/

	DrawLine(v[0][0], v[0][1], v[1][0], v[1][1], x, y);
	DrawLine(v[1][0], v[1][1], v[2][0], v[2][1], x, y);
	DrawLine(v[2][0], v[2][1], v[3][0], v[3][1], x, y);
	DrawLine(v[3][0], v[3][1], v[4][0], v[4][1], x, y);
	DrawLine(v[4][0], v[4][1], v[5][0], v[5][1], x, y);
	DrawLine(v[5][0], v[5][1], v[6][0], v[6][1], x, y);
	DrawLine(v[6][0], v[6][1], v[7][0], v[7][1], x, y);
	DrawLine(v[6][0], v[6][1], v[1][0], v[1][1], x, y);
	DrawLine(v[7][0], v[7][1], v[4][0], v[4][1], x, y);
	DrawLine(v[5][0], v[5][1], v[0][0], v[0][1], x, y);
	DrawLine(v[1][0], v[1][1], v[6][0], v[6][1], x, y);
	DrawLine(v[3][0], v[3][1], v[0][0], v[0][1], x, y);
	DrawLine(v[2][0], v[2][1], v[7][0], v[7][1], x, y);
}

void DrawSOb(Vob * em, Base e1, Base e2, Base e3, int s, int x, int y, int p)
{
	Vob v;
	float num;
	int i;
			      /* scaling */

	for ( i=0; i<CORNERS; i++ )
	{
		v[i][0] = s*(*em)[i][0];
		v[i][1] = s*(*em)[i][1];
	}
	
	/* This is going to be difficult to explain, because 	*/
	/* the formula was something of a longshot.		*/
	/* When deciding which sides to draw you'll have to 	*/
	/* have some relation with the perspective. With 	*/
	/* perspective the sides should be filled somewhat 	*/
	/* later than without perspective to prevent the sides  */
	/* from overwriting eachother. If you look at the wire- */
	/* frame model you'll probably see what I mean. 	*/

	if (p) num = (float) 1/p;
	else   num = 0;

	/* 	   Time to fill those sides with color		*/
	/* Let's look at a cube without perspective first. We	*/
	/* need to know when to draw which side. Start by  	*/
	/* giving each side of the cube a corresponding number, */
	/* like a dice. Now we need a to construct a normal 	*/
	/* to each side (a normal to a plane is a vector such 	*/
	/* that every angle between the vector and the plane is */
	/* straight). Using the cube-object we've already got   */
	/* these vector as a nice spin off from our base.	*/
	/* Hence:	Side nr		Normal			*/
	/*		   1		  e1			*/
	/*		   2		 -e1			*/
	/*		   3		  e2			*/
	/*		   4		 -e2			*/
	/*		   5		  e3			*/
	/*		   6		 -e3			*/
	/* This leaves us just to check if the normal is 	*/
	/* pointing towards or away from us, i e is the 	*/
	/* z-coordinate negative or positive. 			*/
	/* The only difference when using perspective is that   */
	/* the angle between the normal and the (x,y)-plane	*/
	/* must pass a certain value if the side should be 	*/
	/* drawn. This can be achieved by checking the value	*/
	/* of the z-coordinate if the normal. If it's larger 	*/
	/* than a value, which is related to the perspective,   */
	/* then we should draw the side... 			*/
	/* This is done as follows:				*/

	/* 1 */
	SetCol("blue");
	if ( e1[ DIM-1 ] > num )
		DrawSolid(v[0][0], v[0][1], v[1][0], v[1][1], 
			  v[2][0], v[2][1], v[3][0], v[3][1], x, y);
	/* 2 */
	SetCol("blue");
	if ( e1[ DIM-1 ] < -num )
		DrawSolid(v[4][0], v[4][1], v[5][0], v[5][1], 
			  v[6][0], v[6][1], v[7][0], v[7][1], x, y);
	/* 3 */
	SetCol("cornflower blue");
	if ( e2[ DIM-1 ] > num )
		DrawSolid(v[0][0], v[0][1], v[3][0], v[3][1], 
			  v[4][0], v[4][1], v[5][0], v[5][1], x, y);
	/* 4 */
	SetCol("cornflower blue");
	if ( e2[ DIM-1 ] < -num )
		DrawSolid(v[1][0], v[1][1], v[2][0], v[2][1], 
			  v[7][0], v[7][1], v[6][0], v[6][1], x, y);
	/* 5 */
	SetCol("darkslateblue");
	if ( e3[ DIM-1 ] > num )
		DrawSolid(v[0][0], v[0][1], v[1][0], v[1][1], 
			  v[6][0], v[6][1], v[5][0], v[5][1], x, y);
	/* 6 */
	SetCol("darkslateblue");
	if ( e3[ DIM-1 ] < -num )
		DrawSolid(v[3][0], v[3][1], v[2][0], v[2][1], 
			  v[7][0], v[7][1], v[4][0], v[4][1], x, y);
}

/* This is where the perspective is calculated. I use a method where I	    */
/* introduce a line on parametric form from a point on the z-axis to each   */
/* of the cube's corners. I let the screen be the (x,y)-plane and project   */
/* the corner point on to the screen ((x,y)-plane) in the direction of the  */
/* line.								    */

Vob * Perspect(Vob * em, int depth)
{
	Vob temp;
	int i;	

	for ( i=0;i <CORNERS; i++ )
	{
		temp[i][0] = (*em)[i][0]*depth/(depth-(*em)[i][2]);
		temp[i][1] = (*em)[i][1]*depth/(depth-(*em)[i][2]);
	}
	return &temp;
}

/* I guess the main changes from v0.01 to v0.02 are in this function. Here  */
/* I only rotate the three base vectors and you might wonder why this is    */
/* such an improvement. In v0.01 I had to rotate every vector (representing */ 
/* a corner in the cube) which meant rotating eight vectors and in each     */
/* rotation I use nine multiplications, hence I'll have to use CORNERS*9    */
/* multiplications to rotate an object.	Now I only use DIM*9 multiplication */
/* no matter how many corners I have, though the extra multiplications does */
/* not vanish completely, they are substituted with CORNERS*DIM*2 adds and  */
/* subs.								    */

void Rotate(Vob * em, float matrix[][ DIM ], Base * e1, Base * e2, Base * e3)
{
        float te1[ DIM ];
	float te2[ DIM ];
	float te3[ DIM ];
	int i;

	/* This is were I rotate the three base vectors.	*/ 
	/* I need to use temp variables as all base vectors 	*/
	/* appear in each step of the loop.			*/
	/* Btw, in case you haven't noticed, this how 		*/
	/* multiplicating a matrix with a vector works :)	*/

	for ( i=0; i<DIM; i++ )			
	{
	  	te1[i] = matrix[i][0]*(*e1)[0] +
		         matrix[i][1]*(*e1)[1] +
			 matrix[i][2]*(*e1)[2];
	  	te2[i] = matrix[i][0]*(*e2)[0] +
		         matrix[i][1]*(*e2)[1] +
			 matrix[i][2]*(*e2)[2];
	  	te3[i] = matrix[i][0]*(*e3)[0] +
		         matrix[i][1]*(*e3)[1] +
			 matrix[i][2]*(*e3)[2];
	}

	for ( i=0; i<DIM; i++ ) 
	{
		(*e1)[i] = te1[i];
		(*e2)[i] = te2[i];
		(*e3)[i] = te3[i];
	}

	/* Now it's time to remember those inital coordinates	*/
	/* of our object. Here we express the coordinates of 	*/
	/* the corners relative our base e1,e2,e3. Here's a 	*/
	/* short example of how it works: 			*/
	/* Let's say one of the corners had the initial coords  */
	/* {  1,  1, -1 }, now we need to find the linear 	*/
	/* combination of e1,e2 and e3 that corresponds to this */
	/* vector (I suppose knowledge of vector algebra could	*/
	/* be useful). It's quite easy, {1,1,-1} is the same 	*/
	/* as e1 + e2 - e3 because				*/
	/* 	    {a,b,c} + {d,e,f} = {a+d,b+e,c+f}		*/
	/* So, what the following does is calculating the new   */
	/* position of the object relative the rotated base. 	*/
	/* If you change object you'll need to change these 	*/
	/* lines also. I'll be talking more about this in 	*/
	/* the following versions.				*/

	for ( i=0; i<DIM; i++ )
	{
		(*em)[0][i] =   (*e1)[i] + (*e2)[i] + (*e3)[i];
		(*em)[1][i] =   (*e1)[i] - (*e2)[i] + (*e3)[i];
		(*em)[2][i] =   (*e1)[i] - (*e2)[i] - (*e3)[i];
		(*em)[3][i] =   (*e1)[i] + (*e2)[i] - (*e3)[i];
		(*em)[4][i] = - (*e1)[i] + (*e2)[i] - (*e3)[i];
		(*em)[5][i] = - (*e1)[i] + (*e2)[i] + (*e3)[i];
		(*em)[6][i] = - (*e1)[i] - (*e2)[i] + (*e3)[i];
		(*em)[7][i] = - (*e1)[i] - (*e2)[i] - (*e3)[i];
	}
}

/* Someone showed me how to initialize a screen and stuff in X so I can't   */
/* explain any of the following stuff... The imprortance is that they work  */
/* and the drawing routines are probably a bit different on the machines    */
/* I'll be using these routines on later...				    */

void DrawLine(int x, int y, int xe, int ye, int ox, int oy)
{
	XDrawLine(dpy, RootWindow(dpy,scrn), gc, ox+x, oy+y, ox+xe, oy+ye);
}

/* Well.. I actually had to figure this one out by myself...		    */

void DrawSolid(int x1, int y1, int x2, int y2, int x3, int y3, 
	       int x4, int y4, int ox, int oy)
{
	mypoints[0].x = ox + x1;
	mypoints[0].y = oy + y1;
	mypoints[1].x = ox + x2;
	mypoints[1].y = oy + y2;
	mypoints[2].x = ox + x3;
	mypoints[2].y = oy + y3;
	mypoints[3].x = ox + x4;
	mypoints[3].y = oy + y4;

	XFillPolygon(dpy, RootWindow(dpy, scrn), gc, mypoints, PTS, 
		     Convex, CoordModeOrigin);
}

void SetCol(char * str)
{
  	if (XParseColor (dpy, DefaultColormap(dpy,scrn), str, &xcolour))
    		if (XAllocColor (dpy, DefaultColormap(dpy,scrn), &xcolour))
			xgcvalues.foreground = xcolour.pixel;
	XChangeGC (dpy,gc,GCForeground, &xgcvalues);
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
  	if (XParseColor (dpy, DefaultColormap(dpy,scrn), "khaki2", &xcolour))
    		if (XAllocColor (dpy, DefaultColormap(dpy,scrn), &xcolour))
      			pixel = xcolour.pixel;

  	gc = XCreateGC (dpy, RootWindow(dpy,scrn),0,NULL);
}
	
void Exit(void)
{
	XFlush (dpy);
}



