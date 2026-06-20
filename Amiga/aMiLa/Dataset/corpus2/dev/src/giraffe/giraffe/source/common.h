#ifndef GIRAFFE_COMMON_H
#define GIRAFFE_COMMON_H

/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: common.h  -- long version               */
/*    |< |      created: June 14, 1995                        */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

/* This file contains all structures used within the source
   to the giraffe.library. */

#include <exec/types.h>
#include <graphics/text.h>

#define GIRAFFE_SOURCE
#include <giraffe.h>
#include "driver.h"

/*
 * Just a couple of typedefs and
 * definitions that I like. I'm not
 * into using all capitals, since it
 * makes everything emphasized.
 */
 
#define True  1
#define False 0
#define Null  0

typedef unsigned char  boolean;
typedef unsigned char  uchar;
typedef unsigned char  ubyte;
typedef unsigned short uword;
typedef unsigned short ushort;
typedef unsigned long  ulong;

/*
 * Some geometrical structures.
 *
 * point -- Defines a coordinate pair. Usually
 *          return as an unsigned long.
 *
 * line  -- This structure is used by the
 *          line clipping routines to pass
 *          segments around.
 *
 * frame -- Defines a box by upper-left hand
 *          corner and its dimensions.
 *
 * rectangle -- Defines a box by its upper-left
 *              and lower-right corners. These
 *              are useful during clipping.
 */

union point {
  struct { short x,y; }coor;
  ulong xy;
};

struct line {
  union point p1,p2;
};

struct frame {
  union point origin;
  union point size;
};

struct rectangle {
  union point min,max;
  };


#define movepoint(p,dx,dy) (p.coor.x += dx, \
                         p.coor.y += dy)
#define moverectangle(r,dx,dy) (r.min.coor.x += dx, \
                             r.min.coor.y += dy, \
                             r.max.coor.x += dx, \
                             r.max.coor.y += dy)




/*
 * These are all temporary globals.  The heap should
 *  dynamically size itself eventually.
 */

#define BLOCK_FREE 1
#define BLOCK_SIZE 3000
#define BLOCK_SIZE_BYTES (BLOCK_SIZE*sizeof(ulong))
#define MINIMUM_BLOCKS 1

struct heap_block {
  struct heap_block *next;
  int    free;
  ulong *heapp;
  ulong  array[BLOCK_SIZE];
};



/* 
 *  All objects created by the giraffe library
 *  have a header to identify them.  Management
 *  and tracking of objects is kept with 
 *  giraffe.c
 *
 *  The objects defined are:
 *    GT_Layer
 *    GT_Region
 *    GT_ClipList
 *    GT_InputEvent  -- event structures sent to input.device.
 *    GT_Font
 *    GT_Stack
 *
 *   The objects header consists of the following.
 *      .node  -- Node used to link the object into
 *                resource tracking lists.
 *      .type  -- GT_...
 *      .size  -- Size of the object in bytes. not including 
 *                the header.
 *      .match -- part of the object pointer. Used to 
 *                reliably guarantee the validity of the
 *                object. 
 */

struct object_header {
  struct MinNode node;
  ubyte  type;
  ubyte  size;
  ushort match;
};


#define GT_Null		0
#define GT_Layer	1
#define GT_Region    	2
#define GT_ClipList     3
#define	GT_InputEvent	4
#define GT_Font		5
#define GT_Stack        6
#define GT_TOTAL        7

#define allocregionobject() ((struct region *)allocobject(GT_Region,sizeof(struct region)))

/*
 * GT_Layer
 *
 * see layers.h for more information.
 */


/*
 * GT_Region
 * 
 * This object is used for creating a linking list
 * of rectangles and performing logical operations
 * with them.
 *
 * The region structure:
 *   .bounds     -- The rectangular bounds that includes
 *                  all the rectangles in the list.  This
 *                  is useful for a quick overlap check.
 *   .rectangles -- The list of rectangles that comprise
 *                  the region.  The list is singly linked
 *                  and the structure of the nodes is
 *                  self-explanatory.
 *   .usecount   -- Counter to keep the region pointer valid
 *                  until this reaches zero.  This is needed
 *                  because many layers share a single region.
 */

/* These are used to create a linked list of rectangles. */
struct rrectangle {
  struct rrectangle *next;
  struct rectangle bounds;
};

struct region {
  struct rectangle bounds;        
  struct rrectangle *rectangles;  
  short  usecount;                
  short  pad;
};


/*
 * GT_ClipList
 *
 * The cliplist is similar to the regions structure
 * but it maintains bitmaps with the rectangles
 * in its nodes.  When drawing into a layer, one
 * simply traverses the cliplist in order to 
 * determine where one can draw in more than
 * one bitmap.
 *
 * The cliplist has the following fields:
 *   .bounds    -- The overall bounds of all the rectangles in
 *                 the list.  Useful for doing a quick bounds
 *                 check.
 *
 *   .usecount  -- The number of layers that are sharing the
 *                 cliplist.
 *
 *   .list      -- A singly linked list of cliprects.  See
 *                 description following this.
 *
 *   .push      -- Used during udating a layer when only
 *                 the damage list is to be fixed.  A new
 *                 cliplist is created, but the old one is
 *                 put into this field so that it does
 *                 not have to be recreated when the updating
 *                 is complete.
 *
 * The cliprect structure consists of the following:
 *   .next      -- Points to the next node in the
 *                 list.
 *   
 *   .next_bitmap -- The total cliplist is a combination of
 *                   lists for different bitmaps.  The first
 *                   node in each of these lists points to 
 *                   the next, so that those pertaining to
 *                   a particular bitmap may be quicky found.
 *
 *   .bitmap     -- Bitmap that the node describes the
 *                  clipping of.
 *
 *   .origin     -- Used to translate coordinates from the 
 *                  root layer to the bitmap. After clipping
 *                  is performed to bounds, the origin is
 *                  subtracted to fit the drawing into the
 *                  bitmap.
 *
 *   .bounds     -- The visible portion of the bitmap.
 */

struct cliprect {
  struct cliprect *next,*next_bitmap;
  BitMapPtr        bitmap;
  union  point     origin;
  struct rectangle bounds;
};

#define alloccliplist() ((struct cliplist *)allocobject(GT_ClipList,sizeof(struct cliplist)))
#define freecliplist(clip) (freeobject((void *)(clip)))
#define alloccliprect() ((struct cliprect *)alloc24())
#define freecliprect(crectp) (free24((void *)(crectp)))

struct cliplist {
  struct cliplist *push;
  struct rectangle bounds;
  SHORT usecount;
  USHORT pad;
  struct cliprect *list;
};


/*
 * These are bits set for performing
 * Cohen-Sutherland line clipping. 
 */
#define OUTSIDE_LEFT   1
#define OUTSIDE_TOP    2
#define OUTSIDE_RIGHT  4
#define OUTSIDE_BOTTOM 8


/*
 * GT_InputEvent
 *
 * These are for writing events to the input.device.
 *  see "devices/inputevent.h" for
 *  the structure.
 */
 

/*
 * GT_Font
 *
 *  The font system is still under developement
 *  but this is the preliminary work.
 *
 *  The giraffe library maintains a dictionary of
 *  all the fonts open.  Each element in the dictionary
 *  will consist of a font family and the members 
 *  are arranged in a tree.
 *
 *  The structure of the font is as
 *  follows:
 *      .lower,.upper  -- These are used to arrange the members 
 *                        of a font family into a tree.  Currently
 *                        there are linked according to the size
 *                        of the font.
 *
 *      .pointsize     -- Official size of the font.
 *
 *      .usecount      -- Index of how many times the font has been
 *                        opened/used. Font is not destroyed until
 *                        this counter reaches zero.
 *
 *      .width         -- The nominal width of the font in pixels.
 * 
 *      .height        -- The height of the font in pixels.
 *   
 *      .baseline      -- Location of the baseline of the font relative to
 *                        the top.
 *
 *      .lochar,.hichar  -- The ranges of characters stored in this font.
 *
 *      .packing       -- The individual characters in the font are
 *                        stored in a packed bitmap.  This array contains
 *                        the offset and width of each glyph.  The
 *                        array is indexed relative to .lochar.
 *
 *      .spacing       -- These arrays contains spacing and kerning values
 *      .kerning          for each character in the font.  Again, the index
 *                        is relative to .lochar.
 *
 *      .data          -- Pointer to one-plane map that contains the images
 *                        of all the characters.
 *
 *      .RealFont      -- Pointer to font opened using OpenFont() call of the
 *                        graphics.library.  I would like eventually to avoid
 *                        this necessity altogether.  NULL if the font was
 *                        created by scaling another font.
 */
 
struct font {
  struct font *lower,*upper;
  char *name;
  short pointsize;
  short usecount;   /* Used for multiple ownership of the font. */
  
  unsigned short width;      /* Nominal width of font. */
  unsigned short height;     /* The height of the font. */
  unsigned short baseline;   /* Location of the font baseline. */

  uword lochar;     /* The first character in the collection. */
  uword hichar;     /* The last character in the collection. */

  struct bitpack {  /* Fonts are stored with all characters packed together. */
    uword offset;   /* Location of the character in the bitmap. */
    uword width;    /* Width of the font in the bitmap. */
  }*packing;

  uword *space;     /* Contains spacing information for proportional fonts. */
  uword *kern;      /* The kerning information for a proportional font. */

  BitMapPtr data;            /* Bitmap containing glyphs. */
  struct TextFont *RealFont; /* Pointer to the gfx.library font. */
};

/*
 * Font Family
 *
 *   This structure is used by the dictionary to
 *  make a hash table of font families.  For now
 *  all it contains are:
 *   .key      -- The hash value of the font to quickly
 *                check whether to continue.
 *
 *   .name     -- String for holding the title of the font.
 *
 *   .tree     -- Tree to the individual font family
 *                members.
 */
 
struct fontfamily {
  int    key;
  char  *name;
  struct font *tree;
};


/*
 * GT_Stack
 *
 *   .lock    -- An exec semaphore to make sure that the stack
 *               is run in one instance at a time.
 *
 *   .source  -- Array of tokens which make up the script.
 *
 *   .stacksize -- Number of elements to be allocated for the
 *                 operand stack.
 *
 *   .framesize -- Number of elements to be allocated for the
 *                 variable frame.
 *
 *   . frame_org -- Used for creating a preloaded frame. This array
 *                  contains information on how to load user's data
 *                  onto the frame. The array is terminated with a
 *                  a NULL type.
 *
 *   .initial_frame -- Base pointer of where to extract data for 
 *                     preloading the frame. The offset values given
 *                     in frame_org are relative to this pointer.
 *
 *   .colors   -- Standard palette of colors used by the stack. These
 *                are taken from EGS and are labeled.
 *                   Front
 *                   Back
 *                   Light
 *                   Dark
 *                   Select
 *                   TxtFront
 *                   TxtBack
 *
 *   .font    -- The default font to be used by the stack. This font
 *               is loaded into the graphics state. 
 */

struct stack_program {
  struct SignalSemaphore lock;
  unsigned long *source;
  int usecount;
  short stacksize;
  short framesize;
  struct G_DataTag *frame_org;
  unsigned long initial_frame;

  ulong *colors;
  struct font *font;
};

/*
 * The operand union.
 *  The operand stack is made up of an array of
 * these operands. It is a union so that casting
 * can be done in context. However, no type checking
 * is done, except for objects, so care must be
 * taken in debugging stack errors.
 *
 *   .uval -- Used for unsigned numbers like pens,..
 *   .ival -- Used for most mathematical functions.
 *   .string -- Used for addressing strings.
 *   .addr -- Used for passing pointers.
 */

union operand {
  unsigned long uval;
  int ival;
  char *string;
  void *addr;
  BitMapPtr map;
};

/*
 * The graphics state
 *
 *  This structure is used for maintaing the current
 * state of graphics operations into the output. The
 * elements of this structure are:
 *
 *   .gc       -- The graphics context for holding pens
 *                drawmodes, etc... (see giraffe.h)
 *
 *   .clip     -- Used to allow a user clipping rectangle.
 *                The pointer to this is linked into the
 *                graphics context. (see gc.clip)
 *
 *   .layer    -- The output for all graphics operations.
 *
 *   .font     -- The current font for all text related
 *                actions.
 *
 *   .cursor   -- Position of the cursor in the global coordinates
 *                of the output layer. Do not confuse with global
 *                coordinates of the root layer.
 *
 *   .origin   -- Local origin used by translation or during a
 *                call to a subroutine.
 *
 *   .scale    -- Scaling factor for postscript like functions.
 *
 *   .push     -- pointer for linked previous graphics states that
 *                have been saved by the gpush or call operands.
 */

struct gstate {
  struct G_GC    gc;
  struct rectangle clip;
  struct layer *layer;
  struct font  *font;
  union point cursor,origin;

  union point scale;
  struct gstate *push;
};

/*
 * The virtual machine.
 *  This structure maintains the stacks and
 * such for executing the stack.  The members
 * of the structure are:
 *
 *  .gstate -- The current graphics state.
 *
 *  .framep -- Current base pointer of the frame.
 *
 *  .frame  -- Pointer to the bottom of the
 *             frame buffer.
 *
 *  .frame_size -- Number of elements allocated for
 *                 user variables.
 *
 *  .stackp -- Pointer to the current element of the
 *             operand stack.
 *
 *  .stack  -- Bottom address of the operand stack.
 *
 *  .stackcnt -- The number of elements stored in the
 *               operand stack.
 *
 *  .enest  -- The execution nest. This value is increased
 *             by program control tokens like jsr, if, do..while
 *             and such. When this value reaches zero, the
 *             stack is complete.
 *
 *  .loopnest -- The current number of nested loops. This value
 *               is reset to zero whenever the program jumps or
 *               goes to a subroutine.  In the case of a subroutine
 *               the value is restored when the subroutine is
 *               completed.
 *
 *  .ifnest  -- The current number of nested conditional statements.
 *              Behavior is similar to loopnest.
 *
 *  .pc      -- Current address of the program execution.
 *
 *  .mode    -- The current mode of operation. This value holds the
 *              token of a program control statement. For example,
 *              IG_while, IG_repeat, ... This value is reset when
 *              a loop or conditional is finished. The default
 *              value is NULL.
 */

struct context {
  struct gstate gstate;
  ulong colors[7];

  union operand *framep,*frame;
  int frame_size;

  union operand *stackp,*stack;
  short stackcnt;

  short enest;
  short loopnest;
  short ifnest;
  ulong *pc,*loop;
  ulong mode;

};


/*
 * This structure is left over from
 * old versions of this library. Eventually
 * I plan to bring it back, so I'll 
 * save it for now.
 */

struct AreaPattern {
BitMapPtr bitmap;
ushort width;
ushort height;
ushort modulox;
ushort moduloy;
};


/*
 * Some useful macros used throughout
 * giraffe.library.
 *
 * useregion()   -- macro to increment the region usecount.
 * useregion2()  -- same, but increase usecount by two.
 * useregion4()  -- same, but increase usecount by four.
 * rectwidth()   -- returns width a rectangle.
 * rectheight()  -- retrieves height of rectangle.
 * rectpwidth()  -- same as rectwidth(), but uses a pointer.
 * rectpheight() -- same as rectheight(), but uses a pointer.
 * greater()     -- returns the greater of two values.
 * lesser()      -- returns the lesser of two values.
 */
 
#define useregion(region)   (((region)->usecount++),(region))
#define useregion2(region) (((region)->usecount+=2),(region))
#define useregion4(region) (((region)->usecount+=4),(region))
#define rectwidth(rect)     ((rect).max.coor.x-(rect).min.coor.x+1)
#define rectheight(rect)    ((rect).max.coor.y-(rect).min.coor.y+1)
#define rectpwidth(rectp)   ((rectp)->max.coor.x-(rectp)->min.coor.x+1)
#define rectpheight(rectp)  ((rectp)->max.coor.y-(rectp)->min.coor.y+1)
#define greater(x,y) ((x)<(y)?(y):(x))
#define lesser(x,y) ((x)<(y)?(x):(y))

/*
 * The following arrays of numbers used to 
 * calcluate trigonometric values.  The data
 * is in ellipse.c
 *
 * Two macros give sine and cosine values.
 *  sin(), cos().
 * The value must range from 0 to 64 where
 * 64 is a right angle.
 */
 
extern int tangents[];
extern int cosines[];
extern int lower_tangents[];
#define cos(x) (cosines[x])
#define sin(x) (cosines[64-x])


/* function prototypes. */
/* giraffe.c */

BOOL InitLibrary( void );
void free_resource_list( void );
void ShutDownGiraffe( void );
void *allocobject( UBYTE, int );
void freeobject( void * );
void *checkobject( void *, UBYTE );
void *allocm( int );
void freem( void * );
void *alloc24( void );
void free24( void * );
void *alloc12( void );
void free12( void * );

/* regions.c */
struct region *newregion( struct rectangle *start );
void disposeregion( struct region *region );
struct region *copyregion( struct region *region );
struct region *concatregions( struct region *region1, struct region *region2 );
struct region *clearregion( struct region *region );
struct region *andrectregion( struct region *region, struct rectangle *rect );
struct region *andregionregion( struct region *region1, struct region *region2 );
struct region *clearrectregion( struct region *region, struct rectangle *rect );
struct region *clearregionregion( struct region *region1, struct region *region2 );
struct region *orrectregion( struct region *region, struct rectangle *rect );
struct region *orregionregion( struct region *region1, struct region *region2);
struct region *moveregion(struct region *region, int delx, int dely );

/* draw.c */
void pixel( struct cliplist *, BitMapPtr, struct GC *, int, int );
void line( struct cliplist *, BitMapPtr, struct GC *, int, int, int, int );
void rectangle( struct cliplist *, BitMapPtr, struct GC *, int, int, int, int );
void rectanglefill( struct cliplist *, BitMapPtr, struct GC *, int, int, int, int );
void polygon( struct cliplist *, BitMapPtr, struct GC *, union point *, int );
void arc( struct cliplist *, BitMapPtr, struct GC *, int, int, int, int, int, int );
void wedge( struct cliplist *, BitMapPtr, struct GC *, int, int, int, int, int, int );
void filltwotone( struct cliplist *, BitMapPtr, ulong, ulong, BitMapPtr, struct rectangle *, struct rectangle * );
void blit( struct cliplist *, BitMapPtr, struct GC *, int, int, ulong, ulong, BitMapPtr, int, int );

/* clip.c */
ulong checkbounds( struct rectangle *, int, int );
ulong cutline( struct rectangle *, union point, union point );
boolean clipline( struct rectangle *, struct line * );
boolean cliprectangle( struct rectangle *, struct rectangle *, struct rectangle * );
boolean clipvertical( struct rectangle *, struct line * );
boolean cliphorizontal( struct rectangle *, struct line * );
struct cliplist *newcliplist( void );
void disposecliplist(struct cliplist * );
struct cliplist *usecliplist( struct cliplist * );
void updatecliplist( struct layer * );
struct cliplist *pushcliplist( struct cliplist *, struct region * );
struct cliplist *popcliplist( struct cliplist * );
void erasecliplist( struct cliplist *clip );

/* arrange.c */
struct layer *arrangelayers( struct layer *, int, int );

/* ellipse.c */
int flattenarc( union point *, int, int, int, int, int, struct rectangle * );



/* stack.c */
void op_jmp(  struct context *glob );
void op_rts( struct context *glob );
void op_jsr( struct context *glob );
void op_call( struct context *glob );
void op_pop( struct context *glob );
void op_dup( struct context *glob );
void op_swap( struct context *glob );
void op_rot3( struct context *glob );
void op_rotn( struct context *glob );
void op_val( struct context *glob );
void op_adr( struct context *glob );
void op_get1( struct context *glob );
void op_get2( struct context *glob );
void op_getn( struct context *glob );
void op_popn( struct context *glob );
void op_dupn( struct context *glob );
void op_getf( struct context *glob );
void op_putf( struct context *glob );
void op_stkadr( struct context *glob );
void op_pokeb( struct context *glob );
void op_pokew( struct context *glob );
void op_poke( struct context *glob );
void op_add( struct context *glob );
void op_neg( struct context *glob );
void op_sub( struct context *glob );
void op_mul( struct context *glob );
void op_seq( struct context *glob );
void op_sne( struct context *glob );
void op_sgt( struct context *glob );
void op_slt( struct context *glob );
void op_sge( struct context *glob );
void op_sle( struct context *glob );
void op_snot( struct context *glob );
void op_sand( struct context *glob );
void op_sor( struct context *glob );
void op_idiv( struct context *glob );
void op_imod( struct context *glob );
void op_getposx( struct context *glob );
void op_getpoxy( struct context *glob );
void op_getcolor( struct context *glob );
void op_getback( struct context *glob );
void op_color( struct context *glob );
void op_back( struct context *glob );
void op_modea( struct context *glob );
void op_modeab( struct context *glob );
void op_image( struct context *glob );
void op_move( struct context *glob );
void op_draw( struct context *glob );
void op_write( struct context *glob );
void op_box( struct context *glob );
void op_locate( struct context *glob );
void op_locate00( struct context *glob );
void op_packed( struct context *glob );
void op_font( struct context *glob );
void op_drawabs( struct context *glob );
void op_box2d( struct context *glob );
void op_text( struct context *glob );
void op_clight( struct context *glob );
void op_cnormal( struct context *glob );
void op_cdark( struct context *glob );
void op_cselect( struct context *glob );
void op_cback( struct context *glob );
void op_ctxtfront( struct context *glob );
void op_ctxtback( struct context *glob );
void op_while( struct context *glob );
void op_do( struct context *glob );
void op_if( struct context *glob );
void op_else( struct context *glob );
void op_end( struct context *glob );
void op_repeat( struct context *glob );
void op_until( struct context *glob );
void op_debug( struct context *glob );
void op_const( struct context *glob, unsigned long value );
void op_getfi( struct context *glob, unsigned long value );
void op_putfi( struct context *glob, unsigned long value );
void op_getsi( struct context *glob, unsigned long value );
void op_frame( struct context *glob, unsigned long value );
void op_rtf( struct context *glob, unsigned long value );
void op_addi( struct context *glob, unsigned long value );
void op_dupi( struct context *glob, unsigned long value );
void op_const24( struct context *glob, unsigned long value );
void op_popi( struct context *glob, unsigned long value );
void op_justifyntext( struct context *glob, unsigned long value );
void op_justifyctext( struct context *glob, unsigned long value );
void op_setscale( struct context *glob );
void op_setratio( struct context *glob );
void op_smove( struct context *glob );
void op_slocate( struct context *glob );
void op_sdraw( struct context *glob );
void op_sdrawabs( struct context *glob );
void op_scurve( struct context *glob );
void op_scurveabs( struct context *glob );
void op_sellipse( struct context *glob );
void op_sbox( struct context *glob );
void op_sbox2d( struct context *glob );
void op_samove( struct context *glob );
void op_salocate( struct context *glob );
void op_sadraw( struct context *glob );
void op_sadrawabs( struct context *glob );
void op_sacurve( struct context *glob );
void op_sacurveabs( struct context *glob );
void op_saellipse( struct context *glob );
void op_saend( struct context *glob );



/* my extensions to stack language. */
void op_getwidth( struct context *glob );
void op_getheight( struct context *glob );
void op_getframe( struct context *glob );
void op_expandframe( struct context *glob );
void op_getfontbaseline( struct context *glob );
void op_getfontwidth( struct context *glob );
void op_getfontheight( struct context *glob );
void op_getnstringwidth( struct context *glob );
void op_getcstringwidth( struct context *glob );
void op_centernstring( struct context *glob );
void op_centercstring( struct context *glob );
void op_home( struct context *glob );
void op_setlinewidth( struct context *glob );
void op_setround( struct context *glob );
void op_setclip( struct context *glob );
void op_clearclip( struct context *glob );
void op_greater( struct context *glob );
void op_lesser( struct context *glob );

void op_justifyntext( struct context *glob, unsigned long value );
void op_justifyctext( struct context *glob, unsigned long value );
void op_nudgecursor( struct context *glob, unsigned long );

void op_DUP2( struct context *glob );
void op_ADD2( struct context *glob );
void op_SUB2( struct context *glob );

void op_newpath( struct context *glob );
void op_closepath( struct context *glob );
void op_lineto( struct context *glob );
void op_moveto( struct context *glob );
void op_rlineto( struct context *glob );
void op_rmoveto( struct context *glob );
void op_stroke( struct context *glob );
void op_fill( struct context *glob );


#endif  /* GIRAFFE_COMMON_H */
