/* Example9                                                           */
/* This program will open a normal window which is connected to the   */
/* Workbench Screen. The window will use all System Gadgets, and will */
/* close first when the user has selected the System gadget Close     */
/* window. Inside the window we have put a Proportional gadget.       */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* THE PROPORTIONAL GADGET's STRUCTURES: */

/* The IntuiText structure: */
struct IntuiText my_text=
{
  1,         /* FrontPen, colour register 1. */
  0,         /* BackPen, colour register 0. */
  JAM1,      /* DrawMode, draw the characters with colour 1, do not */
             /* change the background. */ 
  -65, 2,    /* LeftEdge, TopEdge. */
  NULL,      /* ITextFont, use default font. */
  "Volume:", /* IText, the text that will be printed. */
  NULL,      /* NextText, no other IntuiText structures. */
};


/* We need to declare an Image structure for the knob, but since */
/* Intuition will take care of the size etc of the knob, we do not need */
/* to initialize the Image structure: */
struct Image my_image;


struct PropInfo my_prop_info=
{
  FREEHORIZ|      /* Flags, the knob should be moved horizontally, and */
  AUTOKNOB,       /* Intuition should take care of the knob image. */
  0,              /* HorizPot, start position of the knob. */
  0,              /* VertPot, 0 since we will not move the knob hor. */
  MAXBODY * 1/64, /* HorizBody, 64 steps. */
  0,              /* VertBody, 0 since we will not move the knob hor. */

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
  80,              /* LeftEdge, 80 pixels out. */
  30,              /* TopEdge, 30 lines down. */
  200,             /* Width, 200 pixels wide. */
  12,              /* Height, 12 pixels lines heigh. */
  GADGHCOMP,       /* Flags, complement the colours. */
  GADGIMMEDIATE|   /* Activation, our program will recieve a message */
  RELVERIFY,       /* when the user has selected this gadget, and when */
                   /* the user has released it. */ 
  PROPGADGET,      /* GadgetType, a Proportional gadget. */
  (APTR) &my_image,/* GadgetRender, a pointer to our Image structure. */
                   /* (Intuition will take care of the knob image) */
                   /* (See chapter 3 GRAPHICS for more information) */
  NULL,            /* SelectRender, NULL since we do not supply the */
                   /* gadget with an alternative image. */
  &my_text,        /* GadgetText, volume. */
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
  320,           /* MinWidth    We will not allow the window to become */
  50,            /* MinHeight   smaller than 320 x 50, and not bigger */
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
    printf("Volume= %1.0f\n\n", (float) my_prop_info.HorizPot/MAXPOT*64);
  }

  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );



  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );

  /* THE END */
}

/*************************************************************************/
/* EXTRA INFORMATION:                                                    */
/* We will recieve a message (GADGETDOWN) when the user selects the      */
/* knob, and one message (GADGETUP) when the user releases the knob. If  */
/* the user on the other hand clicks inside the container (not on the    */
/* knob) we will recieve both a GADGETDOWN and a GADGETUP message at the */
/* same time.                                                            */
/* It is because of that we need to have a while loop which collects the */
/* messages once one or more has arrived. We can not as before just wait */
/* and then collect one message, since there may be more in the queue.   */
/*************************************************************************/
