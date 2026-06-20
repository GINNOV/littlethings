/* Example6                                                              */
/* This program opens a normal window to which we connect a menu strip.  */
/* The menu consists of six small dices which are all action items. This */
/* example shows how you can use Images inside a menu.                   */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/*************************************************************************/
/*                             D I C E   1                               */
/*************************************************************************/

/* Data for dice 1: */
USHORT chip dice1_data[]=
{
  0x0000,  /* 0000 0000 0000 0000   0 : Black  */
  0x0000,  /* 0000 0000 0000 0000   1 : Orange */
  0x0000,  /* 0000 0000 0000 0000              */
  0x03C0,  /* 0000 0011 1100 0000              */
  0x03C0,  /* 0000 0011 1100 0000              */
  0x0000,  /* 0000 0000 0000 0000              */
  0x0000,  /* 0000 0000 0000 0000              */
  0x0000   /* 0000 0000 0000 0000              */
};

/* Image structure for dice 1: */
struct Image dice1=
{
  0,          /* LeftEdge, 0 pixels out. */
  0,          /* TopEdge, 0 pixels down. */
  16,         /* Width, 16 pixels wide. */
  8,          /* Height, 8 lines heigh. */
  1,          /* Depth, one Bitplane. */
  dice1_data, /* ImageData, pointer to the image data. */
  0x1,        /* PlanePick, affect Bitplane zero. */
  0x2,        /* PlaneOnOff, fill Bitplane one with 1's. */
  NULL        /* NextImage, no Image structure connected to this one. */
};

/* The MenuItem structure for dice 1: */
struct MenuItem my_dice1_item=
{
  NULL,            /* NextItem, this is the last item in the list. */
  0,               /* LeftEdge, 0 pixels out. */
  50,              /* TopEdge, 50 lines down. */
  50,              /* Width, 50 pixels wide. */
  8,               /* Height, 8 lines high. */
  ITEMENABLED|     /* Flags, this item will be enabled. */
                   /*        render this item with an Image. */
                   /*        (ITEMTEXT is not set.) */
                   /*        it is an action item. */
                   /*        (CHECKIT is not set.) */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0x00000000,      /* MutualExclude, no mutualexclude. */
  (APTR) &dice1,   /* ItemFill, pointer to the image. */
  NULL,            /* SelectFill, nothing since we complement the col. */
  0,               /* Command, no command-key sequence. */
  NULL,            /* SubItem, no subitem list. */
  MENUNULL,        /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                             D I C E   2                               */
/*************************************************************************/

/* Data for dice 2: */
USHORT chip dice2_data[]=
{
  0x0000,  /* 0000 0000 0000 0000   0 : Black  */
  0x7800,  /* 0111 1000 0000 0000   1 : Orange */
  0x7800,  /* 0111 1000 0000 0000              */
  0x0000,  /* 0000 0000 0000 0000              */
  0x0000,  /* 0000 0000 0000 0000              */
  0x001E,  /* 0000 0000 0001 1110              */
  0x001E,  /* 0000 0000 0001 1110              */
  0x0000   /* 0000 0000 0000 0000              */
};

/* Image structure for dice 2: */
struct Image dice2=
{
  0,          /* LeftEdge, 0 pixels out. */
  0,          /* TopEdge, 0 pixels down. */
  16,         /* Width, 16 pixels wide. */
  8,          /* Height, 8 lines heigh. */
  1,          /* Depth, one Bitplane. */
  dice2_data, /* ImageData, pointer to the image data. */
  0x1,        /* PlanePick, affect Bitplane zero. */
  0x2,        /* PlaneOnOff, fill Bitplane one with 1's. */
  NULL        /* NextImage, no Image structure connected to this one. */
};

/* The MenuItem structure for dice 2: */
struct MenuItem my_dice2_item=
{
  &my_dice1_item,  /* NextItem, pointer to the next item in the list. */
  0,               /* LeftEdge, 0 pixels out. */
  40,              /* TopEdge, 40 lines down. */
  50,              /* Width, 50 pixels wide. */
  8,               /* Height, 8 lines high. */
  ITEMENABLED|     /* Flags, this item will be enabled. */
                   /*        render this item with an Image. */
                   /*        (ITEMTEXT is not set.) */
                   /*        it is an action item. */
                   /*        (CHECKIT is not set.) */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0x00000000,      /* MutualExclude, no mutualexclude. */
  (APTR) &dice2,   /* ItemFill, pointer to the image. */
  NULL,            /* SelectFill, nothing since we complement the col. */
  0,               /* Command, no command-key sequence. */
  NULL,            /* SubItem, no subitem list. */
  MENUNULL,        /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                             D I C E   3                               */
/*************************************************************************/

/* Data for dice 3: */
USHORT chip dice3_data[]=
{
  0x0000,  /* 0000 0000 0000 0000   0 : Black  */
  0x7800,  /* 0111 1000 0000 0000   1 : Orange */
  0x7800,  /* 0111 1000 0000 0000              */
  0x03C0,  /* 0000 0011 1100 0000              */
  0x03C0,  /* 0000 0011 1100 0000              */
  0x001E,  /* 0000 0000 0001 1110              */
  0x001E,  /* 0000 0000 0001 1110              */
  0x0000   /* 0000 0000 0000 0000              */
};

/* Image structure for dice 3: */
struct Image dice3=
{
  0,          /* LeftEdge, 0 pixels out. */
  0,          /* TopEdge, 0 pixels down. */
  16,         /* Width, 16 pixels wide. */
  8,          /* Height, 8 lines heigh. */
  1,          /* Depth, one Bitplane. */
  dice3_data, /* ImageData, pointer to the image data. */
  0x1,        /* PlanePick, affect Bitplane zero. */
  0x2,        /* PlaneOnOff, fill Bitplane one with 1's. */
  NULL        /* NextImage, no Image structure connected to this one. */
};

/* The MenuItem structure for dice 3: */
struct MenuItem my_dice3_item=
{
  &my_dice2_item,  /* NextItem, pointer to the next item in the list. */
  0,               /* LeftEdge, 0 pixels out. */
  30,              /* TopEdge, 30 lines down. */
  50,              /* Width, 50 pixels wide. */
  8,               /* Height, 8 lines high. */
  ITEMENABLED|     /* Flags, this item will be enabled. */
                   /*        render this item with an Image. */
                   /*        (ITEMTEXT is not set.) */
                   /*        it is an action item. */
                   /*        (CHECKIT is not set.) */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0x00000000,      /* MutualExclude, no mutualexclude. */
  (APTR) &dice3,   /* ItemFill, pointer to the image. */
  NULL,            /* SelectFill, nothing since we complement the col. */
  0,               /* Command, no command-key sequence. */
  NULL,            /* SubItem, no subitem list. */
  MENUNULL,        /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                             D I C E   4                               */
/*************************************************************************/

/* Data for dice 4: */
USHORT chip dice4_data[]=
{
  0x0000,  /* 0000 0000 0000 0000   0 : Black  */
  0x781E,  /* 0111 1000 0001 1110   1 : Orange */
  0x781E,  /* 0111 1000 0001 1110              */
  0x0000,  /* 0000 0000 0000 0000              */
  0x0000,  /* 0000 0000 0000 0000              */
  0x781E,  /* 0111 1000 0001 1110              */
  0x781E,  /* 0111 1000 0001 1110              */
  0x0000   /* 0000 0000 0000 0000              */
};

/* Image structure for dice 4: */
struct Image dice4=
{
  0,          /* LeftEdge, 0 pixels out. */
  0,          /* TopEdge, 0 pixels down. */
  16,         /* Width, 16 pixels wide. */
  8,          /* Height, 8 lines heigh. */
  1,          /* Depth, one Bitplane. */
  dice4_data, /* ImageData, pointer to the image data. */
  0x1,        /* PlanePick, affect Bitplane zero. */
  0x2,        /* PlaneOnOff, fill Bitplane one with 1's. */
  NULL        /* NextImage, no Image structure connected to this one. */
};

/* The MenuItem structure for dice 4: */
struct MenuItem my_dice4_item=
{
  &my_dice3_item,  /* NextItem, pointer to the next item in the list. */
  0,               /* LeftEdge, 0 pixels out. */
  20,              /* TopEdge, 20 lines down. */
  50,              /* Width, 50 pixels wide. */
  8,               /* Height, 8 lines high. */
  ITEMENABLED|     /* Flags, this item will be enabled. */
                   /*        render this item with an Image. */
                   /*        (ITEMTEXT is not set.) */
                   /*        it is an action item. */
                   /*        (CHECKIT is not set.) */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0x00000000,      /* MutualExclude, no mutualexclude. */
  (APTR) &dice4,   /* ItemFill, pointer to the image. */
  NULL,            /* SelectFill, nothing since we complement the col. */
  0,               /* Command, no command-key sequence. */
  NULL,            /* SubItem, no subitem list. */
  MENUNULL,        /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                             D I C E   5                               */
/*************************************************************************/

/* Data for dice 5: */
USHORT chip dice5_data[]=
{
  0x0000,  /* 0000 0000 0000 0000   0 : Black  */
  0x781E,  /* 0111 1000 0001 1110   1 : Orange */
  0x781E,  /* 0111 1000 0001 1110              */
  0x03C0,  /* 0000 0011 1100 0000              */
  0x03C0,  /* 0000 0011 1100 0000              */
  0x781E,  /* 0111 1000 0001 1110              */
  0x781E,  /* 0111 1000 0001 1110              */
  0x0000   /* 0000 0000 0000 0000              */
};

/* Image structure for dice 5: */
struct Image dice5=
{
  0,          /* LeftEdge, 0 pixels out. */
  0,          /* TopEdge, 0 pixels down. */
  16,         /* Width, 16 pixels wide. */
  8,          /* Height, 8 lines heigh. */
  1,          /* Depth, one Bitplane. */
  dice5_data, /* ImageData, pointer to the image data. */
  0x1,        /* PlanePick, affect Bitplane zero. */
  0x2,        /* PlaneOnOff, fill Bitplane one with 1's. */
  NULL        /* NextImage, no Image structure connected to this one. */
};

/* The MenuItem structure for dice 5: */
struct MenuItem my_dice5_item=
{
  &my_dice4_item,  /* NextItem, pointer to the next item in the list. */
  0,               /* LeftEdge, 0 pixels out. */
  10,              /* TopEdge, 10 lines down. */
  50,              /* Width, 50 pixels wide. */
  8,               /* Height, 8 lines high. */
  ITEMENABLED|     /* Flags, this item will be enabled. */
                   /*        render this item with an Image. */
                   /*        (ITEMTEXT is not set.) */
                   /*        it is an action item. */
                   /*        (CHECKIT is not set.) */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0x00000000,      /* MutualExclude, no mutualexclude. */
  (APTR) &dice5,   /* ItemFill, pointer to the image. */
  NULL,            /* SelectFill, nothing since we complement the col. */
  0,               /* Command, no command-key sequence. */
  NULL,            /* SubItem, no subitem list. */
  MENUNULL,        /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                             D I C E   6                               */
/*************************************************************************/

/* Data for dice 6: */
USHORT chip dice6_data[]=
{
  0x0000,  /* 0000 0000 0000 0000   0 : Black  */
  0x7BDE,  /* 0111 1011 1101 1110   1 : Orange */
  0x7BDE,  /* 0111 1011 1101 1110              */
  0x0000,  /* 0000 0000 0000 0000              */
  0x0000,  /* 0000 0000 0000 0000              */
  0x7BDE,  /* 0111 1011 1101 1110              */
  0x7BDE,  /* 0111 1011 1101 1110              */
  0x0000   /* 0000 0000 0000 0000              */
};

/* Image structure for dice 6: */
struct Image dice6=
{
  0,          /* LeftEdge, 0 pixels out. */
  0,          /* TopEdge, 0 pixels down. */
  16,         /* Width, 16 pixels wide. */
  8,          /* Height, 8 lines heigh. */
  1,          /* Depth, one Bitplane. */
  dice6_data, /* ImageData, pointer to the image data. */
  0x1,        /* PlanePick, affect Bitplane zero. */
  0x2,        /* PlaneOnOff, fill Bitplane one with 1's. */
  NULL        /* NextImage, no Image structure connected to this one. */
};

/* The MenuItem structure for dice 6: */
struct MenuItem my_dice6_item=
{
  &my_dice5_item,  /* NextItem, pointer to the next item in the list. */
  0,               /* LeftEdge, 0 pixels out. */
  0,               /* TopEdge, 0 lines down. */
  50,              /* Width, 50 pixels wide. */
  8,               /* Height, 8 lines high. */
  ITEMENABLED|     /* Flags, this item will be enabled. */
                   /*        render this item with an Image. */
                   /*        (ITEMTEXT is not set.) */
                   /*        it is an action item. */
                   /*        (CHECKIT is not set.) */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0x00000000,      /* MutualExclude, no mutualexclude. */
  (APTR) &dice6,   /* ItemFill, pointer to the image. */
  NULL,            /* SelectFill, nothing since we complement the col. */
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
  NULL,          /* NextMenu, no more menu structures. */
  0,             /* LeftEdge, left corner. */
  0,             /* TopEdge, for the moment ignored by Intuition. */
  50,            /* Width, 50 pixels wide. */
  0,             /* Height, for the moment ignored by Intuition. */
  MENUENABLED,   /* Flags, this menu will be enabled. */
  "Dice",        /* MenuName, the string. */
  &my_dice6_item /* FirstItem, pointer to the first item in the list. */
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
  "GAME",        /* Title       Title of the window. */
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
