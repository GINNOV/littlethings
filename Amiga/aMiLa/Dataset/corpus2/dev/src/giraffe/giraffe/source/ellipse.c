/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: outline.c -- path generation.           */
/*    |< |                                                    */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

#include "common.h"


int tangents[]=
{
  500000,  10428,  5211,  3471,  2599,  2076,  1726,  1475,
  1287,    1140,   1022,  925,   844,   775,   716,   664,
  618,     576,    541,   509,   479,   452,   427,   404,
  383,     364,    345,   328,   312,   297,   283,   269,
  256
  };

int cosines[]={
  256,  256,  256,  255,  255,  254,  253,  252,
  251,  250,  248,  247,  245,  243,  241,  239,
  237,  234,  231,  229,  226,  223,  220,  216,
  213,  209,  206,  202,  198,  194,  190,  185,
  181,  177,  172,  167,  162,  158,  153,  147,
  142,  137,  132,  127,  121,  115,  109,  104,
  98,   92,   86,   80,   74,   68,   62,   56,
  50,   44,   38,   31,   25,   19,   13,   6,
  0
  };

int lower_tangents[]=
{
  0,    6,    13,   19,   25,   32,   40,   44,
  51,   57,   64,   71,   78,   85,   92,   99,
  106,  113,  121,  129,  137,  145,  153,  162,
  171,  180,  190,  200,  210,  221,  232,  244,
  256
  };

/*
 * The ellipse control structure.
 *  This is used to determine the
 * endpoints of an elliptical arc.
 *
 * The fields are:
 *  .flag[4]   -- The pen flags for each quadrant. When
 *                'True', then points of the arc will be
 *                added for this quadrant.
 *
 *  The others are all arrays of two. These are
 * for the two angles. 0-ang1 1-ang2.
 *
 *  .quad[2]   -- The quadrant into which the angle points.
 *
 *  .octant[2] -- Whether the angle is in the far octant(xi>yi) or
 *                the near one(yi>xi). I wish I could draw what
 *                I mean.
 *
 *  .limit[2]  -- The tangent of the angle. This value is used
 *                to test for the endpoint:
 *                  near octant:  yi*limit==xi ?
 *                  far octant:   xi*limit==yi ?
 *
 * .start[2]   -- These pointers access the flag of the pen
 * .stop[2]       that is to be changed. If it is in start, then
 *                the flag is set 'True' when the test is True.
 *                Conversely, it is set 'False' by the stop pointers.
 *
 *  .direction  -- This flag indicates whether the arc proceeding
 *                 from ang1 to ang2 is counterclockwise(True) or
 *                 clockwise(False). Done by testing ang1 and ang2.
 *                       clockwise: ang1<ang2
 *                   anticlockwise: and1>ang2
 */

struct econtrol {
  int octant[2];
  int flag[4];
  int *start[2],*stop[2];
  int limit[2];
  int	quad[2];
  int direction;
};

int initellipse( struct econtrol *control, int ang1, int ang2 )
     /* initializes the control structure used by arc(), wedge()... */
{
  int i;
  int ang,*temp;
  
  /*
   * First check to see if the arc
   * goes clockwise or counter-clockwise.
   * Set flag True for the latter case.
   */
  if(ang1>ang2)
    { 
      control->direction = True;
      ang = ang1; ang1 = ang2; ang2 = ang;
    }
  else control->direction = False;

  /*
   * Check for the trivial case
   * of a complete oval.
   */
  if(abs(ang2-ang1) >= G_2pi)
    {
      /*
       * Turn on all pens and remove
       * all starts/stops. Return the
       * number of endpoints as zero.
       */
      for(i=0;i<4;i++)
	control->flag[i]=True;
      control->start[0] = control->start[1]=Null;
      control->stop[0]  = control->stop[1]=Null;
      return(0);
    }

  /*
   * Now modulo the endpoints
   * to fit within the range 
   * 0 to 2pi.
   */
  ang1 &= G_2pi-1;
  ang2 &= G_2pi-1;

  /*
   * First of all, we determine which
   * of the pens are initially on.
   * Remember the pens start at 90
   * and 270 degrees.
   */
  control->flag[0]=control->flag[1]=control->flag[2]=control->flag[3]=False;
  if(ang1<ang2)
    { /* determine which quadrants start 'on' */
      if(ang1<G_pi2  && ang2>G_pi2)control->flag[0]=control->flag[1]=True;
      if(ang1<G_3pi2 && ang2>G_3pi2)control->flag[2]=control->flag[3]=True;
    }
  else
    {
      if(ang1<G_pi2  || ang2>G_pi2)control->flag[0]=control->flag[1]=True;
      if(ang1<G_3pi2 || ang2>G_3pi2)control->flag[2]=control->flag[3]=True;
    }

  /*
   * Okay, so let's figure out where the
   * endpoints are and if they act to
   * turn the pens on or off. The pens'
   * state are changed indirectly through
   * pointers. Most of the controls are
   * arrays with two elements. These
   * correspond to ang1 or ang2.
   */
  control->start[0]=control->start[1]=control->stop[0]=control->stop[1]=Null;

  /*
   * First we must deal with 
   * ang1. Use G_Quandrant() to
   * determine into which quadrant
   * the angle is pointed.
   */
  control->quad[0]=G_Quadrant(ang1);

  /*
   * If it is in an odd quadrant
   * then ang1 acts to turn a 
   * pen on. Set the pointer and
   * calculate the tangent of
   * the angle. Be sure to check
   * if it is in the far or near
   * octant so we can keep the 
   * tangents ranging from
   * 0 to 1. (8-bit fixed point:0-256)
   */
  if(control->quad[0]&1)
    {
      control->start[0]=&control->flag[control->quad[0]];
      if((ang=ang1&(G_pi2-1)) >= G_pi4)
	{ /* far octant. phi = 45degrees to 90degrees */
	  control->octant[0] = True;
	  control->limit[0]  = lower_tangents[G_pi2-ang];
	}
      else
	{ /* near octant. phi=0 to 45 degrees */
	  control->octant[0] = False;
	  control->limit[0]  = lower_tangents[ang];
	}
    }
  else
    {
      /* ang1 acts as a stop. */
      control->stop[0] = &control->flag[control->quad[0]];
      if((ang=ang1&(G_pi2-1))>G_pi4)
	{
	  control->octant[0] = False;
	  control->limit[0]  = lower_tangents[G_pi2-ang];
	}
      else
	{
	  control->octant[0] = True;
	  control->limit[0]  = lower_tangents[ang];
	}
    }

  /*
   * ang2 is handled in the same way,
   * but in the odd quadrants the
   * endpoint acts as a stop, while
   * the opposite is true in the
   * even quadrants.
   */
  if(ang2)control->quad[1] = G_Quadrant(ang2-1);
  else control->quad[1] = 3;

  if(control->quad[1]&1)
    {
      /* ang2 acts as a stop. */
      control->stop[1] = &control->flag[control->quad[1]];
      if((ang=((ang2-1)&(G_pi2-1))+1)>=32)
	{
	  control->octant[1] = True;
	  control->limit[1]  = lower_tangents[G_pi2-ang];
	}
      else
	{
	  control->octant[1] = False;
	  control->limit[1]  = lower_tangents[ang];
	}
    }
  else
    {
      /* ang2 acts as a start. */
      control->start[1] = &control->flag[control->quad[1]];
      if((ang=((ang2-1)&(G_pi2-1))+1) >= G_pi4)
	{
	  control->octant[1] = False;
	  control->limit[1]  = lower_tangents[G_pi2-ang];
	}
      else
	{
	  control->octant[1] = True;
	  control->limit[1]  = lower_tangents[ang];
	}
    }

  /*
   * If ang1>ang2 then the direction
   * of the arc is completely different
   * and everything gets flip-flopped.
   * That is, the pens are toggle their
   * state and the stops become start/
   * starts become stops.
   */


/* program seems to work without this part. */
#if 0
  if(control->direction)
    {
      /*
       * Toggle the pen states.
       */
      for(i=0;i<4;i++)control->flag[i] = !control->flag[i];

      /*
       * Switch the role of ang1.
       */
      temp = control->start[0];
      control->start[0] = control->stop[0];
      control->stop[0]  = temp;

      /*
       * Switch the role of ang2.
       */
      temp = control->start[1];
      control->start[1] = control->stop[1];
      control->stop[1]  = temp;

      /*
       * Everythingelse like the quadrant,
       * octant and tangent remain the
       * same.
       */
    }
#endif

  /*
   * Arc has two endpoints.
   */
  return(2);
}


ulong build_xy( int xi, int yi, int quad )
/* creates coordinates used by arc functions. */
{
  union point result;

  /*
   * Puts the point into the appropriate
   * quandrant. xi and yi must be
   * positive.
   */
  result.coor.x = ((quad+1)&2?-xi:xi);
  result.coor.y = (quad&2?-yi:yi);

  return(result.xy);
}

int check_start( struct econtrol *control, int xi, int yi, union point *p0, union point *p1, union point *poly, int *ii, int *is, int *ie )
{
  int cnt;

  cnt = 0;

  /*
   * If ang1 is a start, then check which octant.
   *  If the values of xi,hi are in the proper
   * octant, then perform the test. Note: if the
   * limit is in the near octant, but (xi,yi)
   * has reached the far octant, then ang ~45 degrees
   * so the test is automatic.
   */
  if(control->start[0])
    if(control->octant[0])
      {
	/*
	 * Test not only the limit, but whether
	 * the (xi,yi) has actually reached the
	 * far octant.
	 */
	if((xi>yi)&&(xi*control->limit[0]>=(yi<<8))) 
	  {
	    /*
	     * First, set the pen into the
	     * 'on' state. Then turn the test
	     * off by clearing the pointer.
	     */
	    *(control->start[0]) = TRUE;
	    control->start[0]    = NULL;

	    /*
	     * Build the endpoint and add
	     * it to the array into the
	     * proper quadrant.
	     */
	    p0->xy = build_xy(xi,yi,control->quad[0]);
	    poly[ii[control->quad[0]]] = *p0;
	    *is = ii[control->quad[0]];

	    /*
	     * Increment/Decrement the
	     * appropriate index.
	     */
	    if(control->quad[0]&1)ii[control->quad[0]]++;
	    else ii[control->quad[0]]--;

	    /*
	     * Increase the number of
	     * points by one.
	     */
	    cnt++;
	  }
      }
    else
      {
	/*
	 * See the comments above.
	 */
	if((yi<xi)||(yi*control->limit[0]<=(xi<<8)))
	  { *(control->start[0]) = TRUE;
	    control->start[0]    = NULL;
	    p0->xy=build_xy(xi,yi,control->quad[0]);
	    poly[ii[control->quad[0]]] = *p0;
	    *is=ii[control->quad[0]];
	    if(control->quad[0]&1)ii[control->quad[0]]++;
	    else ii[control->quad[0]]--;
	    cnt++;
	  }
      }
  
  /*
   * This acts the same
   * as the above. Read the
   * comments.
   */
  if(control->start[1])
    if(control->octant[1])
      {
	if((xi>yi)&&(xi*control->limit[1]>=(yi<<8)))
	  { *(control->start[1]) = TRUE;
	    control->start[1]    = NULL;
	    p1->xy=build_xy(xi,yi,control->quad[1]);
	    *ie=ii[control->quad[1]];
	    poly[ii[control->quad[1]]] = *p1;
	    if(control->quad[1]&1)ii[control->quad[1]]++;
	    else ii[control->quad[1]]--;
	    cnt++;
	  }
      }
    else
      {
	if((yi<xi)||(yi*control->limit[1]<=(xi<<8)))
	  { *(control->start[1]) = TRUE;
	    control->start[1]    = NULL;
	    p1->xy=build_xy(xi,yi,control->quad[1]);
	    *ie=ii[control->quad[1]];
	    poly[ii[control->quad[1]]] = *p1;
	    if(control->quad[1]&1)ii[control->quad[1]]++;
	    else ii[control->quad[1]]--;
	    cnt++;
	  }
      }
  return cnt;
}


int check_stop( struct econtrol *control, int xi, int yi, union point *p0, union point *p1, union point *poly, int *ii, int *is, int *ie )
{
  int cnt;

  /*
   * check_stop() behaves in an analogous
   * manner to check_start(). See the comments
   * at the beinning of that function for
   * a full description.
   */

  cnt = 0;

  if(control->stop[0])
    if(control->octant[0])
      {
	if((xi>yi)&&(xi*control->limit[0]>=(yi<<8)))
	  { *(control->stop[0]) = FALSE;
	    control->stop[0]    = NULL;
	    p0->xy=build_xy(xi,yi,control->quad[0]);
	    poly[ii[control->quad[0]]] = *p0;
	    *is=ii[control->quad[0]];
	    if(control->quad[0]&1)ii[control->quad[0]]++;
	    else ii[control->quad[0]]--;
	    cnt++;
	  }
      }
    else
      {
	if((yi<xi)||(yi*control->limit[0]<=(xi<<8)))
	  {
	    *(control->stop[0]) = FALSE;
	    control->stop[0]    = NULL;
	    p0->xy=build_xy(xi,yi,control->quad[0]);
	    poly[ii[control->quad[0]]] = *p0;
	    *is=ii[control->quad[0]];
	    if(control->quad[0]&1)ii[control->quad[0]]++;
	    else ii[control->quad[0]]--;
	    cnt++;
	  }
      }
      
  if(control->stop[1])
    if(control->octant[1])
      {
	if((xi>yi)&&(xi*control->limit[1]>=(yi<<8)))
	  { *(control->stop[1]) = FALSE;
	    control->stop[1]    = NULL;
	    p1->xy=build_xy(xi,yi,control->quad[1]);
	    poly[ii[control->quad[1]]] = *p1;
	    *ie=ii[control->quad[1]];
	    if(control->quad[1]&1)ii[control->quad[1]]++;
	    else ii[control->quad[1]]--;
	    cnt++;
	  }
      }
    else
      {
	if((yi<xi)||(yi*control->limit[1]<=(xi<<8)))
	  { *(control->stop[1]) = FALSE;
	    control->stop[1]    = NULL;
	    p1->xy=build_xy(xi,yi,control->quad[1]);
	    poly[ii[control->quad[1]]] = *p1;
	    *ie=ii[control->quad[1]];
	    if(control->quad[1]&1)ii[control->quad[1]]++;
	    else ii[control->quad[1]]--;
	    cnt++;
	  }
      }
  return cnt;
}

#define ELLIPSE_MAX_SEGMENT 50

int flattenarc( union point *poly, int length, int width, int height, int ang1, int ang2, struct rectangle *bounds )
{
  int actual,count;
  int a,b,c;
  int xi,yi;
  int kh,kv;
  int delta;
  int error;
  int ends;
  union point p0,p1;
  union point mid[ELLIPSE_MAX_SEGMENT/2];
  union point last;
  union point *copy;
  int i,j;
  int errx,erry;
  int ii[4],is,ie;

  struct econtrol control;
 
  /*
   * First of all, prepare another
   * array for storing the points.
   * These are then copied over
   * when all are created.
   */
  if(!(copy=(union point *)allocm(length*sizeof(union point))))return(0);

  /*
   * Prepare the econtrol
   * structure for testing
   * the endpoints. If ends=0,
   * then the arc is a complete
   * oval and no testing is
   * required.
   */
  ends=initellipse(&control,ang1,ang2);
  
  /*
   * Set the initial cursor
   * position.
   */
  xi=0;
  yi=height;
  
  /*
   * These are the values for
   * running the Bresenham loop.
   */
  a=height*height;
  b=width*width;
  c=-a*b;
  delta=a+c+b*(height-1)*(height-1);
  kh=2*b*height-b;
  kv=a;

  /*
   * Split the array into four blocks.
   * The points for each quadrant are
   * stored in these blocks. At the
   * end, these blocks are combined
   * into on array.
   */
  is=ie=-1;
  ii[0]=length>>2;
  ii[1]=ii[0]+1;
  ii[2]=ii[0]+ii[0]+ii[0];
  ii[3]=ii[2]+1;
  count=0;

  /*
   * If the pen is initially on in the
   * first or second quadrants, then
   * add the point and update
   * the bounds' max y value.
   */
  if(control.flag[0]||control.flag[1])
    { bounds->max.coor.y = greater(bounds->max.coor.y,height);
      copy[ii[0]].coor.x = 0;
      copy[ii[0]].coor.y = height;
      count++;
      ii[0]--;
    }

  /*
   * If the pen is on in either the third
   * and fourth quadrant, then add that point
   * and update the bounds' min y value.
   */
  if(control.flag[2]||control.flag[3])
    { bounds->min.coor.y = lesser(bounds->min.coor.y,-height);
      copy[ii[2]].coor.x = 0;
      copy[ii[2]].coor.y = -height;
      count++;
      ii[2]--;
    }
  
  /*
   * Prepare the midpoint array
   * for testing straightness of
   * the arc. See the end of
   * the loop for details
   */
  j=0;
  mid[0].coor.x = xi;
  mid[0].coor.y = yi;
  last.coor.x = xi;
  last.coor.y = yi;

  /*
   * Now, we can begin the loop. This operation
   * works in four steps:
   * 1. Check (xi,yi) to see if any pens should be turned
   *    on.
   * 2. Use Bresenham algorithm to move (xi,yi).
   * 3. Check the straightness of the curve. Try
   *    to estimate by piecewise straight segments.
   *. 4. Check (xi,yi) to see if any pens should be turned
   *    off.
   */
  while(yi>0)
    {
      /*
       * step 1: check for starting points.
       *  Pass p0,p1 to get the points. Also pass the
       * array and the indices for the points to be
       * automatically added.
       */
      count += check_start(&control,xi,yi,&p0,&p1,copy,ii,&is,&ie);
	  
      /*
       * step 2: move (xi,yi)
       *  check an introductory text for an
       * explanation. It takes me about a day
       * to re-derive where I got this.
       */
      if(delta<0)
	{
	  error=2*delta+kh;
	  if(error<=0)
	    {
	      xi++;
	      kv    += 2*a;
	      delta += kv;
	    }
	  else
	    {

	      xi++;
	      yi--;
	      kv    += 2*a;
	      kh    -= 2*b;
	      delta += kv-kh;
	    }
	}
      else
	{
	  
	  error=2*delta-kv;
	  if(error>=0)
	    {
	      yi--;
	      kh    -= 2*b;
	      delta -= kh;
	    }
	  else
	    {
	      xi++;
	      yi--;
	      kv    += 2*a;
	      kh    -= 2*b;
	      delta += kv-kh;
	    }
	}

      /*
       * Step 3:
       * Points are only added to the array
       * when the ellipse differs from a straight
       * line. 'last' is the previous point added
       * to the array. The array mid[] contains
       * all the points since then. The current
       * one is indexed by j. So we compare
       * the midpoint between (xi,yi) and 'last'
       * to the point indicated by j/2. If
       * these points differ, then the ellipse
       * has begun to bend and (xi,yi) must be
       * added to the array.
       */
      errx = mid[j>>1].coor.x-(xi+last.coor.x)/2;
      erry = mid[j>>1].coor.y-(yi+last.coor.y)/2;
      if(errx<0)errx=-errx;
      if(erry<0)erry=-erry;


      if(errx+erry>1||j==ELLIPSE_MAX_SEGMENT)
	{ 
	  /*
	   * Add the points to the array where
	   * applicable. Change the indices to
	   * point to the next available spots.
	   */
	  if(control.flag[0]) { copy[ii[0]].coor.x =  xi; copy[ii[0]--].coor.y =  yi; count++; }
	  if(control.flag[1]) { copy[ii[1]].coor.x = -xi; copy[ii[1]++].coor.y =  yi; count++; }
	  if(control.flag[2]) { copy[ii[2]].coor.x = -xi; copy[ii[2]--].coor.y = -yi; count++; }
	  if(control.flag[3]) { copy[ii[3]].coor.x =  xi; copy[ii[3]++].coor.y = -yi; count++; }

	  /*
	   * Reset the midpoint testing
	   * array. set 'last' to (xi,yi).
	   */
	  j=0;
	  mid[0].coor.x = xi;
	  mid[0].coor.y = yi;
	  last.coor.x = xi;
	  last.coor.y = yi;
	}
      else 
	{
	  /*
	   * This part of the ellipse is still
	   * nearly straight. So add (xi,yi) to
	   * the testing array. Only fill up to
	   * 1/2 the maximum number of steps that
	   * the loop will make before forcing the
	   * point in.
	   */
	  ++j;
	  if(j<ELLIPSE_MAX_SEGMENT)
	    { mid[j].coor.x = xi;
	      mid[j].coor.y   = yi;
	    }
	}

      /*
       * step 4:
       *  Check for any endpoints. Pass p0,p1 to be filled
       * and the output array also.
       */
      count += check_stop(&control,xi,yi,&p0,&p1,copy,ii,&is,&ie);

      /*
       * The loop continues until yi=0,
       */
    }
  /*
   * If the pen is still on in either the first
   * or fourth quadrants, then add (width,0) to the
   * array. Update the bounds max x value. Otherwise,
   * compare the endpoints p0,p1 to the current bounds
   * maximum x value.
   */
  if(control.flag[0]||control.flag[3])
    { if(control.flag[0]) { copy[ii[0]].coor.x = width; copy[ii[0]--].coor.y = 0; count++; }
      if(control.flag[3]) { copy[ii[3]].coor.x = width; copy[ii[3]++].coor.y = 0; count++; }
      bounds->max.coor.x=greater(bounds->max.coor.x,width);
    }
  else bounds->max.coor.x=greater(bounds->max.coor.x,greater(p0.coor.x,p1.coor.x));

  /*
   * Repeat the same thing for the second and
   * third quadrants. (the left side of the ellipse).
   * Again, if both pens are off, then check the bounds
   * with the endpoints.
   */
  if(control.flag[1]||control.flag[2])
    { if(control.flag[1]) { copy[ii[1]].coor.x = -width; copy[ii[1]++].coor.y = 0; count++; }
      if(control.flag[2]) { copy[ii[2]].coor.x = -width; copy[ii[2]--].coor.y = 0; count++; }
      bounds->min.coor.x=lesser(bounds->min.coor.x,-width);
    }
  else bounds->min.coor.x=lesser(bounds->min.coor.x,lesser(p0.coor.x,p1.coor.x));

  /*
   * If there were endpoints, then check them againsts
   * the vertical bounds.
   */
  if(ends)
    {
      if(p0.coor.y<p1.coor.y)bounds->min.coor.y=lesser(bounds->min.coor.y,p0.coor.y);
      else bounds->min.coor.y=lesser(bounds->min.coor.y,p1.coor.y);
      if(p0.coor.y>p1.coor.y)bounds->max.coor.y=greater(bounds->max.coor.y,p0.coor.y);
      else bounds->max.coor.y=greater(bounds->max.coor.y,p1.coor.y);
    }

  /*
   * Now we copy the curve into the
   * array passed to us. The order that
   * the points are copied depends upon
   * the direction flag in econtrol.
   *
   *  Note, while the copying looks pretty
   * ugly it's actually quite straightforward.
   * The complication comes from when the
   * index moves from the points of one
   * quadrant to the next. It must also 
   * check if the new quadrant is empty.
   */
  actual=0;

  if(control.direction)
    {
      /*
       * The index starts at 'is'. This value should
       * have been set by either check_start() or
       * check_stop(). If the arc is complete, then
       * the index starts in the first quadrant.
       */
      if(ends)i=is;
      else i=ii[0]+1;

      /*
       * Increment the index. I don't feel
       * like explaining.
       */
      if(i<=ii[1])
	{ if(i==ii[1])i=(ii[2]+1==ii[3]?ii[0]+1:ii[2]+1); }
      else
	{ if(i==ii[3])i=(ii[0]+1==ii[1]?ii[2]+1:ii[0]+1); }

      /*
       * Now for the actual loop. Simply add
       * the point and increment the index, until
       * all the points have been transferrred.
       */
      while(actual<count)
	{
	  poly[actual++].xy = copy[i++].xy;
	  if(i<=ii[1])
	    { if(i==ii[1])i=(ii[2]+1==ii[3]?ii[0]+1:ii[2]+1); }
	  else
	    { if(i==ii[3])i=(ii[0]+1==ii[1]?ii[2]+1:ii[0]+1); }
	}
    }
  else
    {
      /*
       * Same as the other part,
       * except that the index
       * starts at the ending point
       * and the index counts down.
       */
      if(ends)i=ie;
      else i=ii[1]-1;

      if(i>=ii[2])
	{ if(i==ii[2])i=(ii[1]-1==ii[0]?ii[3]-1:ii[1]-1); }
      else
	{ if(i==ii[0])i=(ii[3]-1==ii[2]?ii[1]-1:ii[3]-1); }

      while(actual<count)
	{
	  poly[actual++].xy = copy[i--].xy;
	  if(i>=ii[2])
	    { if(i==ii[2])i=(ii[1]-1==ii[0]?ii[3]-1:ii[1]-1); }
	  else
	    { if(i==ii[0])i=(ii[3]-1==ii[2]?ii[1]-1:ii[3]-1); }
	}
    }

  /*
   * If there are no endpoints, then
   * make the curve close onto itself.
   */
  if(!ends)poly[actual++].xy=poly[0].xy;

  /*
   * Release the array allocated and
   * then return then number of points
   * created.
   */
  freem(copy);
  return(actual);
}

/*
 * Line outline functions.
 * 
 * lineoutline()  -- This is the only one. This function creates the outline
 *                   of a thick line.
 */

int lineoutline( union point *uv, G_GCPtr gcp, int x1, int y1, int x2, int y2, struct rectangle *bounds )
{
  int i;
  int delx,dely,dx,dy;
  ulong adelx,adely;
  int tan,lo,hi,phi;
  
  /*
   * Check if the line is vertical. If yes, then the
   * outline is easily created as a rectangle.
   */
  if(x1==x2)
    {
      uv[2].coor.x = uv[3].coor.x = -gcp->LineWidth + (uv[0].coor.x = uv[1].coor.x = x1+gcp->LineWidth/2);
      uv[0].coor.y = uv[3].coor.y = lesser(y1,y2);
      uv[2].coor.y = uv[1].coor.y = greater(y1,y2);

      bounds->min = uv[3];
      bounds->max = uv[1];
      return 4;
    }
  
  /*
   * If the line is horizontal, then the outline
   * is also a rectangle.
   */
  if(y1==y2)
    { 
      uv[3].coor.x = uv[0].coor.x = lesser(x1,x2);
      uv[3].coor.y = -gcp->LineWidth/2 + (uv[0].coor.y = y1 + gcp->LineWidth/2);
      uv[2].coor.x = uv[1].coor.x = greater(x1,x2);
      uv[2].coor.y = -gcp->LineWidth/2 + (uv[1].coor.y = y2 + gcp->LineWidth/2);

      bounds->min = uv[3];
      bounds->max = uv[1];

      return 4;
    }
  
  /*
   * First, I determine the orientation of the line.  With this
   * I'll get the perpendicular unit vector.
   */
  delx  = x2-x1;
  dely  = y2-y1;
  adelx = (delx<0?-delx:delx);
  adely = (dely<0?-dely:dely);

  /*
   * Use adely/delx or the reciprocal as 
   * the tangent to determine the angle.
   */
  if(adely>adelx)
    { 
      tan = (256*adely)/adelx;
      lo  = G_pi2; hi = 0;
      for(i=G_AnglePrecision-3;i>=0;i--)
	{
	  if(tan<tangents[(lo+hi)/2])hi=(lo+hi)/2;
	  else lo=(lo+hi)/2;
	}
      phi=lo;
    }
  else
    {
      tan = (256*adelx)/adely;
      lo  = G_pi2; hi = 0;
      for(i=G_AnglePrecision-3;i>=0;i--)
	{
	  if(tan<tangents[(lo+hi)/2])hi=(lo+hi)/2;
	  else lo=(lo+hi)/2;
	}
      phi = G_pi2-lo;
    }

  /*
   * The actual orientation is then determined
   * by using the signed values delx,dely.
   * Then get (dx,dy) which will be perpendicular
   * to the line and have a magnitude given
   * by the LineWidth.
   */
  if(dely<0)
    {
      if(delx<0)
	{
	  /* Line points to the upper left. */
	  dx =  ((gcp->LineWidth*cos(phi))>>8);
	  dy = -((gcp->LineWidth*sin(phi))>>8);
	}				
      else
	{
	  /* Line points to the upper right. */
	  dx = ((gcp->LineWidth*cos(phi))>>8);
	  dy = ((gcp->LineWidth*sin(phi))>>8);
	}
    }
  else
    {
      if(delx<0)
	{
	  /* Line points to the lower left. */
	  dx = -((gcp->LineWidth*cos(phi))>>8);
	  dy = -((gcp->LineWidth*sin(phi))>>8);
	}
      else
	{
	  /* Line points to the lower right. */
	  dx = -((gcp->LineWidth*cos(phi))>>8);
	  dy =  ((gcp->LineWidth*sin(phi))>>8);
	}
    }

  /*
   * Create a bounding box for the polygon.
   * In this case I overestimate for 
   * the sake of simplicity.
   */
  bounds->min.coor.x = lesser(x1,x2)  - gcp->LineWidth;
  bounds->min.coor.y = lesser(y1,y2)  - gcp->LineWidth;
  bounds->max.coor.x = greater(x1,x2) + gcp->LineWidth;
  bounds->max.coor.y = greater(y1,y2) + gcp->LineWidth;

  /*
   * Finally, we'll create all of the
   * points in the polygon.
   */
  uv[3].coor.x = dx + (uv[0].coor.x = x1 - (dx/2));
  uv[3].coor.y = dy + (uv[0].coor.y = y1 - (dy/2));
  uv[2].coor.x = dx + (uv[1].coor.x = x2 - (dx/2));
  uv[2].coor.y = dy + (uv[1].coor.y = y2 - (dy/2));

  /*
   * There's always four points.
   *  Later, if I allow for dashed lines,
   * then this value may change. (some multiple
   * of 4).
   */
  return 4;
}

int outline_rectangle( union point *poly, struct rectangle *bounds, int radius )
{
  int actual;
  int xi,yi;
  int kh,kv;
  int delta;
  int error;
  union point mid[25];
  union point last;
  int i,j;
  int errx,erry;

  /*
   * Set the current
   * point.
   */
  xi=0;
  yi=radius;
  
  /*
   * prepare the values
   * for the loop. This time
   * it is a circle, so it's
   * much easier than the 
   * ellipse.
   */
  delta=-2*(radius-1);
  kh=1;
  kv=2*radius-1;

  /*
   * Prepare array for
   * testing the flatness
   * of the curve.
   */
  j=0;
  mid[0].coor.x = xi;
  mid[0].coor.y = yi;
  last.coor.x = xi;
  last.coor.y = yi;

  /*
   * Add the first point
   * to the array.
   */
  poly[0].coor.x = xi;
  poly[0].coor.y = yi;
  actual = 1;

  /*
   * Perform the loop for creating
   * 1/4 of a circle. The pen is
   * always on.
   */
  while(yi>0)
    {
      if(delta<0)
	{
	  error=2*delta+kv;
	  if(error<=0)
	    {
	      xi++;
	      kh+=2;
	      delta+=kh;
	    }
	  else
	    {

	      xi++;
	      yi--;
	      kh+=2;
	      kv-=2;
	      delta+=kh-kv;
	    }
	}
      else
	{
	  
	  error=2*delta-kh;
	  if(error>=0)
	    {
	      yi--;
	      kv-=2;
	      delta-=kv;
	    }
	  else
	    {
	      xi++;
	      yi--;
	      kh+=2;
	      kv-=2;
	      delta+=kh-kv;
	    }
	}

      /*
       * Check the flatness of the curve.
       *  See flattenarc() for an explanation
       * of this portion. It is repeated
       * verbatim.
       */
      errx=mid[j>>1].coor.x-(xi+last.coor.x)/2;
      erry=mid[j>>1].coor.y-(yi+last.coor.y)/2;
      if(errx<0)errx=-errx;
      if(erry<0)erry=-erry;
      if(errx+erry>1||j==50)
	{ 
	  poly[actual].coor.x = xi;
	  poly[actual].coor.y = yi;
	  actual++;

	  j=0;
	  mid[0].coor.x = xi;
	  mid[0].coor.y = yi;
	  last.coor.x = xi;
	  last.coor.y = yi;
	}
      else 
	{
	  ++j;
	  if(j<25)
	    { mid[j].coor.x = xi;
	      mid[j].coor.y = yi;
	    }
	}

    }

  /*
   * Add the final point.
   */
  poly[actual].coor.x = radius;
  poly[actual].coor.y = 0;
  actual++;

      


  /*
   * When the loop is complete, then expand
   * the 1/4 arc into the rectangle outline.
   */
  for(i=0;i<actual;i++)
    {
      poly[i].coor.x = radius-poly[i].coor.x;
      poly[i].coor.y = radius-poly[i].coor.y;

      poly[2*actual+i].coor.x = 
	poly[4*actual-(i+1)].coor.x = bounds->max.coor.x - poly[i].coor.x;
      poly[2*actual-1-i].coor.y =
	poly[2*actual+i].coor.y = bounds->max.coor.y - poly[i].coor.y;

      poly[i].coor.x = 
	poly[2*actual-1-i].coor.x = bounds->min.coor.x + poly[i].coor.x;
      poly[i].coor.y = 
	poly[4*actual-(i+1)].coor.y = bounds->min.coor.y + poly[i].coor.y;
    }

  return(4*actual);
}


#define midpoint(mp,sp,ep) (mp.coor.x=(sp.coor.x+ep.coor.x)/2,mp.coor.y=(sp.coor.y+ep.coor.y)/2)

int flattenbezier( union point *poly, int max, int *mesh, struct rectangle *bounds )
{
  int actual;
  int mx,my,pp[14];

#define c0x (mesh[0])
#define c0y (mesh[1])
#define c1x (mesh[2])
#define c1y (mesh[3])
#define c2x (mesh[4])
#define c2y (mesh[5])
#define c3x (mesh[6])
#define c3y (mesh[7])

#define v1x (c1x-c0x)
#define v1y (c1y-c0y)
#define v2x (c2x-c0x)
#define v2y (c2y-c0y)
#define vx  (c3x-c0x)
#define vy  (c3y-c0y)

#define FLATNESS_TEST (1<<20)
#define abs(a) ((a)<0?-(a):(a))
  int ar1,ar2;

  /*
   * This function creates a linear approximation of a Bezier spline.  It
   * is done by continuous subdivision as proposed by Foley, vanDam, Steiner
   * and Hughs(those other two guys).  Special thanks to Helene Taran for
   * including source code with her(his?) program 'splines'. See fish
   * disk #97(the one with the juggler)
   */

  if(max>1)
    {
      /*
       * Check to see if the curve is close to a straight line. 
       * This test is done by checking the area of the control points.
       * The area is calculated by the cross-product of vectors.
       */
      ar1 = v1x*vy - vx*v1y;
      ar2 = v2x*vy - vx*v2y;
      if(abs(ar1)+abs(ar2) > FLATNESS_TEST)
	{
	  /*
	   * further subdivide the curve.
	   * Then send each one recursively
	   * into this function.
	   */
	  pp[0]  = c0x;
	  pp[1]  = c0y;
	  pp[12] = c3x;
	  pp[13] = c3y;
	  
	  pp[2] = (c0x+c1x)/2;
	  pp[3] = (c0y+c1y)/2;
	  pp[10] = (c2x+c3x)/2;
	  pp[11] = (c2y+c3y)/2;

	  mx = (c1x+c2x)/2;
	  my = (c1y+c2y)/2;
	  
	  pp[4] = (pp[2]+mx)/2;
	  pp[5] = (pp[3]+my)/2;
	  pp[8] = (pp[10]+mx)/2;
	  pp[9] = (pp[11]+my)/2;
	  
	  pp[6] = (pp[4]+pp[8])/2;
	  pp[7] = (pp[5]+pp[9])/2;

/*
poly[0].coor.x = pp[0]/(1<<8);
poly[0].coor.y = pp[1]/(1<<8);
poly[1].coor.x = pp[2]/(1<<8);
poly[1].coor.y = pp[3]/(1<<8);
poly[2].coor.x = pp[4]/(1<<8);
poly[2].coor.y = pp[5]/(1<<8);
poly[3].coor.x = pp[6]/(1<<8);
poly[3].coor.y = pp[7]/(1<<8);
poly[4].coor.x = pp[8]/(1<<8);
poly[4].coor.y = pp[9]/(1<<8);
poly[5].coor.x = pp[10]/(1<<8);
poly[5].coor.y = pp[11]/(1<<8);
poly[6].coor.x = pp[12]/(1<<8);
poly[6].coor.y = pp[13]/(1<<8);
bounds->min.coor.x = lesser(bounds->min.coor.x,poly[0].coor.x);
bounds->min.coor.x = lesser(bounds->min.coor.x,poly[1].coor.x);
bounds->min.coor.x = lesser(bounds->min.coor.x,poly[2].coor.x);
bounds->min.coor.x = lesser(bounds->min.coor.x,poly[3].coor.x);
bounds->min.coor.y = lesser(bounds->min.coor.y,poly[0].coor.y);
bounds->min.coor.y = lesser(bounds->min.coor.y,poly[1].coor.y);
bounds->min.coor.y = lesser(bounds->min.coor.y,poly[2].coor.y);
bounds->min.coor.y = lesser(bounds->min.coor.y,poly[3].coor.y);
bounds->max.coor.x = greater(bounds->max.coor.x,poly[0].coor.x);
bounds->max.coor.x = greater(bounds->max.coor.x,poly[1].coor.x);
bounds->max.coor.x = greater(bounds->max.coor.x,poly[2].coor.x);
bounds->max.coor.x = greater(bounds->max.coor.x,poly[3].coor.x);
bounds->max.coor.y = greater(bounds->max.coor.y,poly[0].coor.y);
bounds->max.coor.y = greater(bounds->max.coor.y,poly[1].coor.y);
bounds->max.coor.y = greater(bounds->max.coor.y,poly[2].coor.y);
bounds->max.coor.y = greater(bounds->max.coor.y,poly[3].coor.y);

return 7;
*/

	  /* Recursively call this function until flat. */
	  actual  = flattenbezier(poly,max-1,&pp[0],bounds);
	  actual += flattenbezier(poly+actual,max-actual,&pp[6],bounds);
	}
      else
	{
	  /*
	   * The curve is approximately straight.
	   * Add the point to the array.
	   */
	  poly[0].coor.x = c3x/(1<<8);
	  poly[0].coor.y = c3y/(1<<8);
	  actual = 1;
	 
	  /*
	   * Modify the bounds to include this new point.
	   */
	  bounds->min.coor.x = lesser(bounds->min.coor.x,poly->coor.x);
	  bounds->min.coor.y = lesser(bounds->min.coor.y,poly->coor.y);
	  bounds->max.coor.x = greater(bounds->max.coor.x,poly->coor.x);
	  bounds->max.coor.y = greater(bounds->max.coor.y,poly->coor.y);
	}
    }
  else
    { 
      /* There is only space left for one more point, so 
       * we must make the curve straight.
       */
      poly->coor.x = c3x/(1<<8);
      poly->coor.y = c3y/(1<<8);
      actual = 1;
	 
      /*
       * Modify the bounds to include this new point.
       */
      bounds->min.coor.x = lesser(bounds->min.coor.x,poly->coor.x);
      bounds->min.coor.y = lesser(bounds->min.coor.y,poly->coor.y);
      bounds->max.coor.x = greater(bounds->max.coor.x,poly->coor.x);
      bounds->max.coor.y = greater(bounds->max.coor.y,poly->coor.y);
    }
  return actual;
}
      
      

/* ellipse.c */



