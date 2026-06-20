/* Example10                                                             */
/* This program will open a two normal windows with all system gadgets   */
/* connected to them. If the first window is Activated, the pointer will */
/* chage shapes into a Zzz symbol, if the second window is activated,    */
/* the pointer will look like a pistol.                                  */



/* If your program is using Intuition you should include intuition.h: */
#include <intuition/intuition.h>



struct IntuitionBase *IntuitionBase;



/* Declare a pointer to the first Window structure: */ 
struct Window *my_window1;

/* Declare and initialize your first NewWindow structure: */
struct NewWindow my_new_window1=
{
  50,            /* LeftEdge    x position of the window. */
  25,            /* TopEdge     y positio of the window. */
  200,           /* Width       200 pixels wide. */
  150,           /* Height      150 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING,  /*             Sizing Gadget. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "Zzz",         /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  300,           /* MaxWidth    than 300 x 200. */
  200,           /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* Declare a pointer to the second Window structure: */ 
struct Window *my_window2;

/* Declare and initialize your second NewWindow structure: */
struct NewWindow my_new_window2=
{
  300,           /* LeftEdge    x position of the window. */
  25,            /* TopEdge     y positio of the window. */
  200,           /* Width       200 pixels wide. */
  150,           /* Height      150 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  NULL,          /* IDCMPFlags  No IDCMP flags. */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING,  /*             Sizing Gadget. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "BANG!",       /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  80,            /* MinWidth    We will not allow the window to become */
  30,            /* MinHeight   smaller than 80 x 30, and not bigger */
  300,           /* MaxWidth    than 300 x 200. */
  200,           /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};



/* Declare and initialize Sprite data for the Pointers: */

/* Zzz: (16 x 16  pixels) */
USHORT chip sprite_data_Zzz[36]=
{
	0x0000, 0x0000,  /* Used by Intuition only. */

	0x0300, 0x0000,
	0x1F9C, 0x0300,
	0x3FFE, 0x1F9C,
	0x63E3, 0x3FFE,
	0x7A3B, 0x3FFE,
	0xF7B7, 0x7FFE,
	0xEF63, 0x7FFE,
	0xE23F, 0x7FFE,
	0x7FFE, 0x3FC0,
	0x3fC0, 0x0F80,
	0x0FB0, 0x0000,
	0x0078, 0x0030,
	0x0030, 0x0000,
	0x0004, 0x0000,
	0x000E, 0x0004,
	0x0004, 0x0000,

	0x0000, 0x0000  /* Used by Intuition only. */
};

/* Pistol: (16 x 11  pixels) */
USHORT chip sprite_data_Pistol[26]=
{
	0x0000, 0x0000,  /* Used by Intuition only. */

	0x0000, 0x4010,
	0x0000, 0xFFF8,
	0x01E0, 0xFE18,
	0x00E0, 0x071C,
	0x0000, 0x03FC,
	0x001C, 0x027E,
	0x001C, 0x02BF,
	0x001E, 0x01FF,
	0x001E, 0x003F,
	0x000E, 0x001F,
	0x0000, 0x001F,

	0x0000, 0x0000  /* Used by Intuition only. */
};



main()
{
  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *)
    OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit(); /* Could NOT open the Intuition Library! */



  /* We will now try to open the first window: */
  my_window1 = (struct Window *) OpenWindow( &my_new_window1 );
  
  /* Have we opened the first window succesfully? */
  if(my_window1 == NULL)
  {
    /* Could NOT open the first Window! */
    
    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We will now try to open the second window: */
  my_window2 = (struct Window *) OpenWindow( &my_new_window2 );

  /* Have we opened the second window succesfully? */
  if(my_window2 == NULL)
  {
    /* Could NOT open the second Window! */
    
    /* Close the first window: */
    CloseWindow( my_window1 );
    
    /* Close the Intuition Library since we have opened it: */
    CloseLibrary( IntuitionBase );

    exit();  
  }



  /* We will now call the function SetPointer() to change the windows */
  /* default pointer: */
  SetPointer( my_window1, sprite_data_Zzz, 16, 16, 0, 0);
  SetPointer( my_window2, sprite_data_Pistol, 11, 16, 0, -1);



  /* We have opened the windows, and everything seems to be OK. */
  /* Wait for 30 seconds: */
  Delay( 50 * 30);



  /* We should always close the windows we have opened before we leave: */
  CloseWindow( my_window2 );
  CloseWindow( my_window1 );


  
  /* Close the Intuition Library since we have opened it: */
  CloseLibrary( IntuitionBase );
  
  /* THE END */
}