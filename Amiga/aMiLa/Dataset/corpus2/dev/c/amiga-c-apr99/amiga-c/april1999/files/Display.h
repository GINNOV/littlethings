/**************************************************************************

Name       : Display.h
Programmer : Jesse Chan
Version    : 0.01
Date Begun : 03-24-1999
Date Last  : 04-12-1999
Description: Display header

**************************************************************************/

#ifndef DISPLAY_H
#define DISPLAY_H

// DEFINITIONS ////////////////////////////////////////////////////////////

#define WIDTH 640
#define HEIGHT 480
#define DEPTH 3
#define COLORS 8

// FUNCTIONS //////////////////////////////////////////////////////////////

class Display
{
public:
   Display();
   ~Display();
   void OpenDisplay(void);
   void CloseDisplay(void);
   void ClearDisplay(void);
   void Compile_Title(char*, char*, char*);
   void Worms(void);
   void KeyUpdate(void);

   int keypressed;

private:
   int x;
   int y;
   int color;
//   int visible_buffer;
   UWORD colortable[COLORS];
};

///////////////////////////////////////////////////////////////////////////

#endif
