/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: draw.c -- geometric primitive functions */
/*    |< |      created: May 15,1995                          */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

#include <exec/types.h>
#include <exec/memory.h>

#include "common.h"


/*
 * These are macros that I have defined for
 * use in draw.c.  These may find a new life
 * in common.c. But not all of them.
 */
#define PrepColors(pen1,pen2) if(gcp->DrawMode & GC_INVERSVID) \
                                {                              \
				  if(gcp->DrawMode & GC_JAM2)  \
				    {                          \
				      (pen1) = gcp->BgPen;     \
				      (pen2) = gcp->FgPen;     \
				    }                          \
				  else return;                 \
				}                              \
                              else                             \
                                {                              \
				  (pen1) = gcp->FgPen;         \
				  (pen2) = (gcp->DrawMode&GC_JAM2?gcp->BgPen:-1); \
				}  \

#define isPixelInside(rect,x,y) (((x) >= (rect).min.coor.x) && \
				 ((x) <= (rect).max.coor.x) && \
				 ((y) >= (rect).min.coor.y) && \
				 ((y) <= (rect).max.coor.y))

#define isPixelOutside(rect,x,y) (((x) < (rect).min.coor.x) || \
				  ((x) > (rect).max.coor.x) || \
				  ((y) < (rect).min.coor.y) || \
				  ((y) > (rect).max.coor.y))

#define isPixelInsideBM(bm,x,y) (((x) >= 0 && ((x) < (bm)->Width)) && \
				 ((y) >= 0 && ((y) < (bm)->Height)))

#define makeline(l,x1,y1,x2,y2) ((l).p1.coor.x = (x1), \
				 (l).p1.coor.y = (y1), \
				 (l).p2.coor.x = (x2), \
				 (l).p2.coor.y = (y2))

/*
 * This macro is called at the beginning of
 * each primitive except pixel(). This prepares
 * a simple bounding box for the operation.
 *  To save space this could be made into 
 * a function, but all the rectangles would
 * have to be passed as arguments. 
 */

BOOL prepclip( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, struct rectangle *r )
{
  if(clip)
    {           
      if(gcp->Area)
	{
	  if(!cliprectangle(gcp->Area,&clip->bounds,r))return FALSE;
	}
      else
	*r = clip->bounds;
    }                                               
  else
    {
      if(gcp->Area)
	{ 
	  r->min.coor.x = greater(0,gcp->Area->min.coor.x);
	  r->min.coor.y = greater(0,gcp->Area->min.coor.y);
	  r->max.coor.x = lesser(g_Width(bitmap)-1,gcp->Area->max.coor.x);
	  r->max.coor.y = lesser(g_Height(bitmap)-1,gcp->Area->max.coor.y);
	  if(r->min.coor.x > r->max.coor.x ||
	     r->min.coor.y > r->max.coor.y)return FALSE;
	}
      else g_Bounds(bitmap,*r);
    }
  return TRUE;
}

/*
 * Beginning of all the procedural
 * primitives. These are
 *
 *  pixel()  -- sets a single pixel in the output.
 *  line()   -- draws a thick/thin line between to points.
 *  rectangle() -- Draws a rectangular outline. Four cases: thick/thin and/or sharp/rounded.
 *  rectaglefill() -- Draws a filled rectangle with sharp or rounded corners.
 *  polygon()  -- Draws a filled polygon defined by an array of points.
 *  curve()  -- Draws a thin curve using bezier splines.
 *  arc()   -- Draws an elliptical arc. Thickness is changed using LineWidth.
 *  wedge()  --Draws a pie shaped wedge.
 */
 
void pixel( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, int x, int y )
{
  ulong pen1,pen2;
  struct cliprect *crectp;
  
  g_Message {
    g_PixelMsg;
  }g_EndMessage;
  
  
  /*
   * Checking clipping versus optional bounds in the gc.
   */
  if(gcp->Area)
    if(isPixelOutside(*gcp->Area,x,y))return;
  
  /*
   * Determine the color values from the gc.
   */
  PrepColors(pen1,pen2);
  
  g_PixelMsgPrep(pen1);
  
  if(clip)
    {
      /*
       * Check clipping for each node in the cliplist.
       */
      for(crectp=clip->list;crectp;crectp=crectp->next)
	{
	  if(isPixelInside(crectp->bounds,x,y))
	    g_PixelMsgSend(crectp->bitmap,x-crectp->origin.coor.x,
			                  y-crectp->origin.coor.y);
	}
    }
  else
    { 
      /*
       * Check the clipping versus the size of the bitmap.
       */
      if(isPixelInsideBM(bitmap,x,y))
	g_PixelMsgSend(bitmap,x,y);
    }
  return;
}


/*
 * Draw a line from (x1,y1) to (x2,y2).
 */


void line( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, int x1, int y1, int x2, int y2 )
/* entry for all line drawing. */
{
  int n;
  int i,actual;
  ulong front,back;
  struct cliprect *crectp;
  struct rectangle bounds;
  union point uv[16];    /* 16 is twice max points. */
  BitMapPtr mask;
  struct line l,copy;
  ulong width,height;
  struct rectangle area;

  /*
   * Prepare clipping area
   * and check for trivial
   * rejection.
   */
  if(!prepclip(clip,bitmap,gcp,&area))return;

  /*
   * Determine the colors for the line.
   */
  PrepColors(front,back);
  
  if(gcp->LineWidth>1)
    {
      back = -1;

      /*
       * Call outline function to generate polygon
       * of the line. The function returns the number
       * of points used. If I add dashed lines, this
       * may not be just 4.
       */

      if(n=lineoutline(&uv[0],gcp,x1,y1,x2,y2,&bounds))
	{
	  /*
	   * The preliminary clipping is just done to make
	   * sure that the mask is not extraordinarily huge.
	   */

	  if(actual = clippolygon(&bounds,&area,uv,uv,4))
	    {
	      /*
	       * Calculate the new dimensions and allocate
	       * a one-plane mask.
	       */
	      width  = rectwidth(bounds);
	      height = rectheight(bounds);
	      
	      if(mask=g_AllocMask(width,height,NULL))
		{
		  /*
		   * Shift the polygon in order that it
		   * fits completely within the mask.
		   */
		  for(i=0;i<actual;i++)movepoint(uv[i],-bounds.min.coor.x,
						       -bounds.min.coor.y);

		  /*
		   * Draw the polygon and blit
		   * it into the screen.
		   */
		  g_FillPolygon(mask,uv,actual,width,height);
		  filltwotone(clip,bitmap,front,-1,mask,&bounds,&area);
		  g_FreeMask(mask);
		}
	    }
	}
    }
  else
    {
      makeline(l,x1,y1,x2,y2);
      
      /*
       * Do a quick clip to fit the
       * line in bounds.
       */
      if(clipline(&area,&l))
	{
	  /*
	   * If the output is a cliplist, then
	   * check the clipping against each node.
	   * Otherwise, the line has already been
	   * clipped to the boundary of the bitmap.
	   */
	  if(clip)
	    {
	      for(crectp=clip->list;crectp;crectp=crectp->next)
		{
		  /*
		   * Need to reset the copy 
		   * of the line each time.
		   */
		  copy = l;
		  if(clipline(&crectp->bounds,&copy))
		    g_Line(crectp->bitmap,front,
		                  copy.p1.coor.x-crectp->origin.coor.x,
		                  copy.p1.coor.y-crectp->origin.coor.y,
		                  copy.p2.coor.x-crectp->origin.coor.x,
		                  copy.p2.coor.y-crectp->origin.coor.y);
		}
	    }
	  else g_Line(bitmap,front,l.p1.coor.x,l.p1.coor.y,
		                   l.p2.coor.x,l.p2.coor.y);
	}
    }
  return;
}

int ddebug =0;

void rectangle( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, int left, int top, int width, int height )
{
  int i;
  int round;
  int actual,length;
  ulong front,back;
  struct rectangle inside;
  struct rectangle area;
  union point *outline;
  struct rectangle bounds,rect,foo,clipped;
  struct cliprect *crectp;
  struct line l[4],copy;
  

  BitMapPtr mask,mask2;

  g_Message {
    g_RectangleMsg;
  }g_EndMessage;


  if(gcp->LineWidth>=width || gcp->LineWidth>=height)
    return rectanglefill(clip,bitmap,gcp,left,top,width,height);

  /*
   * Prepare clipping area
   * and check for trivial
   * rejection.
   */
  if(!prepclip(clip,bitmap,gcp,&area))return;

  /*
   * Read the pens from the graphics context and
   * prepare the rough clipping rectangle.
   */
  PrepColors(front,back);
  
  


  round = 2*gcp->Round;
  round = lesser(round,width-1);
  round = lesser(round,height-1);
  round = round/2;
  
  /*
   * There are four different possibilites.
   * a. a thin rectangle. In this case we just
   *    draw all the lines individually.
   * b. a thick and/or rounded rectangle (total of three
   *    cases) Here we create a mask and then
   *    blit it into the screen using filltwotone().
   *    The rounded edges are generated using
   *    an outline polygon. see rectangle_outline().
   */
  if(gcp->LineWidth||round)
    { /* begin thick/round */

      /*
       * Prepare ourselves for failure.
       */
      mask = NULL;
      
      if(gcp->LineWidth)
	{ /* begin thick. */

	  /*
	   * If it's width, then we must
	   * increase the dimensions of the
	   * mask. Then generate a bounding
	   * rectangle.
	   */
	  left -= gcp->LineWidth/2;
	  top  -= gcp->LineWidth/2;
	  width  += gcp->LineWidth;
	  height += gcp->LineWidth;

	  rect.max.coor.x = (width-1)  + (rect.min.coor.x = left);
	  rect.max.coor.y = (height-1) + (rect.min.coor.y = top);
          bounds = rect;
          
	  /*
	   * For now, calculate the inner
	   * rectangle dimensions here.
	   */
	  inside.min.coor.x = bounds.min.coor.x+gcp->LineWidth;
	  inside.min.coor.y = bounds.min.coor.y+gcp->LineWidth;
	  inside.max.coor.x = bounds.max.coor.x-gcp->LineWidth;
	  inside.max.coor.y = bounds.max.coor.y-gcp->LineWidth;
         
	  if(round)
	    { /* begin case A */

	      /*
	       * Calculate the radius of curvature of
	       * the outer portion of the rectangle.
	       */
	      round += gcp->LineWidth/2;

	      /*
	       * case A: Thick Rectangle with Rounding
	       *
	       * If the rectangle is rounded, then we'll need to
	       * generate some polygons for the outside and
	       * inside.  We'll generate two masks and combine
	       * the together as an XOR.
	       *   Be sure to allocated plenty of points.
	       */
	      length = 10* 8 * (round+gcp->LineWidth);
	      if(outline=(union point *)allocm(length*sizeof(union point)))
		{ /* allocated outline. */

		  actual = outline_rectangle(outline,&bounds,round,0);
 
		  /*
		   * Before clipping the polygon, get the current
		   * origin to check for changes. Also make a copy
		   * of the bounds for use with the
		   * inner polygon.
		   */
		  if(actual=clippolygon(&bounds,&area,outline,outline,actual))
		    {
		      /*
		       * Translate the points to fit within
		       * the mask.
		       */

		      /*
		       * Now it's safe to make the mask.
		       */
		      width  = rectwidth(bounds);
		      height = rectheight(bounds);

		      if(mask=g_AllocMask(width,height,NULL))
			{
			  for(i=0;i<actual;i++)
			    movepoint(outline[i],-bounds.min.coor.x,-bounds.min.coor.y);

			  g_FillPolygon(mask,outline,actual,width,height);
			  
			  /*
			   * Calculate the radius of curvature for the inner
			   * outline.  If it is one or less, then screw the
			   * polygon and just draw a rectangle.
			   */

			  if((round-=gcp->LineWidth)>1)
			    {
			      /*
			       * Create mask of the inside
			       * an XOR into the preivous
			       * mask.
			       */
			      actual=outline_rectangle(outline,&inside,round,gcp->LineWidth);
		              
			      /*
			       * clip the polygon and check for any 
			       * needed translation.
			       */
			      foo = area;
			      if(actual=clippolygon(&inside,&foo,outline,outline,actual))
				{
				  
				  /*
				   * Create the second mask and XOR
				   * with the first.
				   */  
				  if(mask2=g_AllocMask(width,height,NULL))
				    {
				      for(i=0;i<actual;i++)
					movepoint(outline[i],-bounds.min.coor.x,-bounds.min.coor.y);

				      g_FillPolygon(mask2,outline,actual,width,height);

				      g_BitBlt(mask,0,0,width,height,mask2,0,0,E_nSRC_DST|E_SRC_nDST);
				      g_FreeMask(mask2);
				    }
			  
				}
			    }
			  else
			    {
			      /*
			       * The interior has sharp corners
			       * so we just need a rectangle. Use
			       * color zero to remove. Be careful
			       * if the outline has been clipped.
			       */
			      if(cliprectangle(&inside,&area,&clipped))
				{
				  g_RectangleMsgPrep(0,-1);
				  g_RectangleMsgSend(mask,clipped.min.coor.x-bounds.min.coor.x,
						          clipped.min.coor.y-bounds.min.coor.y,
					                  rectwidth(clipped),
					                  rectheight(clipped));
				}
			    }
			}
		    }
		  /*
		   * The mask has been completed,
		   * so let's release the
		   * polygon array.
		   */
		  freem(outline);
		}
	    }
	  else
	    { /* begin case B */

	      /*
	       * case B: Thick Rectangle and No Rounding.
	       *
	       * The mask for a thick rectangle
	       * without rounding is easily accomplished
	       * with two reactangles.
	       *  Fill the entire mask and then if
	       * the lines aren't too thick draw the
	       * inside.
	       *  Note: I checked that it is okay to
	       * pass a rectangle as both a source
	       * a result for the cliprectangle() 
	       * function.
	       */
	      if(cliprectangle(&bounds,&area,&area))
		{
		  bounds = area;
		  /*
		   * Calculate the dimensions of
		   * the mask and fill it with
		   * 1's.
		   */
		  width  = rectwidth(area);
		  height = rectheight(area);
		  if(mask = g_AllocMask(width,height,NULL))
		    {
		      g_RectangleMsgPrep(1,-1);
		      g_RectangleMsgSend(mask,0,0,width,height);
		      
		      /*
		       * Now we need to clear the inside.
		       * If the rectangle created to 
		       * define the inner bounds is 
		       * a valid rectangle and when
		       * clipped there is still something
		       * left, then draw into the
		       * mask.
		       */
		      if(inside.min.coor.x<=inside.max.coor.x &&
			 inside.min.coor.y<=inside.max.coor.y &&
			 cliprectangle(&area,&inside,&clipped))
			{
			  g_RectangleMsgPrep(0,-1);
			  g_RectangleMsgSend(mask,clipped.min.coor.x-area.min.coor.x,
				   	          clipped.min.coor.y-area.min.coor.y,
					          rectwidth(clipped),rectheight(clipped));
			}
		    }
		}       
	    }
	}
      else
	{
	  /* 
	   * case C: Thin rectangle with rounded corners.
	   *
	   * In this case, we generate the outline of the
	   * rectangle and just draw it into the mask
	   * using the line primitive.
	   */
	  rect.max.coor.x = (width-1)  + (rect.min.coor.x = left);
	  rect.max.coor.y = (height-1) + (rect.min.coor.y = top);
	  bounds = rect;
      
	  length = 10*8*round;
	  if(outline=(union point *)allocm(length*sizeof(union point)))
	    {
	      if(actual=outline_rectangle(outline,&bounds,round,0))
		{
		  if(actual=clippolygon(&bounds,&area,outline,outline,actual))
		    {
		      if(mask=g_AllocMask(rectwidth(bounds),rectheight(bounds),NULL))
			{
			  /*
			   * Translate the points to
			   * the new bounds as we
			   * go along.
			   */
			  outline[0].coor.x -= bounds.min.coor.x;
			  outline[0].coor.y -= bounds.min.coor.y;
			  
			  for(i=1;i<actual;i++)
			    {
			      outline[i].coor.x -= bounds.min.coor.x;
			      outline[i].coor.y -= bounds.min.coor.y;
			      g_Line(mask,1,outline[i-1].coor.x,outline[i-1].coor.y,
				     outline[i].coor.x,outline[i].coor.y);			                  
			    }
			  g_Line(mask,1,outline[0].coor.x,outline[0].coor.y,
				 outline[actual-1].coor.x,outline[actual-1].coor.y);
			}
		    }
		}
	      freem(outline);
	    }
	}
	  /*
       * The mask should be complete here,
       * so blit it into the screen using
       * filltwotone().  Then we're done.
       */
      if(mask)
	{
	  filltwotone(clip,bitmap,front,-1,mask,&bounds,&area);
	  g_FreeMask(mask);
	}
    }
  else
    {
      /*
       * case D: Thin Rectangle with No Rounding
       *
       * In this case the rectangle is made up
       * of up to four line. The number depends
       * on the dimensions. For example, a rectangle
       * that is only one pixel has is just a 
       * horizontal line.
       *  So we're create an array of these lines
       * clip them to the priliminary bounds
       * and if anything is left, draw them
       * into the output.
       */
      actual=0;
      
      /* top line */
      makeline(l[0],left,top,left+width-1,top);
      if(cliphorizontal(&area,&l[0]))actual++;
	  
      /* bottom line. */
      if(height>1)
	{
	  makeline(l[actual],left,top+height-1,left+width-1,top+height-1);
	  if(cliphorizontal(&area,&l[actual]))actual++;
	  
	  if(height>2)
	    {
	      /* left line. */
	      makeline(l[actual],left,top+1,left,top+height-2);
	      if(clipvertical(&area,&l[actual]))actual++;

	      /* right line. */
	      makeline(l[actual],left+width-1,top+1,left+width-1,top+height-2);
	      if(clipline(&area,&l[actual]))actual++;
	    }
	}
      
      /*
       * actual contains the number of lines to
       * be drawn. If there aren't any, then we
       * can leave now.
       */
      if(!actual)return;
      
	  
      /*
       * Choose between two outputs. Remember, if there
       * isn't a cliplist, then we've already clipped
       * to the bitmap.
       */
      if(clip)
	{
	  for(crectp=clip->list;crectp;crectp=crectp->next)
	    {
	      for(i=0;i<actual;i++)
		{
		  /*
		   * The copy needs to be
		   * fixed before each use.
		   */
		  copy=l[i];
		  if(clipline(&crectp->bounds,&copy))
		    g_Line(crectp->bitmap,front,
			   copy.p1.coor.x - crectp->origin.coor.x,
			   copy.p1.coor.y - crectp->origin.coor.y,
			   copy.p2.coor.x - crectp->origin.coor.x,
			   copy.p2.coor.y - crectp->origin.coor.y);
		}
	    }
	}
      else
	{
	  /*
	   * No more clipping is required
	   * for the bitmap.
	   */
	  for(i=0;i<actual;i++)
	    g_Line(bitmap,front,l[i].p1.coor.x,l[i].p1.coor.y,
		                   l[i].p2.coor.x,l[i].p2.coor.y); 

	}
    }
  return;
}

  
void rectanglefill( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, int left, int top, int width, int height )
{
  int i,length,actual;
  ulong front,back;
  unsigned long round;
  struct rectangle bounds,rect,clipped,area,rect2;
  BitMapPtr mask;
  union point *outline;
  struct cliprect *crectp;

  g_Message {
    g_RectangleMsg;
  }g_EndMessage;
  
  /*
   * Prepare clipping area
   * and check for trivial
   * rejection.
   */
  if(!prepclip(clip,bitmap,gcp,&area))return;
  
  /*
   * generate the bounds for 
   * clipping.
   */
  rect.max.coor.x = (width-1)  + (rect.min.coor.x=left);
  rect.max.coor.y = (height-1) + (rect.min.coor.y=top);
  bounds = rect;
  
  PrepColors(front,back);
  
  
  /*
   * Rectangle filling has only two
   * cases. Either the rectangle is rounded
   * and must be created with a polygon, or
   * it has sharp corners and drawing is
   * much faster.
   */
  
  round = (lesser(width,height)-1)/2;
  round = lesser(round,gcp->Round);

  if(round)
    {
      /*
       * Whole thing is done in two easy steps.
       * 1. generate the outline or the rectangle
       *    and clip to the output bounds.
       * 2. create the mask and blit to the output.
       */
      length = 10*8*round;
      if(outline=(union point *)allocm(length*sizeof(union point)))
	{
	  actual = outline_rectangle(outline,&bounds,round);
          if(actual=clippolygon(&bounds,&area,outline,outline,actual))
            {
	      /*
	       * Polygon has been clipped to new
	       * dimensions, so let's 
	       * figure those out. Then 
	       * create the mask.
	       */
	      width  = rectwidth(bounds);
	      height = rectheight(bounds);
	      if(mask=g_AllocMask(width,height,NULL))
		{
		  for(i=0;i<actual;i++)
		    movepoint(outline[i],-bounds.min.coor.x,-bounds.min.coor.y);
		  g_FillPolygon(mask,outline,actual,width,height);
		  filltwotone(clip,bitmap,front,-1,mask,&bounds,&area);
		  g_FreeMask(mask);
		}
	    }
	  freem(outline);
        }
    }
  else
    {
      /*
       * This one is easiest of all. Just
       * draw rectangles.
       */
      if(cliprectangle(&area,&rect,&rect2))
	{
	  
	  g_RectangleMsgPrep(front,back);
      
	  if(clip)
	    {
	      for(crectp=clip->list;crectp;crectp=crectp->next)
		if(cliprectangle(&rect2,&crectp->bounds,&clipped))
		  g_RectangleMsgSend(crectp->bitmap,
				     clipped.min.coor.x-crectp->origin.coor.x,
				     clipped.min.coor.y - crectp->origin.coor.y,
				     rectwidth(clipped),
				     rectheight(clipped));
	    }
	  else
	    {
	      g_RectangleMsgSend(bitmap,rect2.min.coor.x,
				        rect2.min.coor.y,
				        rectwidth(rect2),
				        rectheight(rect2));
	    }
	}
    }
  return;
}

void polygon( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, union point *xy, int count )
{
  int i,j,actual;
  ulong front,back;
  BitMapPtr mask,mask2;
  struct rectangle bounds,area;
  union point *copy;
  ulong width,height;
  unsigned char *ptr1,*ptr2;
  
  /*
   * Prepare the simple clipping
   * rectangle before allocating
   * any points.
   */
  if(!prepclip(clip,bitmap,gcp,&area))return;
     
  /*
   * First of all, we need to calculate
   * the bounding box of the polygon.
   */
  bounds.min.xy = xy->xy;
  bounds.max.xy = xy->xy;
  for(i=1;i<count;i++)
    { bounds.min.coor.x = lesser(bounds.min.coor.x,xy[i].coor.x);
      bounds.min.coor.y = lesser(bounds.min.coor.y,xy[i].coor.y);
      bounds.max.coor.x = greater(bounds.max.coor.x,xy[i].coor.x);
      bounds.max.coor.y = greater(bounds.max.coor.y,xy[i].coor.y);
    }

  /* 
   * Before we can manipulate the polygon
   * we need a buffer to put the changes
   * into. We don't want to screw with the
   * users points.
   */
  if(copy=(union point *)allocm(4*count*sizeof(union point)))
    { 
      PrepColors(front,back);
      
      /*
       * Now do a preliminary clip to make
       * sure that the polygon mask
       * is not gigantic compared to
       * the output.
       */
      if(actual=clippolygon(&bounds,&area,copy,xy,count))
	{
	  /*
	   * Polygon is ready for drawing.
	   * Generate the mask and blit into
	   * the screen like usual.
	   */
	  width  = rectwidth(bounds);
	  height = rectheight(bounds);
	  if(mask=g_AllocMask(width,height,NULL))
	    { 
	      for(i=0;i<actual;i++)
		movepoint(copy[i],-bounds.min.coor.x,-bounds.min.coor.y);
	      g_FillPolygon(mask,copy,actual,width,height);
	      if(mask2=g_AllocMask(width,height,NULL))
		{
		  /*
		   * This is a kludge because EGS does
		   * not draw polygons correctly.  If it is
		   * concave on the bottom, then it wil be
		   * filled in.  So I'll draw the polygon
		   * again upside down and then combine
		   * the two together.
		   */

		  for(i=0;i<actual;i++)
		    copy[i].coor.y = (height-1)-copy[i].coor.y;
		  g_FillPolygon(mask2,copy,actual,width,height);

		  mask->Lock++;
		  mask2->Lock++;
		  ptr1 = (char *)mask->Plane;
		  ptr2 = ((char *)mask2->Plane) +
		    mask->BytesPerRow*(mask->Height-1);
		  for(j=0;j<mask->Height;j++)
		    {
		      for(i=0;i<mask->BytesPerRow;i++)
			ptr1[i] &= ptr2[i];
		      ptr1 += mask->BytesPerRow;
		      ptr2 -= mask->BytesPerRow;
		    }
		  mask->Lock--;
		  mask2->Lock--;

		  filltwotone(clip,bitmap,front,-1,mask,&bounds,&area);
		  g_FreeMask(mask2);
		}
	      g_FreeMask(mask);
	    }
	}
      freem(copy);
    }
  return;
}

void arc( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, int x, int y, int width, int height, int ang1, int ang2 )
{
  char *ptr1,*ptr2;
  int i,j,n1,n2;
  int length,actual;
  union point *poly;
  struct rectangle bounds,rect,area,copy,inside;
  ulong w,h;
  BitMapPtr mask,mask2;
  
  ulong front,back;
  
  if(!prepclip(clip,bitmap,gcp,&area))return;
  
  PrepColors(front,back);
  
  
  /*
   * Arc drawing creates a polygon of
   * the actual shape to be drawn an
   * then fills it in.  If it is thin,
   * then just draw the lines.
   * In either case a mask is created
   * first.
   */
  mask = NULL;
  
  length = greater(width,height);
  length = greater(25,length);
  length = length*200;
  if(poly=(union point *)allocm(2*length*sizeof(union point)))
    {
      /*
       * The real bounds is created by flattenarc.
       * It allows you to give a previous bounds
       * and then modifies it.  Here I've set
       * the bounds to impossible values. These
       * will be changed when the first point
       * is added to the outline.
       */
      bounds.min.coor.x = width;
      bounds.min.coor.y = height;
      bounds.max.coor.x = -width;
      bounds.max.coor.y = -height;
      
      if(gcp->LineWidth>1)
	{
	  /*
	   * If the arc is to be thick, then draw both
	   * the inside and outside portions into
	   * the point array.
	   *  The first goes clockwise and the
	   * other goes anti-clockwise.
	   */
	  if(n1=flattenarc(poly,length,width-gcp->LineWidth/2+1,height-gcp->LineWidth/2+1,ang1,ang2,&bounds))
	    {
	      if(n2 = flattenarc(poly+n1,length,width+gcp->LineWidth/2,height+gcp->LineWidth/2,ang2,ang1,&bounds))
		{
		  bounds.min.coor.x += x;
		  bounds.min.coor.y += y;
		  bounds.max.coor.x += x;
		  bounds.max.coor.y += y;
		  rect = bounds;
		  
		  /*
		   * Translate the polygon to screen
		   * coordinates for clipping.
		   */
		  for(i=0;i<n1+n2;i++)movepoint(poly[i],x,y);
		  
		  if(ang2-ang1>=G_2pi)
		    {
		      /*
		       * In this case, a complete arc is being
		       * drawn. So
		       * make a mask for the outer and inner,
		       * then XOR
		       * the two together.
		       */
		      if(actual=clippolygon(&bounds,&area,poly,poly,n1))
			{
			  w = rectwidth(bounds);
			  h = rectheight(bounds);
			  if(mask=g_AllocMask(w,h,NULL))
			    {
			      for(i=0;i<actual;i++)
				movepoint(poly[i],-bounds.min.coor.x,-bounds.min.coor.y);
			      
			      
			      g_FillPolygon(mask,poly,actual,w,h);
			      
			      /*
			       * Now we can draw the inside 
			       * polygon.
			       */
			      copy = area;
			      if(actual=clippolygon(&inside,&copy,poly+n1,poly,n2))
				{
				  /*
				   * Allocate a second mask, draw theh
				   * polygon and then XOR.
				   */
				  if(mask2=g_AllocMask(w,h,NULL))
				    {
				      for(i=0;i<actual;i++)
					movepoint(poly[i],-bounds.min.coor.x,-bounds.min.coor.y);
				      g_FillPolygon(mask2,poly,actual,w,h);
				      g_BitBlt(mask,0,0,w,h,mask2,0,0,E_nSRC_DST|E_SRC_nDST);
				      g_FreeMask(mask2);
				    }
				}
			    }
			}
		    }
		  else
		    {
		      /*
		       * The arc is not complete, so it can
		       * be drawn with just a single polygon.
		       * First, we clip, then we draw
		       * into into the mask.
		       */
		      if(actual=clippolygon(&bounds,&area,poly,poly,n1+n2))
			{
			  w = rectwidth(bounds);
			  h = rectheight(bounds);
			  if(mask=g_AllocMask(w,h,NULL))
			    {
			      for(i=0;i<actual;i++)
				movepoint(poly[i],-bounds.min.coor.x,-bounds.min.coor.y);
			      g_FillPolygon(mask,poly,actual,w,h);
			      
			      /*
			       * Again because EGS does not
			       * draw concave polygons correctly
			       * then we'll need to draw it
			       * again upside down and combine.
			       */
			      if(mask2=g_AllocMask(w,h,NULL))
				{
				  for(i=0;i<actual;i++)
				    poly[i].coor.y = (h-1)-poly[i].coor.y;
				  g_FillPolygon(mask2,poly,actual,w,h);
				  mask->Lock++;
				  mask2->Lock++;
				  ptr1 = (char *)mask->Plane;
				  ptr2 = ((char *)mask2->Plane)+
				    (h-1)*mask->BytesPerRow;
				  for(j=0;j<mask->Height;j++)
				    {
				      for(i=0;i<mask->BytesPerRow;i++)
					ptr1[i] &= ptr2[i];
				      ptr1+=mask->BytesPerRow;
				      ptr2-=mask->BytesPerRow;
				    }
				  mask->Lock--;
				  mask2->Lock--;

				  g_FreeMask(mask2);
				}
				  
			    }
			}
		    }
		}
	    }
	} /* LineWidth>1 */
      else
	{
	  /*
	   * If the linewidth is zero or one, the
	   * Just generate the outline once and
	   * draw it into the mask using the
	   * line primitive.
	   */ 
	  if(actual=flattenarc(poly,length,width,height,ang1,ang2,&bounds))
	    {
	      /*
	       * Translate the bounds to real coordinates.
	       * Before they are centered around the
	       * center of the arc.
	       */
	      bounds.min.coor.x += x;
	      bounds.min.coor.y += y;
	      bounds.max.coor.x += x;
	      bounds.max.coor.y += y;
	      for(i=0;i<actual;i++)movepoint(poly[i],x,y);
	      
	      /*
	       * Clip the polygon to the
	       * simple rectangular bounds
	       * and then draw it into
	       * the mask.
	       */
	      if(actual=clippolygon(&bounds,&area,poly,poly,actual))
		{
		  width  = rectwidth(bounds);
		  height = rectheight(bounds);
		  if(mask=g_AllocMask(width,height,NULL))
		    {
		      movepoint(poly[0],-bounds.min.coor.x,-bounds.min.coor.y);
		      for(i=1;i<actual;i++)
			{
			  movepoint(poly[i],-bounds.min.coor.x,-bounds.min.coor.y);
			  g_Line(mask,1,poly[i-1].coor.x,poly[i-1].coor.y,
				 poly[i].coor.x,poly[i].coor.y);
			}
		    }
		}
	    }
	}
      /*
       * We're all done with polygons
       * now, so get rid of the array.
       */
      freem(poly);
      
      /*
       * If the mask was successfully created, then
       * blit to the output using filltwotone().
	   */
      if(mask)
	{
	  filltwotone(clip,bitmap,front,-1,mask,&bounds,&area);
	  g_FreeMask(mask);
	}
    }
  return;
}

void wedge( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, int x, int y, int width, int height, int ang1, int ang2 )
{
  int i,j;
  int length,actual;
  union point *poly;
  struct rectangle bounds,rect,area;
  BitMapPtr mask,mask2;
  char *ptr1,*ptr2;
  
  ulong front,back;
  

  
  /*
   * Prepare preliminary clipping
   * rectangle and return
   * on failure.
   */
  if(!prepclip(clip,bitmap,gcp,&area))return;
  
  PrepColors(front,back);
  
  length = greater(width,height);
  length = greater(25,length);
  length = (length<<3+1)*10;

  if(poly=(union point *)allocm(sizeof(union point)*length))
    {
      /*
       * Automatically set the center of the
       * ellipse as the vertex of the pie wedge.
       * Only do this, if the angles do not
       * span the full range.
       */
      if(ang2-ang1<G_2pi)
        {
          bounds.min.xy = 0;
          bounds.max.xy = 0;
          poly[0].xy=0;
          actual = 1;
	}
      else
	{
          bounds.max.coor.x = -width;
          bounds.max.coor.y = -height;
          bounds.min.coor.x = +width;
          bounds.min.coor.y = +width;
          actual = 0;
	  
        }
      
      
      if(actual+=flattenarc(poly+actual,length,width,height,ang1,ang2,&bounds))
	{
	  
	  
	  /*
	   * Shift the bounds to the
	   * coordinates of the output.
	   */
	  bounds.min.coor.x += x;
	  bounds.min.coor.y += y;
	  bounds.max.coor.x += x;
	  bounds.max.coor.y += y;
	  rect = bounds;
	  
	  /*
	   * Translate the coordinates to
	   * the screen so that they may
	   * be clipped.
	   */
	  for(i=0;i<actual;i++)movepoint(poly[i],x,y);
	  
	  if(actual=clippolygon(&bounds,&area,poly,poly,actual))
	    {
	      /*
	       * The polygon has been clipped, so
	       * let's create the mask.  Then blit
	       * to the output.
	       */
	      width  = rectwidth(bounds);
	      height = rectheight(bounds);
	      if(mask=g_AllocMask(width,height,NULL))
		{
		  for(i=0;i<actual;i++)
		    movepoint(poly[i],-bounds.min.coor.x,-bounds.min.coor.y);
		  g_FillPolygon(mask,poly,actual,width,height);

		  if(mask2=g_AllocMask(width,height,NULL))
		    {
		      for(i=0;i<actual;i++)
			poly[i].coor.y = (height-1)-poly[i].coor.y;
		      g_FillPolygon(mask2,poly,actual,width,height);
		      mask->Lock++;
		      mask2->Lock++;
		      ptr1 = (char *)mask->Plane;
		      ptr2 = ((char *)mask2->Plane)+
			(height-1)*mask->BytesPerRow;
		      for(j=0;j<mask->Height;j++)
			{
			  for(i=0;i<mask->BytesPerRow;i++)
			    ptr1[i] &= ptr2[i];
			  ptr1+=mask->BytesPerRow;
			  ptr2-=mask->BytesPerRow;
			}
		      mask->Lock--;
		      mask2->Lock--;
		      
		      g_FreeMask(mask2);
		    }

		  filltwotone(clip,bitmap,front,-1,mask,&bounds,&area);
		  g_FreeMask(mask);
		}
	    }
	}
      freem(poly);
    }
  return;
}

#define MAXIMUM_POINTS 1000

void spline( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, union point *control )
{
  int i,actual;
  union point *curve;
  struct rectangle bounds,rect,area;
  BitMapPtr mask;
  int mesh[8];

  ulong front,back;

  if(!prepclip(clip,bitmap,gcp,&area))return;
  
  PrepColors(front,back);
  
  /*
   * This function uses bezier curves to generate a
   * spline. The curve is approximated by an 
   * array of points generated by flattenbezier() in
   * the ellipse.c source.
   */
  if(curve=(union point *)allocm(MAXIMUM_POINTS*sizeof(union point)))
    {
      curve[0] = control[0];
      bounds.min = bounds.max = control[0];
      
      mesh[0] = ((int)control[0].coor.x)*(1<<8);
      mesh[1] = ((int)control[0].coor.y)*(1<<8);
      mesh[2] = ((int)control[1].coor.x)*(1<<8);
      mesh[3] = ((int)control[1].coor.y)*(1<<8);
      mesh[4] = ((int)control[2].coor.x)*(1<<8);
      mesh[5] = ((int)control[2].coor.y)*(1<<8);
      mesh[6] = ((int)control[3].coor.x)*(1<<8);
      mesh[7] = ((int)control[3].coor.y)*(1<<8);

      actual = 1+flattenbezier(curve+1,MAXIMUM_POINTS-1,mesh,&bounds);
      rect = bounds;
      
      /*
       * Now we must clip
       */
      if(actual=clippolygon(&bounds,&area,curve,curve,actual))
	{
	  if(mask=g_AllocMask(rectwidth(bounds),rectheight(bounds),NULL))
	    {
	      /*
	       * Translate the points to fit
	       * within the bounds
	       * as we go along.
	       */
	      movepoint(curve[0],-bounds.min.coor.x,-bounds.min.coor.y);
	      for(i=1;i<actual;i++)
		{ 
		  movepoint(curve[i],-bounds.min.coor.x,-bounds.min.coor.y);
		  g_Line(mask,1,curve[i-1].coor.x,curve[i-1].coor.y,
			 curve[i].coor.x,curve[i].coor.y);
		}
	      
	      filltwotone(clip,bitmap,front,-1,mask,&bounds,&area);
	      g_FreeMask(mask);
	    }
	}
      freem(curve);
    }
  return;
}


/* blitter functions */

/* template functions */

void filltwotone( struct cliplist *clip, BitMapPtr bitmap, ulong front, ulong back, BitMapPtr mask, struct rectangle *rect1, struct rectangle *rect2 )
{
  struct rectangle clipped;
  struct cliprect *crectp;
  g_Message {
    g_StencilMsg;
  }g_EndMessage;
  
  g_StencilMsgPrep(mask,front,back);
  
  if(clip)
    {
      /*
       * Run through the clipping list
       * and find where to draw the
       * mask.
       */
      for(crectp=clip->list;crectp;crectp=crectp->next)
	if(cliprectangle(rect2,&crectp->bounds,&clipped))
	   g_StencilMsgSend(crectp->bitmap,clipped.min.coor.x-crectp->origin.coor.x,
			                  clipped.min.coor.y-crectp->origin.coor.y,
			                  rectwidth(clipped),
			                  rectheight(clipped),
			                  clipped.min.coor.x-rect1->min.coor.x,
			                  clipped.min.coor.y-rect1->min.coor.y);
    }
  else
    {
      /*
       * Before this function is called, the
       * mask should have been clipped to the
       * rectangle generated by prepclip(). This
       * rectangle is at least within the bounds
       * of the bitmap, so no more clipping is required.
       */
      g_StencilMsgSend(bitmap,rect2->min.coor.x,rect2->min.coor.y,
		              rectpwidth(rect2),rectpheight(rect2),
			      rect2->min.coor.x-rect1->min.coor.x,
			      rect2->min.coor.y-rect1->min.coor.y); 
    }

  return;
}


void blit( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, int left, int top, ulong width, ulong height, BitMapPtr source, int srcx, int srcy )
{
  struct rectangle bounds,rect,clipped,area;
  struct cliprect *crectp;
  
  g_Message {
    g_BitBltMsg;
  }g_EndMessage;
  
  /*
   * Determine the bounds of the
   * destination blit.
   */
  rect.max.coor.x = (width-1)  + (rect.min.coor.x = left);
  rect.max.coor.y = (height-1) + (rect.min.coor.y = top);
  
  /*
   * Prepare the preliminary
   * clipping boundary.
   */
  if(!prepclip(clip,bitmap,gcp,&area))return;
  
  /*
   * Clip the rectangle to the
   * preliminary area. This will
   * be bounds of
   * the blit.
   */
  
  if(cliprectangle(&area,&rect,&bounds))
    {
      /*
       * Prepare the OO message
       * for the bitmap.
       */
      g_BitBltMsgPrep(source,gcp->Mode,gcp->Mask);
      
      /*
       * Finally, if the output is a clipping list,
       * then check the bounds versus each node. Send
       * the message if the result is TRUE.
       *  If the output is just a single bitmap, then
       * the preliminary clip is the only
       * test that we need.
       */
      if(clip)
        {
          for(crectp=clip->list;crectp;crectp=crectp->next)
	    if(cliprectangle(&bounds,&crectp->bounds,&clipped))
	      g_BitBltMsgSend(crectp->bitmap,clipped.min.coor.x-crectp->origin.coor.x,
		                             clipped.min.coor.y-crectp->origin.coor.y,
		                             rectwidth(clipped),
		                             rectheight(clipped),
		                             srcx+(clipped.min.coor.x-bounds.min.coor.x),
		                             srcy+(clipped.min.coor.y-bounds.min.coor.y));

	}
      else g_BitBltMsgSend(bitmap,bounds.min.coor.x,bounds.min.coor.y,
		                  rectwidth(bounds),rectheight(bounds),
		                  srcx+(bounds.min.coor.x-rect.min.coor.x),
		                  srcy+(bounds.min.coor.y-rect.min.coor.y));
	
    }
  return;
}

void blitmask( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, int left, int top, ulong width, ulong height, BitMapPtr source, int srcx, int srcy, BitMapPtr mask, int mskx, int msky )
{
  int dx,dy;
  struct rectangle bounds,rect,clipped,area;
  struct cliprect *crectp;
  BitMapPtr buffer;
  
  g_Message {
    g_BitBltMsg;
    g_StencilPattMsg;
  }g_EndMessage;
  
  /*
   * Make sure the mask is
   * only one bitplane.
   */
  if(g_Depth(mask)!=1)return;
  
  /*
   * Prepare the intial bounds of the operation
   * in global coordinates.
   */
  rect.max.coor.x = (width-1)  + (rect.min.coor.x = left);
  rect.max.coor.y = (height-1) + (rect.min.coor.y = top);
  
  /*
   * Prepare the rectangle 'area' with
   * the preliminary clipping zone.
   */
  if(!prepclip(clip,bitmap,gcp,&area))return;
  
  /*
   * blitmask() works by first copying a portion
   * of the output bitmap into
   * a temporary buffer and performing
   * the blit into it. Then the buffer
   * is used as a pattern and copied
   * back into the output using
   * the mask.
   */
  if(cliprectangle(&rect,&area,&bounds))
    {
      /*
       * The area of the blit is now
       * defined by left+dx,top+dy and
       * width,height.
       */
      dx = bounds.min.coor.x - rect.min.coor.x;
      dy = bounds.min.coor.y - rect.min.coor.y;
      width  = rectwidth(bounds);
      height = rectheight(bounds);
      
      if(clip)
	{
	  /*
	   * As I recall the cliplist is created
	   * in reverse order of the bitmaps as
	   * they are created.  So the last
	   * bitmap in the list is the one 
	   * we want to use.
	   */
	  if(crectp=clip->list)
	    {
	      while(crectp->next_bitmap)crectp=crectp->next_bitmap;
	      /*
	       * Now we can do the
	       * copying.
	       */
	      if(buffer=g_AllocBitMap(width,height,g_Depth(crectp->bitmap),crectp->bitmap))
		g_Copy(buffer,0,0,width,height,crectp->bitmap,left+dx-crectp->origin.coor.x,
		       top+dy-crectp->origin.coor.y);
	    }
	  else buffer = NULL;
	}
      else
	{
	  /*
	   * Copy bounds from bitmap.
	   */
	  if(buffer=g_AllocBitMap(width,height,g_Depth(bitmap),bitmap))
	    g_Copy(buffer,0,0,width,height,bitmap,left+dx,top+dy);
	}
      
      if(buffer)
	{
	  /*
	   * Now that the intermediate bitmap
	   * has been prepared, we can perform
	   * the operation into it.
	   */
	  g_BitBltMsgPrep(source,gcp->Mode,gcp->Mask);
	  g_BitBltMsgSend(buffer,0,0,width,height,srcx+dx,srcy+dy);
	  
	  /*
	   * Finally, we can copy the
	   * resulting bitmap into the output
	   * through the mask.
            */
	  g_StencilPattMsgPrep(mask,buffer);
	  
	  /*
	   * Now if the output is a cliplist, then check
	   * each node in the list. If there is overlap
	   * send a stencil message.
	   *  If the output is a bitmap, then
	   * the clipping has already been done,
	   * and 'bounds' gives
	   * the size of the affected
	   * area.
	   */
	  if(clip)
	    {
	      for(crectp=clip->list;crectp;crectp=crectp->next)
		if(cliprectangle(&bounds,&crectp->bounds,&clipped))	
		  g_StencilPattMsgSend(crectp->bitmap,
				       clipped.min.coor.x-crectp->origin.coor.x,
				       clipped.min.coor.y-crectp->origin.coor.y,
				       rectwidth(clipped),
				       rectheight(clipped),
				       mskx+dx+clipped.min.coor.x-bounds.min.coor.x,
				       msky+dx+clipped.min.coor.y-bounds.min.coor.y,
				       clipped.min.coor.x-bounds.min.coor.x,
				       clipped.min.coor.y-bounds.min.coor.y);
	      
	    }
	  else g_StencilPattMsgSend(bitmap,bounds.min.coor.x,bounds.min.coor.y,
				    width,height,
				    mskx+dx,msky+dy,
				    0,0);
	  
	  /*
	   * Now we can eliminate the
	   * intermediate bitmap.
	   */
	  g_FreeBitMap(buffer);
        }
    }
  return;
}

void template( struct cliplist *clip, BitMapPtr bitmap, G_GCPtr gcp, int left, int top, ulong width, ulong height, BitMapPtr source, int srcx, int srcy )
{
  ulong front,back;
  struct rectangle bounds,rect,area;
  
  struct rectangle clipped;
  struct cliprect *crectp;
  g_Message {
    g_StencilMsg;
  }g_EndMessage;
  
  /*
   * The source must
   * be a single plane bitmap
   * for this to work.
   */
  if(g_Depth(source)!=1)return;
  
  rect.max.coor.x = (width-1)  + (rect.min.coor.x = left);
  rect.max.coor.y = (height-1) + (rect.min.coor.y = top);
  
  PrepColors(front,back);
  
  /*
   * Generate simple clipping
   * area for preliminary clipping.
   */
  if(!prepclip(clip,bitmap,gcp,&area))return;
  
  
  /*
   * Prepare 'bounds' by doing
   * preliminary clipping.
   */
  if(cliprectangle(&area,&rect,&bounds))
    {
      
      /* 
       * Prepare the stencil message
       * before drawing.
       */ 
      g_StencilMsgPrep(source,front,back);
      
      /*
       * If a cliplist, then check against each
       * node. Otherwise, the bounds are already
       * clipped to the bitmap.
       */
      if(clip)
        {
          for(crectp=clip->list;crectp;crectp=crectp->next)
	    if(cliprectangle(&bounds,&crectp->bounds,&clipped))
	      g_StencilMsgSend(crectp->bitmap,
			       clipped.min.coor.x-crectp->origin.coor.x,
			       clipped.min.coor.y-crectp->origin.coor.y,
			       rectwidth(clipped),rectheight(clipped),
			       srcx+clipped.min.coor.x-rect.min.coor.x,
			       srcy+clipped.min.coor.y-rect.min.coor.y);
	  
	  
        }
      else g_StencilMsgSend(bitmap,bounds.min.coor.x,bounds.min.coor.y,
			    rectwidth(bounds),rectheight(bounds),
			    srcx+bounds.min.coor.x-rect.min.coor.x,
			    srcy+bounds.min.coor.y-rect.min.coor.y);
      
    }
  
  return;
}

/* draw.c */

