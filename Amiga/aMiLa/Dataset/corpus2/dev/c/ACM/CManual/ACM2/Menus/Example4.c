/* Example4                                                             */
/* This program opens a normal window to which we connect a menu strip. */
/* The menu will look like this:                                        */
/*                                                                      */
/* Status                                                               */
/* --------------                                                       */
/* | v Readmode | (ghosted)                                             */
/* |   Editmode |                                                       */
/* --------------                                                       */
/*                                                                      */
/* The Readmode item is selected and ghosted, and when the user selects */
/* the Editmode item, it will become disabled (ghosted) while the read- */
/* mode item will be enabled (not ghosted). This means that if the      */
/* program is in "readmode", the user should only be able to chose the  */
/* "editmode", and v.v.                                                 */ 
/*                                                                      */
/* The purpose with this program is to show how you can use the OnMenu  */
/* and OffMenu functions inorder to make an "user-friendly interface".  */



#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/*************************************************************************/
/*                       E D I T M O D E   I T E M                       */
/*************************************************************************/

/* The text for the editmode item: */
struct IntuiText my_editmode_text=
{
  2,          /* FrontPen, black. */
  0,          /* BackPen, not used since JAM1. */
  JAM1,       /* DrawMode, do not change the background. */
  CHECKWIDTH, /* LeftEdge, CHECKWIDTH amount of pixels out. */
              /* This will leave enough space for the check mark. */
  1,          /* TopEdge, 1 line down. */
  NULL,       /* TextAttr, default font. */
  "Editmode", /* IText, the string. */
  NULL        /* NextItem, no link to other IntuiText structures. */
};

/* The MenuItem structure for the editmode item: */
struct MenuItem my_editmode_item=
{
  NULL,            /* NextItem, last item in the list. */
  0,               /* LeftEdge, 0 pixels out. */
  10,              /* TopEdge, 10 lines down. */
  150,             /* Width, 150 pixels wide. */
  10,              /* Height, 10 lines high. */
  ITEMTEXT|        /* Flags, render this item with text. */
  ITEMENABLED|     /*        this item will be enabled. */
  CHECKIT|         /*        it is an attribute item. */
  HIGHCOMP,        /*        complement the colours when highlihted. */
  0xFFFFFFFD,      /* MutualExclude, mutualexclude all items except the */
                   /*                second (this) one. */
  (APTR) &my_editmode_text, /* ItemFill, pointer to the text. */
  NULL,            /* SelectFill, nothing since we complement the col. */
  0,               /* Command, not accessable from the keyboard. */
  NULL,            /* SubItem, ignored by Intuition. */
  MENUNULL,        /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                       R E A D M O D E   I T E M                       */
/*************************************************************************/

/* The text for the readmode item: */
struct IntuiText my_readmode_text=
{
  2,          /* FrontPen, black. */
  0,          /* BackPen, not used since JAM1. */
  JAM1,       /* DrawMode, do not change the background. */
  CHECKWIDTH, /* LeftEdge, CHECKWIDTH amount of pixels out. */
              /* This will leave enough space for the check mark. */
  1,          /* TopEdge, 1 line down. */
  NULL,       /* TextAttr, default font. */
  "Readmode", /* IText, the string. */
  NULL        /* NextItem, no link to other IntuiText structures. */
};

/* The MenuItem structure for the readmode item: */
struct MenuItem my_readmode_item=
{
  &my_editmode_item, /* NextItem, pointer to the second (edit) item. */
  0,                 /* LeftEdge, 0 pixels out. */
  0,                 /* TopEdge, 0 lines down. */
  150,               /* Width, 150 pixels wide. */
  10,                /* Height, 10 lines high. */
  ITEMTEXT|          /* Flags, render this item with text. */
                     /*        this item will be disabled. */
  CHECKIT|           /*        it is an attribute item. */
  CHECKED|           /*        this item is initially selected. */
  HIGHCOMP,          /*        complement the colours when highlihted. */
  0xFFFFFFFE,        /* MutualExclude, mutualexclude all items except the */
                     /*                first (this) one. */
  (APTR) &my_readmode_text, /* ItemFill, pointer to the text. */
  NULL,              /* SelectFill, nothing since we complement the col. */
  0,                 /* Command, not accessable from the keyboard. */
  NULL,              /* SubItem, ignored by Intuition. */
  MENUNULL,          /* NextSelect, no items selected. */
};



/*************************************************************************/
/*                              M E N U                                  */
/*************************************************************************/

/* The Menu structure for the first (and only) menu: */
struct Menu my_menu=
{
  NULL,             /* NextMenu, no more menu structures. */
  0,                /* LeftEdge, left corner. */
  0,                /* TopEdge, for the moment ignored by Intuition. */
  50,               /* Width, 50 pixels wide. */
  0,                /* Height, for the moment ignored by Intuition. */
  MENUENABLED,      /* Flags, this menu will be enabled. */
  "Status",         /* MenuName, the string. */
  &my_readmode_item /* FirstItem, pointer to the first item in the list. */
};



/* Declare a pointer to a Window structure: */ 
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  50,            /* LeftEdge    x position of the window. */
  25,            /* TopEdge     y positio of the window. */
  250,           /* Width       250 pixels wide. */
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
  NULL,          /* CheckMark   Use Intuition's default CheckMark. */
  "Read or Edit", /* Title      Title of the window. */
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
  /* Declare a variable to store the Code value in, and two extra menu */
  /* number variables: */
  USHORT code, menu_number, number;
  
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



          /* Check which item was selected: */
          if( item == &my_readmode_item )
          {
            /* The Readmode (first) item was selected! */
            printf("We are now in READMODE!\n");
            
            /* Disable the Readmode item: */
            number = SHIFTMENU( 0 ) + SHIFTITEM( 0 ) + SHIFTSUB( NOSUB );
            /*       first menu       first item       no subitem. */
            OffMenu( my_window, number );

            /* Enable the Editmode item: */
            number = SHIFTMENU( 0 ) + SHIFTITEM( 1 ) + SHIFTSUB( NOSUB );
            /*       first menu       second item      no subitem. */
            OnMenu( my_window, number );
          }

          if( item == &my_editmode_item )
          {
            /* The Editmode (second) item was selected! */
            printf("We are now in EDITMODE!\n");
            
            /* Disable the Editmode item: */
            number = SHIFTMENU( 0 ) + SHIFTITEM( 1 ) + SHIFTSUB( NOSUB );
            /*       first menu       second item      no subitem. */
            OffMenu( my_window, number );

            /* Enable the Readmode item: */
            number = SHIFTMENU( 0 ) + SHIFTITEM( 0 ) + SHIFTSUB( NOSUB );
            /*       first menu       first item       no subitem. */
            OnMenu( my_window, number );
          }



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
