/* Example8                                                            */
/* Same as Example1 except that we this time will verify any menu      */
/* operations. If the user tries to activate this program's menu we    */
/* check if the position of the pointer, and if it is somewhere at the */
/* top of the window (less than 10 lines down) the menu operation will */
/* continue as normal, else we cancel the menu operation.              */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/*************************************************************************/
/*                         F O U R T H   I T E M                         */
/*************************************************************************/

/* The text for the fourth item: */
struct IntuiText my_fourth_text=
{
  2,            /* FrontPen, black. */
  0,            /* BackPen, not used since JAM1. */
  JAM1,         /* DrawMode, do not change the background. */
  CHECKWIDTH,   /* LeftEdge, CHECKWIDTH amount of pixels out. */
                /* This will leave enough space for the check mark. */
  1,            /* TopEdge, 1 line down. */
  NULL,         /* TextAttr, default font. */
  "Italic",     /* IText, the string. */
  NULL          /* NextItem, no link to other IntuiText structures. */
};

/* The MenuItem structure for the fourth item: */
struct MenuItem my_fourth_item=
{
  NULL,            /* NextItem, this is the last item in the list. */
  0,               /* LeftEdge, 0 pixels out. */
  30,              /* TopEdge, 30 lines down. */
  150,             /* Width, 150 pixels wide. */
  10,              /* Height, 10 lines high. */
  ITEMTEXT|        /* Flags, render this item with text. */
  ITEMENABLED|     /*        this item will be enabled. */
  CHECKIT|         /*        it is an attribute item. */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0x00000001,      /* MutualExclude, mutualexclude the first item only. */
  (APTR) &my_fourth_text, /* ItemFill, pointer to the text. */
  NULL,            /* SelectFill, nothing since we complement the col. */
  0,               /* Command, no command-key sequence. */
  NULL,            /* SubItem, no subitem list. */
  MENUNULL,        /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                          T H I R D   I T E M                          */
/*************************************************************************/

/* The text for the third item: */
struct IntuiText my_third_text=
{
  2,            /* FrontPen, black. */
  0,            /* BackPen, not used since JAM1. */
  JAM1,         /* DrawMode, do not change the background. */
  CHECKWIDTH,   /* LeftEdge, CHECKWIDTH amount of pixels out. */
                /* This will leave enough space for the check mark. */
  1,            /* TopEdge, 1 line down. */
  NULL,         /* TextAttr, default font. */
  "Underlined", /* IText, the string. */
  NULL          /* NextItem, no link to other IntuiText structures. */
};

/* The MenuItem structure for the third item: */
struct MenuItem my_third_item=
{
  &my_fourth_item, /* NextItem, linked to the fourth item. */
  0,               /* LeftEdge, 0 pixels out. */
  20,              /* TopEdge, 20 lines down. */
  150,             /* Width, 150 pixels wide. */
  10,              /* Height, 10 lines high. */
  ITEMTEXT|        /* Flags, render this item with text. */
  ITEMENABLED|     /*        this item will be enabled. */
  CHECKIT|         /*        it is an attribute item. */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0x00000001,      /* MutualExclude, mutualexclude the first item only. */
  (APTR) &my_third_text, /* ItemFill, pointer to the text. */
  NULL,            /* SelectFill, nothing since we complement the col. */
  0,               /* Command, no command-key sequence. */
  NULL,            /* SubItem, no subitem list. */
  MENUNULL,        /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                         S E C O N D   I T E M                         */
/*************************************************************************/

/* The text for the second item: */
struct IntuiText my_second_text=
{
  2,          /* FrontPen, black. */
  0,          /* BackPen, not used since JAM1. */
  JAM1,       /* DrawMode, do not change the background. */
  CHECKWIDTH, /* LeftEdge, CHECKWIDTH amount of pixels out. */
              /* This will leave enough space for the check mark. */
  1,          /* TopEdge, 1 line down. */
  NULL,       /* TextAttr, default font. */
  "Bold",     /* IText, the string. */
  NULL        /* NextItem, no link to other IntuiText structures. */
};

/* The MenuItem structure for the second item: */
struct MenuItem my_second_item=
{
  &my_third_item,  /* NextItem, linked to the third item. */
  0,               /* LeftEdge, 0 pixels out. */
  10,              /* TopEdge, 10 lines down. */
  150,             /* Width, 150 pixels wide. */
  10,              /* Height, 10 lines high. */
  ITEMTEXT|        /* Flags, render this item with text. */
  ITEMENABLED|     /*        this item will be enabled. */
  CHECKIT|         /*        it is an attribute item. */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0x00000001,      /* MutualExclude, mutualexclude the first item only. */
  (APTR) &my_second_text, /* ItemFill, pointer to the text. */
  NULL,            /* SelectFill, nothing since we complement the col. */
  0,               /* Command, no command-key sequence. */
  NULL,            /* SubItem, no subitem list. */
  MENUNULL,        /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                          F I R S T   I T E M                          */
/*************************************************************************/

/* The text for the first item: */
struct IntuiText my_first_text=
{
  2,          /* FrontPen, black. */
  0,          /* BackPen, not used since JAM1. */
  JAM1,       /* DrawMode, do not change the background. */
  CHECKWIDTH, /* LeftEdge, CHECKWIDTH amount of pixels out. */
              /* This will leave enough space for the check mark. */
  1,          /* TopEdge, 1 line down. */
  NULL,       /* TextAttr, default font. */
  "Plain",    /* IText, the string. */
  NULL        /* NextItem, no link to other IntuiText structures. */
};

/* The MenuItem structure for the first item: */
struct MenuItem my_first_item=
{
  &my_second_item, /* NextItem, linked to the second item. */
  0,               /* LeftEdge, 0 pixels out. */
  0,               /* TopEdge, 0 lines down. */
  150,             /* Width, 150 pixels wide. */
  10,              /* Height, 10 lines high. */
  ITEMTEXT|        /* Flags, render this item with text. */
  ITEMENABLED|     /*        this item will be enabled. */
  CHECKIT|         /*        it is an attribute item. */
  CHECKED|         /*        this item is initially selected. */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0xFFFFFFFE,      /* MutualExclude, mutualexclude all items except the */
                   /*                first one. */
  (APTR) &my_first_text, /* ItemFill, pointer to the text. */
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
  "Mode",        /* MenuName, the string. */
  &my_first_item /* FirstItem, pointer to the first item in the list. */
};



/* Declare a pointer to a Window structure: */ 
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  0,             /* LeftEdge    x position of the window. */
  0,             /* TopEdge     y positio of the window. */
  320,           /* Width       320 pixels wide. */
  100,           /* Height      100 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  CLOSEWINDOW|   /* IDCMPFlags  The window will give us a message if the */
                 /*             user has selected the Close window gad. */
  MENUPICK|      /*             Or if the user has done a menu operation, */
  MENUVERIFY,    /*             or if the user tries to activate a menu. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "Style Editor",/* Title       Title of the window. */
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



      /* Before we reply we need to see if we have recieved a MENUVERIFY */
      /* message: */
      
      if( class == MENUVERIFY )
      {
        /* Yes, we have recieved a MENUVERIFY message!                    */
        /* The user wants to activate a menu, but the problem is that we  */
        /* do not know if it is our window's menu that will be activated, */
        /* or some other window's menu. We can however check it by        */
        /* examining the Code field of the message. If it is equal to     */
        /* MENUWAITING, it means that it is not your window's menu that   */
        /* will be activated, but if Code is equal to MENUHOT it means it */
        /* is is your window's menu that will be activated!               */

        if( code == MENUWAITING )
        {
          /* It is not your window's menu that will be activated! */
          
          /* Your program can take a pause if necessary. You maybe want */
          /* to finish of with some drawings, so your program does not  */
          /* trash any menus. This is especially important if you are   */
          /* using the low-level graphics rutines since they do not     */
          /* bother about, windows etc, and will draw over and destroy  */
          /* anything in their way.                                     */
          
          /* Once the program is ready it should reply the message, and */
          /* the menu will be activated.                                */
        
          printf("Another program's menu will be displayed!\n");
        }
        else
          if( code == MENUHOT )
          {
            /* It is your window's menu that will be activated! */
            
            /* You can now take a pause and finish of with something     */
            /* before you let Intuition activate the menu, or you can    */
            /* even stop the whole menu operation if necessary. If you   */
            /* are writing a paint program you maybe only want the user  */
            /* to be able to activate the menu if the pointer is at the  */
            /* top of the display. That would mean that the user can     */
            /* draw with the right mouse button, and when the user wants */
            /* to make a menu choice, he/she simply moves the pointer to */
            /* the top of the display, and then presses the right mouse  */
            /* button.                                                   */
            
            /* We will now check if the pointer is somewhere at the top  */
            /* of the display: */
            if( my_window->MouseY < 10)
            {
              /* The Y coordinate of the pointer is at least less than   */
              /* 10 lines below the TopEdge of the window.               */
            
              /* The menu operation should continue as soon as possible! */
              printf("OK!\n");
            }
            else
            {
              /* The pointer is below the Title bar of the window! */
              /* Cancel the whole menu operation! */
              
              /* To cancel a menu operation you need to change the Code   */
              /* field to MENUCANCEL. IMPORTANT! Do not change the code   */
              /* variable since it is just a copy of the real Code value. */
              /* What we need to do is to change the real value, and that */
              /* is still OK since we have not replied yet.               */
    
              my_message->Code=MENUCANCEL;

              printf("Menu operation canceled!\n");
            }
          }
      }

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
