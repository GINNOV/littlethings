/* Window IDCMPFlags */
#include <intuition/intuition.h>

struct IntuitionBase *IntuitionBase;
struct Window *my_window;

struct NewWindow my_new_window=
{
  20,            /* LeftEdge    x position of the window. */
  20,            /* TopEdge     y position of the window. */
  200,           /* Width       */
  120,           /* Height      */
  0,             /* DetailPen   */
  1,             /* BlockPen    */
  CLOSEWINDOW|   /* IDCMPFlags  Close button */
  MOUSEBUTTONS|  /*             user presses/releases the mouse buttons.  */
  MOUSEMOVE|     /*             user moves the mouse  */
  NEWSIZE|        /*             resizes the window */
  ACTIVEWINDOW|   /*             */
  INACTIVEWINDOW| /*             window is activated/deactivated.     */
  RAWKEY|         /*             user presses/releases a key.        */
  SIZEVERIFY|     /*             user resizes the window.        */
  VANILLAKEY|     /*             user presses/releases a key.        */
  DISKINSERTED|   /*             disk inserted */
  DISKREMOVED|    /*             disk removed  */
  INTUITICKS|     /*             recieve simple time */
  REFRESHWINDOW,  /*             refresh (redraw) the window. */
  
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE|   /*             Close Gadget. */
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  WINDOWSIZING|  /*             Sizing Gadget. */
  //BORDERLESS|    /*             No borders. */
  ACTIVATE|      /*             Active when opened. */
  RMBTRAP|       /*             Recieve MOUSEBUTTONS events even if the right    */
                 /*             mouse button is pressed. */
  REPORTMOUSE,   /*             Create MOUSEMOVE messages */

  NULL,          /* FirstGadget */
  NULL,          /* CheckMark   */
  "IDCMP",		 /* Title       */
  NULL,          /* Screen      */
  NULL,          /* BitMap      */
  80,             /* MinWidth    */
  30,             /* MinHeight   */
  300,             /* MaxWidth    */
  200,             /* MaxHeight */
  WBENCHSCREEN   /* Type        */
};

main()
{
	BOOL close_me;
	ULONG class; /* IDCMP flag */
	USHORT code; /* Code */
	SHORT x, y;  /* Position of the mouse (x,y) */
	BOOL mouse_moved;
	USHORT qualifier; /* Qualifier. */
	ULONG seconds; /* Seconds */
	ULONG micros;  /* Micros */
	
	struct IntuiMessage *my_message;

	IntuitionBase = (struct IntuitionBase *) OpenLibrary( "intuition.library", 0 );

	if( IntuitionBase == NULL )
		exit();

	my_window = (struct Window *) OpenWindow( &my_new_window );

	if(my_window == NULL)
	{
		CloseLibrary( IntuitionBase );
		exit();  
	}

	close_me = FALSE;
	
	while(!close_me)
	{
		mouse_moved = FALSE;
		
		Wait( 1 << my_window->UserPort->mp_SigBit );
		while(my_message = (struct IntuiMessage *) GetMsg(my_window->UserPort))
		{
			class= my_message->Class;
			code= my_message->Code;
			qualifier= my_message->Qualifier; /* Qualifier */
			x= my_message->MouseX; /* X position of the mouse */
			y= my_message->MouseY; /* Y position of the mouse */
			seconds = my_message->Seconds; /* Seconds */
			micros = my_message->Micros;   /* Micros */
			
			if(class==SIZEVERIFY)
			{
				printf("Resize the window\nSIZEVERIFY\n");
			}
			
			ReplyMsg(my_message);
			
			switch(class)
			{
				case CLOSEWINDOW:
					close_me = TRUE;
					printf("window closed\n");
					break;
					
				case MOUSEMOVE:    /* The user moved the mouse. */
					mouse_moved = TRUE;
					break;
					
				case MOUSEBUTTONS:
					switch(code)
					{
						case SELECTDOWN:
							printf("LMB pressed\n");
							break;
						case SELECTUP:
							printf("LMB released\n");
							break;
						case MENUDOWN:
							printf("RMB pressed\n");
							break;
						case MENUUP:
							printf("RMB released\n");
							break;		
					}
					break;
				
				case NEWSIZE:        /* The user resized the window. */
						printf("window resized\n");
						printf("Width: %d\n", my_window->Width);
						printf("Height: %d\n", my_window->Height);
				break;

				case ACTIVEWINDOW:   /* Window actiavted. */
						printf("Window activated!\n");
				break;

				case INACTIVEWINDOW: /* Window inactiavted. */
						printf("Window inactivated!\n");
				break;
				
				case RAWKEY:
						/* Print out the raw keycode (both as decimal and hex.): */
						printf("Raw keycode: %6d(d) %6x(h)\n", code, code );
					   
						/* Print out the qualifier (both as decimal and hex.): */
						printf("Qualifier:   %6d(d) %6x(h)\n", qualifier, qualifier);
					   
						/* SHIFT or CTRL */
						/* qualifier key was also pressed:                 */
						if( qualifier &= IEQUALIFIER_LSHIFT )
							printf("Left SHIFT button pressed\n");

						if( qualifier &= IEQUALIFIER_RSHIFT )
							printf("Right SHIFT button pressed\n");
					   
						if( qualifier &= IEQUALIFIER_CONTROL )
							printf("CTRL button pressed\n");
				break;
				
				case VANILLAKEY:     /* The user pressed/released a key! */
				   printf("Translated keycode: %6d(d) %6x(h)\n\n", code, code );   
				break;
				
				case DISKINSERTED:   /* The user inserted a disk in a drive. */
					printf("Disk inserted!\n");
				break;

				case DISKREMOVED:    /* The user removed a disk from a drive. */
					printf("Disk removed!\n");
				break;
				
				case INTUITICKS:     /* Time event. */
					//printf("Seconds: %6d  Micros: %6d\n", seconds, micros);
				break;
				
				case REFRESHWINDOW:  /* You need to update the window. */
					printf("Redraw the window\n");
					BeginRefresh( my_window );
					/* Redraw the window */
					EndRefresh( my_window );
				break;
			}
			
			if( mouse_moved )
			{
			  //printf("Mouse position: (%d, %d)\n", x, y);
			}
		}
	}

	CloseWindow( my_window );
	CloseLibrary( IntuitionBase );
}