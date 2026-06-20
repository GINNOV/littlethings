/****************************************************************************/
/*									    */
/*			    	  3D-Rotaion Routines			    */
/*									    */
/*    CrEatOr:    LarZ SamuelssoN (C)			     AD: 1993 	    */
/*									    */
/*  Version 0.04: Removed all comments. Read 'em in earlier versions.  	    */ 
/*		  This is probably as close to the asm-version we'll get    */
/*	on	  without using any asm-code...				    */
/*    public	  What I have done is to move as much as possible into the  */
/*    demand	  main loop... Function calls cost valuable time... 	    */
/*		  And as asm won't even get close to floating-point 	    */
/*		  numbers so I converted all routines to integer math.	    */
/* 		  This is the last production from me before the summer	    */
/*		  holidays. But look out for stuff on the Amiga from me     */
/* 		  this summer. 						    */
/* 		  I'll be back in the Unix-World with new ideas this 	    */
/* 		  autumn though....	C Ya				    */
/*									    */
/*    LAteRZ:	  Decided to add some comments after all :)		    */
/*									    */
/*   COPYRIGHT	  Vector0.01 - 0.04.c are SpreadWare			    */
/*    NOTICE	     If you like 'em, spread 'em			    */
/*									    */
/****************************************************************************/

#include <X11/Xlib.h>	
#include <X11/X.h>	
#include <stdio.h>	
#include <math.h>	
#include <stdlib.h>	

#define	CORNERS 8	/* Number of Corners in the object (Cube)	*/
#define DIM	3	/* Number of Coordinates 			*/
#define PTS	4	/* Number of Points to contain a Surface	*/
#define LSIZE	512	/* Number of entrys in the Sine-Table 		*/
#define RSIZE	29000	/* Number of entrys in the Division-Table	*/
#define fe	13	/* Number of shifts (float ~> int)		*/
#define fak	8192	/* 2^fe						*/

void Cls( void );

void Init( void );

void Exit( void );

void WinInit( int, int, unsigned, unsigned );

void SetCol( char * );

void ClearArea( unsigned short, unsigned short, unsigned, unsigned );

void DrawSolid( short, short, short, short, 
		short, short, short, short, 
		unsigned short, unsigned short );

Display 		*dpy;
XPoint			mypoints[ PTS ];
XColor 			xcolour;
GC 			gc;
XGCValues 		xgcvalues;
XSetWindowAttributes 	xsetwattrs;
Window			win;
int			scrn, pixel;

int main (void)
{
	/* loop variable */

	unsigned short	i;
	
	/*                     center of rotation		      */
	/* if you are using WinInit( ) these should be x = y ~= scale */

  	unsigned short	x = 600;
	unsigned short	y = 400;

	/* initial angles for the object ( rem: 2pi = 511 ) */
	/* 		     sine-counters		    */

	unsigned short	wx = 0;
	unsigned short	wy = 0;		
	unsigned short	wz = 0;		

	/*		    cosine-counters		    */

	unsigned short 	vx = wx + LSIZE/4;
	unsigned short 	vy = wy + LSIZE/4;
	unsigned short	vz = wz + LSIZE/4;

	/* rotation velocity around the different axises */

	unsigned short 	sx = 1;
	unsigned short 	sy = 2;
	unsigned short 	sz = 1;

	/* perspective depth */

	int 	depth = 5;
	int 	depte = depth * fak;

	/* enlargement in pixels ( gives sidelenght of cube = 300 pixels ) */
	
	int	scale = 150;

	/* base vectors ( the three unit-vectors in the euclidian space ) */

	int 	e1[ DIM ]; 
	int	e2[ DIM ]; 
	int	e3[ DIM ]; 

	/* holds an int temporarily */

	int 	temp;

	/* cube[][] holds the position of the cube's corners */
	/*         v[][] is cube[][] with perspective 	     */

	int	cube[ CORNERS ][ DIM ];
	int 	   v[ CORNERS ][ DIM ];

	/* num is used in the hidden-plane-removal part to check */
	/* whether a side should be drawn or not		 */

	int 	num = fak / depth;

	/* for use in ClearArea( ) */

	unsigned a = 2*scale;
	unsigned b = 2*a;

	/* sine-table and division-table ( see COMMENTS ) */

	int 	sinT[ LSIZE ];
	int 	divT[ RSIZE ];

	/* creating the precalculated tables */

	for ( i=0; i < LSIZE; i++ ) 
		sinT[i] = fak * sin( 6.28 / LSIZE * i );

	for ( i=0; i < RSIZE; i++ )
		divT[i] = fak * depte / ( depte - RSIZE/2 + i );

	Init( );

	/* if you want the cube in a window uncomment the following line */
	/* WinInit( x, y, a, b ); 					 */

	Cls( ); 

	while (4711)
	{ 
		/*		 	 ROTATION			*/
		/* Remember to keep LSIZE as an exponential of 2 as the	*/
		/* following won't work else. Instead of checking if v  */
		/* and w are out of range I 'AND' them with LSIZE-1. 	*/
		/* This will always keep them in range, because the 	*/
		/* binary representation of LSIZE-1 contains only 1's	*/
		/* and as long as w and v are smaller than LSIZE-1 they */
		/* will be unchanged, but if they get larger they'll    */
		/* start again from a low value (not necessarily 0 as   */
		/* in the previous version, so this is a small bug-fix  */
		/* as well as a speed-up)				*/

		vx = (vx + sx) & LSIZE - 1;
		vy = (vy + sy) & LSIZE - 1;
		vz = (vz + sz) & LSIZE - 1;
		wx = (wx + sx) & LSIZE - 1;
		wy = (wy + sy) & LSIZE - 1;
		wz = (wz + sz) & LSIZE - 1;

		/* After each multiplication I'll get something of the 	*/
		/* size fak^2, so I have to shift the values back to 	*/
		/* something proportional to fak. Note that I get rid   */
		/* of the divisions this way.				*/

		e1[0] = -sinT[wz] * sinT[wx] >> fe;
  		e1[1] =  sinT[vz] * sinT[wx] >> fe; 
  		e1[2] =  sinT[vy] * sinT[vx] >> fe;
		e2[0] = -sinT[wz] * sinT[vx] >> fe;
    		e2[1] =  sinT[vz] * sinT[vx] >> fe;
  		e2[2] = -sinT[vy] * sinT[wx] >> fe;
  		e3[0] =  sinT[vz] * sinT[vy] >> fe;
  		e3[1] =  sinT[wz] * sinT[vy] >> fe;
  		e3[2] =  sinT[wy];

		/* I am using the temp-variable because else I would 	*/
		/* have gotten something proportional to fak^3 and  	*/
		/* fak wouldn't have to be that large to make this an   */
		/* integer overflow.					*/

		temp  = -sinT[vz] * sinT[wy] >> fe;
		temp  =      temp * sinT[vx] >> fe;
		e1[0] =     e1[0] + temp;

		temp  = -sinT[wz] * sinT[wy] >> fe;
		temp  =      temp * sinT[vx] >> fe;
		e1[1] =     e1[1] + temp;

		temp  =  sinT[vz] * sinT[wy] >> fe;
		temp  =      temp * sinT[wx] >> fe;
		e2[0] =     e2[0] + temp;

		temp  =  sinT[wz] * sinT[wy] >> fe;
		temp  =      temp * sinT[wx] >> fe;
		e2[1] =     e2[1] + temp; 

		/* Saving adds is also useful, at least for objects 	*/
		/* with many corners. What I have done is to use the 	*/
		/* symmetry of the corner's coordinates in the cube. 	*/
		/* If you look at the previous versions you'll easily   */
		/* see that the following holds.			*/

		for ( i=0; i<DIM; i++ )
		{
			cube[0][i] =   e1[i] + e2[i] + e3[i];
			cube[1][i] =   e1[i] - e2[i] + e3[i];
			cube[2][i] =   e1[i] - e2[i] - e3[i];
			cube[3][i] =   e1[i] + e2[i] - e3[i];

			cube[4][i] = - cube[1][i];
			cube[5][i] = - cube[2][i];
			cube[6][i] = - cube[3][i];
			cube[7][i] = - cube[0][i];
		}

		/*			PERSPECTIVE			*/
		/* Division is one of the slowest operations you can 	*/
		/* perform, so you can do almost whatever it takes to 	*/
		/* get rid of them. My solution was to precalculate all	*/
		/* possible divisions and put them in a table. Again	*/
		/* using integer math I have to shift the values back	*/
		/* to something proportional to fak.			*/
		/* Also see COMMENTS on this subject.			*/

		for ( i=0; i <CORNERS; i++ )
		{
			v[i][0] = cube[i][0] * divT[ RSIZE/2 - 
						     cube[i][2] ] >> fe;
			v[i][1] = cube[i][1] * divT[ RSIZE/2 - 
						     cube[i][2] ] >> fe;
		}
		
		/*		 	  SCALING			*/
		/* If you want to have any sidelenght you want you can	*/
		/* do the scaling as follows. But then you'll have to 	*/
		/* do a lot of mulsing and that's BAD for speed. So, 	*/
		/* what you might do instead is to play with the    	*/
		/* shift-value (fe). 					*/
		/* Anyhow, here is where I scale everything back down 	*/
		/* to it's ususal proportions, scale * v[][] is prop to */
		/* scale * fak and therefore I have to shift the result */
		/* to get a 'normal' (~1) value.			*/

		for ( i=0; i<CORNERS; i++ )
		{
			v[i][0] = scale * v[i][0] >> fe;
			v[i][1] = scale * v[i][1] >> fe;
		}

		/*		  	 DRAWING			*/
		/* Instead of using Cls( ) or ClearSOb( ) I now use a 	*/
		/* a function that clears a rectangle around the cube.	*/
		/* I also removed some of the SetCol( )'s to save time. */
		/*							*/
		/* BUG: ClearArea( ) should be perspective-sensitive    */
		/*	as the following  won't work if depth = 3.	*/

		ClearArea( x, y, a, b );

		SetCol("blue");
		if ( e1[ DIM-1 ] > num )
			DrawSolid( v[0][0], v[0][1], v[1][0], v[1][1], 
				   v[2][0], v[2][1], v[3][0], v[3][1], x, y );
		if ( e1[ DIM-1 ] < -num )
			DrawSolid( v[4][0], v[4][1], v[5][0], v[5][1], 
				   v[6][0], v[6][1], v[7][0], v[7][1], x, y );

		SetCol("cornflower blue");
		if ( e2[ DIM-1 ] > num )
			DrawSolid( v[0][0], v[0][1], v[3][0], v[3][1], 
				   v[4][0], v[4][1], v[5][0], v[5][1], x, y );
		if ( e2[ DIM-1 ] < -num )
			DrawSolid( v[1][0], v[1][1], v[2][0], v[2][1], 
				   v[7][0], v[7][1], v[6][0], v[6][1], x, y );

		SetCol("darkslateblue");
		if ( e3[ DIM-1 ] > num )
			DrawSolid( v[0][0], v[0][1], v[1][0], v[1][1], 
				   v[6][0], v[6][1], v[5][0], v[5][1], x, y );
		if ( e3[ DIM-1 ] < -num )
			DrawSolid( v[3][0], v[3][1], v[2][0], v[2][1], 
				   v[7][0], v[7][1], v[4][0], v[4][1], x, y );
	}

	Exit( );
  	return 0;
}

/*				COMMENTS				*/
/* In the released versions I have chosen to use the simple standard 	*/
/* way of doing rotation, i e using a 3D-rotation-matrix. I tried to	*/
/* optimize the code as well as possible and in the same time make it 	*/
/* asm-friendly. I wish there were some way of optimizing the drawing 	*/
/* routines. One way of doing this would be to use Double Buffering, 	*/
/* but I haven't got a clue of how to do that under X. So, if anyone    */
/* feel up to it, include multibuf.h and start coding (it sure would 	*/
/* be nice to get rid of that flicker).					*/
/* Time to calculate the number of operations I use in the main loop	*/
/* 									*/
/* 	48 	multiplications						*/
/*	46	adds and subs						*/
/*	48	shifts (each 13 times)					*/
/*	 6 	ands							*/
/*	 6 	compares						*/
/*	 x 	drawing stuffs						*/
/*									*/
/* I bet there are loads of better algorithms than mine out there, but  */
/* I hope I have given you a clue of how things are done. 		*/
/*									*/
/* 			 IMPROVEMENT SUGGESTIONS			*/
/* First, use another algorithm to generate the location of the three   */
/* unit-vectors. Using three 2D-transformations you will get down to    */
/* 12 muls instead of my 16 in that part. Another way of doing it is by */
/* using spherical coordinates:	 x = rsin(s)cos(t)			*/
/*				 y = rsin(s)sin(t)			*/
/*				 z = rcos(s)				*/
/* If you just figure out how the different s and t's for the different */
/* vectors are connected during rigid rotation this will get you down   */
/* to 6 muls ( 2/vector ). Yet other ways of doing rotation are by 	*/
/* using Quaternations, Bresenham's algorithms or the Cayley-Klein	*/
/* Parameters. Some of these might even give further improvement.	*/
/* Another improvement can be achieved using log- and 			*/
/* exponential-tables. Multiplications can then be replaced with some   */
/* adds and table lookups. This is done as follows:			*/
/* a = b * c / d = e^(log(b) + log(c) - log(d))				*/
/* and this is a better way than using a division-table.		*/
/* Speaking of the division-table, it might also be improved somewhat.  */
/* If you print the values of divT[] you'll notice that many of the 	*/
/* values are duplicates, this is because we don't shift the values	*/
/* enough to notice the difference between some values. So, what you 	*/
/* might do is to make another table containing only every fourth value */
/* of divT[], this way you'll save alot of memory as the size of divT[] */
/* is reduced by a factor of 4. When using the new table, call it 	*/
/* div4T[], replace divT[ something ] with div4T[ (int) something/4 ]   */
/* and it should work properly.						*/
/* The ideas presented above has been given almost no thought at all,   */
/* so I will note take any responsibility if something shouldn't work.	*/

void DrawSolid( short x1, short y1, 
	        short x2, short y2, 
	        short x3, short y3, 
	        short x4, short y4,
	        unsigned short ox, 
		unsigned short oy )
{
	mypoints[0].x = ox + x1;
	mypoints[0].y = oy + y1;
	mypoints[1].x = ox + x2;
	mypoints[1].y = oy + y2;
	mypoints[2].x = ox + x3;
	mypoints[2].y = oy + y3;
	mypoints[3].x = ox + x4;
	mypoints[3].y = oy + y4;

	XFillPolygon(dpy, win, gc, mypoints, PTS, 
		     Convex, CoordModeOrigin); 
}

void ClearArea( unsigned short ox, unsigned short oy, unsigned a, unsigned b  )
{
	SetCol("black");
	XFillRectangle(dpy, win, gc, ox - a, oy - a, b, b);
}

void SetCol( char * str )
{
  	if (XParseColor (dpy, DefaultColormap(dpy,scrn), str, &xcolour))
    		if (XAllocColor (dpy, DefaultColormap(dpy,scrn), &xcolour))
			xgcvalues.foreground = xcolour.pixel;
	XChangeGC (dpy,gc,GCForeground, &xgcvalues);
}

void Cls( void )
{
    	XClearWindow(dpy, win);
}

void Init( void )
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

	win = RootWindow(dpy,scrn);
	
  	gc = XCreateGC (dpy, RootWindow(dpy,scrn),0,NULL);
}

void WinInit( int ox, int oy, unsigned a, unsigned b )
{
	win = XCreateSimpleWindow(dpy, RootWindow(dpy,scrn), 
				  ox-a, oy-a, b, b, 0, 
			          WhitePixel(dpy,scrn), BlackPixel(dpy,scrn));

	XMapWindow(dpy, win);
}

void Exit( void )
{
	XFlush (dpy);
}



