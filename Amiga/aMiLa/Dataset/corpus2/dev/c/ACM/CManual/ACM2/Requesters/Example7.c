/* Example7                                                             */
/* This program will open a normal window which is connected to the     */
/* Workbench Screen. The window will use all System Gadgets, and will   */
/* close first when the user has selected the System gadget Close       */
/* window. Inside the window we have activated an Application requester */
/* with three connecting gadgets. Two are Boolean gadgets ("OK and      */
/* "CANCEL"), and one is a String gadget.                               */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/***********************************/
/* THE STRING GADGET's STRUCTURES: */
/***********************************/

/* The coordinates for the box around the string gadget: */
SHORT string_border_points[]=
{
   -7, -4, /* Start at position (-7, -4) */
  200, -4, /* Draw a line to the right to position (200,-4) */
  200, 11, /* Draw a line down to position (200,11) */
   -7, 11, /* Draw a line to the left to position (-7,11) */
   -7, -4  /* Finish of by drawing a line up to position (-7,-4) */ 
};

/* The Border structure for the string gadget: */
struct Border string_border=
{
  0, 0,                 /* LeftEdge, TopEdge. */
  1,                    /* FrontPen, colour register 1. */
  0,                    /* BackPen, for the moment unused. */
  JAM1,                 /* DrawMode, draw the lines with colour 1. */
  5,                    /* Count, 5 pair of coordinates in the array. */
  string_border_points, /* XY, pointer to the array with the coordinates. */
  NULL,                 /* NextBorder, no other Border structures. */
};



/* The IntuiText structure for the string gadget: */
struct IntuiText string_text=
{
  1,         /* FrontPen, colour register 1. (white) */
  0,         /* BackPen, not used since JAM1. */
  JAM1,      /* DrawMode, draw the characters with colour 1, and do not */
             /* bother about the background. */ 
  -53, 0,    /* LeftEdge, TopEdge. */
  NULL,      /* ITextFont, use default font. */
  "Name:",   /* IText, the text that will be printed. */
  NULL,      /* NextText, no other IntuiText structures. */
};



UBYTE my_buffer[50]; /* 50 characters including the NULL-sign. */
UBYTE my_undo_buffer[50]; /* Must be at least as big as my_buffer. */



struct StringInfo string_info=
{
  my_buffer,       /* Buffer, pointer to a null-terminated string. */
  my_undo_buffer,  /* UndoBuffer, pointer to a null-terminated string. */
                   /* (Remember my_buffer is equal to &my_buffer[0]) */
  0,               /* BufferPos, initial position of the cursor. */
  50,              /* MaxChars, 50 characters + null-sign ('\0'). */
  0,               /* DispPos, first character in the string should be */
                   /* first character in the display. */

  /* Intuition initializes and maintaines these variables: */

  0,               /* UndoPos */
  0,               /* NumChars */
  0,               /* DispCount */
  0, 0,            /* CLeft, CTop */
  NULL,            /* LayerPtr */
  NULL,            /* LongInt */
  NULL,            /* AltKeyMap */
};


struct Gadget string_gadget=
{
  NULL,          /* NextGadget, no more gadgets in the list. */
  68,            /* LeftEdge, 68 pixels out. */
  26,            /* TopEdge, 26 lines down. */
  198,           /* Width, 198 pixels wide. */
  8,             /* Height, 8 pixels lines heigh. */
  GADGHCOMP,     /* Flags, draw the select box in the complement */
                 /* colours. Note: it actually only the cursor which */
                 /* will be drawn in the complement colours (yellow). */
                 /* If you set the flag GADGHNONE the cursor will not be */
                 /* highlighted, and the user will therefore not be able */
                 /* to see it. */
  GADGIMMEDIATE| /* Activation, our program will recieve a message when */
  RELVERIFY,     /* the user has selected this gadget, and when the user */
                 /* has released it. */ 
  STRGADGET|     /* GadgetType, a String gadget which is connected to */
  REQGADGET,     /* a requester. IMPORTANT! Every gadget which is */
                 /* connectd to a requester must have the REQGADGET flsg */
                 /* set in the GadgetType field. */
  (APTR) &string_border, /* GadgetRender, a pointer to our Border struc. */
  NULL,          /* SelectRender, NULL since we do not supply the gadget */
                 /* with an alternative image. */
  &string_text,  /* GadgetText, a pointer to our IntuiText structure. */
  NULL,          /* MutualExclude, no mutual exclude. */
  (APTR) &string_info, /* SpecialInfo, a pointer to a StringInfo str. */
  0,             /* GadgetID, no id. */
  NULL           /* UserData, no user data connected to the gadget. */
};



/*******************************/
/* THE OK GADGET's STRUCTURES: */
/*******************************/

/* The coordinates for the OK box: */
SHORT ok_border_points[]=
{
   0,  0, /* Start at position (0,0) */
  22,  0, /* Draw a line to the right to position (22,0) */
  22, 10, /* Draw a line down to position (22,10) */
   0, 10, /* Draw a line to the left to position (0,10) */
   0,  0  /* Finish of by drawing a line up to position (0,0) */ 
};

/* The Border structure: */
struct Border ok_border=
{
  0, 0,        /* LeftEdge, TopEdge. */
  1,           /* FrontPen, colour register 1. */
  0,           /* BackPen, for the moment unused. */
  JAM1,        /* DrawMode, draw the lines with colour 1. */
  5,           /* Count, 5 pair of coordinates in the array. */
  ok_border_points, /* XY, pointer to the array with the coord. */
  NULL,        /* NextBorder, no other Border structures are connected. */
};

/* The IntuiText structure: */
struct IntuiText ok_text=
{
  1,      /* FrontPen, colour register 1. */
  0,      /* BackPen, not used since JAM1. */
  JAM1,   /* DrawMode, draw the characters with colour 1, do not */
          /* change the background. */ 
  4, 2,   /* LeftEdge, TopEdge. */
  NULL,   /* ITextFont, use default font. */
  "OK",   /* IText, the text that will be printed. */
  NULL,   /* NextText, no other IntuiText structures are connected. */
};

struct Gadget ok_gadget=
{
  &string_gadget,/* NextGadget, linked to the string gadget. */
  14,            /* LeftEdge, 14 pixels out. */
  47,            /* TopEdge, 47 lines down. */
  23,            /* Width, 23 pixels wide. */
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
  (APTR) &ok_border, /* GadgetRender, a pointer to our Border struc. */
  NULL,          /* SelectRender, NULL since we do not supply the gadget */
                 /* with an alternative image. (We complement the */
                 /* colours instead) */
  &ok_text,      /* GadgetText, a pointer to our IntuiText structure. */
                 /* (See chapter 3 GRAPHICS for more information) */
  NULL,          /* MutualExclude, no mutual exclude. */
  NULL,          /* SpecialInfo, NULL since this is a Boolean gadget. */
                 /* (It is not a Proportional/String or Integer gdget) */
  0,             /* GadgetID, no id. */
  NULL           /* UserData, no user data connected to the gadget. */
};




/***********************************/
/* THE CANCEL GADGET's STRUCTURES: */
/***********************************/

/* The coordinates for the CANCEL box: */
SHORT cancel_border_points[]=
{
   0,  0, /* Start at position (0,0) */
  54,  0, /* Draw a line to the right to position (54,0) */
  54, 10, /* Draw a line down to position (54,10) */
   0, 10, /* Draw a line to the left to position (0,10) */
   0,  0  /* Finish of by drawing a line up to position (0,0) */ 
};

/* The Border structure: */
struct Border cancel_border=
{
  0, 0,        /* LeftEdge, TopEdge. */
  1,           /* FrontPen, colour register 1. */
  0,           /* BackPen, for the moment unused. */
  JAM1,        /* DrawMode, draw the lines with colour 1. */
  5,           /* Count, 5 pair of coordinates in the array. */
  cancel_border_points, /* XY, pointer to the array with the coord. */
  NULL,        /* NextBorder, no other Border structures are connected. */
};

/* The IntuiText structure: */
struct IntuiText cancel_text=
{
  1,        /* FrontPen, colour register 1. */
  0,        /* BackPen, not used since JAM1. */
  JAM1,     /* DrawMode, draw the characters with colour 1, do not */
            /* change the background. */ 
  4, 2,     /* LeftEdge, TopEdge. */
  NULL,     /* ITextFont, use default font. */
  "CANCEL", /* IText, the text that will be printed. */
  NULL,     /* NextText, no other IntuiText structures are connected. */
};

struct Gadget cancel_gadget=
{
  &ok_gadget,    /* NextGadget, linked to the OK gadget. */
  214,           /* LeftEdge, 214 pixels out. */
  47,            /* TopEdge, 47 lines down. */
  55,            /* Width, 55 pixels wide. */
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
  (APTR) &cancel_border, /* GadgetRender, a pointer to our Border struc. */
  NULL,          /* SelectRender, NULL since we do not supply the gadget */
                 /* with an alternative image. (We complement the */
                 /* colours instead) */
  &cancel_text,  /* GadgetText, a pointer to our IntuiText structure. */
                 /* (See chapter 3 GRAPHICS for more information) */
  NULL,          /* MutualExclude, no mutual exclude. */
  NULL,          /* SpecialInfo, NULL since this is a Boolean gadget. */
                 /* (It is not a Proportional/String or Integer gdget) */
  0,             /* GadgetID, no id. */
  NULL           /* UserData, no user data connected to the gadget. */
};



/************************************************************************/
/* Note:                                                                */
/* Remember that every gadget which is connected to a requester must    */
/* have the flag REQGADGET set in the GadgetType field. Remember also   */
/* that at least one gadget per requester must have the ENDGADGET flag  */
/* set in the Activation field.                                         */
/* In this example we have three gadgets connected to the requester.    */
/* All of them has the REQGADGET flag set, and the OK and CANCEL gadget */
/* has also the ENDGADGET flag set.                                     */
/************************************************************************/



/************************************/
/* THE BORDER AROUND THE REQUESTER: */
/************************************/

/* The coordinates for the box around the requester: */
SHORT requester_border_points[]=
{
    0,  0, /* Start at position (0,0) */
  282,  0, /* Draw a line to the right. */
  282, 64, /* Draw a line down. */
    0, 64, /* Draw a line to the left. */
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
  14, 8,     /* LeftEdge, TopEdge. */
  NULL,      /* ITextFont, use default font. */
  "Please enter your name:", /* IText, the text that will be printed. */
  NULL,      /* NextText, no other IntuiText structures are connected. */
};



/****************************/
/* THE REQUESTER STRUCTURE: */
/****************************/

struct Requester my_requester=
{
  NULL,              /* OlderRequester, used by Intuition. */
  40, 20,            /* LeftEdge, TopEdge, 40 pixels out, 20 lines down. */
  283, 65,           /* Width, Height, 283 pixels wide, 65 lines high. */
  0, 0,              /* RelLeft, RelTop, Since POINTREL flag is not set, */
                     /* Intuition ignores these values. */
  &cancel_gadget,    /* ReqGadget, pointer to the first gadget. */
  &requester_border, /* ReqBorder, pointer to a Border structure. */
  &requester_text,   /* ReqText, pointer to a IntuiText structure. */
  NULL,              /* Flags, no flags set. */
  2,                 /* BackFill, draw everything on a black background. */
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
  REQSET|        /*             Send a message also if a requester has */
  REQCLEAR,      /*             been activated or deactivated. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No gadget connected to this window. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "The Window",  /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  140,           /* MinWidth    We will not allow the window to become */
  50,            /* MinHeight   smaller than 140 x 50, and not bigger */
  300,           /* MaxWidth    than 300 x 200. */
  200,           /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



main()
{
  /* Boolean variable used for the while loop: */
  BOOL close_me;

  /* Declare a variable in which we will store the IDCMP flag: */
  ULONG class;
  
  /* Declare a variable in which we will store the address of the */
  /* gadget which sent the message: */
  APTR address;
  
  /* Declare a pointer to an IntuiMessage structure: */
  struct IntuiMessage *my_message;

  /* We use this variable to check if the requester has ben activated */
  /* or not: */
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



  /* We will now try to activate the requester: */
  result=Request( &my_requester, my_window );

  if( !result )  /* !result is the same thing as result==FALSE */
  {
    /* Intuition could not activate the requester! */
    /* In this case we do not need to quit since it does not matter if */
    /* the requester was activated or not. I just wanted to show how */
    /* you can check if you have opened or not the requester. */
  
    printf("Could not activate the requester!\n");
  }
  else
  {
    /* Intuition could open the requester! */
    printf("Try to close the window!\n");
  }



  close_me = FALSE;

  /* Stay in the while loop until the user has selected the Close window */
  /* gadget. However, in this example the user first need to deactivate */
  /* the requester before he can select the Close window gadget: */
  while( !close_me )
  {
    /* Wait until we have recieved a message: */
    Wait( 1 << my_window->UserPort->mp_SigBit );

    /* As long as we collect messages sucessfully: */
    while(my_message=(struct IntuiMessage *) GetMsg(my_window->UserPort))
    {
      /* After we have collected the message we can read it, and save any */
      /* important values which we maybe want to check later: */
      
      /* Store the IDCMP flag: */
      class = my_message->Class;

      /* Store the address: */
      address = my_message->IAddress;

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
               
               if( address == (APTR) &ok_gadget )
                 printf("The user pressed on the OK gadget!\n");

               if( address == (APTR) &cancel_gadget )
                 printf("The user pressed on the CANCEL gadget!\n");
                 
               if( address == (APTR) &string_gadget )
                 printf("The user selected the string gadget!\n");
               
               break;
             
        case GADGETUP:     /* The user has released a gadget. */

               if( address == (APTR) &ok_gadget )
                 printf("The user released the OK gadget!\n");

               if( address == (APTR) &cancel_gadget )
                 printf("The user released the CANCEL gadget!\n");
                 
               if( address == (APTR) &string_gadget )
               {
                 printf("The user released the string gadget!\n");

                 /* Print out the string: */
                 printf("Name: %s\n\n", my_buffer);
               }

               break;
               
        case REQSET:       /* Requester activated. */
              printf("Requester activated!\n");
              break;

        case REQCLEAR:     /* Requester deactivated. */
              printf("Requester deactivated!\n");
              printf("You can now close the window.\n");
              break;
      }
    }
  }



  /* Print out the string: */
  printf("Name: %s\n\n", my_buffer);



  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );



  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}

