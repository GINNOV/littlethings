/* Example7                                                              */
/* This program opens a normal window to which we connect a menu strip.  */
/* The menu consists of one small action item with two images.           */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/*************************************************************************/
/*                        F A C E   S L E E P I N G                      */
/*************************************************************************/

USHORT chip face_sleeping_data[]=
{
  0x7FFF,0xFC00, /* Bitplane ZERO */
  0xFE10,0xFE00,
  0xF9D7,0x3E00,
  0xE7D7,0xCE00,
  0xDFD7,0xF600,
  0xDF93,0xF600,
  0xC054,0x0600,
  0xDFD7,0xF600,
  0xC010,0x0600,
  0xFFFF,0xFE00,
  0x7FFF,0xFC00,
	
  0x7FFF,0xFC00, /* Bitplane ONE */
  0xFFFF,0xFE00,
  0xFFFF,0xFE00,
  0xFFFF,0xFE00,
  0xFFFF,0xFE00,
  0xFFFF,0xFE00,
  0xFFBB,0xFE00,
  0xE038,0x0E00,
  0xFFFF,0xFE00,
  0xFFFF,0xFE00,
  0x7FFF,0xFC00
};

/* Image structure for the sleeping face: */
struct Image face_sleeping=
{
  0,          /* LeftEdge, 0 pixels out. */
  0,          /* TopEdge, 0 pixels down. */
  23,         /* Width, 23 pixels wide. */
  11,         /* Height, 11 lines heigh. */
  2,          /* Depth, two Bitplanes. */
  face_sleeping_data, /* ImageData, pointer to the image data. */
  0x3,        /* PlanePick, affect Bitplane zero and one. */
  0x0,        /* PlaneOnOff, do not bother about any Bitplanes. */
  NULL        /* NextImage, no Image structure connected to this one. */
};



/*************************************************************************/
/*                          F A C E   A W A K E                          */
/*************************************************************************/

USHORT chip face_awake_data[]=
{
  0x7FFF,0xFC00, /* Bitplane ZERO */
  0xFE10,0xFE00,
  0xF9D7,0x3E00,
  0xE7D7,0xCE00,
  0xDFD7,0xF600,
  0xDE10,0xF600,
  0xDC10,0x7600,
  0xDC10,0x7600,
  0xC010,0x0600,
  0xFFFF,0xFE00,
  0x7FFF,0xFC00,

  0x7FFF,0xFC00, /* Bitplane ONE */
  0xFFFF,0xFE00,
  0xFE38,0xFE00,
  0xF838,0x3E00,
  0xE038,0x0E00,
  0xE1FF,0x0E00,
  0xE3FF,0x8E00,
  0xE3FF,0x8E00,
  0xFFFF,0xFE00,
  0xFFFF,0xFE00,
  0x7FFF,0xFC00
};

/* Image structure for the awake face: */
struct Image face_awake=
{
  0,          /* LeftEdge, 0 pixels out. */
  0,          /* TopEdge, 0 pixels down. */
  23,         /* Width, 23 pixels wide. */
  11,         /* Height, 11 lines heigh. */
  2,          /* Depth, two Bitplanes. */
  face_awake_data, /* ImageData, pointer to the image data. */
  0x3,        /* PlanePick, affect Bitplane zero and one. */
  0x0,        /* PlaneOnOff, do not bother about any Bitplanes. */
  NULL        /* NextImage, no Image structure connected to this one. */
};



/*************************************************************************/
/*                           M E N U   I T E M                           */
/*************************************************************************/

/* The one and only MenuItem structure: */
struct MenuItem my_item=
{
  NULL,            /* NextItem, this is the one and only item. */
  0,               /* LeftEdge, 0 pixels out. */
  0,               /* TopEdge, 0 lines down. */
  50,              /* Width, 50 pixels wide. */
  11,              /* Height, 11 lines high. */
  ITEMENABLED|     /* Flags, this item will be enabled. */
                   /*        render this item with an Image. */
                   /*        (ITEMTEXT is not set.) */
                   /*        it is an action item. */
                   /*        (CHECKIT is not set.) */
  HIGHIMAGE,       /*        display an alternative Image when highl. */
  0x00000000,      /* MutualExclude, no mutualexclude. */
  (APTR) &face_sleeping, /* ItemFill, pointer to the image. */
  (APTR) &face_awake,    /* SelectFill, pointer to the alternative image. */
  0,               /* Command, no command-key sequence. */
  NULL,            /* SubItem, no subitem list. */
  MENUNULL,        /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                              M E N U                                  */
/*************************************************************************/

/* The Menu structure for the first (and only) menu: */
struct Menu my_menu=
{
  NULL,        /* NextMenu, no more menu structures. */
  0,           /* LeftEdge, left corner. */
  0,           /* TopEdge, for the moment ignored by Intuition. */
  50,          /* Width, 50 pixels wide. */
  0,           /* Height, for the moment ignored by Intuition. */
  MENUENABLED, /* Flags, this menu will be enabled. */
  "Face",      /* MenuName, the string. */
  &my_item     /* FirstItem, pointer to the first item in the list. */
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
                 /*             user has selected the Close window gad. */
  MENUPICK,
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom gadgets. */
  NULL,          /* CheckMark   Use Intuition's default checkmark. */
  "Person",      /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
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
  
  /* If we recieve a MENUPICK event, the Code field of the message */
  /* structure will contain the menu number of the first selected item. */
  /* Declare a variable to store the Code value in, and an extra menu */
  /* number variable: */
  USHORT code, menu_number;
  
  /* Declare a MenuItem pointer: */
  struct MenuItem *item;
  
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



  SetMenuStrip( my_window, &my_menu );
  printf("Menustrip connected to window!\n");


  close_me = FALSE;

  /* Stay in the while loop until the user has selected the Close window */
  /* gadget: */
  while( close_me == FALSE )
  {
    /* Wait until we have recieved a message: */
    Wait( 1 << my_window->UserPort->mp_SigBit );

    /* As long as we collect messages sucessfully we stay in the loop: */
    while(my_message=(struct IntuiMessage *) GetMsg( my_window->UserPort ))
    {
      /* After we have collected the message we can read it, and save any */
      /* important values which we maybe want to check later: */
      class = my_message->Class;
      code = my_message->Code;


      /* After we have read it we reply as fast as possible: */
      /* REMEMBER! Do never try to read a message after you have replied! */
      /* Some other process has maybe changed it. */
      ReplyMsg( my_message );

      /* Check which IDCMP flag was sent: */
      if( class == CLOSEWINDOW )
        close_me=TRUE; /* The user selected the Close window gadget! */  

      if(class == MENUPICK)
      {
        printf("\nMenu pick!\n");
        menu_number = code;
        
        while( menu_number != MENUNULL )
        {
          /* Get the address of the item: */
          item = (struct MenuItem *) ItemAddress( &my_menu, menu_number );


          /* Print out the menu number plus etc: */
          printf("menu_number= %d\n", menu_number );
          printf("MENUNUM = %d\n", MENUNUM(menu_number) );
          printf("ITEMNUM = %d\n", ITEMNUM(menu_number) );
          printf("SUBNUM  = %d\n", SUBNUM(menu_number) );


          /* Get the following item's menu number: */
          menu_number = item->NextSelect;
        }
      }
    }
  }



  printf("Menustrip removed from window!\n");
  ClearMenuStrip( my_window );



  /* Close the window: */
  CloseWindow( my_window );



  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}