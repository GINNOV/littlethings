/*------------------------------------------------------------*/
/*   giraffe.library -- Amiga Graphics Replacement Project    */
/*          by Luke Emmert                                    */
/*    \XX/                                                    */
/*    |'' ]     file: example1.c                              */
/*    |< |      created: Feb. 5, 1996                         */
/*    \_/|     version 1                                      */
/*------------------------------------------------------------*/

#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/tasks.h>
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

/*
 * This example just shows how to create and
 * manipulate layers.  The functions used are:
 *
 *  G_OpenRootLayer()
 *  G_OpenLayer()/G_CloseLayer()
 *  G_MapLayer()
 *  G_PushLayer()/G_PullLayer()
 *  G_MoveLayer()
 *
 * Other miscillaneous functions.
 *  G_UseLayer()/G_DropLayer()
 *  G_WhichLayer()
 *
 *  G_BeginUpdate()/G_EndUpdate()
 *  G_Rectangle()/G_RectangleFill()
 * 
 *  these aren't really necessary since this
 *  example is only a single task. But I've
 *  left them in from a previous program.
 *  G_LockLayers()/G_UnlockLayers()
 */

struct Library *GiraffeBase;
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
 * Layer tags just define the dimensions of 
 * the layer.  These values are actually set
 * before the layer is created to fit inside
 * the screen.  The upper left corner of the
 * layers is (0,0) by default.
 */

struct TagItem win_tags[]={
  LA_WIDTH,            550,
  LA_HEIGHT,           400,
  TAG_END,             0
  };

/*
 * The layers for this example.
 */

G_Layer root;
G_Layer l1,l2,l3;





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

void refresh( void )
{
  union G_Point size;

  /*
   * Each layer is filled with
   * one of the three non-background
   * colors.
   *  All geometry of the layers is
   * determined at this time.
   */

  if(G_BeginUpdate(l1))
    {
      if(size.XY=G_GetLayerSize(l1))
	G_RectangleFill(l1,&gc_high,0,0,size.Coor.X,size.Coor.Y);
      G_EndUpdate(l1);
    }

  if(G_BeginUpdate(l2))
    {
      if(size.XY=G_GetLayerSize(l2))
	G_RectangleFill(l2,&gc_black,0,0,size.Coor.X,size.Coor.Y);
      G_EndUpdate(l2);
    }

  if(G_BeginUpdate(l3))
    {
      if(size.XY=G_GetLayerSize(l3))
	G_RectangleFill(l3,&gc_white,0,0,size.Coor.X,size.Coor.Y);
      G_EndUpdate(l3);
    }

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
      if(l1=G_OpenLayer(root,win_tags))
	{
	  if(l2=G_OpenLayer(root,win_tags))
	    {
	      if(l3=G_OpenLayer(root,win_tags))
		{
		  G_MapLayer(l1);
		  G_MapLayer(l2);
		  G_MapLayer(l3);
		  refresh();
	      
		  return TRUE;
		}
	      G_CloseLayer(l2);
	    }
	  G_CloseLayer(l1); 

	}
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
  G_CloseLayer(l1);
  G_CloseLayer(l2);
  G_CloseLayer(l3);

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

/*
 * This is the rubber banding function
 * for moving a window.  When it gets a
 * new position it will call G_MoveLayer().
 */

void move_window( G_Layer win, E_EGSMsgPtr event )
/* drag a window by the title bar. */
{
  int button;
  union G_Point delta;
  E_EGSMsgPtr pmsg,msg;
  struct G_Frame frame;


  G_LockLayers(win);

  delta.XY = 0;
  G_GetLayerFrame(win,&frame,TRUE);

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

  G_UnlockLayers(win);

  if(delta.XY)
    { 
      G_MoveLayer(win,frame.Left+delta.Coor.X,frame.Top+delta.Coor.Y);
      refresh();
    }
  
  
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
  BOOL        rbutton;
  ULONG       signals;
  E_EGSMsgPtr msg;
  G_Layer     focus;

  union       G_Point  xy;


  rbutton = FALSE;

  do
    {
      signals=Wait((1<<screen->Port->mp_SigBit)|SIGBREAKF_CTRL_C);

      while(msg=(E_EGSMsgPtr)GetMsg(screen->Port))
	{
	  xy.Coor.X = msg->MouseX;
	  xy.Coor.Y = msg->MouseY;
	  focus = G_WhichLayer(G_UseLayer(root),&xy);

	  if(msg->Class==E_eMOUSEBUTTONS)
	    {
	      switch(msg->Code)
		{
		case IECODE_LBUTTON:
		  if(rbutton)
		    {
		      /*
		       * The program is exited here.
		       * When both buttons are pressed
		       * starting with the right.
		       */
		      signals |= SIGBREAKF_CTRL_C;
		      break;
		    }

		  /*
		   * Left button pulls the focus
		   * to the front and then drags
		   * it about.
		   */
		  if(focus!=root)
		    {
		      G_PullLayer(focus);
		      refresh();
		      move_window(focus,msg);
		    }
		  break;

		case IECODE_RBUTTON:
		  rbutton = TRUE;

		  /*
		   * right mouse button pushes
		   * the focus to the back.
		   */
		  if(focus!=root)
		    {
		      G_PushLayer(focus);
		      refresh();
		    }
		  break;

		case IECODE_RBUTTON|IECODE_UP_PREFIX:
		  rbutton = FALSE;
		  break;
		}
	    }
	  G_DropLayer(focus);
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
      if(argc>1)
	new.Mode=argv[1];

      if(screen=(E_EScreenPtr)E_OpenScreen(&new))
	{
	  /*
	   * Set colors to mimic 
	   * standard Workbench colors.
	   */
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

/* example1.c */
