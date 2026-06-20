#ifndef LAYERS_H
#define LAYERS_H

/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: layers.h  -- long version               */
/*    |< |                                                    */
/*    \_/|     version 2                                      */
/*------------------------------------------------------------*/

#include <exec/types.h>
#include <exec/lists.h>
#include <exec/tasks.h>
#include <exec/io.h>

#include <devices/input.h>
#include <devices/inputevent.h>
#include <egs/egs.h>
#include <utility/tagitem.h>

#include "common.h"

/*
 * Public Layer Information.
 *
 * All definitions to be used by a user of
 * the giraffe library are contained with
 * giraffe.h
 *
 * See that file for descriptions.
 *
 * This includes:
 * 1. casting of layers: G_layer
 * 2. all the tags used for creating a layer.
 * 3. The input device event classes used
 *    to signal changes in the layer tree.
 *
 * The remaining information here is private
 * and should only be used for compiling or
 * modifying the giraffe.library.
 */


/*
 * Layer Arbitration Structures.
 *  Semaphores/Locks
 */

/*
 * A singly linked node for use with
 * with layer semaphores.  Contains the
 * task that is requesting/sharing the
 * lock.
 *
 * This node is used in both of the lists
 * of the semaphore.  If it is in the queue
 * waiting for the semaphore, then .flags
 * indicates whether or not the request
 * is for a shared lock.
 * If the node is in the shared list, then
 * flags indicates, the number of times
 * that this task has gotten a
 * lock.
 */
struct layerrequest {
  struct layerrequest *next;
  struct Task         *client;
  int    flags;  
  };

/*
 * The layer locking semaphores.
 * These are a personal implementation that
 * overcame a problem that I had when two tasks
 * could effectively lock out a third.
 *
 *  The fields are as follows:
 *   .usercount      -- The number of times this lock has been 
 *                      obtained. When this reaches zero, any
 *                      tasks waiting in line are signaled.
 *
 *   .owner          -- The task pointer of the exclusive owner
 *                      of the layer.  If this is NULL then the
 *                      lock is shared by the tasks listed in
 *                      the shared list.
 *
 *   .next           -- This fixed request is for the next task
 *                      waiting to obtain the semaphore. The 
 *                      layerrequest node is described above.
 *                      NOTE: this node is not linked into any
 *                      list.
 *
 *   .queue          -- A singly linked list of nodes that contain
 *                      the tasks waiting for ownership of the
 *                      lock and the type of lock they want.
 *
 *   .shared         -- A list of all the tasks that are currently
 *                      sharing this node.
 */
 struct layerlock {
  short usecount;
  unsigned short pad;
  struct Task *owner;
  struct layerrequest next;
  struct {
    struct layerrequest *first,*last;
    }queue,shared;
};

/*
 * This is the signal that any task waiting
 * for a layer uses.  I found this value in
 * exec/tasks.h for use with the blitter.  
 * Since I don't expect any conflicts, I'll
 * use it.  I really should figure out the
 * real signal for semaphores used by
 * exec itself.
 */
#define SEMAPHORE_SIGNALF 1<<4


/*
 * Okay, here are the actual layer structures. These
 * are all private, so this is only for the library
 * code to use.
 *
 * There are a total of four different kinds of
 * layers described in the following:
 *
 *  Normal Layer -- This is the biggest layer and it
 *                  has all the bells and whistles.
 *                  It is clipped to its boundary and
 *                  can have children etc..  There are
 *                  limitations on these other than
 *                  they must have a parent.
 *
 *  Non-Clipped Layer -- This layer is the first that
 *                       I created after the normal layer
 *                       so that I could save some resources
 *                       These layers inherit the clipping
 *                       of their parents so that they
 *                       don't need their own cliplist, 
 *                       damagelist etc..  These layers
 *                       are useful for creating GUI elements
 *                       where overlapping is not problem.
 *
 *  Hot-spot Layers -- These layers are the smallest of
 *                     the three and save a little bit of
 *                     space over the Non-Clipped layer by
 *                     giving up the ability to have any
 *                     children. Yes, the Eunuch layer here
 *                     is useful for Buttons, or control
 *                     points. etc..
 *
 *  Root Layer   -- At the bottom of the layer tree, the layer
 *                  which started it all is the root.  This
 *                  layer only has limitations in the sense that
 *                  it is always fixed to the size of the
 *                  bitmap that it was created to wrap.  Other
 *                  than that it behaves just as all the other
 *                  layers.  Oh, it has to be simple refresh
 *                  since it does no make sense to have another
 *                  bitmap.
 *
 *
 * The fields of the layer structure are as follows:
 *      .next,.prev   -- This is the minnode for creating a
 *                       doubly linked list of layers.
 *
 *      .parent       -- Points to the parent of the layer.
 *                       This field is NULL if the layer is the
 *                       root.
 *
 *      .local_lock   -- A semaphore for locking this layer only.
 *                       This semaphore is inherited by the non-
 *                       clipping layers, since they share the
 *                       cliplist of their parent.
 *
 *      .root_lock    -- This semaphore is used for locking the entire
 *                       layer tree when performing an operation which
 *                       changes the tree itself.  This a shared lock
 *                       is requested for graphics operations to keep
 *                       the tree from changing.
 *
 *
 *      .bounds       -- This rectangle is the dimensions of the layer in
 *                       the global coordinates of the root bitmap.
 *
 *      .visibility   -- This region indicates where in the root map
 *                       that the layer is visible. This region is
 *                       inherited by non-clip layers.
 *
 *      .clip         -- The cliplist contains information for actually
 *                       drawing to the screen.  The list consists of
 *                       nodes with a bitmap, rectangle, and origin. The
 *                       primitives go through this list and draw into
 *                       the nodes that are appropriate.
 *
 *      .flags        -- Thirty-two flags which define the state of the
 *                       layer.  See the individual descriptions for 
 *                       more information.
 *
 *      .usecount     -- The number of owners of the layer. In order to 
 *                       maintain the layer in a multi-tasking environment
 *                       its pointer remains valid (even if the layer is
 *                       no longer functional) until this field reaches 
 *                       zero.
 *
 *       .user_id     -- An optional 8-bit identifier that may be set by
 *                       user during creation. Use the tag LA_USER_ID.
 *                       The layer can then be identified using G_GetLayerId().
 *
 *       .hash_id     -- An internal 8-bit identifier used by layers to
 *                       indicate their neighbors.  This was introduced to
 *                       save space.
 *
 *       .minwidth    -- The minimum dimensions of the layer.  If the layer has
 *       .minheight      children, then it is calculated automatically.  If
 *                       the layer has no children, then it must be set
 *                       using the tag LA_MINIMUM_WIDTH/HEIGHT.  By default the
 *                       minimum width/height is one pixel.
 *
 *       .spacing     -- Every layer may specify the minimum spacing between
 *                       its neighbors.  The spacing ranges from 0-255 and
 *                       is independently set for each side. Use tags to set.
 *
 *       .layout      -- This structure is used to set information for the
 *                       automatic layout procedure.  It is a union with
 *                       two members:
 *                       
 *                       .relative -- For relative layer placement.  It just
 *                                    contains the neighbors of the layer on
 *                                    all four sides. These are compressed
 *                                    by using the hash_id instead of pointers.
 *                                    A NULL indicates to use the parent's
 *                                    bounds.
 *
 *                       .groups   -- Contains information about the layer for
 *                                    arranging in either a vertical or 
 *                                    horizontal group.  The link field is not
 *                                    yet used, but the weight of the layers
 *                                    is.  I should just have one weight.
 *
 *    The following fields are only included for NOCLIP and NORMAL layers.
 *   Hotspots do not have children, so these become unnecessary.
 *         
 *       .margins     -- A layer may set up margins in which its children will
 *                       not be arranged. From 0-255 , these values are set
 *                       on creation using the tags.
 *
 *       .local       -- This region incidates the visible portion of the
 *                       layer in the first buffer up the layer tree.  If this
 *                       buffer is the root bitmap, then this region is identical
 *                       to the visibility given earlier.
 *
 *       .region      -- If this layer has its own bitmap (SMART/SUPER refresh)
 *                       then this region is set to the bounds of the buffer.
 *                       If the layer is simple refresh, the region is the same
 *                       as the local layer.
 *
 *       .children    -- This is a doubly linked list of the layer's children.
 *
 *       .refresh     -- This union describes how the layer is to be automatically
 *                       refreshed.  The different members of the union are:
 *
 *                       .simple -- This just contains an optinal stack or hook
 *                                  for refreshing the layer.  If this field is
 *                                  NULL, then an event is sent to the input.device.
 * 
 *                       .smart  -- This member contains both a bitmap for backing
 *                                  up drawing into the layer and an optinal stack
 *                                  or hook.  These are used in the contingency that
 *                                  the buffer is incomplete and must be refreshed
 *                                  like a simple refresh layer.
 *
 *                       .super  -- This last member contains a bitmap provided by
 *                                  by the user and a rectangle that indicates its
 *                                  boundary in the coordinates of the root layer.
 *                                  If this bitmap becomes incomplete, then a
 *                                  an exposure event is signalled as there is no
 *                                  space for either a user stack or hook function.
 *
 *   The following are only found in a normall clipped layer.
 *                        
 *        .bitmap     -- The root bitmap. I might change this later to hold the
 *                       smart refresh buffer or superbitmap since as it is, it
 *                       is only used by the root layer anyway.
 *
 *        .damagelist -- This region maintains a list of rectangles that need to
 *                       be refreshed by the user. When the user calls beginupdate()
 *                       the cliplist will be limited to the damaged region.
 *
 *        .lock       -- The actual semaphore for the layer.  The previous fields were
 *                       just pointers so that the semaphores may be shared.
 *
 *   Finally, the only addition the root layer makes is:
 *        .other_lock -- This semaphore becomes root_lock and is shared by all the
 *                       layers in the tree to lock out everyone else.
 */
 
struct layer {
  /* double linked list/tree of layers */
  struct layer *next,*prev;
  struct layer *parent;

  /* layer resource arbitration. */
  struct layerlock *local_lock,*root_lock;

  /* coordinates and layer bitmap/clipping */
  BitMapPtr bitmap;
  struct rectangle bounds;
  struct region *visibility;

  struct cliplist *clip;
  ulong  flags;

  ushort  usecount;
  ubyte   user_id,hash_id;

  ushort minwidth,minheight;

  struct {
    ubyte left,top;
    ubyte right,bottom;
  }spacing;

  union {
    struct {
      ubyte toleft,totop,toright,tobottom;
    }neighbors;
    struct {
      ubyte link;  /* for identifying identical elements */
      ubyte hweight,vweight;
    }groups;
  }layout;

  /* more goes here. */
  struct region *local;
  struct region *region;

  struct {
    struct layer *head,*tail,*tailpred;
  } children;

  struct {
    unsigned char left,top,right,bottom;
  }margins;

  union {
    struct {
      struct stack *stack;
    }simple;
    
    struct {
      BitMapPtr buffer;
      struct stack *stack;
    }smart;

    struct {
      BitMapPtr bitmap;
      struct rectangle bounds;
    }super;
  }refresh;
  struct region *damagelist;
  struct layerlock lock;
};

/*
 * The following is for non-cliping layers that don't
 * need the extra bytes used up for semaphores and 
 * refresh information.
 */
 
struct mediumlayer {
  /* double linked list/tree of layers */
  struct layer *next,*prev;
  struct layer *parent;

  /* layer resource arbitration. */
  struct layerlock *local_lock,*root_lock;

  /* coordinates and layer bitmap/clipping */
  BitMapPtr bitmap;
  struct rectangle bounds;
  struct region *visibility;

  struct cliplist *clip;
  ulong  flags;

  ushort  usecount;
  ubyte   user_id,hash_id;

  ushort minwidth,minheight;

  struct {
    ubyte left,top;
    ubyte right,bottom;
  }spacing;

  union {
    struct {
      ubyte toleft,totop,toright,tobottom;
    }neighbors;
    struct {
      ubyte link;  /* for identifying identical elements */
      ubyte hweight,vweight;
    }groups;
  }layout;

  /* more goes here. */
  struct region *local;
  struct region *region;

  struct {
    struct layer *head,*tail,*tailpred;
  } children;

  struct {
    unsigned char left,top,right,bottom;
  }margins;

  struct {
    struct {
      struct stack *stack;
    }simple;
  }refresh;

};

/*
 * The last is for a hotspot layer that
 * does not have children, therefore
 * margins and such can be removed.
 */
 
struct hotspot {
  /* double linked list/tree of layers */
  struct layer *next,*prev;
  struct layer *parent;

  /* layer resource arbitration. */
  struct layerlock *local_lock,*root_lock;

  /* coordinates and layer bitmap/clipping */
  BitMapPtr bitmap;
  struct rectangle bounds;
  struct region *visibility;
  struct cliplist *clip;

  ulong  flags;
  ushort  usecount;
  ubyte   user_id,hash_id;

  ushort minwidth,minheight;

  struct {
    ubyte left,top;
    ubyte right,bottom;
  }spacing;

  union {
    struct {
      ubyte toleft,totop,toright,tobottom;
    }neighbors;
    struct {
      ubyte link;  /* for identifying identical elements */
      ubyte hweight,vweight;
    }groups;
  }layout;

};

/*
 * Finally, the root layer in addition
 * to all the space of a layer has an
 * extra semaphore at the end that
 * becomes the root_lock.
 */
 
struct rootlayer {
  struct layer *next,*prev;  /* These are not used. */
  struct layer *parent;      /* The is empty indicating a root layer. */

  /* layer resource arbitration. */
  struct layerlock *local_lock,*root_lock;

  /* coordinates and layer bitmap/clipping */
  BitMapPtr bitmap;
  struct rectangle bounds;
  struct region *visibility;

  struct cliplist *clip;
  ulong  flags;

  ushort  usecount;
  ubyte   user_id,hash_id;

  /*
   * The following is not used by the root layer, but
   * is padded to match with a regular layer in size. 
   */
  ulong pad_0;  /* The minimum dimensions. A root is of fixed size. */
  ulong pad_1;  /* Size of spacing information. */
  ulong pad_2;  /* Size of layout information. */

  /* more goes here. */
  struct region *local;
  struct region *region;
 
  struct {
    struct layer *head,*tail,*tailpred;
  } children;

  struct {
    unsigned char left,top,right,bottom;
  }margins;

  union {
    struct {
      struct stack *stack;
    }simple;
    
    ulong pad_4[3];  /* There should be no smart/super refresh. */
  }refresh;

  struct region *damagelist;
  struct layerlock lock;
  
  /* The only addition of the root layer. */
  struct layerlock other_lock; /* This semaphore becomes the root lock. */
  struct layer *overlay,*backdrop;
};

/*
 * The Layer Flags
 *
 *  Here we go in detail
 *
 *  LAYER_TYPE_NORMAL  -- Indicates a layer with its own clipping. 
 *                        It could be root.
 *  LAYER_TYPE_NOCLIP  -- This layer has inherited its clipping from
 *                        its parent.
 *  LAYER_TYPE_BOUNDED -- Just like a noclip layer except that it
 *                        adds its bounds to the gc.Area field.
 *                        So it and its children all draw within
 *                        its bounds.  This will speed up refreshing
 *                        since we don't have to go all the way
 *                        back to a complete layer.
 *  LAYER_TYPE_HOTSPOT -- This layer has not only inherited, but it
 *                        is not allowed to have any children.
 *
 *  LAYER_REFRESHING   -- The layer is currently in the midst of being
 *                        refreshed. This flag is set by beginupdate()
 *                        to indicate that the cliplist has been limited
 *                        to the damaged region.  This flag is cleared
 *                        by endupdate().
 *
 *  LAYER_FIXED_WIDTH  -- These are set when the user has explicitly
 *  LAYER_FIXED_HEIGHT    requested a specific set of dimensions.  These
 *                        are only used when the layer is arranged by
 *                        its parent.
 *
 *  LAYER_LOCK_RIGHT   -- This flag is set when the layer is arranged
 *  LAYER_LOCK_BOTTOM     by specifying its neighbors and you want it
 *                        to attach itself to the parent's bounds. Note
 *                        that this flag is only important when the 
 *                        width or height is fixed otherwise, the
 *                        layer can be stretched to span any gap.
 *
 *  LAYER_SIZE_INVALID -- This flag is set during the arrangement 
 *                        process to indicate that it is not quite
 *                        ready.
 *
 *  LAYER_SIZE_UPDATING - This flag is used during arrangement by 
 *                        neighbors to check for any circular dependen-
 *                        cies.  See arrange_relative() for its use.
 *
 *  LAYER_ARRANGE_RELATIVE -- Indicates that the layer arranges it children
 *                            by specifying neighbors.
 *  
 *  LAYER_ARRANGE_HGROUP   -- Indicates that the layer arranges its children
 *  LAYER_ARRANGE_VGROUP      in either a horizontal or vertical group.
 *
 *  LAYER_MINIMUM_HEIGHT   -- Used by the horizontal/vertical layout functions to
 *  LAYER_MINIMUM_WIDTH       mark a layer at its minimum dimensions. see either
 *                            arrange_vertical() or arrange_horizontal() for 
 *                            implementation.
 *
 *  LAYER_AUTOCLOSE        -- This flag marks the layer to be dropped when its parent
 *                            is closed. see ownlayer()/disownlayer().
 *
 *  LAYER_MIN_VALID        -- This flag indicates that the minimum dimensions
 *                            in the layer are correct.  This flag is set when
 *                            when the minimum dimensions are calculated before
 *                            arrangement.  It should be cleared when a layer has
 *                            children mapped/unmapped.
 *
 *  LAYER_BOUNDS_VALID     -- This flag is set at the end of the layer arrangement
 *                            process.  Until then, the bounds are not truly valid.
 *
 *  LAYER_REFERENCE_HORZ   -- I can't remember what I used these for.
 *  LAYER_REFERENCE_VERT
 *
 *  LAYER_REFRESH_SIMPLE   -- The layer has simple bounds and uses the
 *                            simple refresh method.
 *
 *  LAYER_REFRESH_SMART    -- The layer has its own bitmap for refreshing
 *                            damaged regions.
 *
 *  LAYER_REFRESH_SUPER    -- The layer has bounds different from the simple bounds
 *                            that are visible. Note, this is not actual a refresh
 *                            mode, but it fits into here. This however, has not
 *                            been actually implemented yet.
 *
 *  LAYER_REFRESH_SUPERSMART -- The layer has a superbitmap for refreshing. This is
 *                              a combination of both SUPER/SMART.
 *
 *  I've also included some mask definitions for extracting bits
 *  that are useful together.
 *
 *  LAYER_BUFFER_INVALID     -- This is used by smart refresh layers to indicate
 *                              that the layer's buffer must be refreshed and
 *                              cannot be used to update the display.  This can
 *                              happen, for example, when a layer is resized and
 *                              the buffer is enlarged.
 * LAYER_DELAY_MAP  -- Indicates that the layer will not be mapped 
 *                     unless specifically passed to G_MapLayer().
 *                     That is, it will not be mapped when its parent
 *                     layer is mapped.
 */

#define LAYER_TYPE_MASK     3
#define LAYER_TYPE_NORMAL   0
#define LAYER_TYPE_NOCLIP   1
#define LAYER_TYPE_BOUNDED  2
#define LAYER_TYPE_HOTSPOT  3
#define LAYER_DELAY_DISPOSE  (1<<2)
#define LAYER_REFRESHING     (1<<3)
#define LAYER_FIXED_WIDTH    (1<<4)
#define LAYER_FIXED_HEIGHT   (1<<5)
#define LAYER_LOCK_RIGHT     (1<<6)
#define LAYER_LOCK_BOTTOM    (1<<7)
#define LAYER_SIZE_INVALID   (1<<8)
#define LAYER_SIZE_UPDATING  (1<<9)
#define LAYER_ARRANGE_MASK       (3<<10)
#define LAYER_ARRANGE_RELATIVE   (1<<10)
#define LAYER_ARRANGE_VERTICAL   (2<<10)
#define LAYER_ARRANGE_HORIZONTAL (3<<10)
#define LAYER_MINIMUM_HEIGHT (1<<12)
#define LAYER_MINIMUM_WIDTH  (1<<13)
#define LAYER_AUTOCLOSE      (1<<14)   /* layer is closed by parent. */
#define LAYER_MIN_VALID      (1<<15)
#define LAYER_BOUNDS_VALID   (1<<16)
#define LAYER_REFERENCE_HORZ (1<<17)
#define LAYER_REFERENCE_VERT (1<<18)
#define LAYER_REFRESH_MASK   (3<<19)
#define LAYER_REFRESH_SIMPLE (0<<19)
#define LAYER_REFRESH_SMART  (1<<19)
#define LAYER_REFRESH_SUPER  (2<<19)
#define LAYER_REFRESH_SUPERSMART (3<<19)
#define LAYER_OVERLAY        (1<<21)
#define LAYER_BACKDROP       (1<<22)
#define LAYER_BUFFER_INVALID (1<<23)
#define LAYER_DELAY_MAP      (1<<24)

#define LAYER_MATCH_LEFT     (1<<25)
#define LAYER_MATCH_TOP      (1<<26)
#define LAYER_MATCH_RIGHT    (1<<27)
#define LAYER_MATCH_BOTTOM   (1<<28)
/* Note: 7 flags are remaining for use. */


/*
 * The following macros are defined to make
 * extraction of the layer state more convenient.
 * 
 *  isCLIPPED()  -- Checks if the layer has its own clipping.
 * 
 *  isNOCLIP()   -- Checks if layer inherits clipping from parent,
 *                  but still can have children.
 *
 *  isBOUNDED()  -- Checks if it is a bounded layer.
 *
 *  isHOTSPOT()  -- Checks for a hotspot layer.
 *
 *  isOVERLAY()  -- Checks if the layer is an overlay.
 * 
 *  isBACKDROP() -- Checks if the layer is a backdrop.
 *
 *  isGROUP()    -- Checks if the layer arranges its children
 *                  as a horizontal or vertical group.
 *
 *  isSIMPLE()   -- Checks if the layer uses simple refresh
 *                  method.
 *
 *  isSMART()    -- Checks if the layer has its own smart
 *                  refresh buffer.
 *
 *  isSUPER()    -- Checks if the layer has a super bitmap.
 *
 *  LAYER_TYPE() -- Returns the type of layer: NORMAL, NOCLIP, HOTSPOT.
 *
 *  LAYER_ARRANGE_TYPE() -- Returns type of arrangment:
 *                            NONE,RELATIVE,HORIZONTAL/VERTICAL GROUP.
 *
 *  LAYER_REFRESH_TYPE() -- Returns the type of refresh:
 *                            SIMPLE, SMART, SIMPLE/VIRTUAL BOUNDS, SUPERBITMAP.
 */
#define LAYER_TYPE(l)         ((l)->flags&LAYER_TYPE_MASK)
#define LAYER_ARRANGE_TYPE(l) ((l)->flags&LAYER_ARRANGE_MASK)
#define LAYER_REFRESH_TYPE(l) ((l)->flags&LAYER_REFRESH_MASK)

/* layer types. */
#define isCLIPPED(l)     (!((l)->flags&LAYER_TYPE_MASK))
#define isNOCLIP(l)      (LAYER_TYPE(l)==LAYER_TYPE_NOCLIP)
#define isBOUNDED(l)     (LAYER_TYPE(l)==LAYER_TYPE_BOUNDED)
#define isHOTSPOT(l)     (LAYER_TYPE(l)==LAYER_TYPE_HOTSPOT)
#define isNOTHOTSPOT(l)  (!isHOTSPOT(l))
#define isOVERLAY(l)     ((l)->flags&LAYER_OVERLAY)
#define isBACKDROP(l)    ((l)->flags&LAYER_BACKDROP)
#define isBUFFERED(l)    ((l)->flags&LAYER_REFRESH_SMART)

/* layer arrangement. */
#define isGROUP(l)       ((l)->flags&LAYER_ARRANGE_VGROUP)

/* layer refresh. */
#define isSIMPLE(l)      (!LAYER_REFRESH_TYPE(l))
#define isSMART(l)       (LAYER_REFRESH_TYPE(l)==LAYER_REFRESH_SMART)
#define isSUPER(l)       (LAYER_REFRESH_TYPE(l)==LAYER_REFRESH_SUPERSMART)


/* layers.c internal ANSI prototypes */
struct layer *openrootlayer( BitMapPtr, struct TagItem * );
struct layer *openlayer( struct layer *, struct TagItem * );
void closelayer( struct layer * );
struct layer *uselayer( struct layer * );
struct layer *droplayer( struct layer * );
BOOL maplayer( struct layer * );
void unmaplayer( struct layer * );
void updatelayer( struct layer * );
void pushlayer( struct layer * );
void pulllayer( struct layer * );
void cyclelayer( struct layer * );
void shufflelayer( struct layer *, struct layer * );
void movelayer( struct layer *, int, int );
void movesizelayer( struct layer *, int, int, ulong, ulong );
void sizelayer( struct layer *, ulong, ulong );
struct layer *whichlayer( struct layer *, union point * );
boolean layerrelative( struct layer *, union point * );

struct layer *getlayerhead( struct layer * );
struct layer *getlayertail( struct layer * );
struct layer *getlayernext( struct layer * );
struct layer *getlayerprev( struct layer * );
ulong getlayersize( struct layer * );
boolean getlayerorigin( struct layer *, union point *, int );
boolean getlayerframe( struct layer *, struct frame *, int );
boolean getlayerbounds( struct layer *, struct rectangle * );
struct layer *getlayerparent( struct layer * );
BitMapPtr getlayerbitmap( struct layer * );


void lpixel( struct layer *, struct GC *, int, int );
void lline( struct layer *, struct GC *, int, int, int, int );
void lrectangle( struct layer *, struct GC *, int, int, ulong, ulong );
void lrectanglefill( struct layer *, struct GC *, int, int, ulong, ulong );
void lpolygon( struct layer *, struct GC *, union point *, int );
void larc( struct layer *, struct GC *, int, int, ulong, ulong, int, int );
void lwedge( struct layer *, struct GC *, int, int, ulong, ulong, int, int );


void lblit( struct layer *, struct GC *, int, int, ulong, ulong, BitMapPtr, int, int );
void lblitmask( struct layer *, struct GC *, int, int, ulong, ulong, BitMapPtr, int, int, BitMapPtr, int, int );
void lblitscale( struct layer *, struct GC *, int, int, ulong, ulong, BitMapPtr, int, int, ulong, ulong );
void ltemplate( struct layer *, struct GC *, int, int, ulong, ulong, BitMapPtr, int, int );
void ltemplatescale( struct layer *, struct GC *, int, int, ulong, ulong, BitMapPtr, int, int, ulong, ulong );

/* functions from arrange.c */
void setweigth( struct layer *, int, int );
void invalidatebounds( struct layer * );
void arrange_vertical( struct layer * );
void arrange_horizontal( struct layer * );
struct layer *gethash( struct layer *, int dir );
void arrange_default( struct layer * );
void arrange( struct layer *, int, int );
ulong calc_minsize( struct layer * );
struct layer *updateminsize( struct layer * );
struct layer *arrangelayer( struct layer *, int, int );
struct region *clip( struct region *, struct layer * );

#endif  /* layers.h */
