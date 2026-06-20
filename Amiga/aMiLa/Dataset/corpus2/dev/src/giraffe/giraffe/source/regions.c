/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: regions.c                               */
/*    |< |                                                    */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

#include "common.h"


/*
 * RRectangle list manipulation functions.
 *
 * allocrrectangle() -- allocate memory for one rrectangle
 *                      node.
 * freerrectangles() -- Free the memory for a list of rrectangle
 *                      nodes.
 * concatrrectangles() -- Combines two lists of rrectangle nodes.
 * copyrectangle()  -- Creates a new rrectangle node and fills
 *                     its bounds with a passed rectangle.
 * copyrrectangles() -- Copies an entire list of rrectangle nodes.
 */

struct rrectangle *allocrrectangle()
/* allocate a single RRectangle node. */
{
  struct rrectangle *rrectp;

  /*
   * a region is 12bytes long. (using
   * current implementation on Amiga)
   * So use quick allocation.
   */
  rrectp=(struct rrectangle *)alloc12();
  rrectp->next=Null;
  return(rrectp);
}

void freerrectangles( struct rrectangle *list )
/* free a linked list of RRectangles. */
{
  struct rrectangle *next;

  /*
   * Run through the whole list
   * freeing each node individually.
   */
  while(list)
    {
      next = list->next;

      free12((void *)list);
      list=next;
    }
  return;
}

struct rrectangle *concatrrectangles( struct rrectangle *list1, struct rrectangle *list2 )
/* Combine two lists of RRectangle nodes. */
{
  struct rrectangle *index;
  
  if(list1&&list2)
    {
      for(index=list1;index->next;index=index->next);
      index->next=list2;
    }
  
  return(list1?list1:list2);
}

struct rrectangle *copyrectangle( struct rectangle *rectp )
/* create a RRectangle node with bounds of rectp. */
{
  struct rrectangle *copy;

  if(copy=(struct rrectangle *)allocrrectangle())
    copy->bounds=*rectp;
  return copy;
}

struct rrectangle *copyrrectangles( struct rrectangle *list )
/* copy a list of RRectangles. */
{
  struct rrectangle *copy,*index;

  if(list)
    {
      if(copy=index=allocrrectangle())
	{
	  copy->bounds=list->bounds;

	  while(list=list->next)
	    {
	      if(index->next=allocrrectangle())
		{
		  index = index->next;
		  index->bounds = list->bounds;
		}
	    }
	}
    }
  else copy = NULL;

  return copy;
}



/*
 * regions functions. 
 *
 * newregion()   -- Creates a new regions. Sets the bounds to
 *                  a rectangle if passed. Otherwise just pass
 *                  NULL for an empty region.
 * disposeregion() -- Decrements the region usecount. When this
 *                    value reaches zero, the region is returned
 *                    to the free resource pool.
 * useregion()  -- (This is #define'd in common.h) This macro
 *                 increments the region's usecount. It is used
 *                 by the layers to share a region with another
 *                 layer.
 * copyregion() -- Makes an exact copy of a region. Should just
 *                 call useregion() since it does about the same
 *                 thing. This function is used internally by
 *                 moveregion().
 * concatregions() -- Combines two regions into one. Both of the 
 *                    regions passed have their usecount dropped
 *                    by one.
 * updateregion()  -- Updates the region's bounds to fit to all
 *                    the rrectangles in its list.
 * clearregion()  -- Returns a NULL region. It eats the one that
 *                   you pass. This could be turned  into a macro
 *                   very easily.
 */


struct region *newregion( struct rectangle *rectp )
/* allocate a new region structure. */
{
  struct region *region;

  if(region=allocregionobject())
    {
      region->usecount=1;
      if(rectp)
	{
	  region->bounds=*rectp;
	  region->rectangles=copyrectangle(rectp);
	}
      else region->rectangles=Null;
    }
  return region;
}

void disposeregion( struct region *region )
/* destroy a region structure. */
{
  if(!(--region->usecount))
    {
      if(region->rectangles)freerrectangles(region->rectangles);
      freeobject(region);
    }
  return;
}

struct region *copyregion( struct region *region )
/* create a copy of a region. */
{
  struct region *copy;

  if(copy=newregion(Null))
    { copy->bounds=region->bounds;
      copy->rectangles=copyrrectangles(region->rectangles);
    }
  return(copy);
}

struct region *concatregions( struct region *region1, struct region *region2 )
     /* combine two regions into one. */
{
  struct region *new;
  
  if(region1->rectangles&&region2->rectangles)
    {
      if(new=copyregion(region1))
	{
	  new->rectangles=concatrrectangles(new->rectangles,copyrrectangles(region2->rectangles));
	  
	  /* update region1 */
	  new->bounds.min.coor.x = lesser(region1->bounds.min.coor.x,region2->bounds.min.coor.x);
	  new->bounds.min.coor.y = lesser(region1->bounds.min.coor.y,region2->bounds.min.coor.y);
	  new->bounds.max.coor.x = greater(region1->bounds.max.coor.x,region2->bounds.max.coor.x);
	  new->bounds.max.coor.y = greater(region1->bounds.max.coor.y,region2->bounds.max.coor.y);
	}
    }
  else
    {
      if(region2->rectangles)new=useregion(region2);
      else new=useregion(region1);
    }
  disposeregion(region1);
  disposeregion(region2);
  
  return(new);
}

void updateregion( struct region *region )
/* update the bounds of a region. */
{
  struct rrectangle *index;

  index = region->rectangles;
  if(index)
    {
      region->bounds=index->bounds;

      while(index=index->next)
	{
	  region->bounds.min.coor.x=lesser(region->bounds.min.coor.x,index->bounds.min.coor.x);
	  region->bounds.min.coor.y=lesser(region->bounds.min.coor.y,index->bounds.min.coor.y);
	  region->bounds.max.coor.x=greater(region->bounds.max.coor.x,index->bounds.max.coor.x);
	  region->bounds.max.coor.y=greater(region->bounds.max.coor.y,index->bounds.max.coor.y);
	}
    }
  return;
}

int checkregion( struct region *region )
/* mainly for debugging. Checks if region's bounds are correct. */
{
  struct rrectangle *rrectp;

  for(rrectp=region->rectangles;rrectp;rrectp=rrectp->next)
    {
      if(rrectp->bounds.min.coor.x<region->bounds.min.coor.x)
	return FALSE;

      if(rrectp->bounds.min.coor.y<region->bounds.min.coor.y)
	return FALSE;

      if(rrectp->bounds.max.coor.x>region->bounds.max.coor.x)
	return FALSE;

      if(rrectp->bounds.max.coor.y>region->bounds.max.coor.y)
	return FALSE;
    }
  return TRUE;
}

struct region *clearregion( struct region *region )
/* clear all RRectangles from a region. */
{
  disposeregion(region);
  return(newregion(NULL));
}


/*
 * region and rectangle combinational functions.
 *
 *  andrectrect()  -- Creates a rrectangle that is the intersection
 *                    of two rectangles. Returns NULL if there
 *                    is no overlap.
 *  andrectregion() -- Returns the intersection of a region with a
 *                     rectangle. This function eats the region.
 *  andregionregion() -- Returns the intersection of two regions. This
 *                       function only eats the first region passed.
 *                       The usecount of the other remains untouched.
 *  clearrectrect() -- Returns a list of rrectangles that defined the
 *                     area of one rectangle that is outside the bounds
 *                     of another.
 *  clearrectregion() -- Returns a region with the bounds of the rectangle
 *                       removed. The region passed is eaten.
 *  clearregionregion() -- Returns only the portions of the region that are
 *                         not overlapping the second. The first region is
 *                         disposed of.
 *  orrectregion()  -- Returns a region with the rectangle included. The region
 *                     is disposed.
 *   orregionregion()  -- Returns the union on two regions. Only the first region
 *                        is disposed.
 *  xorrectregion()  -- Returns the XOR of the rectangle and region. The region
 *                      is disposed.
 *  xorregionregion() -- Returns a new region which is the XOR of two other
 *                       regions.
 */

struct rrectangle *andrectrect( struct rectangle *rect1, struct rectangle *rect2)
/* create the intersection of two rectangles. */
{
  struct rrectangle *intersection;

  if(rect1->min.coor.x<=rect2->max.coor.x)
    { if(rect1->min.coor.y<=rect2->max.coor.y)
	{ if(rect1->max.coor.x>=rect2->min.coor.x)
	    { if(rect1->max.coor.y>=rect2->min.coor.y)
		{ intersection=allocrrectangle();
		  intersection->bounds.min.coor.x=greater(rect1->min.coor.x,rect2->min.coor.x);
		  intersection->bounds.min.coor.y=greater(rect1->min.coor.y,rect2->min.coor.y);
		  intersection->bounds.max.coor.x=lesser(rect1->max.coor.x,rect2->max.coor.x);
		  intersection->bounds.max.coor.y=lesser(rect1->max.coor.y,rect2->max.coor.y);
		  return(intersection);
		}
	    }
	}
    }
  return(Null);
}

#define checkoverlap(r1,r2) (!((r1).max.coor.x<(r2).min.coor.x || \
			      (r1).max.coor.y<(r2).min.coor.y || \
                              (r1).min.coor.x>(r2).max.coor.x || \
                              (r1).min.coor.y>(r2).max.coor.y))

struct region *andrectregion( struct region *region, struct rectangle *rectp )
/* create the intersection of a region and a rectangle. */
{
  struct rrectangle *intersection;
  struct rrectangle *index,*list;
  struct region *new;

  list=index=region->rectangles;
  new=newregion(Null);

  if(list&&checkoverlap(region->bounds,*rectp))
    {
      for(index=list;index;index=index->next)
	if(intersection=andrectrect(rectp,&index->bounds))break;

      if(index)
	{
	  new->bounds = intersection->bounds;
	  new->rectangles = intersection;

	  while(index=index->next)
	    {
	      if(intersection->next=andrectrect(rectp,&index->bounds))
		{ 
		  intersection = intersection->next;
		  new->bounds.min.coor.x = lesser(new->bounds.min.coor.x,intersection->bounds.min.coor.x);
		  new->bounds.min.coor.y = lesser(new->bounds.min.coor.y,intersection->bounds.min.coor.y);
		  new->bounds.max.coor.x = greater(new->bounds.max.coor.x,intersection->bounds.max.coor.x);
		  new->bounds.max.coor.y = greater(new->bounds.max.coor.y,intersection->bounds.max.coor.y);
		}
	    }
	}
    }
  disposeregion(region);

  return(new);
}

struct region *andregionregion( struct region *region1, struct region *region2 )
/* create the intersection of two regions. */
{
  struct rrectangle *index;
  struct region *result;

  /* trivial result */
  if(!region1->rectangles)return(region1);

  /*
   * Check that there are rectangles in region2
   * and that the general region bounds overlap
   * before going on to more detailed tests.
   */
  if((index=region2->rectangles)&&checkoverlap(region2->bounds,region1->bounds))
    {
      /*
       * Go through the list and
       * use andrectregion(). Keep accumulating the
       * results. The bounds are updated by
       * concatregions().
       */
      result=andrectregion(useregion(region1),&index->bounds);
      for(index=index->next;index;index=index->next)
	result=concatregions(result,andrectregion(useregion(region1),&index->bounds));

      disposeregion(region1);
      return(result);
    }

  /*
   * In trivial case, there is
   * no overlap.
   */
  return(clearregion(region1));
}

struct rrectangle *clearrectrect( struct rectangle *rect1, struct rectangle *rect2 )
/* returns a RRectangle list of rect1 NOT rect2 */
{
  struct rrectangle *rrectp,*new;
  struct rectangle overlap;

  rrectp=Null;

  if(cliprectangle(rect1,rect2,&overlap))
    {
      /* bottom */
      if(rect1->max.coor.y>overlap.max.coor.y)
	{
	  new=allocrrectangle();
	  new->bounds.min.coor.x = rect1->min.coor.x;
	  new->bounds.min.coor.y = overlap.max.coor.y+1;
	  new->bounds.max.coor.x = rect1->max.coor.x;
	  new->bounds.max.coor.y = rect1->max.coor.y;
	  rrectp = new;
	}
      /* left */
      if(rect1->min.coor.x<overlap.min.coor.x)
	{
	  new = allocrrectangle();
	  new->bounds.min.coor.x = rect1->min.coor.x;
	  new->bounds.min.coor.y = greater(rect1->min.coor.y,overlap.min.coor.y);
	  new->bounds.max.coor.x = overlap.min.coor.x-1;
	  new->bounds.max.coor.y = lesser(rect1->max.coor.y,overlap.max.coor.y);
	  if(rrectp)new->next = rrectp;
	  rrectp = new;
	}
      /* right */
      if(rect1->max.coor.x>overlap.max.coor.x)
	{
	  new = allocrrectangle();
	  new->bounds.min.coor.x = overlap.max.coor.x+1;
	  new->bounds.min.coor.y = greater(rect1->min.coor.y,overlap.min.coor.y);
	  new->bounds.max.coor.x = rect1->max.coor.x;
	  new->bounds.max.coor.y = lesser(rect1->max.coor.y,overlap.max.coor.y);
	  if(rrectp)new->next = rrectp;
	  rrectp = new;
	}
      /* top */
      if(rect1->min.coor.y<overlap.min.coor.y)
	{
	  new = allocrrectangle();
	  new->bounds.min.coor.x = rect1->min.coor.x;
	  new->bounds.min.coor.y = rect1->min.coor.y;
	  new->bounds.max.coor.x = rect1->max.coor.x;
	  new->bounds.max.coor.y = overlap.min.coor.y-1;
	  if(rrectp)new->next = rrectp;
	  rrectp = new;
	}
    }
  else rrectp = copyrectangle(rect1);
  
  return rrectp;
}

struct region *clearrectregion( struct region *region, struct rectangle *rectp )
{
  struct rrectangle *index;
  struct rrectangle *i2;
  struct region *new;

  /*
   * First check the trivial case.
   * If there is no overlap, then 
   * return the region unchanged.
   */
  if(region->rectangles && checkoverlap(region->bounds,*rectp))
    {
      /*
       * Generate a new
       * region and use clearrectrect()
       * to generate the result. Accumluate
       * the portions as you go along.
       */
      new = newregion(Null);
      if(index=region->rectangles)
	{
	  for(;index;index=index->next)
	    if(new->rectangles=clearrectrect(&index->bounds,rectp))break;

	  if(index)
	    {
	      i2=new->rectangles;
	      while(index=index->next)
		{
		  while(i2->next)i2=i2->next;
		  i2->next=clearrectrect(&index->bounds,rectp);
		}
	    }
	  /*
	   * Update the region's
	   * bounds.
	   */
	  updateregion(new);
	}
      /*
       * Dispose of the old
       * region.
       */
      disposeregion(region);
    }
  else new = region;

  return new;
}

struct region *clearregionregion( struct region *region1, struct region *region2 )
{
  struct rrectangle *index;
  struct region *new,*old;

  new = region1;
  if(region1->rectangles && region2->rectangles &&
     checkoverlap(region1->bounds,region2->bounds))
    {
      for(index=region2->rectangles;index;index=index->next)
	{ 
	  old = new;
	  new=clearrectregion(old,&index->bounds);
	}
    }
  return(new);
}

struct rrectangle *orrectrect( struct rectangle *rect1, struct rectangle *rect2 )
{
  struct rrectangle *copy;

  /*
   * First, clear one rectangle from
   * the other, then add a copy of
   * it to the resulting list.
   */
  copy       = copyrectangle(rect2);
  copy->next = clearrectrect(rect1,rect2);

  return copy;
}
	
struct region *orrectregion( struct region *region, struct rectangle *rect )
{
  struct rrectangle *rrectp;
  struct region *new;

  if(region->rectangles && checkoverlap(region->bounds,*rect))
    {
      new = clearrectregion(region,rect);

      if(rrectp=copyrectangle(rect))
	{
	  rrectp->next    = new->rectangles;
	  new->rectangles = rrectp;
	}
    }
  else
    {
      new=copyregion(region);
      rrectp = copyrectangle(rect);
      rrectp->next = new->rectangles;
      new->rectangles = rrectp;

      disposeregion(region);
    }

  new->bounds.min.coor.x = lesser(new->bounds.min.coor.x,rect->min.coor.x);
  new->bounds.min.coor.y = lesser(new->bounds.min.coor.y,rect->min.coor.y);
  new->bounds.max.coor.x = greater(new->bounds.max.coor.x,rect->max.coor.x);
  new->bounds.max.coor.y = greater(new->bounds.max.coor.y,rect->max.coor.y);

  return new;
}

struct region *orregionregion( struct region *region1, struct region *region2)
{
  struct region *new;

  /* trivial result */
  if(!region2->rectangles)return(region1);
  if(!region1->rectangles)
    {
      disposeregion(region1);
      return copyregion(region2); /* useregion(region2); */
    }

  if(checkoverlap(region1->bounds,region2->bounds))
    {
      new = clearregionregion(region1,region2);
      new->rectangles = concatrrectangles(new->rectangles,copyrrectangles(region2->rectangles));
      new->bounds.min.coor.x = lesser(region1->bounds.min.coor.x,region2->bounds.min.coor.x);
      new->bounds.min.coor.y = lesser(region1->bounds.min.coor.y,region2->bounds.min.coor.y);
      new->bounds.max.coor.x = greater(region1->bounds.max.coor.x,region2->bounds.max.coor.x);
      new->bounds.max.coor.y = greater(region1->bounds.max.coor.y,region2->bounds.max.coor.y);
    }
  else new = concatregions(region1,useregion(region2));

  return(new);
}

struct region *xorrectregion( struct region *region, struct rectangle *rect )
{
  struct region *intersection,*combo,*xor;

  intersection = andrectregion(useregion(region),rect);
  combo        = orrectregion(region,rect);
  if(intersection->rectangles)
    xor          = clearregionregion(combo,intersection);
  else xor = combo;

  disposeregion(intersection);

  return xor;
}

struct region *xorregionregion( struct region *region1, struct region *region2 )
{
  struct region *intersection,*combo,*xor;

  /* trivial result */
  if(!region2->rectangles)return(region1);

  intersection = andregionregion(useregion(region1),region2);
  combo        = orregionregion(region1,region2);

  if(intersection->rectangles)xor=clearregionregion(combo,intersection);
  else xor = combo;

  disposeregion(intersection);

  return(xor);
}

/*
 * miscelaneous region functions.
 *
 *  moveregion()   -- Returns a region that has been translated. It
 *                    automatically drops the region.
 *  comparerectangles()  -- Used by sortregion() as a testing for the
 *                          bubble sort.
 *  sortregion()  -- Sorts the rrectangle nodes of a region for
 *                   blitter operations in which the source and destination
 *                   are the same. Pass the directions that the blitting
 *                   takes place in order to determine the ordering.
 */



struct region *moveregion( struct region *region, int delx, int dely )
{
  struct rrectangle *rrectp;
  struct region *new;

  if(region->rectangles)
    {
      new = copyregion(region);
      for(rrectp=new->rectangles;rrectp;rrectp=rrectp->next)
	moverectangle(rrectp->bounds,delx,dely);
      moverectangle(new->bounds,delx,dely);
      disposeregion(region);
      return(new);
    }
  return(region);
}

BOOL comparerectangles( struct rectangle *r1, struct rectangle *r2, int dx, int dy )
{
  if(dx<0&&r1->max.coor.x<r2->min.coor.x)return(TRUE);
  if(dx>0&&r1->min.coor.x>r2->max.coor.x)return(TRUE);
  if(dy<0&&r1->max.coor.y<r2->min.coor.y)return(TRUE);
  if(dy>0&&r1->min.coor.y>r2->max.coor.y)return(TRUE);
  return(FALSE);
}

void sortregion( struct region *region, int dx, int dy )
{
  struct rrectangle *index;
  struct rrectangle *list,*rrectp,*prev;

  if(region->rectangles)
    {
      list=region->rectangles->next;
      region->rectangles->next=NULL;

      while(list)
	{
	  rrectp=list;
	  list=list->next;

	  prev=NULL;
	  for(index=region->rectangles;index;index=index->next)
	    {
	      if(comparerectangles(&rrectp->bounds,&index->bounds,dx,dy))break;
	      prev=index;
	    }
	  rrectp->next=index;
	  if(prev)prev->next=rrectp;
	  else region->rectangles=rrectp;
	}
    }
  return;
}


  

/* regions.c */
