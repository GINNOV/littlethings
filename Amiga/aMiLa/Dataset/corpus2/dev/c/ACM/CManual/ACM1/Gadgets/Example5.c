/* Example5                                                             */
/* This program will open a normal window which is connected to the     */
/* Workbench Screen. The window will use all System Gadgets, and will   */
/* close first when the user has selected the System gadget Close       */
/* window. Inside the window we have put a Boolean gadget with two      */
/* Image structures connected to it. Each time the user clicks on the   */
/* gadget it will change images, lamp on/lamp off.                      */



/* Since the program is using Intuition we need to include this file: */
#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* The Image data for the dark lamp: */
/* Remember that Image data must ALWAYS be placed in chip memory: */
USHORT chip lamp_off_data[84]=
{
  0x00FF,0x8000, /* Bitplane ZERO */
  0x0700,0x7000,
  0x18F0,0x0C00,
  0x27E0,0x0200,
  0x4800,0x0100,
  0x9100,0x4080,
  0x90AA,0x8080,
  0x8080,0x8080,
  0x4041,0x0100,
  0x2041,0x0200,
  0x1822,0x0C00,
  0x0622,0x3000,
  0x01FF,0xC000,
  0x0150,0x2000,
  0x0205,0x4000,
  0x0150,0x2000,
  0x0205,0x4000,
  0x0150,0x2000,
  0x0205,0x4000,
  0x01FF,0x8000,
  0x003C,0x0000,

  0x0000,0x0000, /* Bitplane ONE */
  0x00FF,0x8000,
  0x070F,0xF000,
  0x181F,0xFC00,
  0x37FF,0xFE00,
  0x6EFF,0xBF00,
  0x6F55,0x7F00,
  0x7F7F,0x7F00,
  0x3FBE,0xFE00,
  0x1FBE,0xFC00,
  0x07DD,0xF000,
  0x01DD,0xC000,
  0x0000,0x0000,
  0x00AF,0xC000,
  0x01FA,0x8000,
  0x00AF,0xC000,
  0x01FA,0x8000,
  0x00AF,0xC000,
  0x01FA,0x8000,
  0x0000,0x0000,
  0x0000,0x0000
};

/* The Image structure for the dark lamp: */
struct Image lamp_off=
{
  0, 0,          /* LeftEdge, TopEdge */
  25, 21,        /* Width, Height */
  2,             /* Depth */
  lamp_off_data, /* ImageData */
  0x03, 0x00,    /* PlanePick, PlaneOnOff */
  NULL           /* NextImage */
};



/* The Image data for the light lamp: */
/* Remember that Image data must ALWAYS be placed in chip memory: */
USHORT chip lamp_on_data[84]=
{
  0x00FF,0x8000, /* Bitplane ZERO */
  0x07FF,0xF000,
  0x1FFF,0xFC00,
  0x3FFF,0xFE00,
  0x7FFF,0xFF00,
  0xFFFF,0xFF80,
  0xFFFF,0xFF80,
  0xFFFF,0xFF80,
  0x7FFF,0xFF00,
  0x3FFF,0xFE00,
  0x1FFF,0xFC00,
  0x07FF,0xF000,
  0x01FF,0xC000,
  0x0150,0x2000,
  0x0205,0x4000,
  0x0150,0x2000,
  0x0205,0x4000,
  0x0150,0x2000,
  0x0205,0x4000,
  0x01FF,0x8000,
  0x003C,0x0000,
  
  0x0000,0x0000, /* Bitplane ONE */
  0x00FF,0x8000,
  0x070F,0xF000,
  0x181F,0xFC00,
  0x37FF,0xFE00,
  0x6CFF,0x9F00,
  0x6E00,0x3F00,
  0x7E7F,0x3F00,
  0x3F3E,0x7E00,
  0x1F3E,0x7C00,
  0x079C,0xF000,
  0x019C,0xC000,
  0x0000,0x0000,
  0x00AF,0xC000,
  0x01FA,0x8000,
  0x00AF,0xC000,
  0x01FA,0x8000,
  0x00AF,0xC000,
  0x01FA,0x8000,
  0x0000,0x0000,
  0x0000,0x0000
};

/* The Image structure for the light lamp: */
struct Image lamp_on=
{
  0, 0,         /* LeftEdge, TopEdge */
  25, 21,       /* Width, Height */
  2,            /* Depth */
  lamp_on_data, /* ImageData */
  0x03, 0x00,   /* PlanePick, PlaneOnOff */
  NULL          /* NextImage */
};



struct Gadget my_gadget=
{
  NULL,          /* NextGadget, no more gadgets in the list. */
  40,            /* LeftEdge, 40 pixels out. */
  20,            /* TopEdge, 20 lines down. */
  25,            /* Width, 25 pixels wide. */
  21,            /* Height, 21 pixels lines heigh. */
  GADGHIMAGE|    /* Flags, display an alternative image when selected. */
  GADGIMAGE,     /* The gadget should be rendered as an Image. */
  GADGIMMEDIATE| /* Activation, our program will recieve a message when */
                 /* the user has selected this gadget. */
  TOGGLESELECT,  /* The on/off state of the gadget is toggled each time. */
  BOOLGADGET,    /* GadgetType, a Boolean gadget. */
  (APTR) &lamp_off, /* GadgetRender, a pointer to our unselected Image. */
                 /* (Since Intuition does not know if this will be a */
                 /* pointer to a Border structure or an Image structure, */
                 /* Intuition expects an APTR (normal memory pointer). */
                 /* We will therefore have to calm down the compiler by */
                 /* doing some "casting". We tell the compiler that */
                 /* the pointer to the Image structure is the same thing */
                 /* as a memory pointer (APTR). */
  (APTR) &lamp_on, /* SelectRender, a pointer to the alternative image. */
  NULL,          /* GadgetText, no text connected to this gadget. */
  NULL,          /* MutualExclude, no mutual exclude. */
  NULL,          /* SpecialInfo, NULL since this is a Boolean gadget. */
                 /* (It is not a Proportional/String or Integer gadget) */
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
  GADGETDOWN,    /*             or a gadget has been pressed on. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  &my_gadget,    /* FirstGadget A pointer to my_gadget structure. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "ENLIGHTEN ME",/* Title       Title of the window. */
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
               /* Is the lamp on? */
               /* We check if the SELECTED bit is set: */
               if(my_gadget.Flags & SELECTED)
                 printf("Lamp: ON\n");
               else
							   printf("Lamp: OFF\n");
								 
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
