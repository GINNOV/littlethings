/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: arrange.c -- layer layout management.   */
/*    |< |                                                    */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

#include <exec/types.h>

#include "layers.h"

void setweight( struct layer *layer, int hweight, int vweight )
{
  int pass;

  pass=0;
  if(layer->parent->flags&LAYER_ARRANGE_MASK)
    {
      if(hweight>layer->layout.groups.hweight)
	{ layer->layout.groups.hweight=hweight;
	  pass=1;
	}
      if(vweight>layer->layout.groups.vweight)
	{ layer->layout.groups.vweight=vweight;
	  pass=1;
	}
      if(pass)setweight(layer->parent,hweight,vweight);
    }
  return;
}

void invalidatebounds( struct layer *layer )
/* sets LAYER_SIZE_INVALID flag for all layers in tree */
{
  struct layer *index;

  layer->flags &= ~LAYER_BOUNDS_VALID;

  if(layer->visibility)
    { layer->visibility = clearregion(layer->visibility);
      layer->damagelist = clearregion(layer->damagelist);
    }

  for(index=layer->children.head;index->next;index=index->next)
    invalidatebounds(index);

  return;
}

void arrange_vertical( struct layer *layer )
/* arranges a vertical group. */
{
  int y;
  int net;
  int left_border,right_border;
  int h;
  ushort height;
  struct rectangle bounds;
  struct layer *index;


  left_border = right_border = 0;

  if(isSUPER(layer))bounds = layer->refresh.super.bounds;
  else bounds = layer->bounds;

  bounds.min.coor.x += layer->margins.left;
  bounds.min.coor.y += layer->margins.top;
  bounds.max.coor.x -= layer->margins.right;
  bounds.max.coor.y -= layer->margins.bottom;
  h = rectheight(bounds);

  net=0;
  for(index=layer->children.head;index->next;index=index->next)
    if(index->visibility)
      { /* get vertical */
	h -= index->spacing.top+index->spacing.bottom;

	/* a zero weight indicates a fixed dimension. */
	/* or and empty group. */
	if(!index->layout.groups.vweight)
	  { 
	    if((rectheight(index->bounds)<index->minheight) ||
	       (!(index->flags&LAYER_FIXED_HEIGHT)))
	      index->bounds.max.coor.y = index->bounds.min.coor.y + index->minheight-1;
	    h -= rectheight(index->bounds);
	  }
	else net+=index->layout.groups.vweight;

	/* do horizontal */
	if((index->flags&LAYER_FIXED_WIDTH) &&
	   (rectwidth(index->bounds)<index->minwidth))
	  index->bounds.max.coor.x = index->bounds.min.coor.x +
	                             index->minwidth-1;

	left_border=greater(left_border,index->spacing.left);
	right_border=greater(right_border,index->spacing.right);
      }
  
  /* now eliminate any layers at minimum size */
  /* or fixed height.                         */
  for(index=layer->children.head;index->next;index=index->next)
    if(index->visibility && index->layout.groups.vweight)
      {
	if((h*index->layout.groups.vweight)/net<index->minheight)
	  { index->flags|=LAYER_MINIMUM_HEIGHT;
	    index->bounds.max.coor.y = index->bounds.min.coor.y + index->minheight-1;
	    net -= index->layout.groups.vweight;
	    h   -= index->minheight;
	  }
	else index->flags &= ~LAYER_MINIMUM_HEIGHT;
      }

  /* Now after two passes, we can actually arrange the 
     layers into their final groupings. */

  y=bounds.min.coor.y;
  for(index=layer->children.head;index->next;index=index->next)
    if(index->visibility)
      { /* vertical portion */
	height = rectheight(index->bounds);

	index->bounds.min.coor.y = y+index->spacing.top;
	if(!index->layout.groups.vweight||index->flags&LAYER_MINIMUM_HEIGHT)
	  index->bounds.max.coor.y = index->bounds.min.coor.y+height-1;
	else index->bounds.max.coor.y=index->bounds.min.coor.y+
	                               (h*index->layout.groups.vweight)/net-1;

	y=index->bounds.max.coor.y + index->spacing.bottom+1;

	/* do horizontal portion.  */
	/* This can use some work. */
	index->bounds.min.coor.x = bounds.min.coor.x + left_border;
	index->bounds.max.coor.x = bounds.max.coor.x - right_border;

	index->flags |= LAYER_BOUNDS_VALID;

	signalresize(index,rectwidth(index->bounds),rectheight(index->bounds));
	nestarray();
	arrange(index,0,0);
	unnestarray();

	/*
	 * Check if smart refresh is
	 * no longer valid.
	 */
	if(isSMART(index))
	  {
	    index->flags |= LAYER_BUFFER_INVALID;
	    if(index->refresh.smart.buffer)
	      {
		g_FreeBitMap(index->refresh.smart.buffer);
		index->refresh.smart.buffer = NULL;
	      }
	  }
      }
  return;
}
  
void arrange_horizontal( struct layer *layer )
{
  int x;
  int net;
  int top_border,bottom_border;
  int w;
  ushort width;
  struct rectangle bounds;
  struct layer *index;

  top_border = bottom_border = 0;

  if(isSUPER(layer))bounds = layer->refresh.super.bounds;
  else bounds = layer->bounds;

  bounds.min.coor.x += layer->margins.left;
  bounds.min.coor.y += layer->margins.top;
  bounds.max.coor.x -= layer->margins.right;
  bounds.max.coor.y -= layer->margins.bottom;
  w=rectwidth(bounds);

  net=0;
  for(index=layer->children.head;index->next;index=index->next)
    if(index->visibility)
      { /* get horizontal */
	w -= (index->spacing.left+index->spacing.right);
	if(!index->layout.groups.hweight)
	  {
	    if((rectwidth(index->bounds)<index->minwidth) ||
	       (!(index->flags&LAYER_FIXED_WIDTH)))
	      index->bounds.max.coor.x = index->bounds.min.coor.x + index->minwidth-1;
	    w -= rectwidth(index->bounds);
	  }
	else net+=index->layout.groups.hweight;

	/* do vertical */
	if((index->flags&LAYER_FIXED_HEIGHT) &&
	   (rectheight(index->bounds)<index->minheight))
	  index->bounds.max.coor.y = index->bounds.min.coor.y +
	                             index->minheight -1;

	top_border=greater(top_border,index->spacing.top);
	bottom_border=greater(bottom_border,index->spacing.bottom);
      }

  /* now eliminate any layers at minimum size */
  for(index=layer->children.head;index->next;index=index->next)
    if(index->visibility && index->layout.groups.hweight)
      {
	if((w*index->layout.groups.hweight)/net<index->minwidth)
	  {
	    index->flags |= LAYER_MINIMUM_WIDTH;
	    index->bounds.max.coor.x = index->bounds.min.coor.x + index->minwidth-1;
	    net -= index->layout.groups.hweight;
	    w   -= index->minwidth;
	  }
	else index->flags &= ~LAYER_MINIMUM_WIDTH;
      }

  x=bounds.min.coor.x;
  for(index=layer->children.head;index->next;index=index->next)
    if(index->visibility)
      {
	/* vertical portion */
	width = rectwidth(index->bounds);

	index->bounds.min.coor.x = x+index->spacing.left;
	if((!index->layout.groups.hweight)||(index->flags&LAYER_MINIMUM_WIDTH))
	  index->bounds.max.coor.x = index->bounds.min.coor.x+width-1;
	else index->bounds.max.coor.x=index->bounds.min.coor.x+
	                               (w*index->layout.groups.hweight)/net-1;

	x=index->bounds.max.coor.x+index->spacing.right+1;

	/* do vertical portion. */
	index->bounds.min.coor.y = bounds.min.coor.y+(top_border+layer->margins.top);
	index->bounds.max.coor.y = bounds.max.coor.y-(bottom_border+layer->margins.bottom);

	index->flags |= LAYER_BOUNDS_VALID;

	signalresize(index,rectwidth(index->bounds),rectheight(index->bounds));
	nestarray();
	arrange(index,0,0);
	unnestarray();

	/*
	 * Check if smart refresh is
	 * no longer valid.
	 */
	if(isSMART(index))
	  {
	    index->flags |= LAYER_BUFFER_INVALID;
	    if(index->refresh.smart.buffer)
	      {
		g_FreeBitMap(index->refresh.smart.buffer);
		index->refresh.smart.buffer = NULL;
	      }
	  }
      }
  return;
}




#define TOLEFT   0
#define TOTOP    1
#define TORIGHT  2
#define TOBOTTOM 3

#define getleft(l)   gethash(l,TOLEFT)
#define gettop(l)    gethash(l,TOTOP)
#define getright(l)  gethash(l,TORIGHT)
#define getbottom(l) gethash(l,TOBOTTOM)

#define group(x) ((x)->layout.groups)
#define loop(y,x) for((x)=(y)->children.head;(x)->next;(x)=(x)->next)

struct layer *gethash( struct layer *layer, int dir )
{
  struct layer *index;
  ubyte  hash;

  switch(dir)
    {
    case TOLEFT:
      hash = layer->layout.neighbors.toleft;
      break;
    case TOTOP:
      hash = layer->layout.neighbors.totop;
      break;
    case TORIGHT:
      hash = layer->layout.neighbors.toright;
      break;
    case TOBOTTOM:
      hash = layer->layout.neighbors.tobottom;
      break;
    }

  while(hash)
    {
      loop(layer->parent,index)
	if(index->hash_id==hash)
	  { 
	    if(index->visibility)return(index);
	    else
	      switch(dir)
		{
		case TOLEFT:
		  hash = index->layout.neighbors.toleft;
		  break;
		case TOTOP:
		  hash = index->layout.neighbors.totop;
		  break;
		case TORIGHT:
		  hash = index->layout.neighbors.toright;
		  break;
		case TOBOTTOM:
		  hash = index->layout.neighbors.tobottom;
		  break;
		}
	  }
      /*
       * If the hash value was not found, then
       * we must return NULL and break.
       */
      if(!index->next)break;
    }
  return NULL;
}


void arrange_relative( struct layer *layer )
/* arranges layers according to neighboring constraints. */
{
  int dx,dy;
  struct layer *toleft,*totop,*tobottom,*toright;
  ushort width,height;
  struct rectangle bounds;

  if(!(layer->flags&LAYER_BOUNDS_VALID))
    { /* avoid any circular dependency */
      if(layer->flags&LAYER_SIZE_UPDATING)Alert(0x80000000);
      layer->flags |= LAYER_SIZE_UPDATING;

      /* Determin how much the layer has moved. */
      dx = -layer->bounds.min.coor.x;
      dy = -layer->bounds.max.coor.y;

      toleft = getleft(layer);
      totop  = gettop(layer);
      toright  = getright(layer);
      tobottom = getbottom(layer);

      bounds = (isSUPER(layer->parent)?layer->parent->refresh.super.bounds:
		layer->parent->bounds);

      width = rectwidth(layer->bounds);
      /* Place the right hand side. */
      if((!(layer->flags&LAYER_FIXED_WIDTH))||(layer->flags&LAYER_LOCK_RIGHT))
	{
	  if(toright)
	    {
	      arrange_relative(toright);
	      if(layer->flags&LAYER_MATCH_RIGHT)
		layer->bounds.max.coor.x = toright->bounds.max.coor.x;
	      else
		layer->bounds.max.coor.x = toright->bounds.min.coor.x-1
		                           -toright->spacing.left
					     -layer->spacing.right;
	    }
	  else layer->bounds.max.coor.x = bounds.max.coor.x
	                                   - layer->parent->margins.right
					     -layer->spacing.right;

	}

      if((!(layer->flags&LAYER_FIXED_WIDTH))||(!(layer->flags&LAYER_LOCK_RIGHT)))
	{
	  if(toleft)
	    {
	      arrange_relative(toleft);
	      if(layer->flags&LAYER_MATCH_LEFT)
		layer->bounds.min.coor.x = toleft->bounds.min.coor.x;
	      else 
		layer->bounds.min.coor.x = toleft->bounds.max.coor.x+1
		                            + toleft->spacing.right
					      + layer->spacing.left;
	    }
	  else layer->bounds.min.coor.x = bounds.min.coor.x
	                                   + layer->parent->margins.left
					     + layer->spacing.left;
	}

      /* Now set the otherside for a fixed width layer. */
      if(layer->flags&LAYER_FIXED_WIDTH)
	{
	  if(layer->flags&LAYER_LOCK_RIGHT)
	    layer->bounds.min.coor.x = layer->bounds.max.coor.x -width +1;
	  else
	    layer->bounds.max.coor.x = layer->bounds.min.coor.x + width-1;
	}

      height = rectheight(layer->bounds);
      /* Place the bottom */
      if((!(layer->flags&LAYER_FIXED_HEIGHT))||(layer->flags&LAYER_LOCK_BOTTOM))
	{
	  if(tobottom)
	    {
	      arrange_relative(tobottom);
	      if(layer->flags&LAYER_MATCH_BOTTOM)
		layer->bounds.max.coor.y = tobottom->bounds.max.coor.y;
	      else
		layer->bounds.max.coor.y = tobottom->bounds.min.coor.y-1
		                           -tobottom->spacing.top
					     -layer->spacing.bottom;
	    }
	  else layer->bounds.max.coor.y = bounds.max.coor.y
	                                   - layer->parent->margins.bottom
					     - layer->spacing.bottom;
	}

      if((!(layer->flags&LAYER_FIXED_HEIGHT))||(!(layer->flags&LAYER_LOCK_BOTTOM)))
	{
	  if(totop)
	    {
	      arrange_relative(totop);
	      if(layer->flags&LAYER_MATCH_TOP)
		layer->bounds.min.coor.y = totop->bounds.min.coor.y;
	      else 
		layer->bounds.min.coor.y = totop->bounds.max.coor.y+1
		                            + totop->spacing.bottom
					      + layer->spacing.top;
	    }
	  else layer->bounds.min.coor.y = bounds.min.coor.y
	                                   + layer->spacing.top
					     + layer->parent->margins.bottom;
	}

      /* Now set the otherside for a fixed width layer. */
      if(layer->flags&LAYER_FIXED_HEIGHT)
	{
	  if(layer->flags&LAYER_LOCK_BOTTOM)
	    layer->bounds.min.coor.y = layer->bounds.max.coor.y - height+1;
	  else
	    layer->bounds.max.coor.y = layer->bounds.min.coor.y + height-1;
	}

      /* validate the dimensions of the layer */
      layer->flags |= LAYER_BOUNDS_VALID;

      signalresize(layer,rectwidth(layer->bounds),rectheight(layer->bounds));
      dx += layer->bounds.min.coor.x;
      dy += layer->bounds.min.coor.y;
      nestarray();
      arrange(layer,dx,dy);
      unnestarray();

      layer->flags &= ~LAYER_SIZE_UPDATING;

      /*
       * Finally, if the layer is a super layer,
       * then check if the buffer is no longer valid.
       */
      if((width!=rectwidth(layer->bounds)) ||
	 (height!=rectheight(layer->bounds)))
	{
	  layer->flags |= LAYER_BUFFER_INVALID;
	  if(layer->refresh.smart.buffer)
	    {
	      g_FreeBitMap(layer->refresh.smart.buffer);
	      layer->refresh.smart.buffer = NULL;
	    }
	}
    }


  return;
}




void arrange( struct layer *layer, int dx, int dy )
{
  struct layer *index;

  switch(layer->flags&LAYER_ARRANGE_MASK)
    {
    case LAYER_ARRANGE_RELATIVE:
      for(index=layer->children.head;index->next;index=index->next)
	index->flags &= ~LAYER_BOUNDS_VALID;
      for(index=layer->children.head;index->next;index=index->next)
	arrange_relative(index);
      break;

    case LAYER_ARRANGE_VERTICAL:
      arrange_vertical(layer);
      break;

    case LAYER_ARRANGE_HORIZONTAL:
      arrange_horizontal(layer);
      break;

    default: /* No arrangement by parent. */
      if(dx||dy)
	for(index=layer->children.head;index->next;index=index->next)
	  {
	    movechild(index,dx,dy,FALSE);
	    arrange(index,0,0);
	  }
      break;
    }
  layer->flags |= LAYER_BOUNDS_VALID;
  
  return;
}



ulong calc_minsize( struct layer *layer )
{
  union  point size;
  struct layer *n;

  updateminsize(layer);

  if(!(layer->flags&LAYER_REFERENCE_HORZ))
    {
      /* first get width. */
      size.coor.x = layer->minwidth;

      /* go left */
      for(n = getleft(layer);n;n=getleft(n))
	{ 
	  if(n->visibility)
	    { updateminsize(n);
	      size.coor.x += (n->flags&LAYER_FIXED_WIDTH?rectwidth(n->bounds):n->minwidth);
	    }
	}
      
      /* go right */
      for(n = getright(layer);n;n=getright(n))
	{
	  if(n->visibility)
	    { updateminsize(n);
	      size.coor.x += (n->flags&LAYER_FIXED_WIDTH?rectwidth(n->bounds):n->minwidth);
	    }
	}
    }
  else size.coor.x = 0;

  if(!(layer->flags&LAYER_REFERENCE_VERT))
    {
      size.coor.y = layer->minheight;
      
      /* go up */
      for(n=gettop(layer);n;n=gettop(n))
	{ 
	  if(n->visibility)
	    { updateminsize(n);
	      size.coor.y += (n->flags&LAYER_FIXED_HEIGHT?rectheight(n->bounds):n->minheight);
	    }
	}
      
      /* go down */
      for(n=getbottom(layer);n;n=getbottom(n))
	{ if(n->visibility)
	    { updateminsize(n);
	      size.coor.y += (n->flags&LAYER_FIXED_HEIGHT?rectheight(n->bounds):n->minheight);
	    }
	}
    }      
  else size.coor.y = 0;
  
  return size.xy;
}

struct layer *updateminsize( struct layer *layer )
{
  struct layer *index;
  union point size;
  ulong ow,oh;

  if(!(layer->flags&LAYER_MIN_VALID))
    {
      ow=layer->minwidth;
      oh=layer->minheight;

      if((!isHOTSPOT(layer))&&(layer->children.head!=(struct layer *)&layer->children.tail))
	{
	  switch(LAYER_ARRANGE_TYPE(layer))
	    {
	    case LAYER_ARRANGE_HORIZONTAL:
	      layer->minwidth  = 0;
	      layer->minheight = 0;
	      for(index=layer->children.head;index->next;index=index->next)
		{
		  if(index->visibility)
		    {
		      updateminsize(index);
		      layer->minwidth += index->spacing.left +
		                         index->spacing.right +
				         (index->flags&LAYER_FIXED_WIDTH?rectwidth(index->bounds):index->minwidth);

		      layer->minheight = greater(layer->minheight,index->spacing.top+index->spacing.bottom+(index->flags&LAYER_FIXED_HEIGHT?rectheight(index->bounds):index->minheight));
		    }
		}
	      layer->minwidth += layer->margins.left+layer->margins.right;
	      layer->minheight += layer->margins.top+layer->margins.bottom;
	      break;

	    case LAYER_ARRANGE_VERTICAL:
	      layer->minwidth =  0;
	      layer->minheight = 0;
	      for(index=layer->children.head;index->next;index=index->next)
		{
		  if(index->visibility)
		    {
		      updateminsize(index);
		      layer->minheight += index->spacing.top + 
		                          index->spacing.bottom +
				          (index->flags&LAYER_FIXED_HEIGHT?rectheight(index->bounds):index->minheight);

		      layer->minwidth = greater(layer->minwidth,index->spacing.left+index->spacing.right+(index->flags&LAYER_FIXED_WIDTH?rectwidth(index->bounds):index->minwidth));

		    }
		}
	      layer->minwidth += layer->margins.left+layer->margins.right;
	      layer->minheight += layer->margins.top+layer->margins.bottom;
	      break;

	    case LAYER_ARRANGE_RELATIVE:
	      layer->minwidth  = 0;
	      layer->minheight = 0;

	      for(index=layer->children.head;index->next;index=index->next)
		{
		  if(index->visibility)
		    {
		      size.xy = calc_minsize(index);
		      layer->minwidth  = greater(layer->minwidth,size.coor.x);
		      layer->minheight = greater(layer->minheight,size.coor.y);
		    }
		}
	      break;

	    }
	  layer->flags |= LAYER_MIN_VALID;
	}
      else layer->flags |= LAYER_MIN_VALID;

      if(!layer->minwidth)layer->minwidth   = 1;
      if(!layer->minheight)layer->minheight = 1;

      if(((ow!=layer->minwidth)||(oh!=layer->minheight)) &&
	 (layer->parent)&&(layer->parent->flags&LAYER_MIN_VALID))
	{
	  layer->flags &= ~LAYER_MIN_VALID;
	  layer = updateminsize(layer->parent);
	}
    }

  return layer;
}
      

struct layer *arrangelayer( struct layer *layer, int dx, int dy )
{
  struct layer *index,*i2;

  /* first calculate the minimum size. */
  index = updateminsize(layer);

  if(layer!=index)
    {
      if(!(layer->flags&LAYER_ARRANGE_MASK))
	{
	  /* First move children if necessary. */
	  for(i2=layer->children.head;i2->next;i2=i2->next)
	    movechild(i2,dx,dy,FALSE);
	}
      arrange(index,0,0);
    }
  else arrange(layer,dx,dy);

  return index;
}

/* arrange.c */
