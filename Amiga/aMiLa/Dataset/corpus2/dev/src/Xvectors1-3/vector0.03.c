/****************************************************************************/
/*									    */
/*			    3D-Rotaion Routines				    */
/*									    */
/*  CrEatOr: LarZ SamuelssoN (C)			     AD: 1993 	    */
/*									    */
/*  Version 0.03: Removed a lot of comments. Read 'em in earlier versions.  */ 
/*									    */
/****************************************************************************/

#include <X11/Xlib.h>	
#include <X11/X.h>	
#include <stdio.h>	
#include <math.h>	
#include <stdlib.h>	

#define	CORNERS 8	
#define DIM	3	
#define PTS	4	
#define LSIZE	628	/* nr of entrys in the sine-table		    */

typedef float   Base[ DIM ];
typedef	float	Vob[ CORNERS ][ DIM ];

/* function prototypes							    */

void Cls(void);
void Init(void);
void Exit(void);

void SetCol(char *);

/* Yep... You're right... Something's different here (another speed-up)	    */

void Rotate(Vob *, int *, int *, int *, int *, int *, int *, 
	    int, int, int, Base *, Base *, Base *, float *);

void DrawSOb(Vob *, Base, Base, Base, int, int, int, int);
void ClearSOb(Vob *, Base, Base, Base, int, int, int, int);
void DrawSolid(int, int, int, int, int, int, int, int, int, int);

Vob * Perspect(Vob *, int);

/* These are the variables set out to explore the unknown (X)	            */

Display 		*dpy;
XPoint			mypoints[ PTS ];
XColor 			xcolour;
GC 			gc;
XGCValues 		xgcvalues;
XSetWindowAttributes 	xsetwattrs;
int			scrn, pixel;

int main (void)
{
  	int 	cx = 850;	/*  Center of rotation (rootwindow coords)  */
	int 	cy = 830;

	int 	wx = 0;		/*        Inital angles of the cube   	    */
	int	wy = 0;		/* These will be used to hold the value of  */
	int	wz = 0;		/*        the angle during rotation 	    */

	int 	vx = wx + LSIZE/4;	/* wX are counters for sine	*/ 
	int 	vy = wy + LSIZE/4;	/* vX are counters for cosine	*/
	int 	vz = wz + LSIZE/4;

	int 	xstep = 1; 	/*       Step-angle used in rotation 	    */
	int 	ystep = 2; 	/*					    */
	int 	zstep = 1; 	/*     ( small step = smooth rotation )	    */

	int 	depth = 5;	/*            Perspective depth 	    */
	int	scale = 40;	/*        Scaling factor (in pixels)	    */

	/* This is our three base vectors				    */

	Base e1 = { 1, 0, 0 };
	Base e2 = { 0, 1, 0 };
	Base e3 = { 0, 0, 1 };

	/* This is the object we will be dealing with, hence, a cube.	    */

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

		/*        precalculated sine-table	    */

	float 	sinT[ LSIZE ];
	int 	i;	

	for ( i=0; i < LSIZE; i++ ) sinT[i] = sin(0.01*i);

	Init( );
	Cls( );

	pos = &cube;
	while (4711)
	{
		ClearSOb( Perspect( pos, depth ), e1, e2, e3, 
			  scale, cx, cy, depth ); 	
	
		Rotate( pos, &wx, &wy, &wz, &vx, &vy, &vz, 
			xstep, ystep, zstep, 
			&e1, &e2, &e3, sinT );	

		DrawSOb( Perspect( pos, depth ), e1, e2, e3, 
			 scale, cx, cy, depth ); 
	}

	Exit( );
  	return 0;
}

void ClearSOb(Vob * em, Base e1, Base e2, Base e3, int s, int x, int y, int p)
{
	Vob v;
	float num;
	int i;

	for ( i=0; i<CORNERS; i++ )
	{
		v[i][0] = s*(*em)[i][0];
		v[i][1] = s*(*em)[i][1];
	}

	if (p) num = (float) 1/p;
	else   num = 0;

	SetCol("black");
	if ( e1[ DIM-1 ] > num )
		DrawSolid(v[0][0], v[0][1], v[1][0], v[1][1], 
			  v[2][0], v[2][1], v[3][0], v[3][1], x, y);
	if ( e1[ DIM-1 ] < -num )
		DrawSolid(v[4][0], v[4][1], v[5][0], v[5][1], 
			  v[6][0], v[6][1], v[7][0], v[7][1], x, y);
	if ( e2[ DIM-1 ] > num )
		DrawSolid(v[0][0], v[0][1], v[3][0], v[3][1], 
			  v[4][0], v[4][1], v[5][0], v[5][1], x, y);
	if ( e2[ DIM-1 ] < -num )
		DrawSolid(v[1][0], v[1][1], v[2][0], v[2][1], 
			  v[7][0], v[7][1], v[6][0], v[6][1], x, y);
	if ( e3[ DIM-1 ] > num )
		DrawSolid(v[0][0], v[0][1], v[1][0], v[1][1], 
			  v[6][0], v[6][1], v[5][0], v[5][1], x, y);
	if ( e3[ DIM-1 ] < -num )
		DrawSolid(v[3][0], v[3][1], v[2][0], v[2][1], 
			  v[7][0], v[7][1], v[4][0], v[4][1], x, y);
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

	if (p) num = (float) 1/p;
	else   num = 0;

	/* 	   Time to fill those sides with color		*/

	SetCol("blue");
	if ( e1[ DIM-1 ] > num )
		DrawSolid(v[0][0], v[0][1], v[1][0], v[1][1], 
			  v[2][0], v[2][1], v[3][0], v[3][1], x, y);
	SetCol("blue");
	if ( e1[ DIM-1 ] < -num )
		DrawSolid(v[4][0], v[4][1], v[5][0], v[5][1], 
			  v[6][0], v[6][1], v[7][0], v[7][1], x, y);
	SetCol("cornflower blue");
	if ( e2[ DIM-1 ] > num )
		DrawSolid(v[0][0], v[0][1], v[3][0], v[3][1], 
			  v[4][0], v[4][1], v[5][0], v[5][1], x, y);
	SetCol("cornflower blue");
	if ( e2[ DIM-1 ] < -num )
		DrawSolid(v[1][0], v[1][1], v[2][0], v[2][1], 
			  v[7][0], v[7][1], v[6][0], v[6][1], x, y);
	SetCol("darkslateblue");
	if ( e3[ DIM-1 ] > num )
		DrawSolid(v[0][0], v[0][1], v[1][0], v[1][1], 
			  v[6][0], v[6][1], v[5][0], v[5][1], x, y);
	SetCol("darkslateblue");
	if ( e3[ DIM-1 ] < -num )
		DrawSolid(v[3][0], v[3][1], v[2][0], v[2][1], 
			  v[7][0], v[7][1], v[4][0], v[4][1], x, y);
}

/* This is where the perspective is calculated.				    */

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

/* I guess the main changes from v0.02 to v0.03 are in this function.	    */
/* In the previous version I needed 27 multiplications and some adds...     */
/* If I instead of calculating each new position from the previous position */
/* calculate everything from an initial position I will save some muls.	    */
/* This is also to prefer because it keeps the errors small... You might    */
/* have noticed that the cube in the earlier versions grew larger or 	    */
/* smaller with time, because of the error introduced in every new rotation */
/* Using an initial position the error will always be the same. 	    */
/* So, as in the earlier versions I use my three base vectors and rotate    */
/* these. But now I gradually rotate these with increasing angles from the  */
/* initial position. As sin( ) is a time-consuming function I had to create */
/* a sine-table with precalcualted values to get the necessary speed.	    */
/* ( This is how it is done in asm also )				    */
/* This roataion routine uses:						    */
/* 					16 multiplications		    */
/*					 6 compares			    */
/*					58 adds and subs		    */
/* I'll try to optimze even further...					    */

void Rotate(Vob * em, int * wx, int * wy, int * wz, 
	    int * vx, int * vy, int * vz, 
	    int sx, int sy, int sz, 
	    Base * e1, Base * e2, Base * e3, float * sinT)
{
	int i;

	/* This is e1, e2, e3 multiplied with the rotation matrix 	*/
	/* ( yes, another one than the one in the earlier versions )	*/

	(*e1)[0] = -sinT[*wz] * sinT[*wx] - sinT[*vz] * sinT[*wy] * sinT[*vx];
  	(*e1)[1] =  sinT[*vz] * sinT[*wx] - sinT[*wz] * sinT[*wy] * sinT[*vx];
  	(*e1)[2] =  sinT[*vy] * sinT[*vx];
	(*e2)[0] = -sinT[*wz] * sinT[*vx] + sinT[*vz] * sinT[*wy] * sinT[*wx];
    	(*e2)[1] =  sinT[*vz] * sinT[*vx] + sinT[*wz] * sinT[*wy] * sinT[*wx];
  	(*e2)[2] = -sinT[*vy] * sinT[*wx];
  	(*e3)[0] =  sinT[*vz] * sinT[*vy];
  	(*e3)[1] =  sinT[*wz] * sinT[*vy];
  	(*e3)[2] =  sinT[*wy];

	/* Here we need to check the values of vX and wX, because our 	*/
	/* table-array only has LSIZE positions.			*/
	/* Note that cos( x ) = sin( x + pi/2 )	and therefore we can    */
	/* use just one table.						*/

	if ( *vx < LSIZE - 1 )		*vx = *vx + sx;
	else				*vx = 0;
	if ( *vy < LSIZE - 1 )		*vy = *vy + sy;
	else				*vy = 0;
	if ( *vz < LSIZE - 1 )		*vz = *vz + sz;
	else				*vz = 0;
	if ( *wx < LSIZE - 1 ) 		*wx = *wx + sx;
	else		 		*wx = 0;
	if ( *wy < LSIZE - 1 ) 		*wy = *wy + sy;
	else		 		*wy = 0;
	if ( *wz < LSIZE - 1 ) 		*wz = *wz + sz;
	else		 		*wz = 0;

	/* Now it's time to remember those inital coordinates		*/
	/* of our object. Here we express the coordinates of 		*/
	/* the corners relative our base e1,e2,e3. 	 		*/

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



