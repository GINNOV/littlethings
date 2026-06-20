/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: clip.c -- graphics clipping list        */
/*    |< |                         generation.                */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/


#include "common.h"
#include "layers.h"


/*
 * This file contains two sections:
 *  The first contains routines for clipping the
 * following primitives.
 *  a. lines
 *  b. rectangles
 *  c. polygons/flattened curves.
 *
 *  The second section contains functions for creating
 * and maintaining the clipping lists used by layers
 * to allow drawing into specific regions of multiple
 * bitmaps.
 */


/*
 * Line clipping.
 *
 *  These functions are my implementation of
 * the Cohen-Sutherland line clipping algorithm.
 * Just check out any good computer graphics
 * text.
 *  The functions for this purpose include:
 *   checkbounds() -- returns flags depending on
 *                    where a point is relative
 *                    to a rectangular bounding
 *                    box.
 *
 *   cutline()  -- This function uses a binary
 *                 search to find the point at
 *                 which a line segment between
 *                 two points crosses the boundary
 *                 of a rectangle. This should only
 *                 be called if we know that the
 *                 two points are inside and outside.
 *
 *   clipline()  -- This function clips a line defined
 *                  by a line structure. (see common.h)
 *                  This is the entry point for the
 *                  line clipping functions. This function
 *                  subdivides a line until it is either
 *                  all inside, all outside, or one-half
 *                  in and the other half out.
 *
 *   cliphorizontal() -- In the case of a horizontal or
 *   clipvertical()      vertical line, the clipping is
 *                       much easier. These can also
 *                       be called if you know that your
 *                       line is appropriately non-diagonal.
 *   IMPORTANT POINT: Because these functions might be
 *                    used by the polygon clipping function,
 *                    the order of the points MUST be
 *                    maintained.
 */
  
ulong checkbounds( struct rectangle *bounds, int x, int y )
{
  ulong check;
  
  /*
   * Check the point versus each boundary
   * and set a flag accordinly.
   * if the result is NULL, then the
   * point is inside of the bounds.
   */
  check = 0;
  if(x<bounds->min.coor.x)check |= OUTSIDE_LEFT;
  if(x>bounds->max.coor.x)check |= OUTSIDE_RIGHT;
  if(y<bounds->min.coor.y)check |= OUTSIDE_TOP;
  if(y>bounds->max.coor.y)check |= OUTSIDE_BOTTOM;
  
  return check;
}

ulong cutline( struct rectangle *bounds, union point in, union point out )
{
  union point mid;
  ulong prev;
  
  /*
   * Perform a binary
   * search until the inside and
   * outside points are adjacent.
   * Since we're dealing with integers
   * this will happen when the sub-
   * division no longer 
   * leads to any change.
   */
  
  /*
   * Calculate the midpoint.
   */
  mid.coor.x = (in.coor.x+out.coor.x)/2;
  mid.coor.y = (in.coor.y+out.coor.y)/2;
  do {
    /*
     * If the midpoint is outside, then
     * replace out. Otherwise, replace
     * in.
     */
    if(checkbounds(bounds,mid.coor.x,mid.coor.y))out.xy=mid.xy;
    else in.xy = mid.xy;
    
    /*
     * Save the last midpoint and 
     * calculate the new one. If these
     * are the same, then
     * exit the loop.
     */
    prev = mid.xy;
    mid.coor.x = (in.coor.x+out.coor.x)/2;
    mid.coor.y = (in.coor.y+out.coor.y)/2;
  }while(mid.xy!=prev);
  
  /*
   * The point inside is the bounds
   * is the one we're interested in.
   * Note: we can't just go until the
   * inside point hits the boundary, 
   * because if the line is nearly 
   * parallel to the boundary, then
   * there will be many such points
   * that lie along it.
   */
  return(in.xy);
}

boolean clipvertical( struct rectangle *bounds, struct line *l )
/* performs clipping fo special case of a vertical line.  Note:
   p1 must be above p2. */
{
  /*
   * Check if the line is to the left or
   * right of the bounds.
   */
  if(l->p1.coor.x<bounds->min.coor.x)return False;
  if(l->p1.coor.x>bounds->max.coor.x)return False;
  
  /*
   * The order of the points must be
   * maintained for polygon clipping,
   * so here we branch.
   */
  if(l->p1.coor.y<l->p2.coor.y)
    {
      /*
       * Check one last time if the line
       * is outside.
       */
      if(l->p1.coor.y>bounds->max.coor.y)return False;
      if(l->p2.coor.y<bounds->min.coor.y)return False; 
      
      /*
       * Clip the line.
       */
      l->p1.coor.y = greater(l->p1.coor.y,bounds->min.coor.y);
      l->p2.coor.y = lesser(l->p2.coor.y,bounds->max.coor.y);
    }
  else
    {
      /*
       * Check one last time if the line
       * is outside.
       */
      if(l->p2.coor.y>bounds->max.coor.y)return False;
      if(l->p1.coor.y<bounds->min.coor.y)return False; 
      
      /*
       * Clip the line.
       */
      l->p2.coor.y = greater(l->p2.coor.y,bounds->min.coor.y);
      l->p1.coor.y = lesser(l->p1.coor.y,bounds->max.coor.y);
    }
  
  return True;
}

boolean cliphorizontal( struct rectangle *bounds, struct line *l )
/* performs clipping for special case of a horizontal line.  Note:
   p1 must be left of p2. */
{
  /*
   * Check if the line is above 
   * or below the bounds.
   */
  if(l->p1.coor.y<bounds->min.coor.y)return False;
  if(l->p1.coor.y>bounds->max.coor.y)return False;

  /*
   * The order of the points must be
   * maintained for polygon clipping,
   * so here we branch.
   */
  if(l->p1.coor.x<l->p2.coor.x)
    {
      /*
       * Check one last time if the line
       * is outside.
       */
      if(l->p1.coor.x>bounds->max.coor.x)return False;
      if(l->p2.coor.x<bounds->min.coor.x)return False; 

      /*
       * Clip the line.
       */
      l->p1.coor.x = greater(l->p1.coor.x,bounds->min.coor.x);
      l->p2.coor.x = lesser(l->p2.coor.x,bounds->max.coor.x);
    }
  else
    {
      /*
       * Check one last time if the line
       * is outside.
       */
      if(l->p2.coor.x>bounds->max.coor.x)return False;
      if(l->p1.coor.x<bounds->min.coor.x)return False; 
      
      /*
       * Clip the line.
       */
      l->p2.coor.x = greater(l->p2.coor.x,bounds->min.coor.x);
      l->p1.coor.x = lesser(l->p1.coor.x,bounds->max.coor.x);
    }
  
  return True;
}

boolean clipline( struct rectangle *bounds, struct line *l )
{
  ulong check1,check2;
  struct line seg1,seg2;
  
  /*
   * Use clipvertical() and cliphorizontal()
   * if at all possible.
   */
  if(l->p1.coor.x==l->p2.coor.x)return clipvertical(bounds,l);
  if(l->p1.coor.y==l->p2.coor.y)return cliphorizontal(bounds,l);
  
  /*
   * Get the flags for
   * the endpoints.
   */
  check1 = checkbounds(bounds,l->p1.coor.x,l->p1.coor.y);
  check2 = checkbounds(bounds,l->p2.coor.x,l->p2.coor.y);
  
  /*
   * If they are both inside the
   * bounds, then we don't need
   * to clip at all.
   */
  if(!(check1||check2))return True;
  
  
  /* 
   * If they both lie on the same
   * side out of bounds, then we
   * can reject the whole line
   * at once.
   */
  if(check1&check2)return False;
  
  /*
   * If we get here, then we
   * need to do more checking on
   * the line.
   */
  
  
  /*
   * If the points are both outside of
   * the bounding box, then we need to
   * split the line in half and check
   * both new segments.
   */
  if(check1&&check2)
    {
      seg1.p1.xy = l->p1.xy;
      seg1.p2.coor.x = seg2.p1.coor.x = (l->p1.coor.x+l->p2.coor.x)/2;
      seg1.p2.coor.y = seg2.p1.coor.y = (l->p1.coor.y+l->p2.coor.y)/2;
      seg2.p2.xy = l->p2.xy;
      
      /*
       * Check each individually and
       * put the line back together when
       * we're done. We run clipline()
       * recursively subdividing on the
       * stack until a result is
       * obtained.
       */
      if(clipline(bounds,&seg1))
	{
	  if(clipline(bounds,&seg2))
	    {
	      l->p1.xy = seg1.p1.xy;
	      l->p2.xy = seg2.p2.xy;
	    }
	  else *l = seg1;
	  
	  return True;
	}
      else
	{
	  if(clipline(bounds,&seg2))
	    {
	      *l = seg2;
	      return True;
	    }
	}
      /*
       * If we've reached here, then both
       * of the segments were outside of 
       * the bounds, so return FALSE.
       */
    }
  else
    {
      /*
       * If one of the points is inside and
       * the other is outside, then use
       * cutline() to find the portion of
       * the line inside.
       * Replace the point on the outside with
       * the result.
       */
      if(check1)l->p1.xy = cutline(bounds,l->p2,l->p1);
      else l->p2.xy = cutline(bounds,l->p1,l->p2);
      return True;
    }
  return False;
}


/*
 * Compared to line clipping, reducing a rectangle
 * is a piece of cake. There's only one function.
 * Note: the pointer r3 does not have to be 
 * different from r1 and r2.
 */

boolean cliprectangle( struct rectangle *r1, struct rectangle *r2, struct rectangle *r3 )
{
  /*
   * Check if there is no
   * overlap.
   */
  if(r1->min.coor.x>r2->max.coor.x ||
     r1->max.coor.x<r2->min.coor.x ||
     r1->min.coor.y>r2->max.coor.y ||
     r1->max.coor.y<r2->min.coor.y)return False;
  
  /*
   * There is overlap, so generate
   * the rectangle.
   */
  r3->min.coor.x = greater(r1->min.coor.x,r2->min.coor.x);
  r3->min.coor.y = greater(r1->min.coor.y,r2->min.coor.y);
  r3->max.coor.x = lesser(r1->max.coor.x,r2->max.coor.x);
  r3->max.coor.y = lesser(r1->max.coor.y,r2->max.coor.y);
  
  return True;
}


/*
 * Polygon clipping.
 *
 *  This is an implementaino of the Hodge-Sutherland
 * clipping algorithm.  Again, this may be found in
 * any introductor graphics text. This algorithm uses
 * the insight that clipping to a rectangle is difficult,
 * because of the corners, but clipping to a half-plane
 * is a snap.
 *  So, we clip to a half-plane four times and keep
 * the result. NOTE: I've made one addition. Because
 * polygon clipping can result in more than one polygon
 * I actually clip to the bounds plus one pixel so that
 * there is still one polygon but the different parts
 * are attached by lines around the border. When I 
 * blit into the output, I don't include this extra
 * portion.
 */


int cliphalfpolygon( struct rectangle *bounds, union point *outp, union point *inp, int count )
/* Clip a polygon to bounds. It should only clip on one side. */
{
  BOOL INSIDE;
  int i,j;
  union point p0;
  struct line line;
  
  /* 
   * This function clips the polygon to 
   * the rectangle, but to properly
   * implement Hodge-Sutherland, we
   * make sure that only one side will
   * actually be crossed by the polygon.
   */


  /*
   * Start with the last point and
   * set the boolean true if the
   * point is inside the rectangle.
   */
  j=0;
  p0 = inp[count-1];
  if(checkbounds(bounds,p0.coor.x,p0.coor.y))INSIDE = FALSE;
  else INSIDE = TRUE;

  /*
   * Loop through each
   * point.
   */
  for(i=0;i<count;i++)
    {
      /*
       * Generate the line from
       * the last point to the current
       * one.
       */
      line.p1 = p0;
      line.p2 = inp[i];
      
      if(INSIDE)
	{
	  /*
	   * If the last point was inside,
	   * then when we clip the line,
	   * p2 will be inside also.
	   * If this point changes, then
	   * the segment has gone out of
	   * bounds.
	   */
	  outp[j++] = p0;

	  clipline(bounds,&line);
	  if(line.p2.xy != inp[i].xy)
	    {
	      INSIDE = FALSE;
	      outp[j++] = line.p2;
	    }
	}
      else
	{
	  /*
	   * If the first point is 
	   * out of bounds, then the
	   * second is only inside if
	   * clipline() returns TRUE.
	   * If the second point is
	   * changed, then we're still
	   * outside.
	   */
	  if(clipline(bounds,&line))
	    {
	      outp[j++] = line.p1;
	      if(line.p2.xy==inp[i].xy)INSIDE=TRUE;
	      else outp[j++] = line.p2;
	    }
	}
      /*
       * The current point now becomes
       * the previous point.
       */
      p0 = inp[i];
    }
  return j;
}

/*
 * Description of the clippolygon() arguments.
 *  bounds -- This must be the bounding box of the
 *            polygon. It is changed as the polygon
 *            is clipped.
 *  box    -- This is the rectangle to which the
 *            polygon is clipped. This rectangle is
 *            changed to match the area of the polygon
 *            that is to remain visible. This is
 *            important since as I noted, part of
 *            the polygon along the boundary might
 *            not be part of the clipped portion.
 *  outp   -- The array into which the polygon is
 *            is to be placed.
 *  inp    -- The array into which the polygon is 
 *            coming from. These can be the same,
 *            but be sure to have plenty of space.
 */

int clippolygon( struct rectangle *bounds, struct rectangle *box, union point *outp, union point *inp, int count )
{
  int i,actual;
  int clipped = FALSE;

  /*
   * Clip the polygon to the
   * left.
   */
  if(bounds->min.coor.x<(box->min.coor.x-1))
    {
      /*
       * Do a check for a trivial rejection.
       */
      if(bounds->max.coor.x<box->min.coor.x)return 0;
      
      /*
       * Set the bounds to just one pixel left
       * of the clipping box. This is as I said
       * to deal with a polygon that becomes
       * more than one.
       */
      bounds->min.coor.x = box->min.coor.x-1;
      
      /*
       * Clip the polygon to the
       * half-plane.
       */
      if(!(actual=cliphalfpolygon(bounds,(outp==inp?outp+count:outp),inp,count)))return FALSE;
      
      /*
       * If the output is the same
       * as the input, then copy it
       * over. Note that during clipping, I
       * placed temporary behind the input,
       * so as I said, allocate plenty of
       * space.
       */
      if(outp==inp)
	for(i=0;i<actual;i++)outp[i] = outp[i+count];
      count = actual;
      inp = outp;

      clipped = TRUE;
    }
  
  /*
   * Now repeat what I just did three
   * more times for the other sides.
   */
  

  
  if(bounds->min.coor.y<(box->min.coor.y-1))
    {
      if(bounds->max.coor.y<box->min.coor.y)return 0;
      bounds->min.coor.y = box->min.coor.y-1;
      if(!(actual=cliphalfpolygon(bounds,(outp==inp?outp+count:outp),inp,count)))return 0;
      if(outp==inp)
	for(i=0;i<actual;i++)outp[i] = outp[i+count];
      count = actual;
      inp = outp;
      clipped = TRUE;
    }
  
  if(bounds->max.coor.x>(box->max.coor.x+1))
    {
      if(bounds->min.coor.x>box->max.coor.x)return 0;
      bounds->max.coor.x = box->max.coor.x+1;
      if(!(actual=cliphalfpolygon(bounds,(outp==inp?outp+count:outp),inp,count)))return 0;
      if(outp==inp)
	for(i=0;i<actual;i++)outp[i] = outp[i+count];
      count = actual;
      inp = outp;
      clipped = TRUE;
    }
  
  if(bounds->max.coor.y>(box->max.coor.y+1))
    {
      if(bounds->min.coor.y>box->max.coor.y)return 0;
      bounds->max.coor.y = box->max.coor.y+1;
      if(!(actual=cliphalfpolygon(bounds,(outp==inp?outp+count:outp),inp,count)))return 0;
      if(outp==inp)
	for(i=0;i<actual;i++)outp[i] = outp[i+count];
      count = actual;
      inp = outp;
      clipped = TRUE;
    }
  
  /*
   * Now we can update
   * the bounds just in case they
   * were changed.
   */

  if(clipped)
    {
      bounds->min.xy = bounds->max.xy = outp[0].xy;
      for(i=1;i<count;i++)
	{
	  bounds->min.coor.x = lesser(bounds->min.coor.x,outp[i].coor.x);
	  bounds->min.coor.y = lesser(bounds->min.coor.y,outp[i].coor.y);
	  bounds->max.coor.x = greater(bounds->max.coor.x,outp[i].coor.x);
	  bounds->max.coor.y = greater(bounds->max.coor.y,outp[i].coor.y);
	}
      box->min.coor.x = greater(box->min.coor.x,bounds->min.coor.x);
      box->min.coor.y = greater(box->min.coor.y,bounds->min.coor.y);
      box->max.coor.x =  lesser(box->max.coor.x,bounds->max.coor.x);
      box->max.coor.y =  lesser(box->max.coor.y,bounds->max.coor.y);
    }
  else
    {
      for(i=0;i<count;i++)outp[i]=inp[i];
      *box = *bounds;
    }

  return count;
}


/* The following are the cliplist functions. */

/*
 * newcliplist()     -- Create a brand new cliplist. It initially starts
 *                      out empty.
 *
 * disposecliplist() -- Drop the usecount of the cliplist. If the value
 *                      reaches zero, then noone else is using the 
 *                      cliplist, so it may be returned to the free resource
 *                      pool.
 *
 * usecliplist()     -- Increases the usecount of a cliplist. Use this
 *                      when you want to share a previously created cliplist.
 *
 * erasecliplist()   -- Clear all the nodes from the cliplist.
 *
 * updatecliplist()  -- Update a layers cliplist. Travels backwards through
 *                      the layer tree to find all the buffers.
 *
 * pushcliplist()    -- This function creates a new cliplist with the
 *                      cliprects limited to a region than is passed. This
 *                      region is typically the damagelist. It keeps the
 *                      old cliplist in the 'push' field for popcliplist().
 *                      A cliplist can only be pushed once.
 *
 * popcliplist()     -- This function returns any pushed cliplist and
 *                      disposes of the current one. It returns the current
 *                      cliplist if it has not been pushed.
 */

struct cliplist *newcliplist( void )
{
  struct cliplist *clip;

  /*
   * Allocate a new cliplist object and
   * initialize the fields.
   */
  if(clip=alloccliplist())
    {
      clip->list     = NULL;
      clip->usecount = 1;
      clip->push     = NULL;
    }
  return clip;
}

void disposecliplist( struct cliplist *clip )
{
  /*
   * If the use count reaches
   * zero, then empty the list
   * free the object.
   */
  if(!(--clip->usecount))
    {
      erasecliplist(clip);
      freecliplist(clip);
    }
  return;
}

struct cliplist *usecliplist( struct cliplist *list )
{
  /*
   * Increment the usecount
   * so the cliplist may
   * shared.
   */
  list->usecount++;
  return(list);
}

void erasecliplist( struct cliplist *clip )
{
  struct cliprect *crectp,*next;

  /*
   * Dump all the nodes in the
   * cliplist.
   */
  if(crectp=clip->list)
    {
      do
	{
	  next = crectp->next;
	  freecliprect(crectp);
	} while(crectp=next);
      clip->list = NULL;
    }

  return;
}

void updatecliplist( struct layer *layer )
{
  struct cliprect *crectp,*free,*first;
  struct rrectangle *rrectp;
  struct region *region;
  struct layer *index;
  union point origin;
  BitMapPtr map;
  struct layer *i2;

  /* This is new.  The cliplist bounds. */
  /* I introduced this field for clipping polygons to */
  /* the cliplist. */
  layer->clip->bounds = layer->region->bounds;

  /*
   * Initialize some important variables.
   *  crectp -- The latest node added to the list.
   *  first  -- The first node for the current bitmap. Initially
   *            it is NULL, since we don't have a bitmap.
   *  free   -- Recycle the previous nodes in the cliplist.
   *  Then clear the list.
   */
  first = crectp = NULL;
  free = layer->clip->list;
  layer->clip->list = NULL;

  /*
   * We'll be modifying the region, so use
   * it now. Then go through all of the 
   * children. If a clipped child is found
   * then remove its bounds from the region.
   * A parent cannot draw into it s clipped 
   * child.
   */
  region = useregion(layer->region);
  for(index=layer->children.head;index->next;index=index->next)
    region = clip(region,index);

  if(region->rectangles)
    {
      /*
       * Find the first layer with a buffer
       * up the tree. Including this layer.
       */
      for(index=layer;index->parent&&isSIMPLE(index);index=index->parent);

      /*
       * If the layer is a smart refresh or
       * super bitmap layer, then enter this
       * loop. It will continue until the
       * root layer is reached.
       */
      while(index->parent)
	{
	  /*
	   * Get the bitmap and its origin in
	   * root coordinates. This point will
	   * be put into crectp->origin, so that
	   * operations can be translated into
	   * the bounds of the bitmap.
	   */
	  if(isSUPER(index))
	    { 
	      origin.xy = index->refresh.super.bounds.min.xy;
	      map = index->refresh.super.bitmap;
	    }
	  else
	    {
	      origin.xy = index->bounds.min.xy;
	      map = index->refresh.smart.buffer;
	    }

	  /*
	   * Get the first bitmap in the
	   * rectangle of the region and create
	   * a cliprect for it. Link the new
	   * node after the current one.
	   */
	  rrectp=region->rectangles;
	  if(crectp)
	    {
	      if(crectp->next=free)free=free->next;
	      else crectp->next = alloccliprect();
	      first->next_bitmap = crectp = crectp->next;
	    }
	  else layer->clip->list = crectp=alloccliprect();

	  /*
	   * Fill in the node.
	   * Set the bitmap, the origin and
	   * the bounds. Then because this
	   * if the first cliprect for this
	   * bitmap, set first.
	   */
	  crectp->bitmap    = map;
	  crectp->origin.xy = origin.xy;
	  crectp->bounds    = rrectp->bounds;
	  first = crectp;

	  /*
	   * Now do the rest of the
	   * rectanlges in a similar way
	   * but keep next_bitmap=NULL.
	   * This field is only set for
	   * the first node of a bitmap.
	   */
	  while(rrectp=rrectp->next)
	    {
	      if(crectp->next=free)free=free->next;
	      else crectp->next = alloccliprect();
	      crectp = crectp->next;
	      crectp->bitmap      = map;
	      crectp->origin.xy   = origin.xy;
	      crectp->bounds      = rrectp->bounds;
	      crectp->next_bitmap = NULL;
	    }

	  /*
	   * Now update the region for the next
	   * buffer in the tree. First, if this has
	   * been a superbitmap layer, then we'll need
	   * to restrict ourselves to the simple bounds
	   * of the layer.
	   */
	  if(isSUPER(index))region = andrectregion(region,&layer->bounds);

	  /*
	   * Now go back through this level of
	   * the layer tree and remove any layers
	   * that overlap this layer. Only clipped
	   * ones count.
	   */
	  for(i2=index->prev;i2->prev;i2=i2->prev)
	    if(i2->visibility&&isCLIPPED(i2))
	      region = clearrectregion(region,&i2->bounds);

	  /*
	   * Finally, do a logical AND with the
	   * parent's region. This limits us to
	   * the exposed portion of our parent.
	   */
	  region = andregionregion(region,index->parent->region);

	  if(!region->rectangles)break;

	  /*
	   * Now search for the next buffer
	   */
	  for(index=index->parent;index->parent&&isSIMPLE(index);index=index->parent);

	  /*
	   * This loop continues until
	   * the root layer is reached.
	   */
	}

      if(rrectp = region->rectangles)
	{
	  /*
	   * We've reached the root layer.
	   * Repeat the actions inside the
	   * loop, but using the layer->bitmap
	   * as the bitmap. Remember, the
	   * origin of this bitmap is (0,0).
	   */
	  if(crectp)
	    { if(crectp->next=free)free=free->next;
	      else crectp->next=alloccliprect();
	      first->next_bitmap = crectp = crectp->next;
	    }
	  else crectp = layer->clip->list = alloccliprect();

	  first = crectp;
	  crectp->bitmap = index->bitmap;
	  crectp->origin.xy = 0;
	  crectp->bounds = rrectp->bounds;

	  while(rrectp=rrectp->next)
	    {
	      if(crectp->next=free)free=free->next;
	      else crectp->next=alloccliprect();
	      crectp = crectp->next;
	      crectp->bitmap      = index->bitmap;
	      crectp->origin.xy   = 0;
	      crectp->bounds      = rrectp->bounds;
	      crectp->next_bitmap = NULL;
	    }
	}

      /*
       * If a node was actually created, then 
       * set the link fields to NULL in order
       * to terminate the list.
       */
      if(crectp)
	{
	  first->next_bitmap = NULL;
	  crectp->next = NULL;
	}

    }

  /*
   * If there are any leftover nodes,
   * the release them.
   */
  while(free)
    {
      crectp = free->next;
      freecliprect(free);
      free = crectp;
    }

  /*
   * Don't forget to drop the region
   * that we created in the beginning.
   */
  disposeregion(region);


  return;
}

struct cliplist *pushcliplist( struct cliplist *clip, struct region *damage )
{
  struct cliplist *new;
  struct cliprect *crectp,*next,*last,*index,*first;
  struct rectangle bounds;
  struct rrectangle *rrectp;
  E_EBitMapPtr map;

  /*
   * A cliplist can only be
   * pushed once.
   */
  if(clip->push)return clip;

  if(new=newcliplist())
    {
      /*
       * Save the old cliplist as
       * pushed.
       */
      new->push = clip;


      /*
       * Set the bounds so that the first
       * values are ridiculous and will be
       * corrected almost immediately.
       */
      new->bounds.min = clip->bounds.max;
      new->bounds.max = clip->bounds.min;

      /*
       * Portions of the cliplist are
       * made and then linked into the 
       * rest. first, is the first node
       * for the curren bitmap. last is
       * the final node of the
       * list.
       */
      first = last = NULL;
      map   = NULL;

      /*
       * go throught the old
       * cliplist.
       */
      for(crectp=clip->list;crectp;crectp=crectp->next)
	{
	  next  = NULL;
	  index = NULL;

	  /*
	   * Now check the cliprect against
	   * every rectangle in the
	   * damage region.
	   */
	  for(rrectp=damage->rectangles;rrectp;rrectp=rrectp->next)
	    if(cliprectangle(&crectp->bounds,&rrectp->bounds,&bounds))
	      {
		/*
		 * Allocate a new cliprect.
		 * Then fill it with the new
		 * bounds and copy the origin
		 * and bitmap of the old one.
		 */
		if(index)
		  { index->next = alloccliprect();
		    index=index->next;
		  }
		else next=index=alloccliprect();

		index->bitmap      = crectp->bitmap;
		index->origin      = crectp->origin;
		index->bounds      = bounds;
		index->next_bitmap = NULL;

		/*
		 * For every node that we add, we
		 * must update the boundary.
		 */
		new->bounds.min.coor.x = lesser(new->bounds.min.coor.x,index->bounds.min.coor.x);
		new->bounds.min.coor.y = lesser(new->bounds.min.coor.y,index->bounds.min.coor.y);
		new->bounds.max.coor.x = greater(new->bounds.max.coor.x,index->bounds.max.coor.x);
		new->bounds.max.coor.y = greater(new->bounds.max.coor.y,index->bounds.max.coor.y);
	      }
	  /*
	   * Terminate the list
	   * just create.
	   */
	  if(index)index->next = NULL;

	  /*
	   * Now append this portion
	   * of the list into the
	   * whole list.
	   * next points to the beginning
	   * of the nodes just created.
	   */
	  if(next)
	    {
	      /*
	       * last indicates the
	       * node at the end
	       * of the list.
	       */
	      if(last)
		{ 
		  last->next = next;

		  /*
		   * Are we dealing with
		   * a different bitmap than
		   * last time. If so, the 
		   * set the next_bitmap field
		   * of 'first'.
		   */
		  if(map!=crectp->bitmap)
		    {
		      first->next_bitmap = next;
		      first              = next;
		      map                = crectp->bitmap;
		    }
		}
	      else 
		{
		  /*
		   * This is apprently the
		   * first node of the
		   * new cliplist. So
		   * link it as such.
		   */
		  new->list = first = next;
		  map       = crectp->bitmap;
		}
	      /*
	       * Update last to point
	       * to the final node
	       * in the list.
	       */
	      last = index;
	    }
	}
    }
  return new;
}

struct cliplist *popcliplist( struct cliplist *clip )
{
  struct cliplist *old;

  /*
   * This part is much easier.
   * First we restore the old
   * pointer. Then we dispose
   * of the cliplist.
   */
  if(old=clip->push)
    disposecliplist(clip);
  else old = clip;

  return old;
}

/* clip.c */

	    
  
