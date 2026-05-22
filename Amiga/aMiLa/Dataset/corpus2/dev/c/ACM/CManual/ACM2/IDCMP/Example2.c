/* Example2                                                   */
/* This program explains how to use the IDCMP flag MOUSEMOVE. */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* Declare a pointer to a Window structure: */ 
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  50,            /* LeftEdge    x position of the window. */
  25,            /* TopEdge     y positio of the window. */
  320,           /* Width       320 pixels wide. */
  100,           /* Height      100 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  CLOSEWINDOW|   /* IDCMPFlags  We will recieve a message when the user:  */
                 /*             selects the Close window gad, or when the */
  MOUSEMOVE,     /*             user moves the mouse.                     */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE|      /*             The window should be Active when opened. */
  
  REPORTMOUSE,   /*             Create MOUSEMOVE messages whenever this */
                 /*             window is active and the mouse is moved. */

  NULL,          /* FirstGadget No gadgets connected to this window. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "MOVE THE MOUSE", /* Title    Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  100,           /* MinWidth    We will not allow the window to become */
  50,            /* MinHeight   smaller than 100 x 50, and not bigger */
  400,           /* MaxWidth    than 400 x 200. */
  200,           /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/***********************************************************************/
/* Extra information:                                                  */
/* If we set the IDCMP flag MOUSEMOVE then we tell Intuition that we   */
/* are interested in MOUSEMOVE events. However, we must tell Intuition */
/* how and when these messages should be created. There exist two      */
/* ways to do it:                                                      */
/* 1. Set the flag FOLLOWMOUSE in the Activation field in the Gadget   */
/*    structure. We will then recieve messages whenever the gadget is  */
/*    selected and the mouse is moved.                                 */
/* 2. Set the flag REPORTMOUSE in the Flag field in the NewWindow      */
/*    structure. We will then recieve messages whenever the window is  */
/*    active and the mouse is moved. (Showed in this example.)         */
/***********************************************************************/



main()
{
  /* Boolean variable used for the while loop: */
  BOOL close_me;

  ULONG class; /* IDCMP flag. */

  SHORT x, y;  /* Position of the mouse (x,y). */

  BOOL mouse_moved;

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

  printf("Move the mouse!\n");



  close_me = FALSE;

  /* Stay in the while loop until the user has selected the Close window */
  /* gadget: */
  while( close_me == FALSE )
  {
    mouse_moved = FALSE;


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
      x     = my_message->MouseX; /* X position of the mouse. */
      y     = my_message->MouseY; /* Y position of the mouse. */


      /* After we have read it we reply as fast as possible: */
      /* REMEMBER! Do never try to read a message after you have replied! */
      /* (Some other process has maybe changed it.) */
      ReplyMsg( my_message );


      /* Check which IDCMP flag was sent: */
      switch( class )
      {
        case CLOSEWINDOW:  /* The user selected the Close window gadget! */
               close_me=TRUE;
               break;
        
        case MOUSEMOVE:    /* The user moved the mouse. */
               mouse_moved = TRUE;
               break;
      }
    }
    
    if( mouse_moved )
    {
      /* Since we recieve so many messages when the mouse is moved, we */
      /* respond first when the mouse has halted. Print out the mouse  */
      /* position relative to the top left corner of the window.       */
      printf("New position: (%d, %d)\n", x, y);
    }
  }



  /* Close the window: */
  CloseWindow( my_window );



  /* Close the Intuition Library: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}



