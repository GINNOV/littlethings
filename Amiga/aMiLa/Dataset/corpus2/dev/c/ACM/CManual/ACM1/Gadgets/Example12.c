/* Example12                                                             */
/* This program will open a SuperBitmap window which is connected to the */
/* Workbench Screen. The window will use all System Gadgets, and will    */
/* close first when the user has selected the System gadget Close        */
/* window. Inside the window we have put two Proportional gadgets, one   */
/* on the right side, and one at the bottom. With help of these two      */
/* gadgets, the user can move around the BitMap.                         */
/*                                                                       */
/* This example is for experienced programmers only, and uses some       */
/* functions etc which we have not discussed yet. I have, however,       */
/* included it here since it is a good example on how you can combine    */
/* Proportional gadgets with SuperBitmap windows.                        */



#include <intuition/intuition.h>



#define WIDTH      320
#define MAX_WIDTH  640
#define HEIGHT     128
#define MAX_HEIGHT 256
#define DEPTH        2 /* 4 colours. */



/* Tell the C compiler that the function draw_some_boxes will return: */
void draw_some_boxes(); /* Return nothing (void). */



/* Declare three pointers to the three libraries we are going to open: */
struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct LayersBase *LayersBase;



/***********************************************/
/* THE RIGHT PROPORTIONAL GADGET's STRUCTURES: */
/***********************************************/

/* We need to declare an Image structure for the knob, but since */
/* Intuition will take care of the size etc of the knob, we do not need */
/* to initialize the Image structure: */
struct Image my_right_image;

struct PropInfo my_right_prop_info=
{
  FREEVERT|       /* Flags, the knob should be moved vertically, and */
  AUTOKNOB,       /* Intuition should take care of the knob image. */
  0,              /* HorizPot, 0 since we will not move the knob hor. */
  0,              /* VertPot, start position of the knob. */
  0,              /* HorizBody. 0 since we will not move the knob hor. */
  MAXBODY * HEIGHT / MAX_HEIGHT, /* VertBody. */

  /* These variables are initialized and maintained by Intuition: */

  0,              /* CWidth */
  0,              /* CHeight */
  0, 0,           /* HPotRes, VPotRes */
  0,              /* LeftBorder */
  0               /* TopBorder */
};

struct Gadget my_right_gadget=
{
  NULL,            /* NextGadget, no more gadgets in the list. */
  -15,             /* LeftEdge, 15 pixels out from the right side. */
    9,             /* TopEdge, 9 lines down. */
   16,             /* Width, 16 pixels wide. */
  -17,             /* Height, 17 lines less than the heigh of the wind. */
  GADGHCOMP|       /* Flags, complement the colours when act. */
  GRELRIGHT|       /* LeftEdge relative to the right border. */
  GRELHEIGHT,      /* Height relative to the height of the window. */
  GADGIMMEDIATE|   /* Activation, our program will recieve a message */
  RELVERIFY|       /* when the user has selected this gadget, and when */
                   /* the user has released it. We will also recieve a */ 
  FOLLOWMOUSE,     /* message when the mouse moves while this gadget is */
                   /* activated. */
  PROPGADGET|      /* GadgetType, a Proportional gadget. */
  GZZGADGET,       /* Put the gadget in the Outer window. */
  (APTR) &my_right_image, /* GadgetRender, the knob's Image structure. */
  NULL,            /* SelectRender, NULL since we do not supply the */
                   /* gadget with an alternative image. */
  NULL,            /* GadgetText, no text. */
  NULL,            /* MutualExclude, no mutual exclude. */
  (APTR) &my_right_prop_info, /* SpecialInfo, our PropInfo structure. */
  0,               /* GadgetID, no id. */
  NULL             /* UserData, no user data connected to the gadget. */
};



/************************************************/
/* THE BOTTOM PROPORTIONAL GADGET's STRUCTURES: */
/************************************************/

/* We need to declare an Image structure for the knob, but since */
/* Intuition will take care of the size etc of the knob, we do not need */
/* to initialize the Image structure: */
struct Image my_bottom_image;

struct PropInfo my_bottom_prop_info=
{
  FREEHORIZ|      /* Flags, the knob should be moved horizontally, and */
  AUTOKNOB,       /* Intuition should take care of the knob image. */
  0,              /* HorizPot, start position of the knob. */
  0,              /* VertPot, 0 since we will not move the knob ver. */
  MAXBODY * WIDTH / MAX_WIDTH, /* HorizBody. */
  0,              /* VertBody, 0 since we will not move the knob ver. */

  /* These variables are initialized and maintained by Intuition: */

  0,              /* CWidth */
  0,              /* CHeight */
  0, 0,           /* HPotRes, VPotRes */
  0,              /* LeftBorder */
  0               /* TopBorder */
};

struct Gadget my_bottom_gadget=
{
  &my_right_gadget,/* NextGadget, no more gadgets in the list. */
    1,             /* LeftEdge, 1 pixel out from the left side. */
   -8,             /* TopEdge, 8 lines above the bottom border. */
  -15,             /* Width, 15 pixels less wide than the window. */
    9,             /* Height, 9 lines heigh. */
  GADGHCOMP|       /* Flags, complement the colours when act. */
  GRELBOTTOM|      /* TopEdge relative to the bottom border. */
  GRELWIDTH,       /* Width relative to the width of the window. */
  GADGIMMEDIATE|   /* Activation, our program will recieve a message */
  RELVERIFY|       /* when the user has selected this gadget, and when */
                   /* the user has released it. We will also recieve a */ 
  FOLLOWMOUSE|     /* message when the mouse moves while this gadget is */
                   /* activated. */
  BOTTOMBORDER,    /* Make the bottom border of the window big enough */
                   /* for this gadge. */
  PROPGADGET|      /* GadgetType, a Proportional gadget. */
  GZZGADGET,       /* Put the gadget in the Outer window. */
  (APTR) &my_bottom_image,/* GadgetRender, the knob's Image structure. */
  NULL,            /* SelectRender, NULL since we do not supply the */
                   /* gadget with an alternative image. */
  NULL,            /* GadgetText, no text. */
  NULL,            /* MutualExclude, no mutual exclude. */
  (APTR) &my_bottom_prop_info, /* SpecialInfo, our PropInfo structure. */
  0,               /* GadgetID, no id. */
  NULL             /* UserData, no user data connected to the gadget. */
};



/******************************/
/* OPEN A SUPERBITMAP WINDOW: */
/******************************/
 
/*************************************************************/
/* 1. Declare and initialize a NewWindow structure with your */
/*    requirements:                                          */
/*************************************************************/

/* Declare a pointer to a Window structure: */ 
struct Window *my_window;

/* Declare and initialize your NewWindow structure: */
struct NewWindow my_new_window=
{
  10,            /* LeftEdge    x position of the window. */
  30,            /* TopEdge     y positio of the window. */
  WIDTH,         /* Width       200 pixels wide. */
  HEIGHT,        /* Height      dsfsafsadfdsafsad50 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  CLOSEWINDOW|   /* IDCMPFlags  The window will give us a message if the */
                 /*             user has selected the Close window gad, */
  GADGETDOWN|    /*             or a gadget has been pressed on, or */
  GADGETUP|      /*             a gadge has been released, or */
  NEWSIZE|       /*             the user has changed the size or */
  MOUSEMOVE,     /*             the mouse moved while a gadget was act. */
  SUPER_BITMAP|  /* Flags       SuperBitMap. (No refreshing necessary) */
  GIMMEZEROZERO| /*             It is also a Gimmezerozero window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  &my_bottom_gadget, /* FirstGadget  Pointer to the first gadget. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "SuperBitMap", /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      We will change this later. */
  50,            /* MinWidth    We will not allow the window to become */
  50,            /* MinHeight   smaller than 50 x 50, and not bigger */
  MAX_WIDTH,     /* MaxWidth    than MAX_WIDTH x MAX_HEIGHT. */
  MAX_HEIGHT,    /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/**********************************/
/* 2. Declare a BitMap structure: */
/**********************************/

struct BitMap my_bitmap;



main()
{
  /* Boolean variable used for the while loop: */
  BOOL close_me;
  
  BOOL fix_window;
 
  int x, y;
  int new_x, new_y; 
  int delta_x, delta_y;

  /* Declare two pointers which the ScrollLayer() function needs: */
  struct Layer *my_layer;
  struct Layer_Info *my_layer_info;
 
  /* Declare a variable in which we will store the IDCMP flag: */
  ULONG class;

  /* Declare a pointer to an IntuiMessage structure: */
  struct IntuiMessage *my_message;

  /* Variable used for the loops: */
  int loop;



  /* Before we can use Intuition we need to open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* Before we can use the function AllocRaster() etc we need to open */
  /* the graphics Library. (See chapter "Amiga C" for more information) */
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0);

  if( GfxBase == NULL )
  {
    /* Could NOT open the Graphics Library! */

    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();
  }


  /* Before we can use the function ScrollLayer() etc we need to open */
  /* the layers Library. (See chapter "Amiga C" for more information) */
  LayersBase = (struct LayersBase *)
    OpenLibrary( "layers.library", 0);

  if( LayersBase == NULL )
  {
    /* Could NOT open the Layers Library! */

    /* Close the Graphics Library since we have opened it: */
    CloseLibrary( GfxBase );

    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();
  }



  /**********************************************************/
  /* 3. Initialize your own BitMap by calling the function: */
  /**********************************************************/

  InitBitMap( &my_bitmap, DEPTH, MAX_WIDTH, MAX_HEIGHT );

  /* &my_bitmap: A pointer to the my_bitmap structure. */
  /* DEPTH:      Number of bitplanes to use. */
  /* MAX_WIDTH:  The width of the BitMap. */
  /* MAX_HEIGHT: The height of the BitMap. */



  /**********************************************/
  /* 4. Allocate display memory for the BitMap: */
  /**********************************************/

  for( loop=0; loop < DEPTH; loop++)
    if((my_bitmap.Planes[loop] = (PLANEPTR)
      AllocRaster( MAX_WIDTH, MAX_HEIGHT )) == NULL )
    {
      /* PANIC! Not enough memory */

      /* Deallocate the display memory, Bitplan by Bitplan. */ 
      for( loop=0; loop < DEPTH; loop++)
        if( my_bitmap.Planes[loop] ) /* Deallocate this Bitplan? */
          FreeRaster( my_bitmap.Planes[loop], MAX_WIDTH, MAX_HEIGHT );

      /* Close the Layers Library since we have opened it: */
      CloseLibrary( LayersBase );

      /* Close the Graphics Library since we have opened it: */
      CloseLibrary( GfxBase );

      /* Close the Intuition Library since we have opened it: */
      CloseLibrary( IntuitionBase );

      exit();
    }



  /***************************/
  /* 5. Clear all Bitplanes: */
  /***************************/
  
  for( loop=0; loop < DEPTH; loop++)
    BltClear( my_bitmap.Planes[loop], RASSIZE( MAX_WIDTH, MAX_HEIGHT ), 0);

  /* The memory we allocated for the Bitplanes, is normaly "dirty", and */
  /* therefore needs cleaning. We can here use the Blitter to clear the */
  /* memory since it is the fastest way to do it, and the easiest. */
  /* RASSIZE is a macro which calculates memory size for a Bitplane of */
  /* the size WIDTH x HEIGHT. We will later go into more details about */
  /* these functions etc, so do not worry about them... yet. */



  /*******************************************************************/
  /* 6. Make sure the NewWindow's BitMap pointer is pointing to your */
  /*    BitMap structure:                                            */
  /*******************************************************************/

  my_new_window.BitMap=&my_bitmap;



  /***************************************/
  /* 7. At last you can open the window: */
  /***************************************/

  my_window = (struct Window *) OpenWindow( &my_new_window );

  /* Have we opened the window succesfully? */
  if(my_window == NULL)
  {
    /* Could NOT open the Window! */

    /* Deallocate the display memory, Bitplan by Bitplan. */ 
    for( loop=0; loop < DEPTH; loop++)
      if( my_bitmap.Planes[loop] ) /* Deallocate this Bitplan? */
        FreeRaster( my_bitmap.Planes[loop], MAX_WIDTH, MAX_HEIGHT );

    /* Close the Layers Library since we have opened it: */
    CloseLibrary( LayersBase );

    /* Close the Graphics Library since we have opened it: */
    CloseLibrary( GfxBase );

    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();
  }



  /* We have opened the window, and everything seems to be OK. */


  
  /* Initialize the two pointers which will be used by the ScrollLayer */
  /* function: */
  my_layer_info=&(my_window->WScreen->LayerInfo);
  my_layer=my_window->RPort->Layer;



  /* We will now draw some boxes in different colours: */
  draw_some_boxes();



  /* We can for the moment see the top left corner of the BitMap: */
  x=0;
  y=0;

  /* The window does not need to be redrawn: */
  fix_window=FALSE;
  
  /* The user wants to run the program for the momnt. */
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

        case MOUSEMOVE:    /* The user moved the mouse while one of the */
                           /* Proportional gadgets was activated: */ 
               fix_window=TRUE; /* Redraw the display. */
               break;             

        case NEWSIZE:      /* The user has resized the window: */
               /* Change size of the knobs: */
               ModifyProp
               (
                 &my_right_gadget,           /* Pointer to the gadget. */
                 my_window,                  /* Pointer to the window. */
                 NULL,                       /* Not a requester gadget. */
                 my_right_prop_info.Flags,   /* Flags, no change. */
                 0,                          /* HorizPot */
                 my_right_prop_info.VertPot, /* VertPot, no change. */
                 0,                          /* HorizBody */
                                             /* VertBody: */
                 (ULONG) MAXBODY*my_window->Height/MAX_HEIGHT
               );
               ModifyProp
               (
                 &my_bottom_gadget,            /* Pointer to the gadget. */
                 my_window,                    /* Pointer to the window. */
                 NULL,                         /* Not a req. gadget. */
                 my_bottom_prop_info.Flags,    /* Flags, no change. */
                 my_bottom_prop_info.HorizPot, /* HorizPot, no change. */
                 0,                            /* VertPot */
                                               /* HorizBody: */
                 (ULONG) MAXBODY*my_window->Width/MAX_WIDTH,
                 0                             /* VertBody: */
               );
               fix_window=TRUE; /* Redraw the display. */
               break;
        
        case GADGETDOWN:   /* The user has selected one of the gadgets: */
               fix_window=TRUE; /* Redraw the display. */
               break;
             
        case GADGETUP:     /* The user has released one of the gadgets: */
               fix_window=TRUE; /* Redraw the display. */
               break;
      }    
    }



    /* Should we update the window's display? */
    if(fix_window)
    {
      fix_window=FALSE;
            
      /* Calculate what part of the BitMap we should display: */
      new_x= (MAX_WIDTH - my_bottom_prop_info.HorizBody / (float) MAXBODY
             * MAX_WIDTH) * my_bottom_prop_info.HorizPot / (float) MAXPOT;

      new_y= (MAX_HEIGHT - my_right_prop_info.VertBody / (float) MAXBODY
             * MAX_HEIGHT) * my_right_prop_info.VertPot / (float) MAXPOT;

      delta_x=new_x-x;
      delta_y=new_y-y;

      x=new_x;
      y=new_y;

      ScrollLayer( my_layer_info, my_layer, delta_x, delta_y );
    }
  }



  /********************************************************************/
  /* 8. Do not forget to close the window, AND deallocate the display */
  /*    memory:                                                       */
  /********************************************************************/

  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );

  /* Deallocate the display memory, Bitplan by Bitplan. */ 
  for( loop=0; loop < DEPTH; loop++)
    if( my_bitmap.Planes[loop] ) /* Deallocate this Bitplan? */
      FreeRaster( my_bitmap.Planes[loop], MAX_WIDTH, MAX_HEIGHT );



  /* Close the Layers Library since we have opened it: */
  CloseLibrary( LayersBase );

  /* Close the Graphics Library since we have opened it: */
  CloseLibrary( GfxBase );

  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}



/* This function draws some coloured boxes: */
/* Returns nothing. */
void draw_some_boxes()
{
  int x, y;
  UBYTE colour;
  

  colour=1; /* Set colour to 1, white. */

  /* Set Draw Mode to normal: */
  SetDrMd( my_window->RPort, JAM1 );
  
  for(x=0; x < MAX_WIDTH/40-2; x++)
    for(y=0; y < MAX_HEIGHT/20-2; y++)
    {
      /* New colour to draw with */
      SetAPen( my_window->RPort, colour );

      colour++;

      /* If colour is bigger than 3 (Orange) we change colour to 1 */
      /* (white) again. (The boxes will therefore be drawn with the */
      /* colours white, black, orange: */
      if(colour > 3)
        colour=1;
    
      Move( my_window->RPort, x*40+40, y*20+20 ); /* Top left corner. */
      Draw( my_window->RPort, x*40+72, y*20+20 ); /* Out to the right. */
      Draw( my_window->RPort, x*40+72, y*20+36 ); /* Down. */
      Draw( my_window->RPort, x*40+40, y*20+36 ); /* Back to the left. */
      Draw( my_window->RPort, x*40+40, y*20+20 ); /* Up again. */    
    }
}
