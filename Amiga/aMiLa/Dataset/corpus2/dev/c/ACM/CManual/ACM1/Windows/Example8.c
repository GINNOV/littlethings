/* Example8                                                              */
/* This program will open a SuperBitMap window which is connected to the */
/* Workbench Screen. Since it is a SuperBitMap we also make the window   */
/* into a Gimmezerozero window. The window will use all System Gadgets,  */
/* and some boxes will be drawn. It will display the window for 30       */
/* seconds, and then close it.                                           */



/* If your program is using Intuition you should include intuition.h: */
#include <intuition/intuition.h>



#define WIDTH  320
#define HEIGHT 150
#define DEPTH    2



struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;



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
  200,           /* Width       200 pixels wide. */
  50,            /* Height      50 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SUPER_BITMAP|  /* Flags       SuperBitMap. (No refreshing necessary) */
  GIMMEZEROZERO| /*             It is also a Gimmezerozero window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "SuperBitMap", /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      We will change this later. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  WIDTH,         /* MaxWidth    than 320 x 150. */
  HEIGHT,        /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/**********************************/
/* 2. Declare a BitMap structure: */
/**********************************/

struct BitMap my_bitmap;



main()
{
  int loop;

  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* Open the Graphics Library: */
  GfxBase = (struct GfxBase *)
    OpenLibrary( "graphics.library", 0);

  if( GfxBase == NULL )
  {
    /* Could NOT open the Graphics Library! */

    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();
  }



  /**********************************************************/
  /* 3. Initialize your own BitMap by calling the function: */
  /**********************************************************/

  InitBitMap( &my_bitmap, DEPTH, WIDTH, HEIGHT );

  /* &my_bitmap: A pointer to the my_bitmap structure. */
  /* DEPTH:      Number of bitplanes to use. */
  /* WIDTH:      The width of the BitMap. (Must be a multiple of 16) */
  /* HEIGHT:     The height of the BitMap. */



  /**********************************************/
  /* 4. Allocate display memory for the BitMap: */
  /**********************************************/

  for( loop=0; loop < DEPTH; loop++)
    if((my_bitmap.Planes[loop] = (PLANEPTR)
      AllocRaster( WIDTH, HEIGHT )) == NULL )
    {
      /* PANIC! Not enough memory */

      /* Deallocate the display memory, Bitplan by Bitplan. */ 
      for( loop=0; loop < DEPTH; loop++)
        if( my_bitmap.Planes[loop] ) /* Deallocate this Bitplan? */
          FreeRaster( my_bitmap.Planes[loop], WIDTH, HEIGHT );

      /* Close the Graphics Library since we have opened it: */
      CloseLibrary( GfxBase );

      /* Close the Intuition Library since we have opened it: */
      CloseLibrary( IntuitionBase );

      exit();
    }

  /* The (PLANEPTR) is not necessary, but you will now not recieve any   */
  /* warnings messages about "pointers do not point to same type of      */
  /* object". This is because my_bitmap.Planes expects to get a          */
  /* memory pointer to some display memory (PLANEPTR), while AllocRaster */
  /* returns an APTR (memory pointer). It is actually no difference      */
  /* between them, but two different names (declarartions) makes the     */
  /* paranoid C compiler worried. To calm it down we make this "casting" */



  /***************************/
  /* 5. Clear all Bitplanes: */
  /***************************/
  
  for( loop=0; loop < DEPTH; loop++)
    BltClear( my_bitmap.Planes[loop], RASSIZE( WIDTH, HEIGHT ), 0);

  /* The memory we allocated for the Bitplanes, is normaly "dirty", and */
  /* therefore needs cleaning. We can here use the Blitter to clear the */
  /* memory since it is the fastest way to do it, and the easiest.      */
  /* RASSIZE is a macro which calculates memory size for a Bitplane of  */
  /* the size WIDTH x HEIGHT. We will later go into more details about  */
  /* these functions etc, so do not worry about them... yet.            */



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
        FreeRaster( my_bitmap.Planes[loop], WIDTH, HEIGHT );

    /* Close the Graphics Library since we have opened it: */
    CloseLibrary( GfxBase );

    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();
  }



  /* Do not bother aboute these commands, since I will explain more */
  /* about them later. I have included them here since I want to put */
  /* some graphics into the window, so you can see how a SuperBitMap */
  /* window works. (Shrink the window, and then enlarge it again, and */
  /* you will noticed that the lines are still there!) */

  SetDrMd( my_window->RPort, JAM1 );

  SetAPen( my_window->RPort, 1 );
  Move( my_window->RPort,  10,  10 );
  Draw( my_window->RPort, 100,  10 );
  Draw( my_window->RPort, 100, 100 );
  Draw( my_window->RPort,  10, 100 );
  Draw( my_window->RPort,  10,  10 );

  SetAPen( my_window->RPort, 2 );
  Move( my_window->RPort,  12,  12 );
  Draw( my_window->RPort,  98,  12 );
  Draw( my_window->RPort,  98,  98 );
  Draw( my_window->RPort,  12,  98 );
  Draw( my_window->RPort,  12,  12 );

  SetAPen( my_window->RPort, 3 );
  Move( my_window->RPort,  14,  14 );
  Draw( my_window->RPort,  96,  14 );
  Draw( my_window->RPort,  96,  96 );
  Draw( my_window->RPort,  14,  96 );
  Draw( my_window->RPort,  14,  14 );



  /* We have opened the window, and everything seems to be OK. */
  /* Wait for 30 seconds: */
  Delay( 50 * 30);



  /********************************************************************/
  /* 8. Do not forget to close the window, AND deallocate the display */
  /*    memory:                                                       */
  /********************************************************************/

  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window );

  /* Deallocate the display memory, Bitplan by Bitplan. */ 
  for( loop=0; loop < DEPTH; loop++)
    if( my_bitmap.Planes[loop] ) /* Deallocate this Bitplan? */
      FreeRaster( my_bitmap.Planes[loop], WIDTH, HEIGHT );



  /* Close the Graphics Library since we have opened it: */
  CloseLibrary( GfxBase );

  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}