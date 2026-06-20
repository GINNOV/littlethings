#ifndef APP_ScreenC_H
#define APP_ScreenC_H
/******************************************************************************
 **
 **   C++ Class Library for the Amiga© system software.
 **
 **   Copyright (C) 1994 by Armin Vogt  **  EMail: armin@uni-paderborn.de
 **   All Rights Reserved.
 **
 **   $VER: apphome:APlusPlus/intuition/ScreenC.h 1.10 (27.07.94) $
 **
 ******************************************************************************/

extern "C" {
#include <intuition/screens.h>
}
#include <APlusPlus/graphics/GraphicObject.h>


/******************************************************************************
         » ScreenC class «

   A ScreenC object encapsulates one Intuition screen. The ScreenC constructors
   either create a new screen or lock a public screen specified by name.
 ******************************************************************************/

class ScreenC : public GraphicObject
{
   public:
      ScreenC(OWNER,AttrList& attrs);
      ScreenC(OWNER,UBYTE* name);
      ~ScreenC();

      const struct Screen* screenPtr() // read screen structure
         { return (Screen*)IObject(); }

      ULONG setAttributes(AttrList& attrs);
      ULONG getAttribute(Tag,ULONG&);

      struct DrawInfo* getScreenDrawInfo();
      APTR getVisualInfo();

      BOOL isPublicScreen() // TRUE if 'this' has locked a public screen.
         { return lockOnPublic; }

      // runtime type inquiry support
      static const Intui_Type_info info_obj;
      virtual const Type_info& get_info() const     // get the 'type_id' to an existing object
         { return info_obj; }
      static const Type_info& info()                // get the 'type_id' of a specific class
         { return info_obj; }

   protected:
      struct Screen* screen() // read/write screen structure
         { return (struct Screen*)IObject(); }

   private:
      struct DrawInfo* drawInfo;
      APTR           visualInfo;
      BOOL         lockOnPublic;

      struct Screen*& screen_ref() // read/write screen pointer
         { return (struct Screen*&)IObject(); }

      BOOL fillInfo();

};

#define SCREENC_NOINFO                       (IOTYPE_SCREEN+1)
#define SCREENC_OPENSCREEN_FAILED            (IOTYPE_SCREEN+2)
#define SCREENC_PUBLICSCREEN_NOT_FOUND       (IOTYPE_SCREEN+3)
#endif
