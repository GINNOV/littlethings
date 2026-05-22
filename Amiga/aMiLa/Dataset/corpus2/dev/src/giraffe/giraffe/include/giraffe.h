#ifndef GIRAFFE_H
#define GIRAFFE_H
/*------------------------------------------------------------*/
/*   giraffe.library -- The Alternative Graphics Library      */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: giraffe.h -- Public Header File         */
/*    |< |      created: June 18, 1995                        */
/*    \_/|     version 2                                      */
/*------------------------------------------------------------*/

#include <exec/types.h>
#include <egs/egs.h>
#include <egs/egsintuigfx.h>

/*
 * The drawable.  This may be
 * either a bitmap or a layer.
 */
typedef void *G_Drawable;
typedef void *G_BitMapPtr;
typedef void *G_Region;

/*
 * Giraffe Library Geometric Structures.
 *
 * G_Point  -- used for coordinate pairs.
 * G_Rectangle -- rectangle defined by upper-left/lower-right corners.
 * G_Frame     -- rectangle defined by upper-left corner and dimensions.
 */

union G_Point {
  struct { SHORT X,Y; } Coor;
  ULONG XY;
};
typedef union G_Point *G_PointPtr;

struct G_Rectangle {
  union G_Point Min;
  union G_Point Max;
};
typedef struct G_Rectangle *G_RectanglePtr;

struct G_Frame {
  SHORT Left,Top;
  USHORT Width,Height;
};
typedef struct G_Frame *G_FramePtr;

/*
 * Useful Macros
 *
 * G_RectWidth(rect)  -- returns width of G_Rectangle.
 * G_RectHeight(rect) -- returns height of G_Rectangle.
 * G_MovePoint(p,x,y) -- translates the point by (x,y).
 * G_MoveRectangle(rect,x,y) -- translates the rectangle by (x,y).
 * G_MoveFrame(frame,x,y)    -- translates the frame by (x,y).
 */

#define G_RectWidth(rect) ((rect).Max.Coor.X-(rect).Min.Coor.X+1)
#define G_RectHeight(rect) ((rect).Max.Coor.Y - (rect).Min.Coor.Y+1)
#define G_MovePoint(p,x,y) ((p).Coor.X += (x), (p).Coor.Y += (y))
#define G_MoveRectangle(rect,x,y)  ((rect).Min.Coor.X += (x), \
				    (rect).Min.Coor.Y += (y), \
				     (rect).Max.Coor.X += (x), \
				      (rect).Max.Coor.Y += (y))
#define G_MoveFrame(frame,x,y) ((frame).Left += (x),(frame).Top += (y))


/*
 * The Graphics Context(GC)
 * 
 *  This structure is passed to primitive functions
 * with additional information about how modify
 * a bitmap.  Combined with the bitmap it plays
 * a similar role to the RastPort of the graphics.library.
 *
 * The fields:
 *   .DrawMode  --  See the individual flags.
 *   .FgPen     -- main pen used by the library. encoded like EGS colors.
 *   .BgPen     -- secondary pen used for backgrounds.
 *   .Mode      -- Mode for the blitter. (see egs/egs.h for description.)
 *   .Mask      -- Indicates which planes are to be used in blitting.
 *   .Round     -- Radius of curvature for rectangle corners.
 *                  Used by: G_Rectangle() and G_RectangleFill().
 *   .LineWidth -- Width in pixels of linear primitives.
 *                  Used by: G_Line(), G_PolyLine(), G_Rectangle(),
 *                            G_Arc() and G_Bezier().
 *   .Area      -- An optional pointer to a G_Rectangle for
 *                  additional clipping.
 */

struct G_GC {
  USHORT DrawMode;
  ULONG  FgPen;
  ULONG  BgPen;
  USHORT Mode;
  USHORT Mask;
  UBYTE  Round;
  UBYTE  LineWidth;
#ifdef GIRAFFE_SOURCE
  struct rectangle *Area;
#else
  G_RectanglePtr Area;
#endif
};
typedef struct G_GC *G_GCPtr;

/*
 * The flags used by the GC DrawMode field.
 *
 * GC_JAM1   -- Draws in one pen mode.
 * GC_JAM2   -- Draws in two pen mode.
 * GC_COMPLEMENT -- XOR bits into the raster.
 * GC_INVERSVID  -- Inverse vide for drawing modes.
 *
 * GC_HSVCOLORS  -- Pen colors are encoded with hue, saturation
 *                  and value.  Otherwise RGB mode is used.
 * GC_GRADIENT   -- For area functions, this flags will make
 *                  a gradient from the FgPen to the BgPen as
 *                  the fill pattern.
 *                   The flags affects: G_RectangleFill(), G_Polygon(),
 *                   G_Wedge(), G_Template().
 *
 * GC_FIXEDFONT  -- Used by all text operations.  Forces a font
 *                  to have a fixed width, even if it is a
 *                  proportional font.
 * GC_ITALICFONT -- Tries to draw text in italic form.
 * GC_BOLDFONT   -- Tries to draw text in bold form.
 */

#define GC_JAM1         0
#define GC_JAM2         1
#define GC_COMPLEMENT   2
#define GC_INVERSVID    4
#define GC_DRWMDMASK    7

#define GC_HSVCOLORS    8
#define GC_GRADIENT    16

#define GC_FIXEDFONT   32
#define GC_ITALICFONT  64
#define GC_BOLDFONT   128

/*
 * Now some macros to make initialization
 * of a graphics context a little bit easier.
 */

#define G_SimpleGC(pen1,pen2)   { GC_JAM2,pen1,pen2,NULL,-1,0,0,NULL }
#define G_Jam1GC(pen1,pen2)     { GC_JAM1,pen1,pen2,NULL,-1,0,0,NULL }
#define G_RoundGC(pen1,pen2,r)  { GC_JAM2,pen1,pen2,NULL,-1,r,0,NULL }
#define G_ThickGC(pen1,pen2,t)  { GC_JAM2,pen1,pen2,NULL,-1,0,t,NULL }

#if 0
/*
 * Layers Definitions and Tags.
 *
 *  Layers provide simple clipping and arrangement for
 * a windowed GUI system.  All operations involve the 
 * pointer to any layer.  This structure is private so
 * no peeking!
 *
 * Examples:
 *  1) root layer creation.
 *
 *  E_EBitMapPtr bitmap;
 *  struct G_GC gc=SimpleGC(1,2);
 *  G_Layer root,child;
 *
 *  if(root=G_OpenRootLayer(bitmap,taglist))  
 *    {
 *      /* root layer can spawn more children. */
 *      if(child=G_OpenLayer(root,taglist))
 *        {
 *          /* This layer must be mapped to be seen. */
 *          G_MapLayer(child);
 *          G_RectangleFill(child,&gc,0,0,100,100);
 *          ...
 *          G_UnmapLayer(child);
 *          G_CloseLayer(child);
 *        }
 *      G_CloseLayer(root);
 *    }
 *  /* exit program. */
 *
 *  The tags recognized when creating a child layer are as follows.
 *
 *  LA_NOCLIP -- (BOOL)      If 'TRUE', then the layer inherits its
 *                          clipping from its parent and can draw outside
 *                          its boundaries.  These layers take less
 *                          memory than a full layer and are useful
 *                          when layers are not overlapping.
 *
 *  LA_HOTSPOT -- (BOOL)      Similar to a 'NOCLIP' layer, but uses even
 *                           less resources.  It cannot have any children
 *                           and it does not generate any exposure events.
 *                           These can be useful for tracking the 
 *                           motion of the mouse. (see demo/spline.c for
 *                           an example.)
 *
 *  LA_WIDTH   -- (USHORT)     Use the tag to set a specific width(height)
 *  LA_HEIGHT                for the layer.  By default, the layer will
 *                           take its minimum dimensions unless arranged
 *                           by its parent.
 *
 *  LA_LOCKRIGHT  -- (BOOL)     Used only by relative layer arrangement.
 *  LA_LOCKBOTTOM              This tag anchors the layer to the right
 *                             or bottom of the parents boundary.  This
 *                             tag is only useful if the dimensions are
 *                             fixed and no neighbors have been given.
 *
 *  LA_TOLEFT    -- (G_layer)   These tags are also used by relative placement
 *  LA_TOTOP                   to identify the neighboring layers.  The
 *  LA_TORIGHT                 default (NULL) indicates that the layer will
 *  LA_BOTTOM                  be attached to the parents bounds.  Beware
 *                             of providing circular references.  This
 *                             problem can be avoided by declaring all
 *                             dependencies when the layer is created and
 *                             not modifying them elsewhere.  (see the
 *                             window arrangement for an example of the
 *                             use of relative placement.)
 *
 *  LA_ARRANGE_RELATIVE -- (BOOL)  Indicates that the layer is the arrange
 *                               all of its children by relative dependecies.
 *                               The neighbors are encoded in the children.
 *
 *  LA_ARRANGE_VERTICAL -- (BOOL)  If 'TRUE', then the layer arranges its
 *  LA_ARRANGE_HORIZONTAL        children in the order that they appear in
 *                               its internal list.  This order may be
 *                               changed using G_Pull(),G_Push(),etc..
 *
 *  NOTE: because of the way that the library interprets these tags,
 *        if two or more are set true, then the result is a horizontal
 *        group.
 *
 *  LA_SPACING_LEFT -- (UBYTE)   When layers are arranged they can have
 *  LA_SPACING_TOP             a space between them and their neighbors.
 *  LA_SPACING_RIGHT           The total spacing is the combination of the
 *  LA_SPACING_BOTTOM          combination of both layers.
 *
 *  LA_WEIGHT_VERTICAL -- (UBYTE)  These tags are used by layers arranged into
 *  LA_WEIGHT_HORIZONTAL         groups.  Sets the ratios for how the total
 *                               area will be divided amongst the children.
 *                               Parent layers will inherit values from 
 *                               their children.
 *
 *  LA_MARGIN_LEFT  -- (UBYTE)   Any layer with children may reserve some
 *  LA_MARGIN_TOP              space around its borders where its children
 *  LA_MARGIN_RIGHT            will not be placed.  This space is included
 *  LA_MARGIN_BOTTOM           into calculating its minimum size.
 *
 *  LA_REFRESH_STACK  -- (G_Stack)  The tags passes a stack object to the
 *                                layer.  This stack will be used to 
 *                                refresh the layer as opposed to sending
 *                                an exposure event.  Sometimes to maintain
 *                                the proper order, an event will be sent
 *                                instead, but then the stack will be called
 *                                if when G_BeginUpdate() is run.
 *                                  NOTE: This tag can only be used by a
 *                                SIMPLE or SMART refresh layer.
 *
 *  LA_REFRESH_SMART  -- (BOOL)   Use this tag if you want the layer to
 *                              maintain a buffer for use during exposure.
 *                              When refresh is required, then the buffer
 *                              will be copied to the screen.  If the buffer
 *                              ever becomes incomplete, then an exposure
 *                              event will be sent or a stack executed.
 *
 *  LA_REFRESH_SUPER  -- (E_EBitMapPtr)  Use this tag to attach your own
 *                                 private bitmap to the layer.  The bitmap
 *                                 can be moved about using G_ScrollLayer()
 *                                 and all graphics calls will be made 
 *                                 relative to the origin of the bitmap.
 *                                 Exposure events may be required if
 *                                 the layer has children that it rearranges.
 *
 *  LA_SUPERLAYER  -- (G_Dimension) This tag can make a layer similar to one
 *                           with SUPER refresh, but without the bitmap. The
 *                           size of the 'virtual' layer is passed in the
 *                           tag data.
 *
 *  LA_MATCH_LEFT  -- (BOOL)   These are used to control the relative 
 *  LA_MATCH_TOP             placement of layers. By default, the layer
 *  LA_MATCH_RIGHT           is arranged to abut its neighbor.  If these 
 *  LA_MATCH_BOTTOM          flags are set, then it will try to match 
 *                           the given side of the dependent.  Let me
 *                           give an example to this poor description.
 *                             If layer 'A' is set to match layer 'B'
 *                           to its right, then the right hand boundary
 *                           of layer 'A' will equal that of layer 'B'.
 *
 *   LA_USER_ID   (UBYTE) -- Sets up a user id# for a layer. These
 *                           can be retrieved using G_GetLayerId().
 * 
 *
 *  NOTE:  Many of the tags are not useful for a root layer since it has no
 *         sibling layers.  These tags will be completely ignored.  These
 *         tags consist of:
 *            LA_NOCLIP
 *            LA_HOTSPOT
 *            LA_WIDTH
 *            LA_HEIGHT
 *            LA_LOCK_RIGHT,LA_LOCK_BOTTOM
 *            LA_TOLEFT, LA_TOTOP, ...
 *            LA_SPACING_LEFT, ...
 *            LA_WEIGTH_VERTICAL, ...
 *            LA_REFRESH_SMART, LA_REFRESH_SUPER
 *            LA_SUPERLAYER
 *            LA_MATCH_LEFT, ....
 *                                       
 */
#endif

typedef void *G_Layer;

#define LA_DUMMY            TAG_USER+1   /* Eventually these tags should find
					  a new home. */
#define LA_NOCLIP              (LA_DUMMY)
#define LA_LEFT                (LA_DUMMY+1)
#define LA_TOP                 (LA_DUMMY+2)
#define LA_WIDTH               (LA_DUMMY+3)
#define LA_HEIGHT              (LA_DUMMY+4)
#define LA_LOCK_RIGHT          (LA_DUMMY+5)
#define LA_LOCK_BOTTOM         (LA_DUMMY+6)
#define LA_TOLEFT              (LA_DUMMY+7)
#define LA_TORIGHT             (LA_DUMMY+8)
#define LA_TOTOP               (LA_DUMMY+9)
#define LA_TOBOTTOM            (LA_DUMMY+10)
#define LA_ARRANGE_VERTICAL    (LA_DUMMY+11)
#define LA_ARRANGE_HORIZONTAL  (LA_DUMMY+12)
#define LA_ARRANGE_RELATIVE    (LA_DUMMY+13)
#define LA_SPACING_LEFT        (LA_DUMMY+14)
#define LA_SPACING_TOP         (LA_DUMMY+15)
#define LA_SPACING_RIGHT       (LA_DUMMY+16)
#define LA_SPACING_BOTTOM      (LA_DUMMY+17)
#define LA_WEIGHT_VERTICAL     (LA_DUMMY+18)
#define LA_WEIGHT_HORIZONTAL   (LA_DUMMY+19)
#define LA_MINIMUM_WIDTH       (LA_DUMMY+20)
#define LA_MINIMUM_HEIGHT      (LA_DUMMY+21)
#define LA_MARGIN_LEFT         (LA_DUMMY+22)
#define LA_MARGIN_TOP          (LA_DUMMY+23)
#define LA_MARGIN_RIGHT        (LA_DUMMY+24)
#define LA_MARGIN_BOTTOM       (LA_DUMMY+25)
#define LA_REFRESH_STACK       (LA_DUMMY+26)
#define LA_REFRESH_SMART       (LA_DUMMY+27)
#define LA_REFRESH_SUPER       (LA_DUMMY+28)
#define LA_USER_ID             (LA_DUMMY+31)

#define LA_MARGIN_DEFAULT      (LA_DUMMY+32)
#define LA_SPACING_DEFAULT     (LA_DUMMY+33)
#define LA_BOUNDED             (LA_DUMMY+34)
#define LA_HOTSPOT             (LA_DUMMY+35)
#define LA_REFRESH_STACKTAGS   (LA_DUMMY+36)

/*
 * InputEvent classes used by giraffe.library to signal
 * changes in layers.
 *
 * IECLASS_EXPOSURE    --  Indicates that a portion of a layer has been
 *                        exposed and must be redrawn.
 * IECLASS_SIZELAYER   --  Passes an array of layers that have been
 *                        resized.
 * IECLASS_CHECK_FOCUS --  Layers have been rearranged and a new focus
 *                        might be present.  Check for any changes.
 */

#define IECLASS_EXPOSURE	0x80
#define IECLASS_SIZELAYER       0x81
#define IECLASS_CHECK_FOCUS     0x82


/*
 *  Stack Objects.
 *
 *   The stack object is my implementation of the EGS
 *  stack language.  See egs/intuigfx.h for their description.
 *  I've encapsulated a stack into an object so that it
 *  can be passed to a layer for automatic execution 
 *  during refresh.  This method skips the whole debate
 *  on whether a layer should be refreshed by the input.device
 *  task, since everything is finished before any event is
 *  sent.
 *
 *   The stack language consists of an array of tokens which
 *  are executed in order.  Operands for the actions are taken
 *  off of a LIFO stack.  In other words, the language is 'like'
 *  encoded postscript, but it doesn't have such a general
 *  imaging model.  It is mainly set up for doing simple
 *  GUI widgets.
 *
 *   Most of the operations from the EGS stack language are the
 *  same here.  Only the ones I couldn't figure out from the include
 *  file may be different.  I've also added a few of my own
 *  commands to make execution faster.
 *
 *
 *  A stack object is created using G_NewStack()
 *
 * For example:
 *
 *   G_Stack stack;
 *   extern struct TagItem *taglist;
 *   extern G_Layer layer;
 *
 *   if(stack=G_NewStack(source,taglist))
 *     {
 *       G_Interpret(layer,stack);
 *       G_DisposeStack(stack);
 *     }
 *
 *  The possible tags used by a taglist are as follows:
 *
 *  SA_STACKSIZE -- (SHORT)  Use this tag to set the number of elements
 *                          available in the operand stack.  The default
 *                          size is STACK_DEFAULTSIZE.
 *
 *  SA_FRAMESIZE -- (SHORT)  Use this tag to allocate the number of bins
 *                          available for personal variables.  The default
 *                          size is STACK_DEFAULTFRAME.
 *
 *  SA_COLORS  -- (G_CArrayPtr)  A palette if colors used for generating
 *                              a GUI go here.  By default a suitable list
 *                              of colors will be used. 
 *
 *  SA_FONT  -- (G_Font)     Set the default font for the stack using this
 *                          tag.  In case it is NULL, the system default
 *                          font will be used.
 *
 *  SA_SEMAPHORE -- (struct SignalSemaphore *)
 *                          This tag is used to pass a semaphore to the
 *                          stack. The purpose of the semaphore is to
 *                          lock any data that is automatically loaded
 *                          onto the frame. (see the next two tags) If
 *                          no semaphore is given, then the stack will
 *                          create its own to keep it single-threaded.
 *
 *    The next two tags must be used together in order to 
 *  preload variables onto the frame.  See demo/slider.c
 *  for a complete example of how this structure can be
 *  used for updating a gadget.
 *
 *  SA_DATAPTR  -- (void *)   This pointer is used as a reference to all dat
 *                           loaded into the frame.  References are given
 *                           as a signed index relative to this pointer.
 *
 *  SA_DATATAGS  -- (G_DataTagPtr)  This tag gives an array of tags that 
 *                                 describe the type of data which is to
 *                                 be loaded onto the frame.  The array
 *                                 ends with a NULL terminator.
 *
 *
 *  The Data Tags:
 *
 *    The data tags are structures with two fields.
 *     .Type   --  This field indicates the type of data.  For example,
 *                a byte, word or long word.
 *     .Offset --  This value points to the data  relative to the base
 *                pointer given by SA_DATAPTR.
 *
 *   Special Note: If that is changed by the stack execution and you'd
 *                 like it to be written back, just make the .Type
 *                 field into a negative number.
 */

typedef void *G_Stack;

struct G_DataTag {
  SHORT Type;
SHORT Offset;
};
typedef struct G_DataTag *G_DataTagPtr;

#define G_DATA_COPYBACK 0x8000
#define G_DATA_MASK     0x00ff

#define G_DATA_BYTE   1
#define G_DATA_UBYTE  2
#define G_DATA_WORD   3
#define G_DATA_SHORT  3
#define G_DATA_UWORD  4
#define G_DATA_USHORT 4
#define G_DATA_LONG   5
#define G_DATA_ULONG  6
#define G_DATA_LAYER  7
#define G_DATA_FONT   8


#define SA_DUMMY     (LA_DUMMY+59)     /* These tags will find a new home. */
#define SA_STACKSIZE (SA_DUMMY)
#define SA_FRAMESIZE (SA_DUMMY+1)
#define SA_HEAPSIZE  (SA_DUMMY+2)
#define SA_DATAPTR   (SA_DUMMY+3)
#define SA_DATATAGS  (SA_DUMMY+4)
#define SA_COLORS    (SA_DUMMY+5)
#define SA_FONT      (SA_DUMMY+6)
#define SA_SEMAPHORE (SA_DUMMY+7)

#define STACK_DEFAULTSIZE   100
#define STACK_DEFAULTFRAME   20

/*
 * Stack error messages. 
 */
#define G_SERROR_STACK_OVERFLOW  1
#define G_SERROR_STACK_UNDERFLOW 2
#define G_SERROR_FRAME_UNDERFLOW 3
#define G_SERROR_FRAME_BOUNDS    4
#define G_SERROR_FRAME_INITIALIZATION 5
#define G_SERROR_IMPROPER_END    6
#define G_SERROR_IMPROPER_ELSE   7
#define G_SERROR_NOTIMPLEMENTED  8
#define G_SERROR_DIVIDE_BY_ZERO  9
#define G_SERROR_BAD_FONT       10
#define G_SERROR_IMPROPER_LOOP  11
/*
 *  The following are the stack operations that I have
 * defined in addition to those give bye EGS.  For those
 * please read egs/intuigfx.h for descriptions, so that
 * I don't have to risk copyright problemos.
 *
 *  The code that follows the command descriptions is C much like
 * the actual source file.  The following global variables are
 * used:
 *       SP - pointer to the stack. It's accessed like a union with
 *            int, ulong, string as int, unsigned long, and char *.
 *       Cursor - The current location of the cursor as G_Point.
 *       output - The bitmap or layer into which graphics are performed.
 *       font   - The current font for the stack.
 *       path,pathp - Array of points for storing a user path.
 *
 *
 *  getwidth    : Puts the width of the output onto the stack.
 *                (--SP)->ulong = output.Width;
 *
 *  getheight   : Puts the height of the output onto the stack.
 *                (--SP)->ulong = output.Height;
 *
 *  getframe    :
 *
 *  expandframe : Expands an frame by 2 pixels in both width and height.
 *                Cursor.Coor.X--;
 *                Cursor.Coor.Y--;
 *                SP[0].int += 2;
 *                SP[1].int += 2;
 *
 *  These commands are all for extracting information from
 *  the current font.
 *
 *  getfontbaseline  : Puts the value of the font baseline onto the stack.
 *                     (--SP)->int = font.Baseline;
 *
 *  getfontwidth     : Puts the nominal width of the font onto the stack.
 *                     (--SP)->ulong = font.Width;
 *
 *  getfontheight    : Puts the height of the current font onto the stack.
 *                     (--SP)->ulong = font.Height;
 *
 *  getnstringwidth  : Puts the width of a Null terminated string onto the
 *                     stack.
 *                     SP[0].ulong = G_TextLength(font,SP[0],strlen(SP[0]));
 *
 *  getcstringwidth  : Puts the width of a Fortran style string.
 *                     SP[0].ulong = G_TextLength(font,SP[0].string[0],
 *                                                     SP[0].string+1);
 *
 *  IG_centernstring
 *  IG_centercstring
 *
 *  home             : Moves the cursor to the upper left corner of output.
 *                     Cursor.Coor.X = 0;
 *                     Cursor.Coor.Y = font.Baseline;
 *
 *
 *  These are for changing the graphics state.
 *
 *  setlinewidth     : Sets the Linewidth field of the graphics context.
 *                     gc.Linewidth = (SP++)->ulong;
 *
 *  setround         : Sets rectangle rounding in the graphics context.
 *                     gc.Round = (SP++)->ulong;
 *
 *  setclip          : Sets the graphics context clipping rectangle.
 *                     rect = (G_RectanglePtr)allocheap();
 *                     rect.Min.XY = cursor.XY;
 *                     rect.Max.Coor.X = SP[1].int;
 *                     rect.Max.Coor.Y = SP[0].ing;
 *                     gc.Area = &rect;
 *                     SP+=2;
 *
 *  clearclip        : Clears the clipping rectangle from graphics context.
 *                     gc.Area = NULL;
 *
 *  Useful little functions.
 *
 *  greater          : Keeps the greater of two elements on top of the stack.
 *                     SP[1].int = (SP[0].int>SP[1].int?SP[0].int:SP[1].int);
 *                     SP++;
 *
 *  lesser           : Keeps the lesser of the top two integers on the stack.
 *                     SP[1].int = (SP[0].int<SP[1].int?SP[0].int:SP[1].int);
 *                     SP++;
 *
 * postscript type operators.
 *
 *  newpath          : Clears the previous path from array.
 *                     pathp = &path[0];
 *
 *  closepath        : Closes a path in on itself.
 *
 *  lineto           : Adds a line from cursor to the point into the path.
 *                     Cursor.Coor.X = SP[1].int;
 *                     Cursor.Coor.Y = SP[0].int;
 *                     *(pathp++) = Cursor;
 *                     SP += 2;
 *
 *  moveto           : Moves the cursor to a new point.
 *                     Cursor.Coor.X = SP[1].int;
 *                     Cursor.Coor.Y = SP[0].int;
 *                     SP += 2;
 *
 *  rlineto          : Draws a line from cursor to relative position.
 *                     Cursor.Coor.X += SP[1].int;
 *                     Cursor.Coor.Y += SP[0].int;
 *                     *(pathp++) = Cursor;
 *                     SP += 2;
 *
 *  rmoveto          : Moves the cursor to a relative position.
 *                     Cursor.Coor.X += SP[1].int;
 *                     Cursor.Coor.Y += SP[0].int;
 *                     SP += 2;
 *
 *  stroke           : Draws the line defined by the path.
 *                     G_Polyline(output,&gc,&path[0],pathp-&path[0]);
 *
 *  fill             : Fill the area defined by the path.
 *                     G_Polygon(output,&gc,&path[0],pathp-&path[0]);
 *

 *  IG_justifyntext
 *  IG_justifyctext
 *  IG_nudgecursor

 * coordinate pair functions
 *  DUP2             : Duplicate top two elements on the stack.
 *                     (--SP)->ulong = SP[1].ulong;
 *                     (--SP)->ulong = SP[1].ulong;
 *
 *  ADD2             : Add the four top elements like coordinates.
 *                     SP[2].int += SP[0].int;
 *                     SP[3].int += SP[1].int;
 *                     SP += 2;
 *
 *  SUB2             : Subtract the top four elements like coordinates.
 *                     SP[2].int -= SP[0].int;
 *                     SP[3].int -= SP[1].int;
 *                     SP += 2;
 *
 * more scaled functions
 *  SBox             : Draw a filled rectangle using scaled values.
 *
 *  SBox2d           : Draw a rectangular outline using scaled values.
 *
 */

#define   IG_getwidth        0x80000500
#define   IG_getheight       0x80000501
#define   IG_getframe        0x80000502
#define   IG_expandframe     0x80000503

#define   IG_getfontbaseline 0x80000510
#define   IG_getfontwidth    0x80000511
#define   IG_getfontheight   0x80000512
#define   IG_getnstringwidth 0x80000513
#define   IG_getcstringwidth 0x80000514
#define   IG_centernstring   0x80000515
#define   IG_centercstring   0x80000516
#define   IG_home            0x80000517
#define   IG_setlinewidth    0x80000520
#define   IG_setround        0x80000521
#define   IG_setclip         0x80000522
#define   IG_clearclip       0x80000523
#define   IG_greater         0x80000530
#define   IG_lesser          0x80000531

/* postscript type operators. */
#define   IG_newpath         0x80000540
#define   IG_closepath       0x80000541
#define   IG_lineto          0x80000542
#define   IG_moveto          0x80000543
#define   IG_rlineto         0x80000544
#define   IG_rmoveto         0x80000545
#define   IG_stroke          0x80000546
#define   IG_fill            0x80000547

#define   IG_justifyntext 0xa0000000
#define   IG_justifyctext 0xa1000000
#define   IG_nudgecursor  0xa2000000

/* coordinate pair functions */
#define   IG_DUP2 0x80000410
#define   IG_ADD2 0x80000411
#define   IG_SUB2 0x80000412

/* more scaled functions */
#define   IG_SBox     0x80000318
#define   IG_SBox2d   0x80000319
#define   IG_SPolygon 0x8000031a

/*
 * Font related definitions.
 */
typedef void *G_Font;

/* text justification flags */
#define FONT_JUSTIFY_HORZ_CENTER 1
#define FONT_JUSTIFY_HORZ_LEFT   2
#define FONT_JUSTIFY_HORZ_RIGHT  3
#define FONT_JUSTIFY_HORZ_MASK   3
#define FONT_JUSTIFY_VERT_CENTER 4
#define FONT_JUSTIFY_VERT_TOP    8
#define FONT_JUSTIFY_VERT_BOTTOM 12
#define FONT_JUSTIFY_VERT_MASK   12


/*
 * Miscilaneous definitions.
 */

/*
 * The angles for doing arcs and pie wedges
 * are chosen for speed. Here, I'm putting a
 * definition so that I can change this number
 * later.  This number is one full circle.
 *
 * G_AnglePrecision -- The number of bits for a 360 
 *                     angle.
 *
 * G_2pi      -- The value of 360 degrees.
 * G_3pi2     -- 270 degrees
 * G_pi       -- 180 degrees
 * G_pi2      -- 90 degrees
 * G_pi4      -- 45 degrees
 * G_pi8      -- 22.5 degrees
 *
 * G_Quadrant(ang) -- Returns which quadrant your angle
 *                    belongs to.
 * G_Octant(and)   -- Returns which octant your angle
 *                    belongs to.
 */
#define G_AnglePrecision 8
#define G_2pi (1<<G_AnglePrecision)
#define G_pi  (1<<G_AnglePrecision-1)
#define G_pi2 (1<<G_AnglePrecision-2)
#define G_pi4 (1<<G_AnglePrecision-3)
#define G_pi8 (1<<G_AnglePrecision-4)
#define G_3pi2 (G_pi+G_pi2)
#define G_Quadrant(ang) ((ang)>>G_AnglePrecision-2)
#define G_Octant(ang)   ((ang)>>G_AnglePrecision-3)


/*
 * Alert codes generated by Giraffe.
 *
 *  The giraffe library keeps track of all resources 
 * created during its life cycle.  If these are not all
 * freed when the library is closed, then it signals
 * a recoverable interrupt so that you may check your
 * code for missing pairs of open/close.
 *
 *  The format of the alert codes is as follows:
 *
 *   0666:xx:nn
 *
 *   0666 indicates that the alert comes from Giraffe.
 *   xx gives the type of object not being freed.  Check
 *      through common.h for the object numbers.  For example,
 *      GT_Layer is 1.
 *   nn shows how many of them are missing.  If this value is
 *      zero, then during a routine object check it did not
 *      pass the test.  This would indicate a bug in the library.
 *
 *    If xx is zero, then this is one of the general 
 *   alerts that I use for debugging.  The are listed in
 *   the following:
 *
 *   ALERT_BAD_OBJECT   -- Issued whenever an object is released
 *                         within the giraffe library.  Since
 *                         all objects are checked before the
 *                         library is entered, this indicates an
 *                         error in MY code.

 *   ALERT_MEMORY_LEAK  -- Indicates that somewhere a 12byte or
 *                         24 byte node has been lost.  clip list
 *                         or regions code must be bad.
 *
 *   ALERT_NOMEMORY     -- For some reason giraffe was not able
 *                         to persuade exec to give more memory.
 *                         This is probably a fatal condition.
 *
 *   ALERT_BAD_POINTERxx -- Either a 12 or 24 byte node has been
 *                          returned but does not belong to any
 *                          memory allocated by giraffe.  Indicates
 *                          bug in the library code.
 *
 *   ALERT_SEMAPHORE_ERROR  -- Indicates that a semaphore could
 *                             not allocate a new 24 byte node.
 *                             This'll probably become a fatal
 *                             error.
 *
 *   ALERT_UNDER_CONSTRUCTION  -- You've stumbled upon a function
 *                                that is not yet completed.
 *
 *   ALERT_REMAINING_CHILDREN  -- This is given by a root layer
 *                                when it is closed but not all
 *                                of its children have been closed.
 *                                This is useful for debugging
 *                                calls to G_UseLayer()/G_DropLayer().
 */

#define ALERT_GIRAFFE            0x06660000
#define ALERT_FATAL              0x80000000

#define ALERT_BAD_OBJECT         (ALERT_GIRAFFE+1)
#define ALERT_BAD_POINTER12      (ALERT_GIRAFFE+2)
#define ALERT_BAD_POINTER24      (ALERT_GIRAFFE+3)
#define ALERT_NOMEMORY           (ALERT_GIRAFFE+4)
#define ALERT_MEMORY_LEAK        (ALERT_GIRAFFE+5)
#define ALERT_SEMAPHORE_ERROR    (ALERT_GIRAFFE+6)
#define ALERT_UNDER_CONSTRUCTION (ALERT_GIRAFFE+7)
#define ALERT_REMAINING_CHILDREN (ALERT_GIRAFFE+8)

/*
 * Automatically parse the
 * pragmas and prototypes of 
 * the library.
 */
#include <giraffe_protos.h>
#include <giraffe_pragmas.h>

#endif /* giraffe.h */
