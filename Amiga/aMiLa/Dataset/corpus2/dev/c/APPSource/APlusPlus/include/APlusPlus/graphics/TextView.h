#ifndef APP_TextView_H
#define APP_TextView_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/graphics/TextView.h 1.10 (27.07.94) $
 **
 ******************************************************************************/


#include <APlusPlus/graphics/Canvas.h>
#include <APlusPlus/graphics/FontC.h>
#include <APlusPlus/intuition/RawKeyDecoder.h>


/******************************************************************************************
      » TextView class «

   The TextView class visualizes ASCII text within a rectangular view that can be moved
   over the text.
   The way in which the text is provided can be customized, as can the format of the text
   output in matters of color and softstyle be adjusted context-sensitively.

 ******************************************************************************************/

class TextView : public Canvas
{
   public:
      TextView(GOB_OWNER, AttrList& attrs);
      ~TextView();

      void drawSelf();

      ULONG setAttributes(AttrList& attrs);
      ULONG getAttribute(Tag tag,ULONG& dataStore);

      void writeLine(LONG lineNr);           // force rewriting a single line
      LONG lines() { return lineCount; }     // get text length in lines

      BOOL setCursor(LONG lineNr,LONG characterNr);
      void moveCursorTo(int CursorPosTag);      // special cursor positioning on text context
      LONG cursorX() { return crsrx; } // get character under cursor number (1..length of line string)
      LONG cursorY() { return crsry; } // get cursor line (1..lines())

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:
      RawKeyDecoder key;

      virtual void formatOutput(UBYTE* lineText,UWORD length);
      /** formatOutput(text) can be overwritten to establish your special text output.
       ** It is called when TextView finds it necessary to write a line. TextView prepares for
       ** writing, then calles formatOutput with the string that is to be written.
       ** Within this method you have to write the whole string by repeated use of
       ** print(). Positioning is done by TextView. You can change colors and softstyle
       ** between the print() calls. Don't assume any color or softstyle being set on entry.
       ** The default method prints each text line as is.
       **/

      void print(UBYTE* partString,UWORD length);  // used only within formatOutput()

      virtual UBYTE* getLineString(LONG lineNr,UWORD& length)=0;
      /** By calling this method a TextView object demands a 0-terminated string which it
       ** will display as line 'lineNr'. Your overwriting method has to return the address
       ** of the string you want to have displayed as line 'lineNr'. The string will not be
       ** copied and thus must be accessable until the next 'getLineString()' call.
       **/

      void callback(const IntuiMessageC* imsg);

   private:
      FontC font;
      LONG crsrx,crsry,lineCount;   // cursor position in the text
      LONG cviewx,cviewy;           // cursor position in the view (1..visibleXY())
      XYVAL cBoxLeft,cBoxRight;     // cursor box dimensions in pixel
      UBYTE crsrOn;

      BOOL cursorIsOn()
         { return crsrOn==TRUE; }
      void cursorOn()
         { crsrOn = TRUE; }
      void cursorOff()
         { crsrOn = FALSE; }

      void toggleCBox();
      void eraseCBox()
         { if (cursorIsOn()) toggleCBox(); }
      void drawCBox()
         { if (cursorIsOn()) toggleCBox(); }

      LONG topLine()
         { return viewY()+1; }
      LONG visibleLines()
         { return visibleY(); }

      void findCursor();
};

#define TXV_Dummy    (IOTYPE_TEXTVIEW+1)

#define TXV_Columns        (TXV_Dummy + 2)
   /* Unused
   */

#define TXV_Lines          (CNV_Height)
   /* LONG: length of the text to be displayed.
   */

#define TXV_FontName       (TXV_Dummy + 3)
#define TXV_FontSize       (CNV_GranularityY)
   /* Set the font (may be non-proportional) for the text display.
   */

#define TXV_CursorOn       (TXV_Dummy + 4)
   /* BOOL: TRUE for a visible cursor, FALSE for no cursor.
   */
#define TXV_CursorX        (TXV_Dummy + 5)
#define TXV_CursorY        (TXV_Dummy + 6)

#endif
