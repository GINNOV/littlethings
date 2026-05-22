/* Window */
#include <intuition/intuition.h>

struct IntuitionBase *IntuitionBase;
struct Window *my_window;
struct Window *my_windowBackdrop;

struct NewWindow my_new_window=
{
  20,            /* LeftEdge    x position of the window. */
  20,            /* TopEdge     y position of the window. */
  200,           /* Width       */
  120,           /* Height      */
  0,             /* DetailPen   */
  1,             /* BlockPen    */
  NULL,          /* IDCMPFlags  */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  //BORDERLESS|    /*             No borders. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget */
  NULL,          /* CheckMark   */
  "Window",		 /* Title       */
  NULL,          /* Screen      */
  NULL,          /* BitMap      */
  80,             /* MinWidth    */
  30,             /* MinHeight   */
  300,             /* MaxWidth    */
  200,             /* MaxHeight */
  WBENCHSCREEN   /* Type        */
};

struct NewWindow my_new_windowBackdrop=
{
  60,            /* LeftEdge    x position of the window. */
  60,            /* TopEdge     y position of the window. */
  200,           /* Width       */
  120,           /* Height      */
  0,             /* DetailPen   */
  1,             /* BlockPen    */
  NULL,          /* IDCMPFlags  */
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  BACKDROP|      /*             Backdrop window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget */
  NULL,          /* CheckMark   */
  "Backdrop",	 /* Title       */
  NULL,          /* Screen      */
  NULL,          /* BitMap      */
  0,             /* MinWidth    */
  0,             /* MinHeight   */
  0,             /* MaxWidth    */
  0,             /* MaxHeight */
  WBENCHSCREEN   /* Type        */
};


main()
{
  IntuitionBase = (struct IntuitionBase *) OpenLibrary( "intuition.library", 0 );
  
  if( IntuitionBase == NULL )
    exit();

  my_window = (struct Window *) OpenWindow( &my_new_window );
  
  if(my_window == NULL)
  {
    CloseLibrary( IntuitionBase );
    exit();  
  }
  
  my_windowBackdrop = (struct Window *) OpenWindow( &my_new_windowBackdrop );
    
  if(my_windowBackdrop == NULL)
  {
	CloseWindow(my_window);
    CloseLibrary( IntuitionBase );
    exit();  
  }
  
  Delay(50 * 10); // 10 saniye bekle

  CloseWindow( my_window );
  CloseWindow ( my_windowBackdrop);
  CloseLibrary( IntuitionBase );
}