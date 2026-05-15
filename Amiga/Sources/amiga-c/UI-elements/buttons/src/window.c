#include "proto.h"
#include <intuition/intuition.h>


struct IntuitionBase *IntuitionBase;
struct Window *window;
struct RastPort *windowContext;
struct EventInfo event;
ULONG signalmask;
ULONG signals;
int windowMarginTop = 0;
int windowMarginLeft = 0;

struct NewWindow winlayout = {
  40,            /* LeftEdge    x position of the window. */
  20,            /* TopEdge     y positio of the window. */
  250,           /* Width       250 pixels wide. */
  150,           /* Height      150 lines high. */
  0,             /* DetailPen   Text should be drawn with colour reg. 0 */
  1,             /* BlockPen    Blocks should be drawn with colour reg. 1 */
  CLOSEWINDOW | IDCMP_MOUSEBUTTONS,          
  SMART_REFRESH| /* Flags       Intuition should refresh the window. */
  WINDOWCLOSE| 
  WINDOWDRAG|    /*             Drag gadget. */
  WINDOWDEPTH|   /*             Depth arrange Gadgets. */
  ACTIVATE,      /*             The window should be Active when opened. */
  NULL,          /* FirstGadget No Custom Gadgets. */
  NULL,          /* CheckMark   Use Intuition's default CheckMark (v). */
  "Buttons",  /* Title       Title of the window. */
  NULL,          /* Screen      Connected to the Workbench Screen. */
  NULL,          /* BitMap      No Custom BitMap. */
  0,             /* MinWidth    We do not need to care about these */
  0,             /* MinHeight   since we have not supplied the window */
  0,             /* MaxWidth    with a Sizing Gadget. */
  0,             /* MaxHeight */
  WBENCHSCREEN   /* Type        Connected to the Workbench Screen. */
};


unsigned char openDisplay(void){
  /* Open the Intuition Library: */
  IntuitionBase = (struct IntuitionBase *) OpenLibrary( "intuition.library", 0 );
  if( IntuitionBase == NULL ) return(1);

  window = OpenWindow(&winlayout);
  if(window == NULL){
    CloseLibrary( IntuitionBase );
     return(1);
  }
  windowContext = window->RPort;
  windowMarginTop = window->BorderTop;
  windowMarginLeft = window->BorderLeft;

  signalmask = 1L << window->UserPort->mp_SigBit;
  return(0);
}

void closeDisplay(void){
    CloseWindow(window );
    CloseLibrary(IntuitionBase);
}


SHORT waitUserAction(){
  signals = Wait(signalmask);
  if (signals & signalmask) return(1);
  return(0);
}

struct EventInfo getUserEvent()
{
    struct IntuiMessage *message = NULL;
    USHORT code;
    ULONG classId;
    SHORT mx, my;

    event.mouseButton = 0;
    event.exit = 0;

    /* Examine pending messages */
    while( message = (struct IntuiMessage *)GetMsg(window->UserPort) ) {

        classId = message->Class;
        code = message->Code;
        mx = message->MouseX;
        my = message->MouseY;

        /* When we're through with a message, reply */
        ReplyMsg( (struct Message *)message);

        /* See what events occurred */
        switch( classId ) {
          case CLOSEWINDOW:  /* The user selected the Close window gadget! */
                    event.exit = 1;
                    break;
            case MOUSEBUTTONS:
                event.mouseX = mx;
                event.mouseY = my;
                switch( code )
                {
                    case SELECTUP:
                        printf( "Left Mouse UP at %d,%d\n",mx,my );
                        event.mouseButton = -1;
                        break;
                    case SELECTDOWN:
                        printf( "Left Mouse DOWN at %d,%d\n",mx,my );
                        event.mouseButton = 1;
                        break;
                    case MENUUP:
                         printf( "Right Mouse UP at %d,%d\n",mx,my );
                        event.mouseButton = -2;
                         break;
                    case MENUDOWN:
                         printf( "Right Mouse DOWN at %d,%d\n",mx,my );
                        event.mouseButton = 2;
                         break;
                    default:
                    	printf("other %d\n",code);
                };
		    break;
        }
    }

    /* Flush any remaining pending messages */
    while( message = (struct IntuiMessage *)GetMsg(window->UserPort)) ReplyMsg( (struct Message *)message );

    return(event);
}
