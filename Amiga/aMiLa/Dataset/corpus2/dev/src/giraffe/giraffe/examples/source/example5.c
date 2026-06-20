/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: example2.c                              */
/*    |< |      created: Feb. 7, 1996                         */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

/*
 * HIGHLIGHTS
 * ----------
 *
 *  This program is designed to highlight the following 
 * properties of giraffe library.  After looking through 
 * example1, you should know about creating and manipulating
 * a layer.  This program expands on that by creating a 
 * hierarchy of layers that mimics an Intuition window.
 * The arrangement of the layers is all handled by giraffe
 * so that you can concentrate on what the layers(gadgets)
 * are supposed to do.
 *
 *  This program demonstrates both kinds of arrangement;
 * relative and group placement.  The gadgets of the window
 * are all placed relative to one another with the main
 * view expanding to fill any extra space.  The view then
 * has some dummy layers to demonstrate groups as they
 * exist in MUI and other such libraries.
 */


#include <exec/types.h>
#include <exec/libraries.h>
#include <dos/dos.h>
#include <utility/tagitem.h>
#include <devices/inputevent.h>
#include <workbench/startup.h>
#include <workbench/workbench.h>

#include <clib/icon_protos.h>

#include <egs/egs.h>
#include <egs/proto/egs.h>
#include <giraffe.h>
#include <giraffe_pragmas.h>
#include <giraffe_protos.h>

struct Library *GiraffeBase;
struct Library *EGSBase;
struct Library *IconBase;


/*
 * Here's an overview of the example:
 *
 *  The layer taglists-
 *    All the layer are described by static taglists. These
 *  describe the layout of the layers.  Only a few are 
 *  added to dynamically before opening using the TAG_MORE
 *  tag.
 *    Each window consists of 13 layers. They are:
 *  1 layer for the window itself. parent to all others.
 *     This layer arranges its children using relative
 *     dependencies.
 *  3 layers for window buttons. (close,size,depth)
 *     These layers are of fixed size and are locked into the
 *     different corners.
 *  1 layer for the main view.  This layer stretches to fit
 *     all the space available to it.  It declares some of
 *     of the window buttons as its neighbors.
 *  6 children of the main view.  These are broken into 
 *     a horizontal and vertical group with three children each.
 *     The main view is itself a horizontal group.
 *
 * The windows functions-
 *
 *  refresh_window() -- This draws into all the layers of a
 *                      window.  Each one is passed to 
 *                      G_BeginUpdate() to minimize the 
 *                      rendering.
 *
 *  refresh()        -- This function simply calls refresh_window()
 *                      for both windows created.  Since there is
 *                      no way of receiving events from the library
 *                      this function is called after every call
 *                      call to giraffe.
 *
 *  openwindow()     -- This function creates all the layers
 *                      in a window and maps them to the screen.
 *                      It then calls refresh() to draw the
 *                      window.
 *
 *  closewindow()    -- This function closes the layers of a
 *                      window.
 *
 *  openscree()      -- This function creates the root layer
 *                      and the two windows.
 * 
 *  closescreen()    -- Undoes the work of openscreen().
 *
 *
 *  The main loop functions
 *
 *  loopy()          -- This function handles the mouse events
 *                      from the screens message port to make
 *                      the program interactive.
 *
 *  size_window()    -- Called by loopy() whenever the mouse
 *                      button is pressed over the resize gadget.
 *                      simply creates a rubber band to follow
 *                      mouse movement.  When done it calls
 *                      G_SizeLayer() to change the window.
 *
 *  move_window()    -- Like size_window() except when the button
 *                      is pressed on the window, this drags the
 *                      window around.
 *
 *  Finally, there is main() which sets everything up, but
 * that's all there is to this simple little example.
 *
 */


/*
 * Default screen mode.  Another may be
 * added using either tooltypes or as
 * an argument on the command line.
 */
char screenmode[80]="EGS-DEFAULT";

struct E_NewEScreen new ={
  screenmode,
#define DEPTH 2
  DEPTH,                     /* Depth */
  0,                         /* Pad_1 */
  0,                         /* Colors */
  0,                         /* Map */
  E_DITHER_COLORS,           /* Flags */
  0,                         /* Mouse */
  E_eMOUSEBUTTONS|
    E_eMOUSEMOVE,            /* EdcmpFlags */
  0                          /* Port */
  };

/*
 * Global pointer to the screen.
 */
E_EScreenPtr screen;

/*
 * Use this pointer to keep track of where the
 * left mouse button was pressed.  When the button
 * is released then this is returned to NULL.
 */
G_Layer lbutton = NULL;


/*
 * A bunch of GCs with
 * different color pens.
 */
struct G_GC gc = G_SimpleGC(1,2);
struct G_GC gc_high  = G_SimpleGC(3,0);
struct G_GC gc_back  = G_SimpleGC(0,0);
struct G_GC gc_black = G_SimpleGC(1,0);
struct G_GC gc_white = G_SimpleGC(2,0);
struct G_GC gc_comp  = G_SimpleGC(-1,0);


/*
 * Layer taglist for creating a window.
 *
 *  Window arranges its children based
 * on relative dependencies.
 */

#define win_id  1

struct TagItem win_tags[]={
  LA_WIDTH,            550,
  LA_HEIGHT,           400,
  LA_USER_ID,          win_id,
  LA_ARRANGE_RELATIVE, TRUE,
  TAG_END,             0
  };

/*
 * All the children of the
 * window layer share these 
 * attributes.
 */


/*
 * Tags for the close button.
 *  This is a fixed size layer locked
 * into the upper left corner (default)
 * of the window.
 */

#define cb_id  2

struct TagItem cbutton_tags[]={
  LA_NOCLIP,    TRUE,
  LA_USER_ID,   cb_id,
  LA_WIDTH,     22,
  LA_HEIGHT,    19,
  TAG_END,      0
  };

/*
 * Tags for the depth
 * arrangement button.
 *  This is a fixed size button
 * locked into the upper left
 * corner of the window.
 */

#define zb_id   3

struct TagItem zbutton_tags[] = {
  LA_NOCLIP,     TRUE,
  LA_USER_ID,    zb_id,
  LA_LOCK_RIGHT, TRUE,
  LA_WIDTH,      22, 
  LA_HEIGHT,     19,
  TAG_END,       0
  };

/*
 * Tags for the right bottom
 * resize button.  The is a fixed
 * size button locked in the bottom
 * right corner of the window.
 */

#define s_id   4

struct TagItem s_tags[]={
  LA_NOCLIP,      TRUE,
  LA_USER_ID,     s_id,
  LA_LOCK_RIGHT,  TRUE,
  LA_LOCK_BOTTOM, TRUE,
  LA_WIDTH,       16,
  LA_HEIGHT,      12,
  TAG_END,        0
  };


/*
 * Main view layer tags.
 *  This layer is a horizontal group
 * with margins of 2 pixels each.  The
 * spacing on the left and bottom are
 * so that it doesn't got to the very
 * edge of the window.
 */


struct TagItem v_tags[]= {
  LA_MARGIN_LEFT,    2,
  LA_MARGIN_TOP,     2,
  LA_MARGIN_RIGHT,   2,
  LA_MARGIN_BOTTOM,  2,
  LA_SPACING_LEFT,   4,
  LA_SPACING_BOTTOM, 2,
  LA_ARRANGE_HORIZONTAL, TRUE,
  TAG_END, 0
  };

/*
 * These tags are for the children in
 * the window.  They do nothing but 
 * separate from one another by 
 * 4 pixels.
 */

#define child_id     25

struct TagItem child_tags[]={
  LA_USER_ID,        child_id,
  LA_NOCLIP,         TRUE,
  LA_MARGIN_LEFT,    2,
  LA_MARGIN_TOP,     2,
  LA_MARGIN_RIGHT,   2,
  LA_MARGIN_BOTTOM,  2,
  LA_SPACING_LEFT,   2,
  LA_SPACING_TOP,    2,
  LA_SPACING_RIGHT,  2,
  LA_SPACING_BOTTOM, 2,
  TAG_END,           0
  };


/*
 * The root layer is held in this nice
 * global variable for use at a finger-tip.
 */

G_Layer root;



struct window {
  /*
   * The bottomost layer of the
   * window.
   */
  G_Layer l;

  /*
   * The layers for the close, depth
   * and resize buttons.
   */
  G_Layer c1,c2,c3;

  /*
   * The layer for the main view
   * of the window.
   */
  G_Layer v;

  /*
   * The children of the main view.
   * There are two groups (g1&g2) which
   * have three children each.  These
   * two groups are vertical and horizontal
   * respectively.
   */
  G_Layer g1,g2,g3,g4,g5;

}win1;


/*
 * This is a simple function that refreshes
 * all the layers at once.  Since this program
 * ignores all the layer events broadcast to the
 * input device, we must refresh after every
 * call to the library and do so to each
 * layer.
 *   This is a limited way of doing refresh if
 * you're going to have a dynamic amount of layers,
 * but for the purpose of demonstration, I think
 * it is okay.
 */

void refresh_window( struct window *win )
{
  union  G_Point size;
  struct G_Frame frame;
  union  G_Point poly[6];

  /*
   * The refresh must begin at the window since
   * it is a fully clipped layer.  Then the button
   * layers which inherit clipping from their parent
   * are drawn in a nested manner.
   */

  if(G_BeginUpdate(win->l))
    {
      /*
       * Get the dimensions of the window and
       * draw a 3d border around it.
       */
      if(size.XY=G_GetLayerSize(win->l))
	{
	  G_Line(win->l,&gc_black,0,size.Coor.Y-1,size.Coor.X-1,size.Coor.Y-1);
	  G_Line(win->l,&gc_black,size.Coor.X-1,0,size.Coor.X-1,size.Coor.Y-1);
	  G_Line(win->l,&gc_white,0,0,size.Coor.X-1,0);
	  G_Line(win->l,&gc_white,0,0,0,size.Coor.Y-1);
	  
	  /*
	   * Here we get the dimensions of the
	   * frame relative to the window (parent)
	   * and draw an inversed 3d rectangle.
	   */
	  if(G_GetLayerFrame(win->v,&frame,FALSE))
	    {
	      G_Line(win->l,&gc_black,frame.Left-1,frame.Top-1,
		     frame.Left+frame.Width,
		     frame.Top-1);
	      G_Line(win->l,&gc_black,frame.Left-1,frame.Top-1,
		     frame.Left-1,
		     frame.Top+frame.Height);
	      G_Line(win->l,&gc_white,frame.Left-1,
		     frame.Top+frame.Height,
		     frame.Left+frame.Width,
		     frame.Top+frame.Height);
	      G_Line(win->l,&gc_white,frame.Left+frame.Width,
		     frame.Top-1,
		     frame.Left+frame.Width,
		     frame.Top+frame.Height);
	    }
	}
      
      /*
       * The close button is drawn during the
       * windows update as described. Just draw
       * a bunch of lines to look like Intuition.
       */
      if(G_BeginUpdate(win->c1))
	{
	  if(size.XY=G_GetLayerSize(win->c1))
	    {
	      G_Line(win->c1,&gc_black,0,size.Coor.Y-1,size.Coor.X-1,size.Coor.Y-1);
	      G_Line(win->c1,&gc_black,size.Coor.X-1,0,size.Coor.X-1,size.Coor.Y-1);
	      G_Line(win->c1,&gc_white,0,0,size.Coor.X-1,0);
	      G_Line(win->c1,&gc_white,0,0,0,size.Coor.Y-1);
	    }
	  G_EndUpdate(win->c1);
	}
      
      /*
       * Next comes the depth 
       * arrange gadget.
       */
      if(G_BeginUpdate(win->c2))
	{
	  if(size.XY=G_GetLayerSize(win->c2))
	    {
	      G_Line(win->c2,&gc_black,0,size.Coor.Y-1,size.Coor.X-1,size.Coor.Y-1);
	      G_Line(win->c2,&gc_black,size.Coor.X-1,0,size.Coor.X-1,size.Coor.Y-1);
	      G_Line(win->c2,&gc_white,0,0,size.Coor.X-1,0);
	      G_Line(win->c2,&gc_white,0,0,0,size.Coor.Y-1);
	    }
	  
	  G_EndUpdate(win->c2);
	}
      
      /*
       * And finally the resize.
       */
      if(G_BeginUpdate(win->c3))
	{
	  if(size.XY=G_GetLayerSize(win->c3))
	    {
	      G_Line(win->c3,&gc_black,0,size.Coor.Y-1,size.Coor.X-1,size.Coor.Y-1);
	      G_Line(win->c3,&gc_black,size.Coor.X-1,0,size.Coor.X-1,size.Coor.Y-1);
	      G_Line(win->c3,&gc_white,0,0,size.Coor.X-1,0);
	      G_Line(win->c3,&gc_white,0,0,0,size.Coor.Y-1);
	    }
	  G_EndUpdate(win->c3);
	}
      
      /*
       *  When complete we release the layers
       * and return them to their normal 
       * state.
       */
      G_EndUpdate(win->l);
    }

  /*
   * Now to draw the main view.
   *  Note that this is outside the refreshing
   * of win->l.  This is because each of these is
   * independent of the other.  The other reason
   * is that this won't be refreshed when the
   * children have their order changed.  Go ahead
   * and try.  It's what I had originally, but since
   * the screen didn't refresh, I changed it.
   */
  if(G_BeginUpdate(win->v))
    {
      if(G_BeginUpdate(win->g1))
	{
	  if(size.XY=G_GetLayerSize(win->g1))
	    {
	      G_RectangleFill(win->g1,&gc_black,size.Coor.X/3,size.Coor.Y/3,size.Coor.X/3,size.Coor.Y/3);
	      G_Rectangle(win->g1,&gc_white,0,0,size.Coor.X,size.Coor.Y);
	    }
	  G_EndUpdate(win->g1);
	}
      
      if(G_BeginUpdate(win->g2))
	{
	  if(size.XY=G_GetLayerSize(win->g2))
	    {
	      G_Wedge(win->g2,&gc_black,size.Coor.X/2,size.Coor.Y/2,size.Coor.X/6,size.Coor.Y/6,0,G_2pi);
	      G_Rectangle(win->g2,&gc_white,0,0,size.Coor.X,size.Coor.Y);
	    }
	  
	  G_EndUpdate(win->g2);
	}
      
      if(G_BeginUpdate(win->g3))
	{
	  if(size.XY=G_GetLayerSize(win->g3))
	    {
	      poly[0].Coor.X = size.Coor.X/2;
	      poly[0].Coor.Y = size.Coor.Y/3;
	      poly[1].Coor.X = (2*size.Coor.X)/3;
	      poly[1].Coor.Y = (2*size.Coor.Y)/3;
	      poly[2].Coor.X = size.Coor.X/3;
	      poly[2].Coor.Y = (2*size.Coor.Y)/3;
	      G_Polygon(win->g3,&gc_black,poly,3);
	      G_Rectangle(win->g3,&gc_white,0,0,size.Coor.X,size.Coor.Y);
	    }
	  
	  G_EndUpdate(win->g3);
	}
      
      if(G_BeginUpdate(win->g4))
	{
	  if(size.XY=G_GetLayerSize(win->g4))
	    {
	      poly[0].Coor.X = size.Coor.X/2;
	      poly[0].Coor.Y = size.Coor.Y/3;
	      poly[1].Coor.X = (2*size.Coor.X)/3;
	      poly[1].Coor.Y = (2*size.Coor.Y)/3;
	      poly[2].Coor.X = size.Coor.X/3;
	      poly[2].Coor.Y = (4*size.Coor.Y)/9;
	      poly[3].Coor.X = (2*size.Coor.X)/3;
	      poly[3].Coor.Y = (4*size.Coor.Y)/9;
	      poly[4].Coor.X = size.Coor.X/3;
	      poly[4].Coor.Y = (2*size.Coor.Y)/3;
	      G_Polygon(win->g4,&gc_black,poly,5);
	      G_Rectangle(win->g4,&gc_white,0,0,size.Coor.X,size.Coor.Y);
	    }
	  
	  G_EndUpdate(win->g4);
	}
      
      if(G_BeginUpdate(win->g5))
	{
	  if(size.XY=G_GetLayerSize(win->g5))
	    {
	      poly[0].Coor.X = (6*size.Coor.X)/15;
	      poly[0].Coor.Y = size.Coor.Y/3;
	      poly[1].Coor.X = (9*size.Coor.X)/15;
	      poly[1].Coor.Y = size.Coor.Y/3;
	      poly[2].Coor.X = (2*size.Coor.X)/3;
	      poly[2].Coor.Y = size.Coor.Y/2;
	      poly[3].Coor.X = (9*size.Coor.X)/15;
	      poly[3].Coor.Y = (2*size.Coor.Y)/3;
	      poly[4].Coor.X = (6*size.Coor.X)/15;
	      poly[4].Coor.Y = (2*size.Coor.Y)/3;
	      poly[5].Coor.X = size.Coor.X/3;
	      poly[5].Coor.Y = size.Coor.Y/2;
	      G_Polygon(win->g5,&gc_black,poly,6);
	      G_Rectangle(win->g5,&gc_white,0,0,size.Coor.X,size.Coor.Y);
	    }
	  
	  G_EndUpdate(win->g5);
	}
      
      G_EndUpdate(win->v);
    }
  
  return;
}

void refresh( void )
{
  
  /*
   * Refresh each of the windows
   * separately.
   */
  refresh_window(&win1);

  return;
}


/*
 * Open an EGS screen and create all
 * of the layers.
 */

int openwindow( struct window *win, int left, int top )
{
  struct TagItem TagList[10];

  TagList[0].ti_Tag  = LA_LEFT;
  TagList[0].ti_Data = left;
  TagList[1].ti_Tag  = LA_TOP;
  TagList[1].ti_Data = top;
  TagList[2].ti_Tag  = TAG_MORE;
  TagList[2].ti_Data = (ULONG)win_tags;

  if(win->l=G_OpenLayer(root,TagList))
    {
      win->c1=G_OpenLayer(win->l,cbutton_tags);
      win->c2=G_OpenLayer(win->l,zbutton_tags);
      win->c3=G_OpenLayer(win->l,s_tags);
      
      /*
       * The main view of the window stretches
       * to the edges of the buttons.  These tags
       * must be created dynamically as the layers
       * to which they attach have only just been
       * created.
       */
      TagList[0].ti_Tag  = LA_TOLEFT;
      TagList[0].ti_Data = NULL;
      TagList[1].ti_Tag  = LA_TOTOP;
      TagList[1].ti_Data = (ULONG)win->c1;
      TagList[2].ti_Tag  = LA_TORIGHT;
      TagList[2].ti_Data = (ULONG)win->c3;
      TagList[3].ti_Tag  = LA_TOBOTTOM;
      TagList[3].ti_Data = NULL;
      TagList[4].ti_Tag  = TAG_MORE;
      TagList[4].ti_Data = (ULONG)v_tags;
      win->v = G_OpenLayer(win->l,TagList);

      /*
       * The first child is a vertical 
       * group and the second is a horizontal
       * group.  Remember that they exist in the
       * list in opposite order that they were 
       * created.  This means that when the
       * window opens expect to see the 
       * vertical group on the right(end of list)
       * while the horizontal group is on the
       * left (head of list).
       */
      win->g1 = G_OpenLayer(win->v,child_tags);
      win->g2 = G_OpenLayer(win->v,child_tags);
      win->g3 = G_OpenLayer(win->v,child_tags);
      win->g4 = G_OpenLayer(win->v,child_tags);
      win->g5 = G_OpenLayer(win->v,child_tags);

      /*
       * If all the layers were 
       * successfully created, then
       * map them to the screen.
       */
      if(win->c1&&win->c2&&win->c3&&
	 win->v &&
	 win->g1 && win->g2 && win->g3 && win->g4 && win->g5)
	{
	  G_MapLayer(win->l);

	  /*
	   * Have to do a refresh in order
	   * to see anything.
	   */
	  refresh();
	  return TRUE;

	}
      else printf("ERROR: child layer failed to open.\n",0);

      /*
       * Oooops, we failed.  Well,
       * at least clean up before
       * leaving.
       *  Note passing a NULL pointer
       * to the library is trapped, so
       * we don't have to worry about
       * which layer didn't open.
       */
      G_CloseLayer(win->c1);
      G_CloseLayer(win->c2);
      G_CloseLayer(win->c3);
      G_CloseLayer(win->v);
      G_CloseLayer(win->g1);
      G_CloseLayer(win->g2);
      G_CloseLayer(win->g3);
      G_CloseLayer(win->g4);
      G_CloseLayer(win->g5);

      G_CloseLayer(win->l);
    }
  else printf("ERROR: window failed to open.\n",0);

  return FALSE;
}


void closewindow( struct window *win )
{
  G_UnmapLayer(win->l);

  /*
   * Close all of the layers.
   * Actually, we should be able
   * to close in any order.
   *  Except for the root.  It will
   * signal an Alert if it still
   * has open children.  This is
   * useful for debugging.
   */
  G_CloseLayer(win->c1);
  G_CloseLayer(win->c2);
  G_CloseLayer(win->c3);
  G_CloseLayer(win->g1);
  G_CloseLayer(win->g2);
  G_CloseLayer(win->g3);
  G_CloseLayer(win->g4);
  G_CloseLayer(win->g5);
  G_CloseLayer(win->v);
  G_CloseLayer(win->l);

  return;
}

int openscreen( void )
{
  /*
   * Match the window tags to the
   * screen size.
   */
  win_tags[0].ti_Data = screen->Map->Width/2;
  win_tags[1].ti_Data = screen->Map->Height/4;

  /*
   * Open the root and two
   * windows.
   */
  if(root=(G_Layer)G_OpenRootLayer(screen->Map,NULL))
    {
      if(openwindow(&win1,screen->Map->Width/5,screen->Map->Height/5))
	return TRUE;


      G_CloseLayer(root);
    }
  else printf("ERROR: could not open root layer.\n",0);

  return FALSE;
}

/*
 * Close the screen before
 * leaving.
 */

void closescreen( void )
{
  G_DropLayer(lbutton);

  closewindow(&win1);
  /*
   * I like to map the bottom
   * layer so that the tree gets
   * unmapped all at once.
   */

  G_CloseLayer(root);
  return;
}



/*
 * For rubber banding the window.
 */


void xor_window( E_EBitMapPtr bitmap, struct G_Frame *frame, union G_Point offset )
/* Draws XOR outline of window.  used for rubber-banding. */
{
  offset.Coor.X += frame->Left;
  offset.Coor.Y += frame->Top;

  G_Rectangle(bitmap,&gc_comp,offset.Coor.X,offset.Coor.Y,
	      frame->Width,
	      frame->Height);

  return;
}

void move_window( struct window *win, E_EGSMsgPtr event )
/* drag a window by the title bar. */
{
  int button;
  union G_Point delta;
  E_EGSMsgPtr pmsg,msg;
  struct G_Frame frame;


  G_LockLayers(win->l);

  delta.XY = 0;
  G_GetLayerFrame(win->l,&frame,TRUE);

  xor_window(screen->Map,&frame,delta);

  for(button=1;button;)
    {
      Wait(1<<screen->Port->mp_SigBit);

      pmsg=NULL;
      while(msg=(E_EGSMsgPtr)GetMsg(screen->Port))
	{
	  if(msg->Class==E_eMOUSEMOVE)
	      { pmsg=msg;
		while(msg=(E_EGSMsgPtr)GetMsg(screen->Port))
		  { if(msg->Class!=E_eMOUSEMOVE)break;
		    ReplyMsg(pmsg);
		    pmsg=msg;
		  }

		xor_window(screen->Map,&frame,delta);
		delta.Coor.X = pmsg->MouseX-event->MouseX;
		delta.Coor.Y = pmsg->MouseY-event->MouseY;
		xor_window(screen->Map,&frame,delta);

		ReplyMsg(pmsg);
	      }

	  if(msg)
	    { if(msg->Class==E_eMOUSEBUTTONS)
		{ if(event->Code==IECODE_UP_PREFIX|IECODE_LBUTTON)
		    { button = 0; break;
		    }
		}
	      ReplyMsg(msg);
	    }
	}
    }	  
  xor_window(screen->Map,&frame,delta);
  /* make changes in layer here. */

  G_UnlockLayers(win->l);

  if(delta.XY)
    {
      G_MoveLayer(win->l,frame.Left+delta.Coor.X,frame.Top+delta.Coor.Y);
      refresh();
    }
  
  return;
}


void size_window( struct window *win, E_EGSMsgPtr event )
/* Resize the window at one of the edges. */
{
  int button;
  struct G_Rectangle band,bounds;
  ULONG width,height;
  E_EGSMsgPtr pmsg,msg;

  G_LockLayers(win->l);

  G_GetLayerBounds(win->l,&bounds);
  band   = bounds;
  width  = G_RectWidth(bounds);
  height = G_RectHeight(bounds);

  G_Rectangle(screen->Map,&gc_comp,
	                  band.Min.Coor.X,
	                  band.Min.Coor.Y,
	                  G_RectWidth(band),
	                  G_RectHeight(band));

  for(button=1;button;)
    {
      Wait(1<<screen->Port->mp_SigBit);

      pmsg=NULL;
      while(msg=(E_EGSMsgPtr)GetMsg(screen->Port))
	{
	  if(msg->Class==E_eMOUSEMOVE)
	      { pmsg=msg;
		while(msg=(E_EGSMsgPtr)GetMsg(screen->Port))
		  { if(msg->Class!=E_eMOUSEMOVE)break;
		    ReplyMsg(pmsg);
		    pmsg=msg;
		  }

		G_Rectangle(screen->Map,&gc_comp,
			                band.Min.Coor.X,
			                band.Min.Coor.Y,
			                G_RectWidth(band),
			                G_RectHeight(band));

		band.Max.Coor.X = bounds.Max.Coor.X +
		  pmsg->MouseX-event->MouseX;
		band.Max.Coor.Y = bounds.Max.Coor.Y + 
		  pmsg->MouseY-event->MouseY;

		G_Rectangle(screen->Map,&gc_comp,
			                band.Min.Coor.X,
			                band.Min.Coor.Y,
			                G_RectWidth(band),
 			                G_RectHeight(band));

		ReplyMsg(pmsg);
	      }

	  if(msg)
	    { if(msg->Class==E_eMOUSEBUTTONS)
		{ if(event->Code==IECODE_UP_PREFIX|IECODE_LBUTTON)
		    { button = 0; break;
		    }
		}
	      ReplyMsg(msg);
	    }
	}
    }	  
  G_Rectangle(screen->Map,&gc_comp,
                          band.Min.Coor.X,
	                  band.Min.Coor.Y,
	                  G_RectWidth(band),
	                  G_RectHeight(band));
  /* make changes in layer here. */

  G_UnlockLayers(win->l);
  G_SizeLayer(win->l,G_RectWidth(band),
 		     G_RectHeight(band));
  refresh();

  return;
}  

/*
 * The main loop of the program.
 * It simply waits for button events
 * and either works the resize buttons
 * or signals a close using
 * SIGBREAKF_CTRL_C.
 */

void loopy( void )
{
  unsigned long signals;
  E_EGSMsgPtr msg;
  G_Layer focus;
  struct G_Frame frame;
  union G_Point xy,size;

  G_Layer win;

  do
    {
      signals = Wait(SIGBREAKF_CTRL_C | (1<<screen->Port->mp_SigBit));
      while(msg=(E_EGSMsgPtr)GetMsg(screen->Port))
	{
	  switch(msg->Class)
	    {
	    case E_eMOUSEBUTTONS:
	      xy.Coor.X = msg->MouseX;
	      xy.Coor.Y = msg->MouseY;

	      if(focus = G_WhichLayer(G_UseLayer(root),&xy))
		{
		  switch(msg->Code)
		    {
		    case IECODE_LBUTTON:
		      if(lbutton)G_DropLayer(lbutton);
		      
		      switch(G_GetLayerId(focus))
			{
			case win_id:
			  if(focus==win1.l)
			    move_window(&win1,msg);
			  break;

			case s_id:
			  if(focus==win1.c3)
			    size_window(&win1,msg);
			  break;

			case child_id:
			  G_PullLayer(focus);
			  refresh();
			  break;

			case 0:
			  break;

			default:
			  if(size.XY=G_GetLayerSize(focus))
			    G_RectangleFill(focus,&gc_comp,1,1,size.Coor.X-2,size.Coor.Y-2);
			  lbutton = G_UseLayer(focus);
			  break;
			}
		      break;
		      
		    case IECODE_UP_PREFIX|IECODE_LBUTTON:
		      if(lbutton&&(size.XY=G_GetLayerSize(lbutton)))
			G_RectangleFill(lbutton,&gc_comp,1,1,size.Coor.X-2,size.Coor.Y-2);
		      
		      switch(G_GetLayerId(lbutton))
			{
			case cb_id:
			  if(focus==lbutton)
			    Signal(FindTask(NULL),SIGBREAKF_CTRL_C);
			  break;
			  
			case zb_id:
			  if(focus==lbutton)
			    if(win=G_GetLayerParent(lbutton))
			      {
				G_CycleLayer(win);
				refresh();
				G_DropLayer(win);
			      }
			  break;

			  
			}
		      G_DropLayer(lbutton);
		      lbutton = NULL;
		  
		      break;

		    case IECODE_RBUTTON:
		      if(G_GetLayerId(focus)==child_id)
			{
			  G_PushLayer(focus);
			  refresh();
			}
		      break;
			

		    }
		  G_DropLayer(focus);
		}
	      break;
	    }
	  ReplyMsg(msg);
	}
    }while(!(signals&SIGBREAKF_CTRL_C));
  return;
}


/*
 * Main function. Creates all 
 * the resources, then calls
 * loopy() to handle any 
 * events from the user.
 */

void main( int argc, char **argv )
{
  struct WBStartup *wbmsg;
  struct DiskObject *icon;
  char  *string;

  if(argc)
    {
      if(argc>1)
	strcpy(screenmode,argv[1]);
    }
  else
    {
      wbmsg=(struct WBStartup *)argv;
      if(IconBase=(struct Library *)OpenLibrary("icon.library",0))
	{
	  if(icon=GetDiskObjectNew(wbmsg->sm_ArgList[0].wa_Name))
	    {
	      if(icon->do_ToolTypes)
		{
		  if(string=FindToolType(icon->do_ToolTypes,"MODE"))
		    strcpy(screenmode,string);
		}
	      FreeDiskObject(icon);
	    }
	  CloseLibrary(IconBase);
	}
      else printf("couldn't open icon library.\n",0);
    }

  if(EGSBase=(struct Library *)OpenLibrary("egs.library",0))
    {

      /*
       * If you don't have an EGS Spectrum, then
       * you'll have to give a screen mode on the
       * command line.
       * ~>example2 "Screen Mode Name"
       *
       * Sorry about this, but I can't get
       * E_OpenScreenTagList() to work at
       * the moment.
       */
      if(argc>1)
	new.Mode=argv[1];

      if(screen=(E_EScreenPtr)E_OpenScreen(&new))
	{
	  /*
	   * Set the colors to mimic standard
	   * intuition colors. (gray,black,white,blue)
	   */
	  E_SetRGB8(screen,0,0x00c0,0x00c0,0x00c0);
	  E_SetRGB8(screen,1,0x0000,0x0000,0x0000);
	  E_SetRGB8(screen,2,0x00ff,0x00ff,0x00ff);
	  E_SetRGB8(screen,3,0x0000,0x0000,0xffff);

	  if(GiraffeBase=(void *)OpenLibrary("giraffe.library",0))
	    {
	      if(openscreen())
		{
		  loopy();
		  closescreen();
		}

	      CloseLibrary(GiraffeBase);
	    }
	  else printf("ERROR: giraffe library failed to open.\n",0);
	  E_CloseScreen(screen);
	}
      else printf("ERROR: could not open an EGS screen.\n",0);

      CloseLibrary(EGSBase);
    }
  else printf("ERROR: could not open EGS.\n",0);

  return;
}

/* example3.c */
