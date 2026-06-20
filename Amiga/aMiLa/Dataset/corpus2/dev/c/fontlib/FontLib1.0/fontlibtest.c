//
// FontLibTest.c
// Version 1.0
//
// FontLib ©1996 Henrik Isaksson
// EMail: henriki@pluggnet.se
// All Rights Reserved.
//
// This library is FreeWare.
// If you plan to use any of theese funtions in commercial software,
// ask me first at the address above.
// I can not be held responsible for any damage or loss of data caused
// by this software. Use it at your own risk.
//
// Questions and suggestions to: henriki@pluggnet.se
//

#include <exec/types.h>
#include <exec/memory.h>
#include <intuition/intuition.h>

#include <clib/diskfont_protos.h>
#include <clib/exec_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>

#include <string.h>

#include "fontlib.h"

void main()
{
 struct Window *Wnd=OpenWindowTags(NULL,TAG_DONE);
 FLFont *f;
 int i;

 if(Wnd) {
  SETWFONT(Wnd,"times.font",24,0,0);	// Set Window Font to times.font 24

  for(i=0;i<100;i++) {
   SETWDRAW(Wnd,1,4,1);			// Set Window DrawMode & Pens to FG=1 BG=4 DrawMode=JAM2
   WTEXT(Wnd,10+i,30+i,"Hejsan!");	// Print the text (Hejsan=Hello)
   Delay(1);				// Delay
   SETWDRAW(Wnd,0,0,1);
   WTEXT(Wnd,10+i,30+i,"Hejsan!");	// Delete the old text.
  }

  CloseWindow(Wnd);
 }

 f=FL_LoadFont(XEN11);

 FL_FreeFont(f);


 FL_FreeAll();	// Close all fonts that I 'forgot' to close
}

// The End!
