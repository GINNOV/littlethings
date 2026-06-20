/* Example5                                                             */
/* This program will open a normal window which is connected to the     */
/* Workbench Screen. The window will use all System Gadgets, and will   */
/* close first when the user has selected the System gadget Close       */
/* window. Whenever the user double-clicks on the right mouse button,   */
/* a Double-menue requester is activated. This example also shows how   */
/* to use the IDCMP flags REQSET and REQCLEAR.                          */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/***************/
/* THE GADGET: */
/***************/

/* The coordinates for the box: */
SHORT gadget_border_points[]=
{
   0,  0, /* Start at position (0,0) */
  70,  0, /* Draw a line to the right to position (70,0) */
  70, 10, /* Draw a line down to position (70,10) */
   0, 10, /* Draw a line to the right to position (0,10) */
   0,  0  /* Finish of by drawing a line up to position (0,0) */ 
};

/* The Border structure: */
struct Border gadget_border=
{
  0, 0,        /* LeftEdge, TopEdge. */
  1,           /* FrontPen, colour register 1. */
  0,           /* BackPen, for the moment unused. */
  JAM1,        /* DrawMode, draw the lines with colour 1. */
  5,           /* Count, 5 pair of coordinates in the array. */
  gadget_border_points, /* XY, pointer to the array with the coord. */
  NULL,        /* NextBorder, no other Border structures are connected. */
};

/* The IntuiText structure: */
struct IntuiText gadget_text=
{
  1,         /* FrontPen, colour register 1. */
  0,         /* BackPen, colour register 0. */
  JAM1,      /* DrawMode, draw the characters with colour 1, do not */
             /* change the background. */ 
  4, 2,      /* LeftEdge, TopEdge. */
  NULL,      /* ITextFont, use default font. */
  "PRESS ME",/* IText, the text that will be printed. */
  NULL,      /* NextText, no other IntuiText structures are connected. */
};

struct Gadget requester_gadget=
{
  NULL,          /* NextGadget, no more gadgets in the list. */
  40,            /* LeftEdge, 40 pixels out. */
  20,            /* TopEdge, 20 lines down. */
  71,            /* Width, 71 pixels wide. */
  11,            /* Height, 11 pixels lines heigh. */
  GADGHCOMP,     /* Flags, when this gadget is highlighted, the gadget */
                 /* will be rendered in the complement colours. */
                 /* (Colour 0 (00) will be changed to colour 3 (11) */
                 /* (Colour 1 (01)           - " -           2 (10) */
                 /* (Colour 2 (10)           - " -           1 (01) */
                 /* (Colour 3 (11)           - " -           0 (00) */  
  GADGIMMEDIATE| /* Activation, our program will recieve a message when */
  RELVERIFY|     /* the user has selected this gadget, and when the user */
                 /* has released it. */
  ENDGADGET,     /* When the user has selected this gadget, the */
                 /* requester is satisfied, and is deactivated. */
                 /* IMPORTANT! At least one gadget per requester */
                 /* must have the flag ENDGADGET set. If not, the */
                 /* requester would never be deactivated! */

  BOOLGADGET|    /* GadgetType, a Boolean gadget which is connected to */
  REQGADGET,     /* a requester. IMPORTANT! Every gadget which is */
                 /* connectd to a requester must have the REQGADGET flsg */
                 /* set in the GadgetType field. */
  (APTR) &gadget_border, /* GadgetRender, a pointer to our Border struc. */
  NULL,          /* SelectRender, NULL since we do not supply the gadget */
                 /* with an alternative image. (We complement the */
                 /* colours instead) */
  &gadget_text,  /* GadgetText, a pointer to our IntuiText structure. */
                 /* (See chapter 3 GRAPHICS for more information) */
  NULL,          /* MutualExclude, no mutual exclude. */
  NULL,          /* SpecialInfo, NULL since this is a Boolean gadget. */
                 /* (It is not a Proportional/String or Integer gdget) */
  0,             /* GadgetID, no id. */
  NULL           /* UserData, no user data connected to the gadget. */
};

/***********************************************************************/
/* Important notice:                                                   */
/* Remember that every gadget which is connected to a requester must   */
/* have the flag REQGADGET set in the GadgetType field. Remember also  */
/* that at least one gadget per requester must have the ENDGADGET flag */
/* set in the Activation field.                                        */
/***********************************************************************/



/************************************/
/* THE BORDER AROUND THE REQUESTER: */
/************************************/

/* The coordinates for the box around the requester: */
SHORT requester_border_points[]=
{
    0,  0, /* Start at position (0,0) */
  319,  0, /* Draw a line to the right to position (319,0) */
  319, 99, /* Draw a line down to position (319,99) */
    0, 99, /* Draw a line to the right to position (319,99) */
    0,  0  /* Finish of by drawing a line up to position (0,0) */ 
};

/* The Border structure for the requester: */
struct Border requester_border=
{
  0, 0,        /* LeftEdge, TopEdge. */
  1,           /* FrontPen, colour register 1. */
  0,           /* BackPen, for the moment unused. */
  JAM1,        /* DrawMode, draw the lines with colour 1. */
  5,           /* Count, 5 pair of coordinates in the array. */
  requester_border_points, /* XY, pointer to the array with the coord. */
  NULL,        /* NextBorder, no other Border structures are connected. */
};



/**********************************/
/* THE TEXT INSIDE THE REQUESTER: */
/**********************************/

/* The IntuiText structure used to print some text inside the requester: */
struct IntuiText requester_text=
{
  1,         /* FrontPen, colour register 1. */
  0,         /* BackPen, unused since JAM1. */
  JAM1,      /* DrawMode, draw the characters with colour 1, do not */
             /* change the background. */ 
  4, 2,      /* LeftEdge, TopEdge. */
  NULL,      /* ITextFont, use default font. */
  "This is the requester!", /* IText, the text that will be printed. */
  NULL,      /* NextText, no other IntuiText structures are connected. */
};



/* Note:                                                                */
/* This is the structure for the Double-menu requester, but as you have */
/* maybe noticed, it is exactly the same as a normal requester struc.   */
/* The diffrence is that we call the function SetDMRequest() instead    */
/* of calling the function Request().                                   */

struct Requester my_requester=
{
  NULL,              /* OlderRequester, used by Intuition. */
  40, 20,            /* LeftEdge, TopEdge, 40 pixels out, 20 lines down. */
  320, 100,          /* Width, Height, 320 pixels wide, 100 lines high. */
  0, 0,              /* RelLeft, RelTop, Since POINTREL flag is not set, */
                     /* Intuition ignores these values. */
  &requester_gadget, /* ReqGadget, pointer to the first gadget. */
  &requester_border, /* ReqBorder, pointer to a Border structure. */
  &requester_text,   /* ReqText, pointer to a IntuiText structure. */
  NULL,              /* Flags, no flags set. */
  3,                 /* BackFill, draw everything on an orange backgr. */
  NULL,              /* ReqLayer, used by Intuition. Set to NULL. */
  NULL,              /* ReqPad1, used by Intuition. Set to NULL. */
  NULL,              /* ImageBMap, no predrawn Bitmap. Set to NULL. */
                     /*            (The PREDRAWN flag was not set) */
  NULL,              /* RWindow, used by Intuition. Set to NULL. */
  NULL               /* ReqPad2, used by Intuition. Set to NULL. */
};



/* Declare a pointer to a Window structure: */ 
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  0,             /* LeftEdge    x position of the window. */
  0,             /* TopEdge     y positio of the window. */
  640,           /* Width       640 pixels wide. */
  200,           /* Height      200 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  CLOSEWINDOW|   /* IDCMPFlags  The window will give us a message if the */
                 /*             user has selected the Close window gad, */
  GADGETDOWN|    /*             or a gadget has been pressed on, or */
  GADGETUP|      /*             a gadge has been released. */
  REQSET|        /*             We will also recieve a message when the */
  REQCLEAR,      /*             user has activated and deactivated a req. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No gadget connected to this window. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "The Fantastic Window!",      /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  140,           /* MinWidth    We will not allow the window to become */
  50,            /* MinHeight   smaller than 140 x 50, and not bigger */
  300,           /* MaxWidth    than 300 x 200. */
  200,           /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};

/* Note:                                                         */
/* Since we want to know when the user selects and deselects the */
/* DMRequester, we set the IDCMP flags REQSET and REQCLEAR.      */



main()
{
  /* Boolean variable used for the while loop: */
  BOOL close_me;

  /* Declare a variable in which we will store the IDCMP flag: */
  ULONG class;
  
  /* Declare a pointer to an IntuiMessage structure: */
  struct IntuiMessage *my_message;

  /* We use this variable to check if Intuition could enable the user */
  /* to bring up the requester whenever he/she wants: */
  BOOL result;



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



  /* We will now try to set the Double-menu requester: */
  result=SetDMRequest( my_window, &my_requester );

  if( !result )  /* !result is the same thing as result==FALSE */
  {
    /* Intuition could not set the Double-menu requester! */
  
    printf("Could not set the Double-menu requester!\n");
  }
  else
  {
    /* OK */
    printf("Try to double-click on the right mouse button!\n\n");
  }


  close_me = FALSE;

  /* Stay in the while loop until the user has selected the Close window */
  /* gadget: */
  while( !close_me )
  {
    /* Wait until we have recieved a message: */
    Wait( 1 << my_window->UserPort->mp_SigBit );

    /* As long as we collect messages sucessfully: */
    while(my_message=(struct IntuiMessage *) GetMsg(my_window->UserPort))
    {
      /* After we have collected the message we can read it, and save any */
      /* important values which we maybe want to check later: */
      class = my_message->Class;

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
             
        case GADGETDOWN:   /* The user has pressed on a gadget. */
               /* Since there exist only one "nomal" gadget, we do not */
               /* need to check which gadget was selected. */
               
               printf("Gadget down\n");
               break;
             
        case GADGETUP:     /* The user has released a gadget. */
               /* Since there exist only one "nomal" gadget, we do not */
               /* need to check which gadget was released. */
               
               /* Once we recieve this message, the requester will be */
               /* satisfied, and therefore deactivated. We will */
               /* therefore also recieve a REQCLEAR message. */
               
               printf("Gadget up\n");
               break;
               
        case REQSET:       /* Requester activated. */
               printf("Requester activated!\n");
               printf("You can not close the window now.\n");
               break;
               
        case REQCLEAR:     /* Requester deactivated. */
               printf("Requester deactivated!\n");
               printf("You can close the window now.\n\n");
               break;
      }
    }
  }



  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );



  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}