/* Example4                                                           */
/* This program will open a normal window which is connected to the   */
/* Workbench Screen. The window will use all System Gadgets, and will */
/* close first when the user has selected the System gadget Close     */
/* window. Inside the window we have put two Boolean gadgets with the */
/* text "GADGET 1" and "GADGET 2".                                    */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* The coordinates for the box: */
SHORT my_points[]=
{
   0,  0, /* Start at position (0,0) */
  70,  0, /* Draw a line to the right to position (70,0) */
  70, 10, /* Draw a line down to position (70,10) */
   0, 10, /* Draw a line to the right to position (0,10) */
   0,  0  /* Finish of by drawing a line up to position (0,0) */ 
};

/* The Border structure: */
struct Border my_border=
{
  0, 0,        /* LeftEdge, TopEdge. */
  1,           /* FrontPen, colour register 1. */
  0,           /* BackPen, for the moment unused. */
  JAM1,        /* DrawMode, draw the lines with colour 1. */
  5,           /* Count, 5 pair of coordinates in the array. */
  my_points,   /* XY, pointer to the array with the coordinates. */
  NULL,        /* NextBorder, no other Border structures are connected. */
};

/* We can use the same Border structure for both of the gadgets since */
/* they have the same size. */ 



/************/
/* GADGET 1 */
/************/

/* The first text string: */
UBYTE my_first_string[]="GADGET 1";

/* The IntuiText structure: */
struct IntuiText my_first_text=
{
  1,         /* FrontPen, colour register 1. */
  0,         /* BackPen, colour register 0. */
  JAM1,      /* DrawMode, draw the characters with colour 1, do not */
             /* change the background. */ 
  4, 2,      /* LeftEdge, TopEdge. */
  NULL,      /* ITextFont, use default font. */
  my_first_string, /* IText, the text that will be printed. */
             /* (Remember my_text = &my_text[0].) */
  NULL,      /* NextText, no other IntuiText structures are connected. */
};

struct Gadget my_first_gadget=
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
  RELVERIFY,     /* the user has selected this gadget, and when the user */
                 /* has released it. */ 
  BOOLGADGET,    /* GadgetType, a Boolean gadget. */
  (APTR) &my_border, /* GadgetRender, a pointer to our Border structure. */
                 /* (Since Intuition does not know if this will be a */
                 /* pointer to a Border structure or an Image structure, */
                 /* Intuition expects an APTR (normal memory pointer). */
                 /* We will therefore have to calm down the compiler by */
                 /* doing some "casting".) */
  NULL,          /* SelectRender, NULL since we do not supply the gadget */
                 /* with an alternative image. (We complement the */
                 /* colours instead) */
  &my_first_text,/* GadgetText, a pointer to our IntuiText structure. */
                 /* (See chapter 3 GRAPHICS for more information) */
  NULL,          /* MutualExclude, no mutual exclude. */
  NULL,          /* SpecialInfo, NULL since this is a Boolean gadget. */
                 /* (It is not a Proportional/String or Integer gdget) */
  0,             /* GadgetID, no id. */
  NULL           /* UserData, no user data connected to the gadget. */
};



/************/
/* GADGET 2 */
/************/

/* The second text string: */
UBYTE my_second_string[]="GADGET 2";

/* The IntuiText structure: */
struct IntuiText my_second_text=
{
  1,         /* FrontPen, colour register 1. */
  0,         /* BackPen, colour register 0. */
  JAM1,      /* DrawMode, draw the characters with colour 1, do not */
             /* change the background. */ 
  4, 2,      /* LeftEdge, TopEdge. */
  NULL,      /* ITextFont, use default font. */
  my_second_string, /* IText, the text that will be printed. */
             /* (Remember my_text = &my_text[0].) */
  NULL,      /* NextText, no other IntuiText structures are connected. */
};

struct Gadget my_second_gadget=
{
  &my_first_gadget, /* NextGadget, after this comes my_first_gadget. */
  150,           /* LeftEdge, 150 pixels out. */
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
  RELVERIFY,     /* the user has selected this gadget, and when the user */
                 /* has released it. */ 
  BOOLGADGET,    /* GadgetType, a Boolean gadget. */
  (APTR) &my_border, /* GadgetRender, a pointer to our Border structure. */
                 /* (Since Intuition does not know if this will be a */
                 /* pointer to a Border structure or an Image structure, */
                 /* Intuition expects an APTR (normal memory pointer). */
                 /* We will therefore have to calm down the compiler by */
                 /* doing some "casting".) */
  NULL,          /* SelectRender, NULL since we do not supply the gadget */
                 /* with an alternative image. (We complement the */
                 /* colours instead) */
  &my_second_text,/* GadgetText, a pointer to our IntuiText structure. */
                 /* (See chapter 3 GRAPHICS for more information) */
  NULL,          /* MutualExclude, no mutual exclude. */
  NULL,          /* SpecialInfo, NULL since this is a Boolean gadget. */
                 /* (It is not a Proportional/String or Integer gdget) */
  0,             /* GadgetID, no id. */
  NULL           /* UserData, no user data connected to the gadget. */
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
  &my_second_gadget, /* FirstGadget A pointer to my_second_gadget
                     /* structure. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "TOUCH ME",    /* Title       Title of the window. */
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

  /* In this example we also need to store the address of the gadget */
  /* which sent us the mesage: */
  APTR address;
  
  /* we declare a memory pointer (APTR) called address. */
 
   
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

    /* Collect the message: */
    my_message = (struct IntuiMessage *) GetMsg( my_window->UserPort );

    /* Have we collected the message sucessfully? */
    if(my_message)
    {
      /* After we have collected the message we can read it, and save any */
      /* important values which we maybe want to check later: */
      class = my_message->Class;      /* Save the IDCMP flag. */
      address = my_message->IAddress; /* Save the address. */
  
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
               
        case GADGETDOWN:   /* The user has pressed on one of the Boolean */
                           /* gadgets. We have now to check which: */
               if( address == (APTR) &my_first_gadget)
                 printf("Gadget 1 Down\n");
               else
                 printf("Gadget 2 Down\n");
  
               /* We need to do some "casting" here again since APTR is a */
               /* normal memory pointer, while &my_first_gadget is a */
               /* pointer to a Gadget structure. It is actually the same */
               /* thing but we need to explain this for the compiler. */
  
               break;
               
        case GADGETUP:     /* The user has released one of the Boolean */
                           /* gadgets. We have now to check which: */
               if( address == (APTR) &my_first_gadget)
                 printf("Gadget 1 Up\n");
               else
                 printf("Gadget 2 Up\n");
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

