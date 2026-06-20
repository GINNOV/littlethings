/**************************************************************************

Name       : Display.cpp
Programmer : Jesse Chan
Version    : 0.01
Date Begun : 03-24-1999
Date Last  : 04-12-1999
Description: Display member functions

Completed  : - Opens a Multiscan:Productivity 640x480 custom screen!
             - Created an 8-color palette to go with it
             - Added a clear screen function using BltClear

To do list : - Add Double Buffering....

**************************************************************************/

// INCLUDES ///////////////////////////////////////////////////////////////

#include <proto/exec.h> // OpenLibrary, CloseLibrary
#include <proto/graphics.h>
#include <proto/intuition.h>

#include <exec/memory.h>
#include <exec/types.h>
#include <graphics/gfxbase.h>
#include <intuition/intuition.h>

#include <iostream.h>
#include <math.h>
#include <string.h>

#include "Display.h"
#include "Keys.h"

// STRUCTS ////////////////////////////////////////////////////////////////

struct IntuitionBase *IntuitionBase = NULL;
struct GfxBase *GfxBase = NULL;

struct RastPort *myrastport = NULL;
struct Screen   *myscreen = NULL;
struct Window   *mywindow = NULL;

//struct ScreenBuffer *sbuffer[2] = { NULL };

// FUNCTIONS //////////////////////////////////////////////////////////////

Display::Display()
{
   x = WIDTH/2;
   y = HEIGHT/2;
   color = 1;
//visible_buffer = 0;

   colortable[0] = 0x007; // Dark Blue
   colortable[1] = 0xFFF; // White
   colortable[2] = 0x999; // Gray
   colortable[3] = 0xF00; // Red
   colortable[4] = 0xFF0; // Yellow
   colortable[5] = 0x083; // Light Green
   colortable[6] = 0x0BB; // Blue-Green
   colortable[7] = 0x73F;  // Medium Blue

   OpenDisplay();

} // End Constructor

///////////////////////////////////////////////////////////////////////////

Display::~Display()
{
   CloseDisplay();

} // End Destructor

///////////////////////////////////////////////////////////////////////////

void Display::OpenDisplay(void)
{
   if(!(IntuitionBase = (struct IntuitionBase *)
      OpenLibrary( (unsigned char *)"intuition.library",0)))
   {
      cerr << "Could not open Intuition.library!" << endl;
   }

   if(!(GfxBase = (struct GfxBase *)
      OpenLibrary( (unsigned char *)"graphics.library",0)))
   {
      cerr << "Could not open Graphics.library!" << endl;
   }

   myscreen = OpenScreenTags( NULL,
                                SA_DisplayID, VGAPRODUCT_KEY,
                                SA_Width, WIDTH,
                                SA_Height, HEIGHT,
                                SA_Depth, DEPTH,
                                SA_ShowTitle, FALSE,
                                SA_Title, (char *)"GFX",
                                SA_SysFont, NULL,
                                SA_Type, CUSTOMSCREEN,
                                SA_Quiet, TRUE,
                                TAG_END );
   // Good to clear everything in random memory
   ClearDisplay();

   mywindow = OpenWindowTags( NULL,
                                WA_Width, WIDTH,
                                WA_Height, HEIGHT,
                                WA_Title, FALSE,
                                WA_Backdrop, TRUE,
                                WA_Borderless, TRUE,
                                WA_Gadgets, FALSE,
                                WA_Activate, TRUE,
                                WA_SimpleRefresh, TRUE,
                                WA_RMBTrap, TRUE,
                                WA_CustomScreen, myscreen,
                                WA_IDCMP,
                                IDCMP_RAWKEY,
                                TAG_END );

  myrastport = mywindow->RPort;

  // Open palette old style, LoadRGB4
  // use LoadRGB32 for AGA palettes
  LoadRGB4(&myscreen->ViewPort, colortable, pow2(DEPTH) );
//sbuffer[0] = AllocScreenBuffer(myscreen, NULL, SB_SCREEN_BITMAP);
//sbuffer[1] = AllocScreenBuffer(myscreen, NULL, SB_COPY_BITMAP);

} // End OpenDisplay

///////////////////////////////////////////////////////////////////////////

void Display::CloseDisplay(void)
{
//FreeScreenBuffer(myscreen, sbuffer[1]);
//FreeScreenBuffer(myscreen, sbuffer[0]);

   if(mywindow)
      CloseWindow(mywindow);
   if(myscreen)
      CloseScreen(myscreen);
   if(GfxBase)
      CloseLibrary( (struct Library *)GfxBase );
   if(IntuitionBase)
      CloseLibrary( (struct Library *)IntuitionBase );

} // End CloseDisplay

///////////////////////////////////////////////////////////////////////////

void Display::ClearDisplay(void)
{
  // Clear screen with blitter
  for (int i = 0; i < DEPTH; i++)
  {
     BltClear( (&myscreen->RastPort)->BitMap->Planes[i], (myscreen->Width/8)*myscreen->Height, 0L );
  }

} // End ClearDisplay

///////////////////////////////////////////////////////////////////////////

void Display::Compile_Title(char* string, char* date, char* time)
{
   SetDrMd(myrastport, JAM1);
   SetAPen(myrastport, 1);

   Move(myrastport, 10, 10);
   Text(myrastport, string, strlen(string));
   Move(myrastport, 10, 30);
   Text(myrastport, date, strlen(date));
   Move(myrastport, 10, 40);
   Text(myrastport, time, strlen(time));

} // End Compile_Title

///////////////////////////////////////////////////////////////////////////

void Display::Worms(void)
{
   SetDrMd(myrastport, JAM1);

   SetAPen(myrastport, 0);
   Move(myrastport, WIDTH/2, HEIGHT/2);
   Draw(myrastport, x, y);

   switch(keypressed)
   {
      case KEY_CURS_UP:
         y--;
      break;

      case KEY_CURS_DOWN:
         y++;
      break;

      case KEY_CURS_LEFT:
         x--;
      break;

      case KEY_CURS_RIGHT:
         x++;
      break;
   }

   // Clipping boundaries
   if(x < 0)
      x = 0;
   if(x > WIDTH-1)
      x = WIDTH-1;
   if(y < 0)
      y = 0;
   if(y > HEIGHT-1)
      y = HEIGHT-1;

   SetAPen(myrastport, color);
   Move(myrastport, WIDTH/2, HEIGHT/2);
   Draw(myrastport, x, y);

//visible_buffer^=1;
//ChangeScreenBuffer(myscreen, sbuffer[visible_buffer]);
WaitTOF();

} // End Worms

///////////////////////////////////////////////////////////////////////////

void Display::KeyUpdate(void)
{
   struct IntuiMessage *msg;

   // loop where to handle all messages
   while(msg = (struct IntuiMessage *)GetMsg(mywindow->UserPort))
   {
      keypressed  = msg->Code;
      ReplyMsg((struct Message *)msg); // reply to message
   }

} // End KeyUpdate

///////////////////////////////////////////////////////////////////////////



