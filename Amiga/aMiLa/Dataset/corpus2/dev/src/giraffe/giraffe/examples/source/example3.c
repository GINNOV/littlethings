/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: example3.c                              */
/*    |< |      created: Feb. 5, 1996                         */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

/*
 * This example program shows the use of
 * a smart refresh layer.  Almost everything is
 * the same of example2, except that there aren't
 * so many layers and the smiley face is drawn
 * using the the G_Wedge() and G_Arc() functions.
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

void *GiraffeBase;
struct Library *EGSBase;
struct Library *IconBase;

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
  E_eMOUSEBUTTONS | 
    E_eMOUSEMOVE,            /* EdcmpFlags */
  0                          /* Port */
  };

/*
 * Global pointer to the screen.
 */
E_EScreenPtr screen;

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

#define win_id     1

struct TagItem win_tags[]={
  LA_WIDTH,            550,
  LA_HEIGHT,           400,
  LA_USER_ID,          win_id,
  LA_ARRANGE_RELATIVE, TRUE,
  TAG_END,   0
  };

/*
 * All the children of the
 * window layer share these 
 * attributes.
 */

struct TagItem child_tags[]={
  LA_NOCLIP,         TRUE,
  TAG_END, 0
  };

/*
 * Tags for the close button.
 */

#define cb_id  2

struct TagItem cbutton_tags[]={
  LA_USER_ID, cb_id,
  LA_WIDTH,   22,
  LA_HEIGHT,  19,
  TAG_MORE,   (ULONG)child_tags
  };

/*
 * Tags for the depth
 * arrangement button.
 */

#define zb_id   3

struct TagItem zbutton_tags[] = {
  LA_USER_ID,    zb_id,
  LA_LOCK_RIGHT, TRUE,
  LA_WIDTH,      22, 
  LA_HEIGHT,     19,
  TAG_MORE,      (ULONG)child_tags
  };

/*
 * Tags for the right bottom
 * resize button.
 */

#define s_id   4

struct TagItem s_tags[]={
  LA_USER_ID,     s_id,
  LA_LOCK_RIGHT,  TRUE,
  LA_LOCK_BOTTOM, TRUE,
  LA_WIDTH,       16,
  LA_HEIGHT,      12,
  TAG_MORE,       (ULONG)child_tags
  };


/*
 * Main view layer tags.
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
 * The layers for creating a 
 * window.
 */

G_Layer root;

struct window {
  G_Layer l,c1,c2,c3;
  G_Layer v;
}win1,win2;


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
  union G_Point size;
  struct G_Frame frame;
  int radius;

  /*
   * Just draw a 
   * gray background in
   * which the window
   * lives.
   */

  if(G_BeginUpdate(win->l))
    {
      if(size.XY=G_GetLayerSize(win->l))
	{
	  G_Line(win->l,&gc_black,0,size.Coor.Y-1,size.Coor.X-1,size.Coor.Y-1);
	  G_Line(win->l,&gc_black,size.Coor.X-1,0,size.Coor.X-1,size.Coor.Y-1);
	  G_Line(win->l,&gc_white,0,0,size.Coor.X-1,0);
	  G_Line(win->l,&gc_white,0,0,0,size.Coor.Y-1);
	  
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
      
      if(G_BeginUpdate(win->c1))
	{
	  if(size.XY=G_GetLayerSize(win->c1))
	    {
	      G_Line(win->c1,&gc_black,0,size.Coor.Y-1,size.Coor.X-1,size.Coor.Y-1);
	      G_Line(win->c1,&gc_black,size.Coor.X-1,0,size.Coor.X-1,size.Coor.Y-1);
	      G_Line(win->c1,&gc_white,0,0,size.Coor.X-1,0);
	      G_Line(win->c1,&gc_white,0,0,0,size.Coor.Y-1);

	      G_Rectangle(win->c1,&gc_black,(3*size.Coor.X)/8,
			                    size.Coor.Y/4,
			                    size.Coor.X/4,
			                    size.Coor.Y/2);
	    }
	  G_EndUpdate(win->c1);
	}
      
      if(G_BeginUpdate(win->c2))
	{
	  if(size.XY=G_GetLayerSize(win->c2))
	    {
	      G_Line(win->c2,&gc_black,0,size.Coor.Y-1,size.Coor.X-1,size.Coor.Y-1);
	      G_Line(win->c2,&gc_black,size.Coor.X-1,0,size.Coor.X-1,size.Coor.Y-1);
	      G_Line(win->c2,&gc_white,0,0,size.Coor.X-1,0);
	      G_Line(win->c2,&gc_white,0,0,0,size.Coor.Y-1);

	      G_Rectangle(win->c2,&gc_black,size.Coor.X/4,
			                    size.Coor.Y/4,
			                    size.Coor.X/2,
			                    size.Coor.Y/2);
	      G_Rectangle(win->c2,&gc_black,size.Coor.X/2,
			                    size.Coor.Y/2,
			                    size.Coor.X/2,0);
	    }
	  
	  G_EndUpdate(win->c2);
	}
      
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
      
      if(G_BeginUpdate(win->v))
	{
	  if(size.XY=G_GetLayerSize(win->v))
	    {
	      radius = (size.Coor.X<size.Coor.Y?size.Coor.X:size.Coor.Y)/2;
	      G_Wedge(win->v,&gc_white,size.Coor.X/2,size.Coor.Y/2,radius,radius,0,G_2pi);
	      G_Arc(win->v,&gc_black,size.Coor.X/2,size.Coor.Y/2,radius,radius,0,G_2pi);
	      
	      G_Wedge(win->v,&gc_black,size.Coor.X/2-radius/3,size.Coor.Y/2-radius/3,radius/5,radius/5,0,G_2pi);
	      G_Wedge(win->v,&gc_black,size.Coor.X/2+radius/3,size.Coor.Y/2-radius/3,radius/5,radius/5,0,G_2pi);

	      gc_black.LineWidth = radius/8;
	      G_Arc(win->v,&gc_black,size.Coor.X/2,size.Coor.Y/2,(2*radius)/3,(2*radius)/3,G_pi8,G_pi-G_pi8);
	      gc_black.LineWidth = 0;

	    }


	  G_EndUpdate(win->v);
	}

      G_EndUpdate(win->l);
    }
  return;
}

void refresh( void )
{
  
/*  if(G_BeginUpdate(root))
    {
      G_RectangleFill(root,&gc_gray,0,0,2000,2000);
      G_EndUpdate(root);
    } */

  refresh_window(&win1);
  refresh_window(&win2);

  return;
}


/*
 * Open an EGS screen and create all
 * of the layers.
 */

void *UtilityBase;

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
       * to the edges of the buttons.
       */
      TagList[0].ti_Tag  = LA_TOLEFT;
      TagList[0].ti_Data = NULL;
      TagList[1].ti_Tag  = LA_TOTOP;
      TagList[1].ti_Data = (ULONG)win->c1;
      TagList[2].ti_Tag  = LA_TORIGHT;
      TagList[2].ti_Data = (ULONG)win->c3;
      TagList[3].ti_Tag  = LA_TOBOTTOM;
      TagList[3].ti_Data = NULL;


      /*
       * Here I make one of the view
       * layers smart while the other is
       * not.  Note, the windows and their
       * gadgets are NOT smart refreshed, just
       * the interior area of the window.
       */
      if(win==&win1)
	{
	  TagList[4].ti_Tag  = TAG_MORE;
	  TagList[4].ti_Data = (ULONG)v_tags;
	}
      else
	{
	  TagList[4].ti_Tag  = LA_REFRESH_SMART;
	  TagList[4].ti_Data = TRUE;
	  TagList[5].ti_Tag  = TAG_MORE;
	  TagList[5].ti_Data = (ULONG)v_tags;
	}

      win->v = G_OpenLayer(win->l,TagList);

      /*
       * If all the layers were 
       * successfully created, then
       * map them to the screen.
       */
      if(win->c1&&win->c2&&win->c3&&win->v)
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
  win_tags[1].ti_Data = screen->Map->Height/2;

  if(root=(G_Layer)G_OpenRootLayer(screen->Map,NULL))
    {
      if(openwindow(&win1,screen->Map->Width/5,screen->Map->Height/5))
	{
	  if(openwindow(&win2,screen->Map->Width/3,screen->Map->Height/4))
	    return TRUE;

	  closewindow(&win1);
	}
		

      printf("closing root layer.\n",0);
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
  printf("closing screen\n",0);


  G_DropLayer(lbutton);


  closewindow(&win1);
  closewindow(&win2);
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
    G_MoveLayer(win->l,frame.Left+delta.Coor.X,frame.Top+delta.Coor.Y);
  
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
  G_MoveSizeLayer(win->l,band.Min.Coor.X,
		         band.Min.Coor.Y,
 		         G_RectWidth(band),
 		         G_RectHeight(band));

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
			  else 
			    move_window(&win2,msg);

			  refresh();
			  break;

			case s_id:
			  if(focus==win1.c3)
			    size_window(&win1,msg);
			  else
			    size_window(&win2,msg);
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
  int i;
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
      if(argc>1)
	new.Mode=argv[1];

      if(screen=(E_EScreenPtr)E_OpenScreen(&new))
	{
	  E_SetRGB8(screen,0,0x00c0,0x00c0,0x00c0);
	  E_SetRGB8(screen,1,0x0000,0x0000,0x0000);
	  E_SetRGB8(screen,2,0x00ff,0x00ff,0x00ff);
	  E_SetRGB8(screen,3,0x0000,0x0000,0xffff);

	  if(GiraffeBase=(void *)OpenLibrary("giraffe.library",0))
	    {
	      printf("library has been opened...\n",0);
	
	      if(openscreen())
		{
		  loopy();
		  closescreen();
		}

	      CloseLibrary(GiraffeBase);
	      printf("library has been closed.\n",0);
	    }
	  else printf("library was not opened.\n",0);
	  CloseLibrary(EGSBase);
	}
      E_CloseScreen(screen);
    }
  return;
}

/* example3.c */
