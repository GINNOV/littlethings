/* Example9                                                           */
/* This program explains how to use the IDCMP flag REFRESHWINDOW, and */
/* how to optimize the redrawing of the window.                       */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* Declare a pointer to a Window structure: */ 
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  50,             /* LeftEdge    x position of the window. */
  25,             /* TopEdge     y positio of the window. */
  320,            /* Width       320 pixels wide. */
  100,            /* Height      100 lines high. */
  0,              /* DetailPen   Text should be drawn with colour reg. 0 */
  1,              /* BlockPen    Blocks should be drawn with colour r. 1 */
  CLOSEWINDOW|    /* IDCMPFlags  We will recieve a message when the user */
                  /*             selects the Close window gad.           */

  REFRESHWINDOW,  /*             We will recieve a message whenever we */
                  /*             need to refresh (redraw) the window. */

  SIMPLE_REFRESH| /* Flags       Your program has to refresh the window. */
  WINDOWCLOSE|    /*             Close Gadget. */
  WINDOWDRAG|     /*             Drag gadget. */
  WINDOWDEPTH|    /*             Depth arrange Gadgets. */
  WINDOWSIZING|   /*             Sizing Gadget. */
  ACTIVATE,       /*             The window should be Active when opened. */
  NULL,           /* FirstGadget No gadgets connected to this window. */
  NULL,           /* CheckMark   Use Intuition's default CheckMark. */
  "UPDATE ME",    /* Title       Title of the window. */
  NULL,           /* Screen      Connected to the Workbench Screen. */
  NULL,           /* BitMap      No Custom BitMap. */
  100,            /* MinWidth    We will not allow the window to become */
  50,             /* MinHeight   smaller than 100 x 50, and not bigger */
  400,            /* MaxWidth    than 400 x 200. */
  200,            /* MaxHeight */
  WBENCHSCREEN    /* Type        Connected to the Workbench Screen. */
};



/*************************************************************************/
/* Extra information:                                                    */
/* We will recieve a REFRESHWINDOW message whenever we need to redraw    */
/* the window's display. If the window is a SuperBitmap window you never */
/* need to redraw it since it has its own BitMap. However, if the window */
/* is of the type SIMPLE_REFRESH or SMART_REFRESH it can happen that     */
/* your program need to redraw the window.                               */
/* SIMPLE_REFRESH: You need to update the window if it is resized,       */
/*                 pushed from behind to the front, or is moved.         */
/* SMART_REFRESH:  You need to update the display if it is resized.      */
/*                                                                       */
/* Once you recieve the message you should redraw the window. However,   */
/* before you start to redraw you need to call the function:             */
/* BeginRefresh(), and when you have finished you should call the        */
/* function EndRefresh(). (Even if you do not redraw anything, you       */
/* should call these functions.) The functions will improve the speed of */
/* the redrawing since only the trashed parts will be redrawed.          */
/*************************************************************************/



main()
{
  /* Boolean variable used for the while loop: */
  BOOL close_me;

  ULONG class;   /* IDCMP flag. */

  /* Pointer to an IntuiMessage structure: */
  struct IntuiMessage *my_message;



  /* Before we can use Intuition we need to open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* We will now try to open the window: */
  my_window = (struct Window *) OpenWindow( &my_new_window );
  
  /* Have we opened the window succesfully? */
  if(my_window == NULL)
  {
    /* Could NOT open the Window! */
    
    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We have opened the window, and everything seems to be OK. */



  close_me = FALSE;

  /* Stay in the while loop until the user has selected the Close window */
  /* gadget: */
  while( close_me == FALSE )
  {
    /* Wait until we have recieved a message: */
    Wait( 1 << my_window->UserPort->mp_SigBit );


    /* As long as we can collect messages successfully we stay in the */
    /* while-loop: */
    while(my_message = (struct IntuiMessage *) GetMsg(my_window->UserPort))
    {
      /* After we have successfully collected the message we can read */
      /* it, and save any important values which we maybe want to check */
      /* later: */
      class = my_message->Class;     /* IDCMP flag. */
      

      /* After we have read it we reply as fast as possible: */
      /* REMEMBER! Do never try to read a message after you have replied! */
      /* (Some other process has maybe changed it.) */
      ReplyMsg( my_message );


      /* Check which IDCMP flag was sent: */
      switch( class )
      {
        case CLOSEWINDOW:    /* The user selected the Close window gad. */
               close_me=TRUE;
               break;

        case REFRESHWINDOW:  /* You need to update the window. */
               printf("We need to redraw the window! (Well almost)\n");
               
               /* Start the redrawing: */
               BeginRefresh( my_window );
               
               /* Redraw the window. For example call the function       */
               /* RefreshGadgets(), DrawImage(), DrawBorder() etc...     */
               /* In this example we do not redraw anything (there does  */
               /* not exist anything to redraw). However, even if you do */
               /* nothing you need to call the functions BeginRefresh()  */
               /* and EndRefresh().                                      */
               
               /* End the redrawing: */
               EndRefresh( my_window );
               break;
      }
    }
  }



  /* Close the window: */
  CloseWindow( my_window );



  /* Close the Intuition Library: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}
