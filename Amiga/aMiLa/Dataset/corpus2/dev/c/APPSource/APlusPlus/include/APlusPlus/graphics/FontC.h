#ifndef APP_FontC_H
#define APP_FontC_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/graphics/FontC.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


extern "C" {
#include <graphics/text.h>
#include <exec/types.h>
}


/******************************************************************************************
      » FontC class «

   Each FontC object poses as handle to one Amiga® font.
   The font specifications default to the IntuiRoot Screen's Font which may be proportional.
 ******************************************************************************************/

class FontC
{
   public:
      FontC(UBYTE *fontName = 0,UWORD ySize = 0,UBYTE style = 0,UBYTE flags = 0);
      // defaults to Preferences Screen Font.

      FontC(struct TextAttr* ta);
      FontC(struct TextFont* tf);
      FontC(const FontC& from);
      FontC& operator = (const FontC&);
      ~FontC();

      operator const struct TextFont* () const { return font; }   // conversion operator
      operator const struct TextAttr* () const;
      UWORD ySize() { return font->tf_YSize; }

   private:
      struct TextFont *font;
      void create(UBYTE *fontName,UWORD ySize,UBYTE style,UBYTE flags);
      void copy(const FontC& from);
};
#endif   /* APP_FontC */
