/* Example11                                                          */
/* This program will open a normal window which is connected to the   */
/* Workbench Screen. The window will use all System Gadgets, and will */
/* close first when the user has selected the System gadget Close     */
/* window. Inside the window we have put a Proportional gadget where  */
/* the knob can be moved both horizontally and vertically.            */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* THE PROPORTIONAL GADGET's STRUCTURES: */

/* We need to declare an Image structure for the knob, but since */
/* Intuition will take care of the size etc of the knob, we do not need */
/* to initialize the Image structure: */
struct Image my_image;


struct PropInfo my_prop_info=
{
  FREEHORIZ|      /* Flags, the knob should be able to movew both */
  FREEVERT|       /* horizontally and vertically. */
  AUTOKNOB,       /* Intuition should take care of the knob image. */
  0,              /* HorizPot, start position of the knob. */
  0,              /* VertPot, start position of the knob. */
  MAXBODY * 1/32, /* HorizBody, 32 steps. */
  MAXBODY * 1/10, /* VertBody, 10 steps. */

  /* These variables are initialized and maintained by Intuition: */

  0,              /* CWidth */
  0,              /* CHeight */
  0, 0,           /* HPotRes, VPotRes */
  0,              /* LeftBorder */
  0               /* TopBorder */
};


struct Gadget my_gadget=
{
  NULL,            /* NextGadget, no more gadgets in the list. */
  10,              /* LeftEdge, 10 pixels out. */
  20,              /* TopEdge, 20 lines down. */
  -20,             /* Width, always 20 pixels less than the wind. size. */
  -40,             /* Height, always 40 lines less than the wind. size. */
  GADGHCOMP|       /* Flags, complement the colours. */
  GRELWIDTH|       /* Width describes the size relative to the window. */
  GRELHEIGHT,      /* Height describes the size relative to the window*/
  GADGIMMEDIATE|   /* Activation, our program will recieve a message */
  RELVERIFY,       /* when the user has selected this gadget, and when */
                   /* the user has released it. */ 
  PROPGADGET,      /* GadgetType, a Proportional gadget. */
  (APTR) &my_image,/* GadgetRender, a pointer to our Image structure. */
                   /* (Intuition will take care of the knob image) */
                   /* (See chapter 3 GRAPHICS for more information) */
  NULL,            /* SelectRender, NULL since we do not supply the */
                   /* gadget with an alternative image. */
  NULL,            /* GadgetText, no text. */
  NULL,            /* MutualExclude, no mutual exclude. */
  (APTR) &my_prop_info, /* SpecialInfo, pointer to a PropInfo structure. */
  0,               /* GadgetID, no id. */
  NULL             /* UserData, no user data connected to the gadget. */
};



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
  CLOSEWINDOW|   /* IDCMPFlags  The window will give us a message if the */
                 /*             user has selected the Close window gad, */
  GADGETDOWN|    /*             or a gadget has been pressed on, or */
  GADGETUP,      /*             a gadge has been released. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  &my_gadget,    /* FirstGadget A pointer to the String gadget. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "Proportional Window", /* Title Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  100,           /* MinWidth    We will not allow the window to become */
  100,           /* MinHeight   smaller than 100 x 100, and not bigger */
  640,           /* MaxWidth    than 640 x 200. */
  200,           /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



main()
{
  /* Boolean variable used for the while loop: */
  BOOL close_me;
 
  /* Declare a variable in which we will store the IDCMP flag: */
  ULONG class;

  /* Declare a pointer to an IntuiMessage structure: */
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

    /* We have now recieved one or more messages. */

    /* Since we may recieve several messages we stay in the while loop */
    /* and collect, save, reply and execute the messages until there is */
    /* a pause: */
    while(my_message=(struct IntuiMessage *)GetMsg( my_window->UserPort))
    {
      /* GetMsg will return a pointer to a message if there was one, */
      /* else it returns NULL. We will therefore stay in this while loop */
      /* as long as there are some messages waiting in the port. */
      
      /* After we have collected the message we can read it, and save */
      /* any important values which we maybe want to check later: */
      class = my_message->Class;      /* Save the IDCMP flag. */

      /* After we have read it we reply as fast as possible: */
      /* REMEMBER! Do never try to read a message after you have replied! */
      /* Some other process has maybe changed it. */
      ReplyMsg( my_message );

      /* Check which IDCMP flag was sent: */
      switch( class )
      {
        case CLOSEWINDOW:  /* The user selected the Close window gadget! */
               close_me=TRUE;
               break;
             
        case GADGETDOWN:   /* The user has selected the Prop. gadget: */
               printf("Proportional gadget selected.\n");
               break;
             
        case GADGETUP:     /* The user has released the Prop. gadget: */
               printf("Proportional gadget released.\n");
               break;
      }
    }
    printf("Hor= %1.0f\n", (float) my_prop_info.HorizPot / MAXPOT * 32);
    printf("Ver= %1.0f\n\n", (float) my_prop_info.VertPot / MAXPOT * 10);
  }

  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );



  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );

  /* THE END */
}
