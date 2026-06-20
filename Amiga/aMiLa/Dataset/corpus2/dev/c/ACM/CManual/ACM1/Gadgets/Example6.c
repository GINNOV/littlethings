/* Example6                                                           */
/* This program will open a normal window which is connected to the   */
/* Workbench Screen. The window will use all System Gadgets, and will */
/* close first when the user has selected the System gadget Close     */
/* window. Inside the window we have put a Boolean gadget with a      */
/* connecting mask. The gadget will only be highlighted when the user */
/* selects this gadget while pointing inside the specified (masked)   */
/* area.                                                              */



/* If your program is using Intuition you should include intuition.h: */
#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* Image data for the gadget: */
USHORT chip my_image_data[32]=
{
   0xFFFF,0xFFFF, /* Bitplane ZERO */
   0xFFF8,0x1FFF,
   0xFFE0,0x07FF,
   0xFF80,0x01FF,
   0xFE00,0x007F,
   0xF800,0x001F,
   0xE000,0x0007,
   0x8000,0x0001,
   0x8000,0x0001,
   0xE000,0x0007,
   0xF800,0x001F,
   0xFE00,0x007F,
   0xFF80,0x01FF,
   0xFFE0,0x07FF,
   0xFFF8,0x1FFF,
   0xFFFF,0xFFFF
};

/* Image structure for the gadget: */
struct Image my_image=
{
  0, 0,          /* LeftEdge, TopEdge */
  32, 16,        /* Width, Height */
  1,             /* Depth */
  my_image_data, /* ImageData */
  0x01, 0x00,    /* PlanePick, PlaneOnOff */
  NULL           /* NextImage */
};


     UWORD chip my_mask[32]=
{
   0x0000,0x0000, /* Bitplane ZERO */
   0x0007,0xE000,
   0x001F,0xF800,
   0x007F,0xFE00,
   0x01FF,0xFF80,
   0x07FF,0xFFE0,
   0x1FFF,0xFFF8,
   0x7FFF,0xFFFE,
   0x7FFF,0xFFFE,
   0x1FFF,0xFFF8,
   0x07FF,0xFFE0,
   0x01FF,0xFF80,
   0x007F,0xFE00,
   0x001F,0xF800,
   0x0007,0xE000,
   0x0000,0x0000
};

/* The BoolInfo structure fot the gadget: */
struct BoolInfo my_bool_info=
{
	BOOLMASK,  /* Flags, for the moment this is the only flag you may use. */
	my_mask,   /* Mask, pointer to our bit mask. Only when the user clicks */
	           /* inside the small area of the gadget it will be selected, */
						 /* and only that area will be highlighted. */
						 /* Remember! The width and height of the mask data must */
						 /* be the same as the width and height of the gadget. */
  0          /* Reserved, set this variable to 0 for the moment. */
};

/* The Gadget structure: */
struct Gadget my_gadget=
{
  NULL,          /* NextGadget, no more gadgets in the list. */
  40,            /* LeftEdge, 40 pixels out. */
  20,            /* TopEdge, 20 lines down. */
  32,            /* Width, 32 pixels wide. */
  16,            /* Height, 16 pixels lines heigh. */
  GADGHCOMP|     /* Flags, complement the colours when selected. */
  GADGIMAGE,     /* Render the gadget with an Image structure. */
  GADGIMMEDIATE| /* Activation, our program will recieve a message when */
  RELVERIFY|     /* the user has selected this gadget, and when the user */
                 /* has released it. */ 
  BOOLEXTEND,    /* This gadget has an BoolInfo connected to it. */ 
  BOOLGADGET,    /* GadgetType, a Boolean gadget. */
  (APTR) &my_image, /* GadgetRender, a pointer to our Image structure. */
  NULL,          /* SelectRender, NULL since we do not supply the gadget */
                 /* with an alternative image. (We complement the */
                 /* colours instead) */
  NULL,          /* GadgetText, no text connected to the gadget. */
                 /* (See chapter 3 GRAPHICS for more information) */
  NULL,          /* MutualExclude, no mutual exclude. */
  (APTR) &my_bool_info, /* SpecialInfo, pointer to the BoolInfo str. */
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
  200,           /* Width       200 pixels wide. */
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
  &my_gadget,    /* FirstGadget A pointer to my_gadget structure. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "TOUCH ME",    /* Title       Title of the window. */
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
             
        case GADGETDOWN:   /* The user has pressed on the Boolean gadget. */
               printf("Down\n");
               break;
             
        case GADGETUP:     /* The user has released the Boolean gadget. */
               printf("Up\n");
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



/*******************************************/
/* Extra Information about masked gadgets: */
/*******************************************/

/*

What is special about this example is that we have connected a mask to the
Boolean gadget. The gadget will therefore only be highlighted when the user
clicks inside the "masked" area, and only that area will be highlighted.

Only Boolean gadgets may have a connecting mask, and if you would want to
use one you need to:

  1. Set the BOOLEXTEND flag in the Activation field.

  2. Declare and initialize the bit mask data. Important, the mask must be
     exactly as high and wide as the gadget itself. Only the selected parts
     (masked = 1's) will be sensetive, and highlighted when selected.

  3. Declare and initialize a BoolInfo structure which look like this:
     struct BoolInfo
     {
       USHORT Flags;
       UWORD *Mask;
       ULONG Reserved;
     };
     
     Flags:    There exist for the moment only one flag, BOOLMASK. Set it.
     Mask:     Pointer to the bit mask data.
     Reserved: Reserved field. Set it to 0.

  4. Set the SpecialInfo pointer in the Gadget structure to point at a
     BoolInfo structure.



In this example the gadget look like this:              
                                             
1111111111111111 1111111111111111    0: blue 
1111111111111000 0001111111111111    1: white
1111111111100000 0000011111111111
1111111110000000 0000000111111111
1111111000000000 0000000001111111
1111100000000000 0000000000011111
1110000000000000 0000000000000111
1000000000000000 0000000000000001
1000000000000000 0000000000000001
1110000000000000 0000000000000111
1111100000000000 0000000000011111
1111111000000000 0000000001111111
1111111110000000 0000000111111111
1111111111100000 0000011111111111
1111111111111000 0001111111111111
1111111111111111 1111111111111111

And the mask look like this:

0000000000000000 0000000000000000    0: Unselected (unmasked) area.
0000000000000111 1110000000000000    1: Selected (masked) area.
0000000000011111 1111100000000000
0000000001111111 1111111000000000
0000000111111111 1111111110000000
0000011111111111 1111111111100000
0001111111111111 1111111111111000
0111111111111111 1111111111111110
0111111111111111 1111111111111110
0001111111111111 1111111111111000
0000011111111111 1111111111100000
0000000111111111 1111111110000000
0000000001111111 1111111000000000
0000000000011111 1111100000000000
0000000000000111 1110000000000000
0000000000000000 0000000000000000

*/
