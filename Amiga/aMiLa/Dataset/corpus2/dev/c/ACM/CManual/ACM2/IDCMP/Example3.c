/* Example3                                                   */
/* This program explains how to use the IDCMP flags: NEWSIZE, */
/* ACTIVEWINDOW and INACTIVEWINDOW.                           */



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
  CLOSEWINDOW|    /* IDCMPFlags  We will recieve a message when the user: */
                  /*             selects the Close window gad, or when    */

  NEWSIZE|        /*             the user resizes the window.             */
  ACTIVEWINDOW|   /*             We will also recieve a message whenever  */
  INACTIVEWINDOW, /*             the window is activated/deactivated.     */

  SMART_REFRESH|  /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|    /*             Close Gadget. */
  WINDOWDRAG|     /*             Drag gadget. */
  WINDOWDEPTH|    /*             Depth arrange Gadgets. */
  WINDOWSIZING|   /*             Sizing Gadget. */
  ACTIVATE,       /*             The window should be Active when opened. */
  NULL,           /* FirstGadget No gadgets connected to this window. */
  NULL,           /* CheckMark   Use Intuition's default CheckMark. */
  "PLAY WITH WINDOWS", /* Title  Title of the window. */
  NULL,           /* Screen      Connected to the Workbench Screen. */
  NULL,           /* BitMap      No Custom BitMap. */
  100,            /* MinWidth    We will not allow the window to become */
  50,             /* MinHeight   smaller than 100 x 50, and not bigger */
  400,            /* MaxWidth    than 400 x 200. */
  200,            /* MaxHeight */
  WBENCHSCREEN    /* Type        Connected to the Workbench Screen. */
};



main()
{
  /* Boolean variable used for the while loop: */
  BOOL close_me;

  ULONG class; /* IDCMP flag. */

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

  printf("Play with the window!\n\n");



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
      class = my_message->Class;  /* IDCMP flag. */


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
        
        case NEWSIZE:        /* The user resized the window. */
               printf("The window was resized!\n");
               printf("Width: %d\n", my_window->Width);
               printf("Height: %d\n\n", my_window->Height);
               break;

        case ACTIVEWINDOW:   /* Window actiavted. */
               printf("Window activated!\n\n");
               break;

        case INACTIVEWINDOW: /* Window inactiavted. */
               printf("Window inactivated!\n\n");
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