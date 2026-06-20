/*
**     $VER: DiskFonts.c 0.01 (14-06-95)
**
**     Author:  Gerben Venekamp
**     Updates: 14-06-95  Version 0.01      Intial module
**
**  DiskFonts.c contains the function to manage the diskfonts. It
**  opens and closes fonts and maintains the information necessary
**  for IFFConverter.
**
*/

#include <exec/types.h>
#include <proto/diskfont.h>
#include <proto/graphics.h>

#include "IFFConverter.h"

// Defining variables
APTR SystemFont = NULL;

struct TextAttr System_8 = {
   (STRPTR)"system.font",    // ta_Name
   8,                        // ta_YSize
   FS_NORMAL,                // ta_Style
   0x0                       // ta_Flags
};

// Defining prototpyes
void GetDiskFonts(void);
void CloseFonts(void);

/*
**  GetDiskFonts()
**
**     Loads one or more diskfonts onto RAM. Loaded fonts are:
**        · System.font
**
**  pre:  None.
**  post: None.
*/
void GetDiskFonts()
{
   SystemFont = OpenDiskFont(&System_8);
}


/*
**  CloseFonts()
**
**     Closes all opened fonts for you. Closed fonts are:
**        ·System
**
**  pre:  None.
**  post: None.
*/
void CloseFonts()
{
   if(SystemFont) CloseFont(SystemFont);
}
